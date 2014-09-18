def cash_flow_ratios(data)
  cash_flow_data = Array.new

  ocf     = data["ocf"][0]
  revenue = data["revenue"][0]
  capex   = data["capex"][0]


  cash_flow_data << ocf_to_sales(ocf, revenue)
  cash_flow_data << fcf_to_ocf(nil, ocf)
  cash_flow_data << capex_coverage(ocf, capex)

  cash_flow_data
end

# Ratios ======================================================================

def ocf_to_sales(ocf, revenue)
  ocf.to_f/revenue
end

def fcf_to_ocf(fcf, ocf)
  fcf.to_f/ocf
end

def capex_coverage(ocf, capex)
  ocf.to_f/capital_expenditure
end