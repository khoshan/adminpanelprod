# encoding: utf-8
require 'mysql'
require 'json'

class BundleController < ApplicationController
  before_filter :login_required, :block_user_from_action, :block_support_from_action
  skip_before_filter :verify_authenticity_token, :only => [:index]
  @selectedmenu = "bundle"

  def index
    t = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    if params[:actionupdate]
      connectLumbaAppData
      str_query = "update ref_Bundle set bundlekey = '#{params[:bundlekey]}', bundlevalue = '#{params[:bundlevalue]}' where pkId = #{params[:pkID]}"
      @db.query(str_query)
      @datas = @db.query("select * from ref_Bundle where game_version = '#{@game_version}' order by bundlekey")
      disconnectLumbaAppData
      my_logger.info("#{session[:user]['username']} #{str_query}")
    elsif params[:editmultibundle]
      connectLumbaAppData
      pkId = params[:pkId].split(",")
      bundlekey = JSON.parse(params[:bundlekey])
      bundlevalue = JSON.parse(params[:bundlevalue])

      pkId.each_with_index { |item, index|
        str_query = "update ref_Bundle set bundlekey = '#{bundlekey[index]}', bundlevalue = '#{bundlevalue[index]}' where pkId = #{item}"
        @db.query(str_query)
        my_logger.info("#{session[:user]['username']} #{str_query}")
      }
      @datas = @db.query("select * from ref_Bundle where game_version = '#{@game_version}' order by bundlekey")
      disconnectLumbaAppData
    elsif (params[:deleteid])
      connectLumbaAppData
      @db.query("delete from ref_Bundle where pkId = #{params[:deleteid]}")
      @datas = @db.query("select * from ref_Bundle where game_version = '#{@game_version}' order by bundlekey")
      disconnectLumbaAppData
    elsif (params[:actionadd])
    elsif (params[:exportbundle])
      properties_config = YAML.load_file("#{Rails.root}/config/properties.yml")
      if File.exist?("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/Bundles.txt")
        `rm #{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/Bundles.txt`
      end
      connectLumbaAppData
      @datas = @db.query("select * from ref_Bundle where game_version = '#{@game_version}' order by bundlekey")
      disconnectLumbaAppData
      @datas.each_hash do |row|
        File.open("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/Bundles.txt", 'a:UTF-8') { |file| file.puts("#{row['bundlekey']} = #{row['bundlevalue']}") }
      end
      if checkpassword(params[:confirmpassword])
        copy_file_to_server("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/Bundles.txt", params[:game_version], params[:exportserver])
        connectLumbaAppData
        @datas = @db.query("select * from ref_Bundle where game_version = '#{@game_version}' order by bundlekey")
        disconnectLumbaAppData
        my_logger.info("#{session[:user]['username']} exported Bundles.txt")
      else
        @error_string = "Invalid password"
      end
    elsif (params[:commit].eql?("Upload"))
      files = params[:files]
      dir_save_file = "#{Rails.root}/exportedfile/currentversionserver/#{session[:game_version_production]}/#{@game_version}"
      files.each { |file| DataFile.save(file, dir_save_file) }
      connectLumbaAppData
      files.each { |file|
        if file.original_filename.eql?("Bundles.txt")
          puts "delete from ref_Bundle where game_version = '#{@game_version}'"
          @db.query("delete from ref_Bundle where game_version = '#{@game_version}'")
          File.open("#{dir_save_file}/Bundles.txt", "r:UTF-8").each_line do |line|
            abc = line.split("=")
            if abc.size < 2
              abc = abc + [""]
            end
            bundlevalue = abc[1].gsub("\\", "\\\\\\")
            bundlevalue = bundlevalue.gsub("\"", "\\\\\"")
            str_insert = "insert into ref_Bundle set bundlekey = \"#{abc[0]}\", bundlevalue = \"#{bundlevalue}\", game_version = '#{@game_version}'"
            @db.query(str_insert)
          end
        end
      }
      @datas = @db.query("select * from ref_Bundle where game_version = '#{@game_version}' order by bundlekey")
      disconnectLumbaAppData
    else
      connectLumbaAppData
      @datas = @db.query("select * from ref_Bundle where game_version = '#{@game_version}' order by bundlekey")
      disconnectLumbaAppData
    end
    connectLumbaAppData
    @game_versions = @db.query("select distinct NextGameVersion from ref_Setting order by NextGameVersion")
    getuniqgameversion
    disconnectLumbaAppData
    @datas
  end
end
