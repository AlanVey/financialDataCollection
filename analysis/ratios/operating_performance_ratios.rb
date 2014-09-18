def operating_performance_ratios(data)
  operating_performance_data = Array.new

  revenue      = data["revenue"][0]
  fixed_assets = data["fixed_assets"][0]

  operating_performance_data << fixed_asset_turnover(revenue, fixed_assets)

  operating_performance_data
end

# Ratios ======================================================================

def fixed_asset_turnover(revenue, fixed_assets)
  revenue.to_f/property_plant_equipment
end
