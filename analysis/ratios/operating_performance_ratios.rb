def operating_performance_ratios(data)
  op_data = Array.new(1, 0)

  if data["revenue"] != nil and data["fixed_assets"] != nil
    op_data[0] = data["revenue"][0].to_f/data["fixed_assets"][0].to_f
  end

  op_data
end
