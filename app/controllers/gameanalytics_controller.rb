class GameanalyticsController < ApplicationController
  before_filter :login_required
  skip_before_filter :verify_authenticity_token, :only => [:index]
  @selectedmenu = "gameanalytics"
  def index
    connectLumbaAppData
    @game_versions = @db.query("select distinct NextGameVersion from ref_Setting")
    disconnectLumbaAppData
  end
end
