require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'vcr_cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!

  record_mode = ENV['VCR'] ? ENV['VCR'].to_sym : :once
  c.default_cassette_options = { record: record_mode }
end
