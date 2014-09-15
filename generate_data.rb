require 'rubygems'
require 'xbrlware-ruby19'


# Level 1 =====================================================================
def generate_data
end

# Level 2 =====================================================================
def process_data
end

def generate_competitor_ratios(processed_data)
end

def generate_historical_ratios(processed_data)
end

# Level 3 =====================================================================
def process_company_data(cik)
end

def get_ciks
end

# Level 4 =====================================================================
def process_company_annual_data(cik, year)
end

# Level 5 =====================================================================
def calculate_ratios(path)
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
end

def debt_ratios(extracted_data)
end

def profitability_ratios(extracted_data)
end

def cash_flow_ratios(extracted_data)
end

def operating_performance_ratios(extracted_data)
end

def valuation_ratios(extracted_data)
end

# Level 7 =====================================================================
# All individual ratio calculation

