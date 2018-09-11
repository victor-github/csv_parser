require 'csv'
require 'active_support/core_ext/time'

# Usage:
# 
# * "ruby truss.rb"
# * Please specify filename at prompt (followed by Enter and Ctrl-D) and make sure it exists in the same directory. 
# * This will read the data from the file, which is a better way than copying-pasting, since it ensures it gets the intended format.
# * It will output on STDOUT, as well as in a file output.csv.
# * This was tested with ruby 2.4 on OSX
#
# Notes on implementation:
#
# * It's using the RowNormalizer module to perform all the needed transformations. An alternative way would have been to use a class and instantiate it for each row, but that would have
# produced a lot of instances (one for each row), making it less memory efficient  
# * Based on the given example files, I made the assumption timestamp data will come in format m/d/yyyy.
# * UTF-8 conversion is done through the method 'encode_utf8' below. An alternate way would have been to specify a converter for CSV.
# * . For this, 'force_encoding' had to be used to produce the proper UTF-8 character substitutions.

module RowNormalizer

  #Timestamp: switch to US/Eastern and convert to ISO-8601
  def normalize_timestamp(row)
    utf8_timestamp = encode_utf8(row["Timestamp"])
    Time.zone = "US/Pacific"
    Time.zone.strptime(utf8_timestamp, "%m/%d/%y %H:%M:%S").in_time_zone("US/Eastern").iso8601
  end

  #Address
  def normalize_address(row)
    encode_utf8(row["Address"])
  end

  #Zip: prepend 0s to make it 5 digits
  def normalize_zip(row)
    zip = encode_utf8(row["ZIP"])
    (5 - zip.size).times { zip = "0" + zip }
    zip
  end

  #FullName: convert to uppercase
  def normalize_full_name(row)
    encode_utf8(row["FullName"]).upcase
  end

  #FooDuration: convert from HH:MM:SS.MS to floating point seconds
  def normalize_foo_duration(row)
    convert_duration_to_seconds(encode_utf8(row["FooDuration"]))
  end

  #BarDuration: convert from HH:MM:SS.MS to floating point seconds
  def normalize_bar_duration(row)
    convert_duration_to_seconds(encode_utf8(row["BarDuration"]))
  end

  #TotalDuration: replace with sum of FooDuration + BarDuration
  def normalize_total_duration(row)
    normalize_foo_duration(row) + normalize_bar_duration(row)
  end

  #Notes
  def normalize_notes(row)
    encode_utf8(row["Notes"])
  end

  def normalize_row(row)
    [normalize_timestamp(row), normalize_address(row), normalize_zip(row), normalize_full_name(row), normalize_foo_duration(row), normalize_bar_duration(row), normalize_total_duration(row), normalize_notes(row)]
  end

  #duration is in format HH:MM:SS.MS
  #result is floating point seconds
  def convert_duration_to_seconds(duration)
    h, m, s, ms = duration.split(/[:,.]/).map(&:to_i)
    h %= 24
    return (((h * 60) + m) * 60) + s + (ms.to_f / 1000)
  end

  def encode_utf8(column_value)
    !column_value.nil? ? column_value.force_encoding('utf-8').encode("utf-8", invalid: :replace, undef: :replace, replace: "�") : ""
  end

end

class Normalize
  extend RowNormalizer

  def self.initialize
    p "Input filename?"
    @filename = STDIN.read.strip
    @output_file = "output.csv"
  end

  def self.main
    row_number = 0
    CSV.open(@output_file, "wb") do |csv|
      csv << ["Timestamp", "Address", "ZIP", "FullName", "FooDuration", "BarDuration", "TotalDuration", "Notes"]
      CSV.foreach(@filename, headers: true, encoding: 'iso-8859-1') do |row|
        row_number += 1 
        output = normalize_row(row)
        csv << output
        STDOUT.puts output.join(",")
      end
    end

  #Only invalid dates should get here, since CSV parsing already gets everything into i-8859-1 and then we convert it to UTF-8
  rescue Errno::ENOENT => e
    STDERR.puts e.to_s 
  rescue ArgumentError => e
    STDERR.puts "Error parsing row #{row_number}: #{e}"
  end
end

Normalize.initialize
Normalize.main


