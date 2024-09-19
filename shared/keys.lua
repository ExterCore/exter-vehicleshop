Keys = {
    {
        ResourceName = "esx_vehiclelock",
        GiveKey = function(vehicle, plate) return exports['esx_vehiclelock']:giveKeys(plate) end
    },
    {
        ResourceName = "gc-key",
        GiveKey = function(vehicle, plate) return exports['gc-key']:giveKeys(plate) end
    },
    {
        ResourceName = "VehicleKeys",
        GiveKey = function(vehicle, plate) return exports['VehicleKeys']:giveKeys(plate) end
    },
    {
        ResourceName = "esx_advancedkeys",
        GiveKey = function(vehicle, plate) return exports['esx_advancedkeys']:giveKeys(plate) end
    },
    {
        ResourceName = "t1ger_keys",
        GiveKey = function(vehicle, plate) return exports['t1ger_keys']:giveKeys(plate) end
    },
    {
        ResourceName = "qb-vehiclekeys",
        GiveKey = function(vehicle, plate) return TriggerEvent('vehiclekeys:client:SetOwner', plate) end
    },
    {
        ResourceName = "qs-vehiclekeys",
        GiveKey = function(vehicle, plate)
            exports['qs-vehiclekeys']:GiveKeys(plate, GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)), true)
            exports['qs-vehiclekeys']:GiveKeysAuto()
        end
    }
}