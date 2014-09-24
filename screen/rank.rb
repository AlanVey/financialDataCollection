def get_rank(companies)
	ratio_ranks = rank_valuation_ratios(companies)

	companies.each do |cik, _, _, ratios|
		ratios.last.each do |key, val|
			ratio_ranks[key].each do |comp_rank|
				if cik == comp_rank[0]
					val = ratio_ranks[key].index(comp_rank)
					break
				end
			end
		end
	end
	companies
end

def rank_valuation_ratios(companies)
	ranked_comps = { 'price_to_sales' => [], 'PEG' => [], 'EBITDA' => [] }
	companies.each do |comp|
    comp_info                      =  [comp[0], comp[1], comp[2]]
		ranked_comps['price_to_sales'] << (comp_info + [comp[3][5]['price_to_sales'][1]])
		ranked_comps['PEG'] 	 			   << (comp_info + [comp[3][5]['PEG'][1]])
		ranked_comps['EBITDA'] 				 << (comp_info + [comp[3][5]['EBITDA'][1]])
	end

	ranked_comps.each do |ratio, companies|
    if ratio != 'PEG'
		  ranked_comps[ratio] = (companies.sort_by { |c| c[3] }).reverse
    else
      ranked_comps[ratio] = companies.sort_by { |c| c[3] }
    end
	end

  ranked_comps
end


