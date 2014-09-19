def find_regex(regexs)
  matching_tags = Hash.new
  Dir["../../download/sec/*/*/*/*"].each do |file_path|
    if file_path =~ /\d+[^_].xml/
      print "#{file_path}..."

      Xbrlware.ins(file_path).item_all_map.keys.each do |key|
        regexs.each do |re|
          matching_tags[re.to_s] = Array.new if matching_tags[re.to_s] == nil
          matching_tags[re.to_s] << key if key =~ re and not matching_tags[re.to_s].include?(key)
        end
      end
      puts "Done"
    end
  end
  matching_tags
end

def combinations(array)
  combinations = (1..5).flat_map{|n| array.permutation(n).map.to_a }

  filtered_combs = Array.new
  combinations.each do |combination|
    unique = true
    filtered_combs.each do |filtered_comb|
      unique = (not (combination.uniq.sort == filtered_comb.uniq.sort))
      break if not unique
    end
    filtered_combs << combination if unique
  end
  filtered_combs.reverse
end