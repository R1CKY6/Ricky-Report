ESX = nil
QBCore = nil
Framework = nil
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
    TriggerServerCallback = function(name, data)
        local data2 = nil
        if Framework == 'esx' then 
            ESX.TriggerServerCallback(name, function(data3) 
                data2 = data3
            end, data)
        elseif Framework == 'qbcore' then
            QBCore.Functions.TriggerCallback(name, function(data3)
                data2 = data3
            end, data)
        end
    
        while data2 == nil do
            Wait(0)
        end
    
        return data2
    end
end