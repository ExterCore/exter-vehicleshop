local taskActive = false
local currentMenuVehs = {}
local isAdmin = false
Citizen.CreateThread(function()
    -- Functions
    for k, v in pairs(Config.VehicleShops) do
		if v.Ped.Enable then
            local pedHash2 = type(v.Ped.Model) == "number" and v.Ped.Model or joaat(v.Ped.Model)
			RequestModel(pedHash2)
			while not HasModelLoaded(pedHash2) do Citizen.Wait(0) end
			v.Ped.ped = CreatePed(0, pedHash2, v.Ped.Coords.x, v.Ped.Coords.y, v.Ped.Coords.z - 1, v.Ped.Coords.w, false, true)
			FreezeEntityPosition(v.Ped.ped, true)
            SetEntityInvincible(v.Ped.ped, true)
            SetBlockingOfNonTemporaryEvents(v.Ped.ped, true)
			PlaceObjectOnGroundProperly(v.Ped.ped)
			SetEntityAsMissionEntity(v.Ped.ped, false, false)
        	SetPedCanPlayAmbientAnims(v.Ped.ped, false) 
            SetModelAsNoLongerNeeded(pedHash2)
            RequestAnimDict(v.Ped.animDict)
            while not HasAnimDictLoaded(v.Ped.animDict) do Citizen.Wait(0) end
			TaskPlayAnim(v.Ped.ped, v.Ped.animDict, v.Ped.animName, 5.0, 5.0, -1, 1, 0, false, false, false)
            if v.Interaction.Target.Enable then
				if GetResourceState('qb-target') == 'started' then
                    local targetData = {}
                    table.insert(targetData, {
                        label = v.Interaction.Target.Label,
                        icon = v.Interaction.Target.Icon,
                        action = function()
                            openDealership(true, k)
                        end
                    })
                    if v.Management.Enable then
                        table.insert(targetData, {
                            label = v.Interaction.Target.Label2,
                            icon = v.Interaction.Target.Icon2,
                            job = v.Management.Job,
                            action = function()
                                openShowroomMenu(k, true, v.ShowroomVehicles, v.Management.Job)
                            end
                        })
                    end
					exports['qb-target']:AddTargetEntity(v.Ped.ped, {
						options = targetData,
						distance = v.Interaction.Target.Distance
					})
				end
            end
        end
        if v.Blip.Enable then
			local blip = AddBlipForCoord(v.Blip.coords.x, v.Blip.coords.y, v.Blip.coords.z)
			SetBlipSprite(blip, v.Blip.sprite)
			SetBlipScale(blip, v.Blip.scale)
			SetBlipDisplay(blip, 4)
			SetBlipColour(blip, v.Blip.color)
			SetBlipAsShortRange(blip, true)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentSubstringPlayerName(v.Blip.text)
			EndTextCommandSetBlipName(blip)
		end
        v.created = false
        for a, b in pairs(v.ShowroomVehicles) do
            b.spotId = a
        end
        if v.Management.Enable then
            exports['exter-textui']:create3DTextUI("exter-vehicleshop-vehshop-" .. k, {
                coords = v.Coords.SellingPoint,
                displayDist = 5.0,
                interactDist = 2.0,
                enableKeyClick = true,
                keyNum = 38,
                key = "E",
                text = Lang:t("general.selling_point"),
                theme = "green", -- or red
                job = v.Management.Job,
                canInteract = function()
                    return not taskActive
                end,
                triggerData = {
                    triggerName = "exter-vehicleshop:openSellingMenu:client",
                    args = {vehshopId = k, open = true, sell = true}
                }
            })
        else
            if v.EnableStocks then
                exports['exter-textui']:create3DTextUI("exter-vehicleshop-vehshop-" .. k, {
                    coords = v.Coords.SellingPoint,
                    displayDist = 5.0,
                    interactDist = 2.0,
                    enableKeyClick = true,
                    keyNum = 38,
                    key = "E",
                    text = Lang:t("general.selling_point"),
                    theme = "green", -- or red
                    job = "all",
                    canInteract = function()
                        return isAdmin
                    end,
                    triggerData = {
                        triggerName = "exter-vehicleshop:openSellingMenu:client",
                        args = {vehshopId = k, open = true, sell = false}
                    }
                })
            end
        end
    end
end)

Citizen.CreateThread(function()
    while not CoreReady do Citizen.Wait(0) end
    if CoreName == "es_extended" then
        RegisterNetEvent('esx:playerLoaded', function(player, xPlayer, isNew)
            TriggerCallback('exter-vehicleshop:checkIsPlayerHasPerm:server', function(hasPerm)
                if hasPerm then
                    isAdmin = true
                end
            end)
        end)
    else
        while not next(GetPlayerData()) do Citizen.Wait(0) end
        TriggerCallback('exter-vehicleshop:checkIsPlayerHasPerm:server', function(hasPerm)
            if hasPerm then
                isAdmin = true
            end
        end)
    end
end)

RegisterNetEvent('exter-vehicleshop:openDealership:client', function(id)
    openDealership(true, id)
end)

local sellMenuActive = false
RegisterNetEvent('exter-vehicleshop:openSellingMenu:client', function(data)
    sellMenuActive = data.open
    if sellMenuActive then
        local showAddStockBtn = false
        TriggerCallback('exter-vehicleshop:checkIsPlayerHasPerm:server', function(hasPerm)
            if hasPerm then
                showAddStockBtn = true
            end
        end)
        if Config.VehicleShops[data.vehshopId].EnableStocks then
            currentMenuVehs = Vehicles
            TriggerCallback('exter-vehicleshop:getVehStock:server', function(stockData)
                if stockData ~= 0 then
                    for k, v in pairs(stockData) do
                        for a, b in pairs(currentMenuVehs) do
                            if b.model == v.model then
                                b.stock = v.stock
                                b.name = Vehicles2[v.model].name
                            end
                        end
                    end
                end
            end, data.vehshopId)
            Citizen.Wait(1000)
            SendNUIMessage({action = "openSellMenu", sellBtnActive = data.sell, dealershipId = data.vehshopId, vehicles = currentMenuVehs, vehicles2 = currentMenuVehs, showAddStockBtn = showAddStockBtn})
        else
            currentMenuVehs = Vehicles
            for k, v in pairs(currentMenuVehs) do
                v.stock = 1
            end
            Citizen.Wait(1000)
            SendNUIMessage({action = "openSellMenu", sellBtnActive = true, dealershipId = data.vehshopId, vehicles = Vehicles})
        end
        SetNuiFocus(true, true)
    else
        SetNuiFocus(false, false)
    end
end)

