#!/usr/bin/env ruby
# encoding: utf-8
require 'rubygems'
require 'uri'
require 'sinatra' 
require 'sinatra/cookies'
require 'slim'
require 'feedjira'
require 'dotenv'

Dotenv.load
enable :sessions
set :session_secret, ENV['SESSION_SECRET']

get "/rss" do
  redirect '/rss.xml'
end

get "/feed" do
  redirect '/feed.xml'
end

get '/' do
  url = cookies['url'].to_s.length == 0 ? ENV['BASE_URL'] : cookies['url']
  begin
    feed = Feedjira::Feed.fetch_and_parse url
    feed.entries.each { |entry| entry.title = CGI::unescapeHTML(entry.title) } # not sure why this is necessary!
    entries = feed.entries
  rescue
    feed = nil
    entries = []
  end
  slim :index, locals: { url: url, entries: entries }
end

post '/change' do
  cookies['url'] = params['url']
  redirect '/'
end

__END__

@@layout 
doctype html 
html
  head 
    meta charset="utf-8" 
    title Feeds4Tweets 
    link rel="stylesheet" media="screen, projection" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous"
    /[if lt IE 9] 
      script src="http://html5shiv.googlecode.com/svn/trunk/html5.js" 
  body 
    .container
      .row
        h1 Feeds4Tweets
      == yield 
      footer
        .row style="padding-top: 1rem;"

@@index
form action="change" method="POST"
  .row
    .col-lg-12
      .form-group
        .input-group
          input.form-control type="text" name="url" value="#{url}"
          span.input-group-btn
            button.btn.btn-primary type="submit" Save URL
- if entries.empty?
  .row
    .alert.alert-success role="alert"
      strong Nothing doing!
      |  No entries found
- unless entries.empty?
  .row
    table.table.table-striped.table-hover.table-condensed
      - entries.each do |entry|
        tr.tasks
          td.tweet
            a.twitter-share-button target="_blank" href="https://twitter.com/intent/tweet?text=#{URI.escape(entry['title'])}&url=#{URI.escape(entry['url'])}"
              == entry['title']
