require 'nokogiri'
require 'open-uri'
require_relative 'SECdownload.rb'

def retrieve_by_cik(year, month)
  month = sprintf('%02d', month)
  cik_list = cik_filter_function
  cik_items = Array.new
  feed = open_feed("http://www.sec.gov/Archives/edgar/monthly/xbrlrss-#{year}-#{month}.xml")

  feed.xpath('//item/edgar:xbrlFiling','edgar' => 'http://www.sec.gov/Archives/edgar').each do |item|
    cik_items << item if cik_list.include?(item.children[7].children.text)
  end

  cik_items
end

def open_feed(url)
  feed = nil

  open(url) do |rss|
    feed = Nokogiri::XML(rss)
  end

  feed
end


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
