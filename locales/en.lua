local Translations = {
    categories = {
        openwheel = "Open Wheels",
        sedans = "Sedans",
        sportsclassics = "Sports Classics",
        commercial = "Commercial",
        offroad = "Off-Road",
        cycles = "Cycles",
        boats = "Boats",
        military = "Military",
        motorcycles = "Motorcycles",
        industrial = "Industrial",
        helicopters = "Helicopters",
        vans = "Vans",
        super = "Super Sports",
        sports = "Sports",
        coupes = "Coupes",
        emergency = "Emergency",
        muscle = "Muscles",
        compacts = "Compacts",
        utility = "Utility",
        suvs = "SUVs",
        service = "Services",
        planes = "Planes"
    },
    notifications = {
        ask_an_employee = "You need ask an employee to purchase this vehicle.",
        spawn_point_not_clear = "Spawn point isn't clear.",
        already_have_test_drive_in_progress = "You already have a test drive in progress.",
        test_period_is_over = "Your test period is over.",
        request_timed_out = "Request timed out.",
        no_players_nearby = "No players nearby.",
        request_accepted = "Request accepted.",
        request_declined = "Request declined.",
        added_stock_num_to_all_vehicles = "Successfully added %{addStockNum} stock to all vehicles.",
        added_stock_num_to_model = "Successfully added %{addStockNum} stock to %{model}.",
        earned_money = "You earned $%{money} - %{vehicle}.",
        not_enough_money = "You don't have enough money.",
        no_access = "You don't have access here."
    },
    commands = {
        add_vehicle_stock = "Add Stock To Vehicle"
    },
    general = {
        selling_point = "Selling Point",
        ask_an_employee = "Ask an employee",
        send_request = "Send Request",
        give_back_test_vehicle = "Give Back Test Vehicle"
    }
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})