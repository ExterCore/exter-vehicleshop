local StringCharset = {}
local NumberCharset = {}
RegisterNetEvent('exter-vehicleshop:buyVehicle:server', function(vtype, vehicle, price, dealershipId, sender, job, color)
    local src = source
    local player = GetPlayer(src)
    local sender = tonumber(sender)
    local target = GetPlayer(sender)
    local playerMoney = GetPlayerMoney(src, vtype)
    if playerMoney < price then
        return Notify(src, Lang:t("notifications.not_enough_money"), 7500, "error")
    end
    if Config.VehicleShops[dealershipId].Management.Enable and Config.EnableSocietyAccount then
        Config.AddManagementMoney(job, price)
    end
    if target then
        local targetMoney = price * Config.SalesShare / 100
        AddMoney(sender, "bank", targetMoney, "Vehicle sales share")
        Notify(sender, Lang:t("notifications.earned_money", {money = targetMoney, vehicle = vehicle}), 7500, "success")
    end
    local plate = GeneratePlate()
    local identifier = nil
    local identifier2 = nil
    if CoreName == "qb-core" or CoreName == "qbx_core" then
        identifier = player.PlayerData.license
        identifier2 = player.PlayerData.citizenid
        -- MySQL.insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, garage, state) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {
        --     player.PlayerData.license,
        --     player.PlayerData.citizenid,
        --     vehicle,
        --     GetHashKey(vehicle),
        --     '{}',
        --     plate,
        --     'pillboxgarage',
        --     0
        -- })
    else
        identifier = player.identifier
        -- MySQL.insert('INSERT INTO owned_vehicles (owner, plate, vehicle, logs, garage, mods, fuel, engine, body) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)', {
        --     player.identifier,
        --     plate,
        --     json.encode({model = joaat(vehicle), plate = plate}),
        --     '{}',
        --     'motelgarage',
        --     '{}',
        --     100,
        --     1000,
        --     1000
        -- })
    end
    RemoveMoney(src, vtype, price, "vehicle-bought-in-showroom")
    if color and next(color) and type(color) == "table" then
        TriggerClientEvent('exter-vehicleshop:buyVehicle:client', src, vehicle, plate, dealershipId, {r = color.r, g = color.g, b = color.b}, identifier, identifier2)
    else
        TriggerClientEvent('exter-vehicleshop:buyVehicle:client', src, vehicle, plate, dealershipId, "pascripts", identifier, identifier2)
    end
    if Config.VehicleShops[dealershipId].EnableStocks then
        local dealershipData = MySQL.query.await('SELECT * FROM exter_vehicleshop_stocks WHERE dealershipId = ?', {dealershipId})
        local anusVal = {}
        for k, v in pairs(dealershipData) do
            for a, b in pairs(v) do
                anusVal[a] = b
            end
        end
        local stocksData = json.decode(anusVal["data"])
        if stocksData and next(stocksData) and next(stocksData) ~= nil then
            for k, v in pairs(stocksData) do
                if v.model == vehicle then
                    v.stock = v.stock - 1
                end
            end
        end
        MySQL.update('UPDATE exter_vehicleshop_stocks SET data = ? WHERE dealershipId = ?', {json.encode(stocksData), dealershipId})
    end
end)

RegisterNetEvent('exter-vehicleshop:buyVehicleStep2:server', function(identifier, identifier2, plate, vehicle, vehicleProps)
    if CoreName == "qb-core" or CoreName == "qbx_core" then
        MySQL.insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, garage, state) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {
            identifier,
            identifier2,
            vehicle,
            GetHashKey(vehicle),
            json.encode(vehicleProps),
            plate,
            'pillboxgarage',
            0
        })
    else
        MySQL.insert('INSERT INTO owned_vehicles (owner, plate, vehicle, logs, garage, mods, fuel, engine, body) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)', {
            identifier,
            plate,
            json.encode({model = joaat(vehicle), plate = plate}),
            '{}',
            'motelgarage',
            json.encode(vehicleProps),
            100,
            1000,
            1000
        })
    end
end)

function Round(value, numDecimalPlaces)
    if not numDecimalPlaces then return math.floor(value + 0.5) end
    local power = 10 ^ numDecimalPlaces
    return math.floor((value * power) + 0.5) / (power)
end

CreateCallback('exter-vehicleshop:generatePlate:server', function(source, cb)
    local plate = GeneratePlate()
    cb(plate)
end)

