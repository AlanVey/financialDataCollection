def debt_ratios(data)
  debt_data = Array.new(2, 0)

  if data["debt"] != nil
    debt = data["debt"][0]

    debt_data[0] = data["fcf"][0]/debt    if data["fcf"] != nil
    debt_data[1] = debt/data["equity"][0] if data["equity"] != nil
  end
  
  debt_data
end