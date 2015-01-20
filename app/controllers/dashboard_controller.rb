require 'zip/zip'
require 'rubygems'
require 'simple_xlsx' #gem install simple_xlsx_writer

class DashboardController < ApplicationController
  before_filter :login_required
  skip_before_filter :verify_authenticity_token, :only => [:index]
  @selectedmenu = "dashBoard"

  def index
    if (params[:newplayinguser])
      #connectLumbaIAP
      connectdb
      starttime = Time.parse("#{params[:daustartdate]}").utc
      endtime = Time.parse("#{params[:dauenddate]}").utc
      category = params[:category]
      # get date array
      datearr = (Date.parse(params[:daustartdate]) .. Date.parse(params[:dauenddate])).to_a
      if session[:googleacount].nil?
        logger.info("vao googlesession nil")
        session[:googleacount] = GoogleDrive.login("dashboard@lum.ba", "181fremont")
      end
      session[:googleacount] = GoogleDrive.login("dashboard@lum.ba", "181fremont")
      title_googlespreadsheet = ""
      CSV.open("#{Rails.root}/exportedfile/activeuser/newplayinguser.txt", "w:ASCII-8BIT:UTF-8", {:col_sep => "\t"}) { |csv|
        if params[:timetocheck].eql?("0")
          csv << ["Date (PDT)", "New Playing User"]
        else
          csv << ["Date (UTC)", "New Playing User"]
        end
        datearr.each { |n|
          startday = "#{n} 00:00:00 -07:00"
          if params[:timetocheck].eql?("1")
            startday = "#{n} 00:00:00 +00:00"
          end
          startdayutc = Time.parse(startday).utc
          endday = "#{n} 23:59:59 -07:00"
          if params[:timetocheck].eql?("1")
            endday = "#{n} 23:59:59 +00:00"
          end
          enddayutc = Time.parse(endday).utc
          if (category.to_s.eql? "0")
            logger.info ("category 0")
            title_googlespreadsheet = "New playing user total in #{params[:daustartdate]} - #{params[:dauenddate]}"
            str_query = "select count(userId) totalnewplaying from lumba.user_v31 where createdAt >= '#{startdayutc}' and createdAt <= '#{enddayutc}'"
            totalnewplaying = @dbgeneral.query(str_query).fetch_hash['totalnewplaying']
            csv << ["#{startday} - #{endday}", totalnewplaying]
          else
            market = ""
            platform = ""
            if category.to_s.eql? "1" #ios/en
              logger.info ("category 1")
              title_googlespreadsheet = "New playing user IOS English in #{params[:daustartdate]} - #{params[:dauenddate]}"
              market = "en"
              platform = "ios"
            elsif category.to_s.eql? "2" # ios arab
              title_googlespreadsheet = "New playing user IOS Arabic in #{params[:daustartdate]} - #{params[:dauenddate]}"
              logger.info ("category 2")
              market = "ar"
              platform = "ios"
            elsif category.to_s.eql? "3" # andr english
              title_googlespreadsheet = "New playing user Android English in #{params[:daustartdate]} - #{params[:dauenddate]}"
              logger.info ("category 3")
              market = "en"
              platform = "android"
            elsif category.to_s.eql? "4" # andr arab
              title_googlespreadsheet = "New playing user Android Arabic in #{params[:daustartdate]} - #{params[:dauenddate]}"
              logger.info ("category 4")
              market = "ar"
              platform = "android"
            end
            str_query = "select count(*) totalnewplaying from (Select t1.userId from lumba.user_v31 t1 left join lumba.userMeta_v31 um3 on t1.userId = um3.userId where t1.market ='#{market}' and um3.platform = '#{platform}' and t1.createdAt >= '#{startdayutc}' and t1.createdAt <= '#{enddayutc}') as a"
            totalnewplaying = @dbgeneral.query(str_query).fetch_hash['totalnewplaying']
            csv << ["#{startday} - #{endday}", totalnewplaying]
          end
        }
      }
      #disconnectLumbaIAP
      disconnectdb
      a = session[:googleacount].upload_from_file("#{Rails.root}/exportedfile/activeuser/newplayinguser.txt", title_googlespreadsheet, :content_type => "text/tab-separated-values")
      a.acl.push({:scope_type => "user", :scope => "tr-support@lum.ba", :role => "writer"})
      logger.info(a.inspect)
      url = a.human_url()
      @error_string = url
    end

    if (params[:dailyactiveuser])
      #connectLumbaIAP
      connectdb
      starttime = Time.parse("#{params[:daustartdate]}").utc
      endtime = Time.parse("#{params[:dauenddate]}").utc
      category = params[:category]
      # get date array
      datearr = (Date.parse(params[:daustartdate]) .. Date.parse(params[:dauenddate])).to_a
      if session[:googleacount].nil?
        logger.info("vao googlesession nil")
        session[:googleacount] = GoogleDrive.login("dashboard@lum.ba", "181fremont")
      end
      title_googlespreadsheet = ""
      CSV.open("#{Rails.root}/exportedfile/activeuser/dailyactiveuser.txt", "w:ASCII-8BIT:UTF-8", {:col_sep => "\t"}) { |csv|
        if params[:timetocheck].eql?("0")
          csv << ["Date (PDT)", "DAU"]
        else
          csv << ["Date (UTC)", "DAU"]
        end
        datearr.each { |n|
          startday = "#{n} 00:00:00 -07:00"
          if params[:timetocheck].eql?("1")
            startday = "#{n} 00:00:00 +00:00"
          end
          startdayutc = Time.parse(startday).utc
          endday = "#{n} 23:59:59 -07:00"
          if params[:timetocheck].eql?("1")
            endday = "#{n} 23:59:59 +00:00"
          end
          enddayutc = Time.parse(endday).utc
          if (category.to_s.eql? "0")
            logger.info ("category 0")
            title_googlespreadsheet = "Active user Total in #{params[:daustartdate]} - #{params[:dauenddate]}"
            str_query_v31 = "select count(distinct userId) DAU from lumba_iap.activeUsers_v31 where login > '#{startdayutc}' and login <= '#{enddayutc}'"
            dauresult_v31 = @dbgeneral.query(str_query_v31).fetch_hash['DAU']
            dauresult = dauresult_v31.to_i
            csv << ["#{startday} - #{endday}", dauresult]
          else
            market = ""
            platform = ""
            if category.to_s.eql? "1" #ios/en
              logger.info ("category 1")
              title_googlespreadsheet = "Active user IOS English in #{params[:daustartdate]} - #{params[:dauenddate]}"
              market = "en"
              platform = "ios"
            elsif category.to_s.eql? "2" # ios arab
              title_googlespreadsheet = "Active user IOS Arabic in #{params[:daustartdate]} - #{params[:dauenddate]}"
              logger.info ("category 2")
              market = "ar"
              platform = "ios"
            elsif category.to_s.eql? "3" # andr english
              title_googlespreadsheet = "Active user Android English in #{params[:daustartdate]} - #{params[:dauenddate]}"
              logger.info ("category 3")
              market = "en"
              platform = "android"
            elsif category.to_s.eql? "4" # andr arab
              title_googlespreadsheet = "Active user Android Arabic in #{params[:daustartdate]} - #{params[:dauenddate]}"
              logger.info ("category 4")
              market = "ar"
              platform = "android"
            end
            str_query = "select count(distinct t1.userId) DAU from lumba_iap.activeUsers_v31 t1 left join lumba.user_v30 u on t1.userId = u.userId left join lumba.user_v29 u1 on t1.userId = u1.userId left join lumba.user_v31 u2 on t1.userId = u2.userId left join lumba.userMeta_v29 um1 on t1.userId = um1.userId left join lumba.userMeta_v30 um2 on t1.userId = um2.userId left join lumba.userMeta_v31 um3 on t1.userId = um3.userId  where t1.action = 'login' and t1.createdAt > '#{startdayutc}' and t1.createdAt <= '#{enddayutc}' and (u.market ='#{market}' or u1.market = '#{market}' or u2.market = '#{market}') and (um1.platform = '#{platform}' or um2.platform = '#{platform}' or um3.platform = '#{platform}')"
            dauresult = @dbgeneral.query(str_query).fetch_hash['DAU']
            csv << ["#{startday} - #{endday}", dauresult]
          end
        }
      }
      #disconnectLumbaIAP
      disconnectdb
      a = session[:googleacount].upload_from_file("#{Rails.root}/exportedfile/activeuser/dailyactiveuser.txt", title_googlespreadsheet, :content_type => "text/tab-separated-values")
      a.acl.push({:scope_type => "user", :scope => "tr-support@lum.ba", :role => "writer"})
      logger.info(a.inspect)
      url = a.human_url()
      @error_string = url
    end
