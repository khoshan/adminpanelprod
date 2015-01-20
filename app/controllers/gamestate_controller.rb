# encoding: utf-8
require 'rubygems'
require 'mysql'
require 'json'
require 'cgi'
require 'money'
require 'money/bank/google_currency'
require 'time'
require 'uri'
require 'digest/md5'
require 'securerandom'
require 'jira'
require 'rubygems'

class GamestateController < ApplicationController
  helper_method :convertShieldTime
  before_filter :login_required
  skip_before_filter :verify_authenticity_token, :only => [:index, :user_details]
  @selectedmenu = "gamestate"
  @user_id = ""

  def index
    # add title
    #get_deploy

  end

  def user_details
    begin
      @reporterEmail = cookies[:login_username]
      current_user_name = cookies[:login_username]
      connectLumbaAppData2
      @admin_users = @dbsfs2.query("SELECT * FROM users WHERE username = '#{current_user_name}'")
      disconnectLumbaAppData2
      user_timezone = ''
      @admin_users.each do |row|
        @user_timezone = row["timezone"]
      end
      @timezone = (@user_timezone.delete 'GMT').to_i
      if @timezone >= 0
        @timezoneSQL = '+'+@timezone.to_s()
      else
        @timezoneSQL = @timezone
      end

      @gamestate_history_url = ""
      @error_string = "Game state is basically correct"
      modifydata = true
      @list_users = nil
      @sfs_version = params[:sfs_version]
      sfsversions = YAML.load_file("#{Rails.root}/config/sfsversions.yml")
      sfsvers = sfsversions['sfs_version'].split(",")
      if (params[:sfs_version].nil?) || (params[:sfs_version].eql?(""))
        sfsvers.each { |sfsver|
          @sfs_version = sfsver
        }
      end

      if params[:commit].eql?("CopyUserData")
        @sfs_version = 31
        connectLumba
        # update userMeta
        str_query_usermeta = "update userMeta_v#{@sfs_version} as m1 inner join (select level, trophies, attacksWon, defensesWon, achievements, battleLog, inboxMessages, recentDefenses, beingAttackedAt, shieldActiveTime, totalBattles, language, troopsDonated, troopsReceived from userMeta_v#{@sfs_version} where userID = '#{params[:src_userId]}') as m2 set m1.battleLog = m2.battleLog, m1.level = m2.level, m1.trophies = m2.trophies, m1.attacksWon = m2.attacksWon, m1.defensesWon = m2.defensesWon, m1.achievements = m2.achievements, m1.inboxMessages = m2.inboxMessages, m1.recentDefenses = m2.recentDefenses, m1.beingAttackedAt = m2.beingAttackedAt, m1.shieldActiveTime = m2.shieldActiveTime, m1.totalBattles = m2.totalBattles, m1.language = m2.language, m1.troopsDonated =  m2.troopsDonated, m1.troopsReceived = m2.troopsReceived where m1.userId = '#{params[:dest_userId]}'"
        # update userGameState
        usergamestate = @dblumba.query("select gameState from userGameState_v#{@sfs_version} where userId = '#{params[:src_userId]}' LIMIT 1").fetch_hash['gameState']
        game_state = JSON.parse(usergamestate)
        game_state['UserId'] = "#{params[:dest_userId]}"
        str_query_usergamestate = "update userGameState_v#{@sfs_version} set gameState = '#{JSON.generate(game_state)}' where userId = '#{params[:dest_userId]}'"
        isActive = @dblumba.query("select activeId from userMeta_v#{@sfs_version} where userId = '#{params[:dest_userId]}'").fetch_hash['activeId']
        logger.info('leu leu 1')
        if isActive.to_i != -1
          str_query_user = "update user_v#{@sfs_version} set isOutOfSync = 1  where userId = '#{params[:dest_userId]}'"
          @dblumba.query(str_query_user)
        end
        logger.info('leu leu 2')
        @dblumba.query(str_query_usergamestate)
        @dblumba.query(str_query_usermeta)
        connectLumbaAppData
        str_insert_copyuserlumba = "insert into copyuserlumba set userId = '#{params[:dest_userId]}', gamestate = '#{JSON.generate(game_state)}', sourceversion = '#{params[:src_userId]}', destinationversion = '#{params[:dest_userId]}'"
        @db.query(str_insert_copyuserlumba)
        disconnectLumbaAppData

        @user_detail = @dblumba.query("select u.userId, u.userNote, u.isFake, u.email, u.name, u.locale, u.facebookId, CONVERT_TZ(u.createdAt,'+00:00','#{@timezoneSQL}:00') createdAtPDT, u.isDeleted, u.isLeaderBoardBlocked, um.shieldActiveTime, um.level, um.trophies,um.attacksWon, um.defensesWon, um.achievements, um.activeId, um.deviceInfo, um.deviceId, um.deviceInfo, um.platform, ugs.gameState, ugs.version, cl.isLocked, cl.clanId from user_v#{@sfs_version} u join userMeta_v#{@sfs_version} um on u.userId = um.userId join userGameState_v#{@sfs_version} ugs on u.userId = ugs.userId join clanLookup_v#{@sfs_version} cl on u.userId = cl.userId where u.userId = '#{params[:dest_userId]}'")
        @copy_user_result = "Copy successfuly data from userId: #{params[:src_userId]} to userId: #{params[:dest_userId]}"
        disconnectLumba
      end

      if params[:commit].eql?("CopyUserDataFromProdToDev")
        connectLumba
        sfs_version_prod = 31
        sfs_version_dev = 54
        dbprod = Mysql.new('lumba.ckyzvr2punhb.eu-west-1.rds.amazonaws.com', 'sgsvn', 'buncha11', 'lumba')
        dbdev = Mysql.new('lumbadev.ckyzvr2punhb.eu-west-1.rds.amazonaws.com', 'sgsvn', 'buncha11', 'lumba')
        dbprodiap = Mysql.new('lumba.ckyzvr2punhb.eu-west-1.rds.amazonaws.com', 'sgsvn', 'buncha11', 'lumba_iap')
        # dbprodiaprestore = Mysql.new('lumba-restore-for-temporary-use.ckyzvr2punhb.eu-west-1.rds.amazonaws.com', 'sgsvn', 'buncha11', 'lumba_iap')
        dbprod.query "SET NAMES utf8"
        if (params[:old_GameState_Date].eql?(""))
          str_query_get_gs_prod = "select gameState from userGameState_v#{sfs_version_prod} where userId = '#{params[:userId_prod_source]}' LIMIT 1"
          str_query_get_ac_prod = "select achievements from userMeta_v#{sfs_version_prod} where userId = '#{params[:userId_prod_source]}' LIMIT 1"
          str_query_get_shield_prod = "select shieldActiveTime from userMeta_v#{sfs_version_prod} where userId = '#{params[:userId_prod_source]}' LIMIT 1"
          gamestateprod = dbprod.query(str_query_get_gs_prod).fetch_hash
          achievement_prod = dbprod.query(str_query_get_ac_prod).fetch_hash
          shield_prod = dbprod.query(str_query_get_shield_prod).fetch_hash
        else
          timeold = params[:old_GameState_Date]
          str_query_get_gs_prod = "select gameState from oldGameState_v31 where userId = '#{params[:userId_prod_source]}' and createdAt = '#{timeold}' LIMIT 1"
          str_query_get_ac_prod = "select achievements from oldGameState_v31 where userId = '#{params[:userId_prod_source]}' and createdAt = '#{timeold}' LIMIT 1"
          str_query_get_shield_prod = "select shieldActiveTime from oldGameState_v31 where userId = '#{params[:userId_prod_source]}' and createdAt = '#{timeold}' LIMIT 1"
          gamestateprod = dbprodiap.query(str_query_get_gs_prod).fetch_hash
          achievement_prod = dbprodiap.query(str_query_get_ac_prod).fetch_hash
          shield_prod = dbprodiap.query(str_query_get_shield_prod).fetch_hash
          # if gamestateprod.nil? || achievement_prod.nil?
          #   str_query_get_gs_prod = "select gameState from oldGameState where userId = '#{params[:userId_prod_source]}' and createdAt = '#{timeold}' LIMIT 1"
          #   str_query_get_ac_prod = "select achievements from oldGameState where userId = '#{params[:userId_prod_source]}' and createdAt = '#{timeold}' LIMIT 1"
          #   str_query_get_shield_prod = "select shieldActiveTime from oldGameState where userId = '#{params[:userId_prod_source]}' and createdAt = '#{timeold}' LIMIT 1"
          #   gamestateprod = dbprodiaprestore.query(str_query_get_gs_prod).fetch_hash
          #   achievement_prod = dbprodiaprestore.query(str_query_get_ac_prod).fetch_hash
          #   shield_prod = dbprodiaprestore.query(str_query_get_shield_prod).fetch_hash
          # end
        end
        game_state_dev = JSON.parse(gamestateprod['gameState'])
        user_level = game_state_dev['HUD']['hInfo'][0]
        user_trophies = game_state_dev['HUD']['trophies']
        user_shield = shield_prod['shieldActiveTime']
        logger.info("level #{user_level}")
        game_state_dev['UserId'] = "#{params[:userId_dev_destination]}"
        str_query_update_dev = "update userGameState_v#{sfs_version_dev} set gameState = '#{JSON.generate(game_state_dev)}' where userId = '#{params[:userId_dev_destination]}'"
        # copy achievement
        logger.info("update userMeta_v#{sfs_version_dev} set level = '#{user_level}' where userId = '#{params[:userId_dev_destination]}'")
        str_query_copy_achievement = "update userMeta_v#{sfs_version_dev} set achievements = '#{achievement_prod['achievements']}' where userId = '#{params[:userId_dev_destination]}'"
        str_query_update_usermeta = "update userMeta_v#{sfs_version_dev} set level = '#{user_level}', trophies = '#{user_trophies}', shieldActiveTime = '#{user_shield}' where userId = '#{params[:userId_dev_destination]}'"
        dbdev.query(str_query_update_dev)
        dbdev.query(str_query_update_usermeta)
        dbdev.query(str_query_copy_achievement)
        @user_detail = dbprod.query("select u.userId, u.userNote, u.isFake, u.email, u.name, u.locale, u.facebookId, CONVERT_TZ(u.createdAt,'+00:00','#{@timezoneSQL}:00') createdAtPDT, u.isDeleted, u.isLeaderBoardBlocked, um.level, um.trophies,um.attacksWon, um.defensesWon, um.achievements, um.activeId, um.deviceInfo, um.deviceId, um.deviceInfo, um.platform, ugs.gameState, ugs.version, cl.isLocked, cl.clanId from user_v#{sfs_version_prod} u join userMeta_v#{sfs_version_prod} um on u.userId = um.userId join userGameState_v#{sfs_version_prod} ugs on u.userId = ugs.userId join clanLookup_v#{sfs_version_prod} cl on u.userId = cl.userId where u.userId = '#{params[:userId_prod_source]}' LIMIT 1")
        logger.info("keke")
        dbprod.close
        dbdev.close
      end
      connectLumba
      puts "sfs_version: #{@sfs_version}"
      puts (@sfs_version.eql?("1") || @sfs_version.eql?(""))
      if @sfs_version.eql?("1") || @sfs_version.eql?("")
        @error_string = "Invalid sfs_version"
      end
      fake_userId = "#{@sfs_version}_#{(@dblumba.query("select UUID() as userId")).fetch_hash['userId']}"
      if params[:commit].eql?("Delete Player")
        puts "delete userId: #{params[:userid_delete]}"
        # delete row in user table
        connectLumba
        str_query = "update user_v#{@sfs_version} set isDeleted = 1 where userId = '#{params[:userid_delete]}'"
        #str_query = "insert into updateFromAdminPanel set userId = '#{params[:userid_delete]}', isDeleted = 1, status = 0, tableType = 1"
        @dblumba.query(str_query)
        connectLumbaAppData
        @db.query("insert into update_GameState set userId = '#{params[:userid_delete]}', action = 'delete user', userChange = '#{session[:user]['username']}'")
        disconnectLumbaAppData
        my_logger_lumba.info("#{session[:user]['username']} delete userId: #{params[:userid_delete]}")
        getuserdetail(params[:userid_delete])
        disconnectLumba
      end
      if params[:commit].eql?("VerifyReceipt")
        connectLumbaIAP
        str_purchase_trans_info = "Select transaction from purchases where id = '#{params[:purchase_id]}'"
        purchase_trans_infos = @dbsfs.query(str_purchase_trans_info)
        disconnectLumbaIAP
        purchase_trans_infos.each_hash do |row|
          logger.info("transaction: #{row['transaction']}")
          trans = JSON.parse(row['transaction'])["base64EncodedTransactionReceipt"]
          ios_url = "https://buy.itunes.apple.com/verifyReceipt"
          uri = URI.parse(ios_url)
          data = {"receipt-data" => trans}.to_json
          https = Net::HTTP.new(uri.host, uri.port)
          https.use_ssl = true
          headers = {"Content-Type" => "application/json"}
          response = https.post(uri.path, data, headers)
          @verifyresult = response.body
        end
        getuserdetail(params[:user_id])
      end
      if params[:commit].eql?("View")
        #@sfs_version = params[:sfs_version]

        if ((params[:userIdGameState].gsub(/\s+/, " ").strip).eql?("") && (params[:nametb].gsub(/\s+/, " ").strip).eql?("") && (params[:emailtb].gsub(/\s+/, " ").strip).eql?(""))
          @error_string = "No Information to search"
          return
        end

        inbox_param = params[:userIdGameState].strip
        email_param = params[:emailtb].strip
        if (!(params[:userIdGameState].gsub(/\s+/, " ").strip).eql?(""))
          getuserdetail(inbox_param)
        elsif (!(params[:nametb].gsub(/\s+/, " ").strip).eql?(""))
          if (!(params[:trophiestb].gsub(/\s+/, " ").strip).eql?(""))
            #@list_users = @dblumba.query("select u.userId, u.name, u.email, um.trophies from user_v#{@sfs_version} u join userMeta_v#{@sfs_version} um on u.userId = um.userId where u.name like '%#{params[:nametb]}%' and um.trophies = #{params[:trophiestb].strip}")
            #
            @list_users = @dblumba.query("select COUNT(u.userId) from user_v#{@sfs_version} u join userMeta_v#{@sfs_version} um on u.userId = um.userId where u.name like '%#{params[:nametb]}%' and um.trophies = #{params[:trophiestb].strip}")
            @user_detail = nil
            cookies[:name_search] = params[:nametb].strip
            cookies[:trophies_search] = params[:trophiestb].strip
            # cookies[:email_search] = params[:emailtb].strip
          else
            cookies[:name_search] = params[:nametb].strip
            cookies.delete :trophies_search
            @list_users = @dblumba.query("select COUNT(userId) from user_v#{@sfs_version} where name like '%#{params[:nametb].strip}%'")
            @user_detail = nil
            # cookies[:userId] = @user_detail
          end
        else
          @user_detail = @dblumba.query("select u.userId, u.userNote, u.isFake, u.email, u.name, u.locale, u.facebookId, CONVERT_TZ(u.createdAt,'+00:00','#{@timezoneSQL}:00') createdAtPDT, u.isDeleted, u.isLeaderBoardBlocked, um.shieldActiveTime, um.level, um.trophies,um.attacksWon, um.defensesWon, um.achievements, um.activeId, um.deviceId, um.deviceInfo, um.platform, ugs.version, ugs.gameState, cl.isLocked, cl.clanId from user_v#{@sfs_version} u join userMeta_v#{@sfs_version} um on u.userId = um.userId join userGameState_v#{@sfs_version} ugs on u.userId = ugs.userId join clanLookup_v#{@sfs_version} cl on u.userId = cl.userId where u.email = '#{params[:emailtb].strip}'")
        end
      elsif params[:commit].eql?("gamestate_list_blocked_leaderboard")
        str_query = "select u.userId, u.isFake, u.email, u.name, u.locale, u.facebookId, CONVERT_TZ(u.createdAt,'+00:00','#{@timezoneSQL}:00') createdAtPDT, u.isDeleted, u.isLeaderBoardBlocked, um.shieldActiveTime, um.level, um.trophies,um.attacksWon, um.defensesWon, um.achievements, um.activeId, um.deviceId, um.deviceInfo, um.platform, ugs.gameState, cl.isLocked, cl.clanId from user_v#{@sfs_version} u join userMeta_v#{@sfs_version} um on u.userId = um.userId join userGameState_v#{@sfs_version} ugs on u.userId = ugs.userId join clanLookup_v#{@sfs_version} cl on u.userId = cl.userId where u.isLeaderBoardBlocked = 1"
        leaderboard_blocked_players = @dblumba.query(str_query)
        CSV.open("#{Rails.root}/exportedfile/sfs/leaderboard_blocked_players.txt", "w:UTF-8", {:col_sep => "\t"}) { |csv|
          csv << ["userId", "Name", "Locale", "FacebookId", "Email", "Level", "Dagger", "Objects"]
          leaderboard_blocked_players.each_hash do |row|
            userId = row['userId']
            locale = row['locale']
            facebookId = row['facebookId']
            email = row['email']
            name = row['name']
            user_json = JSON.parse(row['gameState'])
            game_level = row['level']
            dagger = user_json['HUD']['trophies']
            object = user_json['Objects']
            csv << [userId, name, locale, facebookId, email, game_level, dagger, object]
          end
        }
        send_file("#{Rails.root}/exportedfile/sfs/leaderboard_blocked_players.txt", :disposition => :attachment)
      elsif params[:commit].eql?("gamestate_list_blocked_tribe")
        str_query = "select u.userId, u.isFake, u.email, u.name, u.locale, u.facebookId, CONVERT_TZ(u.createdAt,'+00:00','#{@timezoneSQL}:00') createdAtPDT, u.isDeleted, u.isLeaderBoardBlocked, um.shieldActiveTime, um.level, um.trophies, um.platform from user_v#{@sfs_version} u join userMeta_v#{@sfs_version} um on u.userId = um.userId join clanLookup_v#{@sfs_version} cl on u.userId = cl.userId where cl.isLocked = 1"
        tribe_blocked_players = @dblumba.query(str_query)
        CSV.open("#{Rails.root}/exportedfile/sfs/tribe_blocked_players.txt", "w:UTF-8", {:col_sep => "\t"}) { |csv|
          csv << ["userId", "Name", "Locale", "FacebookId", "Email", "Level"]
          tribe_blocked_players.each_hash do |row|
            userId = row['userId']
            locale = row['locale']
            facebookId = row['facebookId']
            email = row['email']
            name = row['name']
            game_level = row['level']
            csv << [userId, name, locale, facebookId, email, game_level]
          end
        }
        send_file("#{Rails.root}/exportedfile/sfs/tribe_blocked_players.txt", :disposition => :attachment)
      elsif params[:commit].eql?("Detail")
        logger.info("@sfs_version: #{@sfs_version}")
        getuserdetail(params[:userid_detail])
      elsif params[:commit].eql?("Block from tribe")
        connectLumba
        str_query = "update clanLookup_v#{@sfs_version} set isLocked = 1 where userId = '#{params[:userid_delete]}'"
        @dblumba.query(str_query)
        str_query_insert_backgroundNotices = "insert into backgroundNotices_v#{@sfs_version} set status = 'pending', content =  '{\"type\":0, \"userId\":\"#{params[:userid_delete]}\"}'"
        @dblumba.query(str_query_insert_backgroundNotices)
        my_logger_lumba.info("#{session[:user]['username']} Block from tribe userId: #{params[:userid_delete]}")
        connectLumbaAppData
        @db.query("insert into update_GameState set userId = '#{params[:userid_delete]}', action = 'Block from tribe', userChange = '#{session[:user]['username']}'")
        disconnectLumbaAppData
        getuserdetail(params[:userid_delete])
        disconnectLumba
      elsif params[:commit].eql?("UnBlock from tribe")
        connectLumba
        str_query = "update clanLookup_v#{@sfs_version} set isLocked = 0 where userId = '#{params[:userid_delete]}'"
        @dblumba.query(str_query)
        str_query_insert_backgroundNotices = "insert into backgroundNotices_v#{@sfs_version} set status = 'pending', content =  '{\"type\":1, \"userId\":\"#{params[:userid_delete]}\"}'"
        @dblumba.query(str_query_insert_backgroundNotices)
        my_logger_lumba.info("#{session[:user]['username']} UnBlock from tribe userId: #{params[:userid_delete]}")
        connectLumbaAppData
        @db.query("insert into update_GameState set userId = '#{params[:userid_delete]}', action = 'UnBlock from tribe', userChange = '#{session[:user]['username']}'")
        disconnectLumbaAppData
        getuserdetail(params[:userid_delete])
        disconnectLumba
        # Block from Searching opponent
      elsif params[:commit].eql?("Block from searching opponent")
        connectLumba
        # Check if user already be blocked
        str_check_exist = "select userId from BlockHacker where userId = '#{params[:userid_delete]}' and blockType = 0"
        userId_blocked = @dblumba.query(str_check_exist)
        is_insert = true
        userId_blocked.each_hash do |row|
          is_insert = false
        end

        isActive = @dblumba.query("select activeId from userMeta_v#{@sfs_version} where userId = '#{params[:userid_delete]}'").fetch_hash['activeId']
        if isActive.to_i != -1
          @dblumba.query("update user_v#{@sfs_version} set isOutOfSync = 1  where userId = '#{params[:userid_delete]}'")
        end
        if is_insert
          str_block_searching_opponent = "insert into BlockHacker set userId = '#{params[:userid_delete]}', isBlocked = 1, status = 0,blockType = 0"
          @dblumba.query(str_block_searching_opponent)
        else
          str_block_searching_opponent = "update BlockHacker set isBlocked = 1, status = 0 where userId = '#{params[:userid_delete]}' and blockType = 0"
          @dblumba.query(str_block_searching_opponent)
        end
        my_logger_lumba.info("#{session[:user]['username']} Block from searching opponent userId: #{params[:userid_delete]}")
        connectLumbaAppData
        @db.query("insert into update_GameState set userId = '#{params[:userid_delete]}', action = 'Block from searching opponent', userChange = '#{session[:user]['username']}'")
        disconnectLumbaAppData
        getuserdetail(params[:userid_delete])
        disconnectLumba
      elsif params[:commit].eql?("UnBlock from searching opponent")
        connectLumba
        isActive = @dblumba.query("select activeId from userMeta_v#{@sfs_version} where userId = '#{params[:userid_delete]}'").fetch_hash['activeId']
        if isActive.to_i != -1
          @dblumba.query("update user_v#{@sfs_version} set isOutOfSync = 1  where userId = '#{params[:userid_delete]}'")
        end
        str_unblock_searching_opponent = "update BlockHacker set isBlocked = 0, status = 0 where userId = '#{params[:userid_delete]}'"
        @dblumba.query(str_unblock_searching_opponent)
        my_logger_lumba.info("#{session[:user]['username']} UnBlock from searching opponent from tribe userId: #{params[:userid_delete]}")
        connectLumbaAppData
        @db.query("insert into update_GameState set userId = '#{params[:userid_delete]}', action = 'UnBlock from searching opponent', userChange = '#{session[:user]['username']}'")
        disconnectLumbaAppData
        getuserdetail(params[:userid_delete])
        disconnectLumba
      elsif params[:commit].eql?("Block from being attacked")
        connectLumba
        # Check if user already be blocked
        str_check_exist = "select userId from BlockHacker where userId = '#{params[:userid_delete]}' and blockType = 2"
        userId_blocked = @dblumba.query(str_check_exist)
        is_insert = true
        userId_blocked.each_hash do |row|
          is_insert = false
        end
        isActive = @dblumba.query("select activeId from userMeta_v#{@sfs_version} where userId = '#{params[:userid_delete]}'").fetch_hash['activeId']
        if isActive.to_i != -1
          @dblumba.query("update user_v#{@sfs_version} set isOutOfSync = 1  where userId = '#{params[:userid_delete]}'")
        end
        if is_insert
          str_block_be_attacked = "insert into BlockHacker set userId = '#{params[:userid_delete]}', isBlocked = 1, status = 0, blockType = 2"
          @dblumba.query(str_block_be_attacked)
        else
          str_block_be_attacked = "update BlockHacker set isBlocked = 1, status = 0 where userId = '#{params[:userid_delete]}'  and blockType = 2"
          logger.info("query #{str_block_be_attacked}")
          @dblumba.query(str_block_be_attacked)
        end
        my_logger_lumba.info("#{session[:user]['username']} Block from being attacked userId: #{params[:userid_delete]}")
        connectLumbaAppData
        @db.query("insert into update_GameState set userId = '#{params[:userid_delete]}', action = 'Block from being attacked', userChange = '#{session[:user]['username']}'")
        disconnectLumbaAppData
        getuserdetail(params[:userid_delete])
        disconnectLumba
      elsif params[:commit].eql?("UnBlock from being attacked")
        connectLumba
        isActive = @dblumba.query("select activeId from userMeta_v#{@sfs_version} where userId = '#{params[:userid_delete]}'").fetch_hash['activeId']
        if isActive.to_i != -1
          @dblumba.query("update user_v#{@sfs_version} set isOutOfSync = 1  where userId = '#{params[:userid_delete]}'")
        end
        str_unblock_be_attacked = "update BlockHacker set isBlocked = 0, status = 0 where userId = '#{params[:userid_delete]}' and blockType = 2"
        logger.info("query #{str_unblock_be_attacked}")
        @dblumba.query(str_unblock_be_attacked)
        my_logger_lumba.info("#{session[:user]['username']} UnBlock from global chat from tribe userId: #{params[:userid_delete]}")
        connectLumbaAppData
        @db.query("insert into update_GameState set userId = '#{params[:userid_delete]}', action = 'UnBlock from being attacked', userChange = '#{session[:user]['username']}'")
        disconnectLumbaAppData
        getuserdetail(params[:userid_delete])
        disconnectLumba
      elsif params[:commit].eql?("Offline User")
        connectLumba
        str_query_offline = "insert into updateFromAdminPanel set userId = '#{params[:userid_delete]}', status = 0, activeId = -1"
        #str_query_offline = "insert into updateFromAdminPanel set activeId = -1, userId = '#{params[:userid_delete]}', status = 0, tableType = 2"
        @dblumba.query(str_query_offline)
        connectLumbaAppData
        @db.query("insert into update_GameState set userId = '#{params[:userid_delete]}', action = 'Offline User', userChange = '#{session[:user]['username']}'")
        disconnectLumbaAppData
        getuserdetail(params[:userid_delete])
        disconnectLumba
      elsif params[:commit].eql?("Turn on Shield")
        timeturnonshield = params[:selectshieldhours].to_i
        shield = (timeturnonshield*60*60 + 10 - Time.now.gmt_offset)*1000 + (Time.now.utc.to_f * 1000).to_i
        datetimeshield = Time.at(shield/1000)
        datetimeshieldstring = datetimeshield.strftime("%Y/%m/%d %H:%M:%S")
        str_query_turnonshieldActiveTime = "update userMeta_v#{@sfs_version} set shieldActiveTime = #{shield} where userId = '#{params[:userid_delete]}'"
        #str_query_turnonshieldActiveTime = "insert into updateFromAdminPanel set userId = '#{params[:userid_delete]}', status = 0, shieldActiveTime = #{shield}"
        usergamestate = @dblumba.query("select gameState from userGameState_v#{@sfs_version} where userId = '#{params[:userid_delete]}'").fetch_hash['gameState']
        game_state = JSON.parse(usergamestate)
        game_state['HUD']['shieldActiveTime'] = "#{datetimeshieldstring}"
        #str_query_update_gamestate = "update userGameState_v#{@sfs_version} set gameState = '#{JSON.generate(game_state)}' where userId = '#{params[:userid_delete]}'"
        str_query_update_gamestate = "insert into updateFromAdminPanel set userId = '#{params[:userid_delete]}', status = 0, shieldActiveTime = #{shield}"
        # get current shield and compare
        currentshieldstr = @dblumba.query("select shieldActiveTime from userMeta_v#{@sfs_version} where userId = '#{params[:userid_delete]}'").fetch_hash['shieldActiveTime']
        currentshield = currentshieldstr.to_i
        if (shield > currentshield)
          # check if active user or not
          # isActive = @dblumba.query("select activeId from userMeta_v#{@sfs_version} where userId = '#{params[:userid_delete]}'").fetch_hash['activeId']
          # if isActive.to_i != -1
          @dblumba.query("update user_v#{@sfs_version} set isOutOfSync = 1  where userId = '#{params[:userid_delete]}'")
          # end
          #@dblumba.query(str_query_turnonshieldActiveTime)
          @dblumba.query(str_query_update_gamestate)
          connectLumbaAppData
          @db.query("insert into update_GameState set userId = '#{params[:userid_delete]}', action = 'Turn on Shield', FromShield = '#{convertShieldTime(currentshield)}', ToShield = '#{convertShieldTime(shield)}', userChange = '#{session[:user]['username']}'")
          disconnectLumbaAppData
        end
        getuserdetail(params[:userid_delete])
        disconnectLumba
      elsif params[:commit].eql?("Download Battle Log")
        str_query = "select * from userMeta_v31 where userId = '#{params[:userid_delete]}'"
        userMeta = @dblumba.query(str_query)
        filename = ""
        userMeta.each_hash do |row|
          a = row['battleLog'].force_encoding("UTF-8")
          filename = "#{row['userId']}_BattleLog.txt"
          File.open("#{Rails.root}/exportedfile/#{filename}", 'w:UTF-8') { |file| file.puts("#{row['battleLog'].force_encoding("UTF-8")}\n----------------------------------------------------------------------------------\n#{row['inboxMessages'].force_encoding("UTF-8")}") }
        end
        getuserdetail(params[:userid_delete])
        send_file("#{Rails.root}/exportedfile/#{filename}", :disposition => :attachment)
      elsif params[:commit].eql?("Turn off Shield")
        connectLumba
        #str_query_resetshieldActiveTime = "update userMeta_v#{@sfs_version} set shieldActiveTime = 0 where userId = '#{params[:userid_delete]}'"
        str_query_resetshieldActiveTime = "insert into updateFromAdminPanel set userId = '#{params[:userid_delete]}', status = 0, shieldActiveTime = 0"
        usergamestate = @dblumba.query("select gameState from userGameState_v#{@sfs_version} where userId = '#{params[:userid_delete]}'").fetch_hash['gameState']
        game_state = JSON.parse(usergamestate)
        game_state['HUD']['shieldActiveTime'] = "null"
        str_query_update_gamestate = "update userGameState_v#{@sfs_version} set gameState = '#{JSON.generate(game_state)}' where userId = '#{params[:userid_delete]}'"
        #str_query_update_gamestate = "insert into updateFromAdminPanel set userId = '#{params[:userid_delete]}', status = 0, shieldActiveTime = 0"
        # isActive = @dblumba.query("select activeId from userMeta_v#{@sfs_version} where userId = '#{params[:userid_delete]}'").fetch_hash['activeId']
        # if isActive.to_i != -1
        @dblumba.query("update user_v#{@sfs_version} set isOutOfSync = 1  where userId = '#{params[:userid_delete]}'")
        # end
        @dblumba.query(str_query_resetshieldActiveTime)
        @dblumba.query(str_query_update_gamestate)
        connectLumbaAppData
        @db.query("insert into update_GameState set userId = '#{params[:userid_delete]}', action = 'Turn off Shield', userChange = '#{session[:user]['username']}'")
        disconnectLumbaAppData
        getuserdetail(params[:userid_delete])
        disconnectLumba
      elsif params[:commit].eql?("Block from leaderboard")
        connectLumba
        str_query = "update user_v#{@sfs_version} set isLeaderBoardBlocked = 1 where userId = '#{params[:userid_delete]}'"
        #str_query = "insert into updateFromAdminPanel set userId = '#{params[:userid_delete]}', status = 0, tableType = 1, isLeaderBoardBlocked = 1"
        @dblumba.query(str_query)
        @dblumba.query("update user_v#{@sfs_version} set isOutOfSync = 1  where userId = '#{params[:userid_delete]}'")
        connectLumbaAppData
        @db.query("insert into update_GameState set userId = '#{params[:userid_delete]}', action = 'Block from leaderboard', userChange = '#{session[:user]['username']}'")
        disconnectLumbaAppData
        my_logger_lumba.info("#{session[:user]['username']} Block from leaderboard userId: #{params[:userid_delete]}")
        getuserdetail(params[:userid_delete])
        disconnectLumba
      elsif params[:commit].eql?("UnBlock from leaderboard")
        connectLumba
        str_query = "update user_v#{@sfs_version} set isLeaderBoardBlocked = 0 where userId = '#{params[:userid_delete]}'"
        #str_query = "insert into updateFromAdminPanel set userId = '#{params[:userid_delete]}', status = 0, tableType = 1, isLeaderBoardBlocked = 0"
        @dblumba.query(str_query)
        @dblumba.query("update user_v#{@sfs_version} set isOutOfSync = 1  where userId = '#{params[:userid_delete]}'")
        connectLumbaAppData
        @db.query("insert into update_GameState set userId = '#{params[:userid_delete]}', action = 'UnBlock from leaderboard', userChange = '#{session[:user]['username']}'")
        disconnectLumbaAppData
        my_logger_lumba.info("#{session[:user]['username']} UnBlock from leaderboard userId: #{params[:userid_delete]}")
        getuserdetail(params[:userid_delete])
        disconnectLumba
      elsif params[:commit].eql?("Real User")
        str_query = "update user_v#{@sfs_version} set isFake = 0 where userId = '#{params[:userid_delete]}'"
        #str_query = "insert into updateFromAdminPanel set userId = '#{params[:userid_delete]}', status = 0, tableType = 1, isFake = 0"
        @dblumba.query(str_query)
        getuserdetail(params[:userid_delete])
      elsif params[:commit].eql?("Fake User")
        #insert user
        new_fake_user = @dblumba.query("insert into user_v#{@sfs_version} (userId, email, password, name, locale, facebookId, passwordSalt, isFake,resetPasswordCode, requestResetPasswordAt, sfsVersion) select '#{fake_userId}','trang@fake', password, name, locale, facebookId, passwordSalt, 1,resetPasswordCode, requestResetPasswordAt, #{@sfs_version} from user_v#{@sfs_version} where userId = '#{params[:userid_delete]}' ")
        # insert clanLookup
        @dblumba.query("insert into clanLookup_v#{@sfs_version} set userId = '#{fake_userId}', clanId = ''")
        # insert userGameState
        @dblumba.query("insert into userGameState_v#{@sfs_version} (userId, gameState) select '#{fake_userId}', gameState from userGameState_v#{@sfs_version} where userId = '#{params[:userid_delete]}' ")
        # insert userIAP
        userIAP = @dblumba.query("select * from userIAP_v#{@sfs_version} where userId = '#{params[:userid_delete]}'")
        if !userIAP.fetch_hash.nil?
          @dblumba.query("insert into userIAP_v#{@sfs_version} (userId, purchase, platform, purchaseMd5Checksum) select '#{fake_userId}', purchase, platform, purchaseMd5Checksum from userIAP_v#{@sfs_version} where userId = '#{params[:userid_delete]}' ")
        end
        # insert userMeta
        userMeta = @dblumba.query("select userId from userMeta_v#{@sfs_version} where userId = '#{params[:userid_delete]}'")
        if !userMeta.fetch_hash.nil?
          @dblumba.query("insert into userMeta_v#{@sfs_version} (userId, level, trophies, attacksWon, defensesWon, achievements, battleLog, inboxMessages, recentDefenses, beingAttackedAt, shieldActiveTime, activeId, deviceId, platform, notices, totalBattles) select '#{fake_userId}', level, trophies, attacksWon, defensesWon, achievements, battleLog, inboxMessages, recentDefenses, beingAttackedAt, shieldActiveTime, activeId, deviceId, platform, notices, totalBattles from userMeta_v#{@sfs_version} where userId = '#{params[:userid_delete]}' LIMIT 1")
        end
        my_logger_lumba.info("#{session[:user]['username']} maked fake user: id: #{fake_userId}")
        getuserdetail(params[:userid_delete])
      elsif params[:commit].eql?("downloadgamestateinfo")
        `rm -rf #{Rails.root}/exportedfile/gamestatehistorycsv.csv`
        @csvfile = CSV.open("#{Rails.root}/exportedfile/gamestatehistorycsv.csv", "ab", {:col_sep => "\t"})
        @csvfile << ["Level", "experience", "gold", "water", "Oil", "Gem", "townhall level", "Trophies", "TimePDT", "Time"]
        connectLumbaIAP
        starttime = Time.parse("#{params[:starttimehistory]}").utc
        endtime = Time.parse("#{params[:endtimehistory]}").utc
        getgamestatehistory(params[:useridhistory], starttime, endtime)
        disconnectLumbaIAP
        @csvfile.close
        send_file("#{Rails.root}/exportedfile/gamestatehistorycsv.csv", :disposition => :attachment)
        getuserdetail(params[:useridhistory])
      end

      if params[:actioncopyBattlelog]
        # Copy battle log

        connectLumba
        countcpbl = @dblumba.query("SELECT COUNT(userId) countcpbl FROM userMeta_v31 where userId='#{params[:cpbl_destination_uid].strip}';").fetch_hash['countcpbl']
        puts countcpbl
        if countcpbl.to_i != 0
          cpbl = @dblumba.query("update userMeta_v31 as m1 inner join (select battleLog from userMeta_v31 where userId = '#{params[:userId]}') as m2 set m1.battleLog = m2.battleLog where m1.userId = '#{params[:cpbl_destination_uid].strip}';")
          @cpblscmessage = "Copy battle log successfully. "
          @cpblerrmessage = ""
        else
          @cpblscmessage = ""
          @cpblerrmessage = "Destination userId does not exist!"
        end
        getuserdetail(params[:userId])
        disconnectLumba
      end

      # Report User
      if params[:actionReportUser]
        begin
          connectLumba
          viewnoteqr = "SELECT userNote FROM user_v31 WHERE userId='#{params[:userId]}';"
          @viewnote = @dblumba.query(viewnoteqr).fetch_hash['userNote']
          disconnectLumba
          reportTime = Time.now
          if @viewnote.eql? nil
            jsons = JSON.parse("{\"Notes\":[]}")
          else
            jsons = JSON.parse(@viewnote)
          end
          data = {"Reporter"=>params[:reportuser_user], "Date" => reportTime, "Note" => params[:reportuser_note].gsub(/["'+=();]/, '') }
          jsons['Notes'] << data
          newjsons = jsons.to_json
          connectLumba
          addnoteqr = "UPDATE user_v31 SET userNote='#{newjsons}' WHERE userId='#{params[:userId]}';"
          @dblumba.query(addnoteqr)
          getuserdetail(params[:userId])
          disconnectLumba
        rescue Exception => e
          puts e
        end
      end

      if params[:actionupdateJira]
        #create jira bug
        # Consider the use of :use_ssl and :ssl_verify_mode options if running locally
        # for tests.

        puts @reporterEmail
        @jusername = ''
        if @reporterEmail == "osama.fattouh@lum.ba"
          @jusername = "OF"
          @jpassword = "123lumba"
        elsif @reporterEmail == "abdulrahman.aldawood@lum.ba"
          @jusername = "AbA"
          @jpassword = "burgerboutique"
        elsif @reporterEmail == "saleh.bazarah@lum.ba"
          @jusername = "SB"
          @jpassword = "burgerboutique"
        elsif @reporterEmail == "moataz.albanyan@lum.ba"
          @jusername = "MA"
          @jpassword = "burgerboutique"
        elsif @reporterEmail == "anwar.sedam@lum.ba"
          @jusername = "AS"
          @jpassword = "burgerboutique"
        elsif @reporterEmail == "tr-support@lum.ba"
          @jusername = "TR-Support"
          @jpassword = "burgerboutique"
        elsif @reporterEmail == "dashboard@lum.ba"
          @jusername = "Dashboard"
          @jpassword = "25taylor"
        elsif @reporterEmail == "abdullah.hamed@lum.ba"
          @jusername = "AH"
          @jpassword = "burgerboutique"
        end

        options = {
            :username => @jusername,
            :password => @jpassword,
            :site     => 'https://sixthgearstudios.atlassian.net',
            :context_path => '',
            :auth_type => :basic
        }

        client = JIRA::Client.new(options)

        # if params[:commit].eql?("Send")
        if (params[:jira_title] != "" && params[:jira_description] != "")
          issue = client.Issue.build
          issue.save({
                         "fields"=>{"summary"=>"[Investigate 1.9.4] #{params[:jira_title]}",
                                    "description" => "[#{@jusername}] \n User ID:	#{cookies[:userId]} \n #{params[:jira_description]}",
                                    "assignee" => {"name" => "Toan QA"},
                                    "project"=>{
                                        "key"=>"FAYEZ",
                                    },
                                    "issuetype"=>{
                                        "name" => "Bug"
                                    },
                                    "priority" => {
                                        "name" => "#{params[:jira_priority]}"
                                    }
                         }
                     }
          )
          issue.fetch
          test1 = JSON.parse(issue.to_json)
          @jlink = "https://sixthgearstudios.atlassian.net/issues/#{test1["key"]}"
          @jtitle = test1["summary"]
          @jdescription = test1["description"]
          @userId = cookies[:userId]
          @userIdText = "User ID: "
          @reporterText = "Reporter: "
          @summaryText = "Summary: "
          @descriptionText = "Description: "
          @jiraLinkText = "Jira Link: "
          @reporterEmailbuoi = @reporterEmail
          @successText = "Jira created successfully!"
          @saved = ""
        end
        getuserdetail(params[:userId])
      end

      @APPLE_DEVICE_IDENTIFIER_TO_NAME = {
          "iPad1,1" => "iPad 1 (2010)",
          "iPad2,1" => "iPad 2 Wi-Fi (2011)",
          "iPad2,2" => "iPad 2 Wi-Fi+GSM (2011)",
          "iPad2,3" => "iPad 2 Wi-Fi+CDMA (2011)",
          "iPad2,4" => "iPad 2 Wi-Fi (2012)",
          "iPad3,1" => "iPad 3 Wi-Fi (2012)",
          "iPad3,2" => "iPad 3 Wi-Fi+CDMA (2012)",
          "iPad3,3" => "iPad 3 Wi-Fi+GSM (2012)",
          "iPad3,4" => "iPad 4 Wi-Fi (2012)",
          "iPad3,5" => "iPad 4 Wi-Fi+GSM (2012)",
          "iPad3,6" => "iPad 4 Wi-Fi+CDMA (2012)",
          "iPad4,1" => "iPad Air Wi-Fi (2013)",
          "iPad4,2" => "iPad Air Wi-Fi+GSM+CDMA (2013)",
          "iPad2,5" => "iPad Mini 1 Wi-Fi (2012)",
          "iPad2,6" => "iPad Mini 1 Wi-Fi+GSM (2012)",
          "iPad2,7" => "iPad Mini 1 Wi-Fi+CDMA (2012)",
          "iPad4,4" => "iPad Mini 2 Wi-Fi (2013)",
          "iPad4,4" => "iPad Mini 2 Wi-Fi+GSM+CDMA (2013)",
          "iPhone1,1" => "iPhone 1 (2007)",
          "iPhone1,2" => "iPhone 3G (2008)",
          "iPhone2,1" => "iPhone 3GS (2009)",
          "iPhone3,1" => "iPhone 4 GSM (2010)",
          "iPhone3,2" => "iPhone 4 GSM Rev A (2011)",
          "iPhone3,3" => "iPhone 4 CDMA (2010)",
          "iPhone4,1" => "iPhone 4S (2011)",
          "iPhone5,1" => "iPhone 5 GSM (2012)",
          "iPhone5,2" => "iPhone 5 GSM+CDMA (2012)",
          "iPhone5,3" => "iPhone 5c GSM (2013)",
          "iPhone5,4" => "iPhone 5c Global (2013)",
          "iPhone6,1" => "iPhone 5s GSM (2013)",
          "iPhone6,2" => "iPhone 5s Global (2013)",
          "iPhone7,1" => "iPhone 6 Plus",
          "iPhone7,2" => "iPhone 6",
          "iPod1,1" => "iPod Touch 1 (2007)",
          "iPod2,1" => "iPod Touch 2 (2008)",
          "iPod3,1" => "iPod Touch 3 (2009)",
          "iPod4,1" => "iPod Touch 4 (2010)",
          "iPod5,1" => "iPod Touch 5 (2012)",
      }

      if params[:actionupdate]
        # get old info
        fromname = toname = fromemail = toemail = fromlocal = tolocal = fromfacebookid = tofacebookid = ""
        levelreason = pointsreason = goldreason = waterreason = oilreason = pearlsreason = diwanlevelreason = daggerreason = ""
        fromlevel = tolevel = fromexpoint = toexpoint = fromgold = togold = fromwater = towater = fromoil = tooil = frompearls = topearls = fromdiwanlevel = todiwanlevel = fromdagger = todagger = 0
        old_user_detail = @dblumba.query("select u.userId, u.email, u.name, u.locale, u.facebookId, CONVERT_TZ(u.createdAt,'+00:00','#{@timezoneSQL}:00') createdAtPDT, um.level, um.trophies, ugs.gameState from user_v#{@sfs_version} u join userMeta_v#{@sfs_version} um on u.userId = um.userId join userGameState_v#{@sfs_version} ugs on u.userId = ugs.userId where u.userId = '#{params[:userId]}' LIMIT 1")
        old_user_detail.each_hash do |row|
          fromname = row['name'].force_encoding("UTF-8")
          fromemail = row['email']
          fromlocal = row['locale']
          fromfacebookid = row['facebookId']
          fromlevel = row['level']
          fromdagger = row['trophies']
          olduser_json = JSON.parse(row['gameState'])
          oldgame_level = olduser_json['HUD']['hInfo']
          fromexpoint = oldgame_level[1]
          fromgold = oldgame_level[2]
          fromwater = oldgame_level[3]
          fromoil = oldgame_level[4]
          frompearls = oldgame_level[5]
          fromdiwanlevel = oldgame_level[6]
        end
        toname = params[:gamestate_username].force_encoding("UTF-8")
        if (!fromname.eql?(toname))
          logger.info(fromname +" eql to " + toname)
          # check if name exist
          checknamesql = @dblumba.query("select name from user_v#{@sfs_version} where name = '#{toname}' limit 1")
          checknamesql.each_hash do |row|
            logger.info("The name already exist")
            @error_string = "The name already exist"
            modifydata = false
          end
        end
        logger.info("modifydata: #{modifydata}")
        if modifydata
          logger.info("modifydata: #{modifydata} sau")
          toemail = params[:gamestate_email]
          tolocal = params[:gamestate_locale]
          tofacebookid = params[:gamestate_facebookId]
          tolevel = params[:gamestate_level].to_i
          levelreason = params[:gamestate_level_reason].to_s
          pointsreason = params[:gamestate_points_reason].to_s
          goldreason = params[:gamestate_gold_reason].to_s
          waterreason = params[:gamestate_water_reason].to_s
          oilreason = params[:gamestate_oil_reason].to_s
          pearlsreason = params[:gamestate_pearls_reason].to_s
          diwanlevelreason = params[:gamestate_diwanlevel_reason].to_s
          daggerreason = params[:gamestate_dagger_reason].to_s
          toexpoint = params[:gamestate_exper].to_i
          togold = params[:gamestate_gold].to_i
          towater = params[:gamestate_water].to_i
          tooil = params[:gamestate_darkwater].to_i
          topearls = params[:gamestate_gems].to_i
          todiwanlevel = params[:gamestate_townhall].to_i
          todagger = params[:gamestate_trophies]

          #if fromdagger != todagger
          #block_user_from_action
          #if(session[:user]['username'].eql?("tr-support@lum.ba"))
          #return
          #end
          #end
          # update user table
          #@sfs_version = params[:sfs_version]
          puts "sfs_version: #{@sfs_version}"
          isActive = @dblumba.query("select activeId from userMeta_v#{@sfs_version} where userId = '#{params[:userId]}'").fetch_hash['activeId']
          #if isActive.to_i != -1
          #@dblumba.query("update user_v#{@sfs_version} set name = '#{params[:gamestate_username]}', email = '#{params[:gamestate_email]}',locale = '#{params[:gamestate_locale]}', facebookId = '#{params[:gamestate_facebookId]}', isFake = '#{params[:gamestate_isFake]}', isOutOfSync = 1  where userId = '#{params[:userId]}'")
          #else
          #@dblumba.query("update user_v#{@sfs_version} set name = '#{params[:gamestate_username]}', email = '#{params[:gamestate_email]}',locale = '#{params[:gamestate_locale]}', facebookId = '#{params[:gamestate_facebookId]}', isFake = '#{params[:gamestate_isFake]}' where userId = '#{params[:userId]}'")
          #end
          # update userMeta
          #str_query_meta = "update userMeta_v#{@sfs_version} set level = '#{params[:gamestate_level]}', trophies = #{params[:gamestate_trophies]} where userId = '#{params[:userId]}'"
          #str_query_meta = "insert into updateFromAdminPanel set userId = '#{params[:userId]}', status = 0, tableType = 2, level = '#{params[:gamestate_level]}', trophies = #{params[:gamestate_trophies]}"
          #@dblumba.query(str_query_meta)
          # update userGameState
          #game_state_result = @dblumba.query("select gameState from userGameState_v#{@sfs_version} where userId = '#{params[:userId]}'").fetch_hash
          #game_state = JSON.parse(game_state_result['gameState'])
          #abc = "[#{CGI.unescapeHTML(params[:objectValueArray]).gsub(/=>/, ':')}]"
          #abc_json = JSON.parse(abc)
          #game_object = {}
          #objectKeyArray = params[:objectKeyArray].split(",")
          #objectValueArray = params[:objectValueArray].split(",")
          #objectKeyArray.each_with_index do |element,index|
          #  game_object[element] = objectValueArray[index].gsub(/=>/, ':')
          #end
          #game_object['nTiles'] = (objectKeyArray.size - 1)
          #objectKeyArray.each_with_index do |element,index|
          #  game_object[element] = (abc_json[index])
          #end
          #hudinfo = []
          #hudinfo.push(params[:gamestate_level].to_i) # gamestate_level
          #hudinfo.push(params[:gamestate_exper].to_i) # gamestate_exper
          #hudinfo.push(params[:gamestate_gold].to_i) # gamestate_gold
          #hudinfo.push(params[:gamestate_water].to_i) # gamestate_water
          #hudinfo.push(params[:gamestate_darkwater].to_i) # gamestate_darkwater
          #hudinfo.push(params[:gamestate_gems].to_i) # gamestate_gems
          #hudinfo.push(params[:gamestate_townhall].to_i) # gamestate_townhall
          #game_state['HUD']['hInfo'] = hudinfo
          #game_state['HUD']['trophies'] = params[:gamestate_trophies].to_i
          #game_state['Objects'] = game_object

          #game_state['Settings']['sound'] = params[:gamestate_sound].to_i
          #game_state['Settings']['music'] = params[:gamestate_music].to_i
          #lastmessagerequest = game_state['clanUnits']['lastRequestMessage']
          #if !lastmessagerequest.nil?
          #lastmessagerequesti1 = lastmessagerequest.gsub(/["']/){ |s| "" }
          #lastmessagerequesti1 = lastmessagerequest.gsub(/[I]/){ |s| "I\'" }
          #game_state['clanUnits']['lastRequestMessage'] = lastmessagerequesti1
          #end
          #str_query = "update userGameState_v#{@sfs_version} set gameState = '#{JSON.generate(game_state)}' where userId = '#{params[:userId]}'"
          str_query = "insert into updateFromAdminPanel set userId = '#{params[:userId]}', status = 0"
          if (params[:gamestate_level] != "")
            str_query += ", level= '#{params[:gamestate_level]}'"
            @saved = "Saved successfully!"
          end
          if (params[:gamestate_trophies] != "" && cookies[:login_username] == "dashboard@lum.ba")
            str_query += ", trophies = '#{params[:gamestate_trophies]}'"
            @saved = "Saved successfully!"
          elsif (params[:gamestate_trophies] != "" && cookies[:login_username] != "dashboard@lum.ba")
            @saved = "Sorry, your account do not have permission to change the dagger."
            str_query += ""
          end
          # Check if email already exist
          if (params[:gamestate_email] != "")
            countQuery = "SELECT count(email) as emailCount FROM user_v#{@sfs_version} WHERE email='#{params[:gamestate_email]}'"
            lumba_countQuery = @dblumba.query(countQuery).fetch_hash['emailCount'].to_i
          end
          if (params[:gamestate_email] != "" && lumba_countQuery == 0)
            str_query += ", email= '#{params[:gamestate_email]}'"
            @saved = "Saved successfully!"
          end
          if (params[:gamestate_exper] != "")
            str_query += ", experiencePoint = '#{params[:gamestate_exper]}'"
            @saved = "Saved successfully!"
          end
          if (params[:gamestate_gold] != "")
            str_query += ", gold = '#{params[:gamestate_gold]}'"
            @saved = "Saved successfully!"
          end
          if (params[:gamestate_water] != "")
            str_query += ", water = '#{params[:gamestate_water]}'"
            @saved = "Saved successfully!"
          end
          if (params[:gamestate_darkwater] != "")
            str_query += ", oil = '#{params[:gamestate_darkwater]}'"
            @saved = "Saved successfully!"
          end
          if (params[:gamestate_gems] != "")
            str_query += ", pearls = '#{params[:gamestate_gems]}'"
            @saved = "Saved successfully!"
          end
          if (params[:gamestate_townhall] != "")
            str_query += ", diwanlevel = '#{params[:gamestate_townhall]}'"
            @saved = "Saved successfully!"
          end
          if (params[:gamestate_isFake] != "")
            str_query += ", isFake= '#{params[:gamestate_isFake]}'"
            @saved = "Saved successfully!"
          end
          if (params[:gamestate_facebookId] != "")
            str_query += ", facebookId= '#{params[:gamestate_facebookId]}'"
            @saved = "Saved successfully!"
          end
          if (params[:gamestate_username] != "" && !fromname.eql?(toname))
            str_query += ", name = '#{params[:gamestate_username]}'"
            @saved = "Saved successfully!"
          end
          if (params[:gamestate_locale] != "" && !fromlocal.eql?(tolocal))
            str_query += ", locale = '#{params[:gamestate_locale]}'"
            @saved = "Saved successfully!"
          end
          my_logger_lumba.info("#{session[:user]['username']} updated gamestate_v#{@sfs_version}: #{str_query}")
          game_state_result = @dblumba.query(str_query)

          salt = SecureRandom.hex
          if (params[:gamestate_password] != "")
            password = Digest::MD5.hexdigest(salt + params[:gamestate_password])
            user_query = "UPDATE user_v#{@sfs_version} SET password= '#{password}', passwordSalt= '#{salt}' WHERE userId='#{params[:userId]}'"
            connectLumba2
            lumba_user_query = @dblumba2.query(user_query)
            disconnectLumba2
          end

          if (params[:gamestate_password] != "" || params[:gamestate_level] != "" || params[:gamestate_trophies] != ""  || (params[:gamestate_email] != "" && !fromemail.eql?(toemail) && lumba_countQuery == 0) || params[:gamestate_exper] != "" || params[:gamestate_gold] != "" || params[:gamestate_water] != "" || params[:gamestate_darkwater] != "" || params[:gamestate_gems] != "" || params[:gamestate_townhall] != "" || (params[:gamestate_username] != "" && !fromname.eql?(toname)) || (params[:gamestate_locale] != "" && !fromlocal.eql?(tolocal)))
            connectLumbaAppData
            str_querygs = "insert into update_GameState set userId = '#{params[:userId]}', action = 'update gamestate', userChange = '#{session[:user]['username']}'"
            if (params[:gamestate_level] != "")
              str_querygs += ", FromLevel = #{fromlevel}, ToLevel = #{tolevel}, LevelChangeReason = '#{levelreason}'"
              @saved = "Saved successfully!"
            end
            if (params[:gamestate_trophies] != "" && cookies[:login_username] == "dashboard@lum.ba")
              str_querygs += ", FromDagger = #{fromdagger}, ToDagger = #{todagger}, DaggerChangeReason = '#{daggerreason}'"
              @saved = "Saved successfully!"
            elsif (params[:gamestate_trophies] != "" && cookies[:login_username] != "dashboard@lum.ba")
              str_querygs += ""
              @saved = "Sorry, your account do not have permission to change the dagger."
            end
            if (params[:gamestate_email] != "" && lumba_countQuery == 0)
              str_querygs += ", FromEmail = '#{fromemail}', ToEmail = '#{toemail}'"
              @saved = "Saved successfully!"
            elsif (params[:gamestate_email] != "" && lumba_countQuery != 0)
              @saved = "Email already exists!"
              str_querygs += ""
            end
            if (params[:gamestate_password] != "")
              str_querygs += ", PwdChange = 'PasswordChange'"
              @saved = "Saved successfully!"
            end
            if (params[:gamestate_exper] != "")
              str_querygs += ", FromExPoint = #{fromexpoint}, ToExPoint = #{toexpoint}, ExPointChangeReason = '#{pointsreason}'"
              @saved = "Saved successfully!"
            end
            if (params[:gamestate_gold] != "")
              str_querygs += ", FromGold = #{fromgold}, ToGold = #{togold}, GoldChangeReason = '#{goldreason}'"
              @saved = "Saved successfully!"
            end
            if (params[:gamestate_water] != "")
              str_querygs += ", FromWater = #{fromwater}, ToWater = #{towater}, WaterChangeReason = '#{waterreason}'"
              @saved = "Saved successfully!"
            end
            if (params[:gamestate_darkwater] != "")
              str_querygs += ", FromOil = #{fromoil}, ToOil = #{tooil}, OilChangeReason = '#{oilreason}'"
              @saved = "Saved successfully!"
            end
            if (params[:gamestate_gems] != "")
              str_querygs += ", FromPearls = #{frompearls}, ToPearls = #{topearls}, PearlsChangeReason = '#{pearlsreason}'"
              @saved = "Saved successfully!"
            end
            if (params[:gamestate_townhall] != "")
              str_querygs += ", FromDiwanLevel = #{fromdiwanlevel}, ToDiwanLevel = #{todiwanlevel}, DiwanLevelChangeReason = '#{diwanlevelreason}'"
              @saved = "Saved successfully!"
            end
            if (params[:gamestate_isFake] != "")
              str_querygs += ", isFake= '#{params[:gamestate_isFake]}'"
              @saved = "Saved successfully!"
            end
            if (params[:gamestate_facebookId] != "")
              str_querygs += ", FromFacebookId = '#{fromfacebookid}', ToFacebookId = '#{tofacebookid}'"
              @saved = "Saved successfully!"
            end
            if (params[:gamestate_username] != "" && !fromname.eql?(toname))
              str_querygs += ", FromName = '#{fromname}', ToName = '#{toname}'"
              @saved = "Saved successfully!"
            end
            if (params[:gamestate_locale] != "" && !fromlocal.eql?(tolocal))
              str_querygs += ", FromLocal = '#{fromlocal}', ToLocal = '#{tolocal}'"
              @saved = "Saved successfully!"
            end
            @db.query(str_querygs)
            disconnectLumbaAppData
          end
          if (params[:gamestate_email] != "" && lumba_countQuery != 0)
            @saved = "Email already exists!"
          end
        end
        getuserdetail(params[:userId])
      end
      if !(@user_detail.nil?)
        logger.info("======================come here=====================")
        @user_detail.each_hash do |row|
          logger.info(row['userId'])
          cookies[:userId] = row['userId']
          @game_state = row['gameState']
          @user_id = row['userId']
          @locale = row['locale']
          @facebookId = row['facebookId']
          @email = row['email']
          @name = URI.decode(row['name'].force_encoding("UTF-8"))
          @level = row['level']
          @isFake = row['isFake']
          @subversion = row['version']
          @isLeaderBoardBlocked = row['isLeaderBoardBlocked']
          @isClanLocked = row['isLocked']
          sDeviceInfo = row['deviceInfo']
          logger.info(sDeviceInfo)
          if sDeviceInfo.length >= 2
            @deviceInfo = JSON.parse(sDeviceInfo)
          else
            @deviceInfo = nil
          end
          # rescue @deviceInfo = JSON.parse('{"deviceModel":"Null","deviceName":"Null","deviceType":"Null"}')
          @isDeleted = row['isDeleted']
          @achievements = row['achievements']
          @clanId = row['clanId']
          @activeId = row['activeId']
          @createdAt = row['createdAtPDT']
          shield = row['shieldActiveTime']
          @trophies = row['trophies']
          @uuserNote = row['userNote']
          if @uuserNote.eql? nil
            @userNote = JSON.parse("{\"Notes\":[{\"Reporter\":\"\", \"Date\":\"0000-01-01T00:00:00-00:00\", \"Note\":\"\"}]}")
          else
            @userNote = JSON.parse(@uuserNote)
          end
          b = Time.at (shield.to_i / 1000)
          times = ((b.utc.to_f * 1000).to_i - (Time.now.utc.to_f * 1000).to_i)/1000 + Time.now.gmt_offset
          if times > 0
            days = times/86400
            hours = (times - 86400*days)/3600
            mins = (times -86400*days - 3600*hours)/60
            if days == 0
              @shieldactive = "#{hours}H:#{mins}M"
            else
              @shieldactive = "#{days}D:#{hours}H:#{mins}M"
            end
          else
            @shieldactive = "0"
          end
        end
        @clanName = ""
        connectLumba
        if !(@clanId.nil?)
          claninfo = @dblumba.query("select name from clan_v#{@sfs_version} where clanId = '#{@clanId}' LIMIT 1")
          claninfo.each_hash do |row|
            @clanName = URI.decode(row['name'].force_encoding("UTF-8"))
          end
        end
        # get user position in tribe
        tribe_pos = 0
        @tribe_position = nil
        if !(@clanId.nil?)
          str_query_trophies_in_clan = "select cll.clanId, cll.userId, um.userId, um.trophies from clanLookup_v#{@sfs_version} cll join userMeta_v#{@sfs_version} um on cll.userId = um.userId where cll.clanId = '#{@clanId}' order by um.trophies desc"
          list_trophies_in_clan = @dblumba.query(str_query_trophies_in_clan)
          list_trophies_in_clan.each_hash do |row|
            tribe_pos = tribe_pos + 1
            if (row['userId'].eql?(@user_id))
              @tribe_position = tribe_pos
            end
          end
        end
        # Check if blocked from searching opponent
        str_query_block_hacker = "select userId, isBlocked, status from BlockHacker where userId = '#{@user_id}' and blockType = 0"
        @isSearchOpponentLocked = 0
        user_blocked = @dblumba.query(str_query_block_hacker)
        user_blocked.each_hash do |row|
          if row['isBlocked'].to_s.eql?("1")
            @isSearchOpponentLocked = 1
          end
        end
        # Check if blocked from being attacked
        str_query_block_hacker = "select userId, isBlocked, status from BlockHacker where userId = '#{@user_id}' and blockType = 2"
        @isBeingAttackedLocked = 0
        user_blocked = @dblumba.query(str_query_block_hacker)
        user_blocked.each_hash do |row|
          if row['isBlocked'].to_s.eql?("1")
            @isBeingAttackedLocked = 1
          end
        end
        # get battleLog
        begin
          battlelog = @dblumba.query("select battleLog from userMeta_v31 where userId = '#{@user_id}' limit 1").fetch_hash['battleLog']
          battleLogJson = JSON.parse(battlelog)
          @defencelog = []
          @attacklog = []
        rescue Exception => e
        end
        begin
          battleLogJson['defense'].each { |row|
            data = row['data']
            data1 = data.gsub /\t/, ''
            datajson = JSON.parse(data1)
            deflog = {}
            deflog['gainedTrophy'] = datajson['gainedTrophy']
            deflog['username'] = URI.decode(datajson['username'])
            deflog['lootTrophy'] = datajson['lootTrophy']
            deflog['opponentName'] = URI.decode(datajson['opponentName'])
            deflog['opponentTrophy'] = datajson['opponentTrophy']
            deflog['createdAt'] = (Time.at(row['created_at'].to_i()/1000) +@timezone.hours).strftime("%Y/%m/%d %H:%M:%S")
            deflog['percentDamage'] = datajson['percentDamage']
            deflog['numStars'] = datajson['numStars']
            deflog['opponentClanId'] = datajson['opponentClanId']
            deflog['opponentClanName'] = URI.decode(datajson['opponentClanName'])
            deflog['userClanId'] = datajson['userClanId']
            deflog['userClanName'] = URI.decode(datajson['userClanName'])
            @defencelog.push(deflog)
          }
        rescue Exception => e
          @defencelog = []
        end
        begin
          battleLogJson['attack'].each { |row|
            data = row['data']

            data1 = data.gsub /\t/, ''
            # puts data1
            datajson = JSON.parse(data1, :quirks_mode => true)
            atklog = {}
            atklog['gainedTrophy'] = datajson['gainedTrophy']
            atklog['username'] = URI.decode(datajson['username'])
            atklog['userTrophy'] = datajson['userTrophy']
            atklog['lootTrophy'] = datajson['lootTrophy']
            atklog['opponentName'] = URI.decode(datajson['opponentName'])
            atklog['opponentTrophy'] = datajson['opponentTrophy']
            atklog['createdAt'] = (Time.at(row['created_at'].to_i()/1000) +@timezone.hours).strftime("%Y/%m/%d %H:%M:%S")
            atklog['percentDamage'] = datajson['percentDamage']
            atklog['numStars'] = datajson['numStars']
            atklog['userClanId'] = datajson['userClanId']
            atklog['userClanName'] = URI.decode(datajson['userClanName'])
            atklog['opponentClanId'] = datajson['opponentClanId']
            atklog['opponentClanName'] = URI.decode(datajson['opponentClanName'])
            @attacklog.push(atklog)
          }
        rescue Exception => e
          @attacklog = []
        end
        # get pending update gamestate
        @pending = @dblumba.query("SELECT * FROM updateFromAdminPanel WHERE userId = '#{@user_id}' AND status = 0 ORDER BY id DESC LIMIT 1")
        @pending.each_hash do |row|
          @pending_name = row['name']
          @pending_email = row['email']
          @pending_locale = row['locale']
          @pending_facebookid = row['facebookId']
          @pending_level = row['level']
          @pending_exp = row['experiencePoint']
          @pending_gold = row['gold']
          @pending_water = row['water']
          @pending_oil = row['oil']
          @pending_pearls = row['pearls']
          @pending_diwanlevel = row['diwanLevel']
          @pending_dagger = row['trophies']
          @pending_isFake = row['isFake']
          shield2 = row['shieldActiveTime']
          b = Time.at (shield2.to_i / 1000)
          times = ((b.utc.to_f * 1000).to_i - (Time.now.utc.to_f * 1000).to_i)/1000 + Time.now.gmt_offset
          if times > 0
            days = times/86400
            hours = (times - 86400*days)/3600
            mins = (times -86400*days - 3600*hours)/60
            if days == 0
              @pending_shield = "#{hours}H:#{mins}M"
            else
              @pending_shield = "#{days}D:#{hours}H:#{mins}M"
            end
          else
            @pending_shield = "0"
          end
        end
        disconnectLumba
        # get purchase info
        connectLumbaIAP
        str_purchase_info = "Select id, diwanLevel, gameLevel, coins, water, oil, pearls, daggers, status, purchasedPearls, purchasedItemId, rateToUSD, paidAmount, currency, country, createdAt as createdAtUtc, CONVERT_TZ(createdAt,'+00:00','#{@timezoneSQL}:00') createdAt, installAt, ipAddress from purchases where userId = '#{@user_id}'"
        @purchase_infos = @dbsfs.query(str_purchase_info)
        @totalmoney = 0
        @validpur = 0
        @prch_infos = []
        Money::Bank::GoogleCurrency.ttl_in_seconds = 3600
        Money.default_bank = Money::Bank::GoogleCurrency.new
        bank = Money::Bank::GoogleCurrency.new
        @purchase_infos.each_hash do |row|
          prch_info = {}
          prch_info['diwanLevel'] = row['diwanLevel']
          prch_info['coins'] = row['coins']
          prch_info['water'] = row['water']
          prch_info['oil'] = row['oil']
          prch_info['pearls'] = row['pearls']
          prch_info['daggers'] = row['daggers']
          prch_info['status'] = row['status']
          prch_info['purchasedPearls'] = row['purchasedPearls']
          prch_info['purchasedItemId'] = row['purchasedItemId']
          prch_info['paidAmount'] = row['paidAmount']
          prch_info['currency'] = row['currency']
          prch_info['id'] = row['id']
          begin
            if !row['rateToUSD'].nil?
              moneyusd = (row['rateToUSD'].to_f * row['paidAmount'].to_f).to_f.round(2)
            else
              moneyusd = (bank.get_rate(row['currency'], :USD).to_f.round(2) * row['paidAmount'].to_f.round(2)).round(2)
            end
          rescue Exception => e
            moneyusd = 0
          end
          prch_info['paidAmountUSD'] = moneyusd
          prch_info['createdAt'] = row['createdAt']
          prch_info['createdAtUtc'] = row['createdAtUtc']
          @prch_infos.push(prch_info)
          if (row['status'].eql?("Valid"))
            @totalmoney = @totalmoney + moneyusd
            @validpur = @validpur + 1
          end
        end
        disconnectLumbaIAP

        user_j = JSON.parse(@game_state)
        if (@achievements.nil?)
          @error_string = "Missing Achievement"
        else
          begin
            achievementArray = JSON.parse(@achievements)
            achievementArray.each do |achie|
              if (achie['type'].nil?)
                @error_string = "chievement missing key: type"
              end
              if (achie['quantity'].nil?)
                @error_string = "chievement missing key: quantity"
              end
              if (achie['level'].nil?)
                @error_string = "chievement missing key: level"
              end
              if (achie['state'].nil?)
                @error_string = "chievement missing key: state"
              end
              puts achie
            end
          rescue Exception => e
            @error_string = "Wrong achievement format"
          end
        end
        # check if gamestate valid or not
        if (user_j['Objects'].nil?)
          @error_string = "Missing Object"
        else
          obj = user_j['Objects']
          type_val = []
          uid_val = []
          tinfo_val = []
          ntiles = 0
          if (!obj.include?("ver"))
            obj.each { |key, value|
              if (key.eql?("nTiles"))
                if (value.nil? || value.to_s.eql?(""))
                  @error_string = "Incorect nTiles in Object"
                else
                  ntiles = value.to_i
                end
              else
                begin
                  if (!key.eql?("wallReferences") && !key.eql?("sk"))
                    if (value['tInfo'].size != 6)
                      @error_string = "Some tInfo size is not equal 6"
                    end
                    if !(value['uId'].instance_of? String)
                      @error_string = "Some uId is not String type"
                    end
                    if !(value['type'].respond_to?(:to_i))
                      @error_string = "Some type is not int type"
                    end
                    type_val.push(value['type'])
                    uid_val.push(value['uId'])
                    tinfo_val.push(value['tInfo'])
                  end
                rescue Exception => e
                  @error_string = "Some tiles are not json format"
                end
              end
          }
            if (type_val.size != ntiles)
              @error_string = "Missing type in Object"
            end
            if (uid_val.size != ntiles)
              @error_string = "Missing uid in Object"
            end
            if (tinfo_val.size != ntiles)
              @error_string = "Missing tinfo in Object"
            end
          else
            obj.each { |key, value|
              if (key.eql?("bds"))
                value.each { |lon|
                  lon.each{ |bdskey, bdsvalue|
                    if (bdskey.eql?("ty"))
                      type_val.push(bdsvalue)
                    end
                  }
                }
              end
            }
          end
          if !(type_val.include? 19)
            @error_string = "Missing type 19 (building)"
          elsif !(type_val.include? 27)
            @error_string = "Missing type 27 (building)"
          elsif !(type_val.include? 24)
            @error_string = "Missing type 24 (building)"
          elsif !(type_val.include? 28)
            @error_string = "Missing type 28 (building)"
          elsif !(type_val.include? 13)
            @error_string = "Missing type 13 (building)"
          end
        end
        if (user_j['HUD'].nil?)
          @error_string = "Missing HUD"
        elsif (user_j['HUD']['shieldActiveTime'].nil?)
          @error_string = "Missing shieldActiveTime in HUD"
        elsif (user_j['HUD']['hInfo'].nil?)
          @error_string = "Missing hInfo in HUD"
        elsif (user_j['HUD']['hInfo'].size != 7)
          @error_string = "Wrong hInfo size"
        elsif (user_j['HUD']['trophies'].nil?)
          @error_string = "Missing trophies in HUD"
        end
        if (!user_j['clanUnits'].nil?)
          if (user_j['clanUnits']['cap'].nil?)
            @error_string = "Missing cap in clanUnits"
          elsif (user_j['clanUnits']['occupied'].nil?)
            @error_string = "Missing occupied in clanUnits"
          else
            if !(user_j['clanUnits']['cap'].respond_to?(:to_i))
              @error_string = "cap field is not int type"
            elsif !(user_j['clanUnits']['occupied'].respond_to?(:to_i))
              @error_string = "occupied field is not int type"
            else
              if (user_j['clanUnits']['cap'].to_i < user_j['clanUnits']['occupied'].to_i)
                @error_string = "occupied is bigger than cap"
              end
            end
          end
        end
        if !@game_state.nil?
          @user_json = JSON.parse(@game_state)
          @game_level = @user_json['HUD']['hInfo']
          #@trophies = @user_json['HUD']['trophies']
          @settings = @user_json['Settings']
          #@object = @user_json['Objects']
          @balancer_version = get_balancer_version_from_sfs_version(@sfs_version)

          # get history
          connectLumbaAppData
          @updatelumba_history = @db.query("select userChange, action, FromName, ToName, FromLocal, ToLocal, FromLevel, ToLevel, FromExPoint, ToExPoint, FromGold, ToGold, FromWater, ToWater, FromOil, ToOil, FromPearls, ToPearls, FromDiwanLevel, ToDiwanLevel, FromDagger, ToDagger, FromShield, ToShield, CONVERT_TZ(lastMod,'+00:00','#{@timezoneSQL}:00') createdAtPDT from update_GameState where userId = '#{@user_id}' ORDER BY pkID DESC")
          disconnectLumbaAppData
          # get bluebox or not
          connectLumbaIAP
          begin
            @isBlueBox = ""
            # @isBlueBox = @dbsfs.query("select isBlueBox from activeUsers where userId = '#{@user_id}' order by createdAt desc limit 1").fetch_hash['isBlueBox']
            @lastLoginTime = @dbsfs.query("select CONVERT_TZ(login,'+00:00','#{@timezoneSQL}:00') createdAtPDT from activeUsers_v31 where userId = '#{@user_id}' order by id desc limit 1").fetch_hash['createdAtPDT']
            if @isBlueBox.nil?
              @isBlueBox = @dbsfs.query("select isBlueBox from activeUsers where userId = '#{@user_id}' order by createdAt desc limit 1").fetch_hash['isBlueBox']
            end
            if @lastLoginTime.nil?
              @lastLoginTime = @dbsfs.query("select CONVERT_TZ(createdAt,'+00:00','#{@timezoneSQL}:00') createdAtPDT from activeUsers where userId = '#{@user_id}' order by createdAt desc limit 1").fetch_hash['createdAtPDT']
            end
          rescue Exception => e
            @isBlueBox = ""
          end
          disconnectLumbaIAP
        end
        if @activeId.to_i !=-1
          connectLumba
          @activeId = @dblumba.query("SELECT CASE WHEN lastOfflineTime > lastOnlineTime THEN -1 ELSE 1 END as 'active' FROM lumba.userMeta_v31 WHERE userId = '#{@user_id}'").fetch_hash['active']
          disconnectLumba
        end
      end
      `sync && echo 3 > /proc/sys/vm/drop_caches`
     rescue Exception => e
       disconnectLumba
       my_logger_lumba.info("+++++++++++++++++++++++++++#{e.to_s}")
       logger.info("Exception : #{e.to_s}")
       @error_string = "User Not Found"
    end
  end

  def getuserdetail(userId)
    @user_detail = @dblumba.query("select u.userId, u.userNote, u.isFake, u.email, u.name, u.locale, u.facebookId, CONVERT_TZ(u.createdAt,'+00:00','#{@timezoneSQL}:00') createdAtPDT, u.isDeleted, u.isLeaderBoardBlocked, um.shieldActiveTime, um.level, um.trophies, um.attacksWon, um.defensesWon, um.achievements, um.activeId, um.deviceInfo, um.deviceId, um.platform, ugs.version, ugs.gameState, cl.isLocked, cl.clanId from user_v#{@sfs_version} u join userMeta_v#{@sfs_version} um on u.userId = um.userId join userGameState_v#{@sfs_version} ugs on u.userId = ugs.userId join clanLookup_v#{@sfs_version} cl on u.userId = cl.userId where u.userId = '#{userId}' LIMIT 1")
  end

  def getgamestatehistory(prodUserId, timeupdate, enddate)
    gamestatehistory = @dbsfs.query("select gameState, createdAt, CONVERT_TZ(createdAt,'+00:00','#{@timezoneSQL}:00') createdAtPDT from oldGameState where userId = '#{prodUserId}' and createdAt = '#{timeupdate}'")
    if !gamestatehistory.nil?
      gamestatehistory.each_hash do |row|
        timeupdate = row['createdAt']
        game_state = JSON.parse(row['gameState'])
        units = game_state['Units']['unitLevel']
        hinfo = game_state['HUD']['hInfo']
        @csvfile << [hinfo[0], hinfo[1], hinfo[2], hinfo[3], hinfo[4], hinfo[5], hinfo[6], game_state['HUD']['trophies'], "#{row['createdAtPDT']}", timeupdate]
      end
      createdAtNextresult = @dbsfs.query("select createdAt from oldGameState where userId = '#{prodUserId}' and createdAt > '#{timeupdate}' and createdAt < '#{enddate}' limit 1")
      if !createdAtNextresult.nil?
        createdAtNextresult.each_hash do |row|
          createdAtNext = row['createdAt']
          getgamestatehistory(prodUserId, createdAtNext, enddate)
        end
      end
    end
  end

  # show datagrid
  def show_pearls_history
    current_user_name = cookies[:login_username]
    connectLumbaAppData2
    @admin_users = @dbsfs2.query("SELECT * FROM users WHERE username = '#{current_user_name}'")
    disconnectLumbaAppData2
    user_timezone = ''
    @admin_users.each do |row|
      user_timezone = row["timezone"]
    end
    @timezone = (user_timezone.delete 'GMT').to_i
    @userid_common = cookies[:userId]
    puts 'show_pearls_history|id|' + "#{@userid_common}"
    respond_to do |format|
      format.html # show.html.erb
      # With the data grid, we need to render Json data
      format.js do
        # What is the first line of the result set we want ? (due to pagination. 0 = first)
        offset = (params["page"].to_i-1)*params["rp"].to_i if params["page"] and params["rp"]
        # get count
        connectLumbaIAP2
        sql = "select count(*) as total from resourceHistory where userId = '#{@userid_common}'"
        # puts sql
        lumba_history = @dbsfs2.query(sql)
        disconnectLumbaIAP2
        # people = Person.where(conditions)
        total= 0
        # Total count of lines, before paginating
        lumba_history.each do |row|
          total = row["total"]
        end

        connectLumbaIAP2
        sql = "select actionChange,resourceType,amounts,rest,info,createdAt,createdAt as createdAtPDT from resourceHistory where userId = '#{@userid_common}' ORDER BY id DESC LIMIT #{params["rp"]} OFFSET #{offset}"
        puts sql
        lumba_history = @dbsfs2.query(sql, :as => :array)
        disconnectLumbaIAP2
        # Rendering
        return_data = Hash.new()
        array_data = Array.new()
        lumba_history.each do |row|
          row[1] = "pearls"
          row[6] = row[6].strftime("%Y/%m/%d %H:%M:%S")
          row[5] = (row[5] +@timezone.hours).strftime("%Y/%m/%d %H:%M:%S")
          array_data.push(:cell=>row)
        end
        return_data[:rows] = array_data
        return_data[:page] = params["page"]
        return_data[:total] = total
        render :json => return_data.to_json
      end #format.js
    end #respond_to
  end

  def show_lumba_history
    current_user_name = cookies[:login_username]
    connectLumbaAppData2
    @admin_users = @dbsfs2.query("SELECT * FROM users WHERE username = '#{current_user_name}'")
    disconnectLumbaAppData2
    user_timezone = ''
    @admin_users.each do |row|
      user_timezone = row["timezone"]
    end
    @timezone = (user_timezone.delete 'GMT').to_i
    @userid_common = cookies[:userId]
    puts 'id = ' + "#{@userid_common}"

    respond_to do |format|
      format.html # show.html.erb
      # format.xml  { render :xml => Person.all }

      # With the data grid, we need to render Json data
      format.js do
        # What is the first line of the result set we want ? (due to pagination. 0 = first)
        offset = (params["page"].to_i-1)*params["rp"].to_i if params["page"] and params["rp"]
        connectLumbaAppData2
        sql = "select count(*) as total from update_GameState where userId = '#{@userid_common}'"
        lumba_history = @dbsfs2.query(sql)
        logger.info(sql)
        disconnectLumbaAppData2

        total= 0
        # Total count of lines, before paginating
        lumba_history.each do |row|
          total = row["total"]
        end

        connectLumbaAppData2
        sql = "select userChange,action,FromEmail,ToEmail,PwdChange,FromName,ToName,NameChangeReason,FromLocal,ToLocal,LocalChangeReason,FromLevel,ToLevel,LevelChangeReason,FromExPoint,ToExPoint,ExPointChangeReason,FromGold,ToGold,GoldChangeReason,FromWater,ToWater,WaterChangeReason,FromOil,ToOil,OilChangeReason,FromPearls,ToPearls,PearlsChangeReason,FromDiwanLevel,ToDiwanLevel,DiwanLevelChangeReason,FromDagger,ToDagger,DaggerChangeReason,FromShield,ToShield, lastMod, lastMod as PDT from update_GameState where userId = '#{@userid_common}' ORDER BY pkID DESC LIMIT #{params["rp"]} OFFSET #{offset}"
        logger.info(sql)
        lumba_history = @dbsfs2.query(sql, :as => :array)
        disconnectLumbaAppData2
        # Rendering
        return_data = Hash.new()
        array_data = Array.new()
        lumba_history.each do |row|
          # puts Time.at(row[24].to_i()/1000) -7.hours
          row[38] = (row[38] +@timezone.hours).strftime("%Y/%m/%d %H:%M:%S")
          row[37] = (row[37].strftime("%Y/%m/%d %H:%M:%S"))
          array_data.push(:cell => row)
        end
        return_data[:rows] = array_data
        return_data[:page] = params["page"]
        return_data[:total] = total
        render :json => return_data.to_json
      end #format.js
    end #respond_to
  end

  #show_lumba_history
  def list_user
    @userid_common = cookies[:userId]
    @name_search = cookies[:name_search]
    @trophies_search = cookies[:trophies_search]
    respond_to do |format|
      format.html # show.html.erb
      # With the data grid, we need to render Json data
      format.js do
        # What is the first line of the result set we want ? (due to pagination. 0 = first)
        offset = (params["page"].to_i-1)*params["rp"].to_i if params["page"] and params["rp"]
        # get count
        connectLumba
        if !@trophies_search.nil?
          sql = "select COUNT(u.userId) as total from user_v31 u join userMeta_v31 um on u.userId = um.userId where u.name like '%#{@name_search}%' and um.trophies = #{@trophies_search}"
        else
          sql = "select COUNT(userId) as total from user_v31 where name like '%#{@name_search}%'"
        end
        # puts sql
        logger.info(sql)
        total = @dblumba.query(sql).fetch_hash('total')
        disconnectLumba
        logger.info(total['.total'])
        # people = Person.where(conditions)
        # total= 0
        # Total count of lines, before paginating
        # lumba_history.each do |row|
        #   total = row["total"]
        # end

        connectLumba2
        if !@trophies_search.nil?
          sql = "select u.userId, u.name, u.email, um.trophies from user_v31 u join userMeta_v31 um on u.userId = um.userId where u.name like '%#{@name_search}%' and um.trophies = #{@trophies_search} ORDER BY um.trophies DESC LIMIT #{params["rp"]} OFFSET #{offset}"
        else
          sql = "select u.userId, u.name, u.email, um.trophies from user_v31 u join userMeta_v31 um on u.userId = um.userId where u.name like '%#{@name_search}%' ORDER BY um.trophies DESC LIMIT #{params["rp"]} OFFSET #{offset}"
        end
        puts sql
        lumba_history = @dblumba2.query(sql, :as => :array)
        disconnectLumba2
        # Rendering
        return_data = Hash.new()
        array_data = Array.new()
        lumba_history.each do |row|
          row.push('<form action="/lumba/gamestate/user_details" method="post">
                <input type="hidden" name="userid_detail" value="'+row[0]+'">
                <input type="hidden" name="sfs_version" value="31">
                <input name="commit" type="submit" value="Detail">
              </form>')
          array_data.push(:cell=>row)
        end

        return_data[:rows] = array_data
        return_data[:page] = params["page"]
        return_data[:total] = total['.total']
        render :json => return_data.to_json
      end #format.js
    end #respond_to

  end
  # highlight
  def color_tr_if(condition, attributes = {})
    if condition
      attributes = "class = 'highlight'"
    else
      attributes = ""
    end
    "#{attributes}".html_safe
    # content_tag("", attributes, &block)
  end

  # show data if it's not zero
  def show_span_if(condition)
    if !condition.nil?
      content_tag(:span, "(#{condition})", :style => 'color:red')
    end
  end

  def convertShieldTime(shield)
    b = Time.at (shield.to_i / 1000)
    times = ((b.utc.to_f * 1000).to_i - (Time.now.utc.to_f * 1000).to_i)/1000 + Time.now.gmt_offset
    if times > 0
      days = times/86400
      hours = (times - 86400*days)/3600
      mins = (times -86400*days - 3600*hours)/60
      if days == 0
        @shieldactive = "#{hours}H:#{mins}M"
      else
        @shieldactive = "#{days}D:#{hours}H:#{mins}M"
      end
    else
      @shieldactive = "0"
    end
    return @shieldactive
  end
end