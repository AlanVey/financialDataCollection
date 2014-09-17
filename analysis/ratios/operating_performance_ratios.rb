def operating_performance_ratios(data)
  operating_performance_data = Array.new

  operating_performance_data << ocf_to_sales(nil, nil)
  operating_performance_data << fcf_to_ocf(nil, nil)
  operating_performance_data << capex_coverage(nil, nil)

  operating_performance_data
end

# Ratios ======================================================================

def fixed_asset_turnover(revenue, property_plant_equipment)
  revenue.to_f/property_plant_equipment
end

def revenue_per_employee(revenue, num_employees)
  revenue.to_f/num_employees
end
