require 'yahoo_finance_scraper'

def valuation_ratios(data, path)
  valuation_data = Array.new(5, 0)

  ticker = get_ticker(path)
  comp   = YahooFinance::Scraper::Company.new(ticker).details
  
  valuation_data[0] = comp[:earnings_per_share]
  valuation_data[1] = comp[:price_to_sales]
  valuation_data[2] = comp[:price_to_book]
  valuation_data[3] = comp[:price_to_earnings]
  valuation_data[4] = comp[:peg_ratio]

  valuation_data
end

def get_ticker(path)
  return 'aapl'
end

