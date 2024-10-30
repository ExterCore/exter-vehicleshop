Fuels = {
    {
        ResourceName = "LegacyFuel",
        SetFuel = function(vehicle, fuel) return exports["LegacyFuel"]:SetFuel(vehicle, fuel) end
    },
    {
        ResourceName = "cdn-fuel",
        SetFuel = function(vehicle, fuel) return exports["cdn-fuel"]:SetFuel(vehicle, fuel) end
    },
    {
        ResourceName = "ox_fuel",
        SetFuel = function(vehicle, fuel) return exports["ox_fuel"]:SetFuel(vehicle, fuel) end
    }
}
