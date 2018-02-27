class FixedWidthFileParser
  # Parse a fixed width file, yielding the proper data for each line based on the fields passed in
  #
  # @param filepath [String] The path to the file to be parsed.
  # @param fields [Array(Hash{name => String, position => Range|Integer})] An array of field hashes, each containing a `name` and a `position`.
  # @yield [Hash] Yields a hash object based on the fields provided.
  #
  # @example
  # filepath = 'path/to/file'
  # fields = [
  #   { name: 'first_name', position: 0..10 },
  #   { name: 'middle_initial', position: 11 },
  #   { name: 'last_name', position: 12..25 }
  # ]
  #
  # FixedWidthFileParser.parse(filepath, fields) do |row|
  #   puts row
  # end

  def self.parse(filepath, fields, options = {}, &block)
    GC.start
    new(filepath, fields, options).each(&block)
    GC.start
  end

  def initialize(filepath, fields, options = {})
    @options = {
      force_utf8_encoding: true,
      symbolize_keys: true
    }.merge(options)

    check_errors(filepath, fields)
    @filepath = filepath
    @fields = fields
    offset = 0
    @scan_regex = fields.each_with_object([]) do |field, memo|
      first, last = field[:position].is_a?(Range) || field[:position].is_a?(Array) ? [field[:position].first, field[:position].last] : [field[:position], field[:position]]
      memo << ".{#{first - offset}}" if first - offset > 0
      # For the last item we allow it to not reach the full length
      memo << if field == fields.last
                "(.{1,#{last - first + 1}})"
              else
                "(.{#{last - first + 1}})"
              end
      offset = last + 1
    end.join('')
    @scan_regex = Regexp.new(@scan_regex)

    @field_keys = fields.map { |f| f[:name] }.map { |k| @options[:symbolize_keys] ? k.to_sym : k }

    @io = filepath.respond_to?(:readline) ? filepath : File.open(filepath)
    @input_is_io = @io == filepath
    initialize_enumerator
  end

  def initialize_enumerator
    if @options[:skip_lines].to_i > 0
      @options[:skip_lines].times do
        @io.readline unless @io.eof?
      end
    end
    @seek_position = @io.pos
    @enumerator = Enumerator::Lazy.new(@io.each_line) do |yielder, line|
      l = read_line(line)
      next unless l
      yielder.yield(l)
    end
  end

  def check_errors(filepath, fields)
    # Verify `filepath` is a String or IO object
    raise '`filepath` must be a String or IO' unless filepath.is_a?(String) || filepath.respond_to?(:readline)

    # Verify `fields` is an array
    if fields.is_a?(Array)
      # Verify fields is not emtpy
      raise '`fields` must contain at least 1 item' if fields.empty?
    else
      raise '`fields` must be an Array'
    end

    # Verify each field has a `name` and `position`
    unless fields.all? { |item| item.key?(:name) && item.key?(:position) }
      raise 'Each field hash must include a `name` and a `position`'
    end

    # Verify that each `position` is either a Range or an Integer
    unless fields.all? { |item| item[:position].is_a?(Range) || item[:position].is_a?(Integer) }
      raise "Each field's `position` must be a Range or an Integer"
    end
  end

  def read_line(line)
    line = line.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '') if @options[:force_utf8_encoding]
    return nil if line.empty?
    begin
      @field_keys.zip(line.scan(@scan_regex).flatten.map(&:strip)).to_h
    rescue ArgumentError => e
      if e.message =~ /@ outside of string/
        raise ArgumentError, "Invalid line"
      else
        raise
      end
    end
  end

  # Lazy stuff
  def each(&block)
    return @enumerator unless block_given?
    begin
      r = @enumerator.each(&block)
    ensure
      close_io
    end
    r
  end

  def rewind
    @io.seek(@seek_position)
    @enumerator.rewind
  end

  def to_a
    r = @enumerator.to_a
    close_io
    r
  end

  def close_io
    @io.close unless @lazy_csv.instance_variable_get(:@input_is_io)
  end
  alias force to_a
end
