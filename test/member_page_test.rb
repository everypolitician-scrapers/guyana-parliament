# frozen_string_literal: true
require_relative './test_helper'
require_relative '../lib/member_page.rb'

describe MemberPage do
  describe 'Memeber with single prefix' do
    around { |test| VCR.use_cassette('MrsIndranieChandarpal', &test) }

    subject do
      url = 'http://parliament.gov.gy/about-parliament/parliamentarian/indranie-chandarpal/'
      MemberPage.new(response: Scraped::Request.new(url: url).response)
    end

    it 'should contain the expected data' do
      subject.to_h.must_equal(
        id:               'indranie-chandarpal',
        honorific_prefix: 'Mrs.',
        name:             'Indranie Chandarpal',
        gender:           'female',
        role:             '',
        party_id:         'PPP-Civic',
        party:            'People Progressive Party/Civic',
        area_id:          '',
        area:             '',
        image:            'http://parliament.gov.gy/images/member_photos/92/ms._indra_chanderpal,_m.p..jpg',
        source:           'http://parliament.gov.gy/about-parliament/parliamentarian/indranie-chandarpal/'
      )
    end
  end

  describe 'Member with multiple prefixes' do
    around { |test| VCR.use_cassette('JosephHarmon', &test) }

    subject do
      url = 'http://parliament.gov.gy/about-parliament/parliamentarian/lt-col-ret-joseph-harmon/'
      MemberPage.new(response: Scraped::Request.new(url: url).response)
    end

    it 'should contain the expected data' do
      subject.to_h.must_equal(
        id:               'lt-col-ret-joseph-harmon',
        honorific_prefix: 'Lt. Col. (Ret’)',
        name:             'Joseph Harmon',
        gender:           nil,
        role:             'Minister of State',
        party_id:         'APNU-AFC',
        party:            'A Party For National Unity + Alliance For Change',
        area_id:          '',
        area:             '',
        image:            'http://parliament.gov.gy/images/member_photos/121/joseph_harmon.png',
        source:           'http://parliament.gov.gy/about-parliament/parliamentarian/lt-col-ret-joseph-harmon/'
      )
    end
  end

  describe 'Member with no prefixes' do
    around { |test| VCR.use_cassette('JohnAdams', &test) }

    subject do
      url = 'http://parliament.gov.gy/about-parliament/parliamentarian/mr-john-adams/'
      MemberPage.new(response: Scraped::Request.new(url: url).response)
    end

    it 'should contain the expected data' do
      subject.to_h.must_equal(
        id:               'mr-john-adams',
        honorific_prefix: '',
        name:             'John Adams',
        gender:           nil,
        role:             'Public Security and Human Safety',
        party_id:         'APNU-AFC',
        party:            'A Party For National Unity + Alliance For Change',
        area_id:          '3',
        area:             'Essequibo Islands/West Demerara',
        image:            'http://parliament.gov.gy/images/member_photos/105/john.jpg',
        source:           'http://parliament.gov.gy/about-parliament/parliamentarian/mr-john-adams/'
      )
    end
  end

  describe 'Member without space separating title from name' do
    around { |test| VCR.use_cassette('JagdeoBharrat', &test) }

    subject do
      url = 'http://parliament.gov.gy/about-parliament/parliamentarian/bharrat-jagdeo/'
      MemberPage.new(response: Scraped::Request.new(url: url).response)
    end
    # The member's name is displayed as Dr.Bharrat Jagdeo. Since the name and the title
    # are not separated by a space, the scraper cannot yet separate them properly. Instead,
    # as a temporary fix, we are simply replacing Dr.Bharrat with 'Bharrat'. See issue: #5
    it 'Should contain the expected data' do
      subject.to_h.must_equal(
        id:               'bharrat-jagdeo',
        honorific_prefix: '',
        name:             'Bharrat Jagdeo',
        gender:           nil,
        role:             '',
        party_id:         'PPP-Civic',
        party:            'People Progressive Party/Civic',
        area_id:          '',
        area:             '',
        image:            'http://parliament.gov.gy/images/member_photos/4031/mr._bharrat_jagdeo,_m.p..jpg',
        source:           'http://parliament.gov.gy/about-parliament/parliamentarian/bharrat-jagdeo/'
      )
    end
  end
end
