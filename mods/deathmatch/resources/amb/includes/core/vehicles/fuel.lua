-- ================================
-- AMB Vehicle System Server-side Support
-- Manages fuel, vehicle health, and speedometer data
-- ================================

-- Vehicle events
addEvent("onVehicleFuelUpdate", true)
addEvent("onVehicleFuelRequest", true)
addEvent("onPlayerBuyFuel", true)

-- Vehicle fuel storage
local vehicleFuelData = {}

-- Default fuel capacity by vehicle type
local vehicleFuelCapacity = {
    [400] = 60,  -- Landstalker
    [401] = 50,  -- Bravura
    [402] = 40,  -- Buffalo
    [403] = 80,  -- Linerunner
    [404] = 35,  -- Perenniel
    [405] = 45,  -- Sentinel
    [406] = 20,  -- Dumper
    [407] = 20,  -- Firetruck
    [408] = 50,  -- Trashmaster
    [409] = 50,  -- Stretch
    [410] = 35,  -- Manana
    [411] = 45,  -- Infernus
    [412] = 40,  -- Voodoo
    [413] = 35,  -- Pony
    [414] = 35,  -- Mule
    [415] = 40,  -- Cheetah
    [416] = 30,  -- Ambulance
    [417] = 100, -- Leviathan
    [418] = 35,  -- Moonbeam
    [419] = 40,  -- Esperanto
    [420] = 35,  -- Taxi
    [421] = 40,  -- Washington
    [422] = 25,  -- Bobcat
    [423] = 20,  -- Mr Whoopee
    [424] = 25,  -- BF Injection
    [425] = 100, -- Hunter
    [426] = 35,  -- Premier
    [427] = 30,  -- Enforcer
    [428] = 35,  -- Securicar
    [429] = 40,  -- Banshee
    [430] = 100, -- Predator
    [431] = 100, -- Bus
    [432] = 100, -- Rhino
    [433] = 30,  -- Barracks
    [434] = 25,  -- Hotknife
    [435] = 100, -- Trailer 1
    [436] = 35,  -- Previon
    [437] = 100, -- Coach
    [438] = 35,  -- Cabbie
    [439] = 40,  -- Stallion
    [440] = 35,  -- Rumpo
    [441] = 10,  -- RC Bandit
    [442] = 35,  -- Romero
    [443] = 100, -- Packer
    [444] = 20,  -- Monster
    [445] = 35,  -- Admiral
    [446] = 10,  -- Squalo
    [447] = 100, -- Seasparrow
    [448] = 10,  -- Pizzaboy
    [449] = 20,  -- Tram
    [450] = 100, -- Trailer 2
    [451] = 40,  -- Turismo
    [452] = 10,  -- Speeder
    [453] = 10,  -- Reefer
    [454] = 100, -- Tropic
    [455] = 100, -- Flatbed
    [456] = 30,  -- Yankee
    [457] = 10,  -- Caddy
    [458] = 35,  -- Solair
    [459] = 35,  -- Berkley's RC Van
    [460] = 100, -- Skimmer
    [461] = 10,  -- PCJ-600
    [462] = 8,   -- Faggio
    [463] = 10,  -- Freeway
    [464] = 10,  -- RC Baron
    [465] = 10,  -- RC Raider
    [466] = 35,  -- Glendale
    [467] = 35,  -- Oceanic
    [468] = 10,  -- Sanchez
    [469] = 100, -- Sparrow
    [470] = 35,  -- Patriot
    [471] = 8,   -- Quad
    [472] = 100, -- Coastguard
    [473] = 100, -- Dinghy
    [474] = 35,  -- Hermes
    [475] = 35,  -- Sabre
    [476] = 100, -- Rustler
    [477] = 40,  -- ZR-350
    [478] = 35,  -- Walton
    [479] = 35,  -- Regina
    [480] = 35,  -- Comet
    [481] = 5,   -- BMX
    [482] = 35,  -- Burrito
    [483] = 35,  -- Camper
    [484] = 100, -- Marquis
    [485] = 25,  -- Baggage
    [486] = 100, -- Dozer
    [487] = 100, -- Maverick
    [488] = 100, -- News Chopper
    [489] = 8,   -- Rancher
    [490] = 35,  -- FBI Rancher
    [491] = 35,  -- Virgo
    [492] = 35,  -- Greenwood
    [493] = 100, -- Jetmax
    [494] = 35,  -- Hotring
    [495] = 25,  -- Sandking
    [496] = 35,  -- Blista Compact
    [497] = 100, -- Police Maverick
    [498] = 25,  -- Boxville
    [499] = 35,  -- Benson
    [500] = 35,  -- Mesa
    [501] = 10,  -- RC Goblin
    [502] = 35,  -- Hotring Racer A
    [503] = 35,  -- Hotring Racer B
    [504] = 35,  -- Bloodring Banger
    [505] = 25,  -- Rancher
    [506] = 35,  -- Super GT
    [507] = 35,  -- Elegant
    [508] = 35,  -- Journey
    [509] = 8,   -- Bike
    [510] = 5,   -- Mountain Bike
    [511] = 100, -- Beagle
    [512] = 100, -- Cropdust
    [513] = 100, -- Stunt
    [514] = 100, -- Tanker
    [515] = 100, -- RoadTrain
    [516] = 35,  -- Nebula
    [517] = 35,  -- Majestic
    [518] = 35,  -- Buccaneer
    [519] = 100, -- Shamal
    [520] = 100, -- Hydra
    [521] = 10,  -- FCR-900
    [522] = 10,  -- NRG-500
    [523] = 10,  -- HPV1000
    [524] = 100, -- Cement Truck
    [525] = 100, -- Tow Truck
    [526] = 35,  -- Fortune
    [527] = 35,  -- Cadrona
    [528] = 25,  -- FBI Truck
    [529] = 35,  -- Willard
    [530] = 25,  -- Forklift
    [531] = 100, -- Tractor
    [532] = 100, -- Combine
    [533] = 35,  -- Feltzer
    [534] = 35,  -- Remington
    [535] = 35,  -- Slamvan
    [536] = 35,  -- Blade
    [537] = 100, -- Freight
    [538] = 100, -- Streak
    [539] = 35,  -- Vortex
    [540] = 35,  -- Vincent
    [541] = 35,  -- Bullet
    [542] = 35,  -- Clover
    [543] = 35,  -- Sadler
    [544] = 100, -- Firetruck LA
    [545] = 35,  -- Hustler
    [546] = 35,  -- Intruder
    [547] = 35,  -- Primo
    [548] = 100, -- Cargobob
    [549] = 35,  -- Tampa
    [550] = 35,  -- Sunrise
    [551] = 35,  -- Merit
    [552] = 35,  -- Utility
    [553] = 100, -- Nevada
    [554] = 35,  -- Yosemite
    [555] = 35,  -- Windsor
    [556] = 20,  -- Monster A
    [557] = 20,  -- Monster B
    [558] = 35,  -- Uranus
    [559] = 35,  -- Jester
    [560] = 35,  -- Sultan
    [561] = 35,  -- Stratum
    [562] = 35,  -- Elegy
    [563] = 100, -- Raindance
    [564] = 10,  -- RC Tiger
    [565] = 35,  -- Flash
    [566] = 35,  -- Tahoma
    [567] = 35,  -- Savanna
    [568] = 25,  -- Bandito
    [569] = 100, -- Freight Flat
    [570] = 100, -- Streak Carriage
    [571] = 25,  -- Kart
    [572] = 25,  -- Mower
    [573] = 25,  -- Duneride
    [574] = 25,  -- Sweeper
    [575] = 35,  -- Broadway
    [576] = 35,  -- Tornado
    [577] = 100, -- AT-400
    [578] = 25,  -- DFT-30
    [579] = 35,  -- Huntley
    [580] = 35,  -- Stafford
    [581] = 10,  -- BF-400
    [582] = 35,  -- Newsvan
    [583] = 25,  -- Tug
    [584] = 100, -- Petrol Trailer
    [585] = 35,  -- Emperor
    [586] = 10,  -- Wayfarer
    [587] = 35,  -- Euros
    [588] = 35,  -- Hotdog
    [589] = 35,  -- Club
    [590] = 100, -- Freight Box
    [591] = 100, -- Trailer 3
    [592] = 100, -- Andromada
    [593] = 100, -- Dodo
    [594] = 10,  -- RC Cam
    [595] = 100, -- Launch
    [596] = 30,  -- Police Car (LSPD)
    [597] = 30,  -- Police Car (SFPD)
    [598] = 30,  -- Police Car (LVPD)
    [599] = 30,  -- Police Ranger
    [600] = 35,  -- Picador
    [601] = 30,  -- S.W.A.T. Van
    [602] = 35,  -- Alpha
    [603] = 35,  -- Phoenix
    [604] = 35,  -- Glendale
    [605] = 35,  -- Sadler
    [606] = 25,  -- Luggage Trailer A
    [607] = 25,  -- Luggage Trailer B
    [608] = 25,  -- Stair Trailer
    [609] = 25,  -- Boxville
    [610] = 100, -- Farm Plow
    [611] = 100  -- Utility Trailer
}

