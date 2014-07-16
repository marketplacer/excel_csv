require 'csv'

class ExcelCSV
  # Read & Write Microsoft Excel compliant CSV files, including basic
  # support for Excel running on Windows in Germany.

  class << self
    # Encoding used to read, generate and write CSV.
    #
    # Not used by +parse+.
    def default_encoding
      Encoding::Windows_1252
    end

    # Read in an Excel-generated CSV from disk using +encoding+.
    #
    # Accepts the +encoding+ option, otherwise uses +default_encoding+
    #
    # Other +options+ and a block are passed directly to CSV's +parse+ method.
    def read filename, options = {}, &block
      encoding = options.delete(:encoding) || default_encoding
      file = File.open filename, external_encoding: encoding, internal_encoding: 'UTF-8'
      _read file, options, &block
    end

    # Parse an Excel-generated CSV string.
    #
    # +options+ and a block are passed directly to CSV's +parse+ method.
    def parse string, options = {}, &block
      file = StringIO.new(string)
      _read file, options, &block
    end

    # Generate an Excel-compatiable CSV string using +default_encoding+.
    #
    # +options+ and a block are passed directly to CSV's +generate+ method.
    def generate options = {}, &block
      raise ArgumentError, "Block required" unless block_given?
      s = CSV.generate({ row_sep: "\r\n" }.merge(options), &block)
      encode_for_excel("sep=,\r\n" + s)
    end

    # Write an Excel-compatiable CSV to disk using +default_encoding+.
    #
    # +options+ and a block are passed directly to CSV's +generate+ method.
    def write filename, options = {}, &block
      raise ArgumentError, "Block required" unless block_given?
      File.open(filename, 'wb') do |f|
        f.write generate(options, &block)
      end
    end

    private

    def _read file, options, &block
      col_sep = discover_col_sep file
      CSV.parse(file, { col_sep: col_sep }.merge(options), &block)
    end

    # Microsoft Excel, on Mac and Windows, expects to import ANSI (Windows-1252)
    # rather than UTF-8. Importing UTF-8 is possible, but only in Excel 2013, and
    # has problems with line endings.
    def encode_for_excel s
      s.encode(default_encoding, invalid: :replace, undef: :replace)
    end

    def discover_col_sep file
      first_line = file.readline
      # Search for sep=x first line & return separator
      found_sep = /^sep=(.)$/.match(first_line.strip)
      return found_sep[1] if found_sep

      file.rewind # Rewind, as we want CSV to be able to read the header

      # Count commas & semicolons, pick whichever occurs most in the
      # first line. This isn't 100% accurate, but as we can't rely
      # on Germany's Excel to emit the correct sep=; line, we need
      # to do something.
      #
      # Alternative is to rely on localisation, but I want spreadsheets
      # to be portable between verticals.

      first_line.count(';') > first_line.count(',') ? ';' : ','
    rescue EOFError
      ','
    end
  end
end
