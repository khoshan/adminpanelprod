class AdminUsersController < ApplicationController
  before_filter :login_required, :block_user_from_action, :block_support_from_action
  skip_before_filter :verify_authenticity_token, :only => [:index]
  @selectedmenu = "adminUsers"
  def index
    encryptpassword = Encryptpassword.new
    if params[:commit].eql?("Done")
      connectLumbaAppData
        encryptedpassword = encryptpassword.getEncryptedPassword(params[:admin_password])
        @db.query("insert into users set username = '#{params[:admin_name]}', email = '#{params[:admin_email]}', password = '#{encryptedpassword}', ip = '0.0.0.0'")
        @admin_users = @db.query("select * from users")
      disconnectLumbaAppData
      #db = Mysql.new('localhost', 'root', 'lumbapassword', 'LumbaAppData')
      #encryptedpassword = encryptpassword.getEncryptedPassword(params[:admin_password])
      #db.query("insert into users set username = '#{params[:admin_name]}', email = '#{params[:admin_email]}', password = '#{encryptedpassword}', ip = '0.0.0.0'")
      #@admin_users = db.query("select * from users")
      my_logger.info("#{session[:user]['username']} inserted users admin: #{params[:admin_name]} ====== #{params[:admin_email]} ")
      #db.close
    elsif params[:actionupdate]
      connectLumbaAppData
      encryptedpassword = encryptpassword.getEncryptedPassword(params[:admin_password])
      @db.query("update users set username = '#{params[:admin_name]}', password = '#{encryptedpassword}', email = '#{params[:admin_email]}' where id = #{params[:admin_id]}")
      my_logger.info("#{session[:user]['username']} updated users admin: #{params[:admin_name]} ====== #{params[:admin_email]} ")
      @admin_users = @db.query("select * from users")
      disconnectLumbaAppData


      #db = Mysql.new('localhost', 'root', 'lumbapassword', 'LumbaAppData')
      #   encryptedpassword = encryptpassword.getEncryptedPassword(params[:admin_password])
      #  db.query("update users set username = '#{params[:admin_name]}', password = '#{encryptedpassword}', email = '#{params[:admin_email]}' where id = #{params[:admin_id]}")
      #my_logger.info("#{session[:user]['username']} updated users admin: #{params[:admin_name]} ====== #{params[:admin_email]} ")
      #  @admin_users = db.query("select * from users")
      #db.close

    elsif(params[:deleteadminuser])
      connectLumbaAppData
      @db.query("delete from users where id = #{params[:deleteadminuser]}")
      @admin_users = @db.query("select * from users")
      my_logger.info("#{session[:user]['username']} deleted users admin id: #{params[:deleteadminuser]} ")
      disconnectLumbaAppData



      #db = Mysql.new('localhost', 'root', 'lumbapassword', 'LumbaAppData')
      #  db.query("delete from users where id = #{params[:deleteadminuser]}")
      #  @admin_users = db.query("select * from users")
      #my_logger.info("#{session[:user]['username']} deleted users admin id: #{params[:deleteadminuser]} ")
      #db.close
    else
      connectLumbaAppData
        @admin_users = @db.query("select * from users")
      disconnectLumbaAppData 


      #db = Mysql.new('localhost', 'root', 'lumbapassword', 'LumbaAppData')
      #@admin_users = db.query("select * from users")
      #db.close
    end
    @admin_users
    render :index
  end
end