=begin
    if (params[:monthlyactive])
      #connectLumbaIAP
      connectdb
      month = params[:monthactive]
      logger.info("month from: #{params[:monthfrom]}-01")
      logger.info("month to: #{params[:monthto]}-01")
      dayrange = ( Date.parse("#{params[:monthfrom]}-01") .. Date.parse("#{params[:monthto]}-01") ).to_a
      date_months = dayrange.map {|d| Date.new(d.year, d.month, 1) }.uniq
      montharr = []
      category = params[:category]
      date_months.map {|d| montharr.push(d.strftime "%Y-%m") }
      CSV.open("#{Rails.root}/exportedfile/activeuser/monthlyactiveuser.txt", "w:ASCII-8BIT:UTF-8", {:col_sep => "\t"}) { |csv|        csv << ["Month (PDT)", "MAU"]
        montharr.each { |month|
          startmonth = "#{month}-01 00:00:00 -07:00"
          if params[:timetocheck].eql?("1")
            startmonth = "#{month}-01 00:00:00 +00:00"
          end
          startmonthutc = Time.parse(startmonth).utc
          endmonth = "#{month}-31 23:59:59 -07:00"
          if params[:timetocheck].eql?("1")
            endmonth = "#{month}-31 23:59:59 +00:00"
          end
          endmonthutc = Time.parse(endmonth).utc
          if (category.to_s.eql?"0")
            logger.info ("category 0")
            title_googlespreadsheet = "Active user total in month #{params[:monthactive]}"
            str_query = "select count(distinct userId) MAU from lumba_iap.activeUsers where action = 'login' and createdAt > '#{startmonthutc}' and createdAt <= '#{endmonthutc}'"
            mauresult = @dbgeneral.query(str_query).fetch_hash['MAU']
            csv << ["#{month}", mauresult]
          else
            market = ""
            platform = ""
            if category.to_s.eql?"1"  #ios/en
              logger.info ("category 1")
              title_googlespreadsheet = "Active user IOS English in month #{params[:monthfrom]} - #{params[:monthto]}"
              market = "en"
              platform = "ios"
            elsif category.to_s.eql?"2" # ios arab
              title_googlespreadsheet = "Active user IOS Arabic in month #{params[:monthfrom]} - #{params[:monthto]}"
              logger.info ("category 2")
              market = "ar"
              platform = "ios"
            elsif category.to_s.eql?"3" # andr english
              title_googlespreadsheet = "Active user Android English in month #{params[:monthfrom]} - #{params[:monthto]}"
              logger.info ("category 3")
              market = "en"
              platform = "andr"
            elsif category.to_s.eql?"4" # andr arab
              title_googlespreadsheet = "Active user Android Arabic in month #{params[:monthfrom]} - #{params[:monthto]}"
              logger.info ("category 4")
              market = "ar"
              platform = "android"
            end
            str_query = "select count(distinct t1.userId) MAU from lumba_iap.activeUsers t1 left join lumba.user_v30 u on t1.userId = u.userId left join lumba.user_v29 u1 on t1.userId = u1.userId left join lumba.user_v31 u2 on t1.userId = u2.userId left join lumba.userMeta_v29 um1 on t1.userId = um1.userId left join lumba.userMeta_v30 um2 on t1.userId = um2.userId left join lumba.userMeta_v31 um3 on t1.userId = um3.userId  where t1.action = 'login' and t1.createdAt > '#{startmonthutc}' and t1.createdAt <= '#{endmonthutc}' and (u.market ='#{market}' or u1.market = '#{market}' or u2.market = '#{market}') and (um1.platform = '#{platform}' or um2.platform = '#{platform}' or um3.platform = '#{platform}')"
            mauresult = @dbgeneral.query(str_query).fetch_hash['MAU']
            csv << ["#{month}", mauresult]
          end
        }
      }
      #disconnectLumbaIAP
      disconnectdb
      if session[:googleacount].nil?
        logger.info("vao googlesession nil")
        session[:googleacount] = GoogleDrive.login("dashboard@lum.ba", "181fremont")
      end
      a = session[:googleacount].upload_from_file("#{Rails.root}/exportedfile/activeuser/monthlyactiveuser.txt", title_googlespreadsheet, :content_type => "text/tab-separated-values")
      a.acl.push({:scope_type => "user", :scope => "tr-support@lum.ba", :role => "writer"})
      url = a.human_url()
      @error_string = url
    end
