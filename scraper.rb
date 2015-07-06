#!/bin/env ruby
# encoding: utf-8

require 'nokogiri'
require 'open-uri'
require 'csv'
require 'scraperwiki'
require 'pry'

require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

def noko_for(url)
  Nokogiri::HTML(open(url).read) 
end

def scrape_list(url)
  noko = noko_for(url)
  noko.css('table#t800c').xpath('.//tr[td[img]]').each do |tr|
    tds = tr.css('td')

    data = { 
      name: tds[2].text.strip,
      area_ar: tds[4].text.strip,
      area: tds[5] ? tds[5].text.strip : '',
      image: tds[1].css('img/@src').text,
      party: "Independent", # no parties allowed
      term: 1,
      source: url,
    }
    if data[:name].include? 'eplaced by'
      data[:end_date] = '2014-08-04'
      data[:name], data[:end_reason] = data[:name].split("\r\n", 2)
    end
    puts data
    ScraperWiki.save_sqlite([:name, :term], data)
  end
end

term = {
  id: '1',
  name: '1st House of Representatives',
  start_date: '2014-08-04',
}
ScraperWiki.save_sqlite([:id], term, 'terms')

scrape_list('https://www.temehu.com/house-of-representatives.htm')
