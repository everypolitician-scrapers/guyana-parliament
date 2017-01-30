#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

require 'scraperwiki'
require 'nokogiri'
require 'open-uri'

require 'require_all'
require_rel 'lib'

require 'pry'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class String
  def tidy
    gsub(/[[:space:]]+/, ' ').strip
  end
end

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape(h)
  url, klass = h.to_a.first
  klass.new(response: Scraped::Request.new(url: url).response)
end

def scrape_list(url)
  (scrape url => MembersPage).member_urls.each do |mem_url|
    data = (scrape mem_url => MemberPage).to_h
    warn [data[:honorific_prefix], data[:name], data[:gender]].join(' ----- ')
    ScraperWiki.save_sqlite(%i(id term), data)
  end
end

ScraperWiki.sqliteexecute('DROP TABLE data') rescue nil
scrape_list('http://parliament.gov.gy/about-parliament/parliamentarian')
