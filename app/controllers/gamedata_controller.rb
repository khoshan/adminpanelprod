# encoding: utf-8
require 'csv'
require 'zip/zip'
require 'cgi'
require 'rexml/document'
require 'money'
require 'money/bank/google_currency'
class GamedataController < ApplicationController
  before_filter :login_required, :blockIp, :block_user_from_action
  skip_before_filter :verify_authenticity_token, :only => [:index, :campaign, :combat_units, :unit_levels, :defensive_building, :defensive_buildings_level, :resources_building_variables, :army_building, :other_buildings, :town_hall_level, :decoration, :spell, :spell_level, :obstacles, :effects, :pretab, :trophy, :acheivements, :setting, :downloadgamedata, :googlespreadsheet, :newgame, :purchases]
  @selectedmenu = "gameVars"

  def index
    @error_string = ""
    connectLumbaAppData
    @game_versions = @db.query("select distinct NextGameVersion from ref_Setting order by NextGameVersion")
    getuniqgameversion
    disconnectLumbaAppData
    #@data = nil
    @selectedWS = ""
    if params[:selectedWorkSheet].eql?("campaign")
      redirect_to "/lumba/gamedata/campaign"
    elsif params[:selectedWorkSheet].eql?("combat_units")
      redirect_to "/lumba/gamedata/combat_units"
    elsif params[:selectedWorkSheet].eql?("unit_levels")
      redirect_to "/lumba/gamedata/unit_levels"
    elsif params[:selectedWorkSheet].eql?("defensive_building")
      redirect_to "/lumba/gamedata/defensive_building"
    elsif params[:selectedWorkSheet].eql?("defensive_buildings_level")
      redirect_to "/lumba/gamedata/defensive_buildings_level"
    elsif params[:selectedWorkSheet].eql?("resources_building_variables")
      redirect_to "/lumba/gamedata/resources_building_variables"
    elsif params[:selectedWorkSheet].eql?("army_building")
      redirect_to "/lumba/gamedata/army_building"
    elsif params[:selectedWorkSheet].eql?("other_buildings")
      redirect_to "/lumba/gamedata/other_buildings"
    elsif params[:selectedWorkSheet].eql?("town_hall_level")
      redirect_to "/lumba/gamedata/town_hall_level"
    elsif params[:selectedWorkSheet].eql?("spell")
      redirect_to "/lumba/gamedata/spell"
    elsif params[:selectedWorkSheet].eql?("spell_level")
      redirect_to "/lumba/gamedata/spell_level"
    elsif params[:selectedWorkSheet].eql?("obstacles")
      redirect_to "/lumba/gamedata/obstacles"
    elsif params[:selectedWorkSheet].eql?("effects")
      redirect_to "/lumba/gamedata/effects"
    elsif params[:selectedWorkSheet].eql?("pretab")
      redirect_to "/lumba/gamedata/pretab"
    elsif params[:selectedWorkSheet].eql?("trophy")
      redirect_to "/lumba/gamedata/trophy"
    elsif params[:selectedWorkSheet].eql?("acheivements")
      redirect_to "/lumba/gamedata/acheivements"
    elsif params[:selectedWorkSheet].eql?("setting")
      redirect_to "/lumba/gamedata/setting"
    else
      redirect_to "/lumba/gamedata/setting"
    end
  end

  def googlespreadsheet
    connectLumbaAppData
    if params[:commit].eql?("ExportToGoogle")
      handleExportToGoogleSpreadsheet
      error_string = @error_string
      puts CGI::escapeHTML('Usage: foo "bar" <baz>')
      puts CGI.escape(error_string)
      redirect_to "#{params[:currenturl]}?error_string=#{CGI.escape(error_string)}"
    elsif params[:commit].eql?("UpdateFromGoogle")
      handleUploadFromGoogleSpreadsheet
      error_string = @error_string
      redirect_to "#{params[:currenturl]}?error_string=#{CGI.escape(error_string)}"
    end
    disconnectLumbaAppData
  end

  def handleUploadFromGoogleSpreadsheet
    #begin
    t = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    session = GoogleDrive.login(params[:googleemail], params[:googlepassword])
    url_tmp = params[:googleurlGamedata].split("#gid")
    url = url_tmp[0].split("key=")
    if url.size < 2
      url.push("")
    end
    wss = session.spreadsheet_by_key(url[1])
    # Campaign
    ws = wss.worksheets[1]
    @db.query("delete from ref_Campaign where game_version = '#{@game_version}'")
    for row in 2..ws.num_rows
      str_query = "insert into ref_Campaign set Type = \"#{ws[row, 1]}\", Name = \"#{ws[row, 2]}\", RequireCampaignIDtoUnlock = \"#{ws[row, 3]}\", LootableGold = \"#{ws[row, 4]}\", LootableWater = \"#{ws[row, 5]}\", LootableDarkWater = \"#{ws[row, 6]}\", townhallprefab = \"#{ws[row, 7]}\", game_version = '#{@game_version}'"
      puts str_query
      @db.query(str_query)
    end
    # combat
    ws = wss.worksheets[2]
    @db.query("delete from ref_CombatUnit where game_version = '#{@game_version}'")
    for row in 2..ws.num_rows
      str_query = "insert into ref_CombatUnit set Unit = \"#{ws[row, 1]}\", `Unit Group` = \"#{ws[row, 2]}\", PreferredTarget = \"#{ws[row, 3]}\", PreferredTargetDamage = \"#{ws[row, 4]}\", AttackType = \"#{ws[row, 5]}\", AttackTarget = \"#{ws[row, 6]}\", DamageType = \"#{ws[row, 7]}\", SplashRadius = \"#{ws[row, 8]}\", HousingSpace = \"#{ws[row, 9]}\", TrainingTimeSeconds = \"#{ws[row, 10]}\", MovementSpeed = \"#{ws[row, 11]}\", AttackSpeed = \"#{ws[row, 12]}\", BarracksLevel = \"#{ws[row, 13]}\", RangeInTiles = \"#{ws[row, 14]}\", SearchRadiusInTiles = \"#{ws[row, 15]}\", MaxLevel = \"#{ws[row, 16]}\", game_version = '#{@game_version}'"
      puts str_query
      @db.query(str_query)
    end
    # unit level
    ws = wss.worksheets[4]
    @db.query("delete from ref_UnitLevels where game_version = '#{@game_version}'")
    for row in 2..ws.num_rows
      str_query = "insert into ref_UnitLevels set Type = \"#{ws[row, 1]}\", Level = \"#{ws[row, 2]}\", DamagePerSecond = \"#{ws[row, 3]}\", HitPoints = \"#{ws[row, 4]}\", TrainingCostInElixir = \"#{ws[row, 5]}\", UpgradeCostInElixir = \"#{ws[row, 6]}\", LaboratoryLevelRequired = \"#{ws[row, 7]}\", UpgradeTimeInHours = \"#{ws[row, 8]}\", TownHallLevelRequired = \"#{ws[row, 9]}\", RegenerationTimeInMinutes = \"#{ws[row, 10]}\", UpgradeCostInDarkElixir = \"#{ws[row, 11]}\", TrainingCostInDarkElixir = \"#{ws[row, 12]}\", game_version = '#{@game_version}'"
      puts str_query
      @db.query(str_query)
    end
    # defensive building
    ws = wss.worksheets[5]
    @db.query("delete from ref_DefensiveBuildings where game_version = '#{@game_version}'")
    for row in 2..ws.num_rows
      str_query = "insert into ref_DefensiveBuildings set Unit = \"#{ws[row, 1]}\", RangeStart = \"#{ws[row, 2]}\", RangeEnd = \"#{ws[row, 3]}\", Explodetime = \"#{ws[row, 4]}\", AttackSpeedInSeconds = \"#{ws[row, 5]}\", DamageType = \"#{ws[row, 6]}\", DamageRadius = \"#{ws[row, 7]}\", UnitTypeTargeted = \"#{ws[row, 8]}\", PreferredTarget = \"#{ws[row, 9]}\", PreferredTargetBonus = \"#{ws[row, 10]}\", NumberOfRounds = \"#{ws[row, 11]}\", MaxLevel = \"#{ws[row, 12]}\", SizeLimit = \"#{ws[row, 13]}\", AirRange = \"#{ws[row, 14]}\", UnitType = \"#{ws[row, 15]}\", game_version = '#{@game_version}'"
      puts str_query
      @db.query(str_query)
    end
    # defensive building level
    ws = wss.worksheets[7]
    @db.query("delete from ref_DefensiveBuildingsLevel where game_version = '#{@game_version}'")
    for row in 2..ws.num_rows
      str_query = "insert into ref_DefensiveBuildingsLevel set Type = \"#{ws[row, 1]}\", Level = \"#{ws[row, 2]}\", DamagePerSecond = \"#{ws[row, 3]}\", DamagePerShot = \"#{ws[row, 4]}\", HitPoints = \"#{ws[row, 5]}\", CostGold = \"#{ws[row, 6]}\", CostDarkElixir = \"#{ws[row, 7]}\", SellGold = \"#{ws[row, 8]}\", SellDarkElixir = \"#{ws[row, 9]}\", UpgradeTime = \"#{ws[row, 10]}\", ExperienceGained = \"#{ws[row, 11]}\", TownHallLevelRequired = \"#{ws[row, 12]}\", ObjectType = \"#{ws[row, 13]}\", CostToLoad = \"#{ws[row, 14]}\",PrefabName = \"#{ws[row, 15]}\", DisplayName = \"#{ws[row, 16]}\", NumTileOneSide = \"#{ws[row, 17]}\", HasBase = \"#{ws[row, 18]}\", game_version = '#{@game_version}'"
      puts str_query
      @db.query(str_query)
    end
    # resouce building
    ws = wss.worksheets[9]
    @db.query("delete from ref_ResourceBuildingVariables where game_version = '#{@game_version}'")
    for row in 2..ws.num_rows
      str_query = "insert into ref_ResourceBuildingVariables set Note = \"#{ws[row, 1].force_encoding('utf-8')}\", Type = \"#{ws[row, 2]}\", Level = \"#{ws[row, 3]}\", BuildCostElixir = \"#{ws[row, 4]}\", BuildCostGold = \"#{ws[row, 5]}\", BuildCostGem = \"#{ws[row, 6]}\", BuildTimeInMinutes = \"#{ws[row, 7]}\", ExperienceGained = \"#{ws[row, 8]}\", Capacity = \"#{ws[row, 9]}\", ProductionRates = \"#{ws[row, 10]}\", HitPoints = \"#{ws[row, 11]}\", TownHallLevelRequired = \"#{ws[row, 12]}\", BoostCostInGems = \"#{ws[row, 13]}\", MaxLevel = \"#{ws[row, 14]}\", ObjectType = \"#{ws[row, 15]}\", CollectablePoint = \"#{ws[row, 16]}\",PrefabName = \"#{ws[row, 17]}\", DisplayName = \"#{ws[row, 18]}\", NumTileOneSide = \"#{ws[row, 19]}\", HasBase = '#{ws[row, 20]}', game_version = '#{@game_version}'"
      puts str_query
      @db.query(str_query)
    end
    # army building
    ws = wss.worksheets[11]
    @db.query("delete from ref_ArmyBuilding where game_version = '#{@game_version}'")
    for row in 2..ws.num_rows
      str_query = "insert into ref_ArmyBuilding set Note = \"#{ws[row, 1]}\", Type = \"#{ws[row, 2]}\", Level = \"#{ws[row, 3]}\", BuildCostElixir = \"#{ws[row, 4]}\", BuildCostDarkElixir = \"#{ws[row, 5]}\", BuildTimeInMinutes = \"#{ws[row, 6]}\", ExperienceGained = \"#{ws[row, 7]}\", Capacity = \"#{ws[row, 8]}\", HitPoints = \"#{ws[row, 9]}\", MaxUnitQueue = \"#{ws[row, 10]}\", UnlockUnit = \"#{ws[row, 11]}\", UnlockSpell = \"#{ws[row, 12]}\", TownHallLevelRequired = \"#{ws[row, 13]}\", MaxLevel = \"#{ws[row, 14]}\", ObjectType = \"#{ws[row, 15]}\", BoostCostInGems = \"#{ws[row, 16]}\",PrefabName = \"#{ws[row, 17]}\", DisplayName = \"#{ws[row, 18]}\", NumTileOneSide = '#{ws[row, 19]}', HasBase = '#{ws[row, 20]}', game_version = '#{@game_version}'"
      puts str_query
      @db.query(str_query)
    end
    #Other Buildings
    ws = wss.worksheets[13]
    @db.query("delete from ref_OtherBuildings where game_version = '#{@game_version}'")
    for row in 2..ws.num_rows
      str_query = "insert into ref_OtherBuildings set Note = \"#{ws[row, 1]}\", Type = \"#{ws[row, 2]}\", Level = \"#{ws[row, 3]}\", BuildCostGold = \"#{ws[row, 4]}\", BuildCostGem = \"#{ws[row, 5]}\", BuildTimeInMinutes = \"#{ws[row, 6]}\", ExperienceGained = \"#{ws[row, 7]}\", Capacity = \"#{ws[row, 8]}\", HitPoints = \"#{ws[row, 9]}\", TownHallLevelRequired = \"#{ws[row, 10]}\", MaxLevel = '#{ws[row, 11]}', ObjectType = \"#{ws[row, 12]}\",PrefabName = \"#{ws[row, 13]}\", DisplayName = \"#{ws[row, 14]}\", NumTileOneSide = '#{ws[row, 15]}', HasBase = '#{ws[row, 16]}', game_version = '#{@game_version}'"
      puts str_query
      @db.query(str_query)
    end
    # Town Hall Level
    ws = wss.worksheets[14]
    @db.query("delete from ref_TownHallLevel where game_version = '#{@game_version}'")
    for row in 2..ws.num_rows
      str_query = "insert into ref_TownHallLevel set Type = '#{ws[row, 1]}', Level1 = '#{ws[row, 2]}', Level2 = '#{ws[row, 3]}', Level3 = '#{ws[row, 4]}', Level4 = '#{ws[row, 5]}', Level5 = '#{ws[row, 6]}', Level6 = '#{ws[row, 7]}', Level7 = '#{ws[row, 8]}', Level8 = '#{ws[row, 9]}', Level9 = '#{ws[row, 10]}', game_version = '#{@game_version}'"
      puts str_query
      @db.query(str_query)
    end
    # Decoration
    ws = wss.worksheets[16]
    @db.query("delete from ref_Decoration where game_version = '#{@game_version}'")
    for row in 2..ws.num_rows
      str_query = "insert into ref_Decoration set Note = \"#{ws[row, 1]}\", Type = \"#{ws[row, 2]}\", BuildCostElixir = \"#{ws[row, 3]}\", BuildCostDarkElixir = \"#{ws[row, 4]}\", BuildCostGold = \"#{ws[row, 5]}\", BuildCostGems = \"#{ws[row, 6]}\", LevelRequired = \"#{ws[row, 7]}\", ObjectType = '#{ws[row, 8]}' ,PrefabName = \"#{ws[row, 9]}\", DisplayName = \"#{ws[row, 10]}\", NumTileOneSide = '#{ws[row, 11]}', HasBase = '#{ws[row, 12]}', game_version = '#{@game_version}'"
      puts str_query
      @db.query(str_query)
    end
    #spell
    ws = wss.worksheets[17]
    @db.query("delete from ref_Spell where game_version = '#{@game_version}'")
    for row in 2..ws.num_rows
      str_query = "insert into ref_Spell set TypeName = \"#{ws[row, 1]}\", Type = \"#{ws[row, 2]}\", Radius = '#{ws[row, 3]}', StrikeArea = '#{ws[row, 4]}', NumberOfStrikes = '#{ws[row, 5]}', TimeBetweenStrikesInSeconds = '#{ws[row, 6]}', TimeToCreateInSeconds = '#{ws[row, 7]}', BoostTimeInSeconds = '#{ws[row, 8]}', SpellFactoryLevelRequired = \"#{ws[row, 9]}\", MaxLevel = '#{ws[row, 10]}', game_version = '#{@game_version}'"
      puts str_query
      @db.query(str_query)
    end
    # spell level
    ws = wss.worksheets[19]
    @db.query("delete from ref_SpellLevel where game_version = '#{@game_version}'")
    for row in 2..ws.num_rows
      str_query = "insert into ref_SpellLevel set Type = '#{ws[row, 1]}', Level = '#{ws[row, 2]}', BuildCostGold = '#{ws[row, 3]}', UpgradeCost = '#{ws[row, 4]}', UpgradeTimeInHours = '#{ws[row, 5]}', LaboratoryLevelRequired = '#{ws[row, 6]}', TotalDamage = '#{ws[row, 7]}', DamagePerStrike = '#{ws[row, 8]}', DamageBoostInPercent = '#{ws[row, 9]}', SpeedBoost = '#{ws[row, 10]}', SizeLimit = '#{ws[row, 11]}', game_version = '#{@game_version}'"
      puts str_query
      @db.query(str_query)
    end
    # Obstacles
    ws = wss.worksheets[21]
    @db.query("delete from ref_Obstactles where game_version = '#{@game_version}'")
    for row in 2..ws.num_rows
      str_query = "insert into ref_Obstactles set TypeName = '#{ws[row, 1]}', Type = '#{ws[row, 2]}', RemovalTime = '#{ws[row, 3]}', ExperienceGained = '#{ws[row, 4]}', RemovalCostGold = '#{ws[row, 5]}', RemovalCostElixir = '#{ws[row, 6]}', RespawnWeight = '#{ws[row, 7]}', RemovalBenefitElixir = '#{ws[row, 8]}', RemovalBenefitDarkElixir = '#{ws[row, 9]}', InitPosition = '#{ws[row, 10]}', ObjectType = '#{ws[row, 11]}',PrefabName = '#{ws[row, 12]}', DisplayName = '#{ws[row, 13]}', NumTileOneSide = '#{ws[row, 14]}', HasBase = '#{ws[row, 15]}', game_version = '#{@game_version}'"
      puts str_query
      @db.query(str_query)
    end
    # Trophy
    ws = wss.worksheets[22]
    @db.query("delete from ref_Trophy where game_version = '#{@game_version}'")
    for row in 2..ws.num_rows
      str_query = "insert into ref_Trophy set TrophyDifference = '#{ws[row, 1]}', High = '#{ws[row, 2]}', Low = '#{ws[row, 3]}', game_version = '#{@game_version}'"
      puts str_query
      @db.query(str_query)
    end
    # Achievement
    ws = wss.worksheets[24]
    @db.query("delete from ref_Achievement where game_version = '#{@game_version}'")
    for row in 2..ws.num_rows
      str_query = "insert into ref_Achievement set Type = \"#{ws[row, 1]}\", Star = \"#{ws[row, 2]}\", Name = \"#{ws[row, 3]}\", Description = \"#{ws[row, 4]}\", ExpReward = \"#{ws[row, 5]}\", GemReward = '#{ws[row, 6]}', RequiredQuantity = '#{ws[row, 7]}' , game_version = '#{@game_version}'"
      puts str_query
      @db.query(str_query)
    end

    @error_string = "Upload successful"
    #rescue Exception=>e
    #  puts e.to_s
    #  @error_string = e.to_s
    #end
  end

  def handleExportToGoogleSpreadsheet
    begin
      t = Time.now.strftime("%Y-%m-%d %H:%M:%S")
      session = GoogleDrive.login(params[:googleemail], params[:googlepassword])
      spreadsheet = session.create_spreadsheet("Lumba data version #{params[:game_version]}")
      retrieveXml = REXML::Document.new(response.body)
      key_tmp = spreadsheet.worksheets_feed_url.split("worksheets/")[1]
      key = key_tmp.split("/private")[0]
      url = "https://spreadsheets.google.com/ccc?key=#{key}"
      #ws = session.spreadsheet_by_key(key).worksheets[0]
      wss = session.spreadsheet_by_key(key)
      datas = @db.query("select * from ref_Campaign where game_version = '#{@game_version}'")
      puts datas.num_rows
      ws = wss.add_worksheet("Campaign", max_rows = datas.num_rows + 1, max_cols = 7)
      ws[1, 1] = "Type"
      ws[1, 2] = "Name"
      ws[1, 3] = "Require Campaign Id to Unlock"
      ws[1, 4] = "Lootable Gold"
      ws[1, 5] = "Lootable Water"
      ws[1, 6] = "Lootable Dark Water"
      ws[1, 7] = "Town Hall Prefab"
      index = 2
      #datas = @db.query("select * from ref_Campaign where game_version = '#{@game_version}'")
      datas.each_hash do |row|
        ws[index, 1] = row['Type']
        ws[index, 2] = row['Name'].force_encoding("UTF-8")
        ws[index, 3] = row['RequireCampaignIDtoUnlock']
        ws[index, 4] = row['LootableGold']
        ws[index, 5] = row['LootableWater']
        ws[index, 6] = row['LootableDarkWater']
        ws[index, 7] = row['townhallprefab']
        index = index + 1
      end
      ws.save()
      # combat
      datas = @db.query("select * from ref_CombatUnit where game_version = '#{@game_version}'")
      ws = wss.add_worksheet("Combat Units", max_rows = datas.num_rows + 1, max_cols = 16)
      ws[1, 1] = "Unit"
      ws[1, 2] = "Unit Group"
      ws[1, 3] = "Preferred Target"
      ws[1, 4] = "Preferred Target Damage"
      ws[1, 5] = "Attack Type"
      ws[1, 6] = "Attack Target"
      ws[1, 7] = "Damage Type"
      ws[1, 8] = "Splash radius"
      ws[1, 9] = "Housing Space"
      ws[1, 10] = "Training Time (s)"
      ws[1, 11] = "Movement Speed"
      ws[1, 12] = "Attack Speed (s)"
      ws[1, 13] = "Barracks Level "
      ws[1, 14] = "Range (tiles)"
      ws[1, 15] = "Search Radius (tiles)"
      ws[1, 16] = "Max Level"
      index = 2
      #datas = @db.query("select * from ref_CombatUnit where game_version = '#{@game_version}'")
      datas.each_hash do |row|
        ws[index, 1] = row['Unit']
        ws[index, 2] = row['Unit Group']
        ws[index, 3] = row['PreferredTarget']
        ws[index, 4] = row['PreferredTargetDamage']
        ws[index, 5] = row['AttackType']
        ws[index, 6] = row['AttackTarget']
        ws[index, 7] = row['DamageType']
        ws[index, 8] = row['SplashRadius']
        ws[index, 9] = row['HousingSpace']
        ws[index, 10] = row['TrainingTimeSeconds']
        ws[index, 11] = row['MovementSpeed']
        ws[index, 12] = row['AttackSpeed']
        ws[index, 13] = row['BarracksLevel']
        ws[index, 14] = row['RangeInTiles']
        ws[index, 15] = row['SearchRadiusInTiles']
        ws[index, 16] = row['MaxLevel']
        index = index + 1
      end
      ws.save()
      # unit level
      datas = @db.query("select * from ref_UnitLevels where game_version = '#{@game_version}'")
      ws = wss.add_worksheet("Unit levels", max_rows = datas.num_rows + 1, max_cols = 12)
      ws[1, 1] = "Type"
      ws[1, 2] = "Level"
      ws[1, 3] = "Damage per Second"
      ws[1, 4] = "Hitpoints"
      ws[1, 5] = "Training Cost (Elixir)"
      ws[1, 6] = "Upgrade Cost (Elixir)"
      ws[1, 7] = "Laboratory Level Required"
      ws[1, 8] = "Upgrade Time (hours)"
      ws[1, 9] = "Town Hall Level Required"
      ws[1, 10] = "Regeneration Time (minutes)"
      ws[1, 11] = "Upgrade Cost (Dark Elixir)"
      ws[1, 12] = "Training Cost (Dark Elixir)"
      index = 2
      #datas = @db.query("select * from ref_UnitLevels where game_version = '#{@game_version}'")
      datas.each_hash do |row|
        ws[index, 1] = row['Type']
        ws[index, 2] = row['Level']
        ws[index, 3] = row['DamagePerSecond']
        ws[index, 4] = row['HitPoints']
        ws[index, 5] = row['TrainingCostInElixir']
        ws[index, 6] = row['UpgradeCostInElixir']
        ws[index, 7] = row['LaboratoryLevelRequired']
        ws[index, 8] = row['UpgradeTimeInHours']
        ws[index, 9] = row['TownHallLevelRequired']
        ws[index, 10] = row['RegenerationTimeInMinutes']
        ws[index, 11] = row['UpgradeCostInDarkElixir']
        ws[index, 12] = row['TrainingCostInDarkElixir']
        index = index + 1
      end
      ws.save()
      # defensive building
      datas = @db.query("select * from ref_DefensiveBuildings where game_version = '#{@game_version}'")
      ws = wss.add_worksheet("Defensive Buildings", max_rows = datas.num_rows + 1, max_cols = 15)
      ws[1, 1] = "Unit"
      ws[1, 2] = "Range start"
      ws[1, 3] = "Range end"
      ws[1, 4] = "Explode time"
      ws[1, 5] = "Attack Speed (s)"
      ws[1, 6] = "Damage type"
      ws[1, 7] = "Damage radius"
      ws[1, 8] = "Unit type Targeted"
      ws[1, 9] = "Preferred Target"
      ws[1, 10] = "Preferred Target bonus"
      ws[1, 11] = "Number of rounds"
      ws[1, 12] = "Max Level"
      ws[1, 13] = "Size Limit"
      ws[1, 14] = "AirRange"
      ws[1, 15] = "Unit Type"
      index = 2
      datas = @db.query("select * from ref_DefensiveBuildings where game_version = '#{@game_version}'")
      datas.each_hash do |row|
        ws[index, 1] = row['Unit']
        ws[index, 2] = row['RangeStart']
        ws[index, 3] = row['RangeEnd']
        ws[index, 4] = row['Explodetime']
        ws[index, 5] = row['AttackSpeedInSeconds']
        ws[index, 6] = row['DamageType']
        ws[index, 7] = row['DamageRadius']
        ws[index, 8] = row['UnitTypeTargeted']
        ws[index, 9] = row['PreferredTarget']
        ws[index, 10] = row['PreferredTargetBonus']
        ws[index, 11] = row['NumberOfRounds']
        ws[index, 12] = row['MaxLevel']
        ws[index, 13] = row['SizeLimit']
        ws[index, 14] = row['AirRange']
        ws[index, 15] = row['UnitType']
        index = index + 1
      end
      ws.save()
      # defensive building level
      datas = @db.query("select * from ref_DefensiveBuildingsLevel where game_version = '#{@game_version}'")
      ws = wss.add_worksheet("Defensive Buildings Level", max_rows = datas.num_rows + 1, max_cols = 18)
      ws[1, 1] = "Type"
      ws[1, 2] = "Level"
      ws[1, 3] = "Damage per second"
      ws[1, 4] = "Damage per shot"
      ws[1, 5] = "Hitpoints"
      ws[1, 6] = "Cost Gold"
      ws[1, 7] = "Cost Dark Elixir"
      ws[1, 8] = "Sell Gold"
      ws[1, 9] = "Sell Dark Elixir"
      ws[1, 10] = "Upgrade Time"
      ws[1, 11] = "Experience Gained"
      ws[1, 12] = "Town Hall Level Required"
      ws[1, 13] = "Object Type"
      ws[1, 14] = "Cost To Load"
      ws[1, 15] = "PrefabName"
      ws[1, 16] = "DisplayName"
      ws[1, 17] = "NumTileOneSide"
      ws[1, 18] = "HasBase"
      index = 2
      datas = @db.query("select * from ref_DefensiveBuildingsLevel where game_version = '#{@game_version}'")
      datas.each_hash do |row|
        ws[index, 1] = row['Type']
        ws[index, 2] = row['Level']
        ws[index, 3] = row['DamagePerSecond']
        ws[index, 4] = row['DamagePerShot']
        ws[index, 5] = row['HitPoints']
        ws[index, 6] = row['CostGold']
        ws[index, 7] = row['CostDarkElixir']
        ws[index, 8] = row['SellGold']
        ws[index, 9] = row['SellDarkElixir']
        ws[index, 10] = row['UpgradeTime']
        ws[index, 11] = row['ExperienceGained']
        ws[index, 12] = row['TownHallLevelRequired']
        ws[index, 13] = row['ObjectType']
        ws[index, 14] = row['CostToLoad']
        ws[index, 15] = row['PrefabName']
        ws[index, 16] = row['DisplayName']
        ws[index, 17] = row['NumTileOneSide']
        ws[index, 18] = row['HasBase']
        index = index + 1
      end
      ws.save()
      # resource building level
      datas = @db.query("select * from ref_ResourceBuildingVariables where game_version = '#{@game_version}'")
      ws = wss.add_worksheet("Resource Building variables", max_rows = datas.num_rows + 1, max_cols = 20)
      ws[1, 1] = "Note"
      ws[1, 2] = "Type"
      ws[1, 3] = "Level"
      ws[1, 4] = "Build Cost Elixir"
      ws[1, 5] = "Build Cost Gold"
      ws[1, 6] = "Build Cost Gem"
      ws[1, 7] = "Build Time (minutes)"
      ws[1, 8] = "Experience Gained"
      ws[1, 9] = "Capacity"
      ws[1, 10] = "Production Rate"
      ws[1, 11] = "Hit Points"
      ws[1, 12] = "Town Hall level Required"
      ws[1, 13] = "Boost Cost (gems)"
      ws[1, 14] = "Max Level"
      ws[1, 15] = "Object Type"
      ws[1, 16] = "Collectable point"
      ws[1, 17] = "PrefabName"
      ws[1, 18] = "DisplayName"
      ws[1, 19] = "NumTileOneSide"
      ws[1, 20] = "HasBase"
      index = 2
      #datas = @db.query("select * from ref_ResourceBuildingVariables where game_version = '#{@game_version}'")
      datas.each_hash do |row|
        ws[index, 1] = row['Note']
        ws[index, 2] = row['Type']
        ws[index, 3] = row['Level']
        ws[index, 4] = row['BuildCostElixir']
        ws[index, 5] = row['BuildCostGold']
        ws[index, 6] = row['BuildCostGem']
        ws[index, 7] = row['BuildTimeInMinutes']
        ws[index, 8] = row['ExperienceGained']
        ws[index, 9] = row['Capacity']
        ws[index, 10] = row['ProductionRates']
        ws[index, 11] = row['HitPoints']
        ws[index, 12] = row['TownHallLevelRequired']
        ws[index, 13] = row['BoostCostInGems']
        ws[index, 14] = row['MaxLevel']
        ws[index, 15] = row['ObjectType']
        ws[index, 16] = row['CollectablePoint']
        ws[index, 17] = row['PrefabName']
        ws[index, 18] = row['DisplayName']
        ws[index, 19] = row['NumTileOneSide']
        ws[index, 20] = row['HasBase']
        index = index + 1
      end
      ws.save()
      # army building
      datas = @db.query("select * from ref_ArmyBuilding where game_version = '#{@game_version}'")
      ws = wss.add_worksheet("Army Building", max_rows = datas.num_rows + 1, max_cols = 20)
      ws[1, 1] = "Note"
      ws[1, 2] = "Type"
      ws[1, 3] = "Level"
      ws[1, 4] = "Build Cost Elixir"
      ws[1, 5] = "Build Cost Dark Elixir"
      ws[1, 6] = "Build Time (minutes)"
      ws[1, 7] = "Experience Gained"
      ws[1, 8] = "Capacity"
      ws[1, 9] = "Hit Points"
      ws[1, 10] = "Maximum Unit Queue"
      ws[1, 11] = "Unlock Unit"
      ws[1, 12] = "Unlock Spell"
      ws[1, 13] = "Town Hall level Required"
      ws[1, 14] = "Max Level"
      ws[1, 15] = "Object Type"
      ws[1, 16] = "Boost Cost (gems)"
      ws[1, 17] = "PrefabName"
      ws[1, 18] = "DisplayName"
      ws[1, 19] = "NumTileOneSide"
      ws[1, 20] = "HasBase"
      index = 2
      #datas = @db.query("select * from ref_ArmyBuilding where game_version = '#{@game_version}'")
      datas.each_hash do |row|
        ws[index, 1] = row['Note']
        ws[index, 2] = row['Type']
        ws[index, 3] = row['Level']
        ws[index, 4] = row['BuildCostElixir']
        ws[index, 5] = row['BuildCostDarkElixir']
        ws[index, 6] = row['BuildTimeInMinutes']
        ws[index, 7] = row['ExperienceGained']
        ws[index, 8] = row['Capacity']
        ws[index, 9] = row['HitPoints']
        ws[index, 10] = row['MaxUnitQueue']
        ws[index, 11] = row['UnlockUnit']
        ws[index, 12] = row['UnlockSpell']
        ws[index, 13] = row['TownHallLevelRequired']
        ws[index, 14] = row['MaxLevel']
        ws[index, 15] = row['ObjectType']
        ws[index, 15] = row['BoostCostInGems']
        ws[index, 17] = row['PrefabName']
        ws[index, 18] = row['DisplayName']
        ws[index, 19] = row['NumTileOneSide']
        ws[index, 20] = row['HasBase']
        index = index + 1
      end
      ws.save()
      # other building
      datas = @db.query("select * from ref_OtherBuildings where game_version = '#{@game_version}'")
      ws = wss.add_worksheet("Other Buildings", max_rows = datas.num_rows + 1, max_cols = 16)
      ws[1, 1] = "Note"
      ws[1, 2] = "Type"
      ws[1, 3] = "Level"
      ws[1, 4] = "Build Cost Gold"
      ws[1, 5] = "Build Cost Gem"
      ws[1, 6] = "Build Time (minutes)"
      ws[1, 7] = "Experience Gained"
      ws[1, 8] = "Capacity"
      ws[1, 9] = "Hit Points"
      ws[1, 10] = "Town Hall level Required"
      ws[1, 11] = "Max Level"
      ws[1, 12] = "Object Type"
      ws[1, 13] = "PrefabName"
      ws[1, 14] = "DisplayName"
      ws[1, 15] = "NumTileOneSide"
      ws[1, 16] = "HasBase"
      index = 2
      #datas = @db.query("select * from ref_OtherBuildings where game_version = '#{@game_version}'")
      datas.each_hash do |row|
        ws[index, 1] = row['Note']
        ws[index, 2] = row['Type']
        ws[index, 3] = row['Level']
        ws[index, 4] = row['BuildCostGold']
        ws[index, 5] = row['BuildCostGem']
        ws[index, 6] = row['BuildTimeInMinutes']
        ws[index, 7] = row['ExperienceGained']
        ws[index, 8] = row['Capacity']
        ws[index, 9] = row['HitPoints']
        ws[index, 10] = row['TownHallLevelRequired']
        ws[index, 11] = row['MaxLevel']
        ws[index, 12] = row['ObjectType']
        ws[index, 13] = row['PrefabName']
        ws[index, 14] = row['DisplayName']
        ws[index, 15] = row['NumTileOneSide']
        ws[index, 16] = row['HasBase']
        index = index + 1
      end
      ws.save()
      # town hall level
      datas = @db.query("select * from ref_TownHallLevel where game_version = '#{@game_version}'")
      ws = wss.add_worksheet("Town Hall Level", max_rows = datas.num_rows + 1, max_cols = 10)
      ws[1, 1] = "Type"
      ws[1, 2] = "Level1"
      ws[1, 3] = "Level2"
      ws[1, 4] = "Level3"
      ws[1, 5] = "Level4"
      ws[1, 6] = "Level5"
      ws[1, 7] = "Level6"
      ws[1, 8] = "Level7"
      ws[1, 9] = "Level8"
      ws[1, 10] = "Level9"
      index = 2
      #datas = @db.query("select * from ref_TownHallLevel where game_version = '#{@game_version}'")
      datas.each_hash do |row|
        ws[index, 1] = row['Type']
        ws[index, 2] = row['Level1']
        ws[index, 3] = row['Level2']
        ws[index, 4] = row['Level3']
        ws[index, 5] = row['Level4']
        ws[index, 6] = row['Level5']
        ws[index, 7] = row['Level6']
        ws[index, 8] = row['Level7']
        ws[index, 9] = row['Level8']
        ws[index, 10] = row['Level9']
        index = index + 1
      end
      ws.save()
      # decoration
      datas = @db.query("select * from ref_Decoration where game_version = '#{@game_version}'")
      ws = wss.add_worksheet("Decoration", max_rows = datas.num_rows + 1, max_cols = 12)
      ws[1, 1] = "Note"
      ws[1, 2] = "Type"
      ws[1, 3] = "Build Cost Elixir"
      ws[1, 4] = "Build Cost Dark Elixir"
      ws[1, 5] = "Build Cost Gold"
      ws[1, 6] = "Build Cost Gem"
      ws[1, 7] = "Level Require"
      ws[1, 8] = "Object Type"
      ws[1, 9] = "PrefabName"
      ws[1, 10] = "DisplayName"
      ws[1, 11] = "NumTileOneSide"
      ws[1, 12] = "HasBase"
      index = 2
      #datas = @db.query("select * from ref_Decoration where game_version = '#{@game_version}'")
      datas.each_hash do |row|
        ws[index, 1] = row['Note']
        ws[index, 2] = row['Type']
        ws[index, 3] = row['BuildCostElixir']
        ws[index, 4] = row['BuildCostDarkElixir']
        ws[index, 5] = row['BuildCostGold']
        ws[index, 6] = row['BuildCostGems']
        ws[index, 7] = row['LevelRequired']
        ws[index, 8] = row['ObjectType']
        ws[index, 9] = row['PrefabName']
        ws[index, 10] = row['DisplayName']
        ws[index, 11] = row['NumTileOneSide']
        ws[index, 12] = row['HasBase']
        index = index + 1
      end
      ws.save()
      # Spell
      datas = @db.query("select * from ref_Spell where game_version = '#{@game_version}'")
      ws = wss.add_worksheet("Spell", max_rows = datas.num_rows + 1, max_cols = 10)
      ws[1, 1] = "Type name"
      ws[1, 2] = "Type"
      ws[1, 3] = "Radius"
      ws[1, 4] = "Strike area"
      ws[1, 5] = "Numb of Strike"
      ws[1, 6] = "Time between strikes(s)"
      ws[1, 7] = "Time to create(min)"
      ws[1, 8] = "Boost Time(s)"
      ws[1, 9] = "Spell Factory level require"
      ws[1, 10] = "Max Level"
      index = 2
      #datas = @db.query("select * from ref_Spell where game_version = '#{@game_version}'")
      datas.each_hash do |row|
        ws[index, 1] = row['TypeName']
        ws[index, 2] = row['Type']
        ws[index, 3] = row['Radius']
        ws[index, 4] = row['StrikeArea']
        ws[index, 5] = row['NumberOfStrikes']
        ws[index, 6] = row['TimeBetweenStrikesInSeconds']
        ws[index, 7] = row['TimeToCreateInSeconds']
        ws[index, 8] = row['BoostTimeInSeconds']
        ws[index, 9] = row['SpellFactoryLevelRequired']
        ws[index, 10] = row['MaxLevel']
        index = index + 1
      end
      ws.save()
      # spell level
      datas = @db.query("select * from ref_SpellLevel where game_version = '#{@game_version}'")
      ws = wss.add_worksheet("Spell Level", max_rows = datas.num_rows + 1, max_cols = 11)
      ws[1, 1] = "Type"
      ws[1, 2] = "Level"
      ws[1, 3] = "Build Cost Gold"
      ws[1, 4] = "Upgrade Cost Water"
      ws[1, 5] = "Upgrade Time(hours)"
      ws[1, 6] = "Lab Level Require"
      ws[1, 7] = "Total Damage"
      ws[1, 8] = "Damage Per Strike"
      ws[1, 9] = "Damage Boost(%)"
      ws[1, 10] = "Speed Boost"
      ws[1, 11] = "Size Limit"
      index = 2
      #datas = @db.query("select * from ref_SpellLevel where game_version = '#{@game_version}'")
      datas.each_hash do |row|
        ws[index, 1] = row['Type']
        ws[index, 2] = row['Level']
        ws[index, 3] = row['BuildCostGold']
        ws[index, 4] = row['UpgradeCost']
        ws[index, 5] = row['UpgradeTimeInHours']
        ws[index, 6] = row['LaboratoryLevelRequired']
        ws[index, 7] = row['TotalDamage']
        ws[index, 8] = row['DamagePerStrike']
        ws[index, 9] = row['DamageBoostInPercent']
        ws[index, 10] = row['SpeedBoost']
        ws[index, 11] = row['SizeLimit']
        index = index + 1
      end
      ws.save()
      # obstacle
      datas = @db.query("select * from ref_Obstactles where game_version = '#{@game_version}'")
      ws = wss.add_worksheet("Obstacles", max_rows = datas.num_rows + 1, max_cols = 15)
      ws[1, 1] = "Type name"
      ws[1, 2] = "Type"
      ws[1, 3] = "Removal time"
      ws[1, 4] = "Experience Gained"
      ws[1, 5] = "Removal Cost Gold"
      ws[1, 6] = "Removal Cost Elixir"
      ws[1, 7] = "Respawn Weight"
      ws[1, 8] = "Removal Benefit Elixir"
      ws[1, 9] = "Removal Benefit Dark Elixir"
      ws[1, 10] = "Init Position"
      ws[1, 11] = "Object Type"
      ws[1, 12] = "PrefabName"
      ws[1, 13] = "DisplayName"
      ws[1, 14] = "NumTileOneSide"
      ws[1, 15] = "HasBase"
      index = 2
      #datas = @db.query("select * from ref_Obstactles where game_version = '#{@game_version}'")
      datas.each_hash do |row|
        ws[index, 1] = row['TypeName']
        ws[index, 2] = row['Type']
        ws[index, 3] = row['RemovalTime']
        ws[index, 4] = row['ExperienceGained']
        ws[index, 5] = row['RemovalCostGold']
        ws[index, 6] = row['RemovalCostElixir']
        ws[index, 7] = row['RespawnWeight']
        ws[index, 8] = row['RemovalBenefitElixir']
        ws[index, 9] = row['RemovalBenefitDarkElixir']
        ws[index, 10] = row['InitPosition']
        ws[index, 11] = row['ObjectType']
        ws[index, 12] = row['PrefabName']
        ws[index, 13] = row['DisplayName']
        ws[index, 14] = row['NumTileOneSide']
        ws[index, 15] = row['HasBase']
        index = index + 1
      end
      ws.save()
      # effect
