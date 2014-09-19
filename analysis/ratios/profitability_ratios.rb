def profitability_ratios(data)
  prof_data = Array.new(6, 0)

  if data["revenue"] != nil
    revenue = data["revenue"][0].to_f

    prof_data[0] = data["gross_profit"][0].to_f/revenue     if data["gross_profit"] != nil
    prof_data[1] = data["operating_profit"][0].to_f/revenue if data["operating_profit"] != nil
    prof_data[2] = data["net_profit"][0].to_f/revenue       if data["net_profit"] != nil
  end
  
  if data["income_tax"] != nil and data["pre_tax_income"] != nil
    prof_data[3] = data["income_tax_expense"][0].to_f/data["pre_tax_income"][0].to_f
  end
  
  if data["assets"] != nil
    assets = data["assets"][0].to_f

    if data["net_assets"] != nil
      prof_data[4] = return_on_assets(data["net_assets"][0].to_f, data["assets"][1], assets)
    end

    if data["operating_profit"] != nil and data["current_liabilities"] != nil
      ebit                = data["operating_profit"][0].to_f
      current_liabilities = data["current_liabilities"][0].to_f
      
      prof_data[5] = return_on_capital(ebit, assets, current_liabilities)
    end
  end

  prof_data
end

# Ratios ======================================================================

def return_on_assets(net_income, start_assets, end_assets)
  net_income/((start_assets + end_assets)/2.0)
end

def return_on_capital(ebit, assets, current_liabilities)
  ebit.to_f/(assets - current_liabilities)
end