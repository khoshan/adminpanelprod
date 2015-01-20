# encoding: utf-8
require 'mysql'
require 'json'
require 'csv'
require 'net/http'
require 'rubygems'
require 'csv'
require 'net/smtp'

def dailyccu
  time = Time.now.utc.to_s
  puts time
  time = DateTime.parse(time).strftime("%Y-%m-%d")
  starttime = "#{time} 00:00:00"
  endtime = "#{time} 23:59:59"
  dbdev = Mysql.new('lumbadev.ckyzvr2punhb.eu-west-1.rds.amazonaws.com', 'sgsvn', 'buncha11', 'lumba')
  longestsql = ""
  CSV.open("/root/myApp/exportedfile/ccu/sql_slow_query.txt", "w:ASCII-8BIT:UTF-8", {:col_sep => "\t"}) { |csv|
    csv << ["User Host", "Query Time", "DB", "Start Time (UTC)", "SQL Text"]
     str_query = "select user_host, query_time, db, start_time, sql_text from mysql.slow_log where start_time > '#{starttime}' and start_time < '#{endtime}' order by query_time desc"
     slowlogResult = dbdev.query(str_query)
     slowlogResult.each_hash do |row|
       csv << [row['user_host'], row['query_time'], row['db'], row['start_time'], row['sql_text']]
     end
  }
  dbdev.close
end


def send_mail_with_attachment(filepath, filename, content_message, from_email, to_email)
    marker = "AUNIQUEMARKER"
    body = content_message
    # Define the main headers.
    part1 =<<EOF
From: #{from_email}
To: #{to_email}
Subject: Slow SQL information
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

time = Time.now.utc.to_s
time = DateTime.parse(time).strftime("%Y-%m-%d")
puts time

dailyccu
send_mail_with_attachment("/root/myApp/exportedfile/ccu/sql_slow_query.txt", "sql_slow_query.txt", "Slow SQL Log", "trangtn@sixthgearstudios.com", "trangtn@sixthgearstudios.com")
