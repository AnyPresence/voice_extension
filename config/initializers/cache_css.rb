# Fetches the css files from Chameleon so that it can be used by this extension.
# The view layouts should be able to extract the uri from +CSS_URIS+
CSS_URIS = []
unless Rails.env.test?
  url = URI.parse(ENV['CHAMELEON_HOST']) 
  response = ""
  begin
    done_redirecting = false
    until done_redirecting
      host, port = url.host, url.port if url.host && url.port
      req = Net::HTTP::Get.new(url.path)
      response = Net::HTTP.start(host, port) do |http|
        if url.scheme == "https"
          #http.use_ssl = true
        	# This is temporary
      	  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
        http.request(req)
      end
      response.header['location'] ? url = URI.parse(response.header['location']) :
      done_redirecting = true
    end

    doc = Hpricot(response.body)

    (doc/"link").each do |link|
      CSS_URIS << link.attributes['href']
    end
  rescue
    Rails.logger.error "Unable to obtain css..." + $!.message
  end
end