require 'open-uri'
require 'rexml/document'

class NewsController < ApplicationController
  include REXML

  DEFAULT_SOURCE_URL = {
      :kesehatan        => {:url => "http://republika.co.id/rss/index/f/rol/id/5", :category => "Kesehatan"},
      :olahraga         => {:url => "http://republika.co.id/rss/index/f/rol/id/4", :category => "Olahraga"},
      :pendidikan       => {:url => "http://republika.co.id/rss/index/f/rol/id/7", :category => "Pendidikan"},
      :trend_teknologi  => {:url => "http://republika.co.id/rss/index/f/rol/id/11", :category => "Trend Teknologi"}
      }.freeze

  DEFAULT_SEARCH_TEXT = "Enter keywords here"

  def index
    @searched_string = params[:q].nil? ? DEFAULT_SEARCH_TEXT : params[:q].to_s
    fetch_news
    build_map(fetch_news)
  end

  private

  def fetch_news
    searched_keywords = params[:q].to_s
    fetched_news = []
    fetched_news += feed_rss_from_or_default(DEFAULT_SOURCE_URL[:kesehatan], searched_keywords) unless params[:kesehatan].blank?
    fetched_news += feed_rss_from_or_default(DEFAULT_SOURCE_URL[:olahraga], searched_keywords) unless params[:olahraga].blank?
    fetched_news += feed_rss_from_or_default(DEFAULT_SOURCE_URL[:pendidikan], searched_keywords) unless params[:pendidikan].blank?
    fetched_news += feed_rss_from_or_default(DEFAULT_SOURCE_URL[:trend_teknologi], searched_keywords) unless params[:trend_teknologi].blank?

    @fetched_news = fetched_news
  end

  def feed_rss_from_or_default(group=nil, keywords="")
    url = group[:url] || DEFAULT_SOURCE_URL[:kesehatan][:url]
    results = []
    doc = Document.new(open(url))
    doc.root.each_element do |child|
      XPath.each(child, "item") do |xml|
        title = xml.elements["title"].text
        link = xml.elements["link"].text
        description = xml.elements["description"].text
        location = description.split("--").first
        category = group[:category]
        
        regex_keywords = Regexp.new("(#{keywords.split(" ").join("|")})", 1)
        if !title.scan(regex_keywords).blank? || !description.scan(regex_keywords).blank?
          title = title.gsub(regex_keywords, '<strong><i>\1</i></strong>')
          description = description.gsub(regex_keywords, '<strong><i>\1</i></strong>')

          results << {:title => title, :link => link, :description  => description, :category => category, :location => location} 
        else
          results << {:title => title, :link => link, :description  => description, :category => category, :location => location} 
        end
      end
    end
    return results
  end

  def build_map(news = [])
    @map = GMap.new("map_div")
    @map.control_init(:large_map => true,:map_type => true)
    @map.center_zoom_init([-6.211544, 106.845172], 6)
    unless news.blank?
      news.each do |n|

        location = n[:location].to_s.upcase
        long_lat = City.find_by_name(location)
        description = "<div style='color:blue;font-size:80%;'>#{n[:category]}</div><div style='font-size:80%;'>#{n[:title]}</div><div style='font-size:80%'><a href='#{n[:link]}'>more..</a></div>"
        
        @map.overlay_init(GMarker.new([long_lat.latitude, long_lat.longitude], :title => "#{n[:title]}", :info_window => "#{description}")) unless long_lat.blank?

      end
    end
  end

end
