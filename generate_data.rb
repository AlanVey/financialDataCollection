require 'rubygems'
require 'xbrlware-ruby19'

# Level 1 =====================================================================
def generate_data(from)
  processed_data = process_data(from)
  generate_competitor_ratios(processed_data)
  generate_historical_ratios(processed_data)
end

# Level 2 =====================================================================
def process_data(from)
  all_company_data = Array.new

  get_ciks.each do |cik|
    all_company_data << [cik, process_company_data(cik, from)]
  end

  all_company_data
end

def generate_competitor_ratios(processed_data)
  current_year = processed_data[0][1].length - 1

  (0..current_year).each do |year|
    File.open("#{year}.csv", 'w') do |file|
      file.write "CIK, Ratio1, Ratio2, ... , \n"

      processed_data.each do |company|
        file.write "#{company[0]}" 
        company[1][year - from_year][2].each do |ratio_group|
          ratio_group.each do |ratio|
            file.write ",#{ratio}"
          end
        end
      end
      file.write "\n"
      file.close
    end
  end
end

def generate_historical_ratios(processed_data)
  processed_data.each do |company|
    File.open("#{company[0]}.csv", 'w') do |file|
      file.write "Year, Ratio1, Ratio2, ... , \n"
      company[1].each do |year|
        file.write "#{year},"
        year[2].each do |ratio_group|
          ratio_group.each do |ratio|
            file.write ",#{ratio}"
          end
        end
      end
      file.write "\n"
      file.close
    end
  end
end

# Level 3 =====================================================================
def process_company_data(cik, from)
  annual_data = Array.new

  for year in from..Time.now.year
     annual_data << process_company_annual_data(cik, year)
  end

  annual_data
end

def get_ciks
  ciks = Array.new
  file = File.open('my_ciks.txt', 'r') 

  file.each do |line|
    ciks << line
  end

  file.close
  ciks
end

# Level 4 =====================================================================
def process_company_annual_data(cik, year)
  jan         = 1
  dec         = 12

  jan..dec.each do |month|
    month     = month_convert(sprintf('%02d', month))
    data_path = "sec/#{year}/{month}/#{cik}"
    if File.directory?(data_path) and file_is_10_K?(data_path)
      return [year, month, calculate_ratios(data_path)]
    end
  end
end

# Level 5 =====================================================================
def calculate_ratios(path)
  calculated_ratios = Array.new
  extracted_data    = extract_data(path)

  calculated_ratios << liquidity_ratios(extracted_data)
  calculated_ratios << debt_ratios(extracted_data)
  calculated_ratios << profitability_ratios(extracted_data)
  calculated_ratios << cash_flow_ratios(extracted_data)
  calculated_ratios << operating_performance_ratios(extracted_data)
  calculated_ratios << valuation_ratios(extracted_data)

  calculated_ratios
end

def file_is_10_K?(path)
  # TODO
end

# Level 6 =====================================================================
def extract_data(path)
	data = Xbrlware.ins(path)
	all_figures = data.item_all_map 

	all_figures.each do |figure_name, items| 
		if figure_name =~ /TEXTBLOCK/
			all_figures.delete("#{figure_name}")
 		end
 	end
 	all_figures
end


def liquidity_ratios(extracted_data)
  # TODO
  return nil
end

def debt_ratios(extracted_data)
  # TODO
  return nil
end

def profitability_ratios(extracted_data)
  # TODO
  return nil
end

def cash_flow_ratios(extracted_data)
  # TODO
  return nil
end

def operating_performance_ratios(extracted_data)
  # TODO
  return nil
end

def valuation_ratios(extracted_data)
  # TODO
  return nil
end

# Level 7 =====================================================================
# All individual ratio calculation
# TODO

