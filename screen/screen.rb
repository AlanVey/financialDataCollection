require_relative 'process_data'
require_relative 'regression_and_calculus'
require_relative 'rank'

def screen(data)
  companies  = manipulate_data_structure(data)
  companies  = generate_function_data(companies)
  industries = sort_companies_by_industry(companies)
  industries = rank_valuation(industries)
  
  industries
end

# =============================================================================
# Internal 'private' methods ==================================================
# =============================================================================

def generate_function_data(companies)
  ratios_i = 3 # index for ratios

  companies.each do |company|
    company[ratios_i] = regression_for_ratios(company[ratios_i])
  end
  companies
end

def rank_valuation(industries)
	industries.each do |industry, comps|
		industries[industry] = get_valuation_rank(comps)
	end
	industries
end