closestVehShop = {}
Citizen.CreateThread(function()
	while true do
		local sleep = 2000
		playerPed = PlayerPedId()
		playerCoords = GetEntityCoords(playerPed)
		if not closestVehShop.id then
			for k, v in pairs(Config.VehicleShops) do
				local dist = #(playerCoords - vector3(v.ShowroomVehicles[1].coords.x, v.ShowroomVehicles[1].coords.y, v.ShowroomVehicles[1].coords.z))
                if dist <= 40 then
                    closestVehShop = {id = k, created = v.created, distance = dist, maxDist = v.ShowroomVehiclesLoadDistance, data = {coords = vector3(v.ShowroomVehicles[1].coords.x, v.ShowroomVehicles[1].coords.y, v.ShowroomVehicles[1].coords.z)}}
                    if v.ClearAreaOfNPCVehicles then
                        ClearAreaOfVehicles(v.Coords.ShowroomVehicles.x, v.Coords.ShowroomVehicles.y, v.Coords.ShowroomVehicles.z, 30.0, false, false, false, false, false)
                    end
                end
			end
		end
		if closestVehShop.id and not closestVehShop.created then
			while not closestVehShop.created do
				playerCoords = GetEntityCoords(playerPed)
				closestVehShop.distance = #(closestVehShop.data.coords - playerCoords)
				if closestVehShop.distance < closestVehShop.maxDist then
                    Config.VehicleShops[closestVehShop.id].created = true
                    --closestVehShop.created = true
                    TriggerCallback('exter-vehicleshop:getShowroomData:server', function(showroomData)
                        for k, v in pairs(showroomData) do
                            if v.vehicleModel then
                                local model = GetHashKey(v.vehicleModel)
                                RequestModel(model)
                                while not HasModelLoaded(model) do Citizen.Wait(0) end
                                Config.VehicleShops[v.dealershipId].ShowroomVehicles[v.spotId].vehicleModel = v.vehicleModel
                                Config.VehicleShops[v.dealershipId].ShowroomVehicles[v.spotId].vehicle = CreateVehicle(model, v.coords.x, v.coords.y, v.coords.z, false, false)
                                local vehicle = Config.VehicleShops[v.dealershipId].ShowroomVehicles[v.spotId].vehicle
                                SetEntityLodDist(vehicle, closestVehShop.maxDist)
                                SetModelAsNoLongerNeeded(model)
                                SetVehicleOnGroundProperly(vehicle)
                                SetEntityInvincible(vehicle, true)
                                SetVehicleDirtLevel(vehicle, 0.0)
                                SetVehicleDoorsLocked(vehicle, 3)
                                SetEntityHeading(vehicle, v.coords.w)
                                FreezeEntityPosition(vehicle, true)
                                SetVehicleNumberPlateText(vehicle, 'BUY ME')
                                exports['exter-textui']:create3DTextUI("exter-vehicleshop-showroom-vehicle-" .. model .. "-spotId-" .. v.spotId, {
                                    coords = vector3(v.coords.x, v.coords.y, v.coords.z),
                                    displayDist = 5.0,
                                    interactDist = 1.5,
                                    enableKeyClick = true,
                                    keyNum = 38,
                                    key = "E",
                                    text = Lang:t("general.ask_an_employee"),
                                    theme = "green", 
                                    triggerData = {
                                        triggerName = "exter-vehicleshop:askAnEmployee:client",
                                        args = {}
                                    }
                                })
                            end
                        end
                    end, closestVehShop.id)
                    break
				else
					break
				end
				Citizen.Wait(0)
			end
			closestVehShop = {}
			sleep = 0
		end
		Citizen.Wait(sleep)
	end
end)

RegisterNetEvent('exter-vehicleshop:askAnEmployee:client', function()
    Notify(Lang:t("notifications.ask_an_employee"), 7500, "error")
end)

local lastCoords = nil
local currentCar = nil
local menuActive = false
local showroomMenuActive = false
local currentCoords = {}
local nuiState = nil
function openDealership(state, id)
    menuActive = state
    nuiState = state
    Config.HUD(not menuActive)
    if menuActive then
        lastCoords = GetEntityCoords(PlayerPedId())
        -- Functions
        currentCoords.boughtVehCoords = Config.VehicleShops[id].Coords.BoughtVehicles
        currentCoords.testVehCoords = Config.VehicleShops[id].Coords.TestVehicles
        currentCoords.showroomVehCoords = Config.VehicleShops[id].Coords.ShowroomVehicles
        DisplayRadar(0)
        SetNuiFocus(true, true)
        local allowedCategories = Config.VehicleShops[id].AllowedCategories
        local categoriesData = {}
        for k, v in pairs(Categories) do
            for a, b in pairs(allowedCategories) do
                if k == a then
                    table.insert(categoriesData, {
                        name = k,
                        label = Lang:t("categories." .. k)
                    })
                end
            end
        end
        table.sort(categoriesData, function(a, b) return a.label < b.label end)
        SetEntityVisible(PlayerPedId(), false, 0)
        SetUserRadioControlEnabled(false)
        local vehiclesT = setupVehicles(id)
        SendNUIMessage({action = "openDealership", currency = Config.PriceCurrency, customImg = Config.UseCustomImages, dealershipId = id, managementState = Config.VehicleShops[id].Management.Enable, vehicles = vehiclesT, categories = categoriesData, testDriveTime = Config.TestDriveTime})
    else
        SetEntityVisible(PlayerPedId(), true, 0)
        ClearFocus()
        RenderScriptCams(false, true, 1000, true, false)
        DestroyCam(cam, false)
        DeleteVehiclesInsideShop()
        SetNuiFocus(false, false)
        SendNUIMessage({action = "closeUI"})
        SetUserRadioControlEnabled(true)
        if lastCoords then
            SetEntityCoords(PlayerPedId(), lastCoords)
            lastCoords = nil
        end
    end 
end

