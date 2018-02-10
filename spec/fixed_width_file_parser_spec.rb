# frozen_string_literal: true
require 'spec_helper'

describe FixedWidthFileParser do
  it 'has a version number' do
    expect(FixedWidthFileParser::VERSION).not_to be nil
  end

  describe '#parse' do
    let (:filepath) { File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec/fixtures/fixed_width_file.txt')) }
    let (:fields)   do
      [
        { name: 'first_name',     position: 0..24 },
        { name: 'middle_initial', position: 25 },
        { name: 'last_name',      position: 26..50 },
        { name: 'address',        position: 51..100 },
        { name: 'city',           position: 101..125 },
        { name: 'state',          position: 126..128 },
        { name: 'zip',            position: 130..145 }
      ]
    end
    let (:line_1_data) { { first_name: 'Jim', middle_initial: 'B', last_name: 'Smith', address: '123 W. Main St.', city: 'Comstock Park', state: 'MI', zip: '49321' } }
    let (:line_2_data) { { first_name: 'John', middle_initial: 'S', last_name: 'Doe', address: '345 E. Second St.', city: 'Grand Rapids', state: 'MI', zip: '49555' } }

    it 'raises an error if `filepath` is not a String or IO object' do
      fake_filepath = 123
      expect do
        FixedWidthFileParser.parse(fake_filepath, fields) do
        end
      end.to raise_error(RuntimeError, '`filepath` must be a String')
    end

    it 'raises an error if `fields` is not an Array' do
      fake_fields = 123
      expect do
        FixedWidthFileParser.parse(filepath, fake_fields) do
        end
      end.to raise_error(RuntimeError, '`fields` must be an Array')
    end

    it 'raises an error if `fields` does not have any items' do
      fake_fields = []
      expect do
        FixedWidthFileParser.parse(filepath, fake_fields) do
        end
      end.to raise_error(RuntimeError, '`fields` must contain at least 1 item')
    end

    it 'raises an error if all `fields` do not contain a `name` and `position`' do
      fake_fields = fields
      fake_fields.last.delete(:name)
      expect do
        FixedWidthFileParser.parse(filepath, fake_fields) do
        end
      end.to raise_error(RuntimeError, 'Each field hash must include a `name` and a `position`')
    end

    it 'raises an error if `position` is not a Range or an Integer' do
      fake_fields = fields
      fake_fields.last[:position] = nil
      expect do
        FixedWidthFileParser.parse(filepath, fake_fields) do
        end
      end.to raise_error(RuntimeError, "Each field's `position` must be a Range or an Integer")
    end

    context 'with a filepath' do
      it 'yields a hash of the `fields` for each line' do
        expect do |b|
          FixedWidthFileParser.parse(filepath, fields, &b)
        end.to yield_control.exactly(2).times
      end

      it 'yields a hash of the `fields` with the the correct data' do
        expect do |b|
          FixedWidthFileParser.parse(filepath, fields, &b)
        end.to yield_successive_args(line_1_data, line_2_data)
      end
    end

    context 'with an IO object' do
      let (:file) { File.open(filepath) }

      it 'yields a hash of the `fields` for each line' do
        expect do |b|
          FixedWidthFileParser.parse(file, fields, &b)
        end.to yield_control.exactly(2).times
      end

      it 'yields a hash of the `fields` with the the correct data' do
        expect do |b|
          FixedWidthFileParser.parse(file, fields, &b)
        end.to yield_successive_args(line_1_data, line_2_data)
      end
    end

    context 'with :skip_lines set' do
      it 'skips over the lines' do
        expect do |b|
          FixedWidthFileParser.parse(filepath, fields, skip_lines: 1, &b)
        end.to yield_successive_args(line_2_data)
      end

      it "doesn't error if you skip more than the lines in the file" do
        expect do |b|
          FixedWidthFileParser.parse(filepath, fields, skip_lines: 3, &b)
        end.to yield_control.exactly(0).times
      end
    end

    context 'a file with invalid UTF8 characters' do
      before do
        # Set readline to return an invalid UTF8 charater in order to test our handling of that
        allow_any_instance_of(File).to receive(:readline).and_return("\255")
        # Make sure eof? returns true after first attempt in order to prevent an infinite loop
        allow_any_instance_of(File).to receive(:eof?).and_return(false, true)
      end

      context 'with option force_utf8_encoding set to true (default)' do
        it 'does not raise any errors' do
          expect do
            FixedWidthFileParser.parse(filepath, fields, force_utf8_encoding: true) do
            end
          end.not_to raise_error
        end
      end

      context 'with option force_utf8_encoding set to false' do
        it 'raises an error' do
          expect do
            FixedWidthFileParser.parse(filepath, fields, force_utf8_encoding: false) do
            end
          end.to raise_error(ArgumentError, 'invalid byte sequence in UTF-8')
        end
      end
    end
  end
end
