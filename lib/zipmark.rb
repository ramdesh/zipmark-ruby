require "rubygems"
require "net/http"
require "net/https"
require "uri"
require "digest/md5"
require "json"
require "openssl"
require "../lib/config.rb"

# Curdbee app_id/username: ZmM4ZDk4NGYtYjljNy00NGFkLWFjMDctZGUzMjgwMTM1MDBj
# Curdbee app_secret/password: d30468fca5bceed398ca9e684d2f57cae3a38abea397a7d73c71a928d0176902a40652f2db99ec33b778bfc6fbd5a6d76e5c8dccdd11aba7ce97cf1d83fb334b
# Class to access Zipmark REST API
class ZipMark
  #include Net::HTTP, Digest::MD5, URI, JSON
  BASE_URL = "https://sandbox.zipmark.com"
  REALM = "Zipmark"
  API_VERSION_1 = 01
  API_VERSION_2 = 00
  @@nonce_count = -1

  # Constructor
  def initialize(app_id, app_secret)
    @app_id = app_id
    @app_secret = app_secret

  end

  # Build header authorization block to send to given URI
  def build_header_auth(uri, version, httpmethod)
    response = get_auth_response(uri)
    @cnonce = Digest::MD5.hexdigest("%x" % (Time.now.to_i + rand(65535)))
    @@nonce_count += 1

    response['www-authenticate'] =~ /^(\w+) (.*)/
    challenge = $2
    params = {}
    challenge.gsub(/(\w+)="(.*?)"/) { params[$1] = $2 }

    a_1 = "#{@app_id}:#{params['realm']}:#{@app_secret}" #username, realm and password
    a_2 = "#{httpmethod}:#{uri}" #method and path
    request_digest = ''
    request_digest << Digest::MD5.hexdigest(a_1)
    request_digest << ':' << params['nonce']
    request_digest << ':' << ('%08x' % @@nonce_count)
    request_digest << ':' << @cnonce
    request_digest << ':' << params['qop']
    request_digest << ':' << Digest::MD5.hexdigest(a_2)

    header = []
    header << "Digest username=\"#{@app_id}\""
    header << "realm=\"#{params['realm']}\""

    header << "qop=#{params['qop']}"

    header << "algorithm=MD5"
    header << "uri=\"#{uri}\""
    header << "nonce=\"#{params['nonce']}\""
    header << "nc=#{'%08x' % @@nonce_count}"
    header << "cnonce=\"#{@cnonce}\""
    header << "response=\"#{Digest::MD5.hexdigest(request_digest)}\""
    header << "opaque=\"#{params['opaque']}\""

    header_auth_str = header.join(', ')
    @header = {}
    @header["Content-Type"] = "application/json"
    if version == API_VERSION_2
      @header["Accept"] = "application/vnd.com.zipmark.v2+json"
    else
      @header["Accept"] = "application/vnd.com.zipmark.v1+json"
    end
    @header["Authorization"] = header_auth_str
    @header["Host"] = "curdbee.com"
  end
  private:build_header_auth
  # Build request (allows reuse)
  def build_request()
    @http = Net::HTTP.new(@uri.host, @uri.port)
    @http.use_ssl = true
    @http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  end
  private:build_request

  # We need to get a response with a WWW-Authenticate request header
  def get_auth_response(uri)
    url = BASE_URL + uri
    @uri = URI.parse(url)
    build_request()
    req = Net::HTTP::Get.new(@uri.request_uri)
    response = @http.request(req)

    return response
  end
  private:get_auth_response

  #-----------------------START PUBLIC METHODS---------------------------------#
  # Method to get approval rules
  def get_approval_rules()
    build_header_auth('/approval_rules', API_VERSION_1, 'GET')
    build_request()
    request = Net::HTTP::Get.new(@uri.request_uri)
    #puts "Request headers\n"
    @header.each do |name, value|
      request[name] = value

      #puts name+": "+value
    end

    response = @http.request(request)
    # response.body = JSON.parse(response.body)
    return response

  end

  # Method to get vendor relationships
  def get_vendor_relationships()
    build_header_auth('/vendor_relationships', API_VERSION_1, 'GET')
    build_request()
    request = Net::HTTP::Get.new(@uri.request_uri)
    @header.each do |name, value|
      request[name] = value
    end
    response = @http.request(request)
    # response.body = JSON.parse(response.body)
    return response
  end

  # Create a bill
  # Params should be formatted as follows:
  # id, amount_cents, bill_template_id, memo, content, recurring, customer_id, date
  def create_bill(params)
    build_header_auth('/bills', API_VERSION_1, 'POST')
    build_request()
    p_hash = {}
    p_hash["bill"] = {"identifier"        => params['id'],
      "amount_cents"      => params['amount_cents'],
      "bill_template_id"  => params['bill_template_id'],
      "memo"              => params['memo'],
      "content"           => params['content'],
      "recurring"         => params['recurring'],
      "customer_id"       => params['customer_id'],
      "date"              => params['date']}
      req_body = p_hash.to_json.to_s
      request = Net::HTTP::Post.new(@uri.request_uri)
      @header.each do |name, value|
        request[name] = value
      end
      # request.each do |name, value|
      #   puts name+" : "+value
      # end
      request.set_body_internal(req_body)
      response = @http.request(request)
      # response.body = JSON.parse(response.body)
      return response
    end

    # Bill callback request
    def bill_callback(params, api_version)
      if api_version == API_VERSION_1
        build_header_auth('/callback', API_VERSION_1, 'POST')
        build_request()
        p_hash = {}
        p_hash["callback"] = {
          "amount_cents"    => params['amount_cents'],
          "bill_id"         => params['bill_id'],
          "created_at"      => params['created_at'],
          "date"            => params['date'],
          "id"              => params['id'],
          "memo"            => params['memo'],
          "status"          => params['status'],
          "bill_identifier" => params['bill_identifier'],
          "customer_id"     => params['customer_id'],
          "payee"           => params['payee'],
          "bill_encoded_id" => params['bill_encoded_id']
        }
        req_body = p_hash.to_json.to_s
        request = Net::HTTP::Post.new(@uri.request_uri)
        @header.each do |name,value|
          request[name] = value
        end
        request.set_body_internal(req_body)
        response = @http.request(request)
        return response
      else if api_version == API_VERSION_2
        build_header_auth('/callbacks', API_VERSION_2, 'POST')
        build_request()
        p_hash = {}
        p_hash["callback"] = {
          "api_version"    => "v2",
          "url"            => "https://curdbee.com/callbacks",
          "event"          => "bill.update"
        }
        req_body = p_hash.to_json.to_s
        request = Net::HTTP::Post.new(@uri.request_uri)
        @header.each do |name,value|
          request[name] = value
        end
        request.set_body_internal(req_body)
        response = @http.request(request)
        # response.body = JSON.parse(response.body)
        return response
      end
    end
  end
end
    