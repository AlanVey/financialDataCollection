def operating_performance_ratios(data)
  operating_performance_data = Array.new

  operating_performance_data << ocf_to_sales(nil, nil)
  operating_performance_data << fcf_to_ocf(nil, nil)
  operating_performance_data << capex_coverage(nil, nil)

  operating_performance_data
end

# Ratios ======================================================================

def ocf_to_sales(ocf, revenue)
  ocf.to_f/revenue
end

def fcf_to_ocf(fcf, ocf)
  fcf.to_f/ocf
end

def capex_coverage(ocf, capital_expenditure)
  ocf.to_f/capital_expenditure
end