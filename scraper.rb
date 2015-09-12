#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'open-uri'
require 'colorize'

require 'pry'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class String
  def tidy
    self.gsub(/[[:space:]]+/, ' ').strip
  end
end

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def party_from(text)
  return ['unkown', 'Unknown'] if text.to_s.empty?
  return ['APNU-AFC', 'A Party For National Unity + Alliance For Change'] if text.include?('APNU') or text.include?('AFC')
  return ['PPP-Civic', 'People Progressive Party/Civic'] if text.include?('People Progressive Party') or text.include?('Civic')
  warn "Unknown party: #{text}".yellow
end

def region_from(text)
  return ['', ''] if text.to_s.empty?
  if matched = text.match(/Region (\d+) - (.*)/)
    return matched.captures 
  end
  warn "Unknown region: #{text}".green
  return ['', '']
end

def scrape_list(url)
  noko = noko_for(url)
  noko.css('.who-parliament .member-image .swap-title a/@href').map(&:text).each do |link|
    scrape_mp(URI.join url, link)
  end
end

def scrape_mp(url)
  noko = noko_for(url)
  party_id, party   = party_from noko.xpath('.//span[@class="meta-title" and contains(.,"Party")]/following-sibling::text()').text.tidy
  region_id, region = region_from noko.xpath('.//span[@class="meta-title" and contains(.,"Region")]/following-sibling::a').text.tidy
  data = { 
    id: url.to_s.split("/").last,
    name: noko.css('div.bread-crumb li.last').text.tidy.sub(/^Hon.? /,''),
    role: noko.xpath('.//span[@class="meta-title" and contains(.,"Designation")]/following-sibling::text()').text.tidy,
    party_id: party_id,
    party: party,
    area_id: region_id,
    area: region,
    term: 11,
    image: noko.css('.dep-head .member-image img.border/@src').text.sub('__small',''),
    source: url.to_s,
  }
  data[:image] = URI.join(url, URI.escape(data[:image])).to_s unless data[:image].to_s.empty?
  ScraperWiki.save_sqlite([:id, :term], data)
end

scrape_list('http://parliament.gov.gy/about-parliament/parliamentarian')