-- Initialize vehicle fuel on creation
addEventHandler("onVehicleSpawn", root, function()
    local vehicle = source
    local model = getElementModel(vehicle)
    local maxFuel = vehicleFuelCapacity[model] or 50
    
    -- Set full fuel on spawn
    vehicleFuelData[vehicle] = {
        fuel = maxFuel,
        maxFuel = maxFuel,
        consumption = 0.1 -- Default consumption rate
    }
    
    setElementData(vehicle, "fuel", maxFuel)
    setElementData(vehicle, "maxFuel", maxFuel)
end)

-- Handle fuel updates from client
addEventHandler("onVehicleFuelUpdate", root, function(newFuelAmount)
    local vehicle = getPedOccupiedVehicle(source)
    if not vehicle then return end
    
    if not vehicleFuelData[vehicle] then
        local model = getElementModel(vehicle)
        local maxFuel = vehicleFuelCapacity[model] or 50
        vehicleFuelData[vehicle] = {
            fuel = maxFuel,
            maxFuel = maxFuel,
            consumption = 0.1
        }
    end
    
    -- Validate fuel amount
    local maxFuel = vehicleFuelData[vehicle].maxFuel
    newFuelAmount = math.max(0, math.min(newFuelAmount, maxFuel))
    
    vehicleFuelData[vehicle].fuel = newFuelAmount
    setElementData(vehicle, "fuel", newFuelAmount)
end)

