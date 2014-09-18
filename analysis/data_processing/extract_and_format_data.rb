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
    if items != nil
      items.each do |item| 
        #if item.context.id !~ /QTD/ and item.context.id =~ /Q4/ 
        # TODO:
          values << [item.context.id[/\d{4}/], item.value]
        #end
      end
    end
    tags_values << [tag, current_and_previous(values)]
  end 
  tags_values
end

# current_liabilities, accounts_receivable, assets, ofc, revenue, operating_profit, tax_expense, net_income, fixed_assets
# takes { 'ocf' => [["OPERATINACTIVI..", [48384, 4898394]], ["UBDUBDUD", [454634, 2426246]], ... }
# returns {"TAG" => [current_year, previous_year]}
def calculate_figures(data)
  calculated_figures = Hash.new
  data.each do |key, val|
    calculated_figures[key] = val[1] if val.length == 1      
  end
  calculated_figures
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

def find_regex(regexs)
  matching_tags = Hash.new
  Dir["../../download/sec/*/*/*/*"].each do |file_path|
    if file_path =~ /\d+[^_].xml/
      print "#{file_path}..."

      Xbrlware.ins(file_path).item_all_map.keys.each do |key|
        regexs.each do |re|
          matching_tags[re.to_s] = Array.new if matching_tags[re.to_s] == nil
          matching_tags[re.to_s] << key if key =~ re and not matching_tags[re.to_s].include?(key)
        end
      end
      puts "Done"
    end
  end
  matching_tags
end

def get_tags_hash
  {'current_assets' => [["ASSETSCURRENT"]], 
 'current_liabilities' => [["LIABILITIESCURRENT"]], 
 'inventory_net' => [["INVENTORYNET"]], 
 'accounts_receivable' => [["ACCOUNTSRECEIVABLENETCURRENT"], ["RECEIVABLESNETCURRENT"]], 
 'accounts_payable' => [["ACCOUNTSPAYABLECURRENT"], ["ACCOUNTSPAYABLEANDACCRUEDLIABILITIESCURRENT", "ACCRUEDLIABILITIESCURRENT"]], 
 'assets' => [["ASSETS"]], 
 'equity' => [["LIABILITIESANDSTOCKHOLDERSEQUITY", "LIABILITIES"],
 ["LIABILITIESNONCURRENT", "LIABILITIESCURRENT", "LIABILITIESANDSTOCKHOLDERSEQUITY"], ["LIABILITIESANDSTOCKHOLDERSEQUITY", "LIABILITIESCURRENT", "LIABILITIESOTHERTHANLONGTERMDEBTNONCURRENT", "LONGTERMDEBTNONCURRENT"], ["LIABILITIESANDSTOCKHOLDERSEQUITY", "LIABILITIESCURRENT", "OTHERLIABILITIESNONCURRENT", "LONGTERMDEBTNONCURRENT"]],
 'long_term_debt' => [["LONGTERMDEBTANDCAPITALLEASEOBLIGATIONS"], ["LONGTERMDEBTNONCURRENT", "CAPITALLEASEOBLIGATIONSNONCURRENT"], ["LONGTERMDEBTNONCURRENT"]], 
 'current_debt' => [["DEBTCURRENT"], ["SHORTTERMBORROWINGS", "LONGTERMDEBTCURRENT"], ["SHORTTERMBORROWINGS", "LONGTERMDEBTANDCAPITALLEASEOBLIGATIONSCURRENT"]], 
 'fixed_assets' => [["PROPERTYPLANTANDEQUIPMENTNET"]],
 'ocf' => [["NETCASHPROVIDEDBYUSEDINOPERATINGACTIVITIESCONTINUINGOPERATIONS"], ["NETCASHPROVIDEDBYUSEDINCONTINUINGOPERATIONS"],
 ["NETCASHPROVIDEDBYUSEDINOPERATINGACTIVITIES"]], 
 'cogs' => [["COSTOFGOODSANDSERVICESSOLD"], ["COSTOFGOODSSOLD", "COSTOFSERVICES"], ["COSTOFGOODSSOLD"], ["COSTOFSERVICES"], ["COSTOFREVENUE"]], 
 'revenue' => [["REVENUES"], ["SALESREVENUENET"], ["SALESREVENUESERVICESNET"], ["SALESREVENUEGOODSNET"]], 
 'gross_profit' => [["GROSSPROFIT"]], 
 'operating_profit' => [["OPERATINGINCOMELOSS"]], 
 'tax_expense' => [["INCOMETAXEXPENSEBENEFIT"]],
 'pretax_income' => [["INCOMELOSSFROMCONTINUINGOPERATIONSBEFOREINCOMETAXESEXTRAORDINARYITEMSNONCONTROLLINGINTEREST"], 
 ["INCOMELOSSFROMCONTINUINGOPERATIONSBEFOREINCOMETAXESMINORITYINTERESTANDINCOMELOSSFROMEQUITYMETHODINVESTMENTS"], ["INTERESTANDDEBTEXPENSE", "NONOPERATINGINCOMEEXPENSE", "OPERATINGINCOMELOSS"], ["INTERESTANDDEBTEXPENSE", "OPERATINGINCOMELOSS"]], 
 'net_income' => [["NETINCOMELOSS"], ["PROFITLOSS"]], 
 'capex' => [["PAYMENTSTOACQUIREPROPERTYPLANTANDEQUIPMENT"], ["PROPERTYPLANTANDEQUIPMENTGROSS", "ACCUMULATEDDEPRECIATIONDEPLETIONANDAMORTIZATIONPROPERTYPLANTANDEQUIPMENT"]],
 'eps_basic' => [["EARNINGSPERSHAREBASIC"]], 
 'eps_diluted' => [["EARNINGSPERSHAREDILUTED"]]}
end
