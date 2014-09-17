require 'rss'
require 'open-uri'
require 'fileutils'
require 'rubygems'
require 'zip'

def sec_download(from)
	parse_all_rss(from, Time.now.year).each do |financial_stat|
		comp_cik   = financial_stat[1].to_s
		comp_link  = financial_stat[2].to_s
    comp_date  = financial_stat[4].to_s
		target_dir = "sec/#{financial_stat[4][4..7]}/#{financial_stat[4][0..2]}"
	  zip_file   = target_dir + "/#{comp_cik}.zip"

	  FileUtils::mkdir_p(target_dir) 

    if not File.directory?(zip_file.sub(".zip", ''))
		  File.open(zip_file, 'wb') do |fo|
        begin
  		    fo.write open(comp_link).read
          unzip(zip_file)
        rescue Exception => e
          puts e.message
          print "The SEC Does not have the file (404): #{comp_cik}\n"
        end
        FileUtils.rm(zip_file)
      end
    else
      print "Files already downloaded for cik: #{comp_cik} #{comp_date}.\n"
    end
	end
  print "All files have been downloaded.\n"
end

def unzip(path) 
	folder = path.sub(".zip", '')
  FileUtils::mkdir_p(folder)
	Zip::File.open(path) do |zip_file|
  	zip_file.each do |entry|
  		target_dir = folder + "/#{entry.name}"
    	entry.extract(target_dir)

    	entry.get_input_stream.read
    end
  end

  print "Unzipping #{folder} completed.\n"
end

# Both arguments input in years
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

	print edgarFilingsFeed + "...\n"

	begin
		open(edgarFilingsFeed) do |rss|
			company_download_info = feed_reader(RSS::Parser.parse(rss), cik_filter_function)
		end
	rescue
		print "The RSS Feed could not be found for the period\n"
	end

  print "...Done. \n"
  company_download_info
end

def feed_reader(feed, cik_filter)
	filtered_feed = Array.new

	feed.items.each do |item|
		if item.description =~ /10-K/
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
  cik_file = File.open('data/my_ciks.txt')
  cik_file.each do |line|
    cik_filter_list << line[/\d{10}/]
  end
  cik_filter_list
end
