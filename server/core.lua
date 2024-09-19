Core = nil
CoreName = nil
CoreReady = false
Table = nil
Citizen.CreateThread(function()
    for k, v in pairs(Cores) do
        if GetResourceState(v.ResourceName) == "starting" or GetResourceState(v.ResourceName) == "started" then
            CoreName = v.ResourceName
            Core = v.GetFramework()
            CoreReady = true
            if CoreName == "qb-core" or CoreName == "qbx_core" then
                Table = "player_vehicles"
            elseif CoreName == "es_extended" then
                Table = "owned_vehicles"
            end
        end
    end
end)

function GetPlayer(source)
    if CoreName == "qb-core" or CoreName == "qbx_core" then
        local player = Core.Functions.GetPlayer(source)
        return player
    elseif CoreName == "es_extended" then
        local player = Core.GetPlayerFromId(source)
        return player
    end
end

function Notify(source, text, length, type)
    if CoreName == "qb-core" or CoreName == "qbx_core" then
        TriggerClientEvent('QBCore:Notify', source, text, type, length)
    elseif CoreName == "es_extended" then
        local player = Core.GetPlayerFromId(source)
        player.showNotification(text)
    end
end

function GetPlayerMoney(src, type)
    if CoreName == "qb-core" or CoreName == "qbx_core" then
        local player = Core.Functions.GetPlayer(src)
        return player.PlayerData.money[type]
    elseif CoreName == "es_extended" then
        local player = Core.GetPlayerFromId(src)
        local acType = "bank"
        if type == "cash" then
            acType = "money"
        end
        local account = player.getAccount(acType).money
        return account
    end
end

function AddMoney(src, type, amount, description)
    if CoreName == "qb-core" or CoreName == "qbx_core" then
        local player = Core.Functions.GetPlayer(src)
        player.Functions.AddMoney(type, amount, description)
    elseif CoreName == "es_extended" then
        local player = Core.GetPlayerFromId(src)
        if type == "bank" then
            player.addAccountMoney("bank", amount, description)
        elseif type == "cash" then
            player.addMoney(amount, description)
        end
    end
end

function RemoveMoney(src, type, amount, description)
    if CoreName == "qb-core" or CoreName == "qbx_core" then
        local player = Core.Functions.GetPlayer(src)
        player.Functions.RemoveMoney(type, amount, description)
    elseif CoreName == "es_extended" then
        local player = Core.GetPlayerFromId(src)
        if type == "bank" then
            player.removeAccountMoney("bank", amount, description)
        elseif type == "cash" then
            player.removeMoney(amount, description)
        end
    end
end

function HasPermission(src)
    if CoreName == "qb-core" or CoreName == "qbx_core" then
        for _, perm in pairs(Config.Permissions) do
            if Core.Functions.HasPermission(src, perm) then
                return true
            end
        end
        return false
    elseif CoreName == "es_extended" then
        local playerGroup = Core.GetPlayerFromId(src).getGroup()
        for _, perm in pairs(Config.Permissions) do
            if perm == playerGroup then
                return true
            end
        end
        return false
    end
end

function HasPermission2(src)
    for k, v in ipairs(GetPlayerIdentifiers(src)) do
        for a, b in pairs(Config.Permissions2) do
            if string.match(v, b) then
                return true
            end
        end
    end
end

function HasPermissionCid(src, cid)
    local player = Core.Functions.GetPlayer(src)
    if player.PlayerData.citizenid == cid then
        return true
    end
end

Config.ServerCallbacks = {}
function CreateCallback(name, cb)
    Config.ServerCallbacks[name] = cb
end

function TriggerCallback(name, source, cb, ...)
    if not Config.ServerCallbacks[name] then return end
    Config.ServerCallbacks[name](source, cb, ...)
end

RegisterNetEvent('exter-vehicleshop:server:triggerCallback', function(name, ...)
    local src = source
    TriggerCallback(name, src, function(...)
        TriggerClientEvent('exter-vehicleshop:client:triggerCallback', src, name, ...)
    end, ...)
end)