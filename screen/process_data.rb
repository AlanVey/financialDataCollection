def manipulate_data_structure(old_structure)
  new_structure = Array.new

  old_structure.each do |c|
    new_structure << [c[0], c[1], c[2], manipulate_annuals(c[3])]
  end

  remove_useless_data(new_structure)
end

def sort_companies_by_industry(companies)
  industries = Hash.new

  companies.each do |company|
    industry = company[2]

    industries[industry] = Array.new if industries[industry] == nil 
    industries[industry] << company
  end
  industries
end

# =============================================================================
# Internal 'private' methods ==================================================
# =============================================================================

def remove_useless_data(data)
  comp  = Array.new
  valuation = ["price_to_sales", "PEG", "EBITDA"]

  data.each do |company|
    empty = Array.new
    company[3].each do |ratio_hash|
      ratio_hash.each do |key, value|
        if value.empty? and (not valuation.include?(key))
          empty << value
        end
      end
    end
    comp << company if empty.length == 14
  end

  data = data - comp
  data.delete_if { |comp| comp[2] == nil }
  data
end

def manipulate_annuals(annual_data)
  new_structure = Array.new

  new_structure << generate_liquidity_hash(annual_data)
  new_structure << generate_profitability_hash(annual_data)
  new_structure << generate_cashflow_hash(annual_data)
  new_structure << generate_operformance_hash(annual_data)
  new_structure << generate_debt_hash(annual_data)
  new_structure << generate_valuation_hash(annual_data)

  new_structure
end

def generate_liquidity_hash(annual_data)
  hash = Hash.new

  hash["current_ratio"] = create_year_value_pairing(annual_data, 0, 0)
  hash["CCC"]           = create_year_value_pairing(annual_data, 0, 1)

  hash
end

def generate_profitability_hash(annual_data)
  hash = Hash.new

  hash["gross_profit_margin"]     = create_year_value_pairing(annual_data, 1, 0)
  hash["operating_profit_margin"] = create_year_value_pairing(annual_data, 1, 1)
  hash["net_profit_margin"]       = create_year_value_pairing(annual_data, 1, 2)
  hash["tax_margin"]              = create_year_value_pairing(annual_data, 1, 3)
  hash["ROA"]                     = create_year_value_pairing(annual_data, 1, 4)
  hash["ROCE"]                    = create_year_value_pairing(annual_data, 1, 5)

  hash
end

def generate_cashflow_hash(annual_data)
  hash = Hash.new

  hash["OCF_to_sales"] = create_year_value_pairing(annual_data, 2, 0)
  hash["FCF_to_OCF"]   = create_year_value_pairing(annual_data, 2, 1)

  hash
end

def generate_operformance_hash(annual_data)
  hash = Hash.new

  hash["fixed_asset_turnover"] = create_year_value_pairing(annual_data, 3, 0)

  hash
end

def generate_debt_hash(annual_data)
  hash = Hash.new

  hash["FCF_to_debt"]    = create_year_value_pairing(annual_data, 4, 0)
  hash["debt_to_equity"] = create_year_value_pairing(annual_data, 4, 1)
  hash["borrowing_rate"] = create_year_value_pairing(annual_data, 4, 2)

  hash
end

def generate_valuation_hash(annual_data)
  hash = Hash.new

  year = annual_data[annual_data.length - 1]

  hash["price_to_sales"] = [year[0], year[2][5][1]]
  hash["PEG"]            = [year[0], year[2][5][4]]
  hash["EBITDA"]         = [year[0], year[2][5][5]]

  hash
end
<<<<<<< HEAD

# past --> present for years
def create_year_value_pairing(annual_data, group_index, ratio_index)
  pairing = Array.new
  annual_data.each do |year|
    pairing << [year[0], year[2][group_index][ratio_index]] if year[1] != nil
  end
  pairing
end
=======
>>>>>>> aa2d310141672b242a9821e86a5628f96f021df3
