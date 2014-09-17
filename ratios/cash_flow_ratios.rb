def cash_flow_ratios(data)
  cash_flow_data = Array.new

  cash_flow_data << ocf_to_sales(nil, nil)
  cash_flow_data << fcf_to_ocf(nil, nil)
  cash_flow_data << capex_coverage(nil, nil)

  cash_flow_data
end

# Ratios ======================================================================

def fixed_asset_turnover(revenue, property_plant_equipment)
  revenue.to_f/property_plant_equipment
end

def revenue_per_employee(revenue, num_employees)
  revenue.to_f/num_employees
end