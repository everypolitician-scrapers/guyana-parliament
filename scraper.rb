#!/bin/env ruby
# frozen_string_literal: true

require 'nokogiri'
require 'pry'
require 'scraped'
require 'scraperwiki'

require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def party_from(text)
  return %w[unkown Unknown] if text.to_s.empty?
  return ['APNU-AFC', 'A Party For National Unity + Alliance For Change'] if text.include?('APNU') or text.include?('AFC')
  return ['PPP-Civic', 'People Progressive Party/Civic'] if text.include?('People Progressive Party') or text.include?('Civic')

  warn "Unknown party: #{text}"
end

def region_from(text)
  return ['', ''] if text.to_s.empty?
  if matched = text.match(/Region (\d+) - (.*)/)
    return matched.captures
  end

  warn "Unknown region: #{text}"
  ['', '']
end

class NameParts
  @@prefixes = %w[Assoc Prof Professor Rev Bishop Prince Dr Lt Col Colonel].to_set
  @@prefixes.merge @@male = %w[Mr]
  @@prefixes.merge @@female = %w[Mrs Ms Miss]
  @@prefixes << '(Ret’)'

  @@gender_map = Hash[@@female.map { |e| [e, 'female'] }].merge(Hash[@@male.map { |e| [e, 'male'] }])

  def initialize(name)
    @orig = name
  end

  def prefix
    partitioned.first
  end

  def name
    # .sub called for specific case where Dr. is not separated from name by space
    partitioned.last.sub('Dr.Bharrat', 'Bharrat')
  end

  def gender
    prefixes_chomped.map { |p| @@gender_map[p] }.compact.first
  end

  private

  def words
    @orig.split(/\s/)
  end

  def chomped_words
    words.map { |w| w.chomp('.') }
  end

  def split_point
    chomped_words.find_index { |w| !@@prefixes.include? w }
  end

  def parts
    [words.take(split_point), words.drop(split_point)]
  end

  def prefixes_chomped
    chomped_words.take(split_point)
  end

  def partitioned
    parts.map { |p| p.join ' ' }
  end
end

def members_data(url)
  noko = noko_for(url)
  noko.css('.who-parliament .member-image .swap-title a/@href').map(&:text).map do |link|
    mp_data(URI.join(url, link))
  end
end

def mp_data(url)
  noko = noko_for(url)
  party_id, party   = party_from noko.xpath('.//span[@class="meta-title" and contains(.,"Party")]/following-sibling::text()').text.tidy
  region_id, region = region_from noko.xpath('.//span[@class="meta-title" and contains(.,"Region")]/following-sibling::a').text.tidy
  nameparts = NameParts.new(noko.css('div.bread-crumb li.last').text.tidy.sub(/^Hon.? /, ''))
  {
    id:               url.to_s.split('/').last,
    honorific_prefix: nameparts.prefix,
    name:             nameparts.name,
    gender:           nameparts.gender,
    role:             noko.xpath('.//span[@class="meta-title" and contains(.,"Designation")]/following-sibling::text()').text.tidy,
    party_id:         party_id,
    party:            party,
    area_id:          region_id,
    area:             region,
    term:             11,
    image:            noko.css('.dep-head .member-image img.border/@src').text.sub('__small', ''),
    source:           url.to_s,
  }
end

data = members_data('http://parliament.gov.gy/about-parliament/parliamentarian')
data.each { |mem| puts mem.reject { |_, v| v.to_s.empty? }.sort_by { |k, _| k }.to_h } if ENV['MORPH_DEBUG']

ScraperWiki.sqliteexecute('DROP TABLE data') rescue nil
ScraperWiki.save_sqlite(%i[id term], data)
