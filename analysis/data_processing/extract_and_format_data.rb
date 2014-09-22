def extract_data(path)
  tags_hash      = get_tags_hash
  extracted_data = Hash.new
  data           = Xbrlware.ins(path).item_all_map
  keys           = data.keys

  tags_hash.each do |key, priority_list|
    priority_list.each do |tag_list|
      if (tag_list - keys).empty?
        extracted_data[key] = get_tags_data(tag_list, data)
        break
      end
    end
  end
  calculate_figures(extracted_data)
end

def get_tags_data(tags, data)
  tags_values = Array.new

  tags.each do |tag|
    items = data["#{tag}"]
    values = Array.new

    items.each do |item| 
      # TODO: needs work
      if items.count <= 3 or item.context.entity.segment == nil
        values << [parse_context_id(item.context.id), item.value] 
      elsif item.context.id =~ /YTD/ or item.context.id =~ /Q4/
        values << [parse_context_id(item.context.id), item.value] 
      end
    end

    tags_values << [tag, current_and_previous(values)]
  end 
  tags_values
end

def calculate_figures(data)
  calculated_figures = Hash.new
  data.each do |key, val|
    if key == 'capex' and val[0][0] == "ACCUMULATEDDEPRECIATIONDEPLETIONANDAMORTIZATIONPROPERTYPLANTANDEQUIPMENT"
      net_fixed_assets             = data['fixed_assets'][0][1][1].to_f - data['fixed_assets'][0][1][0].to_f
      calculated_figures[key]      = [(val[0][1][1].to_f - val[0][1][0].to_f) + net_fixed_assets, nil]
    elsif key == 'liabilities'
      values                       = val.collect { |tag_value| tag_value[1] }
      values                       = values.map{ |value| value.map{ |string| string.to_f } }
      values                       << data['liabilities_equity'][0][1].map{ |string| string.to_f }
      calculated_figures['equity'] = values.reverse.transpose.map{ |value| value.inject(:-)}
    else
      if val.length == 1
        if key == 'gross_profit' and val[0][0] == "COSTOFREVENUE"
          revenue_cost             = val[0][1].map{ |string| string.to_f }
          revenue                  = data["revenue"][0][1].map{ |string| string.to_f }
          calculated_figures[key]  = [revenue, revenue_cost].transpose.map{ |value| value.inject(:-) }
        else
          calculated_figures[key]  = val[0][1].map{ |string| string.to_f } 
        end
      else
        values                     = val.collect { |tag_value| tag_value[1] }
        values                     = values.map{ |value| value.map{ |string| string.to_f } }

        if key == 'accounts_payable' and val[0][0] == "ACCOUNTSPAYABLEANDACCRUEDLIABILITIESCURRENT"
          calculated_figures[key]  = values.transpose.map{|value| value.inject(:-)}         
        else
          calculated_figures[key]  = values.transpose.map{|value| value.inject(:+)}          
        end
      end
    end    
  end
  calculated_figures['fcf'] = [calculated_figures['ocf'][0] - calculated_figures['capex'][0]]
  calculated_figures['ebit'] = calculated_figures['operating_profit']
  calculated_figures.tap { |unused_data| unused_data.delete('liabilities_equity') }
end

def current_and_previous(figures)
  current = [0,0]
  previous = [0,0]
  for i in 0..(figures.length-1)
    current = [figures[i][0].to_i, i] if current[0] < figures[i][0].to_i
    previous = [figures[i][0].to_i, i] if previous[0] < ( figures[i][0].to_i - 1 )
  end
  [figures[current[1]][1], figures[previous[1]][1]]
end

def parse_context_id(context_id)
  years = Array.new
  context_id.scan(/20\d{2}/).each {|year| years << year.to_i }
  years.max.to_s
end

