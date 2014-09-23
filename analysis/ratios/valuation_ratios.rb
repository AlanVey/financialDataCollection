require 'stock_quote'

def valuation_ratios(data, path)
  valuation_data = Array.new(6, 0)

  ticker = path[/[a-z]+-/]
  ticker = ticker[0..ticker.length - 2]
  comp   = StockQuote::Stock.quote(ticker)
  
  valuation_data[0] = comp.eps_estimate_current_year.to_f
  valuation_data[1] = comp.price_sales.to_f
  valuation_data[2] = comp.price_book.to_f
  valuation_data[3] = comp.pe_ratio.to_f
  valuation_data[4] = comp.peg_ratio.to_f
  valuation_data[5] = comp.ebitda.to_f/data["revenue"][0] if data["revenue"] != nil

  valuation_data
end