-- Handle fuel requests
addEventHandler("onVehicleFuelRequest", root, function()
    local player = source
    local vehicle = getPedOccupiedVehicle(player)
    
    if not vehicle then
        triggerClientEvent(player, "onReceiveFuelData", player, 0, 50)
        return
    end
    
    if not vehicleFuelData[vehicle] then
        local model = getElementModel(vehicle)
        local maxFuel = vehicleFuelCapacity[model] or 50
        vehicleFuelData[vehicle] = {
            fuel = maxFuel,
            maxFuel = maxFuel,
            consumption = 0.1
        }
        setElementData(vehicle, "fuel", maxFuel)
        setElementData(vehicle, "maxFuel", maxFuel)
    end
    
    local fuelData = vehicleFuelData[vehicle]
    triggerClientEvent(player, "onReceiveFuelData", player, fuelData.fuel, fuelData.maxFuel)
end)

-- Handle fuel purchase at gas stations
addEventHandler("onPlayerBuyFuel", root, function(amount)
    local player = source
    local vehicle = getPedOccupiedVehicle(player)
    
    if not vehicle then
        outputChatBox("❌ You must be in a vehicle to buy fuel", player, 255, 100, 100)
        return
    end
    
    -- Check if near gas station
    local x, y, z = getElementPosition(player)
    local nearGasStation = false
    
    -- Gas station locations (simplified check)
    local gasStations = {
        {x = 2202.2, y = -1948.9, z = 13.5}, -- Grove Street
        {x = -1471.0, y = -79.8, z = 14.1},  -- SF Airport
        {x = 1595.8, y = 2199.7, z = 10.8},  -- LV Strip
        {x = 1004.0, y = -939.3, z = 42.2},  -- Temple
        {x = -90.5, y = -1169.4, z = 2.4},   -- Flint County
        {x = -1609.8, y = -2718.2, z = 48.5}, -- SF Docks
        {x = 2113.7, y = 920.1, z = 10.8}    -- LV North
    }
    
    for _, station in ipairs(gasStations) do
        local distance = getDistanceBetweenPoints3D(x, y, z, station.x, station.y, station.z)
        if distance < 15 then
            nearGasStation = true
            break
        end
    end
    
    if not nearGasStation then
        outputChatBox("❌ You must be near a gas station to buy fuel", player, 255, 100, 100)
        return
    end
    
    if not vehicleFuelData[vehicle] then
        local model = getElementModel(vehicle)
        local maxFuel = vehicleFuelCapacity[model] or 50
        vehicleFuelData[vehicle] = {
            fuel = 0,
            maxFuel = maxFuel,
            consumption = 0.1
        }
    end
    
    local fuelData = vehicleFuelData[vehicle]
    local currentFuel = fuelData.fuel
    local maxFuel = fuelData.maxFuel
    
    -- Calculate how much fuel can be added
    local spaceForFuel = maxFuel - currentFuel
    local fuelToBuy = math.min(amount, spaceForFuel)
    
    if fuelToBuy <= 0 then
        outputChatBox("⛽ Your tank is already full", player, 255, 255, 100)
        return
    end
    
    -- Calculate cost (example: $2 per liter)
    local cost = math.ceil(fuelToBuy * 2)
    local playerMoney = getPlayerMoney(player)
    
    if playerMoney < cost then
        outputChatBox("❌ You don't have enough money ($" .. cost .. " needed)", player, 255, 100, 100)
        return
    end
    
    -- Process purchase
    takePlayerMoney(player, cost)
    fuelData.fuel = currentFuel + fuelToBuy
    setElementData(vehicle, "fuel", fuelData.fuel)
    
    outputChatBox("⛽ Purchased " .. math.floor(fuelToBuy) .. "L fuel for $" .. cost, player, 100, 255, 100)
    
    -- Update client
    triggerClientEvent(player, "onReceiveFuelData", player, fuelData.fuel, fuelData.maxFuel)
end)

