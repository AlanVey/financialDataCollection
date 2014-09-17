def valuation_ratios(data)
  valuation_data = Array.new

  valuation_data << price_to_book_ratio(nil, nil)
  valuation_data << peg(nil, nil, nil)
  valuation_data << price_to_ocf(nil, nil)
  valuation_data << price_to_sales(nil, nil)
  valuation_data << price_to_ebitda(nil, nil)

  valuation_data
end

# Ratios ======================================================================

def price_to_book_ratio(price, equity)
  price.to_f/equity
end

def peg(price, eps, eps_growth)
  price.to_f/ebitda/eps_growth.to_f
end

def price_to_ocf(price, ocf)
  price.to_f/ocf
end

def price_to_sales(price, sales)
  price.to_f/sales
end

def price_to_ebitda(price, ebitda)
  price.to_f/ebitda
end