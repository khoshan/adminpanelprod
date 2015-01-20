require 'mysql'
require 'json'
require 'zip/zip'
require 'rubygems'
require 'simple_xlsx' #gem install simple_xlsx_writer

class Export
  def exportdata
    db = Mysql.new('lumba.ckyzvr2punhb.eu-west-1.rds.amazonaws.com', 'sgsvn', 'buncha11', 'LumbaAppData')
    # delete file if exist
    if File.exist?("/root/myApp/exportedfile/ReferenceData.xlsx")
      `rm /root/myApp/exportedfile/ReferenceData.xlsx`
    end
    SimpleXlsx::Serializer.new("/root/myApp/exportedfile/ReferenceData.xlsx") do |doc|
    #campaign
    data = db.query("select * from ref_Campaign")
    doc.add_sheet("campaign") do |sheet|
      sheet.add_row(%w{Type Name Require\ Campaign\ Id\ to\ Unlock Lootable\ Gold Lootable\ Water Lootable\ Dark\ Water})
      data.each_hash do |row|
        sheet.add_row([row['Type'],
                     row['Name'],
                     row['RequireCampaignIDtoUnlock'],
                     row['LootableGold'],
                     row['LootableWater'],
                     row['LootableDarkWater']])
      end
    end
    # combat unit
    data = db.query("select * from ref_CombatUnit")
    doc.add_sheet("Combat Units") do |sheet|
      sheet.add_row(%w{Unit Unit\ Group Preferred\ Target Preferred\ Target\ Damage Attack\ Type Attack\ Target Damage\ Type Splash\ radius Housing\ Space Training\ Time\ (s) Movement\ Speed Attack\ Speed\ (s) Barracks\ Level Range\ (tiles) Search\ Radius\ (tiles) Max\ Level})
      data.each_hash do |row|
        sheet.add_row([row['Unit'],
                       row['Unit Group'],
                       row['PreferredTarget'],
                       row['PreferredTargetDamage'],
                       row['AttackType'],
                       row['AttackTarget'],
                       row['DamageType'],
                       row['SplashRadius'],
                       row['HousingSpace'],
                       row['TrainingTimeSeconds'],
                       row['MovementSpeed'],
                       row['AttackSpeed'],
                       row['BarracksLevel'],
                       row['RangeInTiles'],
                       row['SearchRadiusInTiles'],
                       row['MaxLevel']
                       ])
      end
    end
    #Unit Level
    data = db.query("select * from ref_UnitLevels")
    doc.add_sheet("Unit Levels") do |sheet|      sheet.add_row(%w{Type Level Damage\ per\ Second Hitpoints Training\ Cost\ (Elixir) Upgrade\ Cost\ (Elixir) Laboratory\ Level\ Required Upgrade\ Time\ (hours) Town\ Hall\ Level\ Required Regeneration\ Time\ (minutes) Upgrade\ Cost\ (Dark\ Elixir) Training\ Cost\ (Dark\ Elixir)})
      data.each_hash do |row|
        sheet.add_row([row['Type'],
                       row['Level'],
                       row['DamagePerSecond'],
                       row['HitPoints'],
                       row['TrainingCostInElixir'],
                       row['UpgradeCostInElixir'],
                       row['LaboratoryLevelRequired'],
                       row['UpgradeTimeInHours'],
                       row['TownHallLevelRequired'],
                       row['RegenerationTimeInMinutes'],
                       row['UpgradeCostInDarkElixir'],
                       row['TrainingCostInDarkElixir']
                       ])
      end
    end
    #Defensive Buildings
    data = db.query("select * from ref_DefensiveBuildings")
    doc.add_sheet("Defensive Buildings") do |sheet|
      sheet.add_row(%w{Unit Range\ start Range\ end Explode\ time Attack\ Speed\ (s) Damage\ type Damage\ radius Unit\ type\ Targeted Preferred\ Target Preferred\ Target\ bonus Number\ of\ rounds Max\ Level Size\ Limit AirRange})
      data.each_hash do |row|
        sheet.add_row([row['Unit'],
                       row['RangeStart'],
                       row['RangeEnd'],
                       row['AttackSpeedInSeconds'],
                       row['DamageType'],
                       row['DamageRadius'],
                       row['UnitTypeTargeted'],
                       row['PreferredTarget'],
                       row['PreferredTargetBonus'],
                       row['NumberOfRounds'],
                       row['MaxLevel'],
                       row['SizeLimit']
                       ])
      end
    end
    # Defensive Buildings Level
    data = db.query("select * from ref_DefensiveBuildingsLevel")
    doc.add_sheet("Defensive Buildings Level") do |sheet|      sheet.add_row(%w{Type Level Damage\ per\ second Damage\ per\ shot Hitpoints Cost\ Gold Cost\ Dark\ Elixir Sell\ Gold Sell\ Dark\ Elixir Upgrade\ Time Experience\ Gained Town\ Hall\ Level\ Required Object\ Type Cost\ To\ Load})
      data.each_hash do |row|
        sheet.add_row([row['Type'],
                       row['Level'],
                       row['DamagePerSecond'],
                       row['DamagePerShot'],
                       row['HitPoints'],
                       row['CostGold'],
                       row['CostDarkElixir'],
                       row['SellGold'],
                       row['SellDarkElixir'],
                       row['UpgradeTime'],
                       row['ExperienceGained'],
                       row['TownHallLevelRequired'],
                       row['ObjectType'],
                       row['CostToLoad']
                       ])
      end
    end
    # Resource Building variables
    data = db.query("select * from ref_ResourceBuildingVariables")
    doc.add_sheet("Resource Building variables") do |sheet|      sheet.add_row(%w{Note Type Level Build\ Cost\ Elixir Build\ Cost\ Gold Build\ Cost\ Gem Build\ Time\ (minutes) Experience\ Gained Capacity Production\ Rate\ Points Town\ Hall\ level\ Required Boost\ Cost\ (gems) Max\ Level Object\ Type Collectable\ point})
      data.each_hash do |row|
        sheet.add_row([row['Note'],
                       row['Type'],
                       row['Level'],
                       row['BuildCostElixir'],
                       row['BuildCostGold'],
                       row['BuildCostGem'],
                       row['BuildTimeInMinutes'],
                       row['ExperienceGained'],
                       row['Capacity'],
                       row['ProductionRates'],
                       row['HitPoints'],
                       row['TownHallLevelRequired'],
                       row['BoostCostInGems'],
                       row['MaxLevel'],
                       row['ObjectType'],
                       row['CollectablePoint']
                       ])
      end
    end
    # Army Building
    data = db.query("select * from ref_ArmyBuilding")
    doc.add_sheet("Army Building") do |sheet|
      sheet.add_row(%w{Note Type Level Build\ Cost\ Elixir Build\ Cost\ Dark\ Elixir Build\ Time\ (minutes) Experience\ Gained Capacity Hit\ Points Maximum\ Unit\ Queue Unlock\ Unit Unlock\ Spell Town\ Hall\ level\ Required Object\ Type Boost\ Cost\ (gems)})
      data.each_hash do |row|
        sheet.add_row([row['Note'],
                       row['Type'],
                       row['Level'],
                       row['BuildCostElixir'],
                       row['BuildCostDarkElixir'],
                       row['BuildTimeInMinutes'],
                       row['ExperienceGained'],
                       row['Capacity'],
                       row['HitPoints'],
                       row['MaxUnitQueue'],
                       row['UnlockUnit'],
                       row['UnlockSpell'],
                       row['TownHallLevelRequired'],
                       row['MaxLevel'],
                       row['ObjectType'],
                       row['BoostCostInGems']
                       ])
      end
    end
    # Other Buildings
    data = db.query("select * from ref_OtherBuildings")
    doc.add_sheet("Other Buildings") do |sheet|
      sheet.add_row(%w{Note Type Level Build\ Cost\ Gold Build\ Cost\ Gem Build\ Time\ (minutes) Experience\ Gained Capacity Hit\ Points Town\ Hall\ level\ Required Object\ Type})
      data.each_hash do |row|
        sheet.add_row([row['Note'],
                       row['Type'],
                       row['Level'],
                       row['BuildCostGold'],
                       row['BuildCostGem'],
                       row['BuildTimeInMinutes'],
                       row['ExperienceGained'],
                       row['Capacity'],
                       row['HitPoints'],
                       row['TownHallLevelRequired'],
                       row['MaxLevel'],
                       row['ObjectType']
                       ])      
      end
    end
    # Town Hall Level
    data = db.query("select * from ref_TownHallLevel")
    doc.add_sheet("Town Hall Level") do |sheet|
      sheet.add_row(%w{Type Level1 Level2 Level3 Level4 Level5 Level6 Level7 Level8 Level9})
      data.each_hash do |row|        
        sheet.add_row([row['Type'],
                       row['Level1'],
                       row['Level2'],
                       row['Level3'],
                       row['Level4'],
                       row['Level5'],
                       row['Level6'],
                       row['Level7'],
                       row['Level8'],
                       row['Level9']
                       ])            
      end              
    end
    # Decoration
    data = db.query("select * from ref_Decoration")
    doc.add_sheet("Decoration") do |sheet|
      sheet.add_row(%w{Note Type Build\ Cost\ Elixir Build\ Cost\ Dark\ Elixir Build\ Cost\ Gold Build\ Cost\ Gem Level\ Require})
      data.each_hash do |row|
        sheet.add_row([row['Note'],
                       row['Type'],
                       row['BuildCostElixir'],
                       row['BuildCostDarkElixir'],
                       row['BuildCostGold'],
                       row['BuildCostGems'],
                       row['LevelRequired']
                       ])
      end
    end
    # spell
    data = db.query("select * from ref_Spell")
    doc.add_sheet("Spell") do |sheet|
      sheet.add_row(%w{Type\ name Type Radius Strike\ area Numb\ of\ Strike Time\ between\ strikes(s) Time\ to\ create(min) Boost\ Time(s) Spell\ Factory\ level\ require Max\ Level})
      data.each_hash do |row|
        sheet.add_row([row['TypeName'],
                       row['Type'],
                       row['Radius'],
                       row['StrikeArea'],
                       row['NumberOfStrikes'],
                       row['TimeBetweenStrikesInSeconds'],
                       row['TimeToCreateInSeconds'],
                       row['BoostTimeInSeconds'],
                       row['SpellFactoryLevelRequired'],
                       row['MaxLevel']
                       ])
      end    
    end
    # Spell Level
    data = db.query("select * from ref_SpellLevel")
    doc.add_sheet("Spell Level") do |sheet|
      sheet.add_row(%w{Type Level Build\ Cost\ Gold Upgrade\ Cost\ Water Upgrade\ Time(hours) Lab\ Level\ Require Total\ Damage Damage\ Per\ Strike Damage\ Boost(%) Speed\ Boost Size\ Limit})
      data.each_hash do |row|
        sheet.add_row([row['Type'],
                       row['Level'],
                       row['BuildCostGold'],
                       row['UpgradeCost'],
                       row['UpgradeTimeInHours'],
                       row['LaboratoryLevelRequired'],
                       row['TotalDamage'],
                       row['DamagePerStrike'],
                       row['DamageBoostInPercent'],
                       row['SpeedBoost'],
                       row['SizeLimit']
                       ])
      end
    end
    # Obstacles
    data = db.query("select * from ref_Obstactles")
    doc.add_sheet("Obstacles") do |sheet|
      sheet.add_row(%w{Type\ name Type Removal\ time Experience\ Gained Removal\ Cost\ Gold Removal\ Cost\ Elixir Respawn\ Weight Removal\ Benefit\ Elixir Removal\ Benefit\ Dark\ Elixir Init\ Position Object\ Type})
      data.each_hash do |row|
        sheet.add_row([row['TypeName'],
                       row['Type'],
                       row['RemovalTime'],
                       row['ExperienceGained'],
                       row['RemovalCostGold'],
                       row['RemovalCostElixir'],
                       row['RespawnWeight'],
                       row['RemovalBenefitElixir'],
                       row['RemovalBenefitDarkElixir'],
                       row['InitPosition'],
                       row['ObjectType']
                       ])
      end
    end
    #effects
    data = db.query("select * from ref_Effects")
    doc.add_sheet("Effects") do |sheet|
      sheet.add_row(%w{Type Description PrefabName})
      data.each_hash do |row|
        sheet.add_row([row['Type'],
                       row['Description'],
                       row['PrefabName']
                       ])
      end
    end
    # Prefab
    data = db.query("select * from ref_Prefab")
    doc.add_sheet("Prefab") do |sheet|
      sheet.add_row(%w{Prefab\ name prefab\ path preload cull\ above})
      data.each_hash do |row|
        sheet.add_row([row['PrefabName'],
                       row['PrefabPath'],
                       row['preload'],
                       row['cullAbove']
                       ])
      end
    end
    # Trophy
    data = db.query("select * from ref_Trophy")
    doc.add_sheet("Trophy") do |sheet|
      sheet.add_row(%w{Trophy\ difference High Low})
      data.each_hash do |row|
        sheet.add_row([row['TrophyDifference'],
                       row['High'],
                       row['Low']
                       ])
      end
    end
    # Achievement
    data = db.query("select * from ref_Achievement")
    doc.add_sheet("Achievement") do |sheet|
      sheet.add_row(%w{Type Star Name Description Exp\ reward Gem\ reward Required\ quantity})
      data.each_hash do |row|
        sheet.add_row([row['Type'],
                       row['Star'],
                       row['Name'],
                       row['Description'],
                       row['ExpReward'],
                       row['GemReward'],
                       row['RequiredQuantity']
                       ])
      end
    end
    end
    db.close
  end
end
a = Export.new
      a.exportdata
