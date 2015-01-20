require 'net/smtp'
class SendemailController < ApplicationController
  before_filter :login_required, :block_user_from_action, :block_support_from_action
  skip_before_filter :verify_authenticity_token, :only => [:index]
  @selectedmenu = "sendemail"
  def index
    t = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    if (params[:actionadd])
      connectLumbaAppData
      @db.query("insert into user_sendmail set username = '#{params[:sendmail_username]}', email = '#{params[:sendmail_email]}', uni_string = '#{generatemd5code}', latMod = '#{t.to_s}', expiry_date = '#{params[:sendemail_datepicker]}'")
      @user_emails = @db.query("select * from user_sendmail")
      disconnectLumbaAppData
    elsif (params[:commit].eql?("Send"))
      `echo "this is body" | mail -s "Send from Admin Panel" trangtn@sixthgearstudios.com`
      Notifier.welcome("trannhutrang1986@gmail.com").deliver # sends the email
      connectLumbaAppData
      @user_emails = @db.query("select * from user_sendmail")
      disconnectLumbaAppData
    elsif (params[:actionupdate])
      connectLumbaAppData
      @db.query("update user_sendmail set username = '#{params[:sendmail_username]}', email = '#{params[:sendmail_email]}', uni_string = '#{generatemd5code}', latMod = '#{t.to_s}', expiry_date = '#{params[:sendemail_datepicker]}' where id=#{params[:id]}")
      @user_emails = @db.query("select * from user_sendmail")
      disconnectLumbaAppData
    else
      connectLumbaAppData
      @user_emails = @db.query("select * from user_sendmail")
      disconnectLumbaAppData
    end
    @user_emails
  end
end
