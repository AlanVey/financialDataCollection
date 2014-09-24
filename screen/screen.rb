require_relative 'process_data'
require_relative 'regression_and_calculus'
require_relative 'rank'

def screen(data)
  companies  = manipulate_data_structure(data)
  companies  = generate_function_data(companies)
  industries = sort_companies_by_industry(companies)

  industries
end

def generate_function_data(companies)
  ratios_i = 3 # index for ratios

  companies.each do |company|
    company[ratios_i] = regression_for_ratios(company[ratios_i])
  end
  companies
end