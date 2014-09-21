require 'rss'
require 'nokogiri'
require 'fileutils'
require 'tempfile'

def parse_all_rss(from, to)
  download_info     = Array.new
  download_info_alt = Array.new

  (from..to).each do |year|
    (1..12).each do |month|
      month = sprintf('%02d', month)
      url   = "http://www.sec.gov/Archives/edgar/monthly/xbrlrss-#{year}-#{month}.xml"
      print "#{url}..."
      begin
        rss  = open(url)
        rss2 = Tempfile.new(rss.path)

        FileUtils.copy(rss.path, rss2.path)
    
        download_info_alt += parse_rss_alt(year, month, rss)
        download_info     += filter_feed(RSS::Parser.parse(rss2), get_ciks)
      rescue
        print "\nThe RSS Feed could not be found for the period..."
      end
      print "Done\n"
    end
  end
  [download_info, download_info_alt]
end

# Parse RSS Method ===========================================================
def parse_rss_alt(year, month, feed)
  file_paths  = Array.new
  xbrlFilings = filter_feed_alt(Nokogiri::XML(feed), get_ciks)

  xbrlFilings.each do |xbrlFiling|
    cik       = xbrlFiling.children[7].text
    xbrlFiles = xbrlFiling.children[23] != nil ? xbrlFiling.children[23].children : xbrlFiling.children[21].children
    file_path = Array.new

    (1..(xbrlFiles.length - 1)).step(2) do |j|
      url  = xbrlFiles[j].attributes["url"].value

      file_path << url if (url =~ /.(xml|xsd)$/) != nil
    end
    file_paths << [cik, [year.to_s, month.to_s], file_path]
  end
  file_paths
end


# Filter methods ==============================================================
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

def filter_feed_alt(feed, ciks)
  filtered_xbrlFilings = Array.new

  feed.xpath('//item').each do |item|
    if item.children[9].children.text =~ /10-K/
      xbrlFiling = item.children[13] != nil ? item.children[13] : item.children[9]
      cik        = xbrlFiling.children[7].children.text
    
      filtered_xbrlFilings << xbrlFiling if ciks.include?(cik)
    end
  end
  filtered_xbrlFilings
end

# Util Methods ================================================================
def get_ciks
  ciks = Array.new
  File.open('data/my_ciks.txt').each { |line| ciks << line[/\d{10}/] }
  ciks
end

def month_convert(month)
  months = {'01' => "Jan", '02' => "Feb", '03' => "Mar", '04' => "Apr", 
            '05' => "May", '06' => "Jun", '07' => "Jul", '08' => "Aug", 
            '09' => "Sep", '10' => "Oct", '11' => "Nov", '12' => "Dec"}

  months[month]
end