=begin
      ws = wss.add_worksheet("Effects", max_rows = 1000, max_cols = 20)
      ws[1, 1] = "Type"
      ws[1, 2] = "Description"
      ws[1, 3] = "PrefabName"
      index = 2
      datas = @db.query("select * from ref_Effects where game_version = '#{@game_version}'")
      datas.each_hash do |row|
        ws[index, 1] = row['Type']
        ws[index, 2] = row['Description']
        ws[index, 3] = row['PrefabName']
        index = index + 1
      end
      ws.save()
      # prefab
      ws = wss.add_worksheet("Prefab", max_rows = 1000, max_cols = 20)
      ws[1, 1] = "Prefab name"
      ws[1, 2] = "prefab path"
      ws[1, 3] = "preload"
      ws[1, 4] = "cull above"
      index = 2
      datas = @db.query("select * from ref_Prefab where game_version = '#{@game_version}'")
      datas.each_hash do |row|
        ws[index, 1] = row['PrefabName']
        ws[index, 2] = row['PrefabPath']
        ws[index, 3] = row['preload']
        ws[index, 4] = row['cullAbove']
        index = index + 1
      end
      ws.save()
=end
      # trophy
      datas = @db.query("select * from ref_Trophy where game_version = '#{@game_version}'")
      ws = wss.add_worksheet("Trophy", max_rows = datas.num_rows + 1, max_cols = 3)
      ws[1, 1] = "Trophy difference"
      ws[1, 2] = "High"
      ws[1, 3] = "Low"
      index = 2
      #datas = @db.query("select * from ref_Trophy where game_version = '#{@game_version}'")
      datas.each_hash do |row|
        ws[index, 1] = row['TrophyDifference']
        ws[index, 2] = row['High']
        ws[index, 3] = row['Low']
        index = index + 1
      end
      ws.save()
      # Achievement
      datas = @db.query("select * from ref_Achievement where game_version = '#{@game_version}'")
      ws = wss.add_worksheet("Achievement", max_rows = datas.num_rows + 1, max_cols = 7)
      ws[1, 1] = "Type"
      ws[1, 2] = "Star"
      ws[1, 3] = "Name"
      ws[1, 4] = "Description"
      ws[1, 5] = "Exp reward"
      ws[1, 6] = "Gem reward"
      ws[1, 7] = "Required quantity"
      index = 2
      #datas = @db.query("select * from ref_Achievement where game_version = '#{@game_version}'")
      datas.each_hash do |row|
        ws[index, 1] = row['Type']
        ws[index, 2] = row['Star']
        ws[index, 3] = row['Name']
        ws[index, 4] = row['Description']
        ws[index, 5] = row['ExpReward']
        ws[index, 6] = row['GemReward']
        ws[index, 7] = row['RequiredQuantity']
        index = index + 1
      end
      ws.save()
      # language
      datas = @db.query("select * from lang_Language where game_version = '#{@game_version}'")
      ws = wss.add_worksheet("Language", max_rows = datas.num_rows + 1, max_cols = 3)
      ws[1, 1] = "Key"
      ws[1, 2] = "English"
      ws[1, 3] = "Arabic"
      index = 2
      datas.each_hash do |row|
        ws[index, 1] = row['codeReference']
        ws[index, 2] = row['EN'].force_encoding("UTF-8")
        ws[index, 3] = row['AR'].force_encoding("UTF-8")
        index = index + 1
      end
      ws.save()

      wss.worksheets[0].delete()
      @error_string = "Export url: #{url}"
    rescue Exception => e
      puts e.to_s
      @error_string = e.to_s
    end
    puts "===#{@error_string}"
    @error_string
  end

  def downloadgamedata
    password_ballancer = APP_CONFIG['balancer_server']['password']
    `rm -rf #{Rails.root}/gamedatas_#{params[:game_version]}`
    `sshpass -p '#{password_ballancer}' scp -r #{APP_CONFIG['balancer_server']['address1']}:/home/lumbarunner/apps/lumba_loadbalancer/resources/#{params[:game_version]} #{Rails.root}/gamedatas_#{params[:game_version]}`
    bundle_filename = "#{Rails.root}/gamedatas_#{params[:game_version]}.zip"
    `rm #{bundle_filename}`
    dir = "#{Rails.root}/gamedatas_#{params[:game_version]}"
    Zip::ZipFile.open(bundle_filename, Zip::ZipFile::CREATE) { |zipfile|
      Dir.foreach(dir) do |item|
        item_path = "#{dir}/#{item}"
        if ((!item.index(".txt").nil?) && (zipfile.find_entry(item).nil?))
          zipfile.add("#{item}", item_path) if File.file? item_path
        end
      end
    }
    send_file("#{Rails.root}/gamedatas_#{params[:game_version]}.zip", :disposition => :attachment)
  end

  def campaign
    @error_string = ""
    if !params[:error_string].nil?
      @error_string = CGI.unescape(params[:error_string])
    end
    @selectedServer = params[:server_change]
    puts "puts @selectedServer #{@selectedServer} #{params[:server_change]}"
    t = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    @selectedWS = "campaign"
    if (params[:exportcampaign])
      connectLumbaAppData
      @datas = @db.query("select * from ref_Campaign where game_version = '#{@game_version}'")
      disconnectLumbaAppData
      properties_config = YAML.load_file("#{Rails.root}/config/properties.yml")
      if File.exist?("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/CampaignReference.txt")
        `rm #{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/CampaignReference.txt`
      end
      CSV.open("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/CampaignReference.txt", "w:UTF-8", {:col_sep => "\t"}) { |csv|
        csv << ["Type", "Name", "Require Campaign Id to Unlock", "Lootable Gold", "Lootable Water", "Lootable Dark Water", "Town Hall Prefab"]
        @datas.each_hash do |row|
          csv << [row['Type'], row['Name'], row['RequireCampaignIDtoUnlock'], row['LootableGold'], row['LootableWater'], row['LootableDarkWater'], row['townhallprefab']]
        end
      }
      if checkpassword(params[:confirmpassword])
        copy_file_to_server("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/CampaignReference.txt", params[:game_version], params[:exportserver])
        my_logger.info("#{session[:user]['username']} exported CampaignReference.txt lastMod = '#{t.to_s}'")
      else
        @error_string = "Invalid password"
      end
    end
    connectLumbaAppData
    @game_versions = @db.query("select distinct NextGameVersion from ref_Setting order by NextGameVersion")
    getuniqgameversion
    @datas = @db.query("select * from ref_Campaign where game_version = '#{@game_version}'")
    disconnectLumbaAppData
    @datas
  end

  def combat_units
    @error_string = ""
    if !params[:error_string].nil?
      @error_string = CGI.unescape(params[:error_string])
    end
    t = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    @selectedWS = "combat_units"
    if (params[:exportcombatunit])
      connectLumbaAppData
      @datas = @db.query("select * from ref_CombatUnit where game_version = '#{@game_version}'")
      disconnectLumbaAppData
      properties_config = YAML.load_file("#{Rails.root}/config/properties.yml")
      if File.exist?("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/CombatUnits.txt")
        `rm #{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/CombatUnits.txt`
      end
      CSV.open("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/CombatUnits.txt", "w:UTF-8", {:col_sep => "\t"}) { |csv|
        csv << ["Unit", "Unit Group", "Preferred Target", "Preferred Target Damage", "Attack Type", "Attack Target", "Damage Type", "Splash radius", "Housing Space", "Training Time (s)", "Movement Speed", "Attack Speed (s)", "Barracks Level", "Range (tiles)", "Search Radius (tiles )", "Max Level"]
        @datas.each_hash do |row|
          csv << [row['Unit'], row['Unit Group'], row['PreferredTarget'], row['PreferredTargetDamage'], row['AttackType'], row['AttackTarget'], row['DamageType'], row['SplashRadius'], row['HousingSpace'], row['TrainingTimeSeconds'], row['MovementSpeed'], row['AttackSpeed'], row['BarracksLevel'], row['RangeInTiles'], row['SearchRadiusInTiles'], row['MaxLevel']]
        end
      }
      if checkpassword(params[:confirmpassword])
        copy_file_to_server("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/CombatUnits.txt", params[:game_version], params[:exportserver])
        my_logger.info("#{session[:user]['username']} exported CombatUnits.txt lastMod = '#{t.to_s}'")
      else
        @error_string = "Invalid password"
      end
    end
    connectLumbaAppData
    @game_versions = @db.query("select distinct NextGameVersion from ref_Setting order by NextGameVersion")
    getuniqgameversion
    @datas = @db.query("select * from ref_CombatUnit where game_version = '#{@game_version}'")
    disconnectLumbaAppData
    @datas
  end


  def unit_levels
    @error_string = ""
    if !params[:error_string].nil?
      @error_string = CGI.unescape(params[:error_string])
    end
    t = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    @selectedWS = "unit_levels"
    if (params[:exportunitlevels])
      connectLumbaAppData
      @datas = @db.query("select * from ref_UnitLevels where game_version = '#{@game_version}'")
      disconnectLumbaAppData
      properties_config = YAML.load_file("#{Rails.root}/config/properties.yml")
      if File.exist?("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/UnitLevels.txt")
        `rm #{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/UnitLevels.txt`
      end
      CSV.open("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/UnitLevels.txt", "w:UTF-8", {:col_sep => "\t"}) { |csv|
        csv << ["Type", "Level", "Damage per Second", "Hitpoints", "Training Cost (Elixir)", "Upgrade Cost (Elixir)", "Laboratory Level Required", "Upgrade Time (hours)", "Town Hall Level Required", "Regeneration Time (minutes)", "Upgrade Cost (Dark Elixir)", "Training Cost (Dark Elixir)"]
        @datas.each_hash do |row|
          csv << [row['Type'], row['Level'], row['DamagePerSecond'], row['HitPoints'], row['TrainingCostInElixir'], row['UpgradeCostInElixir'], row['LaboratoryLevelRequired'], row['UpgradeTimeInHours'], row['TownHallLevelRequired'], row['RegenerationTimeInMinutes'], row['UpgradeCostInDarkElixir'], row['TrainingCostInDarkElixir']]
        end
      }
      if checkpassword(params[:confirmpassword])
        copy_file_to_server("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/UnitLevels.txt", params[:game_version], params[:exportserver])
        my_logger.info("#{session[:user]['username']} exported UnitLevels.txt lastMod = '#{t.to_s}'")
      else
        @error_string = "Invalid password"
      end
    end
    connectLumbaAppData
    @game_versions = @db.query("select distinct NextGameVersion from ref_Setting order by NextGameVersion")
    getuniqgameversion
    @datas = @db.query("select * from ref_UnitLevels where game_version = '#{@game_version}'")
    disconnectLumbaAppData
    @datas
  end

  def defensive_building
    @error_string = ""
    if !params[:error_string].nil?
      @error_string = CGI.unescape(params[:error_string])
    end
    t = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    @selectedWS = "defensive_building"
    if (params[:exportdefensivebuilding])
      connectLumbaAppData
      @datas = @db.query("select * from ref_DefensiveBuildings where game_version = '#{@game_version}'")
      disconnectLumbaAppData
      properties_config = YAML.load_file("#{Rails.root}/config/properties.yml")
      if File.exist?("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/DefensiveBuildings.txt")
        `rm #{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/DefensiveBuildings.txt`
      end
      CSV.open("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/DefensiveBuildings.txt", "w:UTF-8", {:col_sep => "\t"}) { |csv|
        csv << ["Unit", "Range start", "Range end", "Explode time", "Attack Speed (s)", "Damage type", "Damage radius", "Unit type Targeted", "Preferred Target", "Preferred Target bonus", "Number of rounds", "Max Level", "Size Limit", "AirRange", "Unit Type"]
        @datas.each_hash do |row|
          puts "UnitType: #{row['UnitType']}"
          csv << [row['Unit'], row['RangeStart'], row['RangeEnd'], row['Explodetime'], row['AttackSpeedInSeconds'], row['DamageType'], row['DamageRadius'], row['UnitTypeTargeted'], row['PreferredTarget'], row['PreferredTargetBonus'], row['NumberOfRounds'], row['MaxLevel'], row['SizeLimit'], row['AirRange'], row['UnitType']]
        end
      }
      if checkpassword(params[:confirmpassword])
        copy_file_to_server("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/DefensiveBuildings.txt", params[:game_version], params[:exportserver])
        my_logger.info("#{session[:user]['username']} exported DefensiveBuildings.txt lastMod = '#{t.to_s}'")
      else
        @error_string = "Invalid password"
      end
    end
    connectLumbaAppData
    @game_versions = @db.query("select distinct NextGameVersion from ref_Setting order by NextGameVersion")
    getuniqgameversion
    @datas = @db.query("select * from ref_DefensiveBuildings where game_version = '#{@game_version}'")
    disconnectLumbaAppData
    @datas
  end

  def defensive_buildings_level
    @error_string = ""
    if !params[:error_string].nil?
      @error_string = CGI.unescape(params[:error_string])
    end
    t = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    @selectedWS = "defensive_buildings_level"
    if (params[:exportdefensivebuildingslevel])
      connectLumbaAppData
      @datas = @db.query("select * from ref_DefensiveBuildingsLevel where game_version = '#{@game_version}'")
      disconnectLumbaAppData
      properties_config = YAML.load_file("#{Rails.root}/config/properties.yml")
      if File.exist?("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/DefensiveBuildingLevel.txt")
        `rm #{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/DefensiveBuildingLevel.txt`
      end
      CSV.open("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/DefensiveBuildingLevel.txt", "w:UTF-8", {:col_sep => "\t"}) { |csv|
        csv << ["Type", "Level", "Damage per second", "Damage per shot", "Hitpoints", "Cost Gold", "Cost Dark Elixir", "Sell Gold", "Sell Dark Elixir", "Upgrade Time", "Experience Gained", "Town Hall Level Required", "Object Type", "Cost To Load", "PrefabName", "DisplayName", "NumTileOneSide", "HasBase"]
        @datas.each_hash do |row|
          csv << [row['Type'].to_i, row['Level'], row['DamagePerSecond'], row['DamagePerShot'], row['HitPoints'], row['CostGold'], row['CostDarkElixir'], row['SellGold'], row['SellDarkElixir'], row['UpgradeTime'], row['ExperienceGained'], row['TownHallLevelRequired'], row['ObjectType'], row['CostToLoad'], row['PrefabName'], row['DisplayName'], row['NumTileOneSide'], row['HasBase']]
        end
      }
      if checkpassword(params[:confirmpassword])
        copy_file_to_server("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/DefensiveBuildingLevel.txt", params[:game_version], params[:exportserver])
        my_logger.info("#{session[:user]['username']} exported DefensiveBuildingLevel.txt lastMod = '#{t.to_s}'")
      else
        @error_string = "Invalid password"
      end
    end
    connectLumbaAppData
    @game_versions = @db.query("select distinct NextGameVersion from ref_Setting order by NextGameVersion")
    getuniqgameversion
    @datas = @db.query("select * from ref_DefensiveBuildingsLevel where game_version = '#{@game_version}'")
    disconnectLumbaAppData
    @datas
  end

  def resources_building_variables
    @error_string = ""
    if !params[:error_string].nil?
      @error_string = CGI.unescape(params[:error_string])
    end
    @error_string = ""
    t = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    @selectedWS = "resources_building_variables"
    if (params[:exportresourcesbuildingvariables])
      connectLumbaAppData
      @datas = @db.query("select * from ref_ResourceBuildingVariables where game_version = '#{@game_version}'")
      disconnectLumbaAppData
      properties_config = YAML.load_file("#{Rails.root}/config/properties.yml")
      if File.exist?("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/ResourceBuildings.txt")
        `rm #{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/ResourceBuildings.txt`
      end
      CSV.open("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/ResourceBuildings.txt", "w:UTF-8", {:col_sep => "\t"}) { |csv|
        csv << ["Note", "Type", "Level", "Build Cost Elixir", "Build Cost Gold", "Build Cost Gem", "Build Time (minutes)", "Experience Gained", "Capacity", "Production Rate", "Hit Points", "Town Hall level Required", "Boost Cost (gems)", "Max Level", "Object Type", "Collectable point", "PrefabName", "DisplayName", "NumTileOneSide", "HasBase"]
        @datas.each_hash do |row|
          csv << [row['Note'].force_encoding("UTF-8"), row['Type'], row['Level'], row['BuildCostElixir'], row['BuildCostGold'], row['BuildCostGem'], row['BuildTimeInMinutes'], row['ExperienceGained'], row['Capacity'], row['ProductionRates'], row['HitPoints'], row['TownHallLevelRequired'], row['BoostCostInGems'], row['MaxLevel'], row['ObjectType'], row['CollectablePoint'], row['PrefabName'], row['DisplayName'], row['NumTileOneSide'], row['HasBase']]
        end
      }
      if checkpassword(params[:confirmpassword])
        copy_file_to_server("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/ResourceBuildings.txt", params[:game_version], params[:exportserver])
        my_logger.info("#{session[:user]['username']} exported ResourceBuildings.txt lastMod = '#{t.to_s}'")
      else
        @error_string = "Invalid password"
      end
    end
    connectLumbaAppData
    @game_versions = @db.query("select distinct NextGameVersion from ref_Setting order by NextGameVersion")
    getuniqgameversion
    @datas = @db.query("select * from ref_ResourceBuildingVariables where game_version = '#{@game_version}'")
    disconnectLumbaAppData
    @datas
  end

  def army_building
    @error_string = ""
    if !params[:error_string].nil?
      @error_string = CGI.unescape(params[:error_string])
    end
    @error_string = ""
    t = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    @selectedWS = "army_building"
    if (params[:exportarmybuilding])
      connectLumbaAppData
      @datas = @db.query("select * from ref_ArmyBuilding where game_version = '#{@game_version}'")
      disconnectLumbaAppData
      properties_config = YAML.load_file("#{Rails.root}/config/properties.yml")
      if File.exist?("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/ArmyBuildings.txt")
        `rm #{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/ArmyBuildings.txt`
      end
      CSV.open("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/ArmyBuildings.txt", "w:UTF-8", {:col_sep => "\t"}) { |csv|
        csv << ["Note", "Type", "Level", "Build Cost Elixir", "Build Cost Dark Elixir", "Build Time (minutes)", "Experience Gained", "Capacity", "Hit Points", "Maximum Unit Queue", "Unlock Unit", "Unlock Spell", "Town Hall level Required", "Max Level", "Object Type", "Boost Cost (gems)", "PrefabName", "DisplayName", "NumTileOneSide", "HasBase"]
        @datas.each_hash do |row|
          csv << [row['Note'], row['Type'], row['Level'], row['BuildCostElixir'], row['BuildCostDarkElixir'], row['BuildTimeInMinutes'], row['ExperienceGained'], row['Capacity'], row['HitPoints'], row['MaxUnitQueue'], row['UnlockUnit'], row['UnlockSpell'], row['TownHallLevelRequired'], row['MaxLevel'], row['ObjectType'], row['BoostCostInGems'], row['PrefabName'], row['DisplayName'], row['NumTileOneSide'], row['HasBase']]
        end
      }
      if checkpassword(params[:confirmpassword])
        copy_file_to_server("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/ArmyBuildings.txt", params[:game_version], params[:exportserver])
        my_logger.info("#{session[:user]['username']} exported ArmyBuildings.txt  lastMod = '#{t.to_s}'")
      else
        @error_string = "Invalid password"
      end
    end
    connectLumbaAppData
    @game_versions = @db.query("select distinct NextGameVersion from ref_Setting order by NextGameVersion")
    getuniqgameversion
    @datas = @db.query("select * from ref_ArmyBuilding where game_version = '#{@game_version}'")
    disconnectLumbaAppData
    @datas
  end

  def other_buildings
    @error_string = ""
    if !params[:error_string].nil?
      @error_string = CGI.unescape(params[:error_string])
    end
    @error_string = ""
    t = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    @selectedWS = "other_buildings"
    if (params[:exportotherbuildings])
      connectLumbaAppData
      @datas = @db.query("select * from ref_OtherBuildings where game_version = '#{@game_version}'")
      disconnectLumbaAppData
      properties_config = YAML.load_file("#{Rails.root}/config/properties.yml")
      if File.exist?("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/OtherBuildings.txt")
        `rm #{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/OtherBuildings.txt`
      end
      CSV.open("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/OtherBuildings.txt", "w:UTF-8", {:col_sep => "\t"}) { |csv|
        csv << ["Note", "Type", "Level", "Build Cost Gold", "Build Cost Gem", "Build Time (minutes)", "Experience Gained", "Capacity", "Hit Points", "Town Hall level Required", "Max Level", "Object Type", "PrefabName", "DisplayName", "NumTileOneSide", "HasBase"]
        @datas.each_hash do |row|
          csv << [row['Note'], row['Type'], row['Level'], row['BuildCostGold'], row['BuildCostGem'], row['BuildTimeInMinutes'], row['ExperienceGained'], row['Capacity'], row['HitPoints'], row['TownHallLevelRequired'], row['MaxLevel'], row['ObjectType'], row['PrefabName'], row['DisplayName'], row['NumTileOneSide'], row['HasBase']]
        end
      }
      if checkpassword(params[:confirmpassword])
        copy_file_to_server("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/OtherBuildings.txt", params[:game_version], params[:exportserver])
        my_logger.info("#{session[:user]['username']} exported OtherBuildings.txt lastMod = '#{t.to_s}'")
      else
        @error_string = "Invalid password"
      end
    end
    connectLumbaAppData
    @game_versions = @db.query("select distinct NextGameVersion from ref_Setting order by NextGameVersion")
    getuniqgameversion
    @datas = @db.query("select * from ref_OtherBuildings where game_version = '#{@game_version}'")
    disconnectLumbaAppData
    @datas
  end

  def town_hall_level
    @error_string = ""
    if !params[:error_string].nil?
      @error_string = CGI.unescape(params[:error_string])
    end
    @error_string = ""
    t = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    @selectedWS = "town_hall_level"
    if (params[:exporttownhalllevel])
      connectLumbaAppData
      @datas = @db.query("select * from ref_TownHallLevel where game_version = '#{@game_version}'")
      disconnectLumbaAppData
      properties_config = YAML.load_file("#{Rails.root}/config/properties.yml")
      if File.exist?("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/TownHallLevel.txt")
        `rm #{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/TownHallLevel.txt`
      end
      CSV.open("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/TownHallLevel.txt", "w:UTF-8", {:col_sep => "\t"}) { |csv|
        csv << ["Type", "Level1", "Level2", "Level3", "Level4", "Level5", "Level6", "Level7", "Level8", "Level9"]
        @datas.each_hash do |row|
          csv << [row['Type'], row['Level1'], row['Level2'], row['Level3'], row['Level4'], row['Level5'], row['Level6'], row['Level7'], row['Level8'], row['Level9']]
        end
      }
      if checkpassword(params[:confirmpassword])
        copy_file_to_server("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/TownHallLevel.txt", params[:game_version], params[:exportserver])
        my_logger.info("#{session[:user]['username']} exported TownHallLevel.txt lastMod = '#{t.to_s}'")
      else
        @error_string = "Invalid password"
      end
    end
    connectLumbaAppData
    @game_versions = @db.query("select distinct NextGameVersion from ref_Setting order by NextGameVersion")
    getuniqgameversion
    @datas = @db.query("select * from ref_TownHallLevel where game_version = '#{@game_version}'")
    disconnectLumbaAppData
    @datas
  end

  def decoration
    @error_string = ""
    if !params[:error_string].nil?
      @error_string = CGI.unescape(params[:error_string])
    end
    @error_string = ""
    t = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    @selectedWS = "decoration"
    if (params[:exportdecoration])
      connectLumbaAppData
      @datas = @db.query("select * from ref_Decoration where game_version = '#{@game_version}'")
      disconnectLumbaAppData
      properties_config = YAML.load_file("#{Rails.root}/config/properties.yml")
      if File.exist?("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/Decorations.txt")
        `rm #{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/Decorations.txt`
      end
      CSV.open("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/Decorations.txt", "w:UTF-8", {:col_sep => "\t"}) { |csv|
        csv << ["Note", "Type", "Build Cost Elixir", "Build Cost Dark Elixir", "Build Cost Gold", "Build Cost Gem", "Level Require", "Object Type", "PrefabName", "DisplayName", "NumTileOneSide", "HasBase"]
        @datas.each_hash do |row|
          if !row['DisplayName'].eql?("")
            csv << [row['Note'], row['Type'], row['BuildCostElixir'], row['BuildCostDarkElixir'], row['BuildCostGold'], row['BuildCostGems'], row['LevelRequired'], row['ObjectType'], row['PrefabName'], row['DisplayName'], row['NumTileOneSide'], row['HasBase']]
          else
            csv << [row['Note'], row['Type'], row['BuildCostElixir'], row['BuildCostDarkElixir'], row['BuildCostGold'], row['BuildCostGems'], row['LevelRequired'], row['ObjectType'], row['PrefabName'], " ", row['NumTileOneSide'], row['HasBase']]
          end
        end
      }
      if checkpassword(params[:confirmpassword])
        copy_file_to_server("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/Decorations.txt", params[:game_version], params[:exportserver])
        my_logger.info("#{session[:user]['username']} exported Decorations.txt lastMod = '#{t.to_s}'")
      else
        @error_string = "Invalid password"
      end
    end
    connectLumbaAppData
    @game_versions = @db.query("select distinct NextGameVersion from ref_Setting order by NextGameVersion")
    getuniqgameversion
    @datas = @db.query("select * from ref_Decoration where game_version = '#{@game_version}'")
    disconnectLumbaAppData
    @datas
  end

  def spell
    @error_string = ""
    if !params[:error_string].nil?
      @error_string = CGI.unescape(params[:error_string])
    end
    @error_string = ""
    t = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    @selectedWS = "spell"
    if (params[:exportspell])
      connectLumbaAppData
      @datas = @db.query("select * from ref_Spell where game_version = '#{@game_version}'")
      disconnectLumbaAppData
      properties_config = YAML.load_file("#{Rails.root}/config/properties.yml")
      if File.exist?("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/Spells.txt")
        `rm #{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/Spells.txt`
      end
      CSV.open("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/Spells.txt", "w:UTF-8", {:col_sep => "\t"}) { |csv|
        csv << ["Type name", "Type", "Radius", "Strike area", "Numb of Strike", "Time between strikes(s)", "Time to create(min)", "Boost Time(s)", "Spell Factory level require", "Max Level"]
        @datas.each_hash do |row|
          csv << [row['TypeName'], row['Type'], row['Radius'], row['StrikeArea'], row['NumberOfStrikes'], row['TimeBetweenStrikesInSeconds'], row['TimeToCreateInSeconds'], row['BoostTimeInSeconds'], row['SpellFactoryLevelRequired'], row['MaxLevel']]
        end
      }
      if checkpassword(params[:confirmpassword])
        copy_file_to_server("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/Spells.txt", params[:game_version], params[:exportserver])
        my_logger.info("#{session[:user]['username']} exported Spells.txt lastMod = '#{t.to_s}'")
      else
        @error_string = "Invalid password"
      end
    end
    connectLumbaAppData
    @game_versions = @db.query("select distinct NextGameVersion from ref_Setting order by NextGameVersion")
    getuniqgameversion
    @datas = @db.query("select * from ref_Spell where game_version = '#{@game_version}'")
    disconnectLumbaAppData
    @datas
  end

  def spell_level
    @error_string = ""
    if !params[:error_string].nil?
      @error_string = CGI.unescape(params[:error_string])
    end
    @error_string = ""
    t = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    @selectedWS = "spell_level"
    if (params[:exportspelllevel])
      connectLumbaAppData
      @datas = @db.query("select * from ref_SpellLevel where game_version = '#{@game_version}'")
      disconnectLumbaAppData
      properties_config = YAML.load_file("#{Rails.root}/config/properties.yml")
      if File.exist?("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/SpellLevels.txt")
        `rm #{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/SpellLevels.txt`
      end
      CSV.open("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/SpellLevels.txt", "w:UTF-8", {:col_sep => "\t"}) { |csv|
        csv << ["Type", "Level", "Build Cost Gold", "Upgrade Cost Water", "Upgrade Time(hours)", "Lab Level Require", "Total Damage", "Damage Per Strike", "Damage Boost(%)", "Speed Boost", "Size Limit"]
        @datas.each_hash do |row|
          csv << [row['Type'], row['Level'], row['BuildCostGold'], row['UpgradeCost'], row['UpgradeTimeInHours'], row['LaboratoryLevelRequired'], row['TotalDamage'], row['DamagePerStrike'], row['DamageBoostInPercent'], row['SpeedBoost'], row['SizeLimit']]
        end
      }
      if checkpassword(params[:confirmpassword])
        copy_file_to_server("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/SpellLevels.txt", params[:game_version], params[:exportserver])
        my_logger.info("#{session[:user]['username']} exported SpellLevels.txt lastMod = '#{t.to_s}'")
      else
        @error_string = "Invalid password"
      end
    end
    connectLumbaAppData
    @game_versions = @db.query("select distinct NextGameVersion from ref_Setting order by NextGameVersion")
    getuniqgameversion
    @datas = @db.query("select * from ref_SpellLevel where game_version = '#{@game_version}'")
    disconnectLumbaAppData
    @datas
  end

  def obstacles
    @error_string = ""
    if !params[:error_string].nil?
      @error_string = CGI.unescape(params[:error_string])
    end
    @error_string = ""
    t = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    @selectedWS = "obstacles"
    if (params[:exportobstacles])
      connectLumbaAppData
      @datas = @db.query("select * from ref_Obstactles where game_version = '#{@game_version}'")
      disconnectLumbaAppData
      properties_config = YAML.load_file("#{Rails.root}/config/properties.yml")
      if File.exist?("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/Obstacles.txt")
        `rm #{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/Obstacles.txt`
      end
      CSV.open("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/Obstacles.txt", "w:UTF-8", {:col_sep => "\t"}) { |csv|
        csv << ["Type name", "Type", "Removal time", "Experience Gained", "Removal Cost Gold", "Removal Cost Elixir", "Respawn Weight", "Removal Benefit Elixir", "Removal Benefit Dark Elixir", "Init Position", "Object Type", "PrefabName", "DisplayName", "NumTileOneSide", "HasBase"]
        @datas.each_hash do |row|
          if !row['InitPosition'].eql?("")
            csv << [row['TypeName'], row['Type'], row['RemovalTime'], row['ExperienceGained'], row['RemovalCostGold'], row['RemovalCostElixir'], row['RespawnWeight'], row['RemovalBenefitElixir'], row['RemovalBenefitDarkElixir'], row['InitPosition'], row['ObjectType'], row['PrefabName'], row['DisplayName'], row['NumTileOneSide'], row['HasBase']]
          else
            csv << [row['TypeName'], row['Type'], row['RemovalTime'], row['ExperienceGained'], row['RemovalCostGold'], row['RemovalCostElixir'], row['RespawnWeight'], row['RemovalBenefitElixir'], row['RemovalBenefitDarkElixir'], nil, row['ObjectType'], row['PrefabName'], row['DisplayName'], row['NumTileOneSide'], row['HasBase']]
          end
        end
      }
      if checkpassword(params[:confirmpassword])
        copy_file_to_server("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/Obstacles.txt", params[:game_version], params[:exportserver])
        my_logger.info("#{session[:user]['username']} exported Obstacles.txt lastMod = '#{t.to_s}'")
      else
        @error_string = "Invalid password"
      end
    end
    connectLumbaAppData
    @game_versions = @db.query("select distinct NextGameVersion from ref_Setting order by NextGameVersion")
    getuniqgameversion
    @datas = @db.query("select * from ref_Obstactles where game_version = '#{@game_version}'")
    disconnectLumbaAppData
    @datas
  end

  def effects
    @error_string = ""
    if !params[:error_string].nil?
      @error_string = CGI.unescape(params[:error_string])
    end
    @error_string = ""
    t = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    @selectedWS = "effects"
    if (params[:exporteffects])
      #db = Mysql.new('localhost', 'root', 'lumbapassword', 'LumbaAppData')
      connectLumbaAppData
      @datas = @db.query("select * from ref_Effects")
      #db.close
      disconnectLumbaAppData
      if File.exist?("#{Rails.root}/exportedfile/Effects.txt")
        `rm #{Rails.root}/exportedfile/Effects.txt`
      end
      CSV.open("#{Rails.root}/exportedfile/Effects.txt", "w:UTF-8", {:col_sep => "\t"}) { |csv|
        csv << ["Type", "Description", "PrefabName"]
        @datas.each_hash do |row|
          csv << [row['Type'], row['Description'], row['PrefabName']]
        end
      }
    end
    connectLumbaAppData
    @game_versions = @db.query("select distinct NextGameVersion from ref_Setting order by NextGameVersion")
    getuniqgameversion
    disconnectLumbaAppData
    @datas
  end

  def pretab
    @error_string = ""
    if !params[:error_string].nil?
      @error_string = CGI.unescape(params[:error_string])
    end
    @error_string = ""
    t = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    @selectedWS = "pretab"
    if (params[:exportpretab])
      connectLumbaAppData
      @datas = @db.query("select * from ref_Prefab")
      disconnectLumbaAppData
      if File.exist?("#{Rails.root}/exportedfile/Prefabs.txt")
        `rm #{Rails.root}/exportedfile/Prefabs.txt`
      end
      CSV.open("#{Rails.root}/exportedfile/Prefabs.txt", "w:UTF-8", {:col_sep => "\t"}) { |csv|
        csv << ["Prefab name", "prefab path", "preload", "cull above"]
        @datas.each_hash do |row|
          csv << [row['PrefabName'], row['PrefabPath'], row['preload'], row['cullAbove']]
        end
      }
    end
    connectLumbaAppData
    @game_versions = @db.query("select distinct NextGameVersion from ref_Setting order by NextGameVersion")
    getuniqgameversion
    disconnectLumbaAppData
    @datas
  end

  def trophy
    @error_string = ""
    if !params[:error_string].nil?
      @error_string = CGI.unescape(params[:error_string])
    end
    @error_string = ""
    t = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    @selectedWS = "trophy"
    if (params[:exporttrophy])
      connectLumbaAppData
      @datas = @db.query("select * from ref_Trophy where game_version = '#{@game_version}'")
      disconnectLumbaAppData
      properties_config = YAML.load_file("#{Rails.root}/config/properties.yml")
      if File.exist?("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/Trophy.txt")
        `rm #{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/Trophy.txt`
      end
      CSV.open("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/Trophy.txt", "w:UTF-8", {:col_sep => "\t"}) { |csv|
        csv << ["Trophy difference", "High", "Low"]
        @datas.each_hash do |row|
          csv << [row['TrophyDifference'], row['High'], row['Low']]
        end
      }
      if checkpassword(params[:confirmpassword])
        copy_file_to_server("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/Trophy.txt", params[:game_version], params[:exportserver])
        my_logger.info("#{session[:user]['username']} exported Trophy.txt lastMod = '#{t.to_s}'")
      else
        @error_string = "Invalid password"
      end
    end
    connectLumbaAppData
    @game_versions = @db.query("select distinct NextGameVersion from ref_Setting order by NextGameVersion")
    getuniqgameversion
    @datas = @db.query("select * from ref_Trophy where game_version = '#{@game_version}'")
    disconnectLumbaAppData
    @datas
  end

  def acheivements
    @error_string = ""
    if !params[:error_string].nil?
      @error_string = CGI.unescape(params[:error_string])
    end
    @error_string = ""
    t = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    @selectedWS = "acheivements"
    if (params[:exportacheivements])
      connectLumbaAppData
      @datas = @db.query("select * from ref_Achievement where game_version = '#{@game_version}'")
      disconnectLumbaAppData
      properties_config = YAML.load_file("#{Rails.root}/config/properties.yml")
      if File.exist?("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/Achievements.txt")
        `rm #{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/Achievements.txt`
      end
      CSV.open("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/Achievements.txt", "w:UTF-8", {:col_sep => "\t"}) { |csv|
        csv << ["Type", "Star", "Name", "Description", "Exp reward", "Gem reward", "Required quantity"]
        @datas.each_hash do |row|
          csv << [row['Type'], row['Star'], row['Name'], row['Description'], row['ExpReward'], row['GemReward'], row['RequiredQuantity']]
        end
      }
      achie_arr = []
      achie_item = {}
      connectLumbaAppData
      data_tmp = @db.query("select * from ref_Achievement where game_version = '#{@game_version}'")
      disconnectLumbaAppData
      data_tmp.each_hash do |row|
        a = {"type" => row['Type'].to_i, "star" => row['Star'].to_i, "name" => "#{row['Name']}", "description" => "#{row['Description']}", "expReward" => row['ExpReward'].to_i, "gemReward" => row['GemReward'].to_i, "reqQuantity" => row['RequiredQuantity'].to_i}
        achie_arr.push(JSON.generate(a))
      end
      file = File.open("#{Rails.root}/exportedfile/sfs/achievements.txt", 'w:UTF-8') do |f|
        f.puts("[#{achie_arr.join(',')}]")
        f.close
      end
      if checkpassword(params[:confirmpassword])
        copy_file_to_server("/root/myApp/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/Achievements.txt", params[:game_version], params[:exportserver])
        upfileto_sfs_server("#{Rails.root}/exportedfile/sfs/achievements.txt")
        my_logger.info("#{session[:user]['username']} exported Achievements.txt lastMod = '#{t.to_s}'")
      else
        @error_string = "Invalid password"
      end
    end
    connectLumbaAppData
    @game_versions = @db.query("select distinct NextGameVersion from ref_Setting order by NextGameVersion")
    getuniqgameversion
    @datas = @db.query("select * from ref_Achievement where game_version = '#{@game_version}'")
    disconnectLumbaAppData
    @datas
  end

  def newgame
    @error_string = ""
    @selectedWS = "newgame"
    if !params[:error_string].nil?
      @error_string = CGI.unescape(params[:error_string])
    end
    if params[:actionupdate]
      newgame_str = ""
      file = File.open("#{Rails.root}/exportedfile/sfs/newGame.txt", 'r:UTF-8') do |f|
        while line = f.gets
          newgame_str = "#{newgame_str} #{line}"
        end
        f.close
      end
      game_state = JSON.parse(newgame_str)
      abc = "[#{CGI.unescapeHTML(params[:objectValueArray]).gsub(/=>/, ':')}]"
      abc_json = JSON.parse(abc)
      game_object = {}
      objectKeyArray = params[:objectKeyArray].split(",")
      objectValueArray = params[:objectValueArray].split(",")
      objectKeyArray.each_with_index do |element, index|
        game_object[element] = objectValueArray[index].gsub(/=>/, ':')
      end
      game_object['nTiles'] = objectKeyArray.size
      objectKeyArray.each_with_index do |element, index|
        game_object[element] = (abc_json[index])
      end
      hudinfo = []
      hudinfo.push(params[:gamestate_level].to_i) # gamestate_level
      hudinfo.push(params[:gamestate_exper].to_i) # gamestate_exper
      hudinfo.push(params[:gamestate_gold].to_i) # gamestate_gold
      hudinfo.push(params[:gamestate_water].to_i) # gamestate_water
      hudinfo.push(params[:gamestate_darkwater].to_i) # gamestate_darkwater
      hudinfo.push(params[:gamestate_gems].to_i) # gamestate_gems
      hudinfo.push(params[:gamestate_townhall].to_i) # gamestate_townhall
      game_state['HUD']['hInfo'] = hudinfo
      game_state['HUD']['trophies'] = params[:gamestate_trophies].to_i
      game_state['Settings']['sound'] = params[:gamestate_sound].to_i
      game_state['Settings']['music'] = params[:gamestate_music].to_i
      #game_state['Settings'] = abc2
      game_state['Objects'] = game_object
      puts JSON.generate(game_state)
      file = File.open("#{Rails.root}/exportedfile/sfs/newGame.txt", 'w:UTF-8') do |f|
        f.puts(JSON.generate(game_state))
        f.close
      end
      upfileto_sfs_server_stage("#{Rails.root}/exportedfile/sfs/newGame.txt")
    end
    if params[:actionnew]
      newgame_str = ""
      file = File.open("#{Rails.root}/exportedfile/sfs/newGame.txt", 'r:UTF-8') do |f|
        while line = f.gets
          newgame_str = "#{newgame_str} #{line}"
        end
        f.close
      end
      game_state = JSON.parse(newgame_str)
      #create array position
      tail_index = 5
      position_arr = []
      file = File.open("#{Rails.root}/config/newGame_position.txt", 'r:UTF-8') do |f|
        while line = f.gets
          a = JSON.parse(line)
          position_arr.push(a)
        end
        f.close
      end
      puts position_arr
      # create uid_arr
      uid_arr = []
      file = File.open("#{Rails.root}/config/newGame_uid.txt", 'r:UTF-8') do |f|
        while line = f.gets
          uid_arr.push(line.gsub(/\n/, ""))
        end
        f.close
      end
      game_object = {}
      game_object['tile0'] = {"type" => 19, "tInfo" => [40, 36, 1, 1, false, "null"], "uId" => "08e82717-8ede-473f-a078-615e4fa350ff"}
      game_object['tile1'] = {"type" => 27, "tInfo" => [38, 40, 3, 1, false, "null"], "uId" => "61eea949-0222-4a5a-804e-a16853483de0"}
      game_object['tile2'] = {"type" => 24, "tInfo" => [43, 44, 2, 1, false, "null"], "uId" => "ecba8757-7ba8-4637-8919-c391c66ddaba"}
      game_object['tile3'] = {"type" => 28, "tInfo" => [28, 44, 3, 0, false, "null"], "uId" => "d1a4469e-9da1-4330-9cb1-4b305284af29"}
      game_object['tile4'] = {"type" => 13, "tInfo" => [43, 40, 1, 1, false, "null"], "specialData" => ["null", "null", "null"], "uId" => "44e17d54-d9a3-404a-ae7b-2898e6d11387"}
      params[:bush_num].to_i.times do |n|
        ran_pos = position_arr[rand(position_arr.size)]
        ran_uid = uid_arr[rand(uid_arr.size)]
        position_arr = position_arr - [ran_pos]
        uid_arr = uid_arr - [ran_uid]
        tile_tmp = {"type" => 2001, "tInfo" => ran_pos, "uId" => "#{ran_uid}"}
        game_object["tile#{tail_index}"] = tile_tmp
        tail_index = tail_index + 1
      end
      params[:tree_num].to_i.times do |n|
        ran_pos = position_arr[rand(position_arr.size)]
        ran_uid = uid_arr[rand(uid_arr.size)]
        position_arr = position_arr - [ran_pos]
        uid_arr = uid_arr - [ran_uid]
        tile_tmp = {"type" => 2002, "tInfo" => ran_pos, "uId" => "#{ran_uid}"}
        game_object["tile#{tail_index}"] = tile_tmp
        tail_index = tail_index + 1
      end
      params[:deadpalm_num].to_i.times do |n|
        ran_pos = position_arr[rand(position_arr.size)]
        ran_uid = uid_arr[rand(uid_arr.size)]
        position_arr = position_arr - [ran_pos]
        uid_arr = uid_arr - [ran_uid]
        tile_tmp = {"type" => 2003, "tInfo" => ran_pos, "uId" => "#{ran_uid}"}
        game_object["tile#{tail_index}"] = tile_tmp
        tail_index = tail_index + 1
      end
      params[:camelskeleton_num].to_i.times do |n|
        ran_pos = position_arr[rand(position_arr.size)]
        ran_uid = uid_arr[rand(uid_arr.size)]
        position_arr = position_arr - [ran_pos]
        uid_arr = uid_arr - [ran_uid]
        tile_tmp = {"type" => 2004, "tInfo" => ran_pos, "uId" => "#{ran_uid}"}
        game_object["tile#{tail_index}"] = tile_tmp
        tail_index = tail_index + 1
      end
      params[:minypalm_num].to_i.times do |n|
        ran_pos = position_arr[rand(position_arr.size)]
        ran_uid = uid_arr[rand(uid_arr.size)]
        position_arr = position_arr - [ran_pos]
        uid_arr = uid_arr - [ran_uid]
        tile_tmp = {"type" => 2005, "tInfo" => ran_pos, "uId" => "#{ran_uid}"}
        game_object["tile#{tail_index}"] = tile_tmp
        tail_index = tail_index + 1
      end
      params[:palmtree_num].to_i.times do |n|
        ran_pos = position_arr[rand(position_arr.size)]
        ran_uid = uid_arr[rand(uid_arr.size)]
        position_arr = position_arr - [ran_pos]
        uid_arr = uid_arr - [ran_uid]
        tile_tmp = {"type" => 2006, "tInfo" => ran_pos, "uId" => "#{ran_uid}"}
        game_object["tile#{tail_index}"] = tile_tmp
        tail_index = tail_index + 1
      end
      params[:palmtreegroup_num].to_i.times do |n|
        ran_pos = position_arr[rand(position_arr.size)]
        ran_uid = uid_arr[rand(uid_arr.size)]
        position_arr = position_arr - [ran_pos]
        uid_arr = uid_arr - [ran_uid]
        tile_tmp = {"type" => 2007, "tInfo" => ran_pos, "uId" => "#{ran_uid}"}
        game_object["tile#{tail_index}"] = tile_tmp
        tail_index = tail_index + 1
      end
      params[:smallrock_num].to_i.times do |n|
        ran_pos = position_arr[rand(position_arr.size)]
        ran_uid = uid_arr[rand(uid_arr.size)]
        position_arr = position_arr - [ran_pos]
        uid_arr = uid_arr - [ran_uid]
        tile_tmp = {"type" => 2008, "tInfo" => ran_pos, "uId" => "#{ran_uid}"}
        game_object["tile#{tail_index}"] = tile_tmp
        tail_index = tail_index + 1
      end
      params[:xsmallrock_num].to_i.times do |n|
        ran_pos = position_arr[rand(position_arr.size)]
        ran_uid = uid_arr[rand(uid_arr.size)]
        position_arr = position_arr - [ran_pos]
        uid_arr = uid_arr - [ran_uid]
        tile_tmp = {"type" => 2009, "tInfo" => ran_pos, "uId" => "#{ran_uid}"}
        game_object["tile#{tail_index}"] = tile_tmp
        tail_index = tail_index + 1
      end
      params[:tinyrock_num].to_i.times do |n|
        ran_pos = position_arr[rand(position_arr.size)]
        ran_uid = uid_arr[rand(uid_arr.size)]
        position_arr = position_arr - [ran_pos]
        uid_arr = uid_arr - [ran_uid]
        tile_tmp = {"type" => 2010, "tInfo" => ran_pos, "uId" => "#{ran_uid}"}
        game_object["tile#{tail_index}"] = tile_tmp
        tail_index = tail_index + 1
      end
      params[:crackedrock_num].to_i.times do |n|
        ran_pos = position_arr[rand(position_arr.size)]
        ran_uid = uid_arr[rand(uid_arr.size)]
        position_arr = position_arr - [ran_pos]
        uid_arr = uid_arr - [ran_uid]
        tile_tmp = {"type" => 2011, "tInfo" => ran_pos, "uId" => "#{ran_uid}"}
        game_object["tile#{tail_index}"] = tile_tmp
        tail_index = tail_index + 1
      end
      params[:mediumrock_num].to_i.times do |n|
        ran_pos = position_arr[rand(position_arr.size)]
        ran_uid = uid_arr[rand(uid_arr.size)]
        position_arr = position_arr - [ran_pos]
        uid_arr = uid_arr - [ran_uid]
        tile_tmp = {"type" => 2012, "tInfo" => ran_pos, "uId" => "#{ran_uid}"}
        game_object["tile#{tail_index}"] = tile_tmp
        tail_index = tail_index + 1
      end
      params[:largerock_num].to_i.times do |n|
        ran_pos = position_arr[rand(position_arr.size)]
        ran_uid = uid_arr[rand(uid_arr.size)]
        position_arr = position_arr - [ran_pos]
        uid_arr = uid_arr - [ran_uid]
        tile_tmp = {"type" => 2013, "tInfo" => ran_pos, "uId" => "#{ran_uid}"}
        game_object["tile#{tail_index}"] = tile_tmp
        tail_index = tail_index + 1
      end
      game_object['nTiles'] = tail_index
      game_state['Objects'] = game_object
      puts JSON.generate(game_state)
      file = File.open("#{Rails.root}/exportedfile/sfs/newGame.txt", 'w:UTF-8') do |f|
        f.puts(JSON.generate(game_state))
        f.close
      end
      upfileto_sfs_server_stage("#{Rails.root}/exportedfile/sfs/newGame.txt")
    end
    get_newgame_fromstageserver
    newgame_str = ""
    file = File.open("#{Rails.root}/exportedfile/sfs/newGame.txt", 'r:UTF-8') do |f|
      while line = f.gets
        newgame_str = "#{newgame_str} #{line}"
      end
      f.close
    end
    if (newgame_str.strip).size > 0
      @newgame_json = JSON.parse(newgame_str)
      @bush_number = 0
      @tree_number = 0
      @deadpalm_number = 0
      @camelskeleton_number = 0
      @minipalmtree_number = 0
      @palmtree_number = 0
      @palmtreegroup_number = 0
      @smallrock_number = 0
      @xsmallrock_number = 0
      @tinyrock_number = 0
      @crackedrock_number = 0
      @mediumrock_number = 0
      @largerock_number = 0
      obj = @newgame_json['Objects']
      obj.each { |key, value|
        if (key.index('tile') == 0)
          if (value['type'] == 2000)
            @bush_number = @bush_number + 1
          elsif (value['type'] == 2001)
            @bush_number = @bush_number + 1
          elsif (value['type'] == 2002)
            @tree_number = @tree_number + 1
          elsif (value['type'] == 2003)
            @deadpalm_number = @deadpalm_number + 1
          elsif (value['type'] == 2004)
            @camelskeleton_number = @camelskeleton_number + 1
          elsif (value['type'] == 2005)
            @minipalmtree_number = @minipalmtree_number + 1
          elsif (value['type'] == 2006)
            @palmtree_number = @palmtree_number + 1
          elsif (value['type'] == 2007)
            @palmtreegroup_number = @palmtreegroup_number + 1
          elsif (value['type'] == 2008)
            @smallrock_number = @smallrock_number + 1
          elsif (value['type'] == 2009)
            @xsmallrock_number = @xsmallrock_number + 1
          elsif (value['type'] == 2010)
            @tinyrock_number = @tinyrock_number + 1
          elsif (value['type'] == 2011)
            @crackedrock_number = @crackedrock_number + 1
          elsif (value['type'] == 2012)
            @mediumrock_number = @mediumrock_number + 1
          elsif (value['type'] == 2013)
            @largerock_number = @largerock_number + 1
          end
        end
      }


      @object = @newgame_json['Objects']
      @settings = @newgame_json['Settings']
      @game_level = @newgame_json['HUD']['hInfo']
      @trophies = @newgame_json['HUD']['trophies']
    end
    connectLumbaAppData
    @game_versions = @db.query("select distinct NextGameVersion from ref_Setting order by NextGameVersion")
    getuniqgameversion
    disconnectLumbaAppData
  end

  def purchases
    @error_string = ""
    if !params[:error_string].nil?
      @error_string = CGI.unescape(params[:error_string])
    end
    @selectedServer = params[:server_change]
    puts "puts @selectedServer #{@selectedServer} #{params[:server_change]}"
    @selectedWS = "purchases"
    connectLumba
    topclanquery = "SELECT * FROM clan_v31 order by trophies desc limit 10;"
    @topclan = @dblumba.query(topclanquery)
    disconnectLumba

    if (params[:downloadpurchasesios])
      begin
        `sync && echo 3 > /proc/sys/vm/drop_caches`
        `rm -f #{Rails.root}/exportedfile/purchases_ios/*`
        bundle_filename = "#{Rails.root}/exportedfile/purchases_ios.zip"
        `rm #{bundle_filename}`

        starttime = Time.parse("#{params[:purchasestartdate]}").utc
        endtime = Time.parse("#{params[:purchaseenddate]}").utc
        puts starttime
        puts endtime
        # starttime = Time.parse("#{darray1} 00:00:00 -06:00").utc
        # endtime = Time.parse("#{darray2} 23:59:59 -06:00").utc
        @query_array = []
        @month_array = []
        number_month = endtime.year * 12 + 1 + endtime.month - starttime.year*12 - starttime.month
        if number_month > 1
          for a in 0..(number_month -1) do
            if (params[:typeiap].eql?("1"))
              str_query_detail = "select id, userId, diwanLevel, gameLevel, coins, water, oil, pearls, daggers, status, purchasedPearls, purchasedItemId, rateToUSD, paidAmount, currency, country, transactionId, deviceInfo, createdAt as createdAtUTC, CONVERT_TZ(createdAt,'+00:00','-08:00') createdAt, CONVERT_TZ(installAt,'+00:00','-08:00') installAt, TIMESTAMPDIFF(SECOND,installAt,createdAt) timediff, transaction, verifyingText, ipAddress from purchases WHERE createdAt >= '#{starttime.beginning_of_month + a.month}' and createdAt <= '#{(starttime.beginning_of_month + a.month).end_of_month}'"
            else
              str_query_detail = "select id, userId, diwanLevel, gameLevel, coins, water, oil, pearls, daggers, status, purchasedPearls, purchasedItemId, rateToUSD, paidAmount, currency, country, transactionId, deviceInfo, createdAt as createdAtUTC, CONVERT_TZ(createdAt,'+00:00','-08:00') createdAt, CONVERT_TZ(installAt,'+00:00','-08:00') installAt, TIMESTAMPDIFF(SECOND,installAt,createdAt) timediff, transaction, verifyingText, ipAddress from purchases WHERE createdAt >= '#{starttime.beginning_of_month + a.month}' and createdAt <= '#{(starttime.beginning_of_month + a.month).end_of_month}'  and status = 'Valid'"
            end
            monthyear = "#{(starttime.beginning_of_month + a.month).month}-#{(starttime.beginning_of_month + a.month).year}"
            if a.eql? 0
              if (params[:typeiap].eql?("1"))
                str_query_detail = "select id, userId, diwanLevel, gameLevel, coins, water, oil, pearls, daggers, status, purchasedPearls, purchasedItemId, rateToUSD, paidAmount, currency, country, transactionId, deviceInfo, createdAt as createdAtUTC, CONVERT_TZ(createdAt,'+00:00','-08:00') createdAt, CONVERT_TZ(installAt,'+00:00','-08:00') installAt, TIMESTAMPDIFF(SECOND,installAt,createdAt) timediff, transaction, verifyingText, ipAddress from purchases WHERE createdAt >= '#{starttime}' and createdAt <= '#{starttime.end_of_month}'"
              else
                str_query_detail = "select id, userId, diwanLevel, gameLevel, coins, water, oil, pearls, daggers, status, purchasedPearls, purchasedItemId, rateToUSD, paidAmount, currency, country, transactionId, deviceInfo, createdAt as createdAtUTC, CONVERT_TZ(createdAt,'+00:00','-08:00') createdAt, CONVERT_TZ(installAt,'+00:00','-08:00') installAt, TIMESTAMPDIFF(SECOND,installAt,createdAt) timediff, transaction, verifyingText, ipAddress from purchases WHERE createdAt >= '#{starttime}' and createdAt <= '#{starttime.end_of_month}' and status = 'Valid'"
              end
              monthyear = "#{starttime.month}-#{starttime.year}"
            end
            if a.eql?(number_month -1)
              if (params[:typeiap].eql?("1"))
                str_query_detail = "select id, userId, diwanLevel, gameLevel, coins, water, oil, pearls, daggers, status, purchasedPearls, purchasedItemId, rateToUSD, paidAmount, currency, country, transactionId, deviceInfo, createdAt as createdAtUTC, CONVERT_TZ(createdAt,'+00:00','-08:00') createdAt, CONVERT_TZ(installAt,'+00:00','-08:00') installAt, TIMESTAMPDIFF(SECOND,installAt,createdAt) timediff, transaction, verifyingText, ipAddress from purchases WHERE createdAt >= '#{endtime.beginning_of_month}' and createdAt <= '#{endtime}'"
              else
                str_query_detail = "select id, userId, diwanLevel, gameLevel, coins, water, oil, pearls, daggers, status, purchasedPearls, purchasedItemId, rateToUSD, paidAmount, currency, country, transactionId, deviceInfo, createdAt as createdAtUTC, CONVERT_TZ(createdAt,'+00:00','-08:00') createdAt, CONVERT_TZ(installAt,'+00:00','-08:00') installAt, TIMESTAMPDIFF(SECOND,installAt,createdAt) timediff, transaction, verifyingText, ipAddress from purchases WHERE createdAt >= '#{endtime.beginning_of_month}' and createdAt <= '#{endtime}' and status = 'Valid'"
              end
              monthyear = "#{endtime.month}-#{endtime.year}"
            end
            @query_array.push(str_query_detail)
            @month_array.push(monthyear)
          end
        else
          if (params[:typeiap].eql?("1"))
            str_query_detail = "select id, userId, diwanLevel, gameLevel, coins, water, oil, pearls, daggers, status, purchasedPearls, purchasedItemId, rateToUSD, paidAmount, currency, country, transactionId, deviceInfo, createdAt as createdAtUTC, CONVERT_TZ(createdAt,'+00:00','-08:00') createdAt, CONVERT_TZ(installAt,'+00:00','-08:00') installAt, TIMESTAMPDIFF(SECOND,installAt,createdAt) timediff, transaction, verifyingText, ipAddress from purchases WHERE createdAt > '#{starttime}' and createdAt <= '#{endtime}'"
          else
            str_query_detail = "select id, userId, diwanLevel, gameLevel, coins, water, oil, pearls, daggers, status, purchasedPearls, purchasedItemId, rateToUSD, paidAmount, currency, country, transactionId, deviceInfo, createdAt as createdAtUTC, CONVERT_TZ(createdAt,'+00:00','-08:00') createdAt, CONVERT_TZ(installAt,'+00:00','-08:00') installAt, TIMESTAMPDIFF(SECOND,installAt,createdAt) timediff, transaction, verifyingText, ipAddress from purchases WHERE createdAt > '#{starttime}' and createdAt <= '#{endtime}' and status = 'Valid'"
          end
          monthyear = "#{endtime.month}-#{endtime.year}"
          @query_array.push(str_query_detail)
          @month_array.push(monthyear)
        end
        #str_query = "SELECT userId, SUM(IF(status='Valid',1,0)) CORRECT, SUM(IF(status>'Valid',1,0)) INVALID, SUM(IF(status='Duplicate',1,0)) DUPLICATES, SUM(IF(status='No verification response',1,0)) NOVERIFICATIONRESPONSE,SUM(IF(status='Not verified',1,0)) NOTVERIFIED,SUM(IF(status='Not handled',1,0)) NOTHANDLE,SUM(IF(status='Product not in the list',1,0)) PRODUCTNOTINTHELIST FROM purchases WHERE platform = 'ios' and createdAt > '#{starttime}' and createdAt < '#{endtime}' GROUP BY userId ORDER BY DUPLICATES DESC"
        #        if (params[:typeiap].eql?("1"))
        #          str_query_detail = "select id, userId, diwanLevel, gameLevel, coins, water, oil, pearls, daggers, status, purchasedPearls, purchasedItemId, rateToUSD, paidAmount, currency, country, transactionId, deviceInfo, createdAt as createdAtUTC, CONVERT_TZ(createdAt,'+00:00','-07:00') createdAt, CONVERT_TZ(installAt,'+00:00','-07:00') installAt, TIMESTAMPDIFF(SECOND,installAt,createdAt) timediff, transaction, verifyingText, ipAddress from purchases WHERE createdAt > '#{starttime}' and createdAt <= '#{endtime}'"
        #        else
        #          str_query_detail = "select id, userId, diwanLevel, gameLevel, coins, water, oil, pearls, daggers, status, purchasedPearls, purchasedItemId, rateToUSD, paidAmount, currency, country, transactionId, deviceInfo, createdAt as createdAtUTC, CONVERT_TZ(createdAt,'+00:00','-07:00') createdAt, CONVERT_TZ(installAt,'+00:00','-07:00') installAt, TIMESTAMPDIFF(SECOND,installAt,createdAt) timediff, transaction, verifyingText, ipAddress from purchases WHERE createdAt > '#{starttime}' and createdAt <= '#{endtime}' and status = 'Valid'"
        #        end
        #datapurchase = @dbsfs.query(str_query)
        if session[:googleacount].nil?
          logger.info("vao googlesession nil")
          session[:googleacount] = GoogleDrive.login("dashboard@lum.ba", "181fremont")
        end
        session[:googleacount] = GoogleDrive.login("dashboard@lum.ba", "181fremont")
        date_array = (Date.parse("#{params[:purchasestartdate]}") .. Date.parse("#{params[:purchaseenddate]}")).to_a
        datehash = {}
        date_array.each { |d|
          datehash[d.strftime('%Y-%m-%d')] = []
        }
        @query_array.each_with_index do |query_detail, n|
          logger.info(query_detail)
          connectLumbaIAP2
          datapurchase_detail = @dbsfs2.query(query_detail, :as => :array)
          disconnectLumbaIAP2
          Money::Bank::GoogleCurrency.ttl_in_seconds = 3600
          Money.default_bank = Money::Bank::GoogleCurrency.new
          bank = Money::Bank::GoogleCurrency.new
          #datapurchase_detail.each_slice(100000).with_index{ |a,i|
          CSV.open("#{Rails.root}/exportedfile/purchases_ios/purchase_details_ios_#{@month_array[n]}.csv", "w:UTF-8:ASCII-8BIT", {:col_sep => ","}) { |csv|
            csv << ["userId", "DiwanLevel", "GameLevel", "Coins", "Water", "Oil", "Pearls", "Daggers", "Status", "transactionId", "purchasedPearls", "purchasedItemId", "paidAmount", "paidAmountUSD", "PaidAmount70%", "currency", "DeviceInfo", "Device", "country", "installAt", "Receipt", "createdAt (PDT)", "createdAt (UTC)", "Time Diffirent CreateAt and InstallAt"]
            datapurchase_detail.each(:cache_rows => false) do |row|
              devicemake = ""
              if (!row[17].nil?)
                #logger.info(row[18])
                #logger.info(row[18])
                begin
                  deviceinforjson = JSON.parse(row[17])
                  devicemake = getdevicemakefromdevicemodel(deviceinforjson['deviceModel'])
                rescue Exception => e
                  devicemake = ""
                end
              end
              paidamount = row[13].to_f
              paidamount100 = paidamount * 100
              #logger.info("Paid amount: #{paidamount}      paidamount100: #{paidamount100}")
              moneyusdvalue = 0
              begin
                if !row[12].nil?
                  moneyusdvalue = (row[12].to_f * row[13].to_f).to_f.round(2)
                else
                  moneyusdvalue = (bank.get_rate(row[14], :USD).to_f.round(2) * row[13].to_f.round(2)).round(2)
                end

              rescue Exception => e
                moneyusd = 0
                moneyusdvalue = 0
              end
              csv << [row[1], row[2], row[3], row[4], row[5], row[6], row[7], row[8], row[9], row[16], row[10], row[11], row[13], moneyusdvalue, moneyusdvalue*0.7, row[14], row[17], devicemake, row[15], "#{row[20]} PDT", row[23], "#{row[19]} PDT", "#{row[18]} UTC", "#{convert_second_to_hhmmss(row[21].to_i)} (dd:hh:mm:ss)"]

            end
          }
          #}
          datapurchase_detail = nil
          GC.start

        end


