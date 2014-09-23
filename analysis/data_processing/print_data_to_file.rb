def generate_competitor_ratios(processed_data)
  current_year = processed_data[0][3].length - 1

  (0..current_year).each do |year|
    File.open("analysed_data/#{year}.csv", 'w') do |file|
      file.write "CIK, GP, OP, NP\n"

      processed_data.each do |company|
        if company[3][year][2].class.to_s == "Array"
          file.write "#{company[0]}, #{company[1]}" 
          company[3][year][2].each do |ratio_group|
            ratio_group.each do |ratio|
              file.write ",#{ratio}"
            end
          end
          file.write "\n"
        end
      end
      file.close
    end
  end
end

def generate_historical_ratios(processed_data)
  processed_data.each do |company|
    company[3].each do |year|
      if year[2].class.to_s == "Array"
        File.open("analysed_data/#{company[1]} (#{company[0]}).csv", 'w') do |file|
          file.write "Year, GP, OP, NP\n"
          file.write "#{year[0]},"
          year[2].each do |ratio_group|
            ratio_group.each do |ratio|
              file.write ",#{ratio}"
            end
          end
          file.write "\n"
          file.close
        end
      end
    end
  end
end