require_relative 'SECdownload.rb'
require_relative 'SECdownloadAdd.rb'

def download(from)
  sec_download(from)
  sec_download_add(from)
end
