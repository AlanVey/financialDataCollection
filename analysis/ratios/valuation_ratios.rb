def valuation_ratios(data)
  valuation_data = Array.new(5, 0)

  if data["price"] != nil
    price = data["price"][0].to_f

    valuation_data[0] = price/data["ocf"][0].to_f     if data["ocf"] != nil
    valuation_data[1] = price/data["equity"][0].to_f  if data["equity"] != nil
    valuation_data[2] = price/data["revenue"][0].to_f if data["revenue"] != nil

    if data["ebitda"] != nil
      ebitda = data["ebitda"][0].to_f

      valuation_data[3] = price/ebitda
      valuation_data[4] = price/ebitda/data["eps_growth"][0].to_f if data["eps_growth"]!= nil
    end
  end

  valuation_data
end

