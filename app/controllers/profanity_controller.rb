class ProfanityController < ApplicationController
  before_filter :login_required, :block_user_from_action
  skip_before_filter :verify_authenticity_token, :only => [:index]

  def index
    properties_config = YAML.load_file("#{Rails.root}/config/properties.yml")
    if (params[:commit].eql?("UpdateFromGoogle"))
      connectLumbaAppData
      handleUploadFromGoogleSpreadsheet1
      @profanitiestext = @db.query("select * from ref_profanity where game_version = '#{@game_version}'")
      disconnectLumbaAppData
    elsif (params[:commit].eql?("ExportToGoogle"))
      connectLumbaAppData
      handleExportToGoogleSpreadsheet
      @profanitiestext = @db.query("select * from ref_profanity where game_version = '#{@game_version}'")
      disconnectLumbaAppData
    elsif (params[:exportenprof])
      if File.exist?("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/EnglishFilterWords.txt")
        `rm #{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/EnglishFilterWords.txt`
      end
      connectLumbaAppData
      datas_profanity = @db.query("select * from ref_profanity where game_version = '#{@game_version}'")
      disconnectLumbaAppData
      datas_profanity.each_hash do |row|
        file = File.open("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/EnglishFilterWords.txt", 'a:UTF-8') { |file| file.puts("#{row['EN'].force_encoding("UTF-8")}") }
      end
      if checkpassword(params[:confirmpassword])
        copy_file_to_server("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/EnglishFilterWords.txt", params[:game_version], params[:exportserver])
      else
        @error_string = "Invalid password"
      end
      connectLumbaAppData
      @profanitiestext = @db.query("select * from ref_profanity where game_version = '#{@game_version}'")
      disconnectLumbaAppData
    elsif (params[:exportarprof])
      if File.exist?("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/ArabFilterWords.txt")
        `rm #{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/ArabFilterWords.txt`
      end
      connectLumbaAppData
      datas_profanity = @db.query("select * from ref_profanity where game_version = '#{@game_version}'")
      disconnectLumbaAppData
      datas_profanity.each_hash do |row|
        file = File.open("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/ArabFilterWords.txt", 'a:UTF-8') { |file| file.puts("#{row['AR'].force_encoding("UTF-8")}") }
      end
      if checkpassword(params[:confirmpassword])
        copy_file_to_server("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/ArabFilterWords.txt", params[:game_version], params[:exportserver])
      else
        @error_string = "Invalid password"
      end
      connectLumbaAppData
      @profanitiestext = @db.query("select * from ref_profanity where game_version = '#{@game_version}'")
      disconnectLumbaAppData

    end
    connectLumbaAppData
    @game_versions = @db.query("select distinct NextGameVersion from ref_Setting order by NextGameVersion")
    getuniqgameversion
    @profanitiestext = @db.query("select * from ref_profanity where game_version = '#{@game_version}'")
    disconnectLumbaAppData
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
      ws = session.spreadsheet_by_key(url[1]).worksheets[1]
      @db.query("delete from ref_profanity where game_version = '#{@game_version}'")
      for row in 2..ws.num_rows
        engl = ws[row, 1].gsub("\\", "\\\\\\")
        engl = engl.gsub("\"", "\\\\\"")
        arab = ws[row, 2].gsub("\\", "\\\\\\")
        arab = arab.gsub("\"", "\\\\\"")
        @db.query("insert into ref_profanity set EN = \"#{engl.strip}\", AR = \"#{arab.strip}\", lastMod = '#{t.to_s}', game_version = '#{@game_version}'")
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
      spreadsheet = session.create_spreadsheet("Lumba Profanity version #{params[:game_version]}")
      retrieveXml = REXML::Document.new(response.body)
      key_tmp = spreadsheet.worksheets_feed_url.split("worksheets/")[1]
      key = key_tmp.split("/private")[0]
      url = "https://spreadsheets.google.com/ccc?key=#{key}"
      ws = session.spreadsheet_by_key(key).worksheets[0]
      ws[1, 1] = "English"
      ws[1, 2] = "Arabic"
      index = 2
      datas = @db.query("select * from ref_profanity where game_version = '#{@game_version}'")
      datas.each_hash do |row|
        ws[index, 1] = row['EN'].force_encoding("UTF-8")
        ws[index, 2] = row['AR'].force_encoding("UTF-8")
        index = index + 1
      end

      ws.save()
      @error_string = "Export url: #{url}"
    rescue Exception => e
      puts e.to_s
      @error_string = e.to_s
    end
  end
end
