wss = ARGV[0]
datapurchase_detail = ARGV[1]
ws = wss.add_worksheet("Detail purchases", max_rows = datapurchase_detail.num_rows + 1, max_cols = 21)
        ws[1, 1] = "userId"
        ws[1, 2] = "DiwanLevel"
        ws[1, 3] = "GameLevel"
        ws[1, 4] = "Coins"
        ws[1, 5] = "Water"
        ws[1, 6] = "Oil"
        ws[1, 7] = "Pearls"
        ws[1, 8] = "Daggers"
        ws[1, 9] = "Status"
        ws[1, 10] = "purchasedPearls"
        ws[1, 11] = "purchasedItemId"
        ws[1, 12] = "paidAmount"
        ws[1, 13] = "currency"
        ws[1, 14] = "country"
        ws[1, 15] = "installAt"
        ws[1, 16] = "transaction"
        ws[1, 17] = "Receipt"
        ws[1, 18] = "IpAddress"
        ws[1, 19] = "DeviceInfo"
        ws[1, 20] = "createdAt"
        ws[1, 21] = "Diffirent between createdAt and installAt"
        index = 2
        datapurchase_detail.each_hash do |row|
          ws[index, 1] = row['userId']
          ws[index, 2] = row['diwanLevel']
          ws[index, 3] = row['gameLevel']
          ws[index, 4] = row['coins']
          ws[index, 5] = row['water']
          ws[index, 6] = row['oil']
          ws[index, 7] = row['pearls']
          ws[index, 8] = row['daggers']
          ws[index, 9] = row['status']
          ws[index, 10] = row['purchasedPearls']
          ws[index, 11] = row['purchasedItemId']
          ws[index, 12] = row['paidAmount']
          ws[index, 13] = row['currency']
          ws[index, 14] = row['country']
          ws[index, 15] = "#{row['installAt']} PDT"
          ws[index, 16] = row['transaction']
          ws[index, 17] = row['verifyingText']
          ws[index, 18] = row['ipAddress']
          ws[index, 19] = row['deviceInfo']
          ws[index, 20] = "#{row['createdAt']} PDT"
          ws[index, 21] = "#{convert_second_to_hhmmss(row['timediff'].to_i)} (dd:hh:mm:ss)"
          index = index + 1
        end
        ws.save()

        ws = wss.add_worksheet("Summary purchases", max_rows = datapurchase.num_rows + 1, max_cols = 8)
        ws[1, 1] = "userId"
        ws[1, 2] = "CORRECT"
        ws[1, 3] = "INVALID"
        ws[1, 4] = "DUPLICATES"
        ws[1, 5] = "NOVERIFICATIONRESPONSE"
        ws[1, 6] = "NOTVERIFIED"
        ws[1, 7] = "NOTHANDLE"
        ws[1, 8] = "PRODUCTNOTINTHELIST"
        index = 2
        datapurchase.each_hash do |row|
          ws[index, 1] = row['userId']
          ws[index, 2] = row['CORRECT']
          ws[index, 3] = row['INVALID']
          ws[index, 4] = row['DUPLICATES']
          ws[index, 5] = row['NOVERIFICATIONRESPONSE']
          ws[index, 6] = row['NOTVERIFIED']
          ws[index, 7] = row['NOTHANDLE']
          ws[index, 8] = row['PRODUCTNOTINTHELIST']
          index = index + 1
        end
        ws.save()
    wss.worksheets[0].delete()
