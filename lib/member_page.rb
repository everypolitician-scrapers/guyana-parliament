# frozen_string_literal: true
require 'scraped'

class MemberPage < Scraped::HTML
  field :id do
    url.to_s.split('/').last
  end

  field :honorific_prefix do
    nameparts.prefix
  end

  field :name do
    nameparts.name
  end

  field :gender do
    nameparts.gender
  end

  field :role do
    noko.xpath('.//span[@class="meta-title" and contains(.,"Designation")]/following-sibling::text()')
        .text
        .tidy
  end

  field :party_id do
    party_id_and_party.first
  end

  field :party do
    party_id_and_party.last
  end

  field :area_id do
    region_id_and_region.first
  end

  field :area do
    region_id_and_region.last
  end

  field :term do
    11
  end

  field :image do
    noko.css('.dep-head .member-image img.border/@src').text.sub('__small', '')
  end

  field :source do
    url.to_s
  end

  private

  def nameparts
    @nameparts ||= (fragment noko.css('div.bread-crumb li.last') => MemberNameParts)
  end

  def party_id_and_party
    party_from noko.xpath('.//span[@class="meta-title" and contains(.,"Party")]/following-sibling::text()')
      .text
      .tidy
  end

  def region_id_and_region
    region_from noko.xpath('.//span[@class="meta-title" and contains(.,"Region")]/following-sibling::a')
      .text
      .tidy
  end

  def party_from(text)
    return %w(unkown Unknown) if text.to_s.empty?
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
end
