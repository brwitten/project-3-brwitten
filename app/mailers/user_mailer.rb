class UserMailer < ApplicationMailer
  default from: 'Two Nouns'
  layout "mailer"

  def welcome_email(current_user)
    @user = current_user
    # need to update URL once deployed
    @url  = 'https://twonounsbeta.herokuapp.com/'
    mail(to: @user.email, subject: 'Welcome to Two Nouns')
  end

  def attach_magazine(current_user, article_info)
    @user = current_user
    @article_info = article_info
    mail(to: @user.email, subject: 'Here is Your Magazine')
  end

end
