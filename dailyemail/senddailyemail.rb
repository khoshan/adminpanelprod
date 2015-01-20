# encoding: utf-8
require 'mysql'
require 'json'
require 'csv'
require 'net/http'
require 'rubygems'
require 'csv'
require 'net/smtp'
require 'time'

def dailyccu
  time = Time.now.to_s
  time = DateTime.parse(time).strftime("%Y-%m-%d")
  time = Date.today.prev_day
  starttimept = "#{time} 00:00:00 -07:00"
  endtimept = "#{time} 23:59:59 -07:00"
  starttime = Time.parse(starttimept).utc
  endtime = Time.parse(endtimept).utc

  dbprod = Mysql.new('lumba.ckyzvr2punhb.eu-west-1.rds.amazonaws.com', 'sgsvn', 'buncha11', 'lumba')
  CSV.open("/root/myApp/exportedfile/ccu/dailyccu.txt", "w:ASCII-8BIT:UTF-8", {:col_sep => "\t"}) { |csv|
    csv << ["ServerIp", "CCU", "CreatedAt (in PT time)"]
     str_query = "select serverIp, version, ccu, sfsVersion, CONVERT_TZ(createdAt,'+00:00','-07:00') createdAt from stats where createdAt > '#{starttime}' and createdAt < '#{endtime}'"
     ccuResult = dbprod.query(str_query)
     ccuResult.each_hash do |row|
       csv << [row['serverIp'], row['ccu'], row['createdAt']]
     end
  }
  dbprod.close
end


def send_mail_with_attachment(filepath, filename, content_message, from_email, to_email)
    marker = "AUNIQUEMARKER"
    body = content_message
    # Define the main headers.
    part1 =<<EOF
From: #{from_email}
To: #{to_email}
Subject: Daily CCU information
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary=#{marker}
--#{marker}
EOF
    mailtext = part1
    part2 =<<EOF
Content-Type: text/plain
Content-Transfer-Encoding:8bit

#{body}
--#{marker}
EOF
    mailtext = mailtext + part2

      filecontent = File.read(filepath)

      encodedcontent = [filecontent].pack("m")   # base64
        # Define the attachment section
        part3 =<<EOF
Content-Type: text/csv; name=\"#{filename}\"
Content-Transfer-Encoding:base64
Content-Disposition: attachment; filename="#{filename}"
#{encodedcontent}
--#{marker}--
EOF
      mailtext = mailtext + part3

    begin
        smtp = Net::SMTP.new('smtp.gmail.com', 587 )
        smtp.enable_starttls
        smtp.start('gmail.com', 'trangtn@sixthgearstudios.com', '12345678!', :login) do |smtp|
        smtp.sendmail(mailtext, "no_reply", ["hieuvt@sixthgearstudios.com", "trangtn@sixthgearstudios.com", "hchoi@sixthgearstudios.com"])
        #smtp.sendmail(mailtext, "no_reply", ["trangtn@sixthgearstudios.com"])
      end
    rescue Exception => e
    end
  end

time = Time.now.to_s
time = DateTime.parse(time).strftime("%Y-%m-%d")
puts time

dailyccu
send_mail_with_attachment("/root/myApp/exportedfile/ccu/dailyccu.txt", "dailyccu.txt", "Daily CCU", "trangtn@sixthgearstudios.com", "trangtn@sixthgearstudios.com")
