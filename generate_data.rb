require 'rubygems'
require 'xbrlware-ruby19'

# Level 1 =====================================================================
def generate_data(from)
  processed_data = process_data(from)
  print processed_data
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
    File.open("sec/#{year}.csv", 'w') do |file|
      file.write "CIK, GP, OP, NP\n"

      processed_data.each do |company|
        if company[1][year][2].class.to_s == "Array"
          file.write "#{company[0]}" 
          company[1][year][2].each do |ratio_group|
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
    company[1].each do |year|
      if year[2].class.to_s == "Array"
        File.open("sec/#{company[0]}.csv", 'w') do |file|
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

# Level 3 =====================================================================
def process_company_data(cik, from)
  annual_data = Array.new

  (from..Time.now.year).each do |year|
     annual_data << process_company_annual_data(cik, year)
  end

  annual_data
end

def get_ciks
  ciks = Array.new
  file = File.open('my_ciks.txt', 'r') 

  file.each do |line|
    ciks << line[/\d+/]
  end

  file.close
  ciks
end

# Level 4 =====================================================================
def process_company_annual_data(cik, year)
  jan         = 1
  dec         = 12

  (jan..dec).each do |month|
    month     = month_convert(sprintf('%02d', month))
    data_path = "sec/#{year}/#{month}/#{cik}/"
    Dir[data_path + '*'].each do |file|
      data_path = file if file =~ /\d+[^_].xml$/
    end
    
    if data_path =~ /.xml$/ and File.exist?(data_path) and file_is_10_K?(data_path)
      return [year, month, calculate_ratios(data_path)]
    end
  end
  return [year, nil, "SEC has no data for this"]
end

# Level 5 =====================================================================
def calculate_ratios(path)
  calculated_ratios = Array.new
  extracted_data    = extract_data(path)

  #calculated_ratios << liquidity_ratios(extracted_data)
  #calculated_ratios << debt_ratios(extracted_data)
  calculated_ratios << profitability_ratios(extracted_data)
  #calculated_ratios << cash_flow_ratios(extracted_data)
  #calculated_ratios << operating_performance_ratios(extracted_data)
  #calculated_ratios << valuation_ratios(extracted_data)

  calculated_ratios
end

def file_is_10_K?(path)
	Xbrlware.ins(path).item_all_map["DOCUMENTTYPE"].first.value == "10-K"
end

# Level 6 =====================================================================
def extract_data(path)
	data = Xbrlware.ins(path).item_all_map
	extracted_data = {}
	figures_needed = ["ASSETSCURRENT", "LIABILITIESCURRENT", "INVENTORYNET", "ACCOUNTSRECEIVABLENETCURRENT",
										"ACCOUNTSPAYABLECURRENT", "COSTOFGOODSSOLD", "SALESREVENUENET", "REVENUES", "GROSSPROFIT", "ASSETS",
									  "OPERATINGINCOMELOSS", "INCOMETAXEXPENSEBENEFIT", "NETINCOMELOSS", "STOCKHOLDERSEQUITY",
									 	"LONGTERMDEBT", "DEBTCURRENT", "PROPERTYPLANTANDEQUIPMENTNET", "DEPRECIATIONANDAMORTIZATION", 
									 	"NETCASHPROVIDEDBYUSEDINOPERATINGACTIVITIES", "PAYMENTSTOACQUIREPROPERTYPLANTANDEQUIPMENT"]

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

# Util Methods =================================================================

def month_convert(month)
  months = {'01' => "Jan", '02' => "Feb", '03' => "Mar", '04' => "Apr", 
            '05' => "May", '06' => "Jun", '07' => "Jul", '08' => "Aug", 
            '09' => "Sep", '10' => "Oct", '11' => "Nov", '12' => "Dec"}

  months[month]
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
