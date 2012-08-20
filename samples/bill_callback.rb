require '../lib/zipmark.rb'

APP_ID = 'ZmM4ZDk4NGYtYjljNy00NGFkLWFjMDctZGUzMjgwMTM1MDBj'
APP_SECRET = 'd30468fca5bceed398ca9e684d2f57cae3a38abea397a7d73c71a928d0176902a40652f2db99ec33b778bfc6fbd5a6d76e5c8dccdd11aba7ce97cf1d83fb334b'
# example implementation
zipmark = ZipMark.new(APP_ID,APP_SECRET)

#response = zipmark.get_vendor_relationships()
params = {"amount_cents"=> 5000,
          "bill_id"=> "ff762b82-c5ca-4541-9d0a-cc13db6dc677",
          "created_at"=> "2012-08-14T14:50:37Z",
          "date"=> "2012-08-14",
          "id"=> "2f0013ac-77c1-4fc7-b625-826c37fad184",
          "memo"=> "",
          "status"=> "pending",
          "bill_identifier"=> "bill_32",
          "customer_id"=> "001",
          "payee"=> "CurdBee Team",
          "bill_encoded_id"=> "3cce63c674bc6ab5067e85accb063b3b3a67"
         }
response = zipmark.bill_callback(params, ZipMark.API_VERSION_1)
response.each do |name, value|
  puts name + " : " + value
end
puts response.body