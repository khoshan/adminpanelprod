class TimezoneController < ApplicationController
  before_filter :login_required
  # validate :public_key_resolves
  skip_before_filter :verify_authenticity_token, :only => [:index]
  @selectedmenu = "changetimezone"
  def index
    current_user_name = cookies[:login_username]

    if params[:commit].eql?("Done")
      connectLumbaAppData2
      @admin_users = @dbsfs2.query("UPDATE users SET timezone='#{params[:select_timezone]}' WHERE username = '#{current_user_name}'")
      disconnectLumbaAppData2
    end

    connectLumbaAppData2
    @admin_users = @dbsfs2.query("SELECT * FROM users WHERE username = '#{current_user_name}'")
    disconnectLumbaAppData2
    @timezone = ''
    @admin_users.each do |row|
      @timezone = row["timezone"]
    end
    @admin_users
  end
end