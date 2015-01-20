MyApp::Application.routes.draw do
  get "sendnotification/index"
#  root 'welcome#index'
#  Profanity
  post 'lumba/profanity' , to: 'profanity#index'
  get 'lumba/profanity' , to: 'profanity#index'
#  user_controller
  root 'user#login'
  post 'lumba/login' , to: 'user#login'
  get 'lumba/logout' , to: 'user#logout'
# dashboard
  get 'lumba/dashboard' , to: 'dashboard#index'
  post 'lumba/dashboard' , to: 'dashboard#index'
# wrong url
  #get '*unmatched_route', :to => 'application#raise_not_found!'
# tribe
  get 'lumba/tribe' , to: 'tribe#index'
  post 'lumba/tribe' , to: 'tribe#index'
  get 'lumba/tribe/tribe_details', to: 'tribe#index'
  post 'lumba/tribe/tribe_details', to: 'tribe#tribe_details'
  get 'lumba/tribe/tournament', to: 'tribe#tournament'
  post 'lumba/tribe/tournament', to: 'tribe#tournament'
# gamestate
  get 'lumba/gamestate' , to: 'gamestate#index'
  post 'lumba/gamestate' , to: 'gamestate#index'
  get 'lumba/gamestate/show_pearls_history' , to: 'gamestate#show_pearls_history'
  get 'lumba/gamestate/show_lumba_history' , to: 'gamestate#show_lumba_history'
  get 'lumba/gamestate/list_user' , to: 'gamestate#list_user'
  get 'lumba/gamestate/user_details' , to: 'gamestate#index'
  post 'lumba/gamestate/user_details' , to: 'gamestate#user_details'
# Adjust callback data
  get 'lumba/adjustcallbackdata' , to: 'adjustcallbackdata#index'
  post 'lumba/adjustcallbackdata' , to: 'adjustcallbackdata#index'
  get 'lumba/adjustcallbackdata/show_log' , to: 'adjustcallbackdata#show_log'
# set language
  get 'lumba/setlang' , to: 'setlang#index'
  post 'lumba/setlang' , to: 'setlang#index'
# set bundle
  get 'lumba/bundle' , to: 'bundle#index'
  post 'lumba/bundle' , to: 'bundle#index'
# set user_email
   get 'lumba/sendemail' , to: 'sendemail#index'
   post 'lumba/sendemail' , to: 'sendemail#index'
# set notification
  get 'lumba/sendnotification' , to: 'sendnotification#index'
  post 'lumba/sendnotification' , to: 'sendnotification#index'
# set time zone
  get '/lumba/changeTimezone' , to: 'timezone#index'
  post '/lumba/changeTimezone' , to: 'timezone#index'
