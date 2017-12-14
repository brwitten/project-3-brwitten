require 'rubygems'
require 'ruby-readability'
require 'prawn'
require 'open-uri'

class MagazineController < ApplicationController

  before_action :authorize

  def article_list
    @my_articles = UserArticle.where(user_id:current_user.id)
    @published_articles = ArticleMagazine.pluck(:article_id)
    @article_list = []
    # for each value check to see if it is present in published articles, if not add to list
    @my_articles.each do |article|
      # only adding articles that the user hasn't already published
      if !@published_articles.include? article.article_id
        @article_list << Article.find(article.article_id)
      end
    end
  end

#using readability
  def parse_article
    @input_url = params[:search]
    source = open(@input_url).read
    @response = Readability::Document.new(source, :tags => %w[div p img a]).content
    puts @response
    new_article = Article.create_with(url:@input_url, text:@response).find_or_create_by(text:@response)
    current_user.articles << new_article
    redirect_to('/article_list')
  end

#diffbot code
  # def parse_article
  #   token = ENV["DIFFBOT_TOKEN"]
  #   input_url = params[:search]
  #   if input_url =~ /\A#{URI::regexp}\z/
  #     url = URI::encode(input_url)
  #     response = HTTParty.get "https://api.diffbot.com/v3/analyze?token=#{token}&url=#{url}"
  #     @response = response
  #     # response length is a hacky way to know if there was an error in processing the URL
  #     if response.length <= 2
  #       flash[:notice] = 'This is embarassing. That link cannot be processed. Please try a different one.'
  #       redirect_to('/article_list')
  #     else
  #       @title = response["objects"][0]["title"] || "No title"
  #       @author = response["objects"][0]["author"]
  #       @source = response["objects"][0]["siteName"]
  #       @url = response["request"]["pageUrl"]
  #       @date = response["objects"][0]["date"]
  #       @text = response["objects"][0]["text"]
  #       new_article = Article.create_with(url:@url, title:@title, author:@author, published:@date, text:@text).find_or_create_by(title:@title)
  #       current_user.articles << new_article
  #       redirect_to('/article_list')
  #     end
  #   else
  #     flash[:notice] = 'This is embarassing. That link cannot be processed. Please try a different one.'
  #     redirect_to('/article_list')
  #   end
  # end

  def save_magazine
    ## need to save the articles specifically listed
    @my_articles = UserArticle.where(user_id:current_user.id)
    @published_articles = ArticleMagazine.pluck(:article_id)
    @article_list = []
    @my_articles.each do |article|
      if !@published_articles.include? article.article_id
        @article_list << Article.find(article.article_id)
      end
    end
    puts @article_list
    ## save magazine
    mag_name = params[:mag_name]
    if mag_name =~ /^[0-9a-zA-Z_ -'-]*$/
      new_mag = Magazine.create(name:mag_name,user_id:current_user.id)
      @article_list.each do |article|
        new_mag.articles << article
      end
      redirect_to('/user')
    else
      flash[:name_warning] = 'Please only use numbers and letters in your magazine name.'
      redirect_to('/article_list')
    end
  end

  def delete_article
    puts "DEL ARTICLE BEING CALLED"
    article_id = Article.where(id:"#{params["id"]}").pluck(:id)
    to_delete = UserArticle.where(user_id:current_user.id,article_id:article_id)
    to_delete.destroy_all
    redirect_to('/article_list')
  end

  def publish
    @my_articles = UserArticle.where(user_id:current_user.id)
    @article_list = []
    @my_articles.each do |article|
      @article_list << Article.find(article.article_id)
    end
  end

end
