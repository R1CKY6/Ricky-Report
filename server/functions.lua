ESX = nil
QBCore = nil
Framework = nil
staffAvailable = {}
GetCore = function()
    if Config.Framework == 'esx' then
        ESX = exports['es_extended']:getSharedObject()
        Framework = 'esx'
    elseif Config.Framework == 'qbcore' then
        QBCore = exports['qb-core']:GetCoreObject()
        Framework = 'qbcore'
    elseif Config.Framework == 'autodetect' then
        if GetResourceState('es_extended') == 'started' then
            ESX = exports['es_extended']:getSharedObject()
            Framework = 'esx'
        elseif GetResourceState('qb-core') == 'started' then
            QBCore = exports['qb-core']:GetCoreObject()
            Framework = 'qbcore'
        end
    else
        print('Invalid framework in config.lua, script is not working.')
        return
    end
    print('Framework detected: ' .. Framework)
end

GetCore()


if Framework ~= nil then 
    RegisterServerCallback = function(name, cb)
        if Framework == 'esx' then 
            ESX.RegisterServerCallback(name, cb)
        elseif Framework == 'qbcore' then
            QBCore.Functions.CreateCallback(name, cb)
        end
    end

    GetIdentifier = function(source)
        return GetLicenseType(source, Config.LicenseType)
    end

    GetFrameworkIdentifier = function(source)
        if Framework == 'esx' then 
            local xPlayer = ESX.GetPlayerFromId(source)
            return xPlayer.identifier
        elseif Framework == 'qbcore' then
            local xPlayer = QBCore.Functions.GetPlayer(source)
            return xPlayer.PlayerData.citizenid
        end
    end

    GetLicenseType = function(source, licenseType)
        local identifiers = GetPlayerIdentifiers(source)
        for k,v in pairs(identifiers) do 
            if licenseType == 'discord' then 
                if string.sub(v, 1, string.len('discord:')) == 'discord:' then 
                    return v:gsub('discord:', '')
                end
            elseif licenseType == 'steam' then
                if string.sub(v, 1, string.len('steam:')) == 'steam:' then 
                    return v:gsub('steam:', '')
                end
            elseif licenseType == 'license' then
                if string.sub(v, 1, string.len('license:')) == 'license:' then 
                    return v:gsub('license:', '')
                end
            end
        end
        return false
    end

    getDiscordAvatar = function(id)
        local tokenBot = ConfigS.DiscordToken or ''
        if tokenBot == '' then 
            return false
        end
        local avatar = nil
        PerformHttpRequest('https://discord.com/api/v8/users/'..id, function(statusCode, response, headers)
            if statusCode == 200 then 
                local data = json.decode(response)
                avatar = 'https://cdn.discordapp.com/avatars/'..id..'/'..data.avatar..'.png'
            else
                avatar = false
            end
        end, 'GET', '', {['Authorization'] = 'Bot ' .. tokenBot})
        while avatar == nil do 
            Citizen.Wait(0)
        end
        return avatar
    end

    getIdentifierOnline = function(id)
        if not id then 
            return 
        end
        if Framework == 'esx' then 
            local xPlayer = ESX.GetPlayerFromIdentifier(id)
            if xPlayer then 
                return true
            else
                return false
            end
          elseif Framework == 'qbcore' then
            local xPlayer = QBCore.Functions.GetPlayerByCitizenId(id)
            if xPlayer then 
              return true
            else
              return false
            end
        end
    end

    getAnnotation = function(identifier)
        local result =  MySQL.Sync.fetchAll("SELECT * FROM ricky_report_annotation WHERE identifier = @identifier", {
              ['@identifier'] =identifier,
        })
        if not result or not result[1] then
            return ''
        else
            return result[1].annotation
        end
    end

    saveAnnotation = function(identifier, newText)
        local result =  MySQL.Sync.fetchAll("SELECT * FROM ricky_report_annotation WHERE identifier = @identifier", {
              ['@identifier'] =identifier,
        })
        if not result or not result[1] then
            MySQL.Async.execute('INSERT INTO ricky_report_annotation (identifier, annotation) VALUES (@identifier, @annotation)', {
                ['@identifier'] = identifier,
                ['@annotation'] = newText
            })
        else
            MySQL.Async.execute('UPDATE ricky_report_annotation SET annotation = @annotation WHERE identifier = @identifier', {
                ['@identifier'] = identifier,
                ['@annotation'] = newText
            })
        end 
    end

    getStaff = function(source)
        if Framework == 'esx' then 
            local xPlayer = ESX.GetPlayerFromId(source)
            if xPlayer then 
                for k,v in pairs(Config.StaffGroups) do 
                    if xPlayer.getGroup() == v then 
                        return true
                    end
                end
            end
        elseif Framework == 'qbcore' then
            local xPlayer = QBCore.Functions.GetPlayer(source)
            if xPlayer then 
                for k,v in pairs(Config.StaffGroups) do 
                    local hasPerm = QBCore.Functions.HasPermission(xPlayer.PlayerData.source, v)
                    if hasPerm then 
                        return true
                    end
                end
            end
        end
        return false
    end

    isClaimedFromStaff = function(idReport, source)
        local result = MySQL.Sync.fetchAll('SELECT * FROM ricky_report WHERE id = @id', {
            ['@id'] = idReport
        })
        if not result or not result[1] then 
            return false
        else
            local staff = json.decode(result[1].staff) or {}
            if staff[source] then 
                return true
            else
                return false
            end
        end
    end

    getChatStaffMessages = function()
        local result =  MySQL.Sync.fetchAll("SELECT * FROM ricky_report_staffchat")
        if not result or not result[1] then 
          return {}
        end
        local messages = {}
  
        for k,v in pairs(result) do 
          if v.type == 'message' then 
            table.insert(messages, {
              fromIdentifier = v.identifier,
              name = v.name,
              type = v.type,
              content = v.content
            })
          elseif v.type == 'position' then 
            table.insert(messages, {
              fromIdentifier = v.identifier,
              name = v.name,
              type = v.type,
              position = json.decode(v.content)
            })
          elseif v.type == 'image' then
            table.insert(messages, {
              fromIdentifier = v.identifier,
              name = v.name,
              type = v.type,
              url = v.content
            })
          end
        end
        return messages or {}
    end

    GetAllStaff = function()
        local staff = {}
        if Framework == 'esx' then 
          local xPlayers = ESX.GetExtendedPlayers()
          local staffFound = {}
          for k,v in pairs(xPlayers) do 
            local group = xPlayers[k].getGroup()
            for a,b in pairs(Config.StaffGroups) do 
              if group == b and not staffFound[xPlayers[k].source] then
                staffFound[xPlayers[k].source] = true
                table.insert(staff, {
                  identifier = GetIdentifier(xPlayers[k].source),
                  name = GetPlayerName(xPlayers[k].source),
                  id = xPlayers[k].source,
                  available = StaffAvailable(GetIdentifier(xPlayers[k].source)) or false
                })
              end
            end
          end
        elseif Framework == 'qbcore' then 
          local xPlayers = QBCore.Functions.GetPlayers()
          local staffFound = {}
          for k,v in pairs(xPlayers) do 
            local id = xPlayers[k]
            for a,b in pairs(Config.StaffGroups) do 
              local hasPerm = QBCore.Functions.HasPermission(id, b)
              if hasPerm and not staffFound[id] then 
                staffFound[id] = true
                table.insert(staff, {
                  identifier = GetIdentifier(id),
                  name = GetPlayerName(id),
                  id = id,
                  available = StaffAvailable(GetIdentifier(id)) or false
                })
              end
            end
          end
        end
        return staff
    end
  
    StaffAvailable = function(identifier)
        for k,v in pairs(staffAvailable) do 
          if v.identifier == identifier then 
            return v.available
          end
        end
        return false
    end

    getStatistic = function(type, identifier)
        local claimed = 0
        local closed = 0
        local messages = 0
        if identifier then 
            if type == 'report_claimed' then 
                local reports =  MySQL.Sync.fetchAll("SELECT * FROM ricky_report")
                for k,v in pairs(reports) do 
                    local staff = json.decode(v.staff) or {}
                    for a,b in pairs(staff) do 
                        if b == identifier then 
                            claimed = claimed + 1
                        end
                    end
                end

                if(claimed >= 1000) then 
                    claimed = (claimed / 1000).. "K"
                    return claimed
                else
                    return claimed
                end
            elseif type == 'report_closed' then 
                local reports =  MySQL.Sync.fetchAll("SELECT * FROM ricky_report WHERE closed = @closed", {
                    ['@closed'] = 1
                })
                for k,v in pairs(reports) do 
                    local closedFrom = v.closedFrom or false 
                    if closedFrom == identifier then 
                        closed = closed + 1
                    end
                end
                if(closed >= 1000) then 
                    closed = (closed / 1000).. "K"
                    return closed
                else
                    return closed
                end
            elseif type == 'sent_messages' then 
                local reports =  MySQL.Sync.fetchAll("SELECT * FROM ricky_report")
                for k,v in pairs(reports) do 
                    local message = json.decode(v.messages) or {}
                    for a,b in pairs(message) do 
                        if b.fromIdentifier == identifier then 
                            messages = messages + 1
                        end
                    end
                end
                if(messages >= 1000) then 
                    messages = (messages / 1000).. "K"
                    return messages
                else
                    return messages
                end
            end
        end
    end

    
end