function GeneratePlate()
    local plate = RandomInt(1) .. RandomStr(2) .. RandomInt(3) .. RandomStr(2)
    local result = MySQL.scalar.await('SELECT plate FROM ' .. Table .. ' WHERE plate = ?', {plate})
    if result then
        return GeneratePlate()
    else
        return plate:upper()
    end
end

for i = 48, 57 do NumberCharset[#NumberCharset + 1] = string.char(i) end
for i = 65, 90 do StringCharset[#StringCharset + 1] = string.char(i) end
for i = 97, 122 do StringCharset[#StringCharset + 1] = string.char(i) end

function RandomStr(length)
    if length <= 0 then return '' end
    return RandomStr(length - 1) .. StringCharset[math.random(1, #StringCharset)]
end

function RandomInt(length)
    if length <= 0 then return '' end
    return RandomInt(length - 1) .. NumberCharset[math.random(1, #NumberCharset)]
end

Citizen.CreateThread(function()
    while CoreReady == false do Citizen.Wait(0) end
    local table1 = MySQL.query.await("SHOW TABLES LIKE 'exter_vehicleshop_stocks'", {}, function(rowsChanged) end)
    if next(table1) then else
        MySQL.query.await([[CREATE TABLE IF NOT EXISTS `exter_vehicleshop_stocks` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `dealershipId` int(11) DEFAULT NULL,
            `data` longtext DEFAULT NULL,
            PRIMARY KEY (`id`)
            ) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;]], {}, function(rowsChanged)
        end)
    end
    local table2 = MySQL.query.await("SHOW TABLES LIKE 'exter_vehicleshop_showroom_vehicles'", {}, function(rowsChanged) end)
    if next(table2) then else
        MySQL.query.await([[CREATE TABLE IF NOT EXISTS `exter_vehicleshop_showroom_vehicles` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `dealershipId` int(11) DEFAULT NULL,
            `data` longtext NOT NULL,
            PRIMARY KEY (`id`)
            ) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;]], {}, function(rowsChanged)
        end)
    end
end)

-- Stocks
RegisterNetEvent('exter-vehicleshop:updateDealershipStockData:server', function(dealershipId, stocksData)
    local dealershipData = MySQL.query.await('SELECT * FROM exter_vehicleshop_stocks WHERE dealershipId = ?', {dealershipId})
    if dealershipData[1] then
        MySQL.update('UPDATE exter_vehicleshop_stocks SET data = ? WHERE dealershipId = ?', {json.encode(stocksData), dealershipId})
    else
        MySQL.insert('INSERT INTO exter_vehicleshop_stocks (dealershipId, data) VALUES (:dealershipId, :data)', {
            dealershipId = dealershipId,
            data = json.encode(stocksData)
        })
    end
    if Config.VehicleShops[dealershipId].Management.Enable and Config.EnableSocietyAccount then
        Config.RemoveMoneyManagement(Config.VehicleShops[dealershipId].Management.Job, Config.AddStockPrice)
    end
end)

CreateCallback('exter-vehicleshop:getVehStock:server', function(source, cb, dealershipId)
    local stocks = getVehStocks(dealershipId)
    cb(stocks)
end)

function getVehStocks(dealershipId)
    local p = promise:new()
    local dealershipData = MySQL.query.await('SELECT * FROM exter_vehicleshop_stocks WHERE dealershipId = ?', {dealershipId})
    local anusVal = {}
    for k, v in pairs(dealershipData) do
        for a, b in pairs(v) do
            anusVal[a] = b
        end
    end
    local stocksData = json.decode(anusVal["data"])
    if stocksData and next(stocksData) and next(stocksData) ~= nil then
        local stocks = {}
        for k, v in pairs(stocksData) do
            table.insert(stocks, {
                model = v.model,
                stock = v.stock
            })
        end
        p:resolve(stocks)
    else
        p:resolve(0)
    end
    return Citizen.Await(p)
end

local testVehicles = {}
RegisterNetEvent('exter-vehicleshop:startTest:server')
AddEventHandler('exter-vehicleshop:startTest:server', function(netId)
    testVehicles[netId] = {
        playerId = source
    }
end)

RegisterNetEvent('exter-vehicleshop:finishTest:server')
AddEventHandler('exter-vehicleshop:finishTest:server', function(netId)
    if testVehicles[netId] then
        testVehicles[netId] = nil
    end
end)

AddEventHandler('entityRemoved', function(entity)
    local netId = NetworkGetNetworkIdFromEntity(entity)
    if testVehicles[netId] then
        TriggerClientEvent('exter-vehicleshop:finishTest:client', testVehicles[netId].playerId)
        testVehicles[netId] = nil
    end
end)

RegisterNetEvent('exter-vehicleshop:updateShowroomVehicles:server', function(dealershipId, data)
    local src = source
    local showroomData = MySQL.query.await('SELECT * FROM exter_vehicleshop_showroom_vehicles WHERE dealershipId = ?', {dealershipId})
    if showroomData[1] then
        MySQL.update('UPDATE exter_vehicleshop_showroom_vehicles SET data = ? WHERE dealershipId = ?', {json.encode(data), dealershipId})
    else
        MySQL.insert('INSERT INTO exter_vehicleshop_showroom_vehicles (dealershipId, data) VALUES (?, ?)', {dealershipId, json.encode(data)})
    end
end)

CreateCallback('exter-vehicleshop:getShowroomData:server', function(source, cb, dealershipId)
    local showroomTable = {}
    local showroomDatas = MySQL.query.await('SELECT * FROM exter_vehicleshop_showroom_vehicles WHERE dealershipId = ?', {dealershipId})
    if showroomDatas[1] then
        if next(showroomDatas) and next(showroomDatas) ~= nil then
            for k, v in pairs(showroomDatas) do
                for a, b in pairs(json.decode(v.data)) do
                    table.insert(showroomTable, {
                        dealershipId = dealershipId,
                        coords = vector4(b.coords.x, b.coords.y, b.coords.z, b.coords.w),
                        vehicleModel = b.vehicleModel,
                        spotId = b.spotId
                    })
                end
            end
        end
    end
    cb(showroomTable)
end)

RegisterNetEvent('exter-vehicleshop:sendRequestText:server', function(sender, target, price, model, dealershipId, color)
    TriggerClientEvent('exter-vehicleshop:sendRequestText:client', target, sender, price, model, dealershipId, {r = color.r, g = color.g, b = color.b})
end)

RegisterNetEvent('exter-vehicleshop:declinePayment:server', function(sender)
    Notify(sender, Lang:t("notifications.request_declined"), 7500, "error")
end)

AddEventHandler('playerDropped', function()
    for k, v in pairs(testVehicles) do
        if v.playerId == source then
            TriggerClientEvent('exter-vehicleshop:deleteVehicle:client', -1, k)
        end
    end
end)

--RegisterNetEvent('exter-vehicleshop:deleteVehicleShowroom:server', function(dealershipId, spotId, newModel, props)
RegisterNetEvent('exter-vehicleshop:deleteVehicleShowroom:server', function(dealershipId, spotId, newModel)
    for _, playerId in ipairs(GetPlayers()) do
        local numPlayerId = tonumber(playerId)
        if numPlayerId ~= source then
            local myPed = GetPlayerPed(numPlayerId)
            local myPedCoords = GetEntityCoords(myPed)
            local dealershipCoords = vector3(Config.VehicleShops[dealershipId].ShowroomVehicles[1].coords.x, Config.VehicleShops[dealershipId].ShowroomVehicles[1].coords.y, Config.VehicleShops[dealershipId].ShowroomVehicles[1].coords.z)
            local dist = #(myPedCoords - dealershipCoords)
            if dist <= 40 then
                --TriggerClientEvent('exter-vehicleshop:deleteVehicleShowroom:client', numPlayerId, dealershipId, spotId, newModel, props)
                TriggerClientEvent('exter-vehicleshop:deleteVehicleShowroom:client', numPlayerId, dealershipId, spotId, newModel, true)
            else
                TriggerClientEvent('exter-vehicleshop:deleteVehicleShowroom:client', numPlayerId, dealershipId, spotId, newModel, false)
            end
        end
    end
end)

CreateCallback('exter-vehicleshop:checkIsPlayerHasPerm:server', function(source, cb)
    local src = source
    if CoreName == "qb-core" or CoreName == "qbx_core" then
        for k, v in pairs(Config.Permissions2) do
            if string.match(v, "citizenid:") then
                if HasPermissionCid(src, v:sub("11")) then
                    cb(true)
                    return
                end
            end
        end
    end
    if HasPermission(src) or HasPermission2(src) then
        cb(true)
        return
    end
end)