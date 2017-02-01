# frozen_string_literal: true
require 'scraped'

class MemberNameParts < Scraped::HTML
  field :prefix do
    partitioned.first.join(' ')
  end

  field :name do
    partitioned.last.join(' ').tidy
  end

  field :gender do
    return 'male' if (prefixes & MALE_PREFIXES).any?
    return 'female' if (prefixes & FEMALE_PREFIXES).any?
  end

  private

  OCCUPATIONAL_PREFIXES = %w(Assoc Prof Professor Rev Bishop Prince Dr Lt Col Colonel (Ret’)).freeze
  FEMALE_PREFIXES       = %w(Mrs Ms Miss).freeze
  MALE_PREFIXES         = %w(Mr).freeze
  PREFIXES              = OCCUPATIONAL_PREFIXES + FEMALE_PREFIXES + MALE_PREFIXES

  def partitioned
    words.partition { |w| PREFIXES.include? w.chomp('.') }
  end

  def prefixes
    partitioned.first.map { |w| w.chomp('.') }
  end

  def words
    noko.text.tidy.sub(/^Hon.? /, '').split(/\s/)
  end
end
