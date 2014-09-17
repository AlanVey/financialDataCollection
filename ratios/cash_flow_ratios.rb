def cash_flow_ratios(data)
  cash_flow_data = Array.new

  cash_flow_data << ocf_to_sales(nil, nil)
  cash_flow_data << fcf_to_ocf(nil, nil)
  cash_flow_data << capex_coverage(nil, nil)

  cash_flow_data
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