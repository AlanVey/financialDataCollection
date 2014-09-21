require 'open-uri'
require 'zip'

def sec_download(data)
	data.each do |financial_stat|
		comp_cik   = financial_stat[1].to_s
		comp_link  = financial_stat[2].to_s
    comp_date  = financial_stat[4].to_s
		target_dir = "sec/#{comp_date[4..7]}/#{comp_date[0..2]}"
	  zip_file   = target_dir + "/#{comp_cik}.zip"

	  FileUtils::mkdir_p(target_dir) 

    if not File.directory?(zip_file.sub(".zip", ''))
		  File.open(zip_file, 'wb') do |fo|
        begin
  		    fo.write open(comp_link).read
          unzip(zip_file)
        rescue
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


# Method for alternative download =============================================
def sec_download_alt(data)
  data.each do |company|
    comp_cik   = company[0]
    comp_month = month_convert(company[1][1])
    comp_year  = company[1][0]
    target_dir = "sec/#{comp_year}/#{comp_month}/#{comp_cik}"

    if not File.directory?(target_dir)
      print "Downloading files for #{comp_cik} #{comp_year} #{comp_month}..."
      FileUtils::mkdir_p(target_dir)

      company[2].each do |comp_link|
        target_name = comp_link[/\/(?=[^\/]*$)(\S+)/]
        
        File.open("#{target_dir}#{target_name}", 'wb') do |fo|
          begin
            fo.write open(comp_link).read
          rescue
            print "\nThe SEC Does not have the file (404): #{comp_link}"
          end
        end
      end
      print "Done\n"
    end
  end
  print "All files have been downloaded.\n"
end
