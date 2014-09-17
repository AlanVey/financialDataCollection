def profitability_ratios(data)
  profitability_data = Array.new

  if data["REVENUES"][0][1] == nil
    revenue = data["SALESREVENUENET"][0][1]
  else
    revenue = data["REVENUES"][0][1]
  end
  
  gross_profit = data["GROSSPROFIT"][0][1]
  
  profitability_data << gross_profit_margin(nil, nil)
  profitability_data << operating_profit_margin(nil, nil)
  profitability_data << net_profit_margin(nil, nil)
  profitability_data << effective_tax_rate(nil, nil)
  profitability_data << return_on_assets(nil, nil, nil)
  profitability_data << return_on_capital_employed(nil, nil, nil, nil, nil)

  profitability_data
end

# Ratios ======================================================================

def gross_profit_margin(gross_profit, revenue)
  gross_profit.to_f/revenue.to_f
end

def operating_profit_margin(operating_profit, revenue)
  operating_profit.to_f/revenue
end

def net_profit_margin(net_profit, revenue)
  net_profit.to_f/revenue
end

def effective_tax_rate(income_tax_expense, pre_tax_income)
  income_tax_expense.to_f/pre_tax_income
end

def return_on_assets(net_income, start_total_assets, end_total_assets)
  net_income.to_f/((start_total_assets.to_f + end_total_assets.to_f)/2.0)
end

def return_on_capital_employed(ebit, total_assets, current_liabilities)
  ebit.to_f/(total-assets.to_f - current_liabilities)
end