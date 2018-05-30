# encoding: utf-8
require_relative '../test_helper'

# Daily Mornitor: TS-394
# UI Test: Daily Monitor - Domain Versions/Redirects
class DomainVersionsRedirectTest < Minitest::Test
  def setup
    @expect_200 = [
      'http://www.ncsasports.org',
      'https://www.ncsasports.org/blog/',
      'http://www.reigningchamps.com',
      'ec2-54-84-46-169.compute-1.amazonaws.com',
      'ec2-52-23-217-154.compute-1.amazonaws.com',
      'http://ec2-52-23-177-122.compute-1.amazonaws.com/#!/',
      'http://reigningchamps.com/',
      'http://www.athleticscholarships.com',
      'http://www.athleteswanted.org/',
      'https://getrecruited.ncsasports.org',
      'http://verifiedid.ncsasports.org',
      'http://allinaward.com/'
    ]

    @expect_301 = [
      'https://www.ncsasports.org',
      'http://ncsasports.org',
      'https://ncsasports.org',
      'http://www.ncsasports.com',
      'http://www.ncsasports.org/blog',
      'http://ncsasports.org/blog',
      'https://www.ncsasports.org/blog',
      'https://ncsasports.org/blog',
      'https://ncsasports.org/blog/'
    ]
  end

  def test_domain_redirect
    no_redir = []; bad_resp = []

    @expect_301.each do |url|
      begin
        resp = RestClient::Request.execute(method: :get, url: url)
      rescue => e
        pp "[ERROR] #{url} - #{e}"
        next
      end

      bad_resp << "#{resp.code} - #{url}" unless resp.code.eql? 200

      unless resp.history.empty?
        no_redir << "#{url}" unless resp.history.last.code.eql? 301
      end
    end

    assert_empty no_redir
    assert_empty bad_resp
  end

  def test_domain_no_redirect
    bad_resp = []; redir = []

    @expect_200.each do |url|
      begin
        resp = RestClient::Request.execute(method: :get, url: url)
      rescue => e
        pp "[ERROR] #{url} - #{e}"
        next
      end

      bad_resp << "#{resp.code} - #{url}" unless resp.code.eql? 200
      redir << "#{url} - #{resp.history}" unless resp.history.empty?
    end

    assert_empty bad_resp
    assert_empty redir
  end
end
