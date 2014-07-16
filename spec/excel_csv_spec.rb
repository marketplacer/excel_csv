# encoding: utf-8

require 'rspec'
require 'excel_csv'
require 'tempfile'
require 'active_support'
require 'active_support/core_ext/string'

# rubocop:disable UnneededPercentQ
# https://github.com/bbatsov/rubocop/issues/1210

describe 'ExcelCSV' do
  def write_csv s
    # Using ASCII-8BIT below ensures our text doesn't get transcoded.
    @spreadsheet_file = Tempfile.new(%w{spreadsheet .csv}, encoding: 'ASCII-8BIT')
    @spreadsheet_file.write s
    @spreadsheet_file.close
    @spreadsheet_file.path
  end

  after do
    @spreadsheet_file.delete if @spreadsheet_file
  end

  describe 'read' do
    let(:expected) { [["Ad ID", "Custom Code"]] }

    it "should read in a regular CSV" do
      rows = ExcelCSV.read write_csv("Ad ID,Custom Code\n")
      expect(rows).to eq(expected)
    end

    it "should read in a spreadsheet with a sep=; special first line" do
      rows = ExcelCSV.read write_csv <<-EOF.strip_heredoc
        sep=;
        Ad ID;Custom Code
      EOF

      expect(rows).to eq(expected)
    end

    it "should auto-detect semicolons as the separator, even if missing the sep= line" do
      rows = ExcelCSV.read write_csv("Ad ID;Custom Code\n")
      expect(rows).to eq(expected)
    end

    it "should read in a DOS-encoded spreadsheet with a sep=; special first line" do
      rows = ExcelCSV.read write_csv <<-EOF.strip_heredoc.gsub("\n", "\r\n")
        sep=;
        Ad ID;Custom Code
      EOF

      expect(rows).to eq(expected)
    end

    it "should read in Windows-1252 encoded characters and express them as UTF-8" do
      rows = ExcelCSV.read write_csv("Ad Id,Fahrräder".encode('Windows-1252'))
      expect(rows).to eq([["Ad Id", "Fahrräder"]])
    end

    it "should allow the encoding to be passed as an option" do
      rows = ExcelCSV.read write_csv("Ad Id,Fahrräder".encode('UTF-16')), encoding: 'UTF-16'
      expect(rows).to eq([["Ad Id", "Fahrräder"]])
    end

    it "should pass options through to CSV.new" do
      file = write_csv <<-EOF.strip_heredoc
        Alpha,Beta
        55,44
      EOF
      rows = ExcelCSV.read file, headers: true
      expect(rows['Alpha'][0]).to eq("55")
      expect(rows['Beta'][0]).to eq("44")
    end

    it "should take an optional block" do
      ExcelCSV.read write_csv("Ad ID;Custom Code\n") do |row|
        expect(row).to eq(['Ad ID', 'Custom Code'])
      end
    end

  end

  describe 'parse' do
    it "should read the CSV from a string, following the same rules as read" do
      s = <<-EOF.strip_heredoc.encode('Windows-1252')
        sep=;
        Alpha;Beta
        55;Fahrräder
      EOF

      rows = ExcelCSV.parse s, headers: true

      expect(rows['Alpha'][0]).to eq("55")
      expect(rows['Beta'][0]).to eq("Fahrräder".encode('Windows-1252'))
    end
  end

  describe 'generate' do
    it "should bitch if you try to invoke it without a block" do
      expect { ExcelCSV.generate }.to raise_error ArgumentError
    end

    it "should generate a regular CSV with DOS line endings, adding a sep=, header" do
      output = ExcelCSV.generate do |csv|
        csv << %w{Ad Brand}
        csv << %w{1 Tre"k}
      end
      expect(output).to eq(%Q(sep=,\r\nAd,Brand\r\n1,"Tre""k"\r\n))
    end

    it "should convert UTF-8 characters in to Windows-1252" do
      output = ExcelCSV.generate { |c| c << %w{Fahrräder} }
      expect(output).to eq("sep=,\r\nFahrräder\r\n".encode('Windows-1252'))
    end

    it "should replace non-encodable characters with a placeholder" do
      output = ExcelCSV.generate { |c| c << %w{hai壱} }
      expect(output).to eq("sep=,\r\nhai?\r\n")
    end

    it "should pass through options to CSV.generate" do
      output = ExcelCSV.generate(force_quotes: true) { |c| c << %w{a b} }
      expect(output).to eq(%Q(sep=,\r\n"a","b"\r\n))
    end
  end

  describe "write" do
    it "should write a CSV to a file, following the same rules as generate" do
      @spreadsheet_file = Tempfile.new(%w{spreadsheet .csv})
      @spreadsheet_file.close
      ExcelCSV.write(@spreadsheet_file.path, force_quotes: true) do |csv|
        csv << %w{Ad hai壱}
        csv << %w{1 Fahrräder}
      end
      contents = File.open(@spreadsheet_file.path, 'rb').read
      expected = %Q(sep=,\r\n"Ad","hai?"\r\n"1","Fahrräder"\r\n).encode('Windows-1252')
      expect(contents).to eq(expected.force_encoding('ASCII-8BIT'))
    end
  end
end
