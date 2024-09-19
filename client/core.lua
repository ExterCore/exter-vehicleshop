Core = nil
CoreName = nil
CoreReady = false
SetFuel = nil
GiveKey = nil
Citizen.CreateThread(function()
    for k, v in pairs(Cores) do
        if GetResourceState(v.ResourceName) == "starting" or GetResourceState(v.ResourceName) == "started" then
            CoreName = v.ResourceName
            Core = v.GetFramework()
            CoreReady = true
        end
    end
    for k, v in pairs(Fuels) do
        if GetResourceState(v.ResourceName) == "starting" or GetResourceState(v.ResourceName) == "started" then
            function SetFuel(vehicle, fuel) v.SetFuel(vehicle, fuel) end
        end
    end
    for k, v in pairs(Keys) do
        if GetResourceState(v.ResourceName) == "starting" or GetResourceState(v.ResourceName) == "started" then
            function GiveKey(vehicle, plate)
                local ignore = "'_./ '" 
                local vehPlate = GetVehicleNumberPlateText(vehicle) 
                vehPlate = vehPlate:gsub("["..ignore.."]+", "")
                v.GiveKey(vehicle, vehPlate) 
            end
        end
    end
end)

function TriggerCallback(name, cb, ...)
    Config.ServerCallbacks[name] = cb
    TriggerServerEvent('exter-vehicleshop:server:triggerCallback', name, ...)
end

RegisterNetEvent('exter-vehicleshop:client:triggerCallback', function(name, ...)
    if Config.ServerCallbacks[name] then
        Config.ServerCallbacks[name](...)
        Config.ServerCallbacks[name] = nil
    end
end)

function Notify(text, length, type)
    if CoreName == "qb-core" or CoreName == "qbx_core" then
        Core.Functions.Notify(text, type, length)
    elseif CoreName == "es_extended" then
        Core.ShowNotification(text)
    end
end

function GetPlayerData()
    if CoreName == "qb-core" or CoreName == "qbx_core" then
        local player = Core.Functions.GetPlayerData()
        return player
    elseif CoreName == "es_extended" then
        local player = Core.GetPlayerData()
        return player
    end
end

function GetPlayerJob()
    if CoreName == "qb-core" or CoreName == "qbx_core" then
        return Core.Functions.GetPlayerData().job.name
    elseif CoreName == "es_extended" then
        local player = Core.GetPlayerData()
        return player.job.name
    end
end