def get_tags_hash
  {'current_assets' => [["ASSETSCURRENT"]], 
 'current_liabilities' => [["LIABILITIESCURRENT"]], 
 'inventory_net' => [["INVENTORYNET"], ["INVENTORYFINISHEDGOODS", "INVENTORYWORKINPROCESSNETOFRESERVES", "INVENTORYRAWMATERIALSNETOFRESERVES", "OTHERINVENTORYNETOFRESERVES", "INVENTORYVALUATIONRESERVES"], ["INVENTORYWORKINPROCESSANDRAWMATERIALSNETOFRESERVES", "INVENTORYFINISHEDGOODSVALUATIONINVENTORYNETOFRESERVES", "OTHERINVENTORYSERVICEMATERIALSANDSUPPLIESNET", "OTHERINVENTORY"], ["INVENTORYFINISHEDGOODSNETOFRESERVES", "INVENTORYWORKINPROCESS", "INVENTORYRAWMATERIALS", "OTHERINVENTORY", "INVENTORYVALUATIONRESERVES"], ["INVENTORYFINISHEDGOODSNETOFRESERVES", "INVENTORYWORKINPROCESS", "INVENTORYRAWMATERIALS", "INVENTORYVALUATIONRESERVES"]], 
 'accounts_receivable' => [["ACCOUNTSRECEIVABLENETCURRENT"], ["RECEIVABLESNETCURRENT"]], 
 'accounts_payable' => [["ACCOUNTSPAYABLECURRENT"], ["ACCOUNTSPAYABLEANDACCRUEDLIABILITIESCURRENT", "ACCRUEDLIABILITIESCURRENT"], ["INCREASEDECREASEINACCOUNTSPAYABLE"], ["ACCRUEDACCOUNTSPAYABLE"], ["ACCOUNTSPAYABLEANDACCRUEDLIABILITIESCURRENT", "ACCRUEDLIABILITIESCURRENT"], ["INCREASEDECREASEINACCOUNTSPAYABLEFORCAPITALEXPENDITURES"]], 
 'assets' => [["ASSETS"]], 
 'fixed_assets' => [["PROPERTYPLANTANDEQUIPMENTNET"]],
 'ocf' => [["NETCASHPROVIDEDBYUSEDINOPERATINGACTIVITIESCONTINUINGOPERATIONS"], ["NETCASHPROVIDEDBYUSEDINCONTINUINGOPERATIONS"],
 ["NETCASHPROVIDEDBYUSEDINOPERATINGACTIVITIES"]], 
 'cogs' => [["COSTOFGOODSANDSERVICESSOLD"], ["COSTOFGOODSSOLD", "COSTOFSERVICES"], ["COSTOFGOODSSOLD"], ["COSTOFSERVICES"], ["COSTOFREVENUE"]], 
 'revenue' => [["REVENUES"], ["SALESREVENUENET"], ["SALESREVENUESERVICESNET"], ["SALESREVENUEGOODSNET"]], 
 'gross_profit' => [["GROSSPROFIT"], ["COSTOFREVENUE"]], 
 'operating_profit' => [["OPERATINGINCOMELOSS"]], 
 'tax_expense' => [["INCOMETAXEXPENSEBENEFIT"]],
 'pretax_income' => [["INCOMELOSSFROMCONTINUINGOPERATIONSBEFOREINCOMETAXESEXTRAORDINARYITEMSNONCONTROLLINGINTEREST"], 
 ["INCOMELOSSFROMCONTINUINGOPERATIONSBEFOREINCOMETAXESMINORITYINTERESTANDINCOMELOSSFROMEQUITYMETHODINVESTMENTS"], ["INTERESTANDDEBTEXPENSE", "NONOPERATINGINCOMEEXPENSE", "OPERATINGINCOMELOSS"], ["INTERESTANDDEBTEXPENSE", "OPERATINGINCOMELOSS"]], 
 'net_income' => [["NETINCOMELOSS"], ["PROFITLOSS"]], 
 'capex' => [["PAYMENTSTOACQUIREPROPERTYPLANTANDEQUIPMENT"], ["ACCUMULATEDDEPRECIATIONDEPLETIONANDAMORTIZATIONPROPERTYPLANTANDEQUIPMENT"]],
 'total_debt' => [["DEBTANDCAPITALLEASEOBLIGATIONS"], ["LONGTERMDEBT", "SHORTTERMDEBT"], ["DEBTCURRENT", "LONGTERMDEBTNONCURRENT"], ["SHORTTERMBORROWINGS", "LONGTERMDEBTCURRENT", "LONGTERMDEBTNONCURRENT"], ["LIABILITIESOTHERTHANLONGTERMDEBTNONCURRENT", "LIABILITIESNONCURRENT", "DEBTCURRENT"], ["LIABILITIESOTHERTHANLONGTERMDEBTNONCURRENT", "LIABILITIESNONCURRENT", "SHORTTERMBORROWINGS", "LONGTERMDEBTCURRENT"], ["LONGTERMDEBTANDCAPITALLEASEOBLIGATIONS", "DEBTCURRENT"], ["LONGTERMDEBTNONCURRENT", "DEBTCURRENT"], ["LONGTERMDEBTNONCURRENT", "DEBTCURRENT"], ["LONGTERMDEBTANDCAPITALLEASEOBLIGATIONS", "SHORTTERMBORROWINGS", "LONGTERMDEBTCURRENT"], ["LONGTERMDEBTNONCURRENT", "SHORTTERMBORROWINGS", "LONGTERMDEBTCURRENT"], ["LONGTERMDEBTNONCURRENT", "SHORTTERMBORROWINGS", "LONGTERMDEBTCURRENT"], ["LONGTERMDEBTANDCAPITALLEASEOBLIGATIONS", "SHORTTERMBORROWINGS", "LONGTERMDEBTANDCAPITALLEASEOBLIGATIONSCURRENT"], ["LONGTERMDEBTNONCURRENT", "SHORTTERMBORROWINGS", "LONGTERMDEBTANDCAPITALLEASEOBLIGATIONSCURRENT"], ["LONGTERMDEBTNONCURRENT", "LONGTERMDEBTCURRENT", "SHORTTERMBORROWINGS"], ["SHORTTERMBANKLOANSANDNOTESPAYABLE", "OTHERSHORTTERMBORROWINGS", "COMMERCIALPAPER", "OTHERLONGTERMDEBTNONCURRENT", "SECUREDDEBTCURRENT", "LINESOFCREDITCURRENT", "NOTESPAYABLECURRENT", "LONGTERMDEBTNONCURRENT"], ["SHORTTERMBORROWINGS", "LONGTERMDEBT"], ["COMMERCIALPAPER", "OTHERSHORTTERMBORROWINGS", "LONGTERMDEBT"], ["UNSECUREDDEBT", "LINEOFCREDIT", "SECUREDDEBT", "SHORTTERMBORROWINGS"], ["OTHERLONGTERMDEBT", "SHORTTERMBORROWINGS", "LINEOFCREDIT"], ["SECUREDDEBT", "UNSECUREDDEBT", "OTHERLONGTERMDEBT", "SHORTTERMBORROWINGS", "OTHERLONGTERMDEBTCURRENT", "NOTESPAYABLECURRENT", "LINESOFCREDITCURRENT", "LOANSPAYABLECURRENT", "SECUREDDEBTCURRENT", "UNSECUREDDEBTCURRENT"], ["LONGTERMDEBTANDCAPITALLEASEOBLIGATIONS"]],
 'liabilities_equity' => [["LIABILITIESANDSTOCKHOLDERSEQUITY"]],
 'liabilities' => [["LIABILITIES"], ["LIABILITIESNONCURRENT", "LIABILITIESCURRENT"], ["LIABILITIESCURRENT", "LIABILITIESOTHERTHANLONGTERMDEBTNONCURRENT", "LONGTERMDEBTNONCURRENT"], ["LIABILITIESCURRENT", "OTHERLIABILITIESNONCURRENT", "LONGTERMDEBTNONCURRENT"], ["LIABILITIESCURRENT", "LONGTERMDEBTNONCURRENT", "ACCOUNTSPAYABLEANDACCRUEDLIABILITIESNONCURRENT", "ACCRUEDINCOMETAXESNONCURRENT", "DEFERREDREVENUEANDCREDITSNONCURRENT", "ASSETRETIREMENTOBLIGATIONSNONCURRENT", "CUSTOMERADVANCESORDEPOSITNONCURRENT", "OTHERLIABILITIESNONCURRENT", "DEFERREDTAXLIABILITIESNONCURRENT"]]}
end
