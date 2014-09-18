def extract_data(path, tags_hash)
  extracted_data = Hash.new
  data           = Xbrlware.ins(path).item_all_map
  keys           = data.keys

  tags_hash.each do |key, priority_list|
    priority_list.each do |tag_list|
      if (tag_list - keys).empty?
        extracted_data[key] = get_tags_data(tag_list, data)
        break
      end
    end
  end
  calculate_figures(extracted_data)
end

def get_tags_data(tags, data)
  tags_values = Array.new
  tags.each do |tag|
    items = data["#{tag}"]
    values = Array.new
    if items != nil
      items.each do |item| 
        if item.context.id !~ /QTD/
          values << [item.context.id[/\d{4}/], item.value]
        end
      end
    end
    tags_values << [tag, current_and_previous(values)]
  end 
  tags_values
end

#returns {"TAG" => [current_year, previous_year]}
def calculate_figures(data)

end

def current_and_previous(figures)
  current = [0,0]
  previous = [0,0]
  for i in 0..(figures.length-1)
    current = [figures[i][0].to_i, i] if current[0] < figures[i][0].to_i
    previous = [figures[i][0].to_i, i] if previous[0] < ( figures[i][0].to_i - 1 )
  end
  [figures[current[1]][1], figures[previous[1]][1]]
end

def find_regex(regexs)
  matching_tags = Hash.new
  Dir["../../download/sec/*/*/*/*"].each do |file_path|
    puts "#{file_path}..."
    if file_path =~ /\d+[^_].xml/
      Xbrlware.ins(file_path).item_all_map.keys.each do |key|
        regexs.each do |re|
          matching_tags[re.to_s] = key if key =~ re 
        end
      end
    end
    puts "...Done"
  end
  matching_tags
end