function setupVehicles(vehshopId)
    local p = promise:new()
    local data = Vehicles
    if Config.VehicleShops[vehshopId].EnableStocks == false then
        for k, v in pairs(data) do
            if Config.VehicleShops[vehshopId].Name == "all" then
                v.stock = 1
            else
                if v.shop == Config.VehicleShops[vehshopId].Name then
                    v.stock = 1
                else
                    v.stock = "dontshow"
                end
            end
        end
        p:resolve(data)
    else
        TriggerCallback('exter-vehicleshop:getVehStock:server', function(stockData)
            if stockData == 0 then
                for a, b in pairs(data) do
                    if Config.VehicleShops[vehshopId].Name == "all" then
                        b.stock = 0
                    else
                        if b.shop == Config.VehicleShops[vehshopId].Name then
                            b.stock = 0
                        else
                            b.stock = "dontshow"
                        end
                    end
                end
                p:resolve(data)
            else
                for k, v in pairs(stockData) do
                    for a, b in pairs(data) do
                        if Config.VehicleShops[vehshopId].Name == "all" then
                            if b.model == v.model then
                                b.stock = v.stock
                            end
                        else
                            if b.shop == Config.VehicleShops[vehshopId].Name then
                                if b.model == v.model then
                                    b.stock = v.stock
                                end
                            else
                                b.stock = "dontshow"
                            end
                        end
                    end
                end
                p:resolve(data)
            end
        end, vehshopId)
    end
    return Citizen.Await(p)
end

Citizen.CreateThread(function()
	while true do
		local sleep = 1000
		local playerCoords = GetEntityCoords(PlayerPedId())
        for k, v in pairs(Config.VehicleShops) do
			if not menuActive and not showroomMenuActive then
				local dist = #(playerCoords - vector3(v.Ped.Coords.x, v.Ped.Coords.y, v.Ped.Coords.z))
				if v.Interaction.Text.Enable then
					if dist <= v.Interaction.Text.Distance then
						sleep = 0
						ShowFloatingHelpNotification(v.Interaction.Text.Label, v.Ped.Coords)
						if IsControlJustReleased(0, 38) then
                            openDealership(true, k)
						end
                        if v.Management.Enable then
                            if IsControlJustReleased(0, 58) then
                                openShowroomMenu(k, true, v.ShowroomVehicles, v.Management.Job)
                            end
                        end
					end
				end
			end
		end
		Citizen.Wait(sleep)
	end
end)

function ShowFloatingHelpNotification(msg, coords)
    AddTextEntry('paVehicleShopFloatingHelpNotification', msg)
    SetFloatingHelpTextWorldPosition(1, coords)
    SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)
    BeginTextCommandDisplayHelp('paVehicleShopFloatingHelpNotification')
    EndTextCommandDisplayHelp(2, false, false, -1)
end

RegisterNetEvent('exter-dealership:close:client', function()
    openDealership(false)
end)

