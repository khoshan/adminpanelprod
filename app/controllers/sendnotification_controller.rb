require 'apns'
require 'gcm'
class SendnotificationController < ApplicationController
  before_filter :login_required, :block_user_from_action, :block_support_from_action
  skip_before_filter :verify_authenticity_token, :only => [:index]
  def index
    if params[:commit]
       connectLumba
       str_query = "select deviceId, platform, language from userMeta_v22"
       user_metas = @dblumba.query(str_query)
       disconnectLumba
       APNS.host = 'gateway.sandbox.push.apple.com'
       APNS.pem = '/root/myApp/config/cert.pem'
       APNS.port = 2195
       #  android
       gcm = GCM.new('AIzaSyCW7M8jGtAcygKX0wvfjdaOC4sARbOZnd4')
       options = {data: {content_title: "Lumba", content_text: params[:englishmessage], ticker: params[:englishmessage]}, collapse_key: "Lumba"} 
       puts options
       options_arabic = {data: {content_title: "Lumba", content_text: params[:arabicmessage], ticker: params[:arabicmessage]}, collapse_key: "Lumba"}
       registration_ids = []
       registration_arabic_ids = []
       user_metas.each_hash do |row|
         if row['platform'].eql?("ios")
           puts "#{row['language']}"
           if row['language'].to_s.eql?("0")
             puts "11"
             APNS.send_notification(row['deviceId'], params[:englishmessage] )
           elsif row['language'].to_s.eql?("1")
             puts "12"
             APNS.send_notification(row['deviceId'], params[:arabicmessage] )
           end
         else
           if row['language'] == 0
             registration_ids.push(row['deviceId'])
           elsif row['language'] == 1
             registration_arabic_ids.push(row['deviceId'])
           end
         end
       end  
       #APNS.send_notification(device_token, params[:arabicmessage] )
       gcm.send_notification(registration_ids, options)
       gcm.send_notification(registration_arabic_ids, options_arabic)
    end
  end
end
