# Load the Rails application.
#require 'memcache'
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
MyApp::Application.initialize!
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8
# trang add memcache
memcache_options = {
  :compression => false,
  :debug => false,
  :urlencode => false
}
#memcache_options = { :urlencode => false }
#CACHE = MemCache.new('lumbacache.asnz1w.cfg.use1.cache.amazonaws.com:11211', memcache_options)
LOAD_SERVER = "http://lumbabalancer-346841882.us-east-1.elb.amazonaws.com"

# trang add for email
ActionMailer::Base.smtp_settings = {
 :address => "email-smtp.eu-west-1.amazonaws.com",
 :port => '25',
 :domain => 'lum.ba',
 :authentication => :login,
 :user_name => "AKIAIB3S3ES4FUKRWSTA",
 :password => "Akb9GYPGxEJyPFxMrgAtfEOv7oNL4Bp49flrekKkloGt",
 :enable_starttls_auto => true,
 :raise_delivery_errors => true
}

NEWRELIC_ENABLE=true