local lastVehicles = {}
local testDriveState = false
RegisterNUICallback('callback', function(data)
    if data.action == "chooseVeh" then
        -- Car
        DeleteVehiclesInsideShop()
        RequestModel(GetHashKey(data.veh))
        while not HasModelLoaded(GetHashKey(data.veh)) do
            Citizen.Wait(0)
        end
        currentCar = CreateVehicle(GetHashKey(data.veh), currentCoords.showroomVehCoords, false, false)
        local brake = GetVehicleMaxBraking(currentCar)
        local speed = GetVehicleHandlingFloat(currentCar, "CHandlingData", "fInitialDriveMaxFlatVel")
        local acceleration = GetVehicleHandlingInt(currentCar, "CHandlingData", "fSteeringLock")
        local weight = GetVehicleHandlingInt(currentCar, "CHandlingData", "fMass")
        SendNUIMessage({action = "updateCarInformations", acceleration = acceleration, speed = speed, handling = weight, brake = brake})
        TaskWarpPedIntoVehicle(PlayerPedId(), currentCar, -1)
        SetFocusEntity(currentCar)
        SetVehicleDirtLevel(currentCar, 0.0)
        SetVehicleNumberPlateText(currentCar, "SHOWROOM")
        table.insert(lastVehicles, currentCar)
        -- Camera
        local coords = GetOffsetFromEntityInWorldCoords(currentCar, 0, 4.5, 0)
        DestroyCam(cam, false)
        if not DoesCamExist(cam) then
            cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
            SetCamActive(cam, true)
            RenderScriptCams(true, true, 1000, true, true)
            SetCamCoord(cam, coords.x, coords.y, coords.z + 0.6)
            SetCamRot(cam, 0.0, 0.0, GetEntityHeading(currentCar) + 180)
            SetCamUseShallowDofMode(cam, true)
            SetCamNearDof(cam, 0.7)
            SetCamFarDof(cam, 3.3)
            SetCamDofStrength(cam, 0.9)
            Citizen.CreateThread(function()
                while DoesCamExist(cam) do
                    SetUseHiDof()
                    Citizen.Wait(0)  
                end
            end)
        end
        headingToCam = GetEntityHeading(currentCar) + 90
        camOffset = 4.5
    elseif data.action == "close" then
        if data.type == "showroom" then
            openDealership(false)
        elseif data.type == "showroomEdit" then
            openShowroomMenu(false)
            TriggerServerEvent('exter-vehicleshop:updateShowroomVehicles:server', data.dealershipId, Config.VehicleShops[data.dealershipId].ShowroomVehicles)
        elseif data.type == "sellMenu" then
            TriggerEvent('exter-vehicleshop:openSellingMenu:client', {open = false})
        else
            SetNuiFocus(false, false)
        end
        if data.test == true and not testDriveState then
            if IsSpawnPointClear(vector3(currentCoords.testVehCoords.x, currentCoords.testVehCoords.y, currentCoords.testVehCoords.z), 2.5) then
                local plate = "TEST" .. math.random(1000, 9999)
                local ped = PlayerPedId()
                playerLastCoords = GetEntityCoords(ped)
                local model = type(data.model) == 'string' and GetHashKey(data.model) or data.model
                if not IsModelInCdimage(model) then return end
                if coords then
                    coords = type(coords) == 'table' and vec3(currentCoords.testVehCoords.x, currentCoords.testVehCoords.y, currentCoords.testVehCoords.z) or coords
                else
                    coords = GetEntityCoords(ped)
                end
                RequestModel(model)
                while not HasModelLoaded(model) do
                    Wait(0)
                end
                currentTestVehicle = CreateVehicle(model, currentCoords.testVehCoords.x, currentCoords.testVehCoords.y, currentCoords.testVehCoords.z, currentCoords.testVehCoords.w, true, false)
                currentTestVehicleNetId = NetworkGetNetworkIdFromEntity(currentTestVehicle)
                SetVehicleHasBeenOwnedByPlayer(currentTestVehicle, true)
                SetNetworkIdExistsOnAllMachines(currentTestVehicleNetId, true)
                SetNetworkIdCanMigrate(currentTestVehicleNetId, true)
                SetVehicleNeedsToBeHotwired(currentTestVehicle, false)
                SetVehRadioStation(currentTestVehicle, 'OFF')
                SetModelAsNoLongerNeeded(model)
                SetVehicleNumberPlateText(currentTestVehicle, plate)
                GiveKey(currentTestVehicle)
                SetFuel(currentTestVehicle, 100.0)
                testDriveState = true
                SendNUIMessage({action = "startTestTimer", testDriveTime = Config.TestDriveTime})
                TriggerServerEvent('exter-vehicleshop:startTest:server', currentTestVehicleNetId)
                if Config.WarpPedToTestVehicle then
                    TaskWarpPedIntoVehicle(PlayerPedId(), currentTestVehicle, -1)
                end
            else
                Notify(Lang:t("notifications.spawn_point_not_clear"), 7500, "error")
            end
        elseif DoesEntityExist(currentTestVehicle) then
            Notify(Lang:t("notifications.already_have_test_drive_in_progress"), 7500, "error")
        end
    elseif data.action == "changeVehColor" then
        SetVehicleCustomPrimaryColour(currentCar, data.r, data.g, data.b)
        SetVehicleCustomSecondaryColour(currentCar, data.r, data.g, data.b)
    elseif data.action == "finishTest" then
        testDriveState = false
        if Config.TeleportBackWhenTestFinishes then
            Notify(Lang:t("notifications.test_period_is_over"), 7500, "info")
            DoScreenFadeOut(1000)
            Citizen.Wait(1000)
            SetEntityCoords(PlayerPedId(), playerLastCoords)
            DeleteVehicle(currentTestVehicle)
            Citizen.Wait(1000)
            DoScreenFadeIn(1000)
        else
            Notify(Lang:t("notifications.test_period_is_over"), 7500, "info")
            SetVehicleUndriveable(currentTestVehicle, true)
        end
    elseif data.action == "camLeft" then
        local pedPos = GetEntityCoords(currentCar)
        local camPos = GetCamCoord(cam)
        if not tonumber(headingToCam) then
            headingToCam = GetEntityHeading(currentCar) + 90
        end
        local heading = headingToCam
        heading = heading - 2.5
        headingToCam = heading
        local cx, cy = GetPositionByRelativeHeading(currentCar, heading, camOffset)
        SetCamCoord(cam, cx, cy, camPos.z)
        PointCamAtCoord(cam, pedPos.x, pedPos.y, camPos.z)
    elseif data.action == "camRight" then
        local pedPos = GetEntityCoords(currentCar)
        local camPos = GetCamCoord(cam)
        if not tonumber(headingToCam) then
            headingToCam = GetEntityHeading(currentCar) + 90
        end
        local heading = headingToCam
        heading = heading + 2.5
        headingToCam = heading
        local cx, cy = GetPositionByRelativeHeading(currentCar, heading, camOffset)
        SetCamCoord(cam, cx, cy, camPos.z)
        PointCamAtCoord(cam, pedPos.x, pedPos.y, camPos.z)
    elseif data.action == "zoomOut" then
        local pedPos = GetEntityCoords(currentCar)
        if camOffset < 5.6 then
            if not tonumber(headingToCam) then
                headingToCam = GetEntityHeading(currentCar) + 90
            end
            camOffset = camOffset + 0.50
            local cx, cy = GetPositionByRelativeHeading(currentCar, headingToCam, camOffset)
            SetCamCoord(cam, cx, cy, pedPos.z + 0.65)
            PointCamAtCoord(cam, pedPos.x, pedPos.y, pedPos.z + 0.65)
        end
    elseif data.action == "zoomIn" then
        local pedPos = GetEntityCoords(currentCar)
        if camOffset > 3.4 then
            if not tonumber(headingToCam) then
                headingToCam = GetEntityHeading(currentCar) + 90
            end
            camOffset = camOffset - 0.50
            local cx, cy = GetPositionByRelativeHeading(currentCar, headingToCam, camOffset)
            SetCamCoord(cam, cx, cy, pedPos.z + 0.65)
            PointCamAtCoord(cam, pedPos.x, pedPos.y, pedPos.z + 0.65)
        end
    elseif data.action == "camDown" then
        if not tonumber(headingToCam) then
            headingToCam = GetEntityHeading(currentCar) + 90
        end
        local pedPos = GetEntityCoords(currentCar)
        local camPos = GetCamCoord(cam)
        local cx, cy = GetPositionByRelativeHeading(currentCar, headingToCam, camOffset)
        SetCamCoord(cam, cx, cy, camPos.z)
        SetCamRot(cam, 0.0, 0.0, 0.0, 0)
    elseif data.action == "camUp" then
        camPitch = camPitch - 0.5
        SetGameplayCamRelativePitch(camPitch, 1.0)
    elseif data.action == "nuiFocusEvent" then
        camHeading = GetGameplayCamRelativeHeading()
        if nuiState then
            SetNuiFocus(true, false)
            nuiState = false
            RenderScriptCams(false, true, 1000, true, false)
        else
            nuiState = true
            SetNuiFocus(true, true)
            RenderScriptCams(true, true, 1000, true, true)
        end
    elseif data.action == "updateShowroomVehicle" then
        if DoesEntityExist(Config.VehicleShops[data.dealershipId].ShowroomVehicles[data.spotId].vehicle) then
            DeleteVehicle(Config.VehicleShops[data.dealershipId].ShowroomVehicles[data.spotId].vehicle)
        end
        local model = GetHashKey(data.model)
        RequestModel(model)
        while not HasModelLoaded(model) do Citizen.Wait(0) end
        Config.VehicleShops[data.dealershipId].ShowroomVehicles[data.spotId].vehicleModel = data.model
        local spot = Config.VehicleShops[data.dealershipId].ShowroomVehicles[data.spotId]
        Config.VehicleShops[data.dealershipId].ShowroomVehicles[data.spotId].vehicle = CreateVehicle(model, spot.coords.x, spot.coords.y, spot.coords.z, false, false)
        local vehicle = Config.VehicleShops[data.dealershipId].ShowroomVehicles[data.spotId].vehicle
        SetModelAsNoLongerNeeded(model)
        SetVehicleOnGroundProperly(vehicle)
        SetEntityInvincible(vehicle, true)
        SetVehicleDirtLevel(vehicle, 0.0)
        SetVehicleDoorsLocked(vehicle, 3)
        SetEntityHeading(vehicle, spot.coords.w)
        FreezeEntityPosition(vehicle, true)
        SetVehicleNumberPlateText(vehicle, 'BUY ME')
        PlaceObjectOnGroundProperly(vehicle)
        SetVehicleColourCombination(vehicle, 0)
        while not DoesEntityExist(vehicle) do Citizen.Wait(0) end
        --local props = GetVehicleProperties(vehicle)
        --TriggerServerEvent('exter-vehicleshop:deleteVehicleShowroom:server', data.dealershipId, data.spotId, data.model, props)
        TriggerServerEvent('exter-vehicleshop:deleteVehicleShowroom:server', data.dealershipId, data.spotId, data.model)
    elseif data.action == "createSpotCam" then
        DeleteVehiclesInsideShop()
        local coords = GetOffsetFromEntityInWorldCoords(Config.VehicleShops[tonumber(data.dealershipId)].ShowroomVehicles[tonumber(data.spotId)].vehicle, 1.0, 5.5, 0.5)
        if DoesEntityExist(Config.VehicleShops[tonumber(data.dealershipId)].ShowroomVehicles[tonumber(data.spotId)].vehicle) then
            DestroyCam(cam, false)
            if not DoesCamExist(cam) then
                cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
                SetCamActive(cam, true)
                RenderScriptCams(true, true, 1000, true, true)
                SetCamCoord(cam, coords.x, coords.y, coords.z + 0.6)
                SetCamRot(cam, 0.0, 0.0, GetEntityHeading(currentCar) + 180)
            end
        else
            local coords = Config.VehicleShops[tonumber(data.dealershipId)].ShowroomVehicles[tonumber(data.spotId)].coords
            local model = GetHashKey("dubsta2")
            RequestModel("dubsta2")
            while not HasModelLoaded("dubsta2") do Citizen.Wait(0) end
            local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, false, false)
            table.insert(lastVehicles, vehicle)
            SetEntityVisible(vehicle, false, 0)
            SetModelAsNoLongerNeeded(model)
            SetVehicleOnGroundProperly(vehicle)
            DestroyCam(cam, false)
            local camCoords = GetOffsetFromEntityInWorldCoords(vehicle, 1.0, 5.5, 0.5)
            if not DoesCamExist(cam) then
                cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
                SetCamActive(cam, true)
                RenderScriptCams(true, true, 1000, true, true)
                SetCamCoord(cam, camCoords.x, camCoords.y, camCoords.z + 0.6)
                SetCamRot(cam, 0.0, 0.0, GetEntityHeading(vehicle) + 180)
            end
        end
    elseif data.action == "createTextsOnPlayers" then
        SetNuiFocus(false, false)
        sellMenuActive = false
        if data.currentSellType == "myself" then
            TriggerServerEvent('exter-vehicleshop:buyVehicle:server', "bank", data.model, tonumber(data.price), data.dealershipId, data.sender, Config.VehicleShops[data.dealershipId].Management.Job, {r = data.color.r, g = data.color.g, b = data.color.b})
            return
        end
        nearbyPlayers = GetPlayersInArea(GetEntityCoords(PlayerPedId()), 5.0)
        if next(nearbyPlayers) ~= nil and next(nearbyPlayers) then
            taskActive = true
            for _, id in pairs(nearbyPlayers) do
                exports['exter-textui']:create3DTextUIOnPlayers("exter-vehicleshop-vehshop-players-" .. id, {
                    id = id,
                    displayDist = 5.0,
                    interactDist = 1.3,
                    enableKeyClick = true, -- If true when you near it and click key it will trigger the event that you write inside triggerData
                    keyNum = 38,
                    key = "E",
                    text = Lang:t("general.send_request"),
                    theme = "green", -- or red
                    triggerData = {
                        triggerName = "exter-vehicleshop:sendSellRequest:client",
                        args = {sender = GetPlayerServerId(PlayerId()), target = id, model = data.model, price = data.price, dealershipId = data.dealershipId, color = {r = data.color.r, g = data.color.g, b = data.color.b}}
                    }
                })
            end
            Citizen.Wait(7500)
            taskActive = false
            Notify(Lang:t("notifications.request_timed_out"), 7500, "error")
            if next(nearbyPlayers) ~= nil and next(nearbyPlayers) then
                for _, id in pairs(nearbyPlayers) do
                    exports['exter-textui']:delete3DTextUIOnPlayers("exter-vehicleshop-vehshop-players-" .. id)
                end
            end
        else
            Notify(Lang:t("notifications.no_players_nearby"), 7500, "error")
        end
    elseif data.action == "confirmPurchase" then
        TriggerServerEvent('exter-vehicleshop:buyVehicle:server', data.paymentType, data.model, Vehicles2[data.model].price, data.dealershipId, data.sender, Config.VehicleShops[data.dealershipId].Management.Job)
    elseif data.action == "addStockForAllVehicles" then
        SetNuiFocus(false, false)
        taskActive = true
        local stocks = {}
        for k, v in pairs(currentMenuVehs) do
            if tonumber(v.stock) then
                v.stock = tonumber(v.stock) + tonumber(data.addStockNum)
            else
                v.stock = tonumber(data.addStockNum)
            end
            table.insert(stocks, {model = v.model, stock = tonumber(v.stock)})
        end
        Citizen.Wait(3000)
        Notify(Lang:t("notifications.added_stock_num_to_all_vehicles", {addStockNum = data.addStockNum}), 7500, "success")
        TriggerServerEvent('exter-vehicleshop:updateDealershipStockData:server', data.dealershipId, stocks)
        taskActive = false
    elseif data.action == "addStockForSpecificVehicle" then
        SetNuiFocus(false, false)
        taskActive = true
        local stocks = {}
        for k, v in pairs(currentMenuVehs) do
            if v.model == data.model then
                if v.stock then
                    v.stock = v.stock + tonumber(data.addStockNum)
                else
                    v.stock = tonumber(data.addStockNum)
                end
                table.insert(stocks, {model = data.model, stock = v.stock})
            else
                table.insert(stocks, {model = v.model, stock = v.stock})
            end
        end
        Citizen.Wait(3000)
        Notify(Lang:t("notifications.added_stock_num_to_model", {addStockNum = data.addStockNum, model = data.model}), 7500, "success")
        TriggerServerEvent('exter-vehicleshop:updateDealershipStockData:server', data.dealershipId, stocks)
        taskActive = false
    end
