require_relative 'SECdownload.rb'

def check_ciks(from, to, path)
	import_ciks(path) - downloaded_ciks(from, to)
end

def downloaded_ciks(from, to)
	company_download_info = parse_all_rss(from, to)
	downloaded_ciks = Array.new

	company_download_info.each do |item|
		downloaded_ciks << item[1]
	end

	downloaded_ciks
end

def import_ciks(path)
	cik_file = File.open(path, "r")
	cik_list = Array.new

	cik_file.each do |line|
		cik_list << line.to_s.sub(/\s+/, '')
	end

	cik_list
end