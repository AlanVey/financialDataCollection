def debt_ratios(data)
  debt_data = Array.new(2, 0)

  if data["debt"] != nil
    debt = data["debt"][0].to_f

    debt_data[0] = data["fcf"][0].to_f/debt    if data["fcf"] != nil
    debt_data[1] = debt/data["equity"][0].to_f if data["equity"] != nil
  end
  
  debt_data
end