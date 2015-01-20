require 'zip/zip'
class UploadgamedataController < ApplicationController
  before_filter :login_required
  skip_before_filter :verify_authenticity_token, :only => [:upload]
  def upload
     read_properties_file
     properties_config = YAML.load_file("#{Rails.root}/config/properties.yml")
     dir_read_file = "#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{@game_version}"
     begin
      files = params[:files]
      files.each {|file|
        puts files.inspect
        DataFile.save(file, dir_read_file)
      }
      dir_read_file = "#{Rails.root}/exportedfile/#{decrypt(properties_config['server1'])}/#{@game_version}"
      files.each { |file|
        connectLumbaAppData
        # reinsert database
        if file.original_filename.eql?("CampaignReference.txt")
          #@db.query("truncate ref_Campaign")
          @db.query("delete from ref_Campaign where game_version = '#{@game_version}'")
          CSV.foreach("#{dir_read_file}/CampaignReference.txt", {:col_sep => "\t"}) do |row|
            if !row[0].eql?("Type")
              str_query = "insert into ref_Campaign set Type = \"#{row[0]}\", Name = \"#{row[1]}\", RequireCampaignIDtoUnlock = \"#{row[2]}\", LootableGold = \"#{row[3]}\", LootableWater = \"#{row[4]}\", LootableDarkWater = \"#{row[5]}\", townhallprefab = \"#{row[6]}\", game_version = \"#{@game_version}\" "
              @db.query(str_query)
            end
          end
        end
        # combat unit
        if file.original_filename.eql?("CombatUnits.txt")
          #@db.query("truncate ref_CombatUnit")
          @db.query("delete from ref_CombatUnit where game_version = '#{@game_version}'")
          CSV.foreach("#{dir_read_file}/CombatUnits.txt", {:col_sep => "\t"}) do |row|
            if !row[0].eql?("Unit")
              str_query = "insert into ref_CombatUnit set Unit = \"#{row[0]}\", `Unit Group` = \"#{row[1]}\", PreferredTarget = \"#{row[2]}\", PreferredTargetDamage = \"#{row[3]}\", AttackType = \"#{row[4]}\", AttackTarget = \"#{row[5]}\", DamageType = \"#{row[6]}\", SplashRadius = \"#{row[7]}\", HousingSpace = \"#{row[8]}\", TrainingTimeSeconds = \"#{row[9]}\", MovementSpeed = \"#{row[10]}\", AttackSpeed = \"#{row[11]}\", BarracksLevel = \"#{row[12]}\", RangeInTiles = \"#{row[13]}\", SearchRadiusInTiles = \"#{row[14]}\", MaxLevel = \"#{row[15]}\", game_version = \"#{@game_version}\" "
               puts str_query
              @db.query(str_query)
            end
          end
        end
        # unit level
        if file.original_filename.eql?("UnitLevels.txt")
          #@db.query("truncate ref_UnitLevels")
          @db.query("delete from ref_UnitLevels where game_version = '#{@game_version}'")
          CSV.foreach("#{dir_read_file}/UnitLevels.txt", {:col_sep => "\t"}) do |row|
            if !row[0].eql?("Type")
              str_query = "insert into ref_UnitLevels set Type = \"#{row[0]}\", Level = \"#{row[1]}\", DamagePerSecond = \"#{row[2]}\", HitPoints = \"#{row[3]}\", TrainingCostInElixir = \"#{row[4]}\", UpgradeCostInElixir = \"#{row[5]}\", LaboratoryLevelRequired = \"#{row[6]}\", UpgradeTimeInHours = \"#{row[7]}\", TownHallLevelRequired = \"#{row[8]}\", RegenerationTimeInMinutes = '#{row[9]}', UpgradeCostInDarkElixir = '#{row[10]}', TrainingCostInDarkElixir = '#{row[11]}', game_version = '#{@game_version}'"
              @db.query(str_query)
            end
          end
        end
        # defensive building
        if file.original_filename.eql?("DefensiveBuildings.txt")
          #@db.query("truncate ref_DefensiveBuildings")
          @db.query("delete from ref_DefensiveBuildings where game_version = '#{@game_version}'")
          CSV.foreach("#{dir_read_file}/DefensiveBuildings.txt", {:col_sep => "\t"}) do |row|
            if !row[0].eql?("Unit")
              str_query = "insert into ref_DefensiveBuildings set Unit = '#{row[0]}', RangeStart = '#{row[1]}', RangeEnd = '#{row[2]}', Explodetime = '#{row[3]}', AttackSpeedInSeconds = '#{row[4]}', DamageType = '#{row[5]}', DamageRadius = '#{row[6]}', UnitTypeTargeted = '#{row[7]}', PreferredTarget = '#{row[8]}', PreferredTargetBonus = '#{row[9]}', NumberOfRounds = '#{row[10]}', MaxLevel = '#{row[11]}', SizeLimit = '#{row[12]}', AirRange = '#{row[13]}', UnitType = '#{row[14]}', game_version = '#{@game_version}'"
              @db.query(str_query)
            end
          end
        end
        # defensive building level
        if file.original_filename.eql?("DefensiveBuildingLevel.txt")
          #@db.query("truncate ref_DefensiveBuildingsLevel")
          @db.query("delete from ref_DefensiveBuildingsLevel where game_version = '#{@game_version}'")
          CSV.foreach("#{dir_read_file}/DefensiveBuildingLevel.txt", {:col_sep => "\t"}) do |row|
            if !row[0].eql?("Type")
              str_query = "insert into ref_DefensiveBuildingsLevel set Type = '#{row[0]}', Level = '#{row[1]}', DamagePerSecond = '#{row[2]}', DamagePerShot = '#{row[3]}', HitPoints = '#{row[4]}', CostGold = '#{row[5]}', CostDarkElixir = '#{row[6]}', SellGold = '#{row[7]}', SellDarkElixir = '#{row[8]}', UpgradeTime = '#{row[9]}', ExperienceGained = '#{row[10]}', TownHallLevelRequired = '#{row[11]}', ObjectType = '#{row[12]}', CostToLoad = '#{row[13]}', PrefabName = '#{row[14]}', DisplayName = '#{row[15]}', NumTileOneSide = '#{row[16]}', HasBase = '#{row[17]}', game_version = '#{@game_version}'"
              @db.query(str_query)
            end
          end
        end
        # resource building variable
        if file.original_filename.eql?("ResourceBuildings.txt")
          #@db.query("truncate ref_ResourceBuildingVariables")
          @db.query("delete from ref_ResourceBuildingVariables where game_version = '#{@game_version}'")
          CSV.foreach("#{dir_read_file}/ResourceBuildings.txt", {:encoding => "iso-8859-1:UTF-8", :col_sep => "\t"}) do |row|
            if !row[0].eql?("Note")
              str_query = "insert into ref_ResourceBuildingVariables set Note = '#{row[0].force_encoding('utf-8')}', Type = '#{row[1]}', Level = '#{row[2]}', BuildCostElixir = '#{row[3]}', BuildCostGold = '#{row[4]}', BuildCostGem = '#{row[5]}', BuildTimeInMinutes = '#{row[6]}', ExperienceGained = '#{row[7]}', Capacity = '#{row[8]}', ProductionRates = '#{row[9]}', HitPoints = '#{row[10]}', TownHallLevelRequired = '#{row[11]}', BoostCostInGems = '#{row[12]}', MaxLevel = '#{row[13]}', ObjectType = '#{row[14]}', CollectablePoint = '#{row[15]}', PrefabName = '#{row[16]}', DisplayName = '#{row[17]}', NumTileOneSide = '#{row[18]}', HasBase = '#{row[19]}', game_version = '#{@game_version}'"
              @db.query(str_query)
            end
          end
        end
        # army building
        if file.original_filename.eql?("ArmyBuildings.txt")
          #@db.query("truncate ref_ArmyBuilding")
          @db.query("delete from ref_ArmyBuilding where game_version = '#{@game_version}'")
          CSV.foreach("#{dir_read_file}/ArmyBuildings.txt", {:col_sep => "\t"}) do |row|
            if !row[0].eql?("Note")
              str_query = "insert into ref_ArmyBuilding set Note = '#{row[0]}', Type = '#{row[1]}', Level = '#{row[2]}', BuildCostElixir = '#{row[3]}', BuildCostDarkElixir = '#{row[4]}', BuildTimeInMinutes = '#{row[5]}', ExperienceGained = '#{row[6]}', Capacity = '#{row[7]}', HitPoints = '#{row[8]}', MaxUnitQueue = '#{row[9]}', UnlockUnit = '#{row[10]}', UnlockSpell = '#{row[11]}', TownHallLevelRequired = '#{row[12]}', MaxLevel = '#{row[13]}', ObjectType = '#{row[14]}', BoostCostInGems = '#{row[15]}', PrefabName = '#{row[16]}', DisplayName = '#{row[17]}', NumTileOneSide = '#{row[18]}', HasBase = '#{row[19]}', game_version = '#{@game_version}'"
              @db.query(str_query)
            end
          end
        end
        # other building
        if file.original_filename.eql?("OtherBuildings.txt")
          #@db.query("truncate ref_OtherBuildings")
          @db.query("delete from ref_OtherBuildings where game_version = '#{@game_version}'")
          CSV.foreach("#{dir_read_file}/OtherBuildings.txt", {:col_sep => "\t"}) do |row|
            if !row[0].eql?("Note")
              str_query = "insert into ref_OtherBuildings set Note = '#{row[0]}', Type = '#{row[1]}', Level = '#{row[2]}', BuildCostGold = '#{row[3]}', BuildCostGem = '#{row[4]}', BuildTimeInMinutes = '#{row[5]}', ExperienceGained = '#{row[6]}', Capacity = '#{row[7]}', HitPoints = '#{row[8]}', TownHallLevelRequired = '#{row[9]}', MaxLevel = '#{row[10]}', ObjectType = '#{row[11]}', PrefabName = '#{row[12]}', DisplayName = '#{row[13]}', NumTileOneSide = '#{row[14]}', HasBase = '#{row[15]}', game_version = '#{@game_version}'"
              @db.query(str_query)
            end
          end
        end
        # town hall level
        if file.original_filename.eql?("TownHallLevel.txt")
          @db.query("delete from ref_TownHallLevel where game_version = '#{@game_version}'")
          #@db.query("truncate ref_TownHallLevel")
          CSV.foreach("#{dir_read_file}/TownHallLevel.txt", {:col_sep => "\t"}) do |row|
            if !row[0].eql?("Type")
              str_query = "insert into ref_TownHallLevel set Type = '#{row[0]}', Level1 = '#{row[1]}', Level2 = '#{row[2]}', Level3 = '#{row[3]}', Level4 = '#{row[4]}', Level5 = '#{row[5]}', Level6 = '#{row[6]}', Level7 = '#{row[7]}', Level8 = '#{row[8]}', Level9 = '#{row[9]}', game_version = '#{@game_version}'"
              @db.query(str_query)
            end
          end 
        end
        # decoration
        if file.original_filename.eql?("Decorations.txt")
          #@db.query("truncate ref_Decoration")
          @db.query("delete from ref_Decoration where game_version = '#{@game_version}'")
          CSV.foreach("#{dir_read_file}/Decorations.txt", {:col_sep => "\t"}) do |row|
            if !row[0].eql?("Note")
              str_query = "insert into ref_Decoration set Note = '#{row[0]}', Type = '#{row[1]}', BuildCostElixir = '#{row[2]}', BuildCostDarkElixir = '#{row[3]}', BuildCostGold = '#{row[4]}', BuildCostGems = '#{row[5]}', LevelRequired = '#{row[6]}', ObjectType = '#{row[7]}', PrefabName = '#{row[8]}', DisplayName = '#{row[9]}', NumTileOneSide = '#{row[10]}', HasBase = '#{row[11]}', game_version = '#{@game_version}'"
              @db.query(str_query)
            end
          end
        end
        # spell
        if file.original_filename.eql?("Spells.txt")
          #@db.query("truncate ref_Spell")
          @db.query("delete from ref_Spell where game_version = '#{@game_version}'")
          CSV.foreach("#{dir_read_file}/Spells.txt", {:col_sep => "\t"}) do |row|
            if !row[0].eql?("Type name")
              str_query = "insert into ref_Spell set TypeName = '#{row[0]}', Type = '#{row[1]}', Radius = '#{row[2]}', StrikeArea = '#{row[3]}', NumberOfStrikes = '#{row[4]}', TimeBetweenStrikesInSeconds = '#{row[5]}', TimeToCreateInSeconds = '#{row[6]}', BoostTimeInSeconds = '#{row[7]}', SpellFactoryLevelRequired = '#{row[8]}', MaxLevel = '#{row[9]}', game_version = '#{@game_version}'"
              @db.query(str_query)
            end
          end
        end
        # spell level
        if file.original_filename.eql?("SpellLevels.txt")
          #@db.query("truncate ref_SpellLevel")
          @db.query("delete from ref_SpellLevel where game_version = '#{@game_version}'")
          CSV.foreach("#{dir_read_file}/SpellLevels.txt", {:col_sep => "\t"}) do |row|
            if !row[0].eql?("Type name")
              str_query = "insert into ref_SpellLevel set Type = '#{row[0]}', Level = '#{row[1]}', BuildCostGold = '#{row[2]}', UpgradeCost = '#{row[3]}', UpgradeTimeInHours = '#{row[4]}', LaboratoryLevelRequired = '#{row[5]}', TotalDamage = '#{row[6]}', DamagePerStrike = '#{row[7]}', DamageBoostInPercent = '#{row[8]}', SpeedBoost = '#{row[9]}', SizeLimit = '#{row[10]}', game_version = '#{@game_version}'"
              @db.query(str_query)
            end
          end
        end
        # obstacle
        if file.original_filename.eql?("Obstacles.txt")
          #@db.query("truncate ref_Obstactles")
          @db.query("delete from ref_Obstactles where game_version = '#{@game_version}'")
          CSV.foreach("#{dir_read_file}/Obstacles.txt", {:col_sep => "\t"}) do |row|
            if !row[0].eql?("Type name")
              str_query = "insert into ref_Obstactles set TypeName = '#{row[0]}', Type = '#{row[1]}', RemovalTime = '#{row[2]}', ExperienceGained = '#{row[3]}', RemovalCostGold = '#{row[4]}', RemovalCostElixir = '#{row[5]}', RespawnWeight = '#{row[6]}', RemovalBenefitElixir = '#{row[7]}', RemovalBenefitDarkElixir = '#{row[8]}', InitPosition = '#{row[9]}', ObjectType = '#{row[10]}', PrefabName = '#{row[11]}', DisplayName = '#{row[12]}', NumTileOneSide = '#{row[13]}', HasBase = '#{row[14]}', game_version = '#{@game_version}'"
              @db.query(str_query)
            end
          end
        end
        # trophy
        if file.original_filename.eql?("Trophy.txt")
          #@db.query("truncate ref_Trophy")
          @db.query("delete from ref_Trophy where game_version = '#{@game_version}'")
          CSV.foreach("#{dir_read_file}/Trophy.txt", {:col_sep => "\t"}) do |row|
            if !row[0].eql?("Trophy")
              str_query = "insert into ref_Trophy set TrophyDifference = '#{row[0]}', High = '#{row[1]}', Low = '#{row[2]}', game_version = '#{@game_version}'"
              @db.query(str_query)
            end
          end
        end
        # achivement
        if file.original_filename.eql?("Achievements.txt")
          #@db.query("truncate ref_Achievement")
          @db.query("delete from ref_Achievement where game_version = '#{@game_version}'")
          CSV.foreach("#{dir_read_file}/Achievements.txt", {:col_sep => "\t"}) do |row|
            if !row[0].eql?("Type")
              str_query = "insert into ref_Achievement set Type = \"#{row[0]}\", Star = \"#{row[1]}\", Name = \"#{row[2]}\", Description = \"#{row[3]}\", ExpReward = \"#{row[4]}\", GemReward = \"#{row[5]}\", RequiredQuantity = \"#{row[6]}\" , game_version = \"#{@game_version}\" "
              @db.query(str_query)
            end
          end
        end
        if file.original_filename.eql?("Bundles.txt")
          #@db.query("truncate ref_Bundle")
          @db.query("delete from ref_Bundle where game_version = '#{@game_version}'")
          File.open("#{dir_read_file}/Bundles.txt", "r:UTF-8").each_line do |line|
            abc = line.split("=")
            if abc.size < 2
              abc = abc + [""]
            end
            bundlevalue = abc[1].gsub("\\","\\\\\\")
            bundlevalue = bundlevalue.gsub("\"", "\\\\\"")
            str_insert = "insert into ref_Bundle set bundlekey = \"#{abc[0]}\", bundlevalue = \"#{bundlevalue}\", game_version = '#{@game_version}'"
            @db.query(str_insert)
          end
        end
        disconnectLumbaAppData

        copy_file_to_server("#{dir_read_file}/#{file.original_filename}", @game_version, "production")
      }
      @error_string = "Uploaded successfull"
    rescue Exception=>e
      puts e.to_s
      @error_string = "Uploaded false"
    end
    
    #redirect_to params[:currenturl]
  end
end
