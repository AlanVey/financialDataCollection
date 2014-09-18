require 'rubygems'
require 'xbrlware-ruby19'

def print_tags_to_file(tags_data)
  File.open('data.csv', 'w') do |file|
    tags_data.each do |year, tags_hash|
      file.puts("#{year}")
      file.puts("Tag, Accounts, 1, 2, 3, 4, 5, Total")
      no_acc = tags_hash.delete("NUMACCOUNTS")
      tags_hash.each do |tag, pc|
        file.puts("#{tag}, #{no_acc}, #{pc[0]}, #{pc[1]}, #{pc[2]}, #{pc[3]}, #{pc[4]}, #{pc.inject{|sum, x| sum+x}}")
      end
    end
  end
end

def find_tags(xbrl_tags)
  tags_data = Hash.new

  (2010..Time.now.year).each do |year|
    puts "Reading tags for #{year}..."
    total_hash                = Hash.new
    total_hash["NUMACCOUNTS"] = 0

    (1..12).each do |m|
      print "  Reading tags for #{m}..."
      month = month_convert(sprintf('%02d', m))

      Dir["../download/sec/#{year}/#{month}/*/*"].each do |file_path|
        if file_path =~ /\d+[^_].xml$/
          open_xbrl = Xbrlware.ins(file_path).item_all_map.keys
          total_hash["NUMACCOUNTS"] += 1
          total_hash = find_matching_priority_tags(xbrl_tags, total_hash, open_xbrl)
        end
      end
      print "Done\n"
    end
    tags_data[year.to_s] = total_hash
    puts "...Done"
  end
  tags_data
end

def find_matching_priority_tags(tags_hash, hash, keys)
  tags_hash.each do |key, priority_list|
    matched_priority = 100
    for i in 0..(priority_list.length - 1)
      if (priority_list[i] - keys).empty?
        matched_priority = i 
        break
      end
    end

    if matched_priority != 100
      hash[key] = Array.new(priority_list.length, 0) if hash[key] == nil
      hash[key][matched_priority] += 1
    end
  end 
  hash
end

def month_convert(month)
  months = {'01' => "Jan", '02' => "Feb", '03' => "Mar", '04' => "Apr", 
            '05' => "May", '06' => "Jun", '07' => "Jul", '08' => "Aug", 
            '09' => "Sep", '10' => "Oct", '11' => "Nov", '12' => "Dec"}

  months[month]
end