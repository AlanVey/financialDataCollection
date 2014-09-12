require 'rss'
require 'open-uri'
require 'fileutils'
require 'rubygems'
require 'zip'

#===================HELPER METHODS===================
def unzip(path) 
	Zip::File.open(path) do |zip_file|
  		zip_file.each do |entry|
    	  target_dir = "sec/poop/#{entry.name}"
    	  FileUtils::mkdir_p("sec/poop") 
    		puts "Extracting #{entry.name}...\n"
    		entry.extract(target_dir)
    		puts "...Done\n"

    # Read into memory
    		#content = entry.get_input_stream.read
    	end
  end
end


def sec_download(from, to)
	parse_all_rss(from, to).each do |financial_stat|
		target_dir = "sec/#{financial_stat[4][4..7]}/#{financial_stat[4][0..2]}"
		zip_file_name = target_dir[/\d{10}.{19}$/]
	  
	  FileUtils::mkdir_p(target_dir) 
	  
	  exec("wget #{financial_stat[2]};")
	  
	  
	end
end

# Both arguments input in years
def parse_all_rss(from, to)
	company_download_info = Array.new

	for year in from..to
		for month in 1..2
			company_download_info += parse_rss(year, month)
		end
	end

	company_download_info
end

def parse_rss(year, month)
	month = sprintf('%02d', month)
	edgarFilingsFeed = "http://www.sec.gov/Archives/edgar/monthly/xbrlrss-#{year.to_s}-#{month}.xml"
	company_download_info = nil

	print edgarFilingsFeed + "...\n"

	begin
		open(edgarFilingsFeed) do |rss|
			company_download_info = feed_reader(RSS::Parser.parse(rss), cik_filter_function)
		end
	rescue => e
		print e.message
	end

  print "...Done. \n"
  company_download_info
end

def feed_reader(feed, cik_filter)
	filtered_feed = Array.new

	feed.items.each do |item|
		if ["10-K", "10-Q"].include?(item.description)
			cik = cik_extractor(item.title)
			if cik_filter.include?(cik[1])
				link_zip = item.link.sub("index.htm", "xbrl.zip")
				date = item.pubDate.to_s[/[a-zA-Z]+\s\d{4}/]

				filtered_feed << cik + [link_zip, item.description, date]
			end
		end
	end

	filtered_feed
end

def cik_extractor(title)
	cik = title[/\d+/]
	[title.sub("(" + cik + ")", ''), cik]
end

def cik_filter_function
  cik_filter_list = Array.new
  cik_file = File.open('my_ciks.txt')
  cik_file.each do |line|
    cik_filter_list << line[/\d{10}/]
  end
  cik_filter_list = cik_filter_list.reject{|s| s.to_s == ''}
  cik_filter_list
end
