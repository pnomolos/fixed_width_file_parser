require 'spec_helper'

describe FixedWidthFileParser do
  it 'has a version number' do
    expect(FixedWidthFileParser::VERSION).not_to be nil
  end

  describe '#parse' do
    let (:filepath) { File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec/fixtures/fixed_width_file.txt')) }
    let (:fields)   {
                      [
                        { name: 'first_name',     position: 0..24 },
                        { name: 'middle_initial', position: 25 },
                        { name: 'last_name',      position: 26..50 },
                        { name: 'address',        position: 51..100 },
                        { name: 'city',           position: 101..125 },
                        { name: 'state',          position: 126..128 },
                        { name: 'zip',            position: 130..145 },
                      ]
                    }

    it 'raises an error if `filepath` is not a String' do
      fake_filepath = 123
      expect{
        FixedWidthFileParser.parse(fake_filepath, fields) do
        end
      }.to raise_error(RuntimeError, "`filepath` must be a String")
    end

    it 'raises an error if `fields` is not an Array' do
      fake_fields = 123
      expect{
        FixedWidthFileParser.parse(filepath, fake_fields) do
        end
      }.to raise_error(RuntimeError, "`fields` must be an Array")
    end

    it 'raises an error if `fields` does not have any items' do
      fake_fields = []
      expect{
        FixedWidthFileParser.parse(filepath, fake_fields) do
        end
      }.to raise_error(RuntimeError, "`fields` must contain at least 1 item")
    end

    it 'raises an error if all `fields` do not contain a `name` and `position`' do
      fake_fields = fields
      fake_fields.last.delete(:name)
      expect{
        FixedWidthFileParser.parse(filepath, fake_fields) do
        end
      }.to raise_error(RuntimeError, "Each field hash must include a `name` and a `position`")
    end

    it 'raises an error if `position` is not a Range or an Integer' do
      fake_fields = fields
      fake_fields.last[:position] = nil
      expect{
        FixedWidthFileParser.parse(filepath, fake_fields) do
        end
      }.to raise_error(RuntimeError, "Each field's `position` must be a Range or an Integer")
    end

    it 'yields a hash of the `fields` passed in for each line of the file containing the correct data' do
      expect{ |b|
        FixedWidthFileParser.parse(filepath, fields, &b)
      }.to yield_control.exactly(2).times

      line_1_data = {first_name: 'Jim', middle_initial: 'B', last_name: 'Smith', address: '123 W. Main St.', city: 'Comstock Park', state: 'MI', zip: '49321'}
      line_2_data = {first_name: 'John', middle_initial: 'S', last_name: 'Doe', address: '345 E. Second St.', city: 'Grand Rapids', state: 'MI', zip: '49555'}

      expect{ |b|
        FixedWidthFileParser.parse(filepath, fields, &b)
      }.to yield_successive_args(line_1_data, line_2_data)
    end
  end
end
