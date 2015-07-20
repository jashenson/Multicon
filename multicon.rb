#################
##
## multicon (multiple contingency)
## Version: 0.1a
## multicon computes a contingency table comparing n raters to a gold standard
##
## Developer: Jared Shenson
## Email: jared.shenson@gmail.com
## 
## Usage: ruby multicon.rb goldstd.csv rater1.csv [rater2.csv...]
##
## Output: multicon_r[# of raters]_[timestamp].csv
##
## Notes:
## - Files must be saved as CSV, one column per possible code, one row per segment. 
## - Cell contents must be 0 or 1, indicating absence (0) or presence (1) of given code.
## - A single header row may be included. It will be auto-detected and removed.
## - May use as many raters as desired 
##
#################

# IMPORT CSV PARSER
require 'csv'

## Read in rater data
gold = []
raters = []
codes = []
code_count = 0
ARGV.each_with_index do |file, i|

    rater_data = []
    CSV.foreach(file, {:converters => [:numeric]}) do |row|
        
        # Cache code count
        if i == 0 && $. == 1
            code_count = row.count
        end
        
        # Identify header row, if present, and store its contents for output use
        if row[0].is_a?(String) && row[0].match(/[A-Za-z]/)
            codes = row if codes.empty?
            next
        end
        
        # For each code in the row, check if it's marked present
        # If so, add it to the rater's marked codes
        row_data = []
        row.each_with_index do |code, idx|
            row_data << idx if code == 1
        end
        
        # Add row data to rater's data stack
        rater_data << row_data
        
    end
    
    if i == 0
        gold = rater_data
    else
        # Add rater data to raters' stack
        raters << rater_data
    end

end

## Compute agreements for each code
segment_count = gold.count

# agreements is a 3D matrix (i,j,k) where:
# i = gold standard code
# j = rater #
# k = array [n, m] where n is the sum of agreements, m is the number of evaluated segments
agreements = []
for i in 0...code_count
    agreements[i] = []
    raters.count.times do
        agreements[i] << [0, 0]
    end
end

# Loop through the segments, comparing codes
for i in 0...segment_count
    gold[i].each do |code|
        for j in 0...raters.count
            
            next if raters[j][i].nil? || raters[j][i].empty?
            
            agreements[code][j][0] += raters[j][i].include?(code) ? 1 : 0 # increment agreement count
            agreements[code][j][1] += 1 # increment segment count
            
        end
    end
end

## Output Results
# Create output file
timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
output = File.new("multicon_r#{raters.count}_#{timestamp}.csv", "w")

# Output summary statistics
output.puts "Input files,#{ARGV.join('; ')}"
output.puts "Segments analyzed,#{segment_count}"

# Output segment data
rater_code_str = ""
for i in 1..raters.count
    rater_code_str += "Rater #{i},"
end

output.puts ""
output.puts "Code,#{rater_code_str}Composite Agreement" #header

for i in 0...code_count

    o = codes.empty? ? i + 1 : codes[i]
    o += ","
    
    sum_agreements = 0.0
    evaluated_count = 0
    for j in 0...raters.count
        if agreements[i][j][1] == 0
            o += ","
            next
        end
    
        a = agreements[i][j][0] / agreements[i][j][1].to_f
        sum_agreements += a
        evaluated_count += 1
        
        o += "#{a.to_s},"
    end
    
    o += "#{sum_agreements / evaluated_count}" if evaluated_count > 0
    
    output.puts o
end

output.close