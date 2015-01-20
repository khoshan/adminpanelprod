class SwitchserverController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:index, :apply_to_other_server, :switchversion]
  @selectedServer = ""
  def index
    # write properties.txt file
    if params[:server_change].eql?("currentversionserver")
      File.open("#{Rails.root}/config/properties.yml",'w:UTF-8') { |file| file.puts("mysql1: #{encrypt('LumbaAppData')}\nserver1: #{encrypt("currentversionserver")}\nserverhost1: #{encrypt('ec2-54-235-174-119.compute-1.amazonaws.com')}\nmysql2: #{encrypt('LumbaAppDataNext')}\nserver2: #{encrypt("nextversionserver")}\nserverhost2: #{encrypt('ec2-54-235-174-119.compute-1.amazonaws.com')}")}
    else
      File.open("#{Rails.root}/config/properties.yml",'w:UTF-8') { |file| file.puts("mysql1: #{encrypt('LumbaAppDataNext')}\nserver1: #{encrypt("nextversionserver")}\nserverhost1: #{encrypt('ec2-54-235-174-119.compute-1.amazonaws.com')}\nmysql2: #{encrypt('LumbaAppData')}\nserver2: #{encrypt("currentversionserver")}\nserverhost2: #{encrypt('ec2-54-235-174-119.compute-1.amazonaws.com')}")}
    end
  
    redirect_to params[:currenturl]
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

  def switchversion
    session[:game_version] = params[:game_version]
    session[:game_version_production] = params[:game_version]
    logger.info("session[:game_version_production]: #{session[:game_version_production]}")
    getserver # get server sfs version files
    # read file and store game server to session
    session[:sfs_server] = ""
    session[:sfs_version] = ""
    if File.exist?("#{Rails.root}/exportedfile/sfs/version1.properties")
      File.open("#{Rails.root}/exportedfile/sfs/version1.properties", 'r:UTF-8') do |f|
        while line = f.gets
          if !line.index(session[:game_version_production]).nil?
            session[:sfs_server] = APP_CONFIG['sfs_server']['address1']
            prop = load_properties("#{Rails.root}/exportedfile/sfs/settings1.properties")
            logger.info(prop['sfs_version'])
            session[:sfs_version] = prop['sfs_version']
          end
        end
      end
    end
    if File.exist?("#{Rails.root}/exportedfile/sfs/version2.properties")
      File.open("#{Rails.root}/exportedfile/sfs/version2.properties", 'r:UTF-8') do |f|
        while line = f.gets
          if !line.index(session[:game_version_production]).nil?
            session[:sfs_server] = APP_CONFIG['sfs_server']['address2']
            prop = load_properties("#{Rails.root}/exportedfile/sfs/settings2.properties")
            logger.info(prop['sfs_version'])
            session[:sfs_version] = prop['sfs_version']
          end
        end
      end
    end
    # check server 3
    if File.exist?("#{Rails.root}/exportedfile/sfs/version3.properties")
      File.open("#{Rails.root}/exportedfile/sfs/version3.properties", 'r:UTF-8') do |f|
        while line = f.gets
          if !line.index(session[:game_version_production]).nil?
            session[:sfs_server] = APP_CONFIG['sfs_server']['address3']
            prop = load_properties("#{Rails.root}/exportedfile/sfs/settings3.properties")
            logger.info(prop['sfs_version'])
            session[:sfs_version] = prop['sfs_version']
          end
        end
      end
    end

    if !(File.exists?(""))
      `mkdir #{Rails.root}/exportedfile/currentversionserver/#{session[:game_version_production]}`
    end
    if (!params[:game_version].eql?(""))
    File.open("#{Rails.root}/config/game_version.yml",'w:UTF-8') { |file| file.puts("game_version: #{encrypt(params[:game_version])}")}
    end
    redirect_to params[:currenturl]
  end
  def apply_to_other_server # copy db from mysql1 to mysql2, text file from nserverhost1 to nserverhost2
    connectLumbaAppData
      @datas = @db.query("select * from ref_Setting order by pkID desc limit 1")
      disconnectLumbaAppData
    @datas.each_hash do |row|
      `cp #{Rails.root}/exportedfile/currentversionserver/*.txt #{Rails.root}/exportedfile/nextversionserver/`
      # insert next db
      #campaign
      # combat unit
      # unit level
      # defensive building
      # defensive building level
      # resource building variable
      # army building
      # other building
      # town hall level
      # decoration
      # spell
      # spell level
      # obstacle
      # trophy
      # achivement
      # setting
      # language
      # bundle
      `sshpass -p 'buncha11' scp #{Rails.root}/exportedfile/nextversionserver/*.txt lumbarunner@ec2-54-235-174-119.compute-1.amazonaws.com:/home/lumbarunner/apps/lumba_loadbalancer/resources/#{row['softMovedVersions2']}`
      redirect_to params[:currenturl]
    end
  end
end
