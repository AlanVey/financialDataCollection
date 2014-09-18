def cash_flow_ratios(data)
  cash_flow_data = Array.new

  ocf     = data["ocf"][0].to_f
  revenue = data["revenue"][0].to_f
  capex   = data["capex"][0].to_f


  cash_flow_data << ocf_to_sales(ocf, revenue)
  cash_flow_data << fcf_to_ocf(nil, ocf)
  cash_flow_data << capex_coverage(ocf, capex)

  cash_flow_data
end

# Ratios ======================================================================

def ocf_to_sales(ocf, revenue)
  ocf/revenue
end

def fcf_to_ocf(fcf, ocf)
  fcf/ocf
end

def capex_coverage(ocf, capex)
  ocf/capex
end