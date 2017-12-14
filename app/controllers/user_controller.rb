class UserController < ApplicationController

  def new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      redirect_to '/article_list'
      UserMailer.welcome_email(@user).deliver_now
    else
      redirect_to '/signup'
    end
  end

  def index
    if current_user == nil
      redirect_to('/')
    else
      @my_magazines = Magazine.where(user_id:current_user.id).order(created_at: :desc)
    end
  end

  def generate_pdf
    @mag_id = "#{params["mag_id"]}"
    @mag_title = Magazine.where(id:@mag_id).pluck("name").first
    @mag_articles = ArticleMagazine.where(magazine_id:@mag_id)
    @article_info = []
    @mag_articles.each do |article|
      @article_info << Article.find(article.article_id)
    end
    pdf = Prawn::Document.new
    pdf.font_families.update("Roboto_Slab" => {
      :normal => "app/assets/fonts/Roboto_Slab/RobotoSlab-Regular.ttf",
      :bold => "app/assets/fonts/Roboto_Slab/RobotoSlab-Bold.ttf",
      :italic => "app/assets/fonts/Roboto_Slab/RobotoSlab-Thin.ttf"
    })
    pdf.font "Roboto_Slab"
    pdf.draw_text "#{current_user.name}'s", :at => [10, 650], :size => 35
    pdf.draw_text "Two Nouns Magazine:", :at => [10, 600], :size => 35
    pdf.draw_text "#{@mag_title}", :at => [10, 550], :size => 35
    pdf.draw_text "Created on #{Time.now.strftime("%m/%d/%Y")}", :at => [10, 500], :size => 25
    pdf.start_new_page
    @article_info.each do |article|
      pdf.text "#{article.title}", :style => :bold
      pdf.text "Written By: #{article.author}", :style => :italic
      pdf.pad_top(10) do
        pdf.text "#{article.text}"
      pdf.start_new_page
      end
    end
    pdf.draw_text "Thanks for using Two Nouns", :at => [100, 350], :style => :italic, :size => 25
    send_data pdf.render, :disposition => 'inline'
  end

  def delete_magazine
    @mag_id = "#{params["mag_id"]}"
    @delete_articles = ArticleMagazine.where(magazine_id:@mag_id).pluck(:article_id)
    ArticleMagazine.where(magazine_id:@mag_id).destroy_all
    Magazine.where(id:@mag_id).destroy_all
    @delete_articles.each do |article|
      Article.where(id:article).destroy_all
    end
    redirect_to('/user')
  end

  def email_magazine
    @mag_id = "#{params["mag_id"]}"
    @mag_articles = ArticleMagazine.where(magazine_id:@mag_id)
    @article_info = []
    @mag_articles.each do |article|
      @article_info << Article.find(article.article_id)
    end
    @user = current_user
    UserMailer.attach_magazine(@user,@article_info).deliver_now
    flash[:success]= "Magazine successfully sent. Check your email."
    redirect_to('/user')
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

end
