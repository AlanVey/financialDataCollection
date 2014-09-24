def rank_valuation_ratios(data)
	ranked_comps = { 'price_to_sales' => [], 'PEG' => [], 'EBITDA' => [] }
	data.each do |comp|
    comp_info                      = [comp[0], comp[1], comp[2]]
		ranked_comps['price_to_sales'] << (comp_info + [comp[3][5]['price_to_sales'][1]])
		ranked_comps['PEG'] 	 			   << (comp_info + [comp[3][5]['PEG'][1]])
		ranked_comps['EBITDA'] 				 << (comp_info + [comp[3][5]['EBITDA'][1]])
	end

	ranked_comps.each do |ratio, companies|
    if ratio != 'PEG'
		  ranked_comps[ratio] = companies.sort_by { |c| c[3] }
    else
      companies = companies.sort_by { |c| c[3] }
      ranked_comps[ratio] = companies.reverse
    end
	end

  ranked_comps
end