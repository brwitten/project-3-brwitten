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
    @text = Readability::Document.new(source, :tags => %w[div p img a], :attributes => %w[src href], :remove_empty_nodes => true).content
    @title = Readability::Document.new(source, :tags => %w[div p img a], :attributes => %w[src href], :remove_empty_nodes => true).title
    @clean_text_2 = @text.gsub("<[^>]*>", "")
    new_article = Article.create(url:@input_url, title:@title, text:@clean_text_2)
    current_user.articles << new_article
    redirect_to('/article_list')
  end

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
