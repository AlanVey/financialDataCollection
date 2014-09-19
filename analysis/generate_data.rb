require 'rubygems'
require 'xbrlware-ruby19'
require 'open-uri'

require_relative 'data_processing/print_data_to_file'
require_relative 'data_processing/extract_and_format_data'

require_relative 'ratios/cash_flow_ratios'
require_relative 'ratios/debt_ratios'
require_relative 'ratios/liquidity_ratios'
require_relative 'ratios/operating_performance_ratios'
require_relative 'ratios/profitability_ratios'
require_relative 'ratios/valuation_ratios'

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
    all_company_data << [cik, get_industry(cik), process_company_data(cik, from)]
  end

  all_company_data
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
  file = File.open('../download/data/my_ciks.txt', 'r') 

  file.each { |line| ciks << line[/\d+/] }

  file.close
  ciks
end

def get_industry(cik)
  ticker = nil

  Dir["../download/sec/*/*/#{cik}/*"].each do |path|
    if path =~ /\d+[^_].xml$/
      ticker = path[/[a-z]+-/]
      ticker = ticker[0..ticker.length - 2]
    end
  end

  if ticker != nil
    parsed = Nokogiri::HTML(open("http://finance.yahoo.com/q/pr?s=#{ticker}"))
    # Throws error of nil class sometimes
    puts ticker # use this to error catch
    return parsed.xpath("//table/tr").children[15].text
  else
    return nil
  end
end

# Level 4 =====================================================================
def process_company_annual_data(cik, year)
  jan         = 1
  dec         = 1

  (jan..dec).each do |month|
    month     = month_convert(sprintf('%02d', month))
    data_path = "../download/sec/#{year}/#{month}/#{cik}/"

    Dir[data_path + '*'].each do |file|
      data_path = file if file =~ /\d+[^_].xml$/
    end
    
    if data_path =~ /.xml$/ and File.exist?(data_path)
      return [year, month, calculate_ratios(data_path)]
    end
  end
  return [year, nil, "SEC has no data for this"]
end

# Level 5 =====================================================================
def calculate_ratios(path)
  calculated_ratios = Array.new
  extracted_data    = extract_data(path)

  calculated_ratios << liquidity_ratios(extracted_data)
  calculated_ratios << profitability_ratios(extracted_data)
  calculated_ratios << cash_flow_ratios(extracted_data)
  calculated_ratios << operating_performance_ratios(extracted_data)
  calculated_ratios << valuation_ratios(extracted_data, path)
  #calculated_ratios << debt_ratios(extracted_data)

  calculated_ratios
end

# Util Methods =================================================================
def month_convert(month)
  months = {'01' => "Jan", '02' => "Feb", '03' => "Mar", '04' => "Apr", 
            '05' => "May", '06' => "Jun", '07' => "Jul", '08' => "Aug", 
            '09' => "Sep", '10' => "Oct", '11' => "Nov", '12' => "Dec"}

  months[month]
end
