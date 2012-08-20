require '../lib/zipmark.rb'

APP_ID = 'ZmM4ZDk4NGYtYjljNy00NGFkLWFjMDctZGUzMjgwMTM1MDBj'
APP_SECRET = 'd30468fca5bceed398ca9e684d2f57cae3a38abea397a7d73c71a928d0176902a40652f2db99ec33b778bfc6fbd5a6d76e5c8dccdd11aba7ce97cf1d83fb334b'
# example implementation
zipmark = ZipMark.new(APP_ID,APP_SECRET)

#response = zipmark.get_vendor_relationships()
params = {"id"=>"0001",
          "amount_cents"=>"5000",
          "bill_template_id"=>"393b1022-8ea5-466a-baaf-23185088c5e4",
          "memo"=> "Memoize",
          "content"=> "{\"memo\":\"Other content\"}",
          "recurring"=> false,
          "customer_id"=> "0089",
          "date"=> "2012-08-19"
         }
response = zipmark.create_bill(params)
response.each do |name, value|
  puts name + " : " + value
end
puts response.body