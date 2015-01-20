# encoding: utf-8
require 'mysql'
require 'json'

class CcuController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:index]
  @selectedmenu = "ccu"
  def index
    begin
      logger.info(request.url)
      path_info = request.env['PATH_INFO']
      query_string = request.env['QUERY_STRING']
      if query_string.eql?("key=hcLoCUz4T16kVSrJnYptYA")
      timequery = path_info.gsub("/ccu/", "")
      ccustartdate = "#{timequery} 00:00:00 +00:00"
      ccuenddate = "#{timequery} 23:59:59 +00:00"
      logger.info(ccustartdate)
      logger.info(ccuenddate)
      starttime = Time.parse("#{ccustartdate}").utc
      endtime = Time.parse("#{ccuenddate}").utc
      connectLumba
      str_query = "select ccu, createdAt as createdAtUTC, CONVERT_TZ(createdAt,'+00:00','-07:00') createdAt from stats where createdAt > '#{starttime}' and createdAt < '#{endtime}'"
      ccuResult = @dblumba.query(str_query)
      disconnectLumba
      `rm -rf #{Rails.root}/exportedfile/ccu/ccu_view.txt`
      CSV.open("#{Rails.root}/exportedfile/ccu/ccu_view.txt", "w:ASCII-8BIT:UTF-8", {:col_sep => "\t"}) { |csv|
        ccuResult.each_hash do |row|
            csv << [row['createdAtUTC'], row['ccu']]
        end
      }
      render inline: File.read("#{Rails.root}/exportedfile/ccu/ccu_view.txt")
      else
        render "wrong_key"
      end
      rescue Exception=>e
        render inline: "There's error, Please check url"
      end
    end
end
