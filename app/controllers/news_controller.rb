require 'open-uri'
require 'rexml/document'

class NewsController < ApplicationController
  include REXML

  DEFAULT_SOURCE_URL = {
      :kesehatan        => "http://republika.co.id/rss/index/f/rol/id/5",
      :olahraga         => "http://republika.co.id/rss/index/f/rol/id/4",
      :pendidikan       => "http://republika.co.id/rss/index/f/rol/id/7",
      :trend_teknologi  => "http://republika.co.id/rss/index/f/rol/id/11"}.freeze

  DEFAULT_SEARCH_TEXT = "Enter keywords here"

  def index
    @searched_string = params[:q].nil? ? DEFAULT_SEARCH_TEXT : params[:q].to_s
    build_map
  end
  
  def fetch_news
    searched_keywords = params[:q].to_s
    fetched_news = []
    fetched_news += feed_rss_from_or_default(DEFAULT_SOURCE_URL[:kesehatan], searched_keywords) unless params[:kesehatan].blank?
    fetched_news += feed_rss_from_or_default(DEFAULT_SOURCE_URL[:olahraga], searched_keywords) unless params[:olahraga].blank?
    fetched_news += feed_rss_from_or_default(DEFAULT_SOURCE_URL[:pendidikan], searched_keywords) unless params[:pendidikan].blank?
    fetched_news += feed_rss_from_or_default(DEFAULT_SOURCE_URL[:trend_teknologi], searched_keywords) unless params[:trend_teknologi].blank?

    @fetched_news = fetched_news
    render :update do |page|
      page.replace_html "fetched_news", :partial => 'fetched_news', :locals => {:news => @fetched_news}
    end
  end

  private

  def feed_rss_from_or_default(url=nil, keywords="")
    url ||= DEFAULT_SOURCE_URL[:kesehatan]
    results = []
    doc = Document.new(open(url))
    doc.root.each_element do |child|
      XPath.each(child, "item") do |xml|
        title = xml.elements["title"].text
        link = xml.elements["link"].text
        description = xml.elements["description"].text

        regex_keywords = Regexp.new("(#{keywords.split(" ").join("|")})", 1)
        if !title.scan(regex_keywords).blank? || !description.scan(regex_keywords).blank?
          title = title.gsub(regex_keywords, '<strong><i>\1</i></strong>')
          description = description.gsub(regex_keywords, '<strong><i>\1</i></strong>')
          results << {:title => title, :link => link, :description  => description} 
        end
      end
    end
    return results
  end

  def build_map
    @map = GMap.new("map_div")
    @map.control_init(:large_map => true,:map_type => true)
    @map.center_zoom_init([-6.211544, 106.845172], 6)
    @map.overlay_init(GMarker.new([-6.211544, 106.845172],:title => "Jakarta", :info_window => "jakarta disini"))
    @map.overlay_init(GMarker.new([-6.91243, 107.606903], :title => "bandung", :info_window => "bandung disini"))
  end

end
