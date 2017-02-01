# frozen_string_literal: true
require 'scraped'

class MemberNameParts < Scraped::HTML
  field :prefix do
    partitioned.first
  end

  field :name do
    partitioned.last
  end

  field :gender do
    prefixes_chomped.map { |p| gender_map[p] }.compact.first
  end

  private

  def prefixes
    occupational_prefixes.merge(female_prefixes)
                         .merge(male_prefixes)
  end

  def occupational_prefixes
    %w(Assoc Prof Professor Rev Bishop Prince Dr Lt Col Colonel (Ret’)).to_set
  end

  def female_prefixes
    %w(Mrs Ms Miss)
  end

  def male_prefixes
    %w(Mr)
  end

  def gender_map
    female_prefixes.map { |e| [e, 'female'] }.to_h
                   .merge((male_prefixes.map { |e| [e, 'male'] }).to_h)
  end

  def partitioned
    @partitioned ||= parts.map { |p| p.join ' ' }
  end

  def split_point
    @_split_point ||= chomped_words.find_index { |w| !prefixes.include? w }
  end

  def chomped_words
    @_chomped_words ||= words.map { |w| w.chomp('.') }
  end

  def parts
    @_parts ||= [words.take(split_point), words.drop(split_point)]
  end

  def prefixes_chomped
    @_pref_chomped ||= chomped_words.take(split_point)
  end

  def words
    @_words ||= noko.text.tidy.sub(/^Hon.? /, '').split(/\s/)
  end
end