function GetVehicleProperties(vehicle)
    if CoreName == "qb-core" or CoreName == "qbx_core" then
        if DoesEntityExist(vehicle) then
            local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)

            local colorPrimary, colorSecondary = GetVehicleColours(vehicle)
            if GetIsVehiclePrimaryColourCustom(vehicle) then
                local r, g, b = GetVehicleCustomPrimaryColour(vehicle)
                colorPrimary = { r, g, b }
            end

            if GetIsVehicleSecondaryColourCustom(vehicle) then
                local r, g, b = GetVehicleCustomSecondaryColour(vehicle)
                colorSecondary = { r, g, b }
            end

            local extras = {}
            for extraId = 0, 12 do
                if DoesExtraExist(vehicle, extraId) then
                    local state = IsVehicleExtraTurnedOn(vehicle, extraId) == 1
                    extras[tostring(extraId)] = state
                end
            end

            local modLivery = GetVehicleMod(vehicle, 48)
            if GetVehicleMod(vehicle, 48) == -1 and GetVehicleLivery(vehicle) ~= 0 then
                modLivery = GetVehicleLivery(vehicle)
            end

            local tireHealth = {}
            for i = 0, 3 do
                tireHealth[i] = GetVehicleWheelHealth(vehicle, i)
            end

            local tireBurstState = {}
            for i = 0, 5 do
                tireBurstState[i] = IsVehicleTyreBurst(vehicle, i, false)
            end

            local tireBurstCompletely = {}
            for i = 0, 5 do
                tireBurstCompletely[i] = IsVehicleTyreBurst(vehicle, i, true)
            end

            local windowStatus = {}
            for i = 0, 7 do
                windowStatus[i] = IsVehicleWindowIntact(vehicle, i) == 1
            end

            local doorStatus = {}
            for i = 0, 5 do
                doorStatus[i] = IsVehicleDoorDamaged(vehicle, i) == 1
            end

            local xenonColor
            local hasCustom, r, g, b = GetVehicleXenonLightsCustomColor(vehicle)
            if hasCustom then
                xenonColor = table.pack(r, g, b)
            else
                xenonColor = GetVehicleXenonLightsColor(vehicle)
            end

            return {
                model = GetEntityModel(vehicle),
                plate = GetVehicleNumberPlateText(vehicle),
                plateIndex = GetVehicleNumberPlateTextIndex(vehicle),
                bodyHealth = Round(GetVehicleBodyHealth(vehicle), 0.1),
                engineHealth = Round(GetVehicleEngineHealth(vehicle), 0.1),
                tankHealth = Round(GetVehiclePetrolTankHealth(vehicle), 0.1),
                fuelLevel = Round(GetVehicleFuelLevel(vehicle), 0.1),
                dirtLevel = Round(GetVehicleDirtLevel(vehicle), 0.1),
                oilLevel = Round(GetVehicleOilLevel(vehicle), 0.1),
                color1 = colorPrimary,
                color2 = colorSecondary,
                pearlescentColor = pearlescentColor,
                dashboardColor = GetVehicleDashboardColour(vehicle),
                wheelColor = wheelColor,
                wheels = GetVehicleWheelType(vehicle),
                wheelSize = GetVehicleWheelSize(vehicle),
                wheelWidth = GetVehicleWheelWidth(vehicle),
                tireHealth = tireHealth,
                tireBurstState = tireBurstState,
                tireBurstCompletely = tireBurstCompletely,
                windowTint = GetVehicleWindowTint(vehicle),
                windowStatus = windowStatus,
                doorStatus = doorStatus,
                neonEnabled = {
                    IsVehicleNeonLightEnabled(vehicle, 0),
                    IsVehicleNeonLightEnabled(vehicle, 1),
                    IsVehicleNeonLightEnabled(vehicle, 2),
                    IsVehicleNeonLightEnabled(vehicle, 3)
                },
                neonColor = table.pack(GetVehicleNeonLightsColour(vehicle)),
                interiorColor = GetVehicleInteriorColour(vehicle),
                extras = extras,
                tyreSmokeColor = table.pack(GetVehicleTyreSmokeColor(vehicle)),
                xenonColor = xenonColor,
                modSpoilers = GetVehicleMod(vehicle, 0),
                modFrontBumper = GetVehicleMod(vehicle, 1),
                modRearBumper = GetVehicleMod(vehicle, 2),
                modSideSkirt = GetVehicleMod(vehicle, 3),
                modExhaust = GetVehicleMod(vehicle, 4),
                modFrame = GetVehicleMod(vehicle, 5),
                modGrille = GetVehicleMod(vehicle, 6),
                modHood = GetVehicleMod(vehicle, 7),
                modFender = GetVehicleMod(vehicle, 8),
                modRightFender = GetVehicleMod(vehicle, 9),
                modRoof = GetVehicleMod(vehicle, 10),
                modEngine = GetVehicleMod(vehicle, 11),
                modBrakes = GetVehicleMod(vehicle, 12),
                modTransmission = GetVehicleMod(vehicle, 13),
                modHorns = GetVehicleMod(vehicle, 14),
                modSuspension = GetVehicleMod(vehicle, 15),
                modArmor = GetVehicleMod(vehicle, 16),
                modKit17 = GetVehicleMod(vehicle, 17),
                modTurbo = IsToggleModOn(vehicle, 18),
                modKit19 = GetVehicleMod(vehicle, 19),
                modSmokeEnabled = IsToggleModOn(vehicle, 20),
                modKit21 = GetVehicleMod(vehicle, 21),
                modXenon = IsToggleModOn(vehicle, 22),
                modFrontWheels = GetVehicleMod(vehicle, 23),
                modBackWheels = GetVehicleMod(vehicle, 24),
                modCustomTiresF = GetVehicleModVariation(vehicle, 23),
                modCustomTiresR = GetVehicleModVariation(vehicle, 24),
                modPlateHolder = GetVehicleMod(vehicle, 25),
                modVanityPlate = GetVehicleMod(vehicle, 26),
                modTrimA = GetVehicleMod(vehicle, 27),
                modOrnaments = GetVehicleMod(vehicle, 28),
                modDashboard = GetVehicleMod(vehicle, 29),
                modDial = GetVehicleMod(vehicle, 30),
                modDoorSpeaker = GetVehicleMod(vehicle, 31),
                modSeats = GetVehicleMod(vehicle, 32),
                modSteeringWheel = GetVehicleMod(vehicle, 33),
                modShifterLeavers = GetVehicleMod(vehicle, 34),
                modAPlate = GetVehicleMod(vehicle, 35),
                modSpeakers = GetVehicleMod(vehicle, 36),
                modTrunk = GetVehicleMod(vehicle, 37),
                modHydrolic = GetVehicleMod(vehicle, 38),
                modEngineBlock = GetVehicleMod(vehicle, 39),
                modAirFilter = GetVehicleMod(vehicle, 40),
                modStruts = GetVehicleMod(vehicle, 41),
                modArchCover = GetVehicleMod(vehicle, 42),
                modAerials = GetVehicleMod(vehicle, 43),
                modTrimB = GetVehicleMod(vehicle, 44),
                modTank = GetVehicleMod(vehicle, 45),
                modWindows = GetVehicleMod(vehicle, 46),
                modKit47 = GetVehicleMod(vehicle, 47),
                modLivery = modLivery,
                modKit49 = GetVehicleMod(vehicle, 49),
                liveryRoof = GetVehicleRoofLivery(vehicle),
            }
        else
            return
        end
    elseif CoreName == "es_extended" then
        if not DoesEntityExist(vehicle) then
            return
        end
    
        local colorPrimary, colorSecondary = GetVehicleColours(vehicle)
        local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
        local hasCustomPrimaryColor = GetIsVehiclePrimaryColourCustom(vehicle)
        local dashboardColor = GetVehicleDashboardColor(vehicle)
        local interiorColor = GetVehicleInteriorColour(vehicle)
        local customPrimaryColor = nil
        if hasCustomPrimaryColor then
            customPrimaryColor = { GetVehicleCustomPrimaryColour(vehicle) }
        end
    
        local hasCustomXenonColor, customXenonColorR, customXenonColorG, customXenonColorB = GetVehicleXenonLightsCustomColor(vehicle)
        local customXenonColor = nil
        if hasCustomXenonColor then
            customXenonColor = { customXenonColorR, customXenonColorG, customXenonColorB }
        end
    
        local hasCustomSecondaryColor = GetIsVehicleSecondaryColourCustom(vehicle)
        local customSecondaryColor = nil
        if hasCustomSecondaryColor then
            customSecondaryColor = { GetVehicleCustomSecondaryColour(vehicle) }
        end
    
        local extras = {}
        for extraId = 0, 20 do
            if DoesExtraExist(vehicle, extraId) then
                extras[tostring(extraId)] = IsVehicleExtraTurnedOn(vehicle, extraId)
            end
        end
    
        local doorsBroken, windowsBroken, tyreBurst = {}, {}, {}
        local numWheels = tostring(GetVehicleNumberOfWheels(vehicle))
    
        local TyresIndex = { -- Wheel index list according to the number of vehicle wheels.
            ["2"] = { 0, 4 }, -- Bike and cycle.
            ["3"] = { 0, 1, 4, 5 }, -- Vehicle with 3 wheels (get for wheels because some 3 wheels vehicles have 2 wheels on front and one rear or the reverse).
            ["4"] = { 0, 1, 4, 5 }, -- Vehicle with 4 wheels.
            ["6"] = { 0, 1, 2, 3, 4, 5 }, -- Vehicle with 6 wheels.
        }
    
        if TyresIndex[numWheels] then
            for _, idx in pairs(TyresIndex[numWheels]) do
                tyreBurst[tostring(idx)] = IsVehicleTyreBurst(vehicle, idx, false)
            end
        end
    
        for windowId = 0, 7 do -- 13
            RollUpWindow(vehicle, windowId) --fix when you put the car away with the window down
            windowsBroken[tostring(windowId)] = not IsVehicleWindowIntact(vehicle, windowId)
        end
    
        local numDoors = GetNumberOfVehicleDoors(vehicle)
        if numDoors and numDoors > 0 then
            for doorsId = 0, numDoors do
                doorsBroken[tostring(doorsId)] = IsVehicleDoorDamaged(vehicle, doorsId)
            end
        end
    
        return {
            model = GetEntityModel(vehicle),
            doorsBroken = doorsBroken,
            windowsBroken = windowsBroken,
            tyreBurst = tyreBurst,
            tyresCanBurst = GetVehicleTyresCanBurst(vehicle),
            plate = Trim(GetVehicleNumberPlateText(vehicle)),
            plateIndex = GetVehicleNumberPlateTextIndex(vehicle),
    
            bodyHealth = Round(GetVehicleBodyHealth(vehicle), 1),
            engineHealth = Round(GetVehicleEngineHealth(vehicle), 1),
            tankHealth = Round(GetVehiclePetrolTankHealth(vehicle), 1),
    
            fuelLevel = Round(GetVehicleFuelLevel(vehicle), 1),
            dirtLevel = Round(GetVehicleDirtLevel(vehicle), 1),
            color1 = colorPrimary,
            color2 = colorSecondary,
            customPrimaryColor = customPrimaryColor,
            customSecondaryColor = customSecondaryColor,
    
            pearlescentColor = pearlescentColor,
            wheelColor = wheelColor,
    
            dashboardColor = dashboardColor,
            interiorColor = interiorColor,
    
            wheels = GetVehicleWheelType(vehicle),
            windowTint = GetVehicleWindowTint(vehicle),
            xenonColor = GetVehicleXenonLightsColor(vehicle),
            customXenonColor = customXenonColor,
    
            neonEnabled = { IsVehicleNeonLightEnabled(vehicle, 0), IsVehicleNeonLightEnabled(vehicle, 1), IsVehicleNeonLightEnabled(vehicle, 2), IsVehicleNeonLightEnabled(vehicle, 3) },
    
            neonColor = table.pack(GetVehicleNeonLightsColour(vehicle)),
            extras = extras,
            tyreSmokeColor = table.pack(GetVehicleTyreSmokeColor(vehicle)),
    
            modSpoilers = GetVehicleMod(vehicle, 0),
            modFrontBumper = GetVehicleMod(vehicle, 1),
            modRearBumper = GetVehicleMod(vehicle, 2),
            modSideSkirt = GetVehicleMod(vehicle, 3),
            modExhaust = GetVehicleMod(vehicle, 4),
            modFrame = GetVehicleMod(vehicle, 5),
            modGrille = GetVehicleMod(vehicle, 6),
            modHood = GetVehicleMod(vehicle, 7),
            modFender = GetVehicleMod(vehicle, 8),
            modRightFender = GetVehicleMod(vehicle, 9),
            modRoof = GetVehicleMod(vehicle, 10),
            modRoofLivery = GetVehicleRoofLivery(vehicle),
    
            modEngine = GetVehicleMod(vehicle, 11),
            modBrakes = GetVehicleMod(vehicle, 12),
            modTransmission = GetVehicleMod(vehicle, 13),
            modHorns = GetVehicleMod(vehicle, 14),
            modSuspension = GetVehicleMod(vehicle, 15),
            modArmor = GetVehicleMod(vehicle, 16),
    
            modTurbo = IsToggleModOn(vehicle, 18),
            modSmokeEnabled = IsToggleModOn(vehicle, 20),
            modXenon = IsToggleModOn(vehicle, 22),
    
            modFrontWheels = GetVehicleMod(vehicle, 23),
            modCustomFrontWheels = GetVehicleModVariation(vehicle, 23),
            modBackWheels = GetVehicleMod(vehicle, 24),
            modCustomBackWheels = GetVehicleModVariation(vehicle, 24),
    
            modPlateHolder = GetVehicleMod(vehicle, 25),
            modVanityPlate = GetVehicleMod(vehicle, 26),
            modTrimA = GetVehicleMod(vehicle, 27),
            modOrnaments = GetVehicleMod(vehicle, 28),
            modDashboard = GetVehicleMod(vehicle, 29),
            modDial = GetVehicleMod(vehicle, 30),
            modDoorSpeaker = GetVehicleMod(vehicle, 31),
            modSeats = GetVehicleMod(vehicle, 32),
            modSteeringWheel = GetVehicleMod(vehicle, 33),
            modShifterLeavers = GetVehicleMod(vehicle, 34),
            modAPlate = GetVehicleMod(vehicle, 35),
            modSpeakers = GetVehicleMod(vehicle, 36),
            modTrunk = GetVehicleMod(vehicle, 37),
            modHydrolic = GetVehicleMod(vehicle, 38),
            modEngineBlock = GetVehicleMod(vehicle, 39),
            modAirFilter = GetVehicleMod(vehicle, 40),
            modStruts = GetVehicleMod(vehicle, 41),
            modArchCover = GetVehicleMod(vehicle, 42),
            modAerials = GetVehicleMod(vehicle, 43),
            modTrimB = GetVehicleMod(vehicle, 44),
            modTank = GetVehicleMod(vehicle, 45),
            modWindows = GetVehicleMod(vehicle, 46),
            modLivery = GetVehicleMod(vehicle, 48) == -1 and GetVehicleLivery(vehicle) or GetVehicleMod(vehicle, 48),
            modLightbar = GetVehicleMod(vehicle, 49),
        }
    end
