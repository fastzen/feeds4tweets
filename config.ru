require_relative "app"
require 'rack-livereload'

use Rack::LiveReload
run Sinatra::Application