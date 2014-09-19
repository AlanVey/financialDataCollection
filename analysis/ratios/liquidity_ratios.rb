def liquidity_ratios(data)
  liquidity_data = Array.new(2, 0)

  if data["current_assets"] != nil and data["current_liabilities"] != nil
    liquidity_data[0] = data["current_assets"][0].to_f/data["current_liabilities"][0].to_f
  end

  if data["inventory"] != nil and data["inventory"] != nil and data["accounts_receivable"] != nil and 
     data["accounts_payable"] != nil and data["cogs"] != nil and data["net_income"] != nil
  
    start_inventory           = data["inventory"][1]
    end_inventory             = data["inventory"][0]
    start_accounts_receivable = data["accounts_receivable"][1]
    end_accounts_receivable   = data["accounts_receivable"][0]
    start_accounts_payable    = data["accounts_payable"][1]
    end_accounts_payable      = data["accounts_payable"][0]
    cogs                      = data["cogs"][0]
    net_sales                 = data["net_income"][0]     

    liquidity_data[1] = cash_conversion_cycle(start_inventory, end_inventory,
      start_accounts_receivable, end_accounts_receivable, start_accounts_payable,
      end_accounts_payable, cogs, net_sales)
  end

  liquidity_data
end

# Ratios ======================================================================

def cash_conversion_cycle(start_inventory, end_inventory, 
  start_accounts_receivable, end_accounts_receivable, start_accounts_payable, 
  end_accounts_payable, cogs, net_sales)
  accounts_receivable = start_accounts_receivable/end_accounts_receivable
  accounts_payable    = start_accounts_payable/end_accounts_payable
  inventory           = start_inventory/end_inventory

  dio                 = inventory/(cogs/365.25)
  dso                 = accounts_receivable/(net_sales/365.25)  
  dpo                 = accounts_payable/(cogs/365.25)

  dio+dso-dpo
end