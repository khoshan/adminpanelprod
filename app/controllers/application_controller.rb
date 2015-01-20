require 'net/http'
require 'open-uri'
require 'date'
require 'stringio'
require 'base64'
#require 'openssl'
require 'cgi'
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  APP_CONFIG = YAML.load_file("#{Rails.root}/config/config.yml")
  VECTOR = "sgs2013ec2%lumba"

  def login_required
    if session[:googleacount].nil?
      logger.info("come here come here")
      session[:googleacount] = GoogleDrive.login("dashboard@lum.ba", "181fremont")
    end
    if session[:user]
      return true
    end
    flash[:warning]='Please login to continue'
    redirect_to :controller => "user", :action => "login"
    return false
  end

  def blockIp
    ipblocks_file = YAML.load_file("#{Rails.root}/config/blockips.yml")
    ipblocks = ipblocks_file['ipaddress'].split(",")
    logger.info(ipblocks)
    ipblocks.each { |ipbl|
      logger.info(ipbl)
      logger.info(request.remote_ip.to_s)
      logger.info(request.remote_ip.to_s.eql?(ipbl))
      logger.info("-----")
      if request.remote_ip.eql?(ipbl)
        redirect_to "/500.html"
        return false
      end
    }
  end

  def block_user_from_action
    if (session[:user]['username'].eql?("tr-support@lum.ba") || session[:user]['username'].eql?("abdulrahman.aldawood@lum.ba") || session[:user]['username'].eql?("osama.fattouh@lum.ba") || session[:user]['username'].eql?("saleh.bazarah@lum.ba") || session[:user]['username'].eql?("moataz.albanyan@lum.ba") || session[:user]['username'].eql?("anwar.sedam@lum.ba"))
      redirect_to "/501.html"
      return true
    else
      return false
    end
  end
  def is_support
    if (session[:user]['username'].eql?("tr-support@lum.ba") || session[:user]['username'].eql?("abdulrahman.aldawood@lum.ba") || session[:user]['username'].eql?("osama.fattouh@lum.ba") || session[:user]['username'].eql?("saleh.bazarah@lum.ba") || session[:user]['username'].eql?("moataz.albanyan@lum.ba") || session[:user]['username'].eql?("anwar.sedam@lum.ba"))
      return true
    else
      return false
    end
  end
  def block_support_from_action
    if (session[:user]['username'].eql?("emilio"))
      redirect_to "/501.html"
      return true
    else
      return false
    end
  end

  def raise_not_found!
    redirect_to "/404.html"
  end

  def encode(text)
    k = 16
    l = text.length
    output = StringIO.new
    val = k - (l % k)
    val.times { output.write('%02x' % val) }
    return text.to_s + output.string.hex_to_binary
  end

  def getEncryptedPassword(password)
    raw = "Key=zesagape7u2a7apedazu3u7u3a9a4ed&GenDT=#{password}"
    pad_text = encode(raw)
    encryptor = OpenSSL::Cipher.new("AES-256-CBC")
    encryptor.iv = VECTOR.encode("ascii")
    encryptor.encrypt
    encryptor.key = "zesagape7u2a7apedazu3u7u3a9a4eda"
    abc = encryptor.update(pad_text)
    result = CGI.escape(Base64.encode64(abc))
    result_final = result.gsub("%0A", "")
    result_final
  end

  def checkpassword(password)
    getEncryptedPassword(password) == session[:user]['password']
  end

  def encrypt(string)
    Base64.encode64(aes(string)).gsub /\s/, ''
  end

  def decrypt(string)
    aes_decrypt(Base64.decode64(string))
  end

  def aes(string)
    cipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
    cipher.encrypt
    cipher.key = Digest::SHA256.digest(VECTOR)
    cipher.iv = initialization_vector = cipher.random_iv
    cipher_text = cipher.update(string)
    cipher_text << cipher.final
    return initialization_vector + cipher_text
  end

  def aes_decrypt(encrypted)
    cipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
    cipher.decrypt
    cipher.key = Digest::SHA256.digest(VECTOR)
    cipher.iv = encrypted.slice!(0, 16)
    d = cipher.update(encrypted)
    d << cipher.final
  end

  def read_properties_file
    properties_config = YAML.load_file("#{Rails.root}/config/properties.yml")
    @selectedServer = decrypt(properties_config['server1'])
    game_server_config = YAML.load_file("#{Rails.root}/config/game_version.yml")
    @game_version = session[:game_version_production]
  end

  def current_user
    session[:user]
  end

  def redirect_to_stored
    if return_to = session[:return_to]
      session[:return_to]=nil
      redirect_to_url(return_to)
    else
      redirect_to :controller => 'user', :action => 'welcome'
    end
  end

  def connectdb
    @dbgeneral = Mysql.new(APP_CONFIG['mysql']['address'], APP_CONFIG['mysql']['username'], APP_CONFIG['mysql']['password'])
  end

  def disconnectdb
    @dbgeneral.close
  end

  def connectLumbaAppData
    game_server_config = YAML.load_file("#{Rails.root}/config/game_version.yml")
    @game_version = session[:game_version_production]
    properties_config = YAML.load_file("#{Rails.root}/config/properties.yml")
    @selectedServer = decrypt(properties_config['server1'])
    @db = Mysql.new(APP_CONFIG['mysql']['address'], APP_CONFIG['mysql']['username'], APP_CONFIG['mysql']['password'], decrypt(properties_config['mysql1']))
  end

  def disconnectLumbaAppData
    @db.close
  end

  def connectLumba
    puts APP_CONFIG['mysql_lumba']['dbname']
    @dblumba = Mysql.new(APP_CONFIG['mysql_lumba']['address'], APP_CONFIG['mysql_lumba']['username'], APP_CONFIG['mysql_lumba']['password'], APP_CONFIG['mysql_lumba']['dbname'])
    @dblumba.query "SET NAMES utf8"
  end

  def disconnectLumba
    @dblumba.close
  end

  def connectLumba2
    puts APP_CONFIG['mysql_lumba']['dbname']
    @dblumba2 = Mysql2::Client.new(:host => APP_CONFIG['mysql_lumba']['address'], :username => APP_CONFIG['mysql_lumba']['username'], :password => APP_CONFIG['mysql_lumba']['password'], :database => APP_CONFIG['mysql_lumba']['dbname'])
    @dblumba2.query "SET NAMES utf8"
  end

  def disconnectLumba2
    @dblumba2.close
  end

  def connectLumbaIAP
    puts APP_CONFIG['mysql_lumba']['dbname']
    @dbsfs = Mysql.new(APP_CONFIG['mysql_lumba_iap']['address'], APP_CONFIG['mysql_lumba_iap']['username'], APP_CONFIG['mysql_lumba_iap']['password'], APP_CONFIG['mysql_lumba_iap']['dbname'])
    @dbsfs.query "SET NAMES utf8"
  end

  def connectLumbaIAP2
    puts APP_CONFIG['mysql_lumba']['dbname']
    @dbsfs2 = Mysql2::Client.new(:host => APP_CONFIG['mysql_lumba_iap']['address'], :username => APP_CONFIG['mysql_lumba_iap']['username'], :password => APP_CONFIG['mysql_lumba_iap']['password'], :database => APP_CONFIG['mysql_lumba_iap']['dbname'])
    @dbsfs2.query "SET NAMES utf8"
    logger.info('opened')
  end

  def connectLumbaAppData2
    # puts APP_CONFIG['mysql']['dbname']
    puts APP_CONFIG['mysql_lumba']['dbname']
    @dbsfs2 = Mysql2::Client.new(:host => APP_CONFIG['mysql']['address'], :username => APP_CONFIG['mysql']['username'], :password => APP_CONFIG['mysql']['password'], :database => APP_CONFIG['mysql']['dbname'])
    @dbsfs2.query "SET NAMES utf8"
    # logger.info('opened')
  end

  def disconnectLumbaAppData2
    @dbsfs2.close
    # logger.info('closed')
  end

  def disconnectLumbaIAP2
    @dbsfs2.close
    logger.info('closed')
  end

  def disconnectLumbaIAP
    @dbsfs.close
  end

  def copy_file_to_server(filepath, version, server)
    password_ballancer = APP_CONFIG['balancer_server']['password']
    `sshpass -p '#{password_ballancer}' scp #{filepath} #{APP_CONFIG['balancer_server']['address1']}:/home/lumbarunner/apps/lumba_loadbalancer/resources/#{version}`
    `sshpass -p '#{password_ballancer}' scp #{filepath} #{APP_CONFIG['balancer_server']['address2']}:/home/lumbarunner/apps/lumba_loadbalancer/resources/#{version}`
  end

  def copy_property_to_server(filepath, server)
    properties_config = YAML.load_file("#{Rails.root}/config/properties.yml")
    password_ballancer = APP_CONFIG['balancer_server']['password']
    `sshpass -p '#{password_ballancer}' scp #{filepath} #{APP_CONFIG['balancer_server']['address1']}:/home/lumbarunner/apps/lumba_loadbalancer/resources/`
    `sshpass -p '#{password_ballancer}' scp #{filepath} #{APP_CONFIG['balancer_server']['address2']}:/home/lumbarunner/apps/lumba_loadbalancer/resources/`
  end

  def get_newgame_fromserver
    password_sfs = APP_CONFIG['sfs_server']['password']
    if !session[:sfs_server].eql?("")
      `sshpass -p '#{password_sfs}' scp #{session[:sfs_server]}:/home/lumbarunner/apps/SmartFoxServer_2X/SFS2X/data/lumba/core/newGame.txt #{Rails.root}/exportedfile/sfs/newGame.txt`
    else
      file = File.open("#{Rails.root}/exportedfile/sfs/newGame.txt", "w") {}
    end
  end

  def get_newgame_fromstageserver
    `scp -i ~/.ec2/fayez-eu-region-keypair root@ec2-54-195-70-23.eu-west-1.compute.amazonaws.com:/root/apps/SmartFoxServer_2X/SFS2X/data/lumba/core/newGame.txt #{Rails.root}/exportedfile/sfs/newGame.txt`
  end

  def gettournamentDurationfromserver
    password_sfs = APP_CONFIG['sfs_server']['password']
    puts "sshpass -p '#{password_sfs}' scp #{session[:sfs_server]}:/home/lumbarunner/apps/SmartFoxServer_2X/SFS2X/data/lumba/core/tournamentDuration.txt #{Rails.root}/exportedfile/sfs/tournamentDuration.txt"
    if !session[:sfs_server].eql?("")
      if (session[:sfs_server].eql?(APP_CONFIG['sfs_server']['address1']) || session[:sfs_server].eql?(APP_CONFIG['sfs_server']['address2']) || session[:sfs_server].eql?(APP_CONFIG['sfs_server']['address3']))
        `sshpass -p '#{password_sfs}' scp #{session[:sfs_server]}:/home/lumbarunner/apps/SmartFoxServer_2X/SFS2X/data/lumba/core/tournamentDuration.txt #{Rails.root}/exportedfile/sfs/tournamentDuration.txt`
      else
        file = File.open("#{Rails.root}/exportedfile/sfs/tournamentDuration.txt", "w") {}
      end
    else
      file = File.open("#{Rails.root}/exportedfile/sfs/tournamentDuration.txt", "w") {}
    end
  end

  def get_dagger_ranges_fromserver
    password_sfs = APP_CONFIG['sfs_server']['password']
    puts "sshpass -p '#{password_sfs}' scp #{session[:sfs_server]}:/home/lumbarunner/apps/SmartFoxServer_2X/SFS2X/data/lumba/core/opponent_search.properties #{Rails.root}/exportedfile/sfs/opponent_search.properties"
    if !session[:sfs_server].eql?("")
      if (session[:sfs_server].eql?(APP_CONFIG['sfs_server']['address1']) || session[:sfs_server].eql?(APP_CONFIG['sfs_server']['address2']) || session[:sfs_server].eql?(APP_CONFIG['sfs_server']['address3']))
        `sshpass -p '#{password_sfs}' scp #{session[:sfs_server]}:/home/lumbarunner/apps/SmartFoxServer_2X/SFS2X/data/lumba/core/opponent_search.properties #{Rails.root}/exportedfile/sfs/opponent_search.properties`
      else
        file = File.open("#{Rails.root}/exportedfile/sfs/opponent_search.properties", "w") {}
      end
    else
      file = File.open("#{Rails.root}/exportedfile/sfs/opponent_search.properties", "w") {}
    end
  end

  def get_attack_matching_limit_fromserver
    password_sfs = APP_CONFIG['sfs_server']['password']
    if !session[:sfs_server].eql?("")
      if (session[:sfs_server].eql?(APP_CONFIG['sfs_server']['address1']) || session[:sfs_server].eql?(APP_CONFIG['sfs_server']['address2']) || session[:sfs_server].eql?(APP_CONFIG['sfs_server']['address3']))
        `sshpass -p '#{password_sfs}' scp #{session[:sfs_server]}:/home/lumbarunner/apps/SmartFoxServer_2X/SFS2X/data/lumba/core/attack_matching_limit.properties #{Rails.root}/exportedfile/sfs/attack_matching_limit.properties`
      else
        file = File.open("#{Rails.root}/exportedfile/sfs/attack_matching_limit.properties", "w") {}
      end
    else
      file = File.open("#{Rails.root}/exportedfile/sfs/attack_matching_limit.properties", "w") {}
    end
  end

  # get inap purchases from server
  def getpurchasesfromserver
    password_sfs = APP_CONFIG['sfs_server']['password']
    if !session[:sfs_server].eql?("")
      if (session[:sfs_server].eql?(APP_CONFIG['sfs_server']['address1']) || session[:sfs_server].eql?(APP_CONFIG['sfs_server']['address2']) || session[:sfs_server].eql?(APP_CONFIG['sfs_server']['address3']))
        `sshpass -p '#{password_sfs}' scp #{session[:sfs_server]}:/home/lumbarunner/apps/SmartFoxServer_2X/SFS2X/data/lumba/core/purchases.txt #{Rails.root}/exportedfile/sfs/purchases.txt`
      else
        file = File.open("#{Rails.root}/exportedfile/sfs/purchases.txt", "w") {}
      end
    else
      file = File.open("#{Rails.root}/exportedfile/sfs/purchases.txt", "w") {}
    end
  end

  # get kochava status from server
  def getkochavastatusfromserver
    password_sfs = APP_CONFIG['sfs_server']['password']
    if !session[:sfs_server].eql?("")
      if (session[:sfs_server].eql?(APP_CONFIG['sfs_server']['address1']) || session[:sfs_server].eql?(APP_CONFIG['sfs_server']['address2']) || session[:sfs_server].eql?(APP_CONFIG['sfs_server']['address3']))
        `sshpass -p '#{password_sfs}' scp #{session[:sfs_server]}:/home/lumbarunner/apps/SmartFoxServer_2X/SFS2X/data/lumba/core/kochavastatus.txt #{Rails.root}/exportedfile/sfs/kochavastatus.txt`
      else
        file = File.open("#{Rails.root}/exportedfile/sfs/kochavastatus.txt", "w") {}
      end
    else
      file = File.open("#{Rails.root}/exportedfile/sfs/kochavastatus.txt", "w") {}
    end
  end

  def load_properties(properties_filename)
    properties = {}
    File.open(properties_filename, 'r') do |properties_file|
      properties_file.read.each_line do |line|
        line.strip!
        if (line[0] != ?# and line[0] != ?=)
          i = line.index('=')
          if (i)
            properties[line[0..i - 1].strip] = line[i + 1..-1].strip
          else
            properties[line] = ''
          end
        end
      end
    end
    properties
  end

  def get_sfs_version_from_balancer_version(balancer_version)
    prop1 = load_properties("#{Rails.root}/exportedfile/sfs/settings1.properties")
    prop2 = load_properties("#{Rails.root}/exportedfile/sfs/settings2.properties")
    prop3 = load_properties("#{Rails.root}/exportedfile/sfs/settings3.properties")
    ver1 = load_properties("#{Rails.root}/exportedfile/sfs/version1.properties")
    ver2 = load_properties("#{Rails.root}/exportedfile/sfs/version2.properties")
    ver3 = load_properties("#{Rails.root}/exportedfile/sfs/version3.properties")
    if (ver1['version'].eql?(balancer_version))
      return prop1['sfs_version']
    elsif (ver2['version'].eql?(balancer_version))
      return prop2['sfs_version']
    elsif (ver3['version'].eql?(balancer_version))
      return prop3['sfs_version']
    else
      return nil
    end
  end

  def get_balancer_version_from_sfs_version(sfs_version)
    prop1 = load_properties("#{Rails.root}/exportedfile/sfs/settings1.properties")
    prop2 = load_properties("#{Rails.root}/exportedfile/sfs/settings2.properties")
    prop3 = load_properties("#{Rails.root}/exportedfile/sfs/settings3.properties")
    ver1 = load_properties("#{Rails.root}/exportedfile/sfs/version1.properties")
    ver2 = load_properties("#{Rails.root}/exportedfile/sfs/version2.properties")
    ver3 = load_properties("#{Rails.root}/exportedfile/sfs/version3.properties")
    logger.info("sfs_version: #{sfs_version}    pro1: #{prop1['sfs_version']}  pro2: #{prop2['sfs_version']}  pro3: #{prop3['sfs_version']}")
    balancer_version = nil
    if (prop1['sfs_version'].eql?(sfs_version.to_s))
      balancer_version = ver1['version']
    end
    if (prop2['sfs_version'].eql?(sfs_version.to_s))
      balancer_version = ver2['version']
    end
    if (prop3['sfs_version'].eql?(sfs_version.to_s))
      balancer_version = ver3['version']
    end
    return balancer_version
  end


  def getserver
    password_sfs = APP_CONFIG['sfs_server']['password']
    puts "sshpass -p '#{password_sfs}' scp #{APP_CONFIG['sfs_server']['address1']}:/home/lumbarunner/apps/SmartFoxServer_2X/SFS2X/config/lumba/version.properties #{Rails.root}/exportedfile/sfs/version1.properties"
    `sshpass -p '#{password_sfs}' scp #{APP_CONFIG['sfs_server']['address1']}:/home/lumbarunner/apps/SmartFoxServer_2X/SFS2X/config/lumba/version.properties #{Rails.root}/exportedfile/sfs/version1.properties`
    `sshpass -p '#{password_sfs}' scp #{APP_CONFIG['sfs_server']['address1']}:/home/lumbarunner/apps/SmartFoxServer_2X/SFS2X/config/lumba/settings.properties #{Rails.root}/exportedfile/sfs/settings1.properties`
    `sshpass -p '#{password_sfs}' scp #{APP_CONFIG['sfs_server']['address2']}:/home/lumbarunner/apps/SmartFoxServer_2X/SFS2X/config/lumba/version.properties #{Rails.root}/exportedfile/sfs/version2.properties`
    `sshpass -p '#{password_sfs}' scp #{APP_CONFIG['sfs_server']['address2']}:/home/lumbarunner/apps/SmartFoxServer_2X/SFS2X/config/lumba/settings.properties #{Rails.root}/exportedfile/sfs/settings2.properties`
    `sshpass -p '#{password_sfs}' scp #{APP_CONFIG['sfs_server']['address3']}:/home/lumbarunner/apps/SmartFoxServer_2X/SFS2X/config/lumba/version.properties #{Rails.root}/exportedfile/sfs/version3.properties`
    `sshpass -p '#{password_sfs}' scp #{APP_CONFIG['sfs_server']['address3']}:/home/lumbarunner/apps/SmartFoxServer_2X/SFS2X/config/lumba/settings.properties #{Rails.root}/exportedfile/sfs/settings3.properties`
    logger.info("after getserver")
  end

  def getsfsserverfromversion(version)
    sfsserverfromversion = ""
    if File.exist?("#{Rails.root}/exportedfile/sfs/version1.properties")
      File.open("#{Rails.root}/exportedfile/sfs/version1.properties", 'r:UTF-8') do |f|
        while line = f.gets
          if !line.index(version).nil?
            sfsserverfromversion = APP_CONFIG['sfs_server']['address1']
          end
        end
      end
    end
    if File.exist?("#{Rails.root}/exportedfile/sfs/version2.properties")
      File.open("#{Rails.root}/exportedfile/sfs/version2.properties", 'r:UTF-8') do |f|
        while line = f.gets
          if !line.index(version).nil?
            sfsserverfromversion = APP_CONFIG['sfs_server']['address2']
          end
        end
      end
    end
    if File.exist?("#{Rails.root}/exportedfile/sfs/version3.properties")
      File.open("#{Rails.root}/exportedfile/sfs/version3.properties", 'r:UTF-8') do |f|
        while line = f.gets
          if !line.index(version).nil?
            sfsserverfromversion = APP_CONFIG['sfs_server']['address3']
          end
        end
      end
    end
    sfsserverfromversion
  end

  def spreadsheet_by_url(url)
    uri = URI.parse(url)
    if ["spreadsheets.google.com", "docs.google.com"].include?(uri.host)
      case uri.path
        when /\/d\/([^\/]+)/
          return spreadsheet_by_key($1)
        when /\/ccc$/
          if (uri.query || "").split(/&/).find() { |s| s=~ /^key=(.*)$/ }
            return spreadsheet_by_key($1)
          end
      end
    end
  end

  def upfileto_sfs_server (filepath)
    password_sfs = APP_CONFIG['sfs_server']['password']
    `sshpass -p '#{password_sfs}' scp #{filepath} #{session[:sfs_server]}:/home/lumbarunner/apps/SmartFoxServer_2X/SFS2X/data/lumba/core`
    `sshpass -p '#{password_sfs}' scp #{filepath} #{APP_CONFIG['sfs_server']['address2']}:/home/lumbarunner/apps/SmartFoxServer_2X/SFS2X/data/lumba/core`
  end

  def upfileto_sfs_server_custom(sfsserverfromversion, filepath)
    password_sfs = APP_CONFIG['sfs_server']['password']
    logger.info("sfsserverfromversion: #{sfsserverfromversion}, filepath: #{filepath}")
    if !(sfsserverfromversion.eql?(""))
      `sshpass -p '#{password_sfs}' scp #{filepath} #{sfsserverfromversion}:/home/lumbarunner/apps/SmartFoxServer_2X/SFS2X/config/lumba`
      `sshpass -p '#{password_sfs}' scp #{filepath} #{APP_CONFIG['sfs_server']['address2']}:/home/lumbarunner/apps/SmartFoxServer_2X/SFS2X/config/lumba`
    else
      `sshpass -p '#{password_sfs}' scp #{filepath} #{APP_CONFIG['sfs_server']['address3']}:/home/lumbarunner/apps/SmartFoxServer_2X/SFS2X/config/lumba`
      `sshpass -p '#{password_sfs}' scp #{filepath} #{APP_CONFIG['sfs_server']['address2']}:/home/lumbarunner/apps/SmartFoxServer_2X/SFS2X/config/lumba`
    end
  end

  def upfileto_sfs_server_stage (filepath)
    `scp -i ~/.ec2/fayez-eu-region-keypair #{filepath} root@ec2-54-195-70-23.eu-west-1.compute.amazonaws.com:/root/apps/SmartFoxServer_2X/SFS2X/data/lumba/core`
  end

  def my_logger
    @my_logger ||= Logger.new("#{Rails.root}/log/updategamevar.log")
  end

  def my_logger_lumba
    @my_logger_lumba ||= Logger.new("#{Rails.root}/log/updatelumba.log")
  end

  def convert_second_to_hhmmss(second)
    hh = second/3600
    mm = (second - 3600*hh)/60
    ss = second - 3600*hh - 60*mm
    dd = hh/24
    hh = hh - dd*24
    hhmmss = "#{dd}:#{hh}:#{mm}:#{ss}"
    hhmmss
  end
  def getuniqgameversion
    @version_array = []
    @game_versions.each_hash do |row|
      @version_array.push(row)
    end
    @version_array = @version_array.uniq
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
