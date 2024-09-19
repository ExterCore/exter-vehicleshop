Config = {
    ServerCallbacks = {}, -- Don't edit or change
    AutoDatabaseCreator = false, -- If you are starting the script for the first time, make this true and restart the script, after restarting, make this false otherwise you will get an error.
    TestDriveTime = 30000, -- Seconds 600000
    TeleportBackWhenTestFinishes = true, -- If false destroys the test vehicle's engine and sets it unusable again
    WarpPedToTestVehicle = true, -- If you activate it, a player will be automatically teleported to the driver's seat of a test vehicle when they pick it up.
    SalesShare = 10, -- The player making the sale receives a share of the entered amount from the sale.
    EnableSocietyAccount = false, -- Activate/deactivate management bank accounts
    UseCustomImages = true, -- If false, a default car photo is shown instead of the one without a photo, if true, the photo from the html/customcars file is used.
    PriceCurrency = "$",
    Permissions = {"admin", "staff", "god"},
    Permissions2 = {"license:ed22ea92722d717ee15047301e65c4b908ccfcac", "license:xxx", "citizenid:URX62787"},
    VehicleShops = {
        {   
            Name = "pdm", -- or use all to see all vehicles in showroom
            ClearAreaOfNPCVehicles = true, -- If true script deletes default spawned NPC cars around the vehicle shop
            Management = {
                Enable = false,
                Job = "cardealer"
            },
            EnableStocks = false,
            AllowedCategories = {
                -- AddStockPrice removes money from society account after stock adding 
                ["sedans"] = {AddStockPrice = 1000},
                ["sportsclassics"] = {AddStockPrice = 1000},
                ["offroad"] = {AddStockPrice = 1000},
                ["cycles"] = {AddStockPrice = 1000},
                ["motorcycles"] = {AddStockPrice = 1000},
                ["vans"] = {AddStockPrice = 1000},
                ["super"] = {AddStockPrice = 1000},
                ["sports"] = {AddStockPrice = 1000},
                ["coupes"] = {AddStockPrice = 1000},
                ["compacts"] = {AddStockPrice = 1000},
                ["suvs"] = {AddStockPrice = 1000},
                ["muscle"] = {AddStockPrice = 1000},
                ["AddStockAllVehicles"] = {AddStockPrice = 100000},
            },
            Coords = {
                ShowroomVehicles = vector4(-47.68, -1094.61, 26.42, 133.71),
                BoughtVehicles = vector4(-32.21, -1091.13, 26.18, 336.48),
                TestVehicles = vector4(-32.21, -1091.13, 26.18, 336.48),
                SellingPoint = vector3(-30.82, -1106.09, 26.42)
            },
            Ped = {
                Enable = true,
                Coords = vector4(-57.13, -1099.05, 26.42, 22.75),
                Model = "a_m_y_hasjew_01",
                animDict = "amb@world_human_hang_out_street@female_arms_crossed@idle_a",
                animName = "idle_a"
            },
            ShowroomVehiclesLoadDistance = 40,
            ShowroomVehicles = {
                {coords = vector4(-50.67, -1116.44, 25.97, 2.26)},
                {coords = vector4(-53.56, -1116.84, 25.79, 3.36)},
                {coords = vector4(-56.3, -1116.97, 25.66, 1.13)},
                {coords = vector4(-59.18, -1116.89, 26.17, 1.44)},
                {coords = vector4(-61.83, -1117.06, 25.84, 2.23)}
            },
            Blip = { -- https://docs.fivem.net/docs/game-references/blips/
                Enable = true,
                coords = vector3(-57.13, -1099.05, 26.42),
                sprite = 820,
                color = 0,
                scale = 0.5,
                text = "Dealership"
            },
            Interaction = {
                Target = {
                    Enable = false,
                    Distance = 2.0,
                    Label = "Open Showroom",
                    Icon = "fa-solid fa-car",
                    Label2 = "Open Management",
                    Icon2 = "fa-solid fa-car"
                },
                Text = {
                    Enable = true,
                    Distance = 3.0,
                    Label = "[E] Open Showroom | [G] Open Management"
                },
                DrawText = {
                    Enable = false,
                    Distance = 3.0,
                    Show = function()
                        exports["qb-core"]:DrawText("Open Showroom/Open Management", "E/G")
                    end,
                    Hide = function()
                        exports["qb-core"]:HideText()
                    end
                }
            }
        }
    }
}

-- HUD Function
function Config.HUD(state)
    TriggerEvent('esx:toggleHUD', state)
    --TriggerEvent('ps-hud:display', state)
end

-- Management Function
function Config.AddManagementMoney(job, amount)
    exports['qb-management']:AddMoney(job, amount)
end

function Config.RemoveMoneyManagement(job, amount)
    exports['qb-banking']:RemoveMoney(job, amount)
end