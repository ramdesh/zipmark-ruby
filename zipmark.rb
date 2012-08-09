require "rubygems"
require "net/http"
require "uri"
require "digest/md5"

# Curdbee app_id/username: ZmM4ZDk4NGYtYjljNy00NGFkLWFjMDctZGUzMjgwMTM1MDBj
# Curdbee app_secret/password: d30468fca5bceed398ca9e684d2f57cae3a38abea397a7d73c71a928d0176902a40652f2db99ec33b778bfc6fbd5a6d76e5c8dccdd11aba7ce97cf1d83fb334b
# Class to access Zipmark REST API
class ZipMark
  include Net::HTTP
  include Digest::MD5
  include URI
  BASE_URL = "https://sandbox.zipmark.com"
  REALM = "Zipmark"
  @@nonce_count = -1
  def initialize(app_id, app_secret)
    @app_id = app_id
    @app_secret = app_secret

  end

  # Build header authorization block to send to given URI
  def build_header_auth(uri, httpmethod)
    response = get_response(uri)
    @cnonce = Digest::MD5.new("%x" % (Time.now.to_i + rand(65535))).hexdigest
    @@nonce_count += 1

    response['www-authenticate'] =~ /^(\w+) (.*)/

    params = {}
    $2.gsub(/(\w+)="(.*?)"/) { params[$1] = $2 }

    a_1 = "#{@app_id}:#{REALM}:#{@app_secret}" #username, realm and password
    a_2 = "#{httpmethod}:#{uri}" #method and path
    request_digest = ''
    request_digest << Digest::MD5.new(a_1).hexdigest
    request_digest << ':' << params['nonce']
    request_digest << ':' << ('%08x' % @@nonce_count)
    request_digest << ':' << @cnonce
    request_digest << ':' << params['qop']
    request_digest << ':' << Digest::MD5.new(a_2).hexdigest

    header = []
    header << "Digest username=\"#{@app_id}\""
    header << "realm=\"#{REALM}\""

    header << "qop=#{params['qop']}"

    header << "algorithm=MD5"
    header << "uri=\"#{@path}\""
    header << "nonce=\"#{params['nonce']}\""
    header << "nc=#{'%08x' % @@nonce_count}"
    header << "cnonce=\"#{CNONCE}\""
    header << "response=\"#{Digest::MD5.new(request_digest).hexdigest}\""

    @header['Authorization'] = header
  end

  # We need to get a response with a WWW-Authenticate request header
  def get_response(uri)
    url = BASE_URL + uri
    uri = URI.parse(url)
    h = Net::HTTP.new uri.host, uri.port
    req = Net::HTTP::Get.new uri.request_uri
    response = h.request req

    return response
  end
end

