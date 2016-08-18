#!/usr/bin/env ruby
# encoding: utf-8
require 'rubygems'
require 'spec_helper.rb'
require 'rack/test'

describe 'App' do

  include Rack::Test::Methods

  before do
    def app
      Sinatra::Application
    end
  end
  
  it "should show the base URL" do
    get '/'
    expect(last_response.body).to include("Feeds4Tweets")
    expect(last_response.body).to include("http://feedjira.com/blog/feed.xml")
  end

  it "should allow a new URL" do
    post '/change', :url => "http://www.sinatrarb.com/feed.xml"
    follow_redirect!
    expect(last_response.body).to include("Sinatra")
  end

end