require 'nokogiri'
require 'open-uri'

def retrieve_company_xbrl_files(feed)
  xml_struct = '//item/edgar:xbrlFiling/edgar:xbrlFiles/edgar:xbrlFile'
  edgar_path = 'http://www.sec.gov/Archives/edgar'

  file_paths = Array.new

  feed.xpath(xml_struct, 'edgar' => edgar_path).each do |i|
    type = i.attributes["type"].value
    url  = i.attributes["url"].value

    if ["10-K", "10-Q"].include?(type) and (url =~ /.(xml|xsd)$/) != nil
      file_paths << url
    end 
  end

  file_paths
end
