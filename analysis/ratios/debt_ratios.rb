def debt_ratios(data)
  debt_data = Array.new

  equity = data["equity"][0]

  debt_data << debt_to_equity_ratio(nil, equity)
  debt_data << free_cash_flow_to_debt(nil, nil)

  debt_data
end

# Ratios ======================================================================

def debt_to_equity_ratio(total_debt, equity)
  long_term_debt.to_f/equity
end

def free_cash_flow_to_debt(fcf, total_debt)
  free_cash_flow.to_f/total_debt
end