#        datapurchase_detail = @dbsfs2.query(str_query_detail, :as => :array)
#        disconnectLumbaIAP2
#        logger.info("Got Data")

#      Money::Bank::GoogleCurrency.ttl_in_seconds = 3600
#      Money.default_bank = Money::Bank::GoogleCurrency.new
#      bank = Money::Bank::GoogleCurrency.new
#      datapurchase_detail.each_slice(10000).with_index{ |a,i|
#        CSV.open("#{Rails.root}/exportedfile/purchases_ios/purchase_details_ios_#{(i+1).to_s}.csv", "w:UTF-8:ASCII-8BIT", {:col_sep => ","}){ |csv|
#          csv << ["userId", "DiwanLevel", "GameLevel", "Coins", "Water", "Oil", "Pearls", "Daggers", "Status", "transactionId", "purchasedPearls", "purchasedItemId", "paidAmount", "paidAmountUSD", "PaidAmount70%", "currency", "DeviceInfo", "Device", "country", "installAt", "Receipt", "createdAt (PDT)", "createdAt (UTC)", "Time Diffirent CreateAt and InstallAt"]
#          a.each do |row|
#            devicemake = ""
#            if (!row[18].nil?)
#              #logger.info(row[18])
#              #logger.info(row[18])
#              begin
#                deviceinforjson = JSON.parse(row[18])
#                devicemake = getdevicemakefromdevicemodel(deviceinforjson['deviceModel'])
#              rescue Exception=>e
#                devicemake = ""
#              end
#            end
#            date = Date.parse "#{row[20]}"
#            if params[:timetocheck].eql?("1")
#              date = Date.parse "#{row[19]}"
#            end
#            dateonly = date.strftime('%Y-%m-%d')
#            datehash[dateonly].push(row[1])
#            paidamount = row[14].to_f
#            paidamount100 = paidamount * 100
#            logger.info("Paid amount: #{paidamount}      paidamount100: #{paidamount100}")
#            moneyusdvalue = 0
#            begin
#            if !row[13].nil?
#              moneyusdvalue = (row[13].to_f * row[14].to_f).to_f.round(2)
#            else
#              moneyusdvalue = (bank.get_rate(row['currency'], :USD).to_f.round(2) * row[14].to_f.round(2)).round(2)
#            end
#
#            rescue Exception=>e
#              moneyusd = 0
#              moneyusdvalue = 0
#            end
#            csv << [row[1], row[3], row[4], row[5], row[6], row[7], row[8], row[9], row[10], row[17], row[11], row[12], row[14], moneyusdvalue, moneyusd*0.7, row[15],row[18].force_encoding("UTF-8"),devicemake, row[16], "#{row[21]} PDT", row[24], "#{row[20]} PDT", "#{row[19]} UTC", "#{convert_second_to_hhmmss(row[22].to_i)} (dd:hh:mm:ss)"]
#          end
#          }
#        
#        }

        if (params[:selectexporttype].eql?("doc"))
          begin
            @file_array_upload = Dir.glob("#{Rails.root}/exportedfile/purchases_ios/*.csv").sort
            @file_array_link = []
