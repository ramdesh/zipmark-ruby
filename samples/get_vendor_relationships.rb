require '../lib/zipmark.rb'

# example implementation
zipmark = ZipMark.new(ZipMarkConfig::APP_ID,ZipMarkConfig::APP_SECRET)

response = zipmark.get_vendor_relationships
response.each do |name, value|
  puts name + " : " + value
end
puts response.body