-- Command to check fuel
addCommandHandler("fuel", function(player)
    local vehicle = getPedOccupiedVehicle(player)
    
    if not vehicle then
        outputChatBox("❌ You must be in a vehicle", player, 255, 100, 100)
        return
    end
    
    if not vehicleFuelData[vehicle] then
        local model = getElementModel(vehicle)
        local maxFuel = vehicleFuelCapacity[model] or 50
        vehicleFuelData[vehicle] = {
            fuel = maxFuel,
            maxFuel = maxFuel,
            consumption = 0.1
        }
        setElementData(vehicle, "fuel", maxFuel)
        setElementData(vehicle, "maxFuel", maxFuel)
    end
    
    local fuelData = vehicleFuelData[vehicle]
    local fuelPercent = math.floor((fuelData.fuel / fuelData.maxFuel) * 100)
    
    outputChatBox("⛽ Fuel: " .. math.floor(fuelData.fuel) .. "L / " .. fuelData.maxFuel .. "L (" .. fuelPercent .. "%)", player, 100, 255, 100)
end)

-- Command to refuel (cheat for testing)
addCommandHandler("refuel", function(player)
    if not isPlayerAdmin(player, 1) then
        outputChatBox("❌ Admin only command", player, 255, 100, 100)
        return
    end
    
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox("❌ You must be in a vehicle", player, 255, 100, 100)
        return
    end
    
    if not vehicleFuelData[vehicle] then
        local model = getElementModel(vehicle)
        local maxFuel = vehicleFuelCapacity[model] or 50
        vehicleFuelData[vehicle] = {
            fuel = maxFuel,
            maxFuel = maxFuel,
            consumption = 0.1
        }
    end
    
    vehicleFuelData[vehicle].fuel = vehicleFuelData[vehicle].maxFuel
    setElementData(vehicle, "fuel", vehicleFuelData[vehicle].fuel)
    
    outputChatBox("⛽ Vehicle refueled", player, 100, 255, 100)
    triggerClientEvent(player, "onReceiveFuelData", player, vehicleFuelData[vehicle].fuel, vehicleFuelData[vehicle].maxFuel)
end)

-- Clean up vehicle data on destroy
addEventHandler("onVehicleDestroy", root, function()
    vehicleFuelData[source] = nil
end)

-- Fuel consumption timer
setTimer(function()
    for vehicle, data in pairs(vehicleFuelData) do
        if isElement(vehicle) then
            local driver = getVehicleOccupant(vehicle, 0)
            if driver and not isPedDead(driver) then
                local speed = getElementSpeed(vehicle)
                
                if speed > 5 then -- Only consume fuel when moving
                    local consumption = data.consumption * (speed / 100) -- Scale with speed
                    data.fuel = math.max(0, data.fuel - consumption)
                    setElementData(vehicle, "fuel", data.fuel)
                    
                    -- Stop engine if out of fuel
                    if data.fuel <= 0 then
                        setVehicleEngineState(vehicle, false)
                        if getElementData(vehicle, "fuelWarning") ~= true then
                            outputChatBox("⛽ Vehicle out of fuel!", driver, 255, 100, 100)
                            setElementData(vehicle, "fuelWarning", true)
                        end
                    else
                        setElementData(vehicle, "fuelWarning", false)
                    end
                end
            end
        else
            vehicleFuelData[vehicle] = nil
        end
    end
end, 1000, 0) -- Check every second

-- Helper function to get element speed
function getElementSpeed(element)
    if not isElement(element) then return 0 end
    local vx, vy, vz = getElementVelocity(element)
    return math.sqrt(vx^2 + vy^2 + vz^2) * 180 -- Convert to km/h roughly
end

outputDebugString("[VEHICLE] Vehicle system loaded with fuel management")
