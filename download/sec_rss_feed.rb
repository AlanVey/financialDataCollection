require 'rss'

def parse_all_rss(from, to)
  company_download_info = Array.new

  (from..to).each do |year|
    (1..12).each do |month|
      company_download_info += parse_rss(year, month)
    end
  end
  company_download_info
end

def parse_rss(year, month)
  month = sprintf('%02d', month)
  edgarFilingsFeed = "http://www.sec.gov/Archives/edgar/monthly/xbrlrss-#{year.to_s}-#{month}.xml"
  company_download_info = Array.new

  print edgarFilingsFeed + "..."

  begin
    open(edgarFilingsFeed) do |rss|
      company_download_info = filter_feed(RSS::Parser.parse(rss), get_ciks)
    end
  rescue
    print "The RSS Feed could not be found for the period\n"
  end

  print "Done. \n"
  company_download_info
end

def filter_feed(feed, ciks)
  filtered_feed = Array.new

  feed.items.each do |item|
    if item.description =~ /10-K/
      cik = item.title[/\d{10}/]
      if ciks.include?(cik)
        link_zip  = item.link.sub("index.htm", "xbrl.zip")
        date      = item.pubDate.to_s[/[a-zA-Z]+\s\d{4}/]
        comp_name = item.title.sub("(#{cik})", '')

        filtered_feed << [comp_name, cik, link_zip, item.description, date]
      end
    end
  end
  filtered_feed
end

def get_ciks
  ciks = Array.new

  File.open('data/my_ciks.txt').each { |line| ciks << line[/\d{10}/] }
  
  ciks
end