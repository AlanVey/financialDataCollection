require 'rubygems'
require 'xbrlware-ruby19'
require 'nokogiri'

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
	extracted_data = {}
	figures_needed = []

	all_figures.each do |figure_name, items| 
		if figures_needed.include?(figure_name)
			extracted_data["#{figure_name}"] = nil 
		end

		values = Array.new

		items.each do |item|
 			if item.context.id.match("YTD")
 				values << [item.context.id, item.value] 
 			end
 		end
 		extracted_data["#{figure_name}"] = values
 	end
 	extracted_data
end

def liquidity_ratios(data)
  liquidity_data = Array.new

  liquidity_data << current_ratio(nil, nil)
  liquidity_data << cash_conversion_cycle(nil, nil)

  liquidity_data
end

def debt_ratios(data)
  debt_data = Array.new

  debt_data
end

def profitability_ratios(data)
  profitability_data = Array.new

  profitability_data
end

def cash_flow_ratios(data)
  cash_flow_data = Array.new

  cash_flow_data
end

def operating_performance_ratios(data)
  operating_performance_data = Array.new

  operating_performance_data
end

def valuation_ratios(data)
  valuation_data = Array.new

  valuation_data
end

# Level 7 =====================================================================
def current_ratio(current_assets, current_liabilities)
end

def cash_conversion_cycle(start_inventory, end_inventory, 
  start_accounts_receivable, end_accounts_receivable, start_accounts_payable, 
  end_accounts_payable, cogs, net_sales)
end

def gross_profit_margin(gross_profit, revenue)
end

def operating_profit_margin(operating_profit, revenue)
end

def net_profit_margin(net_profit, revenue)
end

def effective_tax_rate(income_tax_expense, pre_tax_income)
end

def return_on_assets(net_income, start_total_assets, end_total_assets)
end

def return_on_capital_employed(ebit, start_debt_liabilities, end_debt_liabilities,
  start_shareholders_equity, end_shareholders_equity)
end

def debt_to_equity_ratio(long_term_debt, equity)
end

def free_cash_flow_to_debt(free_cash_flow, total_debt)
end

def fixed_asset_turnover()
end


