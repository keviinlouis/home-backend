require 'vcr'
require 'webmock'

WebMock.enable!
VCR.configure do |config|
  config.hook_into :webmock
  config.ignore_hosts 'codeclimate.com'
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.allow_http_connections_when_no_cassette = false
  config.default_cassette_options = { record: :once, match_requests_on: %i[method host] }
end
