def cash_flow_ratios(data)
  cash_flow_data = Array.new(3, 0)

  if data["ocf"] != nil
    ocf = data["ocf"][0].to_f

    cash_flow_data[0] = ocf/data["revenue"][0].to_f if data["revenue"] != nil
    cash_flow_data[1] = data["fcf"][0].to_f/ocf     if data["fcf"] != nil
    cash_flow_data[2] = ocf/data["capex"][0].to_f   if data["capex"] != nil
  end

  cash_flow_data
end
