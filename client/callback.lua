if Framework ~= nil then 
    RegisterNUICallback('createNewReport', function(data, cb)
        TriggerServerEvent('ricky-report:createReport', data)
    end)

    RegisterNUICallback('sendMessageToReport', function(data, cb)
        TriggerServerEvent('ricky-report:sendMessageToReport', data, GetEntityCoords(PlayerPedId()))
    end)

    RegisterNUICallback('selectReport', function(data, cb)
        idReportSelected = data.idReport
    end)

    RegisterNUICallback('getMyInfo', function(data, cb)
        local info = TriggerServerCallback('ricky-report:getMyInfo')
        cb(info)
    end)

    RegisterNUICallback('changeAvailable', function(data, cb)
        TriggerServerEvent('ricky-report:changeAvailable', data)
    end)

    RegisterNUICallback('sendMessageToChatStaff', function(data, cb)
        TriggerServerEvent('ricky-report:sendMessageToChatStaff', data, GetEntityCoords(PlayerPedId()), GetPlayerServerId(PlayerId()))
    end)

    RegisterNUICallback('getStaff', function(data, cb)
        local staff = TriggerServerCallback('ricky-report:getStaffList')
        cb(staff)
    end)

    RegisterNUICallback('close', function(data, cb)
        SetNuiFocus(false, false)
        idReportSelected = nil
        generalUiOpened = false
        staffMenuOpened = false
        sendingImage = false
    end)

    RegisterNUICallback('action', function(data, cb)
        TriggerServerEvent('ricky-report:action', data)
    end)

    RegisterNUICallback('setWaypoint', function(data, cb)
        local x = data.position.x
        local y = data.position.y
        local z = data.position.z
        SetNewWaypoint(x, y)
        Config.NotificationFunction(Config.Notification.new_waypoint.label, Config.Notification.new_waypoint.type)
    end)

    RegisterNUICallback('getIdentifierOnline', function(data, cb)
        local online = TriggerServerCallback('ricky-report:getIdentifierOnline', data.identifier)
        cb(online)
    end)

    RegisterNUICallback('getAvatar', function(data, cb)
        local avatar = TriggerServerCallback('ricky-report:getDiscordAvatar', data.idDiscord)
        cb(avatar)
    end)

    RegisterNUICallback('getStaffChat', function(data, cb)
        local messages = TriggerServerCallback('ricky-report:getStaffChat')
        inStaffChat = true
        cb(messages)
    end)

    RegisterNUICallback('noStaffChat', function(data, cb)
        inStaffChat = false
    end)

    RegisterNUICallback('saveAnnotation', function(data, cb)
        TriggerServerEvent('ricky-report:saveAnnotation', data)
    end)

    RegisterNUICallback('getStatistic', function(data, cb)
        local statistic = TriggerServerCallback('ricky-report:getStatistic', data)
        cb(statistic)
    end)

    RegisterNUICallback('send_image', function(data, cb)
        SetNuiFocus(false, false)
        sendingImage = true
    end)
end