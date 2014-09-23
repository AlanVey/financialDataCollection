def manipulate_data_structure(old_structure)
end

#output {'PS' => [rank list: [cik, name, industry, best ratio], ...]}
def rank_valuation_ratios(data)
	ranked_comps = { 'price_to_sales' => [], 'PEG' => [], 'EBITDA' => [] }
	data.collect do |comp|
		comp_info = [comp[0], comp[1], comp[2]]
		ranked_comps['price_to_sales'] 	 << (comp_info << comp[3][4]['price_to_sales'][0][1])
		ranked_comps['PEG'] 	 					 << (comp_info << comp[3][4]['PEG'][0][1])
		ranked_comps['EBITDA'] 					 << (comp_info << comp[3][4]['EBITDA'][0][1])
	end

	ranked_comps.each do |ratio, comps|
		ranked_comps.store(ratio, comps.sort_by { |comp| comp[3] })
	end

ranked_comps
end