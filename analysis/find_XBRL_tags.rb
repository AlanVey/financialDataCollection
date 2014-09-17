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

def find_tags(array_of_regex)
  tags_data = Hash.new

  (2009..Time.now.year).each do |year|
    puts "Reading tags for #{year}..."

    total_hash                = Hash.new
    total_hash["NUMACCOUNTS"] = 0
    (1..12).each do |m|
      print "  Reading tags for #{m}..."

      month = month_convert(sprintf('%02d', m))

      Dir["sec/#{year}/#{month}/*/*"].each do |file_path|
        if file_path =~ /\d+[^_].xml$/
          open_xbrl = file_is_10_K?(file_path)
          if open_xbrl != nil
            total_hash = find_tags_matching_regex(file_path, array_of_regex, 
                                                  total_hash, open_xbrl.keys)
            total_hash["NUMACCOUNTS"] += 1
          else
            next
          end
        end
      end
      print "Done\n"
    end
    tags_data[year.to_s] = total_hash
    puts "...Done"
  end
  tags_data
end

def find_tags_matching_regex(path, regexs, hash, keys)
  regexs.each do |regex|
    matched_keys = Hash.new

    keys.each do |key|
      matched_keys[key] = 1 if key =~ regex
    end

    if hash[regex.to_s] == nil
      hash[regex.to_s] = matched_keys
    elsif matched_keys.keys.length != 0
      matched_keys.keys.each do |mk|
        if hash[regex.to_s][mk] == nil
          hash[regex.to_s][mk] = 1
        else
          hash[regex.to_s][mk] += 1
        end
      end
    end
  end 
  hash
end

def file_is_10_K?(path)
  data = Xbrlware.ins(path).item_all_map
  if data["DOCUMENTTYPE"].first.value == "10-K"
    return data
  else 
    return nil
  end
end

def month_convert(month)
  months = {'01' => "Jan", '02' => "Feb", '03' => "Mar", '04' => "Apr", 
            '05' => "May", '06' => "Jun", '07' => "Jul", '08' => "Aug", 
            '09' => "Sep", '10' => "Oct", '11' => "Nov", '12' => "Dec"}

  months[month]
end