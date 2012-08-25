require '../lib/zipmark.rb'


# example implementation
zipmark = ZipMark.new(ZipMarkConfig::APP_ID,ZipMarkConfig::APP_SECRET)

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