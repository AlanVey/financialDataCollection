def extract_data(path)
  data = Xbrlware.ins(path).item_all_map
  extracted_data = {}
  figures_needed = []

  figures_needed.each do |figure|
    items = data["#{figure}"]
    values = Array.new
    if items != nil
      items.each do |item| 
        if item.context.id !~ /QTD/
          values << [item.context.id[/\d{4}/], item.value]
        end
      end
      extracted_data.store("#{figure}", values)
    end
  end

  extracted_data
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