#            dir = "#{Rails.root}/exportedfile/purchases_ios"
#            Dir.foreach(dir) do |item|
#               item_path = "#{dir}/#{item}"
#               if ((!item.index(".csv").nil?))
#                 #send_file("#{item_path}", :disposition => :attachment)
#                 @file_array_upload.push("#{item_path}")
#               end
#            end
            @file_array_upload.each_with_index do |row, i|
              a = session[:googleacount].upload_from_file(row.to_s, "Production Purchase IOS in #{params[:purchasestartdate]} - #{params[:purchaseenddate]} Part #{i+1}", :content_type => "text/csv")
              a.acl.push({:scope_type => "user", :scope => "tr-support@lum.ba", :role => "writer"})
              url = a.human_url()
              #url = a.human_url()
              logger.info("url: #{url}")
              urls = url.split("/d/")
              logger.info("urls: #{urls}")
              key = urls[1].split("/")[0]
              logger.info("key: #{key}")
              @file_array_link.push(url)
              `sync && echo 3 > /proc/sys/vm/drop_caches`
            end
          rescue Exception => e
            @error_string = e.to_s
            logger.info("@error_string2: #{@error_string}")
          end
        else
          dir = "#{Rails.root}/exportedfile/purchases_ios"
          `cd #{dir};zip #{bundle_filename} *.csv`
