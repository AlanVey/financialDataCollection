def liquidity_ratios(data)
  liquidity_data = Array.new

  liquidity_data << current_ratio(nil, nil)
  liquidity_data << cash_conversion_cycle(nil, nil)

  liquidity_data
end

# Ratios ======================================================================

def current_ratio(current_assets, current_liabilities)
  current_assets.to_f/current_liabilities
end

def cash_conversion_cycle(start_inventory, end_inventory, 
  start_accounts_receivable, end_accounts_receivable, start_accounts_payable, 
  end_accounts_payable, cogs, net_sales)
  accounts_receivable = start_accounts_receivable.to_f/end_accounts_receivable
  accounts_payable    = start_accounts_payable.to_f/end_accounts_payable
  inventory           = start_inventory.to_f/end_inventory

  dio                 = inventory/(cogs/365.25)
  dso                 = accounts_receivable/(net_sales/365.25)  
  dpo                 = accounts_payable/(cogs/365.25)

  dio+dso-dpo
end