end)

RegisterNetEvent('exter-vehicleshop:sendSellRequest:client', function(data)
    -- Delete All
    if next(nearbyPlayers) ~= nil and next(nearbyPlayers) then
        for _, id in pairs(nearbyPlayers) do
            exports['exter-textui']:delete3DTextUIOnPlayers("exter-vehicleshop-vehshop-players-" .. id)
        end
    end
    -- Add To Sender
    TriggerServerEvent('exter-vehicleshop:sendRequestText:server', data.sender, data.target, data.price, data.model, data.dealershipId, {r = data.color.r, g = data.color.g, b = data.color.b})
    Citizen.Wait(500)
    taskActive = false
end)

currentSender = nil
RegisterNetEvent('exter-vehicleshop:sendRequestText:client', function(sender, price, model, dealershipId, color)
    currentSender = sender
    exports['exter-textui']:create3DTextUIOnPlayers("exter-vehicleshop-vehshop-players-confirm-purchase-" .. sender, {
        id = sender,
        displayDist = 5.0,
        interactDist = 1.3,
        enableKeyClick = true,
        keyNum = 38,
        keyNum2 = 246,
        key = "E/Y",
        text = "Accept Bank - ($" .. price .. ") / Decline",
        theme = "green",
        triggerData = {
            triggerName = "exter-vehicleshop:acceptPayment:client",
            args = {price = price, model = model, sender = sender, me = GetPlayerServerId(PlayerId()), dealershipId = dealershipId, color = {r = color.r, g = color.g, b = color.b}}
        },
        triggerData2 = {
            triggerName = "exter-vehicleshop:declinePayment:client",
            args = {sender = sender, me = GetPlayerServerId(PlayerId())}
        }
    })
    Citizen.Wait(7500)
    taskActive = false
    Notify(Lang:t("notifications.request_timed_out"), 7500, "error")
    exports['exter-textui']:delete3DTextUIOnPlayers("exter-vehicleshop-vehshop-players-confirm-purchase-" .. sender)
    currentSender = nil
end)

