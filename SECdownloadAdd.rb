require 'nokogiri'
require 'open-uri'
require_relative 'SECdownload.rb'

def sec_download_add(from)
  file_paths = companies_xbrl_files(from)

  file_paths.each do |company|
    comp_cik   = company[0]
    comp_month = month_convert(company[1][1])
    comp_year  = company[1][0]
    target_dir = "sec/#{comp_year}/#{comp_month}/#{comp_cik}"

    print "Downloading files for #{comp_cik} #{comp_year} #{comp_month}...\n"

    if not File.directory?(target_dir)
      FileUtils::mkdir_p(target_dir)

      company[2].each do |comp_link|
        target_name = comp_link[/\/(?=[^\/]*$)(\S+)/]
        
        File.open("#{target_dir}#{target_name}", 'wb') do |fo|
          begin
            fo.write open(comp_link).read
          rescue
            print "The SEC Does not have the file (404): #{comp_link}\n"
          end
        end
      end
    else
      print "Files already downloaded for cik: #{comp_cik} #{comp_year} #{comp_month} .\n"
    end

    print "...Done\n"

  end
  print "All files have been downloaded.\n"
end

def companies_xbrl_files(from)
  file_paths = Array.new

  for year in from..Time.now.year
    for month in 1..1
      file_paths += companies_xbrl_files_monthly(year, month)
    end
  end

  file_paths
end

def companies_xbrl_files_monthly(year, month)
  month       = sprintf('%02d', month)
  sec_url     = "http://www.sec.gov/Archives/edgar/monthly/xbrlrss-#{year}-#{month}.xml"
  file_paths  = Array.new
  xbrlFilings = retrieve_by_cik(retrieve_by_form_type(sec_url))

  if xbrlFilings == nil
    return Array.new
  end

  xbrlFilings.each do |xbrlFiling|
    cik       = xbrlFiling.children[7].text
    xbrlFiles = xbrlFiling.children[23] != nil ? xbrlFiling.children[23].children : xbrlFiling.children[21].children
    file_path = Array.new

    (1..(xbrlFiles.length - 1)).step(2) do |j|
      url  = xbrlFiles[j].attributes["url"].value

      if (url =~ /.(xml|xsd)$/) != nil
        file_path << url
      end 
    end
    file_paths << [cik, [year.to_s, month.to_s], file_path]
  end

  file_paths
end

def retrieve_by_cik(filtered_items)
  if filtered_items == nil
    return nil
  end

  cik_list             = cik_filter_function
  filtered_xbrlFilings = Array.new

  filtered_items.each do |item|
    xbrlFiling = item.children[13] != nil ? item.children[13] : item.children[9]
    cik        = xbrlFiling.children[7].children.text
    
    filtered_xbrlFilings << xbrlFiling if cik_list.include?(cik)
  end

  filtered_xbrlFilings
end

def retrieve_by_form_type(url)
  feed           = open_feed(url)

  if feed == nil
    return nil
  end

  items          = feed.xpath('//item')
  filtered_items = Array.new

  items.each do |item|
    filtered_items << item if item.children[9].children.text =~ /(10-K|10-Q)/
  end

  filtered_items
end

def open_feed(url)
  feed = nil

  print url + "...\n"

  begin
    open(url) do |rss|
      feed = Nokogiri::XML(rss)
    end
  rescue
    print "The RSS Feed could not be found for the period\n"
  end

  print "...done\n"

  feed
end

def month_convert(month)
  months = {'01' => "Jan", '02' => "Feb", '03' => "Mar", '04' => "Apr", 
            '05' => "May", '06' => "Jun", '07' => "Jul", '08' => "Aug", 
            '09' => "Sep", '10' => "Oct", '11' => "Nov", '12' => "Dec"}

  months[month]
end