end

function SetVehicleProperties(vehicle, props)
    if CoreName == "qb-core" or CoreName == "qbx_core" then
        if DoesEntityExist(vehicle) then
            if props.extras then
                for id, enabled in pairs(props.extras) do
                    if enabled then
                        SetVehicleExtra(vehicle, tonumber(id), 0)
                    else
                        SetVehicleExtra(vehicle, tonumber(id), 1)
                    end
                end
            end
            local colorPrimary, colorSecondary = GetVehicleColours(vehicle)
            local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
            SetVehicleModKit(vehicle, 0)
            if props.plate then
                SetVehicleNumberPlateText(vehicle, props.plate)
            end
            if props.plateIndex then
                SetVehicleNumberPlateTextIndex(vehicle, props.plateIndex)
            end
            if props.bodyHealth then
                SetVehicleBodyHealth(vehicle, props.bodyHealth + 0.0)
            end
            if props.engineHealth then
                SetVehicleEngineHealth(vehicle, props.engineHealth + 0.0)
            end
            if props.tankHealth then
                SetVehiclePetrolTankHealth(vehicle, props.tankHealth)
            end
            if props.fuelLevel then
                SetVehicleFuelLevel(vehicle, props.fuelLevel + 0.0)
            end
            if props.dirtLevel then
                SetVehicleDirtLevel(vehicle, props.dirtLevel + 0.0)
            end
            if props.oilLevel then
                SetVehicleOilLevel(vehicle, props.oilLevel)
            end
            if props.color1 then
                if type(props.color1) == 'number' then
                    ClearVehicleCustomPrimaryColour(vehicle)
                    SetVehicleColours(vehicle, props.color1, colorSecondary)
                else
                    SetVehicleCustomPrimaryColour(vehicle, props.color1[1], props.color1[2], props.color1[3])
                end
            end
            if props.color2 then
                if type(props.color2) == 'number' then
                    ClearVehicleCustomSecondaryColour(vehicle)
                    SetVehicleColours(vehicle, props.color1 or colorPrimary, props.color2)
                else
                    SetVehicleCustomSecondaryColour(vehicle, props.color2[1], props.color2[2], props.color2[3])
                end
            end
            if props.pearlescentColor then
                SetVehicleExtraColours(vehicle, props.pearlescentColor, wheelColor)
            end
            if props.interiorColor then
                SetVehicleInteriorColor(vehicle, props.interiorColor)
            end
            if props.dashboardColor then
                SetVehicleDashboardColour(vehicle, props.dashboardColor)
            end
            if props.wheelColor then
                SetVehicleExtraColours(vehicle, props.pearlescentColor or pearlescentColor, props.wheelColor)
            end
            if props.wheels then
                SetVehicleWheelType(vehicle, props.wheels)
            end
            if props.tireHealth then
                for wheelIndex, health in pairs(props.tireHealth) do
                    SetVehicleWheelHealth(vehicle, wheelIndex, health)
                end
            end
            if props.tireBurstState then
                for wheelIndex, burstState in pairs(props.tireBurstState) do
                    if burstState then
                        SetVehicleTyreBurst(vehicle, tonumber(wheelIndex), false, 1000.0)
                    end
                end
            end
            if props.tireBurstCompletely then
                for wheelIndex, burstState in pairs(props.tireBurstCompletely) do
                    if burstState then
                        SetVehicleTyreBurst(vehicle, tonumber(wheelIndex), true, 1000.0)
                    end
                end
            end
            if props.windowTint then
                SetVehicleWindowTint(vehicle, props.windowTint)
            end
            if props.windowStatus then
                for windowIndex, smashWindow in pairs(props.windowStatus) do
                    if not smashWindow then SmashVehicleWindow(vehicle, windowIndex) end
                end
            end
            if props.doorStatus then
                for doorIndex, breakDoor in pairs(props.doorStatus) do
                    if breakDoor then
                        SetVehicleDoorBroken(vehicle, tonumber(doorIndex), true)
                    end
                end
            end
            if props.neonEnabled then
                SetVehicleNeonLightEnabled(vehicle, 0, props.neonEnabled[1])
                SetVehicleNeonLightEnabled(vehicle, 1, props.neonEnabled[2])
                SetVehicleNeonLightEnabled(vehicle, 2, props.neonEnabled[3])
                SetVehicleNeonLightEnabled(vehicle, 3, props.neonEnabled[4])
            end
            if props.neonColor then
                SetVehicleNeonLightsColour(vehicle, props.neonColor[1], props.neonColor[2], props.neonColor[3])
            end
            if props.interiorColor then
                SetVehicleInteriorColour(vehicle, props.interiorColor)
            end
            if props.wheelSize then
                SetVehicleWheelSize(vehicle, props.wheelSize)
            end
            if props.wheelWidth then
                SetVehicleWheelWidth(vehicle, props.wheelWidth)
            end
            if props.tyreSmokeColor then
                SetVehicleTyreSmokeColor(vehicle, props.tyreSmokeColor[1], props.tyreSmokeColor[2], props.tyreSmokeColor[3])
            end
            if props.modSpoilers then
                SetVehicleMod(vehicle, 0, props.modSpoilers, false)
            end
            if props.modFrontBumper then
                SetVehicleMod(vehicle, 1, props.modFrontBumper, false)
            end
            if props.modRearBumper then
                SetVehicleMod(vehicle, 2, props.modRearBumper, false)
            end
            if props.modSideSkirt then
                SetVehicleMod(vehicle, 3, props.modSideSkirt, false)
            end
            if props.modExhaust then
                SetVehicleMod(vehicle, 4, props.modExhaust, false)
            end
            if props.modFrame then
                SetVehicleMod(vehicle, 5, props.modFrame, false)
            end
            if props.modGrille then
                SetVehicleMod(vehicle, 6, props.modGrille, false)
            end
            if props.modHood then
                SetVehicleMod(vehicle, 7, props.modHood, false)
            end
            if props.modFender then
                SetVehicleMod(vehicle, 8, props.modFender, false)
            end
            if props.modRightFender then
                SetVehicleMod(vehicle, 9, props.modRightFender, false)
            end
            if props.modRoof then
                SetVehicleMod(vehicle, 10, props.modRoof, false)
            end
            if props.modEngine then
                SetVehicleMod(vehicle, 11, props.modEngine, false)
            end
            if props.modBrakes then
                SetVehicleMod(vehicle, 12, props.modBrakes, false)
            end
            if props.modTransmission then
                SetVehicleMod(vehicle, 13, props.modTransmission, false)
            end
            if props.modHorns then
                SetVehicleMod(vehicle, 14, props.modHorns, false)
            end
            if props.modSuspension then
                SetVehicleMod(vehicle, 15, props.modSuspension, false)
            end
            if props.modArmor then
                SetVehicleMod(vehicle, 16, props.modArmor, false)
            end
            if props.modKit17 then
                SetVehicleMod(vehicle, 17, props.modKit17, false)
            end
            if props.modTurbo then
                ToggleVehicleMod(vehicle, 18, props.modTurbo)
            end
            if props.modKit19 then
                SetVehicleMod(vehicle, 19, props.modKit19, false)
            end
            if props.modSmokeEnabled then
                ToggleVehicleMod(vehicle, 20, props.modSmokeEnabled)
            end
            if props.modKit21 then
                SetVehicleMod(vehicle, 21, props.modKit21, false)
            end
            if props.modXenon then
                ToggleVehicleMod(vehicle, 22, props.modXenon)
            end
            if props.xenonColor then
                if type(props.xenonColor) == 'table' then
                    SetVehicleXenonLightsCustomColor(vehicle, props.xenonColor[1], props.xenonColor[2], props.xenonColor[3])
                else
                    SetVehicleXenonLightsColor(vehicle, props.xenonColor)
                end
            end
            if props.modFrontWheels then
                SetVehicleMod(vehicle, 23, props.modFrontWheels, false)
            end
            if props.modBackWheels then
                SetVehicleMod(vehicle, 24, props.modBackWheels, false)
            end
            if props.modCustomTiresF then
                SetVehicleMod(vehicle, 23, props.modFrontWheels, props.modCustomTiresF)
            end
            if props.modCustomTiresR then
                SetVehicleMod(vehicle, 24, props.modBackWheels, props.modCustomTiresR)
            end
            if props.modPlateHolder then
                SetVehicleMod(vehicle, 25, props.modPlateHolder, false)
            end
            if props.modVanityPlate then
                SetVehicleMod(vehicle, 26, props.modVanityPlate, false)
            end
            if props.modTrimA then
                SetVehicleMod(vehicle, 27, props.modTrimA, false)
            end
            if props.modOrnaments then
                SetVehicleMod(vehicle, 28, props.modOrnaments, false)
            end
            if props.modDashboard then
                SetVehicleMod(vehicle, 29, props.modDashboard, false)
            end
            if props.modDial then
                SetVehicleMod(vehicle, 30, props.modDial, false)
            end
            if props.modDoorSpeaker then
                SetVehicleMod(vehicle, 31, props.modDoorSpeaker, false)
            end
            if props.modSeats then
                SetVehicleMod(vehicle, 32, props.modSeats, false)
            end
            if props.modSteeringWheel then
                SetVehicleMod(vehicle, 33, props.modSteeringWheel, false)
            end
            if props.modShifterLeavers then
                SetVehicleMod(vehicle, 34, props.modShifterLeavers, false)
            end
            if props.modAPlate then
                SetVehicleMod(vehicle, 35, props.modAPlate, false)
            end
            if props.modSpeakers then
                SetVehicleMod(vehicle, 36, props.modSpeakers, false)
            end
            if props.modTrunk then
                SetVehicleMod(vehicle, 37, props.modTrunk, false)
            end
            if props.modHydrolic then
                SetVehicleMod(vehicle, 38, props.modHydrolic, false)
            end
            if props.modEngineBlock then
                SetVehicleMod(vehicle, 39, props.modEngineBlock, false)
            end
            if props.modAirFilter then
                SetVehicleMod(vehicle, 40, props.modAirFilter, false)
            end
            if props.modStruts then
                SetVehicleMod(vehicle, 41, props.modStruts, false)
            end
            if props.modArchCover then
                SetVehicleMod(vehicle, 42, props.modArchCover, false)
            end
            if props.modAerials then
                SetVehicleMod(vehicle, 43, props.modAerials, false)
            end
            if props.modTrimB then
                SetVehicleMod(vehicle, 44, props.modTrimB, false)
            end
            if props.modTank then
                SetVehicleMod(vehicle, 45, props.modTank, false)
            end
            if props.modWindows then
                SetVehicleMod(vehicle, 46, props.modWindows, false)
            end
            if props.modKit47 then
                SetVehicleMod(vehicle, 47, props.modKit47, false)
            end
            if props.modLivery then
                SetVehicleMod(vehicle, 48, props.modLivery, false)
                SetVehicleLivery(vehicle, props.modLivery)
            end
            if props.modKit49 then
                SetVehicleMod(vehicle, 49, props.modKit49, false)
            end
            if props.liveryRoof then
                SetVehicleRoofLivery(vehicle, props.liveryRoof)
            end
        end
    elseif CoreName == "es_extended" then
        if not DoesEntityExist(vehicle) then
            return
        end
        local colorPrimary, colorSecondary = GetVehicleColours(vehicle)
        local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
        SetVehicleModKit(vehicle, 0)
        if props.tyresCanBurst ~= nil then
            SetVehicleTyresCanBurst(vehicle, props.tyresCanBurst)
        end
        if props.plate ~= nil then
            SetVehicleNumberPlateText(vehicle, props.plate)
        end
        if props.plateIndex ~= nil then
            SetVehicleNumberPlateTextIndex(vehicle, props.plateIndex)
        end
        if props.bodyHealth ~= nil then
            SetVehicleBodyHealth(vehicle, props.bodyHealth + 0.0)
        end
        if props.engineHealth ~= nil then
            SetVehicleEngineHealth(vehicle, props.engineHealth + 0.0)
        end
        if props.tankHealth ~= nil then
            SetVehiclePetrolTankHealth(vehicle, props.tankHealth + 0.0)
        end
        if props.fuelLevel ~= nil then
            SetVehicleFuelLevel(vehicle, props.fuelLevel + 0.0)
        end
        if props.dirtLevel ~= nil then
            SetVehicleDirtLevel(vehicle, props.dirtLevel + 0.0)
        end
        if props.customPrimaryColor ~= nil then
            SetVehicleCustomPrimaryColour(vehicle, props.customPrimaryColor[1], props.customPrimaryColor[2], props.customPrimaryColor[3])
        end
        if props.customSecondaryColor ~= nil then
            SetVehicleCustomSecondaryColour(vehicle, props.customSecondaryColor[1], props.customSecondaryColor[2], props.customSecondaryColor[3])
        end
        if props.color1 ~= nil then
            SetVehicleColours(vehicle, props.color1, colorSecondary)
        end
        if props.color2 ~= nil then
            SetVehicleColours(vehicle, props.color1 or colorPrimary, props.color2)
        end
        if props.pearlescentColor ~= nil then
            SetVehicleExtraColours(vehicle, props.pearlescentColor, wheelColor)
        end
        if props.interiorColor ~= nil then
            SetVehicleInteriorColor(vehicle, props.interiorColor)
        end
        if props.dashboardColor ~= nil then
            SetVehicleDashboardColor(vehicle, props.dashboardColor)
        end
        if props.wheelColor ~= nil then
            SetVehicleExtraColours(vehicle, props.pearlescentColor or pearlescentColor, props.wheelColor)
        end
        if props.wheels ~= nil then
            SetVehicleWheelType(vehicle, props.wheels)
        end
        if props.windowTint ~= nil then
            SetVehicleWindowTint(vehicle, props.windowTint)
        end  
        if props.neonEnabled ~= nil then
            SetVehicleNeonLightEnabled(vehicle, 0, props.neonEnabled[1])
            SetVehicleNeonLightEnabled(vehicle, 1, props.neonEnabled[2])
            SetVehicleNeonLightEnabled(vehicle, 2, props.neonEnabled[3])
            SetVehicleNeonLightEnabled(vehicle, 3, props.neonEnabled[4])
        end  
        if props.extras ~= nil then
            for extraId, enabled in pairs(props.extras) do
                SetVehicleExtra(vehicle, tonumber(extraId), enabled and 0 or 1)
            end
        end
        if props.neonColor ~= nil then
            SetVehicleNeonLightsColour(vehicle, props.neonColor[1], props.neonColor[2], props.neonColor[3])
        end
        if props.xenonColor ~= nil then
            SetVehicleXenonLightsColor(vehicle, props.xenonColor)
        end
        if props.customXenonColor ~= nil then
            SetVehicleXenonLightsCustomColor(vehicle, props.customXenonColor[1], props.customXenonColor[2], props.customXenonColor[3])
        end
        if props.modSmokeEnabled ~= nil then
            ToggleVehicleMod(vehicle, 20, true)
        end
        if props.tyreSmokeColor ~= nil then
            SetVehicleTyreSmokeColor(vehicle, props.tyreSmokeColor[1], props.tyreSmokeColor[2], props.tyreSmokeColor[3])
        end
        if props.modSpoilers ~= nil then
            SetVehicleMod(vehicle, 0, props.modSpoilers, false)
        end
        if props.modFrontBumper ~= nil then
            SetVehicleMod(vehicle, 1, props.modFrontBumper, false)
        end
        if props.modRearBumper ~= nil then
            SetVehicleMod(vehicle, 2, props.modRearBumper, false)
        end
        if props.modSideSkirt ~= nil then
            SetVehicleMod(vehicle, 3, props.modSideSkirt, false)
        end
        if props.modExhaust ~= nil then
            SetVehicleMod(vehicle, 4, props.modExhaust, false)
        end
        if props.modFrame ~= nil then
            SetVehicleMod(vehicle, 5, props.modFrame, false)
        end
        if props.modGrille ~= nil then
            SetVehicleMod(vehicle, 6, props.modGrille, false)
        end
        if props.modHood ~= nil then
            SetVehicleMod(vehicle, 7, props.modHood, false)
        end
        if props.modFender ~= nil then
            SetVehicleMod(vehicle, 8, props.modFender, false)
        end
        if props.modRightFender ~= nil then
            SetVehicleMod(vehicle, 9, props.modRightFender, false)
        end
        if props.modRoof ~= nil then
            SetVehicleMod(vehicle, 10, props.modRoof, false)
        end
    
        if props.modRoofLivery ~= nil then
            SetVehicleRoofLivery(vehicle, props.modRoofLivery)
        end
    
        if props.modEngine ~= nil then
            SetVehicleMod(vehicle, 11, props.modEngine, false)
        end
        if props.modBrakes ~= nil then
            SetVehicleMod(vehicle, 12, props.modBrakes, false)
        end
        if props.modTransmission ~= nil then
            SetVehicleMod(vehicle, 13, props.modTransmission, false)
        end
        if props.modHorns ~= nil then
            SetVehicleMod(vehicle, 14, props.modHorns, false)
        end
        if props.modSuspension ~= nil then
            SetVehicleMod(vehicle, 15, props.modSuspension, false)
        end
        if props.modArmor ~= nil then
            SetVehicleMod(vehicle, 16, props.modArmor, false)
        end
        if props.modTurbo ~= nil then
            ToggleVehicleMod(vehicle, 18, props.modTurbo)
        end
        if props.modXenon ~= nil then
            ToggleVehicleMod(vehicle, 22, props.modXenon)
        end
        if props.modFrontWheels ~= nil then
            SetVehicleMod(vehicle, 23, props.modFrontWheels, props.modCustomFrontWheels)
        end
        if props.modBackWheels ~= nil then
            SetVehicleMod(vehicle, 24, props.modBackWheels, props.modCustomBackWheels)
        end
        if props.modPlateHolder ~= nil then
            SetVehicleMod(vehicle, 25, props.modPlateHolder, false)
        end
        if props.modVanityPlate ~= nil then
            SetVehicleMod(vehicle, 26, props.modVanityPlate, false)
        end
        if props.modTrimA ~= nil then
            SetVehicleMod(vehicle, 27, props.modTrimA, false)
        end
        if props.modOrnaments ~= nil then
            SetVehicleMod(vehicle, 28, props.modOrnaments, false)
        end
        if props.modDashboard ~= nil then
            SetVehicleMod(vehicle, 29, props.modDashboard, false)
        end
        if props.modDial ~= nil then
            SetVehicleMod(vehicle, 30, props.modDial, false)
        end
        if props.modDoorSpeaker ~= nil then
            SetVehicleMod(vehicle, 31, props.modDoorSpeaker, false)
        end
        if props.modSeats ~= nil then
            SetVehicleMod(vehicle, 32, props.modSeats, false)
        end
        if props.modSteeringWheel ~= nil then
            SetVehicleMod(vehicle, 33, props.modSteeringWheel, false)
        end
        if props.modShifterLeavers ~= nil then
            SetVehicleMod(vehicle, 34, props.modShifterLeavers, false)
        end
        if props.modAPlate ~= nil then
            SetVehicleMod(vehicle, 35, props.modAPlate, false)
        end
        if props.modSpeakers ~= nil then
            SetVehicleMod(vehicle, 36, props.modSpeakers, false)
        end
        if props.modTrunk ~= nil then
            SetVehicleMod(vehicle, 37, props.modTrunk, false)
        end
        if props.modHydrolic ~= nil then
            SetVehicleMod(vehicle, 38, props.modHydrolic, false)
        end
        if props.modEngineBlock ~= nil then
            SetVehicleMod(vehicle, 39, props.modEngineBlock, false)
        end
        if props.modAirFilter ~= nil then
            SetVehicleMod(vehicle, 40, props.modAirFilter, false)
        end
        if props.modStruts ~= nil then
            SetVehicleMod(vehicle, 41, props.modStruts, false)
        end
        if props.modArchCover ~= nil then
            SetVehicleMod(vehicle, 42, props.modArchCover, false)
        end
        if props.modAerials ~= nil then
            SetVehicleMod(vehicle, 43, props.modAerials, false)
        end
        if props.modTrimB ~= nil then
            SetVehicleMod(vehicle, 44, props.modTrimB, false)
        end
        if props.modTank ~= nil then
            SetVehicleMod(vehicle, 45, props.modTank, false)
        end
        if props.modWindows ~= nil then
            SetVehicleMod(vehicle, 46, props.modWindows, false)
        end
        if props.modLivery ~= nil then
            SetVehicleMod(vehicle, 48, props.modLivery, false)
            SetVehicleLivery(vehicle, props.modLivery)
        end
        if props.windowsBroken ~= nil then
            for k, v in pairs(props.windowsBroken) do
                if v then
                    RemoveVehicleWindow(vehicle, tonumber(k))
                end
            end
        end
        if props.doorsBroken ~= nil then
            for k, v in pairs(props.doorsBroken) do
                if v then
                    SetVehicleDoorBroken(vehicle, tonumber(k), true)
                end
            end
        end
        if props.tyreBurst ~= nil then
            for k, v in pairs(props.tyreBurst) do
                if v then
                    SetVehicleTyreBurst(vehicle, tonumber(k), true, 1000.0)
                end
            end
        end
    end
end

function Round(value, numDecimalPlaces)
    if not numDecimalPlaces then return math.floor(value + 0.5) end
    local power = 10 ^ numDecimalPlaces
    return math.floor((value * power) + 0.5) / (power)
end