# game data tab
  get 'lumba/gamedata' , to: 'gamedata#index'
  post 'lumba/gamedata' , to: 'gamedata#index'
  post 'lumba/gamedata/index' , to: 'gamedata#index'
  get "lumba/gamedata/campaign" , to: 'gamedata#campaign'
  post "lumba/gamedata/campaign" , to: 'gamedata#campaign'
  get "lumba/gamedata/combat_units", to: 'gamedata#combat_units'
  post "lumba/gamedata/combat_units", to: 'gamedata#combat_units'
  get "lumba/gamedata/unit_levels" , to: 'gamedata#unit_levels'
  post "lumba/gamedata/unit_levels" , to: 'gamedata#unit_levels'
  get "lumba/gamedata/defensive_building" , to: 'gamedata#defensive_building'
  post "lumba/gamedata/defensive_building" , to: 'gamedata#defensive_building'
  get "lumba/gamedata/defensive_buildings_level" , to: 'gamedata#defensive_buildings_level'
  post "lumba/gamedata/defensive_buildings_level" , to: 'gamedata#defensive_buildings_level'
  get "lumba/gamedata/resources_building_variables" , to: 'gamedata#resources_building_variables'
  post "lumba/gamedata/resources_building_variables" , to: 'gamedata#resources_building_variables'
  get "lumba/gamedata/army_building" , to: 'gamedata#army_building'
  post "lumba/gamedata/army_building" , to: 'gamedata#army_building'
  get "lumba/gamedata/other_buildings" , to: 'gamedata#other_buildings'
  post "lumba/gamedata/other_buildings" , to: 'gamedata#other_buildings'
  get "lumba/gamedata/town_hall_level" , to: 'gamedata#town_hall_level'
  post "lumba/gamedata/town_hall_level" , to: 'gamedata#town_hall_level'
  get "lumba/gamedata/decoration" , to: 'gamedata#decoration'
  post "lumba/gamedata/decoration" , to: 'gamedata#decoration'
  get "lumba/gamedata/spell" , to: 'gamedata#spell'
  post "lumba/gamedata/spell" , to: 'gamedata#spell'
  get "lumba/gamedata/spell_level" , to: 'gamedata#spell_level'
  post "lumba/gamedata/spell_level" , to: 'gamedata#spell_level'
  get "lumba/gamedata/obstacles" , to: 'gamedata#obstacles'
  post "lumba/gamedata/obstacles" , to: 'gamedata#obstacles'
  get "lumba/gamedata/effects" , to: 'gamedata#effects'
  post "lumba/gamedata/effects" , to: 'gamedata#effects'
  get "lumba/gamedata/pretab" , to: 'gamedata#pretab'
  post "lumba/gamedata/pretab" , to: 'gamedata#pretab'
  get "lumba/gamedata/trophy" , to: 'gamedata#trophy'
  post "lumba/gamedata/trophy" , to: 'gamedata#trophy'
  get "lumba/gamedata/acheivements" , to: 'gamedata#acheivements'
  post "lumba/gamedata/acheivements" , to: 'gamedata#acheivements'
  get "lumba/gamedata/newgame" , to: 'gamedata#newgame'
  post "lumba/gamedata/newgame" , to: 'gamedata#newgame'
  get "lumba/gamedata/setting" , to: 'gamedata#setting'
  post "lumba/gamedata/setting" , to: 'gamedata#setting'
  get "lumba/gamedata/purchases" , to: 'gamedata#purchases'
  post "lumba/gamedata/purchases" , to: 'gamedata#purchases'
  get "lumba/gamedata/downloadgamedata" , to: 'gamedata#downloadgamedata'
  post "lumba/gamedata/downloadgamedata" , to: 'gamedata#downloadgamedata'
  get "lumba/gamedata/googlespreadsheet" , to: 'gamedata#googlespreadsheet'
  post "lumba/gamedata/googlespreadsheet" , to: 'gamedata#googlespreadsheet'
# webplayer
  get 'lumba/webView' , to: 'web_view#index'
  post 'lumba/webView' , to: 'web_view#index'
# gameanalytics
  get 'lumba/gameanalytics' , to: 'gameanalytics#index'
  post 'lumba/gameanalytics' , to: 'gameanalytics#index'
# admin users
  get 'lumba/adminUsers' , to: 'admin_users#index'
  post 'lumba/adminUsers' , to: 'admin_users#index'
# export
 get 'lumba/export' , to: 'exportdata#exportxlsx'
 post 'lumba/export' , to: 'exportdata#exportxlsx'
# get ccu
 get '*ccu', :to => 'ccu#index'
# upload game data files
 get 'lumba/uploadgamedata' , to: 'uploadgamedata#upload'
 post 'lumba/uploadgamedata' , to: 'uploadgamedata#upload'
#switch server
 post 'lumba/switchserver', to: 'switchserver#index'
 post 'lumba/switchserver/apply_to_other_server', to: 'switchserver#apply_to_other_server'
 post 'lumba/switchserver/switchversion', to: 'switchserver#switchversion'
end
