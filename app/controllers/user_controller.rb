require 'date'
require 'stringio'
require 'base64'
require 'openssl'
require 'cgi'

class UserController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:login, :logout]
  before_filter :login_required, :only => ['welcome', 'change_password', 'hidden']
  VECTOR = "sgs2013ec2%lumba"

  def login
    if cookies[:login]
      puts "session:" + cookies[:login]
        # puts "session:" + session[:login]
        # if session[:login] == ""
        #   session[:login] = 0
        # end        
    else
      puts "no cookies"
      cookies[:login] = 1
    end
    if cookies[:time_now]
      puts "time now:" + cookies[:time_now]
      if cookies[:login].to_i > 4
        @time_diff = Time.parse(DateTime.now.to_s) - Time.parse(cookies[:time_now])
        puts "time diff: " + @time_diff.to_s
        if (@time_diff)/60 > 10
          cookies[:login] = 1
        end 
      end
    end
      # if cookies[:time_now]
      #   puts cookies[:time_now]
      # end
    @login_ss = cookies[:login].to_i()

    if request.post?
      # puts "user: " + authenticate(params[:username], params[:password]).inspect
      # write IP log
      @ip_client = request.remote_ip
      puts "|action|login|" + params[:username] + "|" + params[:password] + '|' + "'#{@ip_client}'"
      # 
      if session[:user] = authenticate(params[:username], params[:password])
        logger.info("get session googleaccount")
        session[:googleacount] = GoogleDrive.login("dashboard@lum.ba", "181fremont")
        redirect_to "/lumba/dashboard"
      else
      end
    end
  end

  def authenticate(login, password)
    # encryptedPassword = encrypt(password)
    # connectLumbaAppData
    # u = @db.query("select * from users where username = '#{login}' and password = '#{encryptedPassword}'")
    # disconnectLumbaAppData
    # user = Hash.new
    # u.each_hash do |row|
    #   user["id"] = row['id']
    #   user["username"] = row['username']
    #   user["password"] = row['password']
    #   user["ip"] = row['ip']
    #   return user
    # end
      if cookies[:login].to_i() < 5
          # end    
          # head :status => 403 and return unless current_user
          #encryptedPassword = getEncryptedPassword(password)
          # certificate = request.cgi.env_table['SSL_CLIENT_CERT'].gsub(/(\n|-----(BEGIN|END) CERTIFICATE-----)/, '');
          # if @me = User::find_by_ssl_certificate(certificate)
          puts getEncryptedPassword("25taylor")
          puts getEncryptedPassword("burgerboutique")
	  begin 
	  
          encryptedPassword = getEncryptedPassword(password)
	  rescue => ex
	   encryptedPassword = ""
	  ensure
	   #encryptedPassword = ""
	  end
          connectLumbaAppData
          #u = @db.query("select * from users where username = '#{login}' and password = '#{encryptedPassword}'")
          u = @db.query("select * from users where username = '#{login}' and password = '#{encryptedPassword}'")
          disconnectLumbaAppData
          user = Hash.new
          rows = 0;
          u.each_hash do |row|
            rows = rows + 1
            #if decrypt(row['password']).eql?(password) 
              user["id"] = row['id']
              user["username"] = row['username']
              user["password"] = row['password']
              user["ip"] = row['ip']
              # check IP address
              # @id = row['id']
               # @ip_client = request.remote_ip
              # # check ip address
              # connectLumbaAppData       
               # c = @db.query("select * from ref_IP where IP='#{@ip_client}'")
              # disconnectLumbaAppData
              # # correct
              # c.each_hash do |row|
                
              # end
              # puts "wrong IP connect"
              cookies[:login] = 1
              cookies[:login_username] = row['username']
              return user
            #else
              # write log to database
            #  cookies[:login] = cookies[:login].to_i() + 1
            #end
          # end
          end
          if rows == 0
            cookies[:login] = cookies[:login].to_i() + 1
          end
          
      end
      if (cookies[:login].to_i() == 5)
        cookies[:time_now] = DateTime.now
      end   
    nil
  end

  def encode(text)
    k = 16
    l = text.length
    output = StringIO.new
    val = k - (l % k)
    val.times { output.write('%02x' % val) }
    return text.to_s + output.string.hex_to_binary
  end

#  def getEncryptedPassword(password)
#    raw = "Key=zesagape7u2a7apedazu3u7u3a9a4ed&GenDT=#{password}"
#    pad_text = encode(raw)
#    encryptor = OpenSSL::Cipher.new("AES-256-CBC")
#    encryptor.iv = VECTOR.encode("ascii")
#    encryptor.encrypt
#    encryptor.key = "zesagape7u2a7apedazu3u7u3a9a4eda"
#    abc = encryptor.update(pad_text)
#    result = CGI.escape(Base64.encode64(abc))
#    result_final = result.gsub("%0A", "")
#puts "result_final " + result_final
#    result_final
#  end


  def logout
    session.clear
    session[:user] = nil
    flash[:message] = 'Logged out'
    redirect_to :action => 'login'
  end

  def forgot_password
    if request.post?
      u= User.find_by_email(params[:user][:email])
      if u and u.send_new_password
        flash[:message] = "A new password has been sent by email."
        redirect_to :action => 'login'
      else
        flash[:warning] = "Couldn't send password"
      end
    end
  end

  def change_password
    @user=session[:user]
    if request.post?
      @user.update_attributes(:password => params[:user][:password], :password_confirmation => params[:user][:password_confirmation])
      if @user.save
        flash[:message]="Password Changed"
      end
    end
  end

  def welcome
  end

  def hidden
  end
end

class String
  def hex_to_binary
    temp = gsub("\s", "");
    ret = []
    (0...temp.size()/2).each { |index| ret[index] = [temp[index*2, 2]].pack("H2") }
    abc = ret[0] + ret[1]
    return abc
  end
end
