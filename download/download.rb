require_relative 'sec_download_methods'
require_relative 'sec_rss_feed'

def download(from)
  data = parse_all_rss(from, Time.now.year)
  
  sec_download(data[0])
  sec_download_alt(data[1])
end
