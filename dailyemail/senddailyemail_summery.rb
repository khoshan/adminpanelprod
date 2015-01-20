# encoding: utf-8
require 'mysql'
require 'json'
require 'csv'
require 'net/http'
require 'rubygems'
require 'csv'
require 'time'
require 'net/smtp'

def dailyemail
  a = Date.today.prev_day.strftime("%B %d, %Y")
  puts a

  time = Date.today.prev_day
  #time = time.prev_day
  #timeheader = Date.today.prev_day.strftime("%B %d, %Y")
  timeheader = time.strftime("%B %d, %Y")
  starttime = "#{time} 00:00:00 -08:00"
  endtime = "#{time} 23:59:59 -08:00"
  startdayutc = Time.parse(starttime).utc
  enddayutc = Time.parse(endtime).utc
  dbprod = Mysql.new('lumba.ckyzvr2punhb.eu-west-1.rds.amazonaws.com', 'sgsvn', 'buncha11', 'lumba')
  dbprod.query "SET NAMES utf8"

  str_query_ccu = "select ccu, CONVERT_TZ(createdAt,'+00:00','-08:00') createdAt from stats where createdAt > '#{startdayutc}' and createdAt < '#{enddayutc}' order by ccu desc"
  ccuResult = dbprod.query(str_query_ccu)
  ccuArr = []
  ccuResult.each_hash do |row|
    createdAt1 = Time.parse(row['createdAt'])
    timeresult = createdAt1.strftime("at %I:%M%p").downcase
    ccuArr.push("#{row['ccu']} (#{timeresult} PT)")
  end
  max_ccu = ccuArr.first
  min_ccu = ccuArr.last
  # new player
  str_query_new_player = "select count(userId) totalnewplaying from user_v31 where createdAt >= '#{startdayutc}' and createdAt <= '#{enddayutc}'"
  totalnewplaying = dbprod.query(str_query_new_player).fetch_hash['totalnewplaying']
  # Number of unique users
  str_query_numberuser = "select count(userId) totalplaying from user_v31 where createdAt <= '#{enddayutc}'"
  totalplaying = dbprod.query(str_query_numberuser).fetch_hash['totalplaying']

  # Number of IAP purchases
  dbprod_iap = Mysql.new('lumba.ckyzvr2punhb.eu-west-1.rds.amazonaws.com', 'sgsvn', 'buncha11', 'lumba_iap')
  str_query_valid_iap = "select count(status) as num_valid_iap from purchases where status = 'Valid' and createdAt >= '#{startdayutc}' and createdAt <= '#{enddayutc}'"
  total_valid_iap = dbprod_iap.query(str_query_valid_iap).fetch_hash['num_valid_iap']

  # DAU
  str_query_v31 = "select count(distinct userId) DAU from lumba_iap.activeUsers_v31 where login > '#{startdayutc}' and login <= '#{enddayutc}'"
  dauresult_v31 = dbprod_iap.query(str_query_v31).fetch_hash['DAU']
  dau = dauresult_v31.to_i
  puts dau
  # total amount iap purchase
  str_query_total_iap_usd = "select purchasedPearls, paidAmount, rateToUSD, userId from purchases where status = 'Valid' and createdAt >= '#{startdayutc}' and createdAt <= '#{enddayutc}'"
  puts (str_query_total_iap_usd)
  total_iap_usd = dbprod_iap.query(str_query_total_iap_usd)
  moneyusdvaluearr = []
  hashuserId = {}
  moneyusdvalue = 0.0
  total_iap_usd.each_hash do |row|
    moneyusdvalue = 0.0
    if !row['rateToUSD'].nil?
      if !row['paidAmount'].to_s.eql?("0")
        moneyusdvalue = (row['rateToUSD'].to_f * row['paidAmount'].to_f).to_f.round(2)
        moneyusdvaluearr.push((moneyusdvalue * 0.7).to_f.round(3))
      else
        if (row['purchasedPearls'].to_s.eql?("625"))
          moneyusdvalue = 4.99
          moneyusdvaluearr.push((moneyusdvalue * 0.7).to_f.round(3))
        elsif (row['purchasedPearls'].to_s.eql?("1500"))
          moneyusdvalue = 9.99
          moneyusdvaluearr.push((moneyusdvalue * 0.7).to_f.round(3))
        elsif (row['purchasedPearls'].to_s.eql?("3125"))
          moneyusdvalue = 19.99
          moneyusdvaluearr.push((moneyusdvalue * 0.7).to_f.round(3))
        elsif (row['purchasedPearls'].to_s.eql?("8125"))
          moneyusdvalue = 49.99
          moneyusdvaluearr.push((moneyusdvalue * 0.7).to_f.round(3))
        elsif (row['purchasedPearls'].to_s.eql?("17500"))
          moneyusdvalue = 99.99
          moneyusdvaluearr.push((moneyusdvalue * 0.7).to_f.round(3))
        end
      end
      puts "Is 0: #{row['purchasedPearls']}  paidAmount: #{row['paidAmount']}   moneyusdvalue: #{moneyusdvalue}"
    else
      if !row['paidAmount'].to_s.eql?("0")
        moneyusdvalue = row['paidAmount'].to_f.round(2)
        moneyusdvaluearr.push((moneyusdvalue * 0.7).to_f.round(3))
      else
        #puts "Is 0: #{row['purchasedPearls']}"
        if (row['purchasedPearls'].to_s.eql?("625"))
          moneyusdvalue = 4.99
          moneyusdvaluearr.push((moneyusdvalue * 0.7).to_f.round(3))
        elsif (row['purchasedPearls'].to_s.eql?("1500"))
          moneyusdvalue = 9.99
          moneyusdvaluearr.push((moneyusdvalue * 0.7).to_f.round(3))
        elsif (row['purchasedPearls'].to_s.eql?("3125"))
          moneyusdvalue = 19.99
          moneyusdvaluearr.push((moneyusdvalue * 0.7).to_f.round(3))
        elsif (row['purchasedPearls'].to_s.eql?("8125"))
          moneyusdvalue = 49.99
          moneyusdvaluearr.push((moneyusdvalue * 0.7).to_f.round(3))
        elsif (row['purchasedPearls'].to_s.eql?("17500"))
          moneyusdvalue = 99.99
          moneyusdvaluearr.push((moneyusdvalue * 0.7).to_f.round(3))
        end
      end
    end
    if hashuserId[row['userId']].nil?
      hashuserId[row['userId']] = 0
    end
    hashuserId[row['userId']] = hashuserId[row['userId']] + (moneyusdvalue * 0.7).to_f.round(3)
  end
  puts moneyusdvaluearr
  hashafterorder = hashuserId.sort {|a1,a2| a2[1]<=>a1[1]}
  #puts "============="
  #puts hashafterorder
  #puts "================"
  toppaid = "Top players paid:"
  (0..2).each do |i|
    hashobj = hashafterorder[i]
    if hashobj.size > 1
      str_query_villagename = "select name from user_v31 where userId = '#{hashobj[0]}'"
      villagename = dbprod.query(str_query_villagename).fetch_hash['name']
      toppaid = "#{toppaid}\n- Player #{(i + 1)}: #{villagename} (net $#{hashobj[1].to_f.round(2)})"
    end
  end
  total_money_usd = moneyusdvaluearr.inject(:+).to_f.round(2)

  #puts toppaid
  # player purchase first time
  newpurchases = 0
  #str_query_newpurchase = "SELECT userId, SUM(IF(status = 'Valid' && createdAt >= '#{startdayutc}' && createdAt <= '#{enddayutc}',1,0)) as TODAY, SUM(IF(status = 'Valid' && createdAt < '#{startdayutc}',1,0)) NOTTODAY FROM purchases group by userId HAVING TODAY > 0 AND NOTTODAY = 0 order by TODAY desc;"
  #strnew = "SELECT COUNT(*) as newpayingusers FROM (SELECT DISTINCT userId FROM lumba_iap.purchases p1 WHERE status = 'Valid' AND createdAt BETWEEN '#{startdayutc}' AND '#{enddayutc}' AND NOT EXISTS (SELECT * FROM lumba_iap.purchases p2 WHERE p2.userId = p1.userId AND createdAt < '#{startdayutc}' AND status = 'Valid')) test1"
  str_new = "SELECT userId FROM lumba_iap.purchases p1 WHERE status = 'Valid' AND createdAt BETWEEN '#{startdayutc}' AND '#{enddayutc}' AND NOT EXISTS (SELECT * FROM lumba_iap.purchases p2 WHERE p2.userId = p1.userId AND createdAt < '#{startdayutc}' AND status = 'Valid')"
  # newpurchases_tmp = dbprod_iap.query(str_query_newpurchase)
  # newpurchases_tmp.each_hash do |row|
  #   newpurchases = newpurchases + 1
  # end
  count_array = []
  count_temp = dbprod_iap.query(str_new)
  count_temp.each_hash do |row|
    count_array.push(row['userId'])
  end
  count_array = count_array.uniq
  #newpurchases = dbprod_iap. query(strnew).fetch_hash['newpayingusers']
  File.open("/root/myApp/dailyemail/dailysummary.txt", 'w') { |file| file.write("Daily Stats for #{timeheader} (PT)\n- Max CCU: #{max_ccu}\n- Min CCU: #{min_ccu}\n- Number of IAP: #{total_valid_iap}\n- Total amount of IAP (net): $#{total_money_usd}\n- Number of first-time players: #{totalnewplaying}\n- Number of players who purchased IAP for the first time: #{count_array.size}\n- Daily active users: #{dau}\n- Total unique users: #{totalplaying}\n#{toppaid}") }

  dbprod.close
  dbprod_iap.close
  `mail -s 'TR - Daily Stats' corporate@lum.ba -c 'hieuvt@sixthgearstudios.com, hchoi@sixthgearstudios.com' -- -f 'TR.Bot@no_reply' < /root/myApp/dailyemail/dailysummary.txt`
  #`mail -s 'TR - Daily Stats' trangtn@sixthgearstudios.com -c 'hieuvt@sixthgearstudios.com, hchoi@sixthgearstudios.com' -- -f 'TR.Bot@no_reply' < /root/myApp/dailyemail/dailysummary.txt`
  #`mail -s 'TR - Daily Stats' trieupd@sixthgearstudios.com -- -f 'TR.Bot@no_reply' < /root/myApp/dailyemail/dailysummary.txt`
  `mail -s 'TR - Daily Stats' hunglv@sixthgearstudios.com -c 'nhatphai99@gmail.com' -- -f 'TR.Bot@no_reply' < /root/myApp/dailyemail/dailysummary.txt`
end

dailyemail