=end
    if (params[:monthlyactive])
      d_endmonth = Date.parse(params[:datemonthto])
      d_startmonth = (d_endmonth<<1)
      startmonth = "#{d_startmonth} 00:00:00 -07:00"
      endmonth = "#{d_endmonth} 23:59:59 -07:00"
      logger.info("1")
      if params[:timetocheck].eql?("1")
        startmonth = "#{d_startmonth} 00:00:00 +00:00"
      end
      if params[:timetocheck].eql?("1")
        endmonth = "#{d_endmonth} 00:00:00 +00:00"
      end
      startmonthutc = Time.parse(startmonth).utc
      endmonthutc = Time.parse(endmonth).utc
      connectdb
      logger.info("2")
      str_query_mau_v31 = "select count(distinct userId) MAU from lumba_iap.activeUsers_v31 where login > '#{startmonthutc}' and login <= '#{endmonthutc}'"
      mauresult_v31 = @dbgeneral.query(str_query_mau).fetch_hash['MAU']
      mauresult = mauresult_v31.to_i
      logger.info("3")
      CSV.open("#{Rails.root}/exportedfile/activeuser/monthlyactiveuser.txt", "w:ASCII-8BIT:UTF-8", {:col_sep => "\t"}) { |csv|
        csv << ["Startday", "Endday", "MAU"]
        csv << ["#{startmonth}", "#{endmonth}", mauresult]

      }
      disconnectdb
      if session[:googleacount].nil?
        logger.info("vao googlesession nil")
        session[:googleacount] = GoogleDrive.login("dashboard@lum.ba", "181fremont")
      end
      a = session[:googleacount].upload_from_file("#{Rails.root}/exportedfile/activeuser/monthlyactiveuser.txt", title_googlespreadsheet, :content_type => "text/tab-separated-values")
      a.acl.push({:scope_type => "user", :scope => "tr-support@lum.ba", :role => "writer"})
      url = a.human_url()
      @error_string = url
    end
    # CCU
    if (params[:ccuview])
      title_googlespreadsheet = "CCU from #{params[:ccustartdate]} to #{params[:ccuenddate]}"
      sfsversions = YAML.load_file("#{Rails.root}/config/sfsversions.yml")
      sfsvers = sfsversions['sfs_version'].split(",")
      starttime = Time.parse("#{params[:ccustartdate]}").utc
      endtime = Time.parse("#{params[:ccuenddate]}").utc
      connectLumba
      CSV.open("#{Rails.root}/exportedfile/ccu/ccu.txt", "w:ASCII-8BIT:UTF-8", {:col_sep => "\t"}) { |csv|
        csv << ["ServerIp", "CCU", "CreatedAt (PDT)", "CreatedAt (UTC)"]
        sfsvers.each { |sfsver|
          str_query = "select serverIp, version, ccu, sfsVersion, CONVERT_TZ(createdAt,'+00:00','-07:00') createdAt, createdAt as createdAtUTC from stats where createdAt > '#{starttime}' and createdAt < '#{endtime}'"
          ccuResult = @dblumba.query(str_query)
          ccuResult.each_hash do |row|
            csv << [row['serverIp'], row['ccu'], row['createdAt'], row['createdAtUTC']]
          end
        }
      }
      disconnectLumba
      if session[:googleacount].nil?
        logger.info("vao googlesession nil")
        session[:googleacount] = GoogleDrive.login("dashboard@lum.ba", "181fremont")
      end
      a = session[:googleacount].upload_from_file("#{Rails.root}/exportedfile/ccu/ccu.txt", title_googlespreadsheet, :content_type => "text/tab-separated-values")
      a.acl.push({:scope_type => "user", :scope => "tr-support@lum.ba", :role => "writer"})
      url = a.human_url()
      @error_string = url
    end

    # CCU view from time
    if (params[:ccufromtime])
      title_googlespreadsheet = "CCU from #{params[:ccustartdatetime]} to previous 24 hours"
      sfsversions = YAML.load_file("#{Rails.root}/config/sfsversions.yml")
      sfsvers = sfsversions['sfs_version'].split(",")
      starttime = Time.parse("#{params[:ccustartdatetime]}").utc
      toprevtime = starttime - 24*60*60
      connectLumba
      CSV.open("#{Rails.root}/exportedfile/ccu/ccuin24h.txt", "w:ASCII-8BIT:UTF-8", {:col_sep => "\t"}) { |csv|
        csv << ["ServerIp", "CCU", "CreatedAt (PDT)", "CreatedAt (UTC)"]
        sfsvers.each { |sfsver|
          str_query = "select serverIp, version, ccu, sfsVersion, CONVERT_TZ(createdAt,'+00:00','-07:00') createdAt, createdAt as createdAtUTC from stats where createdAt > '#{toprevtime}' and createdAt < '#{starttime}'"
          ccuResult = @dblumba.query(str_query)
          ccuResult.each_hash do |row|
            csv << [row['serverIp'], row['ccu'], row['createdAt'], row['createdAtUTC']]
          end
        }
      }
      disconnectLumba
      if session[:googleacount].nil?
        logger.info("vao googlesession nil")
        session[:googleacount] = GoogleDrive.login("dashboard@lum.ba", "181fremont")
      end
      a = session[:googleacount].upload_from_file("#{Rails.root}/exportedfile/ccu/ccuin24h.txt", title_googlespreadsheet, :content_type => "text/tab-separated-values")
      url = a.human_url()
      @error_string = url
    end


    # User Action
    if (params[:useractionview])
      title_googlespreadsheet = "User action from #{params[:useractionstartdate]} to #{params[:useractionenddate]}"
      starttime = Time.parse("#{params[:useractionstartdate]}").utc
      endtime = Time.parse("#{params[:useractionenddate]}").utc
      connectLumbaIAP
      str_query_activeuser = "select userId, login, logout, CONVERT_TZ(createdAt,'+00:00','-07:00') createdAt, createdAt as createdAtUTC from activeUsers_v31 where createdAt > '#{starttime}' and createdAt < '#{endtime}' and userId = '#{params[:userid]}'"
      activeuser_result = @dbsfs.query(str_query_activeuser)
      if File.exist?("#{Rails.root}/exportedfile/ccu/activeuser.xlsx")
        `rm #{Rails.root}/exportedfile/ccu/activeuser.xlsx`
      end
      CSV.open("#{Rails.root}/exportedfile/ccu/activeuser.txt", "w:ASCII-8BIT:UTF-8", {:col_sep => "\t"}) { |csv|
        csv << ["UserId", "Login", "Logout", "CreatedAt (PDT)", "CreatedAt (UTC)"]
        activeuser_result.each_hash { |row|
          csv << [row['userId'], row['login'], row['logout'], row['createdAt'], row['createdAtUTC']]
        }
      }
      disconnectLumbaIAP
      if session[:googleacount].nil?
        logger.info("vao googlesession nil")
        session[:googleacount] = GoogleDrive.login("dashboard@lum.ba", "181fremont")
      end
      a = session[:googleacount].upload_from_file("#{Rails.root}/exportedfile/ccu/activeuser.txt", title_googlespreadsheet, :content_type => "text/tab-separated-values")
      a.acl.push({:scope_type => "user", :scope => "tr-support@lum.ba", :role => "writer"})
      url = a.human_url()
      @error_string = url
    end
    # Global Chat
    if (params[:globalchatview])
      title_googlespreadsheet = "Global chat from #{params[:globalchatstartdate]} to #{params[:globalchatenddate]}"
      sfsversions = YAML.load_file("#{Rails.root}/config/sfsversions.yml")
      sfsvers = sfsversions['sfs_version'].split(",")
      starttime = Time.parse("#{params[:globalchatstartdate]}").utc
      endtime = Time.parse("#{params[:globalchatenddate]}").utc
      connectLumba
      CSV.open("#{Rails.root}/exportedfile/chat/globalchat.txt", "w:ASCII-8BIT:UTF-8", {:col_sep => "\t"}) { |csv|
        csv << ["userId", "UserName", "Room name", "Chat messages", "Time (PT)", "Time (UTC)"]
        sfsvers.each { |sfsver|
          str_query = "select gc.userId, u.name, gc.roomName, gc.message, CONVERT_TZ(gc.createdAt,'+00:00','-07:00') createdAt, gc.createdAt as createdAtUTC from globalChat_v#{sfsver} gc join user_v#{sfsver} u on gc.userId = u.userId where gc.createdAt > '#{starttime}' and gc.createdAt < '#{endtime}' order by roomName"
          logger.info(str_query)
          chatResult = @dblumba.query(str_query)
          chatResult.each_hash do |row|
            csv << [row['userId'], row['name'], row['roomName'], "'#{row['message']}", row['createdAt'], row['createdAtUTC']]
          end
        }
      }
      disconnectLumba
      if session[:googleacount].nil?
        logger.info("vao googlesession nil")
        session[:googleacount] = GoogleDrive.login("dashboard@lum.ba", "181fremont")
      end
      a = session[:googleacount].upload_from_file("#{Rails.root}/exportedfile/chat/globalchat.txt", title_googlespreadsheet, :content_type => "text/tab-separated-values")
      a.acl.push({:scope_type => "user", :scope => "tr-support@lum.ba", :role => "writer"})
      url = a.human_url()
      @error_string = url
    end
    # Tribe Chat
    if (params[:tribechatview])
      title_googlespreadsheet = "Tribe chat from #{params[:globalchatstartdate]} to #{params[:globalchatenddate]}"
      sfsversions = YAML.load_file("#{Rails.root}/config/sfsversions.yml")
      sfsvers = sfsversions['sfs_version'].split(",")
      starttime = Time.parse("#{params[:globalchatstartdate]}").utc
      endtime = Time.parse("#{params[:globalchatenddate]}").utc
      connectLumba
      CSV.open("#{Rails.root}/exportedfile/chat/tribechat.txt", "w:ASCII-8BIT:UTF-8", {:col_sep => "\t"}) { |csv|
        csv << ["userId", "User Name", "Clan Id", "Chat messages", "Time (PT)", "Time (UTC)"]
        sfsvers.each { |sfsver|
          str_query = "select cc.userId, u.name, cc.clanId, cc.message, CONVERT_TZ(cc.createdAt,'+00:00','-07:00') createdAt, cc.createdAt as createdAtUTC from clanChat_v#{sfsver} cc join user_v#{sfsver} u on cc.userId = u.userId where cc.createdAt > '#{starttime}' and cc.createdAt < '#{endtime}' order by clanId"
          logger.info(str_query)
          chatResult = @dblumba.query(str_query)
          chatResult.each_hash do |row|
            csv << [row['userId'], row['name'], row['clanId'], "'#{row['message']}", row['createdAt'], row['createdAtUTC']]
          end
        }
      }
      disconnectLumba
      if session[:googleacount].nil?
        logger.info("vao googlesession nil")
        session[:googleacount] = GoogleDrive.login("dashboard@lum.ba", "181fremont")
      end
      a = session[:googleacount].upload_from_file("#{Rails.root}/exportedfile/chat/tribechat.txt", title_googlespreadsheet, :content_type => "text/tab-separated-values")
      a.acl.push({:scope_type => "user", :scope => "tr-support@lum.ba", :role => "writer"})
      url = a.human_url()
      @error_string = url
    end

    # number of unique user
    if (params[:numberofuniqueusers])
      title_googlespreadsheet = "Number of unique users until #{params[:numberofuniqueuserstildate]}"
      endtime = Time.parse("#{params[:numberofuniqueuserstildate]}").utc
      connectLumba
      CSV.open("#{Rails.root}/exportedfile/ccu/uniqueusernum.txt", "w:ASCII-8BIT:UTF-8", {:col_sep => "\t"}) { |csv|
        csv << ["Number of unique users"]
        str_query_numberuser = "select count(userId) totalplaying from user_v31 where createdAt < '#{endtime}'"
        totalplaying = @dblumba.query(str_query_numberuser).fetch_hash['totalplaying']
        csv << [totalplaying]
      }
      disconnectLumba
      if session[:googleacount].nil?
        logger.info("vao googlesession nil")
        session[:googleacount] = GoogleDrive.login("dashboard@lum.ba", "181fremont")
      end
      a = session[:googleacount].upload_from_file("#{Rails.root}/exportedfile/ccu/uniqueusernum.txt", title_googlespreadsheet, :content_type => "text/tab-separated-values")
      a.acl.push({:scope_type => "user", :scope => "tr-support@lum.ba", :role => "writer"})
      url = a.human_url()
      @error_string = url
    end
  end
end
