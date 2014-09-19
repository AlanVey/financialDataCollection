require 'rubygems'
require 'xbrlware-ruby19'

def find_tags
  tags_data = Hash.new
  xbrl_tags = get_tags

  (2010..Time.now.year).each do |year|
    puts "Reading tags for #{year}..."
    total_hash                = Hash.new
    total_hash["NUMACCOUNTS"] = 0

    (1..12).each do |m|
      print "  Reading tags for #{m}..."
      month = month_convert(sprintf('%02d', m))

      Dir["../../download/sec/#{year}/#{month}/*/*"].each do |file_path|
        if file_path =~ /\d+[^_].xml$/
          open_xbrl = Xbrlware.ins(file_path).item_all_map.keys
          total_hash["NUMACCOUNTS"] += 1
          total_hash = find_matching_priority_tags(xbrl_tags, total_hash, open_xbrl)
        end
      end
      print "Done\n"
    end
    tags_data[year.to_s] = total_hash
    puts "...Done"
  end
  print_tags_to_file(tags_data)
  tags_data
end

def find_matching_priority_tags(tags_hash, hash, keys)
  tags_hash.each do |key, priority_list|
    matched_priority = 100
    for i in 0..(priority_list.length - 1)
      if (priority_list[i] - keys).empty?
        matched_priority = i 
        break
      end
    end

    if matched_priority != 100
      hash[key] = Array.new(priority_list.length, 0) if hash[key] == nil
      hash[key][matched_priority] += 1
    end
  end 
  hash
end

def print_tags_to_file(tags_data)
  File.open('data.csv', 'w') do |file|
    keys = get_keys(tags_data)

    keys.each do |key|
      file.write(", #{key}") if key != "NUMACCOUNTS"
    end
    file.write("\n")

    tags_data.each do |year, tags_hash|
      file.write("#{year}, ")
      keys.each do |key|
        num_acc = tags_hash["NUMACCOUNTS"].to_f
        if key != "NUMACCOUNTS"
          file.write("#{tags_hash[key].inject {|sum, x| sum + x}/num_acc}, ")
        end
      end
      file.write("\n")
    end
  end
  puts "Data printed to data.csv"
end

def get_keys(tags_data)
  all_keys   = tags_data.first[1].keys
  extra_keys = Array.new
  tags_data.each do |year, tags_hash|
    extra_keys = tags_data[year].keys - extra_keys
  end
  extra_keys = all_keys - extra_keys
  all_keys + extra_keys
end

def month_convert(month)
  months = {'01' => "Jan", '02' => "Feb", '03' => "Mar", '04' => "Apr", 
            '05' => "May", '06' => "Jun", '07' => "Jul", '08' => "Aug", 
            '09' => "Sep", '10' => "Oct", '11' => "Nov", '12' => "Dec"}

  months[month]
end

def get_tags
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
 'eps_diluted' => [["EARNINGSPERSHAREDILUTED"]],
 'total_debt' => [["DEBTANDCAPITALLEASEOBLIGATIONS"], ["LONGTERMDEBT", "SHORTTERMDEBT"], ["DEBTCURRENT", "LONGTERMDEBTNONCURRENT"], ["SHORTTERMBORROWINGS", "LONGTERMDEBTCURRENT", "LONGTERMDEBTNONCURRENT"], ["LIABILITIESOTHERTHANLONGTERMDEBTNONCURRENT", "LIABILITIESNONCURRENT", "DEBTCURRENT"], ["LIABILITIESOTHERTHANLONGTERMDEBTNONCURRENT", "LIABILITIESNONCURRENT", "SHORTTERMBORROWINGS", "LONGTERMDEBTCURRENT"], ["LONGTERMDEBTANDCAPITALLEASEOBLIGATIONS", "DEBTCURRENT"], ["LONGTERMDEBTNONCURRENT", "CAPITALLEASEOBLIGATIONSNONCURRENT", "DEBTCURRENT"], ["LONGTERMDEBTNONCURRENT", "DEBTCURRENT"], ["LONGTERMDEBTANDCAPITALLEASEOBLIGATIONS", "SHORTTERMBORROWINGS", "LONGTERMDEBTCURRENT"], ["LONGTERMDEBTNONCURRENT", "CAPITALLEASEOBLIGATIONSNONCURRENT", "SHORTTERMBORROWINGS", "LONGTERMDEBTCURRENT"], ["LONGTERMDEBTNONCURRENT", "SHORTTERMBORROWINGS", "LONGTERMDEBTCURRENT"], ["LONGTERMDEBTANDCAPITALLEASEOBLIGATIONS", "SHORTTERMBORROWINGS", "LONGTERMDEBTANDCAPITALLEASEOBLIGATIONSCURRENT"], ["LONGTERMDEBTNONCURRENT", "CAPITALLEASEOBLIGATIONSNONCURRENT", "SHORTTERMBORROWINGS", "LONGTERMDEBTANDCAPITALLEASEOBLIGATIONSCURRENT"], ["LONGTERMDEBTNONCURRENT", "SHORTTERMBORROWINGS", "LONGTERMDEBTANDCAPITALLEASEOBLIGATIONSCURRENT"]]}
end 
