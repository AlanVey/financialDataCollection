require 'nokogiri'
require 'open-uri'

def ticker_to_cik(path)
	tickers = Array.new
	ciks = Array.new

	File.open(path, 'r').each { |line| tickers << line }

	print "Retrieving CIKS..."
	tickers.each do |ticker|
		url 	 = "http://www.sec.gov/cgi-bin/browse-edgar?CIK={#{ticker}}&Find=Search&owner=exclude&action=getcompany"
		url 	 = URI.parse(URI.encode(url.strip))
		parsed = Nokogiri::HTML(open(url)).xpath('//span/a')

		ciks << parsed.text[/\d{10}/] if parsed.length != 0
	end
	puts "Done"
	ciks
end