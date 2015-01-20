class ExportdataController < ApplicationController
  def exportxlsx
    @exportstatus = "export successful"
    begin
    #`ruby /root/myApp/app/controllers/export.rb`
    #  send_file('/root/myApp/exportedfile/ReferenceData.xlsx', :disposition => :attachment)
    connectLumbaIAP
    datas_in_app_purcha = @dbsfs.query("select * from monetizations")
    disconnectLumbaIAP
    if File.exist?("#{Rails.root}/exportedfile/in_app_purchase.csv")
      `rm #{Rails.root}/exportedfile/in_app_purchase.csv`
    end
    CSV.open("#{Rails.root}/exportedfile/in_app_purchase.csv", "w:UTF-8", {:col_sep => ","}) { |csv|
      csv << ["userId", "spentAmount", "currency", "deviceInfo", "region", "gameState", "createdAt"]
      datas_in_app_purcha.each_hash do |row|
        csv << [row['userId'], row['spentAmount'], row['currency'], row['deviceInfo'], row['region'], row['gameState'], row['createdAt']]
      end
    }
    send_file("#{Rails.root}/exportedfile/in_app_purchase.csv", :disposition => :attachment)
    rescue Exception=>e
      @exportstatus = "export fail: #{e}"
    end
  end
end
