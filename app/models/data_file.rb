require 'active_record'
class DataFile < ActiveRecord::Base
  def self.save(upload, dir)
    name =  upload.original_filename
    #directory = "#{Rails.root}/exportedfile/currentversionserver/#{@game_version}"
    # create the file path
    path = File.join(dir, name)
    # write the file
    puts path
    File.open(path, "wb+") { |f| f.write(upload.read) }
  end
end