#          Zip::ZipFile.open(bundle_filename, Zip::ZipFile::CREATE) { |zipfile|
#            Dir.foreach(dir) do |item|
#              item_path = "#{dir}/#{item}"
#              if ((!item.index(".csv").nil?) && (zipfile.find_entry(item).nil?))
#                zipfile.add( "#{item}",item_path) if File.file?item_path
#              end
#            end
#          }
          `sync && echo 3 > /proc/sys/vm/drop_caches`
          send_file("#{bundle_filename}", :disposition => :attachment)
          GC.start

        end
      end
      logger.info("@error_string: #{@error_string}")
      @error_string
    elsif (params[:downloadexportfile])
      send_file("#{params[:itempath]}", :disposition => :attachment)
=begin
    elsif params[:downloadpurchaseandroid]
      connectLumbaIAP
      str_query = "SELECT userId, SUM(IF(status='Valid',1,0)) CORRECT, SUM(IF(status>'Valid',1,0)) INVALID, SUM(IF(status='Duplicate',1,0)) DUPLICATES, SUM(IF(status='No verification response',1,0)) NOVERIFICATIONRESPONSE,SUM(IF(status='Not verified',1,0)) NOTVERIFIED,SUM(IF(status='Not handled',1,0)) NOTHANDLE,SUM(IF(status='Product not in the list',1,0)) PRODUCTNOTINTHELIST FROM purchases WHERE platform = 'android' and createdAt > '#{params[:purchasestartdate]} 00:00:00' and createdAt < '#{params[:purchaseenddate]} 00:00:00' GROUP BY userId ORDER BY DUPLICATES DESC"
      str_query_detail = "select * from purchases WHERE platform = 'android' and createdAt > '#{params[:purchasestartdate]} 00:00:00' and createdAt < '#{params[:purchaseenddate]} 00:00:00'"
      datapurchase = @dbsfs.query(str_query)
      datapurchase_detail = @dbsfs.query(str_query_detail)
      disconnectLumbaIAP
      CSV.open("#{Rails.root}/exportedfile/purchases_android/purchase_summary_android.txt", "w:UTF-8", {:col_sep => "\t"}) { |csv|
        csv << ["userId", "CORRECT", "INVALID", "DUPLICATES", "NOVERIFICATIONRESPONSE", "NOTVERIFIED", "NOTHANDLE", "PRODUCTNOTINTHELIST"]
        datapurchase.each_hash do |row|
          csv << [row['userId'], row['CORRECT'], row['INVALID'], row['DUPLICATES'], row['NOVERIFICATIONRESPONSE'], row['NOTVERIFIED'], row['NOTHANDLE'], row['PRODUCTNOTINTHELIST']]
        end
      }
      CSV.open("#{Rails.root}/exportedfile/purchases_android/purchase_details_android.txt", "w:UTF-8", {:col_sep => "\t"}) { |csv|
        csv << ["userId", "DiwanLevel", "GameLevel", "Coins", "Water", "Oil", "Pearls", "Daggers", "Status", "purchasedPearls", "purchasedItemId", "paidAmount", "currency", "country", "installAt", "createdAt"]
        datapurchase_detail.each_hash do |row|
          csv << [row['userId'], row['diwanLevel'], row['gameLevel'], row['coins'], row['water'], row['oil'], row['pearls'], row['daggers'], row['status'], row['purchasedPearls'], row['purchasedItemId'], row['paidAmount'], row['currency'], row['country'], row['installAt
'], row['createdAt']]
        end
      }
      bundle_filename = "#{Rails.root}/exportedfile/purchases_android.zip"
      `rm #{bundle_filename}`
      dir = "#{Rails.root}/exportedfile/purchases_android"
      Zip::ZipFile.open(bundle_filename, Zip::ZipFile::CREATE) { |zipfile|
        Dir.foreach(dir) do |item|
          item_path = "#{dir}/#{item}"
          if ((!item.index(".txt").nil?) && (zipfile.find_entry(item).nil?))
            zipfile.add("#{item}", item_path) if File.file? item_path
          end
        end
      }
      #send_file("#{bundle_filename}", :disposition => :attachment)
      if session[:googleacount].nil?
        logger.info("vao googlesession nil")
        session[:googleacount] = GoogleDrive.login("dashboard@lum.ba", "181fremont")
      end
      begin
        session[:googleacount] = GoogleDrive.login("dashboard@lum.ba", "181fremont")
        a = session[:googleacount].upload_from_file("#{Rails.root}/exportedfile/purchases_android/purchase_details_android.txt", "Production Purchase Android in #{params[:purchasestartdate]} - #{params[:purchaseenddate]}", :content_type => "text/tab-separated-values")
        a.acl.push({:scope_type => "user", :scope => "tr-support@lum.ba", :role => "writer"})
        logger.info(a.inspect)
        url = a.human_url()
        @error_string = url
      rescue Exception => e
        @error_string = e.to_s
        logger.info("@error_string2: #{@error_string}")
      end
=end
    end
    if (params[:newpurchaseView])
      date_array = (Date.parse("#{params[:purchasestartdate]}") .. Date.parse("#{params[:purchaseenddate]}")).to_a
      CSV.open("#{Rails.root}/exportedfile/purchase_new_paying.txt", "w:UTF-8", {:col_sep => "\t"}) { |csv|
        csv << ["Date (00:00:00 - 23:59:59 UTC-7)", "Total new paying"]
        connectLumbaIAP
        date_array.each { |d|
          newpurchases = 0
          starttime = Time.parse("#{d} 00:00:00 -08:00").utc
          endtime = Time.parse("#{d} 23:59:59 -08:00").utc
          #str = "SELECT userId, SUM(IF(status = 'Valid' && createdAt >= '#{starttime}' && createdAt <= '#{endtime}',1,0)) as TODAY, SUM(IF(status = 'Valid' && createdAt < '#{starttime}',1,0)) NOTTODAY FROM purchases group by userId HAVING TODAY > 0 AND NOTTODAY = 0 order by TODAY desc"
          #strnew = "SELECT COUNT(*) as newpayingusers FROM (SELECT DISTINCT userId FROM lumba_iap.purchases p1 WHERE status = 'Valid' AND createdAt BETWEEN '#{starttime}' AND '#{endtime}' AND NOT EXISTS (SELECT * FROM lumba_iap.purchases p2 WHERE p2.userId = p1.userId AND createdAt < '#{starttime}' AND status = 'Valid')) test1"
          str_new = "SELECT userId FROM lumba_iap.purchases p1 WHERE status = 'Valid' AND createdAt BETWEEN '#{starttime}' AND '#{endtime}' AND NOT EXISTS (SELECT * FROM lumba_iap.purchases p2 WHERE p2.userId = p1.userId AND createdAt < '#{starttime}' AND status = 'Valid')"
=begin
          #str_query_newpurchase = "SELECT userId, SUM(IF(status = 'Valid' && createdAt >= '#{d} 00:00:00' && createdAt <= '#{d} 23:59:59',1,0)) as TODAY, SUM(IF(status = 'Valid' && createdAt < '#{d} 00:00:00',1,0)) NOTTODAY FROM purchases group by userId HAVING TODAY > 0 AND NOTTODAY = 0 order by TODAY desc;"
          newpurchases_tmp = @dbsfs.query(str)
          newpurchases_tmp.each_hash do |row|
            newpurchases = newpurchases + 1
          end
          timestart = Time.parse("#{d} 00:00:00").getutc
          timeend = Time.parse("#{d} 23:59:59").getutc
=end
          count_array = []
          count_temp = @dbsfs.query(str_new)
          count_temp.each_hash do |row|
            count_array.push(row['userId'])
          end
          count_array = count_array.uniq
          #newpurchases = @dbsfs.query(strnew).fetch_hash['newpayingusers']
          csv << [d, count_array.size]
        }
      }
      disconnectLumbaIAP
      # google spreadsheet
      if session[:googleacount].nil?
        logger.info("vao googlesession nil")
        session[:googleacount] = GoogleDrive.login("dashboard@lum.ba", "181fremont")
      end
      begin
        session[:googleacount] = GoogleDrive.login("dashboard@lum.ba", "181fremont")
        a = session[:googleacount].upload_from_file("#{Rails.root}/exportedfile/purchase_new_paying.txt", "New Paying user", :content_type => "text/tab-separated-values")
        a.acl.push({:scope_type => "user", :scope => "tr-support@lum.ba", :role => "writer"})
        logger.info(a.inspect)
        url = a.human_url()
        @error_string = url
      rescue Exception => e
        @error_string = e.to_s
        logger.info("@error_string2: #{@error_string}")
      end
      #send_file("#{Rails.root}/exportedfile/purchase_new_paying.txt", :disposition => :attachment)
    end

    # Unique paying
    if (params[:uniquepurchaseView])
      date_array = (Date.parse("#{params[:purchasestartdate]}") .. Date.parse("#{params[:purchaseenddate]}")).to_a
      CSV.open("#{Rails.root}/exportedfile/purchase_unique_paying.txt", "w:UTF-8", {:col_sep => "\t"}) { |csv|
        if params[:timetocheck].eql?("0")
          csv << ["Date (00:00:00 - 23:59:59 PT)", "Total unique paying"]
        else
          csv << ["Date (00:00:00 - 23:59:59 UTC)", "Total unique paying"]
        end
        connectLumbaIAP
        date_array.each { |d|
          newpurchases = 0
          starttime = Time.parse("#{d} 00:00:00 +00:00").utc
          endtime = Time.parse("#{d} 23:59:59 +00:00").utc
          # if PT time is selected
          if params[:timetocheck].eql?("0")
            starttime = Time.parse("#{d} 00:00:00 -08:00").utc
            endtime = Time.parse("#{d} 23:59:59 -08:00").utc
          end
          str = "SELECT count(distinct userId) as TotalUniquePaying from purchases where createdAt >= '#{starttime}' and createdAt <= '#{endtime}'"
          uniquepaying = @dbsfs.query(str).fetch_hash['TotalUniquePaying']
          csv << [d, uniquepaying]
        }
      }
      disconnectLumbaIAP
      # google spreadsheet
      if session[:googleacount].nil?
        logger.info("vao googlesession nil")
        session[:googleacount] = GoogleDrive.login("dashboard@lum.ba", "181fremont")
      end
      begin
        session[:googleacount] = GoogleDrive.login("dashboard@lum.ba", "181fremont")
        a = session[:googleacount].upload_from_file("#{Rails.root}/exportedfile/purchase_unique_paying.txt", "Unique Paying user", :content_type => "text/tab-separated-values")
        a.acl.push({:scope_type => "user", :scope => "tr-support@lum.ba", :role => "writer"})
        logger.info(a.inspect)
        url = a.human_url()
        @error_string = url
      rescue Exception => e
        @error_string = e.to_s
        logger.info("@error_string2: #{@error_string}")
      end
    end

    if (params[:totalvalidpurchase])
      date_array = (Date.parse("#{params[:purchasestartdate]}") .. Date.parse("#{params[:purchaseenddate]}")).to_a
      CSV.open("#{Rails.root}/exportedfile/total_valid_purchase.txt", "w:UTF-8", {:col_sep => "\t"}) { |csv|
        if params[:timetocheck].eql?("0")
          csv << ["Date (00:00:00 - 23:59:59 PT)", "Total unique paying"]
        else
          csv << ["Date (00:00:00 - 23:59:59 UTC)", "Total unique paying"]
        end
        connectLumbaIAP
        date_array.each { |d|
          newpurchases = 0
          starttime = Time.parse("#{d} 00:00:00 +00:00").utc
          endtime = Time.parse("#{d} 23:59:59 +00:00").utc
          puts starttime
          puts endtime
          if params[:timetocheck].eql?("0")
            starttime = Time.parse("#{d} 00:00:00 -08:00").utc
            endtime = Time.parse("#{d} 23:59:59 -08:00").utc
          end
          str = "select sum(paidAmount * rateToUSD) as MoneyUSD from purchases where createdAt >= '#{starttime}' and createdAt <= '#{endtime}' and status = 'Valid';"
          total_valid_purchases = @dbsfs.query(str).fetch_hash['MoneyUSD']
          csv << [d, total_valid_purchases.to_f.round(2)]
        }
      }
      disconnectLumbaIAP
      if session[:googleacount].nil?
        logger.info("vao googlesession nil")
        session[:googleacount] = GoogleDrive.login("dashboard@lum.ba", "181fremont")
      end
      begin
        session[:googleacount] = GoogleDrive.login("dashboard@lum.ba", "181fremont")
        a = session[:googleacount].upload_from_file("#{Rails.root}/exportedfile/total_valid_purchase.txt", "Total valid purchase", :content_type => "text/tab-separated-values")
        a.acl.push({:scope_type => "user", :scope => "tr-support@lum.ba", :role => "writer"})
        logger.info(a.inspect)
        url = a.human_url()
        @error_string = url
      rescue Exception => e
        @error_string = e.to_s
        logger.info("@error_string2: #{@error_string}")
      end
    end

    if (params[:topclanpurchase])
      puts params[:purchasestartdate]
      puts params[:purchaseenddate]
      date_array = ( Date.parse("#{params[:purchasestartdate]}") .. Date.parse("#{params[:purchaseenddate]}") ).to_a
      CSV.open("#{Rails.root}/exportedfile/top_clan_id_#{params[:topclan]}_purchase.txt", "w:UTF-8", {:col_sep => "\t"}) { |csv|
        if params[:timetocheck].eql?("0")
          csv << ["Date (00:00:00 - 23:59:59 PT)", "Players name", "Players ID", "Clan Name", "Total valid purchases"]
        else
          csv << ["Date (00:00:00 - 23:59:59 PT)", "Players name", "Players ID", "Clan Name", "Total valid purchases"]
        end
        connectLumba
        memberidsquery = @dblumba.query("SELECT memberIds FROM clan_v31 where id = '#{params[:topclan]}';").fetch_hash['memberIds']
        @clanname = @dblumba.query("SELECT name FROM clan_v31 where id = '#{params[:topclan]}';").fetch_hash['name']
        memberidslist = JSON.parse(memberidsquery)
        begin
          memberidslist['list'].each do |row|
            @memberid = row
            @membername = @dblumba.query("SELECT name FROM user_v31 where userId = '#{row}';").fetch_hash['name']

            connectLumbaIAP
            date_array.each { |d|
              newpurchases = 0
              starttime = Time.parse("#{d} 00:00:00 +00:00").utc
              endtime = Time.parse("#{d} 23:59:59 +00:00").utc
              if params[:timetocheck].eql?("0")
                starttime = Time.parse("#{d} 00:00:00 -07:00").utc
                endtime = Time.parse("#{d} 23:59:59 -07:00").utc
              end
              uservalidpurchase = "select sum(paidAmount * rateToUSD) as MoneyUSD from purchases where createdAt >= '#{starttime}' and createdAt <= '#{endtime}' and status = 'Valid' and userId = '#{row}';"
              userpurchases = @dbsfs.query(uservalidpurchase).fetch_hash['MoneyUSD']
              if (!(userpurchases.to_i).eql? 0)
                csv << [d, @membername.force_encoding("utf-8"), row, @clanname.force_encoding("utf-8"), userpurchases.to_f.round(2)]
              end
            }
          end
        rescue Exception => e
          @error_string = e.to_s
        end
        disconnectLumba
      }
      disconnectLumbaIAP
      # send_file("#{Rails.root}/exportedfile/top_clan_id_#{params[:topclan]}_purchase.txt", :disposition => :attachment)
      if session[:googleacount].nil?
        logger.info("vao googlesession nil")
        session[:googleacount] = GoogleDrive.login("dashboard@lum.ba", "181fremont")
      end
      begin
        session[:googleacount] = GoogleDrive.login("dashboard@lum.ba", "181fremont")
        a = session[:googleacount].upload_from_file("#{Rails.root}/exportedfile/top_clan_id_#{params[:topclan]}_purchase.txt", "Top Clan id #{params[:topclan]} valid purchase", :content_type => "text/tab-separated-values")
        a.acl.push({:scope_type => "user", :scope => "tr-support@lum.ba", :role => "writer"})
        logger.info(a.inspect)
        url = a.human_url()
        @error_string = url
      rescue Exception => e
        @error_string = e.to_s
        logger.info("@error_string2: #{@error_string}")
      end
    end

    connectLumbaAppData
    @game_versions = @db.query("select distinct NextGameVersion from ref_Setting order by NextGameVersion")
    getuniqgameversion
    disconnectLumbaAppData
  end

  def setting
    if (session[:user]['username'].eql?("emilio"))
      redirect_to "/lumba/gamedata/campaign"
      return true
    end
    @error_string = ""
    if !params[:error_string].nil?
      @error_string = CGI.unescape(params[:error_string])
    end
    @error_string = ""
    t = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    @selectedWS = "setting"
    if (params[:exportsettinginfo])
      properties_config = YAML.load_file("#{Rails.root}/config/properties.yml")
      if File.exist?("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/Setting.txt")
        `rm #{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/Setting.txt`
      end
      connectLumbaAppData
      datas_settinginfo = @db.query("select * from ref_SettingInfo where game_version = '#{@game_version}'")
      disconnectLumbaAppData
      # get purchase value
      pile_Of_Gems_en = 0
      pile_Of_Gems_ar = 0
      bag_Of_Gems_en = 0
      pag_Of_Gems_ar = 0
      sack_Of_Gems_en = 0
      sack_Of_Gems_ar = 0
      box_Of_Gems_en = 0
      box_Of_Gems_ar = 0
      chest_Of_Gems_en = 0
      chest_Of_Gems_ar = 0
      products=params[:purchase_products]
      products_arr = products.split(",")
      if products_arr.size > 0
        if (!products_arr[0].nil?)
          pile_Of_Gems_en = products_arr[0].to_i
          pile_Of_Gems_ar = products_arr[0].to_i
        end
        if (!products_arr[1].nil?)
          bag_Of_Gems_en = products_arr[1].to_i
          pag_Of_Gems_ar = products_arr[1].to_i
        end
        if (!products_arr[2].nil?)
          sack_Of_Gems_en = products_arr[2].to_i
          sack_Of_Gems_ar = products_arr[2].to_i
        end
        if (!products_arr[3].nil?)
          box_Of_Gems_en = products_arr[3].to_i
          box_Of_Gems_ar = products_arr[3].to_i
        end
        if (!products_arr[4].nil?)
          chest_Of_Gems_en = products_arr[4].to_i
          chest_Of_Gems_ar = products_arr[4].to_i
        end
        CSV.open("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/Setting.txt", "w:UTF-8", {:col_sep => "\t"}) { |csv|
          csv << ["Key", "Value", "English Version", "Arabic Version"]
          save_interval = ""
          iap_ratio = ""
          datas_settinginfo.each_hash do |row|
            save_interval = row['SAVE_INTERVAL']
            iap_ratio = row['IAP_RATIO']
            csv << ["SAVE_INTERVAL", save_interval, nil, nil]
            csv << ["PING_INTERVAL_SECONDS", row['PING_INTERVAL_SECONDS'], nil, nil]
            csv << ["REQUEST_TIME_OUT", row['REQUEST_TIME_OUT'], nil, nil]
            csv << ["SHOULD_FIND_SFS_SERVER", row['SHOULD_FIND_SFS_SERVER'], nil, nil]
            csv << ["IAP_RATIO", iap_ratio, nil, nil]
            csv << ["Pile_Of_Gems", nil, pile_Of_Gems_en, pile_Of_Gems_ar]
            csv << ["Bag_Of_Gems", nil, bag_Of_Gems_en, pag_Of_Gems_ar]
            csv << ["Sack_Of_Gems", nil, sack_Of_Gems_en, sack_Of_Gems_ar]
            csv << ["Box_Of_Gems", nil, box_Of_Gems_en, box_Of_Gems_ar]
            csv << ["Chest_Of_Gems", nil, chest_Of_Gems_en, chest_Of_Gems_ar]
            csv << ["Gem_Range_For_Calculate_Time", row['Gem_Range_For_Calculate_Time'], nil, nil]
            csv << ["Gold_Water_Range", row['Gold_Water_Range'], nil, nil]
            csv << ["Oil_Range", row['Oil_Range'], nil, nil]
            csv << ["Gem_Range_For_Calculate_Resource", row['Gem_Range_For_Calculate_Resource'], nil, nil]
            csv << ["TERM_SERVICE_LINK", row['TERM_SERVICE_LINK'], row['TERM_SERVICE_LINK_EN'], row['TERM_SERVICE_LINK_AR']]
            csv << ["POLICY_LINK", row['POLICY_LINK'], row['POLICY_LINK_EN'], row['POLICY_LINK_AR']]
            csv << ["FACEBOOK_LINK", row['FACEBOOK_LINK'], nil, nil]
            csv << ["TWITTER_LINK", row['TWITTER_LINK'], nil, nil]
            csv << ["COME_BACK_NOTIFICATION_DURATION", row['COME_BACK_NOTIFICATION_DURATION'], nil, nil]
            csv << ["SIGNATURE_ORDER", row['SIGNATURE_ORDER'], nil, nil]
            csv << ["GAME_MAINTAIN", row['GAME_MAINTAIN'], nil, nil]
            csv << ["ENABLE_LOG", row['ENABLE_LOG'], nil, nil]
            csv << ["ENABLE_ADJUST_LOG", row['ENABLE_ADJUST_LOG'],nil, nil]
            csv << ["MAX_LOG", row['MAX_LOG'], nil, nil]
            csv << ["ENABLE_IAP_LOG", row['ENABLE_IAP_LOG'], nil, nil]
            csv << ["CHAT_INTERVAL", row['CHAT_INTERVAL'], nil, nil]
            csv << ["SAVE_HISTORY_MINUTES", row['SAVE_HISTORY_MINUTES'], nil, nil]
            csv << ["SEND_TROOP_SECONDS", row['SEND_TROOP_SECONDS'], nil, nil]
          end
        }
        if checkpassword(params[:confirmpassword])
          copy_file_to_server("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/Setting.txt", params[:game_version], params[:exportserver])
          my_logger.info("#{session[:user]['username']} exported Setting.txt lastMod = '#{t.to_s}'")
        else
          @error_string = "Invalid password"
        end
      else
        @error_string = "Can not publish! Please check purchase value"
      end
    end
    if (params[:exportsetting])
      connectLumbaAppData
      @datas = @db.query("select * from ref_Setting order by pkID desc limit 1")
      disconnectLumbaAppData
      properties_config = YAML.load_file("#{Rails.root}/config/properties.yml")
      maintainVersions = ""
      enableGhost = ""
      if File.exist?("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/Setting.txt")
        `rm #{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/Setting.txt`
      end
      if File.exist?("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/Properties.txt")
        `rm #{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/Properties.txt`
      end
      if File.exist?("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/version.properties")
        `rm #{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/version.properties`
      end
      CSV.open("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/Setting.txt", "w:UTF-8", {:col_sep => "\t"}) { |csv|
        csv << ["SaveInterval"]
        @datas.each_hash do |row|
          csv << [row['SaveInterval']]
          maintainVersions = row['maintainVersions']
          enableGhost = row['enableGhost']
          file = File.open("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/Properties.txt", 'a:UTF-8') { |file| file.puts("versions=#{row['GameVersion']},#{row['NextGameVersion']}\nmaintainVersions=#{row['maintainVersions']}\nsubVersions=#{row['subVersions']}\nforcedUpdateSubVersionClanIds=#{row['forcedUpdateSubVersionClanIds']}\nen_iosAppUrl=#{row['en_iosAppUrl']}\nen_androidAppUrl=#{row['en_androidAppUrl']}\nar_iosAppUrl=#{row['ar_iosAppUrl']}\nar_androidAppUrl=#{row['ar_androidAppUrl']}\nforcedUpdateClanIds=#{row['forcedUpdateClanIds']}\nsoftMovedVersions=#{row['softMovedVersions1']},#{row['softMovedVersions2']}\nresourceFileNames=#{row['resourceFileNames']}") }
          file = File.open("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/version.properties", 'a:UTF-8') { |file| file.puts("version=#{row['GameVersion']}") }
          file = File.open("#{Rails.root}/exportedfile/nextversionserver/version.properties", 'w:UTF-8') { |file| file.puts("version=#{row['softMovedVersions2']}") }
        end
      }
      # create maintain file to sfs server
      if !(maintainVersions.eql?(""))
        sfsserverfromversion = getsfsserverfromversion(maintainVersions)
        if !(sfsserverfromversion.eql?(""))
          file = File.open("#{Rails.root}/exportedfile/sfs/server_status.properties", 'w:UTF-8') { |file| file.puts("maintain=true\nenableGhost=#{enableGhost}") }
          upfileto_sfs_server_custom(sfsserverfromversion, "#{Rails.root}/exportedfile/sfs/server_status.properties")
        end
      else
        sfsserverfromversion = getsfsserverfromversion(maintainVersions)
        if !(sfsserverfromversion.eql?(""))
          file = File.open("#{Rails.root}/exportedfile/sfs/server_status.properties", 'w:UTF-8') { |file| file.puts("maintain=false\nenableGhost=#{enableGhost}") }
          upfileto_sfs_server_custom(sfsserverfromversion, "#{Rails.root}/exportedfile/sfs/server_status.properties")
        end
      end

      if checkpassword(params[:confirmpassword])
        #copy_property_to_server("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/Setting.txt", params[:exportserver])
        copy_property_to_server("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/Properties.txt", params[:exportserver])
        my_logger.info("#{session[:user]['username']} exported Setting.txt and Properties.txt lastMod = '#{t.to_s}'")
      else
        @error_string = "Invalid password"
      end
    elsif (params[:actionupdateinfo])
      connectLumbaAppData
      @db.query("delete from ref_SettingInfo where game_version = '#{@game_version}'")
      str_query = "insert into ref_SettingInfo set SAVE_INTERVAL = '#{params[:settinfoSaveInterval]}', IAP_RATIO = '#{params[:settinfoIapRatio]}', game_version = '#{@game_version}', Gem_Range_For_Calculate_Time = '#{params[:settinggemrangeforcalculatetime]}', Gold_Water_Range = '#{params[:settinggoldwaterrange]}', Oil_Range = '#{params[:settingoilrange]}', Gem_Range_For_Calculate_Resource = '#{params[:settinggemrangeforcalculateresource]}', TERM_SERVICE_LINK_EN = '#{params[:settingTERM_SERVICE_LINK_EN]}', TERM_SERVICE_LINK_AR = '#{params[:settingTERM_SERVICE_LINK_AR]}', POLICY_LINK_EN = '#{params[:settingPOLICY_LINK_EN]}', POLICY_LINK_AR = '#{params[:settingPOLICY_LINK_AR]}', FACEBOOK_LINK = '#{params[:settingFACEBOOK_LINK]}', TWITTER_LINK = '#{params[:settingTWITTER_LINK]}', COME_BACK_NOTIFICATION_DURATION = '#{params[:settingCOME_BACK_NOTIFICATION_DURATION]}', SIGNATURE_ORDER = '#{params[:settingSIGNATURE_ORDER]}', SHOULD_FIND_SFS_SERVER = '#{params[:settingSHOULD_FIND_SFS_SERVER]}', SAVE_HISTORY_MINUTES = '#{params[:settingSAVE_HISTORY_MINUTES]}', SEND_TROOP_SECONDS = '#{params[:settingSEND_TROOP_SECONDS]}', GAME_MAINTAIN = '#{params[:settingGAME_MAINTAIN]}', ENABLE_LOG = '#{params[:settingENABLE_LOG]}', ENABLE_ADJUST_LOG = '#{params[:settingENABLE_ADJUST_LOG]}', ENABLE_IAP_LOG = '#{params[:settingENABLE_IAP_LOG]}', CHAT_INTERVAL = '#{params[:settingCHAT_INTERVAL]}', MAX_LOG = '#{params[:settingMAX_LOG]}', PING_INTERVAL_SECONDS = '#{params[:settingPING_INTERVAL_SECONDS]}', REQUEST_TIME_OUT = '#{params[:settingREQUEST_TIME_OUT]}'"
      @db.query(str_query)
      disconnectLumbaAppData
    elsif (params[:actionupdate])
      #insert_new_gameversion_data(params[:settsoftMovedVersions1], params[:settsoftMovedVersions2])
      connectLumbaAppData
      str_query = "insert into ref_Setting set SaveInterval = '#{params[:settSaveInterval]}', GameVersion = '#{params[:settGameVersion]}', ComicVersionIOS = '#{params[:settComicVersionIOS]}', ComicVersionAndr = '#{params[:settComicVersionAndr]}', NextGameVersion = '#{params[:settNextGameVersion]}', maintainVersions = '#{params[:settmaintainVersions]}',enableGhost = '#{params[:settEnableGhost]}', subVersions = '#{params[:settingsubVersions]}', forcedUpdateSubVersionClanIds = '#{params[:settingsubVersionsClanIds]}', forcedUpdateClanIds = '#{params[:settforcedUpdateClanIds]}', softMovedVersions1 = '#{params[:settsoftMovedVersions1]}', softMovedVersions2 = '#{params[:settsoftMovedVersions2]}', resourceFileNames = '#{params[:settresourceFileNames]}', en_androidAppUrl = '#{params[:settandroidAppUrl_en]}', en_iosAppUrl = '#{params[:settiosAppUrl_en]}', ar_androidAppUrl = '#{params[:settandroidAppUrl_ar]}', ar_iosAppUrl = '#{params[:settiosAppUrl_ar]}', lastMod = '#{t.to_s}'"
      @db.query(str_query)
      @datas = @db.query("select * from ref_Setting order by pkID desc limit 1")
      disconnectLumbaAppData
      my_logger.info(str_query)
    else
      connectLumbaAppData
      @datas = @db.query("select * from ref_Setting order by pkID desc limit 1")
      disconnectLumbaAppData
    end
    connectLumbaAppData
    @game_versions = @db.query("select distinct NextGameVersion from ref_Setting order by NextGameVersion")
    getuniqgameversion
    @datas = @db.query("select * from ref_Setting order by pkID desc limit 1")
    disconnectLumbaAppData
    @datas
    # setting smartfox
    if (params[:actionupdatesfs])
      connectLumbaIAP
      str_query = ""
      if (params[:settsfsandroidNewVersionUrl].eql?("undefined"))
        str_query = "update versions set fromVersion = '#{params[:settsfsfromVersion]}', toVersion = '#{params[:settsfstoVersion]}', updateType = '#{params[:settsfsupdateType]}', description = '#{params[:settsfsdescription]}', iosNewVersionUrl = '#{params[:settsfsiosNewVersionUrl]}', androidNewVersionUrl = '' where id = '#{params[:id]}'"
      elsif (params[:settsfsiosNewVersionUrl].eql?("undefined"))
        str_query = "update versions set fromVersion = '#{params[:settsfsfromVersion]}', toVersion = '#{params[:settsfstoVersion]}', updateType = '#{params[:settsfsupdateType]}', description = '#{params[:settsfsdescription]}', iosNewVersionUrl = '', androidNewVersionUrl = '#{params[:settsfsandroidNewVersionUrl]}' where id = '#{params[:id]}'"
      else
        str_query = "update versions set fromVersion = '#{params[:settsfsfromVersion]}', toVersion = '#{params[:settsfstoVersion]}', updateType = '#{params[:settsfsupdateType]}', description = '#{params[:settsfsdescription]}', iosNewVersionUrl = '#{params[:settsfsiosNewVersionUrl]}', androidNewVersionUrl = '#{params[:settsfsandroidNewVersionUrl]}' where id = '#{params[:id]}'"
      end
      @dbsfs.query(str_query)
      @datasfs = @dbsfs.query("select * from versions order by id desc limit 1")
      disconnectLumbaIAP
      my_logger.info(str_query)
    elsif (params[:actionaddversionsfs])
      connectLumbaIAP
      str_query = "insert versions set fromVersion = '#{params[:fromversion]}', toVersion = '#{params[:toversion]}', updateType = '#{params[:updatetype]}', description = '#{params[:description]}', iosNewVersionUrl = '#{params[:iosnewversionurl]}', androidNewVersionUrl = '#{params[:androidnewversionurl]}'"
      puts str_query
      @dbsfs.query(str_query)
      @datasfs = @dbsfs.query("select * from versions order by id desc limit 1")
      disconnectLumbaIAP
      my_logger.info(str_query)
    else
      connectLumbaIAP
      @datasfs = @dbsfs.query("select * from versions order by id desc limit 1")
      disconnectLumbaIAP
    end
    connectLumbaIAP
    @datasfs = @dbsfs.query("select * from versions order by id desc limit 1")
    disconnectLumbaIAP
    @datasfs
    # setting tournamentDuration to sfs server
    if (params[:publishtournamentDuration])
      #upload tournamentDuration to server 1
      endtime = params[:tournamentDuration_endtime]
      file = File.open("#{Rails.root}/exportedfile/sfs/tournamentDuration.txt", 'w:UTF-8') { |file| file.puts("duration=#{params[:tournamentDuration]}\nstarttime=#{endtime}\nrewards=#{params[:tournamentDuration_rewards]}") }
      upfileto_sfs_server("#{Rails.root}/exportedfile/sfs/tournamentDuration.txt")
    else
      # download tournamentDuration from server
      gettournamentDurationfromserver
    end
    if File.exist?("#{Rails.root}/exportedfile/sfs/tournamentDuration.txt")
      file = File.open("#{Rails.root}/exportedfile/sfs/tournamentDuration.txt", 'r:UTF-8') do |f|
        index = 0
        while line = f.gets
          infoarr = line.split("=")
          if (infoarr[0].eql?("duration"))
            @tournamentDuration = infoarr[1]
          elsif (infoarr[0].eql?("starttime"))
            @tournamentDuration_endtime = infoarr[1]
          elsif (infoarr[0].eql?("rewards"))
            @tournamentDuration_rewards = infoarr[1]
          end
          index = index + 1
        end
        f.close
      end
    else
      @tournamentDuration = ""
      @tournamentDuration_endtime = ""
      @tournamentDuration_rewards = ""
    end

    # dagger_ranges
    if (params[:publish_dagger_ranges])
      file = File.open("#{Rails.root}/exportedfile/sfs/opponent_search.properties", 'w:UTF-8') { |file| file.puts("dagger_ranges=#{params[:dagger_ranges]}") }
      upfileto_sfs_server("#{Rails.root}/exportedfile/sfs/opponent_search.properties")
    else
      get_dagger_ranges_fromserver
    end
    if File.exist?("#{Rails.root}/exportedfile/sfs/opponent_search.properties")
      file = File.open("#{Rails.root}/exportedfile/sfs/opponent_search.properties", 'r:UTF-8') do |f|
        while line = f.gets
          infoarr = line.split("=")
          if (infoarr[0].eql?("dagger_ranges"))
            @dagger_ranges = infoarr[1]
          end
        end
        f.close
      end
    else
      @dagger_ranges = ""
    end

    # attack_matching_limit
    if (params[:publish_match_limit])
      file = File.open("#{Rails.root}/exportedfile/sfs/attack_matching_limit.properties", 'w:UTF-8') { |file| file.puts("match_limit=#{params[:match_limit]}") }
      upfileto_sfs_server("#{Rails.root}/exportedfile/sfs/attack_matching_limit.properties")
    else
      get_attack_matching_limit_fromserver
    end
    if File.exist?("#{Rails.root}/exportedfile/sfs/attack_matching_limit.properties")
      file = File.open("#{Rails.root}/exportedfile/sfs/attack_matching_limit.properties", 'r:UTF-8') do |f|
        while line = f.gets
          infoarr = line.split("=")
          if (infoarr[0].eql?("match_limit"))
            @match_limit = infoarr[1]
          end
        end
        f.close
      end
    else
      @match_limit = ""
    end

    if (params[:saveasdefault])
      saveDetaultValue
    end

    if params[:commit].eql?("Delete Unuse Version")
      connectLumbaAppData
      unuseversions = params[:unuseversions].split(",")
      unuseversions.each { |unuseversion|
        @db.query("delete from ref_Setting where NextGameVersion = '#{unuseversion}'")
      }
      @game_versions = @db.query("select distinct NextGameVersion from ref_Setting order by NextGameVersion")
      getuniqgameversion
      disconnectLumbaAppData
    end

    # setting purchase to sfs server
    if (params[:publishPurchase])
      properties_config = YAML.load_file("#{Rails.root}/config/properties.yml")
      if File.exist?("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/Setting.txt")
        `rm #{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/Setting.txt`
      end
      connectLumbaAppData
      datas_settinginfo = @db.query("select * from ref_SettingInfo where game_version = '#{@game_version}'")
      disconnectLumbaAppData
      pile_Of_Gems_en = 0
      pile_Of_Gems_ar = 0
      bag_Of_Gems_en = 0
      pag_Of_Gems_ar = 0
      sack_Of_Gems_en = 0
      sack_Of_Gems_ar = 0
      box_Of_Gems_en = 0
      box_Of_Gems_ar = 0
      chest_Of_Gems_en = 0
      chest_Of_Gems_ar = 0
      products=params[:purchase_products]
      products_arr = products.split(",")
      if (!products_arr[0].nil?)
        pile_Of_Gems_en = products_arr[0].to_i
        pile_Of_Gems_ar = products_arr[0].to_i
      end
      if (!products_arr[1].nil?)
        bag_Of_Gems_en = products_arr[1].to_i
        pag_Of_Gems_ar = products_arr[1].to_i
      end
      if (!products_arr[2].nil?)
        sack_Of_Gems_en = products_arr[2].to_i
        sack_Of_Gems_ar = products_arr[2].to_i
      end
      if (!products_arr[3].nil?)
        box_Of_Gems_en = products_arr[3].to_i
        box_Of_Gems_ar = products_arr[3].to_i
      end
      if (!products_arr[4].nil?)
        chest_Of_Gems_en = products_arr[4].to_i
        chest_Of_Gems_ar = products_arr[4].to_i
      end
      CSV.open("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/Setting.txt", "w:UTF-8", {:col_sep => "\t"}) { |csv|
        csv << ["Key", "Value", "English Version", "Arabic Version"]
        save_interval = ""
        iap_ratio = ""
        datas_settinginfo.each_hash do |row|
          save_interval = row['SAVE_INTERVAL']
          iap_ratio = row['IAP_RATIO']
          csv << ["SAVE_INTERVAL", save_interval]
          csv << ["PING_INTERVAL_SECONDS", row['PING_INTERVAL_SECONDS'], nil, nil]
          csv << ["REQUEST_TIME_OUT", row['REQUEST_TIME_OUT'],nil, nil]
          csv << ["SHOULD_FIND_SFS_SERVER", row['SHOULD_FIND_SFS_SERVER'], nil, nil]
          csv << ["IAP_RATIO", iap_ratio]
          csv << ["Pile_Of_Gems", nil, pile_Of_Gems_en, pile_Of_Gems_ar]
          csv << ["Bag_Of_Gems", nil, bag_Of_Gems_en, pag_Of_Gems_ar]
          csv << ["Sack_Of_Gems", nil, sack_Of_Gems_en, sack_Of_Gems_ar]
          csv << ["Box_Of_Gems", nil, box_Of_Gems_en, box_Of_Gems_ar]
          csv << ["Chest_Of_Gems", nil, chest_Of_Gems_en, chest_Of_Gems_ar]
          csv << ["Gem_Range_For_Calculate_Time", row['Gem_Range_For_Calculate_Time'], nil, nil]
          csv << ["Gold_Water_Range", row['Gold_Water_Range'], nil, nil]
          csv << ["Oil_Range", row['Oil_Range'], nil, nil]
          csv << ["Gem_Range_For_Calculate_Resource", row['Gem_Range_For_Calculate_Resource'], nil, nil]
          csv << ["TERM_SERVICE_LINK", row['TERM_SERVICE_LINK'], row['TERM_SERVICE_LINK_EN'], row['TERM_SERVICE_LINK_AR']]
          csv << ["POLICY_LINK", row['POLICY_LINK'], row['POLICY_LINK_EN'], row['POLICY_LINK_AR']]
          csv << ["FACEBOOK_LINK", row['FACEBOOK_LINK'], nil, nil]
          csv << ["TWITTER_LINK", row['TWITTER_LINK'], nil, nil]
          csv << ["COME_BACK_NOTIFICATION_DURATION", row['COME_BACK_NOTIFICATION_DURATION'], nil, nil]
          csv << ["SIGNATURE_ORDER", row['SIGNATURE_ORDER'], nil, nil]
          csv << ["GAME_MAINTAIN", row['GAME_MAINTAIN'], nil, nil]
          csv << ["ENABLE_LOG", row['ENABLE_LOG'], nil, nil]
          csv << ["ENABLE_ADJUST_LOG", row['ENABLE_ADJUST_LOG'], nil, nil]
          csv << ["MAX_LOG", row['MAX_LOG'], nil, nil]
          csv << ["CHAT_INTERVAL", row['CHAT_INTERVAL'], nil, nil]
          csv << ["ENABLE_IAP_LOG", row['ENABLE_IAP_LOG'], nil, nil]
          csv << ["SAVE_HISTORY_MINUTES", row['SAVE_HISTORY_MINUTES'], nil, nil]
          csv << ["SEND_TROOP_SECONDS", row['SEND_TROOP_SECONDS'], nil, nil]
        end
      }
      copy_file_to_server("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/Setting.txt", params[:game_version], "production")
      #upload purchase to server 1
      file = File.open("#{Rails.root}/exportedfile/sfs/purchases.txt", 'w:UTF-8') { |file| file.puts("en_identifiers=#{params[:purchase_identifiers_en]}\nar_identifiers=#{params[:purchase_identifiers_ar]}\nproducts=#{params[:purchase_products]}") }
      file = File.open("#{Rails.root}/exportedfile/sfs/kochavastatus.txt", 'w:UTF-8') { |file| file.puts("KOCHAVA_ON=#{params[:kochavastatus]}") }
      upfileto_sfs_server("#{Rails.root}/exportedfile/sfs/purchases.txt")
      upfileto_sfs_server("#{Rails.root}/exportedfile/sfs/kochavastatus.txt")
    else
      # download tournamentDuration from server
      getpurchasesfromserver
    end
    if File.exist?("#{Rails.root}/exportedfile/sfs/purchases.txt")
      file = File.open("#{Rails.root}/exportedfile/sfs/purchases.txt", 'r:UTF-8') do |f|
        while line = f.gets
          str = line.split("=")
          if (str[0].eql?("en_identifiers"))
            @purchase_identifiers_en = str[1]
          end
          if (str[0].eql?("ar_identifiers"))
            @purchase_identifiers_ar = str[1]
          end
          if (str[0].eql?("products"))
            @purchase_products = str[1]
          end
        end
        f.close
      end
    else
      @purchase_identifiers_en = ""
      @purchase_identifiers_ar = ""
      @purchase_products = ""
    end
    getkochavastatusfromserver
    if File.exist?("#{Rails.root}/exportedfile/sfs/kochavastatus.txt")
      file = File.open("#{Rails.root}/exportedfile/sfs/kochavastatus.txt", 'r:UTF-8') do |f|
        while line = f.gets
          str = line.split("=")
          if (str[0].eql?("KOCHAVA_ON"))
            @kochava_on = str[1]
          end
        end
        f.close
      end
    else
      @kochava_on = 0
    end
    # for SAVE_INTERVAL and IAP_RATIO
    @save_interval = ""
    @iap_ratio = ""
    connectLumbaAppData
    @datas_settinginfo = @db.query("select * from ref_SettingInfo where game_version = '#{@game_version}'")
    datas_settinginfo = @datas_settinginfo
    datas_settinginfo.each_hash do |row|
      @save_interval = row['SAVE_INTERVAL']
      @iap_ratio = row['IAP_RATIO']
    end
    @datas_settinginfo = @db.query("select * from ref_SettingInfo where game_version = '#{@game_version}'")
    disconnectLumbaAppData
  end

  def insert_new_gameversion_data(settsoftMovedVersions1, settsoftMovedVersions2)
    t = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    connectLumbaAppData
    # setting info
    datas = @db.query("select * from ref_SettingInfo where game_version = '#{settsoftMovedVersions1}'")
    datas.each_hash do |row|
      str_delete = "delete from ref_SettingInfo where game_version = '#{settsoftMovedVersions2}'"
      @db.query(str_delete)
      str_insert = "insert into ref_SettingInfo set SAVE_INTERVAL = \"#{row['SAVE_INTERVAL']}\", IAP_RATIO = \"#{row['IAP_RATIO']}\", Gem_Range_For_Calculate_Time = \"#{row['Gem_Range_For_Calculate_Time']}\", Gold_Water_Range = \"#{row['Gold_Water_Range']}\", Oil_Range = \"#{row['Oil_Range']}\", Gem_Range_For_Calculate_Resource = \"#{row['Gem_Range_For_Calculate_Resource']}\", TERM_SERVICE_LINK = \"#{row['TERM_SERVICE_LINK']}\", TERM_SERVICE_LINK_EN = \"#{row['TERM_SERVICE_LINK_EN']}\", TERM_SERVICE_LINK_AR = \"#{row['TERM_SERVICE_LINK_AR']}\", POLICY_LINK = \"#{row['POLICY_LINK']}\",POLICY_LINK_EN = \"#{row['POLICY_LINK_EN']}\", POLICY_LINK_AR = \"#{row['POLICY_LINK_AR']}\", FACEBOOK_LINK = \"#{row['FACEBOOK_LINK']}\", TWITTER_LINK = \"#{row['TWITTER_LINK']}\", COME_BACK_NOTIFICATION_DURATION = \"#{row['COME_BACK_NOTIFICATION_DURATION']}\", SIGNATURE_ORDER =\"#{row['SIGNATURE_ORDER']}\", SHOULD_FIND_SFS_SERVER =\"#{row['SHOULD_FIND_SFS_SERVER']}\", SEND_TROOP_SECONDS =\"#{row['SEND_TROOP_SECONDS']}\", SAVE_HISTORY_MINUTES =\"#{row['SAVE_HISTORY_MINUTES']}\", ENABLE_LOG = #{row['ENABLE_LOG']}, ENABLE_ADJUST_LOG = #{row['ENABLE_ADJUST_LOG']}, PING_INTERVAL_SECONDS = #{row['PING_INTERVAL_SECONDS']}, REQUEST_TIME_OUT = #{row['REQUEST_TIME_OUT']}, ENABLE_IAP_LOG = #{row['ENABLE_IAP_LOG']}, CHAT_INTERVAL = #{row['CHAT_INTERVAL']}, MAX_LOG = #{row['MAX_LOG']}, GAME_MAINTAIN =\"#{row['GAME_MAINTAIN']}\", game_version = '#{settsoftMovedVersions2}'"
      @db.query(str_insert)
    end
    disconnectLumbaAppData
  end

  def saveDetaultValue
    properties_config = YAML.load_file("#{RAILS_ROOT}/config/properties.yml")
    logger.info("TERM_SERVICE_LINK_EN : #{DEFAULT_VAL['SettingInfo']['TERM_SERVICE_LINK_EN']}")
    update_query = "update ref_SettingInfo set SAVE_INTERVAL = #{DEFAULT_VAL['SettingInfo']['SaveInterval']}, IAP_RATIO = #{DEFAULT_VAL['SettingInfo']['IapRatio']}, Gem_Range_For_Calculate_Time = '#{DEFAULT_VAL['SettingInfo']['Gem_Range_For_Calculate_Time']}', Gold_Water_Range = '#{DEFAULT_VAL['SettingInfo']['Gold_Water_Rangei']}', Oil_Range = '#{DEFAULT_VAL['SettingInfo']['Oil_Range']}', Gem_Range_For_Calculate_Resource = '#{DEFAULT_VAL['SettingInfo']['Gem_Range_For_Calculate_Resource']}', TERM_SERVICE_LINK_EN = '#{DEFAULT_VAL['SettingInfo']['TERM_SERVICE_LINK_EN']}', TERM_SERVICE_LINK_AR = '#{DEFAULT_VAL['SettingInfo']['TERM_SERVICE_LINK_AR']}', POLICY_LINK_EN = '#{DEFAULT_VAL['SettingInfo']['POLICY_LINK_EN']}', POLICY_LINK_AR = '#{DEFAULT_VAL['SettingInfo']['POLICY_LINK_AR']}', FACEBOOK_LINK = '#{DEFAULT_VAL['SettingInfo']['FACEBOOK_LINK']}', TWITTER_LINK = '#{DEFAULT_VAL['SettingInfo']['TWITTER_LINK']}', COME_BACK_NOTIFICATION_DURATION = '#{DEFAULT_VAL['SettingInfo']['COME_BACK_NOTIFICATION_DURATION']}', SIGNATURE_ORDER = '#{DEFAULT_VAL['SettingInfo']['SIGNATURE_ORDER']}', SHOULD_FIND_SFS_SERVER = '#{DEFAULT_VAL['SettingInfo']['SHOULD_FIND_SFS_SERVER']}', SAVE_HISTORY_MINUTES = '#{DEFAULT_VAL['SettingInfo']['SAVE_HISTORY_MINUTES']}', PING_INTERVAL_SECONDS = '#{DEFAULT_VAL['SettingInfo']['PING_INTERVAL_SECONDS']}', REQUEST_TIME_OUT = '#{DEFAULT_VAL['SettingInfo']['REQUEST_TIME_OUT']}',SEND_TROOP_SECONDS = '#{DEFAULT_VAL['SettingInfo']['SEND_TROOP_SECONDS']}', ENABLE_LOG = 1, ENABLE_ADJUST_LOG = 1, ENABLE_IAP_LOG = 1, CHAT_INTERVAL = 1.0, MAX_LOG = 100, GAME_MAINTAIN = '#{DEFAULT_VAL['SettingInfo']['GAME_MAINTAIN']}' where game_version = '#{params[:game_version]}'"
    connectLumbaAppData
    @db.query(update_query)
    disconnectLumbaAppData
    connectLumbaAppData
    datas_settinginfo = @db.query("select * from ref_SettingInfo where game_version = '#{@game_version}'")
    disconnectLumbaAppData
    pile_Of_Gems_en = 0
    pile_Of_Gems_ar = 0
    bag_Of_Gems_en = 0
    pag_Of_Gems_ar = 0
    sack_Of_Gems_en = 0
    sack_Of_Gems_ar = 0
    box_Of_Gems_en = 0
    box_Of_Gems_ar = 0
    chest_Of_Gems_en = 0
    chest_Of_Gems_ar = 0
    logger.info (DEFAULT_VAL['Purchases']['Products'])
    products=DEFAULT_VAL['Purchases']['Products']
    products_arr = products.split(",")
    if (!products_arr[0].nil?)
      pile_Of_Gems_en = products_arr[0].to_i
      pile_Of_Gems_ar = products_arr[0].to_i
    end
    if (!products_arr[1].nil?)
      bag_Of_Gems_en = products_arr[1].to_i
      pag_Of_Gems_ar = products_arr[1].to_i
    end
    if (!products_arr[2].nil?)
      sack_Of_Gems_en = products_arr[2].to_i
      sack_Of_Gems_ar = products_arr[2].to_i
    end
    if (!products_arr[3].nil?)
      box_Of_Gems_en = products_arr[3].to_i
      box_Of_Gems_ar = products_arr[3].to_i
    end
    if (!products_arr[4].nil?)
      chest_Of_Gems_en = products_arr[4].to_i
      chest_Of_Gems_ar = products_arr[4].to_i
    end
    if File.exist?("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/Setting.txt")
      `rm #{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/Setting.txt`
    end
    CSV.open("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/Setting.txt", "w:UTF-8", {:col_sep => "\t"}) { |csv|
      csv << ["Key", "Value", "English Version", "Arabic Version"]
      save_interval = ""
      iap_ratio = ""
      datas_settinginfo.each_hash do |row|
        save_interval = row['SAVE_INTERVAL']
        iap_ratio = row['IAP_RATIO']
        csv << ["SAVE_INTERVAL", save_interval, nil, nil]
        csv << ["PING_INTERVAL_SECONDS", row['PING_INTERVAL_SECONDS'], nil, nil]
        csv << ["REQUEST_TIME_OUT", row['REQUEST_TIME_OUT'],nil, nil]
        csv << ["SHOULD_FIND_SFS_SERVER", row['SHOULD_FIND_SFS_SERVER'], nil, nil]
        csv << ["IAP_RATIO", iap_ratio, nil, nil]
        csv << ["Pile_Of_Gems", nil, pile_Of_Gems_en, pile_Of_Gems_ar]
        csv << ["Bag_Of_Gems", nil, bag_Of_Gems_en, pag_Of_Gems_ar]
        csv << ["Sack_Of_Gems", nil, sack_Of_Gems_en, sack_Of_Gems_ar]
        csv << ["Box_Of_Gems", nil, box_Of_Gems_en, box_Of_Gems_ar]
        csv << ["Chest_Of_Gems", nil, chest_Of_Gems_en, chest_Of_Gems_ar]
        csv << ["Gem_Range_For_Calculate_Time", row['Gem_Range_For_Calculate_Time'], nil, nil]
        csv << ["Gold_Water_Range", row['Gold_Water_Range'], nil, nil]
        csv << ["Oil_Range", row['Oil_Range'], nil, nil]
        csv << ["Gem_Range_For_Calculate_Resource", row['Gem_Range_For_Calculate_Resource'], nil, nil]
        csv << ["TERM_SERVICE_LINK", row['TERM_SERVICE_LINK'], row['TERM_SERVICE_LINK_EN'], row['TERM_SERVICE_LINK_AR']]
        csv << ["POLICY_LINK", row['POLICY_LINK'], row['POLICY_LINK_EN'], row['POLICY_LINK_AR']]
        csv << ["FACEBOOK_LINK", row['FACEBOOK_LINK'], nil, nil]
        csv << ["TWITTER_LINK", row['TWITTER_LINK'], nil, nil]
        csv << ["COME_BACK_NOTIFICATION_DURATION", row['COME_BACK_NOTIFICATION_DURATION'], nil, nil]
        csv << ["SIGNATURE_ORDER", row['SIGNATURE_ORDER'], nil, nil]
        csv << ["GAME_MAINTAIN", row['GAME_MAINTAIN'], nil, nil]
      end
    }
    # create tournament file
    file = File.open("#{Rails.root}/exportedfile/sfs/tournamentDuration.txt", 'w:UTF-8') { |file| file.puts("duration=#{DEFAULT_VAL['TournamentDurations']['TournamentDuration']}\nstarttime=#{DEFAULT_VAL['TournamentDurations']['Starttime']}\nrewards=#{DEFAULT_VAL['TournamentDurations']['Rewards']}") }
    # create purchase file
    file = File.open("#{Rails.root}/exportedfile/sfs/purchases.txt", 'w:UTF-8') { |file| file.puts("en_identifiers=#{DEFAULT_VAL['Purchases']['Identifiers_en']}\nar_identifiers=#{DEFAULT_VAL['Purchases']['Identifiers_ar']}\nproducts=#{DEFAULT_VAL['Purchases']['Products']}") }
    # push file to server
    copy_file_to_server("#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{session[:game_version_production]}/Setting.txt", params[:game_version], 'development', 'LoadBalancer_1')
    upfileto_sfs_server("#{Rails.root}/exportedfile/sfs/tournamentDuration.txt")
    upfileto_sfs_server("#{Rails.root}/exportedfile/sfs/purchases.txt")
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

  def getdevicemakefromdevicemodel(devicemode)
    devicemake = ""
    if (devicemode.eql?("i386"))
      devicemake = "simulator"
    elsif (devicemode.eql?("iPod1,1"))
      devicemake = "iPod Touch"
    elsif (devicemode.eql?("iPod2,1"))
      devicemake = "iPod Touch Second Generation"
    elsif (devicemode.eql?("iPod3,1"))
      devicemake = "iPod Touch Third Generation"
    elsif (devicemode.eql?("iPod4,1"))
      devicemake = "iPod Touch Fourth Generation"
    elsif (devicemode.eql?("iPod5,1"))
      devicemake = "iPod Touch (5 Gen)"
    elsif (devicemode.eql?("iPhone1,1"))
      devicemake = "iPhone"
    elsif (devicemode.eql?("iPhone1,2"))
      devicemake = "iPhone 3G"
    elsif (devicemode.eql?("iPhone2,1"))
      devicemake = "iPhone 3GS"
    elsif (devicemode.eql?("iPad1,1"))
      devicemake = "iPad"
    elsif (devicemode.eql?("iPad1,2"))
      devicemake = "iPad 3G"
    elsif (devicemode.eql?("iPad2,1"))
      devicemake = "iPad 2 (WiFi)"
    elsif (devicemode.eql?("iPad2,2"))
      devicemake = "iPad 2"
    elsif (devicemode.eql?("iPad2,3"))
      devicemake = "iPad 2 (CDMA)"
    elsif (devicemode.eql?("iPad2,4"))
      devicemake = "iPad 2"
    elsif (devicemode.eql?("iPad2,5"))
      devicemake = "iPad Mini (WiFi)"
    elsif (devicemode.eql?("iPad2,6"))
      devicemake = "iPad Mini"
    elsif (devicemode.eql?("iPad2,7"))
      devicemake = "iPad Mini (GSM+CDMA)"
    elsif (devicemode.eql?("iPad3,1"))
      devicemake = "iPad 3 (WiFi)"
    elsif (devicemode.eql?("iPad3,2"))
      devicemake = "iPad 3 (GSM+CDMA)"
    elsif (devicemode.eql?("iPad3,4"))
      devicemake = "iPad 4 (WiFi)"
    elsif (devicemode.eql?("iPad3,5"))
      devicemake = "iPad 4"
    elsif (devicemode.eql?("iPad3,6"))
      devicemake = "iPad 4 (GSM+CDMA)"
    elsif (devicemode.eql?("iPhone3,1"))
      devicemake = "iPhone 4"
    elsif (devicemode.eql?("iPhone3,2"))
      devicemake = "iPhone 4"
    elsif (devicemode.eql?("iPhone3,3"))
      devicemake = "iPhone 4 (CDMA)"
    elsif (devicemode.eql?("iPhone4,1"))
      devicemake = "iPhone 4S"
    elsif (devicemode.eql?("iPhone5,1"))
      devicemake = "iPhone 5 (model A1428, AT&T/Canada)"
    elsif (devicemode.eql?("iPhone5,2"))
      devicemake = "iPhone 5 (model A1429, everything else)"
    elsif (devicemode.eql?("iPhone5,3"))
      devicemake = "iPhone 5c (model A1456, A1532 | GSM)"
    elsif (devicemode.eql?("iPhone5,4"))
      devicemake = "iPhone 5c (model A1507, A1516, A1526 (China), A1529 | Global)"
    elsif (devicemode.eql?("iPhone6,1"))
      devicemake = "iPhone 5s (model A1433, A1533 | GSM)"
    elsif (devicemode.eql?("iPhone6,2"))
      devicemake = "iPhone 5s (model A1457, A1518, A1528 (China), A1530 | Global)"
    elsif (devicemode.eql?("iPad4,1"))
      devicemake = "5th Generation iPad (iPad Air) - Wifi"
    elsif (devicemode.eql?("iPad4,2"))
      devicemake = "5th Generation iPad (iPad Air) - Cellular"
    elsif (devicemode.eql?("iPad4,4"))
      devicemake = "2nd Generation iPad Mini - Wifi"
    elsif (devicemode.eql?("iPad4,5"))
      devicemake = "2nd Generation iPad Mini - Cellular"
    elsif (devicemode.eql?("iPad3,3"))
      devicemake = "iPad 3rd Gen (Wi-Fi + Cellular)"
    end
    devicemake
  end
end
