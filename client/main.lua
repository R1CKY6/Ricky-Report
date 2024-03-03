if Framework ~= nil then 
    idReportSelected = nil
    generalUiOpened = false
    staffMenuOpened = false 
    sendingImage = false
    inStaffChat = false
    local configValueLoaded = false
    local infoLoad = nil

    Citizen.CreateThread(function()
        while not infoLoad do
            infoLoad = TriggerServerCallback('ricky-report:getMyInfo')
            Citizen.Wait(0)
        end
        Wait(1000)
        SendNUIMessage({
            type = 'SET_MY_INFO',
            id = GetPlayerServerId(PlayerId()),
            identifier = infoLoad.identifier,
            name = infoLoad.name
        })
        local staff = TriggerServerCallback('ricky-report:getStaffList')
        SendNUIMessage({
            type = 'UPDATE_STAFF',
            staff = staff
        })
    end)

    RegisterCommand(Config.Command.openReportStaff.commandName, function(source, args, rawCommand)
        local staff = TriggerServerCallback('ricky-report:ImStaff') or false
        if not staff then 
            return 
        end
        if not configValueLoaded then 
            SendNUIMessage({
                type = "SET_CONFIGVALUE",
                locales = Config.Locales,
                url = Config.ServerLogo,
                canUserOpenStaffStats = Config.CanUserOpenStaffStats
            })
            configValueLoaded = true
        end
        generalUiOpened = true
        staffMenuOpened = true
        local reports = TriggerServerCallback('ricky-report:getAllReports')
        SetNuiFocus(true, true)
        SendNUIMessage({
            type = 'OPEN_STAFF',
            reports = reports
        })
    end)

    if Config.KeyMapping.openReport.enable then 
        RegisterKeyMapping(Config.Command.openReport.commandName, Config.KeyMapping.openReport.description, 'keyboard', Config.KeyMapping.openReport.key)
    end

    if Config.KeyMapping.openReportStaff.enable then 
        RegisterKeyMapping(Config.Command.openReportStaff.commandName, Config.KeyMapping.openReportStaff.description, 'keyboard', Config.KeyMapping.openReportStaff.key)
    end

    RegisterCommand(Config.Command.openReport.commandName, function(source, args, rawCommand)
        if not configValueLoaded then 
            SendNUIMessage({
                type = "SET_CONFIGVALUE",
                locales = Config.Locales,
                url = Config.ServerLogo,
                canUserOpenStaffStats = Config.CanUserOpenStaffStats
            })
            configValueLoaded = true
        end
        generalUiOpened = true
        staffMenuOpened = false
        SetNuiFocus(true, true)
        local reports = TriggerServerCallback('ricky-report:getReports')
        SendNUIMessage({
            type = 'OPEN_USER',
            reports = reports
        })
    end)

    RegisterNetEvent('ricky-report:createReport')
    AddEventHandler('ricky-report:createReport', function(idReport)
        local report = nil
        while not report do
            Citizen.Wait(0)
            report = TriggerServerCallback('ricky-report:getReport', idReport)
        end
        SendNUIMessage({
            type = 'OPEN_REPORT',
            id = idReport
        })
    end)

    RegisterNetEvent('ricky-report:updateReportData')
    AddEventHandler('ricky-report:updateReportData', function(idReport)
        local reports = nil
        if staffMenuOpened then 
            reports = TriggerServerCallback('ricky-report:getAllReports')
        else
            reports = TriggerServerCallback('ricky-report:getReports')
        end
        SendNUIMessage({
            type = 'UPDATE_REPORT',
            reports = reports
        })
    end)

    RegisterNetEvent('ricky-report:updateStaffAvailable')
    AddEventHandler('ricky-report:updateStaffAvailable', function(staffAvailable)
        SendNUIMessage({
            type = 'UPDATE_STAFF',
            staff = staffAvailable
        })
    end)

    RegisterNetEvent('ricky-report:updateChatStaff')
    AddEventHandler('ricky-report:updateChatStaff', function(messages)
        SendNUIMessage({
            type = 'UPDATE_STAFF_CHAT',
            messages = messages
        })
    end)

    local freezed = false
    local freezedWait = 1000
    Citizen.CreateThread(function()
      while true do
        Citizen.Wait(freezedWait)
        if freezed then 
            freezedWait = 0
            FreezeEntityPosition(PlayerPedId(), true)
        else
            freezedWait = 1000
        end
       end
    end)

    RegisterNetEvent('ricky-report:freezePlayer')
    AddEventHandler('ricky-report:freezePlayer', function()
      local ped = PlayerPedId()
      freezed = not IsEntityPositionFrozen(ped)
      if not freezed then 
          FreezeEntityPosition(ped, false)
      end
    end)

    RegisterNetEvent('ricky-report:sendNotificationToStaff')
    AddEventHandler('ricky-report:sendNotificationToStaff', function(Table)
        local staff = TriggerServerCallback('ricky-report:ImStaff')
        if staff and not (generalUiOpened or staffMenuOpened) then 
            Config.NotificationFunction(Table.label, Table.type)
        end
    end)

    RegisterNetEvent('ricky-report:sendNotificationToUser')
    AddEventHandler('ricky-report:sendNotificationToUser', function(Table)
        if not generalUiOpened then 
            Config.NotificationFunction(Table.label, Table.type)
        end
    end)

    RegisterNetEvent('ricky-report:sendNotificationToStaffMessage')
    AddEventHandler('ricky-report:sendNotificationToStaffMessage', function(idReport, Table)
        local claimed = TriggerServerCallback('ricky-report:isClaimed', idReport)
        if claimed and not staffMenuOpened then 
            Config.NotificationFunction(Table.label, Table.type)
        end
    end)

    RegisterCommand('-+sendticketphoto', function(source, args, rawCommand)
        if (idReportSelected or inStaffChat) and sendingImage then
            SendNUIMessage({
                type = 'SHOW_CONTAINER',
                openReport = idReportSelected,
            })
            TriggerServerEvent('ricky-report:sendImage')
        end
    end)

    RegisterNetEvent('ricky-report:sendImage')
    AddEventHandler('ricky-report:sendImage', function(webhook)
        if (idReportSelected or inStaffChat) and webhook and sendingImage then
            sendingImage = false
            exports['screenshot-basic']:requestScreenshotUpload(webhook, 'files[]', function(data)
                local resp = json.decode(data)
                local url = resp.attachments[1].url
                if idReportSelected then
                    TriggerServerEvent('ricky-report:sendMessageToReport', {
                        type = 'image',
                        url = url,
                        idReport = idReportSelected
                    }, GetEntityCoords(PlayerPedId()))
                else
                    TriggerServerEvent('ricky-report:sendMessageToChatStaff', {
                        type = 'image',
                        url = url
                    }, GetEntityCoords(PlayerPedId()), GetPlayerServerId(PlayerId()))
                end
                SetNuiFocus(true, true)
            end)
        end
    end)
    TriggerEvent('chat:removeSuggestion', '/-+sendticketphoto')

    RegisterCommand('-+sendticketphotoreturn', function(source, args, rawCommand)
        if (idReportSelected or inStaffChat) and sendingImage then
            sendingImage = false
            SetNuiFocus(true, true)
            SendNUIMessage({
                type = 'SHOW_CONTAINER',
                openReport = idReportSelected,
            })

        end
    end)

    TriggerEvent('chat:removeSuggestion', '/-+sendticketphotoreturn')
    RegisterKeyMapping('-+sendticketphotoreturn', Config.KeyMapping.sendImage2.description, 'keyboard', Config.KeyMapping.sendImage2.key)
    RegisterKeyMapping('-+sendticketphoto', Config.KeyMapping.sendImage.description, 'keyboard', Config.KeyMapping.sendImage.key)
end