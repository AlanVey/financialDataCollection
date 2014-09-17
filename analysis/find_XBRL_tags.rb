require 'rubygems'
require 'xbrlware-ruby19'

def good_tags(tags_data, array_of_regex)
  best_tags = Hash.new

  (2009..Time.now.year).each do |year|
    num_accounts = tags_data[year.to_s]["NUMACCOUNTS"]
    regex_hash   = Hash.new

    array_of_regex.each do |regex|
      regex_hash[regex.to_s] = Array.new
      tags_data[year.to_s][regex.to_s].each do |tag|
        regex_hash[regex.to_s] << tag[0] if tag[1] == num_accounts
      end
    end
    best_tags[year.to_s] = regex_hash
  end
  best_tags
end

def find_tags(xbrl_tags)
  tags_data = Hash.new

  (2009..Time.now.year).each do |year|
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

          total_hash = find_matching_tags(xbrl_tags, total_hash, open_xbrl)
        end
      end
      print "Done\n"
    end
    tags_data[year.to_s] = total_hash
    puts "...Done"
  end
  tags_data
end

def find_matching_tags(tags, hash, keys)
  tags.each do |tag|
    if keys.include?(tag)
      hash[tag] == nil ? hash[tag] = 1 : hash[tag] += 1
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