RegisterNetEvent('exter-vehicleshop:acceptPayment:client', function(data)
    Notify(Lang:t("notifications.request_accepted"), 7500, "success")
    exports['exter-textui']:delete3DTextUIOnPlayers("exter-vehicleshop-vehshop-players-confirm-purchase-" .. data.sender)
    currentSender = nil
    TriggerServerEvent('exter-vehicleshop:buyVehicle:server', "bank", data.model, tonumber(data.price), data.dealershipId, data.sender, Config.VehicleShops[data.dealershipId].Management.Job, {r = data.color.r, g = data.color.g, b = data.color.b})
end)

RegisterNetEvent('exter-vehicleshop:declinePayment:client', function(data)
    Notify(Lang:t("notifications.request_declined"), 7500, "error")
    exports['exter-textui']:delete3DTextUIOnPlayers("exter-vehicleshop-vehshop-players-confirm-purchase-" .. data.sender)
    TriggerServerEvent('exter-vehicleshop:declinePayment:server', data.sender)
end)

function GetPlayers(onlyOtherPlayers, returnKeyValue, returnPeds)
    local players, myPlayer = {}, PlayerId()
    local active = GetActivePlayers()
    for i = 1, #active do
        local currentPlayer = active[i]
        local ped = GetPlayerPed(currentPlayer)
        if DoesEntityExist(ped) and ((onlyOtherPlayers and currentPlayer ~= myPlayer) or not onlyOtherPlayers) then
            if returnKeyValue then
                players[currentPlayer] = {entity = ped, id = GetPlayerServerId(currentPlayer)}
            else
                players[#players + 1] = returnPeds and ped or currentPlayer
            end
        end
    end
    return players
end

function EnumerateEntitiesWithinDistance(entities, isPlayerEntities, coords, maxDistance)
    local nearbyEntities = {}
    if coords then
        coords = vector3(coords.x, coords.y, coords.z)
    else
        local playerPed = PlayerPedId()
        coords = GetEntityCoords(playerPed)
    end
    for k, v in pairs(entities) do
        local distance = #(coords - GetEntityCoords(v.entity))
        if distance <= maxDistance then
            nearbyEntities[#nearbyEntities + 1] = v.id
        end
    end
    return nearbyEntities
end

function EnumerateEntitiesWithinDistance2(entities, isPlayerEntities, coords, maxDistance)
    local nearbyEntities = {}
    if coords then
        coords = vector3(coords.x, coords.y, coords.z)
    else
        local playerPed = ESX.PlayerData.ped
        coords = GetEntityCoords(playerPed)
    end
    for k, entity in pairs(entities) do
        local distance = #(coords - GetEntityCoords(entity))

        if distance <= maxDistance then
            nearbyEntities[#nearbyEntities + 1] = isPlayerEntities and k or entity
        end
    end
    return nearbyEntities
end

function GetPlayersInArea(coords, maxDistance)
    return EnumerateEntitiesWithinDistance(GetPlayers(true, true), true, coords, maxDistance)
end

function GetVehiclesInArea(coords, maxDistance)
    return EnumerateEntitiesWithinDistance2(GetVehicles(), false, coords, maxDistance)
end

function IsSpawnPointClear(coords, maxDistance)
    return #GetVehiclesInArea(coords, maxDistance) == 0
end

function GetVehicles()
    return GetGamePool("CVehicle")
end

function GetPositionByRelativeHeading(ped, head, dist)
    local pedPos = GetEntityCoords(ped)
    local finPosx = pedPos.x + math.cos(head * (math.pi / 180)) * dist
    local finPosy = pedPos.y + math.sin(head * (math.pi / 180)) * dist
    return finPosx, finPosy
end

function DeleteVehiclesInsideShop()
	while #lastVehicles > 0 do
		local vehicle = lastVehicles[1]
		DeleteVehicle(vehicle)
		table.remove(lastVehicles, 1)
	end
end

AddEventHandler('onResourceStop', function(resource)
    if GetCurrentResourceName() == resource then
        DeleteEntity(obj)
        openDealership(false)
        DeleteVehicle(currentCar)
        ClearFocus()
        RenderScriptCams(false, true, 1000, true, false)
        DestroyCam(cam, false)
        for k, v in pairs(Config.VehicleShops) do
            if v.Ped.Enable then
                DeletePed(v.Ped.ped)
            end
            for a, b in pairs(v.ShowroomVehicles) do
                DeleteVehicle(b.vehicle)
                local model = GetHashKey(b.vehicleModel)
                exports['exter-textui']:delete3DTextUI("exter-vehicleshop-showroom-vehicle-" .. model .. "-spotId-" .. b.spotId)
            end
            exports['exter-textui']:delete3DTextUI("exter-vehicleshop-vehshop-" .. k)
        end
        if nearbyPlayers and next(nearbyPlayers) ~= nil and next(nearbyPlayers) then
            for _, id in pairs(nearbyPlayers) do
                exports['exter-textui']:delete3DTextUIOnPlayers("exter-vehicleshop-vehshop-players-" .. id)
            end
        end
        if currentSender then
            exports['exter-textui']:delete3DTextUIOnPlayers("exter-vehicleshop-vehshop-players-confirm-purchase-" .. currentSender)
        end
    end
end)

local str = [[🚫Keep Area Clear🚫
Test Drive Vehicle Returns]]
Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        local playerCoords = GetEntityCoords(PlayerPedId())
        for k, v in pairs(Config.VehicleShops) do
            local dist = #(playerCoords - vector3(v.Coords.TestVehicles.x, v.Coords.TestVehicles.y, v.Coords.TestVehicles.z))
            if dist <= 5 then
                sleep = 0
                DrawText3D(v.Coords.TestVehicles.x, v.Coords.TestVehicles.y, v.Coords.TestVehicles.z, str)
            end
        end
        Citizen.Wait(sleep)
    end
end)

function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(6)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 245)
    BeginTextCommandDisplayText('STRING')
    SetTextCentre(true)
    AddTextComponentSubstringPlayerName(text)
    SetDrawOrigin(x, y, z, 0)
    EndTextCommandDisplayText(0.0, 0.0)
    local factor = (string.len(text)) / 570
    DrawRect(0.0, 0.0 + 0.025, 0.017 + factor, 0.06, 0, 0, 0, 145)
    ClearDrawOrigin()
end

RegisterNetEvent('exter-vehicleshop:buyVehicle:client', function(model, plate, dealershipId, color, id1, id2)
    DoScreenFadeOut(500)
    openDealership(false)
    Citizen.Wait(1000)
    local model2 = model
    local model = type(model) == 'string' and GetHashKey(model) or model
    if not IsModelInCdimage(model) then return end
    RequestModel(model)
    while not HasModelLoaded(model) do Citizen.Wait(0) end
    local boughtVehCoords = Config.VehicleShops[tonumber(dealershipId)].Coords.BoughtVehicles
    local currentBoughtVehicle = CreateVehicle(model, boughtVehCoords.x, boughtVehCoords.y, boughtVehCoords.z, boughtVehCoords.w, true, false)
    local currentBoughtVehicleNetId = NetworkGetNetworkIdFromEntity(currentBoughtVehicle)
    SetVehicleHasBeenOwnedByPlayer(currentBoughtVehicle, true)
    SetNetworkIdExistsOnAllMachines(currentBoughtVehicleNetId, true)
    SetNetworkIdCanMigrate(currentBoughtVehicleNetId, true)
    SetVehicleNeedsToBeHotwired(currentBoughtVehicle, false)
    SetVehRadioStation(currentBoughtVehicle, 'OFF')
    SetModelAsNoLongerNeeded(model)
    SetVehicleNumberPlateText(currentBoughtVehicle, plate)
    TaskWarpPedIntoVehicle(PlayerPedId(), currentBoughtVehicle, -1)
    GiveKey(currentBoughtVehicle)
    SetFuel(currentBoughtVehicle, 100.0)
    DoScreenFadeIn(500)
    if type(color) == "table" then
        SetVehicleCustomPrimaryColour(currentBoughtVehicle, color.r, color.g, color.b)
        SetVehicleCustomSecondaryColour(currentBoughtVehicle, color.r, color.g, color.b)
    end
    Citizen.Wait(1000)
    TriggerServerEvent('exter-vehicleshop:buyVehicleStep2:server', id1, id2, plate, model2, GetVehicleProperties(currentBoughtVehicle))
end)

function openShowroomMenu(id, state, spots, job)
    if job ~= nil and not GetPlayerJob() == job then return Notify(Lang:t("notifications.no_access"), 7500, "error") end
    showroomMenuActive = state
    if showroomMenuActive then
        local spotsData = {}
        for k, v in pairs(spots) do
            table.insert(spotsData, {
                id = k,
                coords = v.coords
            })
        end
        SendNUIMessage({action = "openShowroomMenu", dealershipId = id, spots = spotsData, vehicles = Vehicles})
        SetNuiFocus(true, true)
    else
        DeleteVehiclesInsideShop()
        RenderScriptCams(false, true, 1000, true, false)
        DestroyCam(cam, false)
        SetNuiFocus(false, false)
        SendNUIMessage({action = "closeUI"})
    end
end

RegisterNetEvent('exter-vehicleshop:finishTest:client', function()
    testDriveState = false
    SendNUIMessage({action = "stopTestTimer"})
    if Config.TeleportBackWhenTestFinishes then
        Notify(Lang:t("notifications.test_period_is_over"), 7500, "info")
        DoScreenFadeOut(1000)
        Citizen.Wait(1000)
        SetEntityCoords(PlayerPedId(), playerLastCoords)
        if DoesEntityExist(currentTestVehicle) then DeleteVehicle(currentTestVehicle) end
        Citizen.Wait(1000)
        DoScreenFadeIn(1000)
    else
        Notify(Lang:t("notifications.test_period_is_over"), 7500, "info")
        if DoesEntityExist(currentTestVehicle) then
            SetVehicleUndriveable(currentTestVehicle, true)
        end
    end
end)

AddEventHandler('gameEventTriggered', function(event, data)
    if event == "CEventNetworkVehicleUndrivable" then
        local vehicle = data[1]
        local netId = NetworkGetNetworkIdFromEntity(vehicle)
        if netId == currentTestVehicleNetId then
            TriggerEvent('exter-vehicleshop:finishTest:client')
            TriggerServerEvent('exter-vehicleshop:finishTest:server', netId)
        end
    end
    if event == "CEventNetworkEntityDamage" then
        local vehicle = data[1]
        local netId = NetworkGetNetworkIdFromEntity(vehicle)
        if netId == currentTestVehicleNetId then
            if GetVehicleBodyHealth(vehicle) == 0 then
                TriggerEvent('exter-vehicleshop:finishTest:client')
                TriggerServerEvent('exter-vehicleshop:finishTest:server', netId)
            end
        end
    end
    if event == 'CEventNetworkEntityDamage' then
        local victim, attacker, victimDied, weapon = data[1], data[2], data[4], data[7]
		if not IsEntityAPed(victim) then return end
        if victimDied and NetworkGetPlayerIndexFromPed(victim) == PlayerId() and IsEntityDead(PlayerPedId()) and menuActive then
            openDealership(false)
            menuActive = false
		end
	end
end)

closestDeliveryPoints = {}
local showTextUI = false
Citizen.CreateThread(function()
	while true do
		local sleep = 1000
		playerPed = PlayerPedId()
		playerCoords = GetEntityCoords(playerPed)
        if IsPedInAnyVehicle(playerPed, false) then
            if not closestDeliveryPoints.id then
                for k, v in pairs(Config.VehicleShops) do
                    local dist = #(playerCoords - vector3(v.Coords.TestVehicles.x, v.Coords.TestVehicles.y, v.Coords.TestVehicles.z))
                    if dist <= 3 then
                        function currentShow()
                            exports["exter-textui"]:displayTextUI(Lang:t("general.give_back_test_vehicle"), "E")
                            showTextUI = true
                        end
                        function currentHide()
                            showTextUI = false
                            exports["exter-textui"]:hideTextUI()
                        end
                        closestDeliveryPoints = {id = k, distance = dist, maxDist = 5.0, data = {coords = vector3(v.Coords.TestVehicles.x, v.Coords.TestVehicles.y, v.Coords.TestVehicles.z)}}
                    end
                end
            end
        end
		if closestDeliveryPoints.id then
			while true do
				playerCoords = GetEntityCoords(playerPed)
				closestDeliveryPoints.distance = #(closestDeliveryPoints.data.coords - playerCoords)
				if closestDeliveryPoints.distance < closestDeliveryPoints.maxDist then
					if IsControlJustReleased(0, 38) then
                        local veh = GetVehiclePedIsUsing(PlayerPedId())
                        if DoesEntityExist(currentTestVehicle) then
                            if VehToNet(veh) == VehToNet(currentTestVehicle) then
                                testDriveState = false
                                SendNUIMessage({action = "stopTestTimer"})
                                TriggerServerEvent('exter-vehicleshop:finishTest:server', VehToNet(currentTestVehicle))
                                TaskLeaveVehicle(PlayerPedId(), currentTestVehicle, 0)
                                while IsPedInAnyVehicle(playerPed, false) do Citizen.Wait(2000) end
                                if DoesEntityExist(currentTestVehicle) then DeleteVehicle(currentTestVehicle) end
                                showTextUI = false
                                exports["exter-textui"]:hideTextUI()
                            end
                        end
					end
					if not showTextUI then
						currentShow()
					end
				else
					currentHide()
					break
				end
				Citizen.Wait(0)
			end
			showTextUI = false
			closestDeliveryPoints = {}
			--sleep = 0
		end
		Citizen.Wait(sleep)
	end
end)

RegisterNetEvent('exter-vehicleshop:deleteVehicle:client', function(netId)
    local vehicle = NetToVeh(netId)
    if DoesEntityExist(vehicle) then
        DeleteVehicle(vehicle)
    end
end)

--RegisterNetEvent('exter-vehicleshop:deleteVehicleShowroom:client', function(dealershipId, spotId, newModel, props)
RegisterNetEvent('exter-vehicleshop:deleteVehicleShowroom:client', function(dealershipId, spotId, newModel, createNew)
    -- Delete Old
    if Config.VehicleShops[dealershipId].ShowroomVehicles[spotId].vehicle then
        if DoesEntityExist(Config.VehicleShops[dealershipId].ShowroomVehicles[spotId].vehicle) then
            DeleteVehicle(Config.VehicleShops[dealershipId].ShowroomVehicles[spotId].vehicle)
        end
    end
    -- New Model
    Config.VehicleShops[dealershipId].ShowroomVehicles[spotId].vehicleModel = newModel
    if createNew then
        local model = GetHashKey(newModel)
        RequestModel(model)
        while not HasModelLoaded(model) do Citizen.Wait(0) end
        local spot = Config.VehicleShops[dealershipId].ShowroomVehicles[spotId]
        Config.VehicleShops[dealershipId].ShowroomVehicles[spotId].vehicle = CreateVehicle(model, spot.coords.x, spot.coords.y, spot.coords.z, false, false)
        local vehicle = Config.VehicleShops[dealershipId].ShowroomVehicles[spotId].vehicle
        SetModelAsNoLongerNeeded(model)
        SetVehicleOnGroundProperly(vehicle)
        SetEntityInvincible(vehicle, true)
        SetVehicleDirtLevel(vehicle, 0.0)
        SetVehicleDoorsLocked(vehicle, 3)
        SetEntityHeading(vehicle, spot.coords.w)
        FreezeEntityPosition(vehicle, true)
        SetVehicleNumberPlateText(vehicle, 'BUY ME')
        PlaceObjectOnGroundProperly(vehicle)
        SetVehicleColourCombination(vehicle, 0)
        --SetVehicleProperties(props)
    end
end)

showTextUI2 = false
closestVehShopPed = {}
Citizen.CreateThread(function()
	while true do
		local sleep = 2000
		playerPed = PlayerPedId()
		playerCoords = GetEntityCoords(playerPed)
		if not closestVehShopPed.id then
			for k, v in pairs(Config.VehicleShops) do
                if v.Interaction.DrawText.Enable then
                    local dist = #(playerCoords - vector3(v.Ped.Coords.x, v.Ped.Coords.y, v.Ped.Coords.z))
                    if dist <= v.Interaction.DrawText.Distance then
                        function currentShow()
                            v.Interaction.DrawText.Show()
                            showTextUI2 = true
                        end
                        function currentHide()
                            v.Interaction.DrawText.Hide()
                        end
                        closestVehShopPed = {id = k, distance = dist, maxDist = v.Interaction.DrawText.Distance, data = {coords = vector3(v.Ped.Coords.x, v.Ped.Coords.y, v.Ped.Coords.z)}}
                    end
                end
			end
		end
		if closestVehShopPed.id then
			while true do
                playerPed = PlayerPedId()
				playerCoords = GetEntityCoords(playerPed)
				closestVehShopPed.distance = #(closestVehShopPed.data.coords - playerCoords)
				if closestVehShopPed.distance < closestVehShopPed.maxDist then
                    if not showTextUI2 then
                        currentShow()
                    end
                else
                    currentHide()
                    break
				end
				Citizen.Wait(0)
			end
            showTextUI2 = false
			closestVehShopPed = {}
			sleep = 0
		end
		Citizen.Wait(sleep)
	end
end)