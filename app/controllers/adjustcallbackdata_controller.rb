require 'mysql'
require 'json'

class AdjustcallbackdataController < ApplicationController
  before_filter :login_required, :block_user_from_action
  skip_before_filter :verify_authenticity_token, :only => [:index]

  def index
  end

  def show_log
    respond_to do |format|
      begin
      format.html # show.html.erb
      # format.xml  { render :xml => Person.all }

      # With the data grid, we need to render Json data
      format.js do
        # What is the first line of the result set we want ? (due to pagination. 0 = first)
        offset = (params["page"].to_i-1)*params["rp"].to_i if params["page"] and params["rp"]

        connectLumba
          queryGetlog = @dblumba.query("select count(*) as total from errorLog_v31 where errorType=8;")
        disconnectLumba

        total= 0
        # Total count of lines, before paginating
        queryGetlog.each_hash do |row|
          total = row["total"]
        end

        connectLumba
          sql = "select userId,error,createdAt from errorLog_v31 where errorType=8 ORDER BY id DESC LIMIT #{params["rp"]} OFFSET #{offset};"
          queryGetlog = @dblumba.query(sql)
        disconnectLumba
        # Rendering
        return_data = Hash.new()
        array_data = Array.new()

        queryGetlog.each_hash do |row|
          # puts Time.at(row[24].to_i()/1000) -7.hours
          # row[35] = (row[35] +@timezone.hours).strftime("%Y/%m/%d %H:%M:%S")
          # row[2] = (row[2].strftime("%Y/%m/%d %H:%M:%S"))
          array_data.push(:cell=>row)
          # puts row[2]
        end

        return_data[:rows] = array_data
        return_data[:page] = params["page"]
        return_data[:total] = total
        render :json => return_data.to_json
      end #format.js
      rescue Exception => e
        puts e
        end
    end #respond_to
  end #show_lumba_history
end