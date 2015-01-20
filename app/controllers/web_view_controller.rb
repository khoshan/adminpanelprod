require 'rubygems' # Only if installed via RubyGems
require 'mysql'
require 'json'

class WebViewController < ApplicationController
  before_filter :login_required
  skip_before_filter :verify_authenticity_token, :only => [:index, :viewinsane]
  
  @selectedmenu = "webView"
  def index
    if (params[:commit]) 
      connectLumba
      @insaneId = params[:insaneid]
      @datas = @dblumba.query("select * from insaneGameState")
      disconnectLumba
    else
      connectLumba
      @datas = @dblumba.query("select * from insaneGameState")
      @insaneId = ""
      disconnectLumba
    end
    @datas
  end
  def viewinsane
  
  end
end
