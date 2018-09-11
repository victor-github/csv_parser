 Usage:
 
 * "ruby truss.rb"
 * Please specify filename at prompt (followed by Enter and Ctrl-D) and make sure it exists in the same directory. 
 * This will read the data from the file, which is a better way than copying-pasting, since it ensures it gets the intended format.
 * It will output on STDOUT, as well as in a file output.csv.
 * This was tested with ruby 2.4 on OSX

 Notes on implementation:

 * It's using the RowNormalizer module to perform all the needed transformations. An alternative way would have been to use a class and instantiate it for each row, but that would have
 produced a lot of instances (one for each row), making it less memory efficient  
 * Based on the given example files, I made the assumption timestamp data will come in format m/d/yyyy.
 * UTF-8 conversion is done through the method 'encode_utf8' below. An alternate way would have been to specify a converter for CSV.
 * For this version of ruby, 'force_encoding' had to be used to produce the proper UTF-8 character substitutions.


