# encoding: utf-8
require 'mysql'
require 'json'
require 'uri'
require 'csv'

class TribeController < ApplicationController
  before_filter :login_required, :block_user_from_action
  skip_before_filter :verify_authenticity_token, :only => [:index, :tribe_details, :tournament]
  @selectedmenu = "bundle"

  def index
    @error_string = ""
    if (params[:actionupdate])
      # Define bad word array
      badword_arr = []
      file = File.open("#{Rails.root}/config/badword.txt", 'r:UTF-8') do |f|
        while line = f.gets
          badword_arr.push(line.gsub(/\n/, ""))
        end
        f.close
      end
      isUpdate = true
      badword_arr.each { |badword|
        if (params[:tribe_name].eql?(badword))
          @error_string = "Error: New Tribe name: #{params[:tribe_name]} is a bad word"
          isUpdate = false
        end
      }
      if (isUpdate)
        # select clan_id
        str_query = "select clanId, name from clan_v#{session[:sfs_version]} where id = #{params[:tribe_id]}"
        #str_update_tribe = "update clan_v#{session[:sfs_version]} set name = '#{params[:tribe_name]}' where id = #{params[:tribe_id]}"
        connectLumba
        clanIds = @dblumba.query(str_query)
        clanIds.each_hash do |row|
          prop1 = load_properties("#{Rails.root}/exportedfile/sfs/settings1.properties")
          str_update_tribe1 = "update clan_v#{prop1['sfs_version']} set name = '#{params[:tribe_name]}' where clanId = '#{row['clanId']}'"
          prop2 = load_properties("#{Rails.root}/exportedfile/sfs/settings2.properties")
          str_update_tribe2 = "update clan_v#{prop2['sfs_version']} set name = '#{params[:tribe_name]}' where clanId = '#{row['clanId']}'"
          prop3 = load_properties("#{Rails.root}/exportedfile/sfs/settings3.properties")
          str_update_tribe3 = "update clan_v#{prop3['sfs_version']} set name = '#{params[:tribe_name]}' where clanId = '#{row['clanId']}'"
          @dblumba.query(str_update_tribe1)
          @dblumba.query(str_update_tribe2)
          @dblumba.query(str_update_tribe3)
          @error_string = "Changed tribe name from #{row['name'].force_encoding('utf-8')} to #{params[:tribe_name].force_encoding('utf-8')}"
        end
        #@dblumba.query(str_update_tribe)
        disconnectLumba
      end
    end
    if !(session[:sfs_version].nil? || session[:sfs_version].eql?(""))
      if (params[:search])
        connectLumba
        str_set_count = "Set @rownum := 0;"
        setcountrow = @dblumba.query(str_set_count)
        str_query_tribe = "Select id, clanId, name, membersCount, trophies, rank From (Select id, clanId, name, membersCount, trophies, @rownum := @rownum + 1 As rank From clan_v#{session[:sfs_version]} Order By trophies desc, name) As Z where name = '#{params[:search_tribe]}'"
        @tribedatas = @dblumba.query(str_query_tribe)
        disconnectLumba
        if (@tribedatas.nil?)
          @error_string = "Not Found any tribe"
        end
      else
        connectLumba
        str_set_count = "Set @rownum := 0;"
        str_query_tribe = "Select id, clanId, name, membersCount, trophies, rank From (Select id, clanId, name, membersCount, trophies, @rownum := @rownum + 1 As rank From clan_v#{session[:sfs_version]} Order By trophies desc, name) As Z"
        setcountrow = @dblumba.query(str_set_count)
        @tribedatas = @dblumba.query(str_query_tribe)
        disconnectLumba
      end
      @tribe_array = []
      @tribedatas.each_hash do |row|
        @tribe_array.push(row)
      end
      @tribe_array = Kaminari.paginate_array(@tribe_array).page(params[:page]).per(200)
      @currentpage = @tribe_array.current_page
    end

    read_properties_file
    connectLumbaAppData
    @game_versions = @db.query("select distinct NextGameVersion from ref_Setting order by NextGameVersion")
    getuniqgameversion
    disconnectLumbaAppData
  end

  def tribe_details
    @sfs_version = session[:sfs_version]
    connectLumba
    str_set_count = "Set @rownum := 0;"
    setcountrow = @dblumba.query(str_set_count)
    str_query = "Select id, clanId, name, memberIds, trophies, rank From (Select id, clanId, name, memberIds, trophies, @rownum := @rownum + 1 As rank From clan_v#{session[:sfs_version]} Order By trophies desc, name) As Z where id = #{params[:tribeid]}"
    clan = @dblumba.query(str_query)
    clan.each_hash do |row|
      @clanidd = row['clanId']
      @daggers = row['trophies']
      @rankk = row['rank']
      @name = row['name']
      @listid = row['memberIds']
    end
    listid = JSON.parse(@listid);
    getusersfromtribe(listid['list'])
    disconnectLumba
    connectLumbaAppData
    @game_versions = @db.query("select distinct NextGameVersion from ref_Setting order by NextGameVersion")
    getuniqgameversion
    disconnectLumbaAppData
  end

  def getusersfromtribe(listid)
    @test = listid.join(',').gsub(',', "','").insert(0, "'") << "'"
    @tribedetails = @dblumba.query("select u.userId, u.name, um.level, um.trophies from user_v#{@sfs_version} u join userMeta_v#{@sfs_version} um on u.userId = um.userId where u.userId IN (#{@test}) order by trophies desc")
  end

  def tournament
    password_ballancer = APP_CONFIG['balancer_server']['password']
    `sshpass -p '#{password_ballancer}' scp -r '#{APP_CONFIG['sfs_server']['address1']}:/mnt/ebs500/tournaments/*' '#{Rails.root}/tmp/tournaments/'`

    Dir.foreach("#{Rails.root}/tmp/tournaments") do |item|
      next if item == '.' or item == '..'
      `unzip '#{Rails.root}/tmp/tournaments/#{item}' -d '#{Rails.root}/tmp/tournaments/unzipped/'`
    end

    @testarr = Array.new
    @itemarr = Array.new

    tournamentdir = "#{Rails.root}/tmp/tournaments/unzipped/"````````
    countitem = Dir[File.join(tournamentdir, '**', '*')].count {|file| File.file?(file) }
    Dir.glob("#{tournamentdir}*.csv") {|item|
      @itemarr.push(item)
      for i in 0..countitem
        @testarr.push[i]
        @testarr[i] = CSV.foreach(@itemarr[i], :headers => true, :col_sep => "\t")
      end
    }

    @itemarr = Kaminari.paginate_array(@itemarr).page(params[:page]).per(1)
    @currentitem = @itemarr.current_page

    # @testcsv = CSV.foreach("#{Rails.root}/tmp/tournament-2014-12-16-07-02-00-EST.csv", :headers => true, :col_sep => ' ')

    connectLumbaAppData
    @game_versions = @db.query("select distinct NextGameVersion from ref_Setting order by NextGameVersion")
    getuniqgameversion
    disconnectLumbaAppData
  end
end
