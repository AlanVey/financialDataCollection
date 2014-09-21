require 'stock_quote'

def valuation_ratios(data, path)
  valuation_data = Array.new(5, 0)

  ticker = (path[/[a-z]+-/])[0..tmp.length - 2]
  comp   = StockQuote::Stock..quote(ticker)
  
  valuation_data[0] = comp.eps_estimate_current_year
  valuation_data[1] = comp.price_sales
  valuation_data[2] = comp.price_book
  valuation_data[3] = comp.pe_ratio
  valuation_data[4] = comp.peg_ratio

  valuation_data
end
