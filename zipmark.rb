require "rubygems"
require "httparty"

# Class to access Zipmark REST API
class ZipMark
  include HTTParty
  base_url = "https://sandbox.zipmark.com"
  
  def initialize(app_id, app_secret)
    @app_id = app_id
    @app_secret = app_secret
  end
  
  # Build header authorization block to send to given URI
  def build_header_auth(uri)
    @header = "Digest username:\"#{@app_id}\", 
                          realm:\"Zipmark\", 
                          uri:\"#{uri}\",
                          nonce:\"#{@app_secret}\""
  end
end


