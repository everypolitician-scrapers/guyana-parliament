# frozen_string_literal: true
require 'scraped'

class MembersPage < Scraped::HTML
  decorator Scraped::Response::Decorator::AbsoluteUrls

  field :member_urls do
    noko.css('.who-parliament .member-image .swap-title a/@href').map(&:text).each do |link|
      link
    end
  end
end
