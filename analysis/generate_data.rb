require 'rubygems'
require 'xbrlware-ruby19'
require 'open-uri'
require 'nokogiri'

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

  get_ciks(from).each do |cik|
    name_industry = get_name_industry(cik)
    name          = name_industry[0]
    industry      = name_industry[1]

    print "Analysing #{name}...\n"

    all_company_data << [cik, name, industry, get_company_data(cik, from)]
  end

  all_company_data
end

# Level 3 =====================================================================
def get_company_data(cik, from)
  annual_data = Array.new

  (from..Time.now.year).each do |year|
    print "  #{year}..."
    annual_data << process_company_annual_data(cik, year)
    print "Done\n"
  end

  annual_data
end

def get_ciks(from)
  ciks = Array.new
  Dir["../download/sec/#{from}/*/*"].each do |cik_path|
    ciks << cik_path[/\d{10}/]
  end
  ciks
end

def get_name_industry(cik)
  tkr           = nil
  name_industry = Array.new

  Dir["../download/sec/*/*/#{cik}/*"].each do |path|
    if path =~ /\d+[^_].xml$/
      tkr = path[/[a-z]+-/]
      next if tkr == nil
      tkr = tkr[0..(tkr.length - 2)]
      break 
    end
  end

  parsed   = Nokogiri::HTML(open("http://finance.yahoo.com/q/pr?s=#{tkr}"))
  industry = parsed.xpath("//table/tr").children[15]
  name     = parsed.xpath("//td/b").first

  name_industry[0] = name.text     if name != nil
  name_industry[1] = industry.text if industry != nil

  return name_industry
end

# Level 4 =====================================================================
def process_company_annual_data(cik, year)
  (1..12).each do |month|
    month     = month_convert(sprintf('%02d', month))
    data_path = "../download/sec/#{year}/#{month}/#{cik}/"

    Dir["#{data_path}*"].each do |file|
      data_path = file if file =~ /\d+[^_].xml$/
    end
    
    if data_path =~ /.xml$/ and File.exist?(data_path)
      return [year, month, calculate_ratios(data_path)]
    end
  end
  [year, nil, nil]
end

# Level 5 =====================================================================
def calculate_ratios(path)
  calculated_ratios = Array.new
  extracted_data    = extract_data(path)

  calculated_ratios << liquidity_ratios(extracted_data)
  calculated_ratios << profitability_ratios(extracted_data)
  calculated_ratios << cash_flow_ratios(extracted_data)
  calculated_ratios << operating_performance_ratios(extracted_data)
  calculated_ratios << debt_ratios(extracted_data)
  calculated_ratios << valuation_ratios(extracted_data, path)

  calculated_ratios
end

# Util Methods =================================================================
def month_convert(month)
  months = {'01' => "Jan", '02' => "Feb", '03' => "Mar", '04' => "Apr", 
            '05' => "May", '06' => "Jun", '07' => "Jul", '08' => "Aug", 
            '09' => "Sep", '10' => "Oct", '11' => "Nov", '12' => "Dec"}

  months[month]
end
