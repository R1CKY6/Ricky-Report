if Framework ~= nil then 
    
    RegisterServerCallback('ricky-report:getStaffList', function(source, cb)
      local staff = GetAllStaff()
      cb(staff)
    end)

    RegisterServerEvent('ricky-report:changeAvailable')
    AddEventHandler('ricky-report:changeAvailable', function(data)
      local found = false
      for k,v in pairs(staffAvailable) do 
        if v.identifier == data.identifier then 
          v.available = data.available
          found = true
        end
      end
      if not found then 
        table.insert(staffAvailable, {
          identifier = data.identifier,
          name = data.name,
          id = data.id,
          available = data.available
        })
      end
      TriggerClientEvent('ricky-report:updateStaffAvailable', -1, GetAllStaff())
    end)

    RegisterServerEvent('ricky-report:createReport')
    AddEventHandler('ricky-report:createReport', function(data)
      local title = data.title
      local type = data.type
      local src = source
      local reportss =  MySQL.Sync.fetchAll("SELECT * FROM ricky_report")
      local reports = #reportss
      local futureId = reports+1
      local result = MySQL.Sync.execute("INSERT INTO ricky_report (id, identifier, reportInfo) VALUES(@id, @identifier, @reportInfo)", {
            ['@reportInfo'] = json.encode({
                title = title,
                type = type,
                user = {
                  name = GetPlayerName(src),
                  steam = GetLicenseType(src, 'steam') or false,
                  discord = '<@'..GetLicenseType(src, 'discord')..'>' or false,
                  license = GetLicenseType(src, 'license') or false,
                  frameworkIdentifier = GetFrameworkIdentifier(src),
                }
            }),
            ['@identifier'] = GetIdentifier(src),
            ['@id'] = futureId
        })
        TriggerClientEvent('ricky-report:updateReportData', -1)
        TriggerClientEvent('ricky-report:createReport', src, futureId)
        TriggerClientEvent('ricky-report:sendNotificationToStaff', -1, Config.Notification['new_report'])
    end)

    RegisterServerCallback('ricky-report:getReport', function(source, cb, idReport)
      local result = MySQL.Sync.fetchAll("SELECT * FROM ricky_report WHERE id = @idReport", {
          ['@idReport'] = idReport
      })
      if not result or not result[1] then 
        cb(false)
        return
      end
      cb(true)
    end)

    RegisterServerCallback('ricky-report:getReports', function(source, cb)
        local identifier = GetIdentifier(source)
        if not identifier then
            cb({})
            return
        end

        local result = MySQL.Sync.fetchAll("SELECT * FROM ricky_report WHERE identifier = @identifier", {
            ['@identifier'] = identifier
        })

        local reports = {}
        

        for k,v in pairs(result) do 
          local claimed = false
          if v.staff and #v.staff >= 1 then 
            claimed = true 
          end
          local closed = false 
          if tonumber(v.closed) == 1 then 
            closed = true
          end
          table.insert(reports, {
            id = v.id,
            title = json.decode(v.reportInfo).title,
            type = json.decode(v.reportInfo).type,
            messages = json.decode(v.messages) or {},
            staff = json.decode(v.staff) or {},
            claimed = claimed,
            closed = closed,
            closedFrom = v.closedFrom or false,
            userInfo = {
              annotation = getAnnotation(v.identifier),
              identifier = v.identifier,
              name = json.decode(v.reportInfo).user.name,
              discord = json.decode(v.reportInfo).user.discord,
              steam = json.decode(v.reportInfo).user.steam,
              license = json.decode(v.reportInfo).user.license,
              frameworkIdentifier = json.decode(v.reportInfo).user.frameworkIdentifier
            }
          })
        end
        cb(reports)
    end)

    RegisterServerCallback('ricky-report:getAllReports', function(source, cb)
      local identifier = GetIdentifier(source)
      if not identifier then
          cb({})
          return
      end

      local result = MySQL.Sync.fetchAll("SELECT * FROM ricky_report")

      local reports = {}

      for k,v in pairs(result) do 
        local claimed = false
        if v.staff and #v.staff >= 1 then 
          claimed = true 
        end
        local closed = false 
        if tonumber(v.closed) == 1 then 
          closed = true
        end
        table.insert(reports, {
          id = v.id,
          title = json.decode(v.reportInfo).title,
          type = json.decode(v.reportInfo).type,
          messages = json.decode(v.messages) or {},
          staff = json.decode(v.staff) or {},
          claimed = claimed,
          closed = closed,
          closedFrom = v.closedFrom or false,
          userInfo = {
            annotation = getAnnotation(v.identifier),
            identifier = v.identifier,
            name = json.decode(v.reportInfo).user.name,
            discord = json.decode(v.reportInfo).user.discord,
            steam = json.decode(v.reportInfo).user.steam,
            license = json.decode(v.reportInfo).user.license,
            frameworkIdentifier = json.decode(v.reportInfo).user.frameworkIdentifier
          }
        })
      end
      cb(reports)
    end)

    RegisterServerEvent('ricky-report:sendMessageToReport')
    AddEventHandler('ricky-report:sendMessageToReport', function(data, position)
      local src = source
      local idReport = data.idReport
      local messages = MySQL.Sync.fetchAll("SELECT messages FROM ricky_report WHERE id = @idReport", {
          ['@idReport'] = idReport
      })

      local messages = json.decode(messages[1].messages) or {}
      if data.type == 'message' then 
        table.insert(messages, {
          fromIdentifier = GetIdentifier(src),
          name = GetPlayerName(src),
          type = data.type,
          content = data.content,
        })
      elseif data.type == 'position' then 
        table.insert(messages, {
          fromIdentifier = GetIdentifier(src),
          name = GetPlayerName(src),
          type = data.type,
          position = position
        })
      elseif data.type == 'image' then 
        table.insert(messages, {
          fromIdentifier = GetIdentifier(src),
          name = GetPlayerName(src),
          type = data.type,
          url = data.url,
        })
      end

      local result = MySQL.Sync.execute("UPDATE ricky_report SET messages = @messages WHERE id = @idReport", {
          ['@messages'] = json.encode(messages),
          ['@idReport'] = idReport
      })

      TriggerClientEvent('ricky-report:updateReportData', -1, idReport)

      TriggerClientEvent('ricky-report:sendNotificationToStaffMessage', -1, idReport, Config.Notification['new_message'])
    end)

    RegisterServerCallback('ricky-report:getMyInfo', function(source, cb)
      local data = {
        identifier = GetIdentifier(source),
        name = GetPlayerName(source)
      }
      cb(data)
    end)

    RegisterServerEvent('ricky-report:sendMessageToChatStaff')
    AddEventHandler('ricky-report:sendMessageToChatStaff', function(data, position, src)
      local content = nil 
      if data.type == 'message' then 
        content = data.content
      elseif data.type == 'position' then 
        content = json.encode(position)
      elseif data.type == 'image' then 
        content = data.url
      end
      
      if not content then 
        return 
      end

        MySQL.Sync.execute("INSERT INTO ricky_report_staffchat (identifier, name, type, content) VALUES(@identifier, @name, @type, @content)", {
          ['@identifier'] = GetIdentifier(src),
          ['@name'] = GetPlayerName(src),
          ['@type'] = data.type,
          ['@content'] = content
        })
      TriggerClientEvent('ricky-report:updateChatStaff', -1, getChatStaffMessages() or {})
    end)

    RegisterServerCallback('ricky-report:getStaffChat', function(source, cb)
      cb(getChatStaffMessages() or {})
    end)
    

    RegisterServerCallback('ricky-report:getIdentifierOnline', function(source, cb, id)
      cb(getIdentifierOnline(id) or false)
    end)

    RegisterServerEvent('ricky-report:saveAnnotation')
    AddEventHandler('ricky-report:saveAnnotation', function(data)
      saveAnnotation(data.identifier, data.annotation)
    end)

    RegisterServerEvent('ricky-report:action')
    AddEventHandler('ricky-report:action', function(data)
      local identifierTarget = data.identifier
      if not identifierTarget then 
        return
      end
      if not getIdentifierOnline(identifierTarget) and not (data.type == 'claim' or data.type == 'closeReport') then 
        return
      end
      local action = data.action
      local idReport = data.idReport
      if data.type == 'goto' then 
        local targetCoords
        if Framework == 'esx' then 
          local xPlayer = ESX.GetPlayerFromIdentifier(identifierTarget)
          if not xPlayer then 
            return
          end
          targetCoords = xPlayer.getCoords(true)
        elseif Framework == 'qbcore' then
          local xPlayer = QBCore.Functions.GetPlayerByCitizenId(identifierTarget)
          if not xPlayer then 
            return
          end
          local ped = GetPlayerPed(xPlayer.PlayerData.source)
          local coords = QBCore.Functions.GetCoords(ped)
          targetCoords = coords
        end

        SetEntityCoords(GetPlayerPed(source), targetCoords.x, targetCoords.y, targetCoords.z)
      elseif data.type == 'bring' then 
        local targetCoords
        if Framework == 'esx' then 
          local xPlayer = ESX.GetPlayerFromId(source)
          if not xPlayer then 
            return
          end
          targetCoords = xPlayer.getCoords(true)
        elseif Framework == 'qbcore' then
          local xPlayer = QBCore.Functions.GetPlayer(source)
          if not xPlayer then 
            return
          end
          local ped = GetPlayerPed(xPlayer.PlayerData.source)
          local coords = QBCore.Functions.GetCoords(ped)
          targetCoords = coords
        end

        if Framework == 'esx' then 
          local xTarget = ESX.GetPlayerFromIdentifier(identifierTarget)
          if not xTarget then 
            return
          end
          xTarget.setCoords(targetCoords)
        elseif Framework == 'qbcore' then
          local xTarget = QBCore.Functions.GetPlayerByCitizenId(identifierTarget)
          if not xTarget then 
            return
          end
          local ped = GetPlayerPed(xTarget.PlayerData.source)
          SetEntityCoords(ped, targetCoords.x, targetCoords.y, targetCoords.z)
        end
      elseif data.type == 'freeze' then 
        local idTarget = nil
        if Framework == 'esx' then 
          local xTarget = ESX.GetPlayerFromIdentifier(identifierTarget)
          if not xTarget then 
            return
          end
          idTarget = xTarget.source
        elseif Framework == 'qbcore' then
          local xTarget = QBCore.Functions.GetPlayerByCitizenId(identifierTarget)
          if not xTarget then 
            return
          end
          idTarget = xTarget.PlayerData.source
        end
        if not idTarget then 
          return
        end
        TriggerClientEvent('ricky-report:freezePlayer', idTarget)
      elseif data.type == 'claim' then
        local stoClaimando = true
        local result = MySQL.Sync.fetchAll("SELECT staff FROM ricky_report WHERE id = @idReport", {
          ['@idReport'] = idReport
        })
      local staff = json.decode(result[1].staff) or {}
        if data.claimed then
          stoClaimando = false
          for k,v in pairs(staff) do 
            if v == data.myIdentifier then 
              table.remove(staff, k)
            end
          end
        else
          table.insert(staff, data.myIdentifier)
        end

        if #staff == 0 then 
          staff = nil
        end

        if staff then 
           MySQL.Sync.execute("UPDATE ricky_report SET staff = @staff WHERE id = @idReport", {
            ['@staff'] = json.encode(staff),
            ['@idReport'] = idReport
          })
        else
          MySQL.Sync.execute("UPDATE ricky_report SET staff = @staff WHERE id = @idReport", {
            ['@staff'] = nil,
            ['@idReport'] = idReport
          })
        end
        local xTarget = nil
        if Framework == 'esx' then 
          xTarget = ESX.GetPlayerFromIdentifier(identifierTarget)
        elseif Framework == 'qbcore' then
          xTarget = QBCore.Functions.GetPlayerByCitizenId(identifierTarget)
        end
        if xTarget and stoClaimando then 
          local id = nil 
          if Framework == 'esx' then 
            id = xTarget.source
          elseif Framework == 'qbcore' then
            id = xTarget.PlayerData.source
          end
          TriggerClientEvent('ricky-report:sendNotificationToUser', id, Config.Notification['your_report_claimed'])
        end
        TriggerClientEvent('ricky-report:updateReportData', -1, idReport)
      elseif data.type == 'closeReport' then
          MySQL.Sync.execute("UPDATE ricky_report SET closed = @closed, closedFrom = @closedFrom WHERE id = @id", {
              ['@id'] = idReport,
              ['@closedFrom'] = GetIdentifier(source),
              ['@closed'] = true
          })
          TriggerClientEvent('ricky-report:updateReportData', -1, idReport)
        end
    end)

    RegisterServerCallback('ricky-report:getDiscordAvatar', function(source, cb, idDiscord)
      idDiscord = idDiscord:gsub('<@', '')
      idDiscord = idDiscord:gsub('>', '')
      idDiscord = tonumber(idDiscord)
      if not idDiscord then 
        cb(false)
        return
      end

      cb(getDiscordAvatar(idDiscord))
    end)

    RegisterServerCallback('ricky-report:ImStaff', function(source, cb)
      cb(getStaff(source) or false)
    end)

    RegisterServerCallback('ricky-report:isClaimed', function(source, cb, idReport)
      cb(isClaimedFromStaff(idReport, source or false))
    end)

    RegisterServerCallback('ricky-report:getStatistic', function(source, cb, data)
      cb(getStatistic(data.type, data.identifier))
    end)

    RegisterServerEvent('ricky-report:sendImage')
    AddEventHandler('ricky-report:sendImage', function()
      TriggerClientEvent('ricky-report:sendImage', -1, ConfigS.Webhook)
    end)
end
