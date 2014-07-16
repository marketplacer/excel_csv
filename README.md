# ExcelCSV

Read, parse, generate and write CSV directly compatiable with Microsoft Excel
on a Windows & Mac.

99% of the time, Ruby's CSV works just fine. This library deals with the other 1%:

  * Some European countries use a semicolon instead of a comma as a field separator. **ExcelCSV** will try to autodetect this, and also supports Excel's proprietary `sep=` header.
  * Excel can't deal with UTF-8, and will read & write in the local character set, which is usually 'Windows-1252'. **ExcelCSV** reads & writes in this character set automatically.
  * Some versions of Excel can't deal with UNIX newlines. **ExcelCSV** forces DOS newlines.

## Installation

Add this line to your application's Gemfile:

    gem 'excel_csv'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install excel_csv

## Usage

**ExcelCSV** copies some of the Ruby's CSV method names & pragmas, and returns CSV objects:

``` ruby
require 'excel_csv'

# Read a file
rows = ExcelCSV.read("foo.csv", headers: true)

# Parse a string
ExcelCSV.parse(csv_string) do |row|
  parse_row(row)
end

# Generate a string
csv_string = ExcelCSV.generate do |csv|
  csv << %w{ ... }
end

# Write a file
ExcelCSV.write("foo.csv") do |csv|
  csv << %w{ ... }
end
```

## Contributing

1. Fork it ( https://github.com/exchangegroup/excel_csv/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
