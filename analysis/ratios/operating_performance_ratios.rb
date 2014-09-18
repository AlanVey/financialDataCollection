def operating_performance_ratios(data)
  operating_performance_data = Array.new

  if data["revenue"] == nil or data["fixed_assets"] == nil
    return operating_performance_data
  end

  revenue      = data["revenue"][0].to_f
  fixed_assets = data["fixed_assets"][0].to_f

  operating_performance_data << fixed_asset_turnover(revenue, fixed_assets)

  operating_performance_data
end

# Ratios ======================================================================

def fixed_asset_turnover(revenue, fixed_assets)
  revenue/fixed_assets
end
