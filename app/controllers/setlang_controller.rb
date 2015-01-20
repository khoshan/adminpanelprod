# encoding: utf-8
require 'mysql'
require 'json'
require 'rubygems'
require 'simple_xlsx' #gem install simple_xlsx_writer
require 'google_drive'
require 'rexml/document'

class SetlangController < ApplicationController
  before_filter :login_required, :block_user_from_action
  skip_before_filter :verify_authenticity_token, :only => [:index, :user_details]
  @selectedmenu = "setLang"

  def index
    t = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    #t = Time.zone.now
    properties_config = YAML.load_file("#{Rails.root}/config/properties.yml")
    if (params[:exporten])
      if File.exist?("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/English.txt")
        `rm #{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/English.txt`
      end
      if File.exist?("#{Rails.root}/exportedfile/sfs/english.txt")
        `rm #{Rails.root}/exportedfile/sfs/english.txt`
      end
      if File.exist?("#{Rails.root}/exportedfile/sfs/en_resetPasswordCodeEmail.txt")
        `rm #{Rails.root}/exportedfile/sfs/en_resetPasswordCodeEmail.txt`
      end
      if File.exist?("#{Rails.root}/exportedfile/sfs/en_resetPasswordCodeEmailSetting.txt")
        `rm #{Rails.root}/exportedfile/sfs/en_resetPasswordCodeEmailSetting.txt`
      end
      if File.exist?("#{Rails.root}/exportedfile/sfs/reward_english.txt")
        `rm #{Rails.root}/exportedfile/sfs/reward_english.txt`
      end

      connectLumbaAppData
      @datas = @db.query("select * from lang_Language where game_version = '#{@game_version}'")
      disconnectLumbaAppData
      @datas.each_hash do |row|
        file = File.open("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/English.txt", 'a:UTF-8') { |file| file.puts("#{row['codeReference']} = #{row['EN'].force_encoding("UTF-8")}") }
        if row['codeReference'].eql?("Notification_ATTACK")
          file = File.open("#{Rails.root}/exportedfile/sfs/english.txt", 'a:UTF-8') { |file| file.puts("#{row['codeReference']}=#{row['EN'].force_encoding("UTF-8")} ") }
        end
        if row['codeReference'].eql?("ResetPassword_Code")
          file = File.open("#{Rails.root}/exportedfile/sfs/en_resetPasswordCodeEmail.txt", 'a:UTF-8') { |file| file.puts("#{row['EN'].force_encoding("UTF-8")} {code}") }
        end
        if row['codeReference'].eql?("ResetPassword_Code_Title")
          file = File.open("#{Rails.root}/exportedfile/sfs/en_resetPasswordCodeEmailSetting.txt", 'a:UTF-8') { |file| file.puts("title=#{row['EN'].force_encoding("UTF-8")}") }
        end
        if row['codeReference'].eql?("ResetPassword_Code_Email")
          file = File.open("#{Rails.root}/exportedfile/sfs/en_resetPasswordCodeEmailSetting.txt", 'a:UTF-8') { |file| file.puts("admin_email=#{row['EN'].force_encoding("UTF-8")}") }
        end
        if row['codeReference'].eql?("Notification_Reward")
          file = File.open("#{Rails.root}/exportedfile/sfs/reward_english.txt", 'a:UTF-8') { |file| file.puts("#{row['codeReference']}=#{row['EN'].force_encoding("UTF-8")}") }
        end

      end
      if checkpassword(params[:confirmpassword])
        copy_file_to_server("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/English.txt", params[:game_version], params[:exportserver])
        upfileto_sfs_server("#{Rails.root}/exportedfile/sfs/english.txt")
        upfileto_sfs_server("#{Rails.root}/exportedfile/sfs/en_resetPasswordCodeEmail.txt")
        upfileto_sfs_server("#{Rails.root}/exportedfile/sfs/en_resetPasswordCodeEmailSetting.txt")
        upfileto_sfs_server("#{Rails.root}/exportedfile/sfs/reward_english.txt")
        my_logger.info("#{session[:user]['username']} exported English.txt")
      else
        @error_string = "Invalid password"
      end
      connectLumbaAppData
      @lang_languages = @db.query("select * from lang_Language where game_version = '#{@game_version}'")
      disconnectLumbaAppData
    elsif (params[:exportar])
      if File.exist?("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/Arab.txt")
        `rm #{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/Arab.txt`
      end
      if File.exist?("#{Rails.root}/exportedfile/sfs/arabic.txt")
        `rm #{Rails.root}/exportedfile/sfs/arabic.txt`
      end
      if File.exist?("#{Rails.root}/exportedfile/sfs/ar_resetPasswordCodeEmail.txt")
        `rm #{Rails.root}/exportedfile/sfs/ar_resetPasswordCodeEmail.txt`
      end
      if File.exist?("#{Rails.root}/exportedfile/sfs/ar_resetPasswordCodeEmailSetting.txt")
        `rm #{Rails.root}/exportedfile/sfs/ar_resetPasswordCodeEmailSetting.txt`
      end
      if File.exist?("#{Rails.root}/exportedfile/sfs/reward_arabic.txt")
        `rm #{Rails.root}/exportedfile/sfs/reward_arabic.txt`
      end
      connectLumbaAppData
      @datas = @db.query("select * from lang_Language where game_version = '#{@game_version}'")
      disconnectLumbaAppData
      @datas.each_hash do |row|
        file = File.open("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/Arab.txt", 'a:UTF-8') { |file| file.puts("#{row['codeReference']} = #{row['AR'].force_encoding("UTF-8")}") }
        if row['codeReference'].eql?("Notification_ATTACK")
          file = File.open("#{Rails.root}/exportedfile/sfs/arabic.txt", 'a:UTF-8') { |file| file.puts("#{row['codeReference']}=#{row['AR'].force_encoding("UTF-8")} ") }
        end
        if row['codeReference'].eql?("ResetPassword_Code")
          file = File.open("#{Rails.root}/exportedfile/sfs/ar_resetPasswordCodeEmail.txt", 'a:UTF-8') { |file| file.puts("#{row['AR'].force_encoding("UTF-8")} {code}") }
        end
        if row['codeReference'].eql?("ResetPassword_Code_Title")
          file = File.open("#{Rails.root}/exportedfile/sfs/ar_resetPasswordCodeEmailSetting.txt", 'a:UTF-8') { |file| file.puts("title=#{row['AR'].force_encoding("UTF-8")}") }
        end
        if row['codeReference'].eql?("ResetPassword_Code_Email")
          file = File.open("#{Rails.root}/exportedfile/sfs/ar_resetPasswordCodeEmailSetting.txt", 'a:UTF-8') { |file| file.puts("admin_email=#{row['AR'].force_encoding("UTF-8")}") }
        end
        if row['codeReference'].eql?("Notification_Reward")
          file = File.open("#{Rails.root}/exportedfile/sfs/reward_arabic.txt", 'a:UTF-8') { |file| file.puts("#{row['codeReference']}=#{row['AR'].force_encoding("UTF-8")}") }
        end
      end
      if checkpassword(params[:confirmpassword])
        copy_file_to_server("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/Arab.txt", params[:game_version], params[:exportserver])
        upfileto_sfs_server("#{Rails.root}/exportedfile/sfs/arabic.txt")
        upfileto_sfs_server("#{Rails.root}/exportedfile/sfs/ar_resetPasswordCodeEmail.txt")
        upfileto_sfs_server("#{Rails.root}/exportedfile/sfs/ar_resetPasswordCodeEmailSetting.txt")
        upfileto_sfs_server("#{Rails.root}/exportedfile/sfs/reward_arabic.txt")
        my_logger.info("#{session[:user]['username']} exported Arab.txt")
      else
        @error_string = "Invalid password"
      end
      connectLumbaAppData
      @lang_languages = @db.query("select * from lang_Language where game_version = '#{@game_version}'")
      disconnectLumbaAppData
    elsif (params[:commit].eql?("DownloadLanguage"))
      password_ballancer = APP_CONFIG['balancer_server']['password']
      `rm -rf #{Rails.root}/languages_#{params[:game_version]}`
      `mkdir #{Rails.root}/languages_#{params[:game_version]}`
      `sshpass -p '#{password_ballancer}' scp #{APP_CONFIG['balancer_server']['address1']}:/home/lumbarunner/apps/lumba_loadbalancer/resources/#{params[:game_version]}/English.txt #{Rails.root}/languages_#{params[:game_version]}`
      `sshpass -p '#{password_ballancer}' scp #{APP_CONFIG['balancer_server']['address1']}:/home/lumbarunner/apps/lumba_loadbalancer/resources/#{params[:game_version]}/Arab.txt #{Rails.root}/languages_#{params[:game_version]}`
      engl_keys = []
      engl_text = []
      arab_keys = []
      arab_text = []
      File.open("#{Rails.root}/languages_#{params[:game_version]}/English.txt", 'r:UTF-8') do |f|
        while line = f.gets
          engls = line.split("=")
          if engls.size < 2
            engls = engls + [" "]
          end
          engl_keys.push(engls[0])
          engl_text.push(engls[1])
        end
      end
      File.open("#{Rails.root}/languages_#{params[:game_version]}/Arab.txt", 'r:UTF-8') do |f|
        while line = f.gets
          arabs = line.split("=")
          if arabs.size < 2
            arabs = arabs + [" "]
          end
          arab_keys.push(arabs[0])
          arab_text.push(arabs[1])
        end
      end
      langs_arr = []
      engl_keys.each_with_index { |item, index|
        langs = Hash.new
        langs["key"] = item
        langs["english"] = engl_text[index]
        arab_keys.each_with_index { |item1, index1|
          if (item1.eql?(item))
            langs["arabic"] = arab_text[index1]
            break
          end
        }
        langs_arr.push(langs)
      }
      x = arab_keys - engl_keys
      if x.length > 0
        langs = Hash.new
        x.each_with_index { |item, index|
          arab_keys.each_with_index { |item1, index1|
            if (item1.eql?(item))
              langs["key"] = item
              langs["english"] = ""
              langs["arabic"] = arab_text[index1]
            end
          }
          langs_arr.push(langs)
        }
      end
      SimpleXlsx::Serializer.new("#{Rails.root}/languages_#{params[:game_version]}/Language.xlsx") do |doc|
        doc.add_sheet("Language") do |sheet|
          sheet.add_row(%w{Key English Arabic})
          langs_arr.each do |row|
            sheet.add_row([row['key'],
                           row['english'],
                           row['arabic']])
          end
        end
      end
      CSV.open("#{Rails.root}/languages_#{params[:game_version]}/Language.xls", "w:UTF-8", {:col_sep => "\t"}) { |csv|
        csv << ["Key", "English", "Arabic"]
        langs_arr.each do |row|
          csv << [row['key'], row['english'], row['arabic']]
        end
      }
      bundle_filename = "#{Rails.root}/languages_#{params[:game_version]}.zip"
      `rm #{bundle_filename}`
      dir = "#{Rails.root}/languages_#{params[:game_version]}"
      Zip::ZipFile.open(bundle_filename, Zip::ZipFile::CREATE) { |zipfile|
        Dir.foreach(dir) do |item|
          item_path = "#{dir}/#{item}"
          if ((!item.index(".txt").nil?) && (zipfile.find_entry(item).nil?))
            zipfile.add("#{item}", item_path) if File.file? item_path
          end
          if ((!item.index(".xls").nil?) && (zipfile.find_entry(item).nil?))
            zipfile.add("#{item}", item_path) if File.file? item_path
          end
          if ((!item.index(".xlsx").nil?) && (zipfile.find_entry(item).nil?))
            zipfile.add("#{item}", item_path) if File.file? item_path
          end
        end
      }
      connectLumbaAppData
      @lang_languages = @db.query("select * from lang_Language where game_version = '#{@game_version}'")
      disconnectLumbaAppData
      send_file("#{Rails.root}/languages_#{params[:game_version]}.zip", :disposition => :attachment)
    elsif (params[:commit].eql?("UpdateFromGoogle"))
      connectLumbaAppData
      handleUploadFromGoogleSpreadsheet1
      @lang_languages = @db.query("select * from lang_Language where game_version = '#{@game_version}'")
      disconnectLumbaAppData
    elsif (params[:commit].eql?("ExportToGoogle"))
      connectLumbaAppData
      handleExportToGoogleSpreadsheet
      @lang_languages = @db.query("select * from lang_Language where game_version = '#{@game_version}'")
      disconnectLumbaAppData
    elsif (params[:commit].eql?("Upload"))
      files = params[:files]
      dir_save_file = "#{Rails.root}/exportedfile/currentversionserver/#{session[:game_version_production]}/#{@game_version}"
      files.each { |file| DataFile.save(file, dir_save_file) }
      connectLumbaAppData
      update_arab = true
      my_logger.info("hix hix")
      files.each { |file|
        if file.original_filename.eql?("English.txt")
          update_arab = false
          @db.query("delete from lang_Language where game_version = '#{@game_version}'")
          # reinsert enlish
          file = File.open("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/English.txt", "r:UTF-8").each_line do |line|
            abc = line.split("=")
            if abc.size < 2
              abc = abc + [" "]
            end
            engl = abc[1].gsub("\\", "\\\\\\")
            engl = engl.gsub("\"", "\\\\\"")
            str_insert_engl = "insert into lang_Language set codeReference = \"#{abc[0].strip}\", EN = \"#{engl.strip}\", AR = '', game_version = '#{@game_version}'"
            puts str_insert_engl
            my_logger.info(str_insert_engl)
            @db.query(str_insert_engl)
          end
          # update arab
          File.open("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/Arab.txt", 'r:UTF-8') do |f|
            while line = f.gets
              arabs = line.split("=")
              if arabs.size < 2
                arabs = arabs + [" "]
              end
              a = arabs[1].eql?("\\n")
              arab = arabs[1].gsub("\\", "\\\\\\")
              arab = arab.gsub("\"", "\\\\\"")
              str_update_arab = "update lang_Language set AR = \"#{arab.strip}\" where codeReference = \"#{arabs[0].strip}\" and game_version = '#{@game_version}'"
              @db.query(str_update_arab)
            end
          end
        end
      }
      if update_arab
        files.each { |file|
          if file.original_filename.eql?("Arab.txt")
            # update arab
            File.open("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/Arab.txt", 'r:UTF-8') do |f1|
              while line = f1.gets
                arabs = line.split("=")
                if arabs.size < 2
                  arabs = arabs + [" "]
                end
                arab = arabs[1].gsub("\\", "\\\\\\")
                arab = arab.gsub("\"", "\\\\\"")
                str_update_arab = "update lang_Language set AR = \"#{arab.strip}\" where codeReference = \"#{arabs[0].strip}\" and game_version = '#{@game_version}'"
                @db.query(str_update_arab)
              end
            end
          end
        }
      end
      @lang_languages = @db.query("select * from lang_Language where game_version = '#{@game_version}'")
      disconnectLumbaAppData
    else
      connectLumbaAppData
      if params[:commit].eql?("Search")
        @codeRef = params[:codeRef]
        @lang_languages = @db.query("select * from lang_Language where codeReference like '%#{@codeRef}%' and game_version = '#{@game_version}'")
      else
        @lang_languages = @db.query("select * from lang_Language where game_version = '#{@game_version}'")
      end
      disconnectLumbaAppData
    end
    connectLumbaAppData
    @game_versions = @db.query("select distinct NextGameVersion from ref_Setting order by NextGameVersion")
    getuniqgameversion
    disconnectLumbaAppData
    @lang_languages
    @lang_languages_sfs = []
  end

  def handleUploadFromGoogleSpreadsheet
    begin
      t = Time.now.strftime("%Y-%m-%d %H:%M:%S")
      session = GoogleDrive.login(params[:googleemail], params[:googlepassword])
      url_tmp = params[:googleurlRef].split("#gid")
      url = url_tmp[0].split("key=")
      if url.size < 2
        url.push("")
      end
      ws = session.spreadsheet_by_key(url[1]).worksheets[15]
      @db.query("delete from lang_Language where game_version = '#{@game_version}'")
      for row in 2..ws.num_rows
        code_ref = ws[row, 1]
        engl = ws[row, 2].gsub("\\", "\\\\\\")
        engl = engl.gsub("\"", "\\\\\"")
        arab = ws[row, 3].gsub("\\", "\\\\\\")
        arab = arab.gsub("\"", "\\\\\"")
        @db.query("insert into lang_Language set codeReference = \"#{code_ref.strip}\", EN = \"#{engl.strip}\", AR = \"#{arab.strip}\", lastMod = '#{t.to_s}', game_version = '#{@game_version}'")
      end
      @error_string = "Upload successful"
    rescue Exception => e
      puts e.to_s
      @error_string = e.to_s
    end
  end

  def handleUploadFromGoogleSpreadsheet1
    begin
      t = Time.now.strftime("%Y-%m-%d %H:%M:%S")
      session = GoogleDrive.login(params[:googleemail], params[:googlepassword])
      url_tmp = params[:googleurlRef].split("#gid")
      url = url_tmp[0].split("key=")
      if url.size < 2
        url.push("")
      end
      ws = session.spreadsheet_by_key(url[1]).worksheets[0]
      @db.query("delete from lang_Language where game_version = '#{@game_version}'")
      for row in 2..ws.num_rows
        code_ref = ws[row, 1]
        engl = ws[row, 2].gsub("\\", "\\\\\\")
        engl = engl.gsub("\"", "\\\\\"")
        arab = ws[row, 5].gsub("\\", "\\\\\\")
        arab = arab.gsub("\"", "\\\\\"")
        @db.query("insert into lang_Language set codeReference = \"#{code_ref.strip}\", EN = \"#{engl.strip}\", AR = \"#{arab.strip}\", lastMod = '#{t.to_s}', game_version = '#{@game_version}'")
      end
      @error_string = "Upload successful"
    rescue Exception => e
      puts e.to_s
      @error_string = e.to_s
    end
  end

  def handleExportToGoogleSpreadsheet
    begin
      t = Time.now.strftime("%Y-%m-%d %H:%M:%S")
      session = GoogleDrive.login(params[:googleemail], params[:googlepassword])
      spreadsheet = session.create_spreadsheet("Lumba Language version #{params[:game_version]}")
      retrieveXml = REXML::Document.new(response.body)
      key_tmp = spreadsheet.worksheets_feed_url.split("worksheets/")[1]
      key = key_tmp.split("/private")[0]
      url = "https://spreadsheets.google.com/ccc?key=#{key}"
      ws = session.spreadsheet_by_key(key).worksheets[0]
      ws[1, 1] = "Key"
      ws[1, 2] = "English"
      ws[1, 3] = "Arabic"
      index = 2
      datas = @db.query("select * from lang_Language where game_version = '#{@game_version}'")
      datas.each_hash do |row|
        ws[index, 1] = row['codeReference']
        ws[index, 2] = row['EN'].force_encoding("UTF-8")
        ws[index, 3] = row['AR'].force_encoding("UTF-8")
        index = index + 1
      end

      ws.save()
      @error_string = "Export url: #{url}"
    rescue Exception => e
      puts e.to_s
      @error_string = e.to_s
    end
  end

  def uploadFile
    dir_save_file = "#{Rails.root}/exportedfile/currentversionserver/#{session[:game_version_production]}/#{@game_version}"
    post = DataFile.save(params[:upload], dir_save_file)
    render :text => "File has been uploaded successfully"
  end
end
