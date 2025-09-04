-- ================================
-- AMB MTA:SA - Jobs System
-- Various job types and employment
-- ================================
-- Job definitions
local jobs = {
    ["Trucker"] = {
        name = "Trucker",
        description = "Transport goods across San Andreas",
        salary = 150,
        vehicles = {414, 515, 403}, -- Mule, Roadtrain, Linerunner
        spawn = {-76.6, -1149.5, 1.1},
        routes = {{
            name = "LS to SF",
            start = {-76.6, -1149.5, 1.1},
            finish = {-1997.7, 240.5, 34.8},
            distance = 500,
            pay = 3000
        }, {
            name = "SF to LV",
            start = {-1997.7, 240.5, 34.8},
            finish = {970.1, 2072.8, 10.8},
            distance = 600,
            pay = 3500
        }, {
            name = "LV to LS",
            start = {970.1, 2072.8, 10.8},
            finish = {-76.6, -1149.5, 1.1},
            distance = 450,
            pay = 2800
        }}
    },
    ["Taxi Driver"] = {
        name = "Taxi Driver",
        description = "Transport passengers around the city",
        salary = 120,
        vehicles = {420, 438}, -- Taxi, Cabbie
        spawn = {1744.1, -1862.8, 13.6},
        baseRate = 50,
        perMeter = 2
    },
    ["Bus Driver"] = {
        name = "Bus Driver",
        description = "Drive city bus routes",
        salary = 130,
        vehicles = {431}, -- Bus
        spawn = {1809.8, -1905.4, 13.4},
        routes = {{
            name = "LS Route 1",
            stops = {{1809.8, -1905.4, 13.4, "Bus Depot"}, {1440.3, -1635.1, 13.4, "Commerce"},
                     {1158.7, -1308.9, 13.8, "Pershing Square"}, {1464.9, -1010.3, 23.9, "City Hall"},
                     {1809.8, -1905.4, 13.4, "Bus Depot"}},
            pay = 800
        }}
    },
    ["Pilot"] = {
        name = "Pilot",
        description = "Fly passengers and cargo",
        salary = 200,
        vehicles = {592, 577, 511}, -- Andromada, AT-400, Beagle
        spawn = {1644.8, -2335.7, 13.5},
        routes = {{
            name = "LS to SF",
            start = {1644.8, -2335.7, 13.5},
            finish = {-1422.8, -286.5, 14.1},
            pay = 5000
        }, {
            name = "SF to LV",
            start = {-1422.8, -286.5, 14.1},
            finish = {1444.9, 1481.7, 10.8},
            pay = 5500
        }, {
            name = "LV to LS",
            start = {1444.9, 1481.7, 10.8},
            finish = {1644.8, -2335.7, 13.5},
            pay = 4800
        }}
    },
    ["Police Officer"] = {
        name = "Police Officer",
        description = "Protect and serve the community",
        salary = 180,
        vehicles = {596, 597, 598, 599, 427, 523},
        spawn = {1554.8, -1675.6, 16.2},
        weapons = {3, 22, 23, 24, 25, 29, 31}
    },
    ["Paramedic"] = {
        name = "Paramedic",
        description = "Provide emergency medical services",
        salary = 160,
        vehicles = {416}, -- Ambulance
        spawn = {1172.0, -1323.4, 15.4},
        equipment = {45} -- Fire extinguisher (as medical kit)
    },
    ["Mechanic"] = {
        name = "Mechanic",
        description = "Repair and maintain vehicles",
        salary = 140,
        vehicles = {525, 552}, -- Tow Truck, Utility Van
        spawn = {-1935.3, 258.2, 41.0},
        tools = {14, 15} -- Flower (toolbox), Cane (wrench)
    },
    ["Pizza Delivery"] = {
        name = "Pizza Delivery",
        description = "Deliver hot pizzas to customers",
        salary = 100,
        vehicles = {448, 461, 462}, -- Pizzaboy, PCJ-600, Faggio
        spawn = {2105.5, -1806.4, 13.6},
        baseDeliveryPay = 200
    },
    ["Farmer"] = {
        name = "Farmer",
        description = "Grow and harvest crops",
        salary = 110,
        vehicles = {531, 532}, -- Tractor, Combine
        spawn = {-368.8, -1416.6, 25.7},
        crops = {"Wheat", "Corn", "Potatoes", "Tomatoes"}
    },
    ["Fisher"] = {
        name = "Fisher",
        description = "Catch fish from the ocean",
        salary = 90,
        vehicles = {453, 454}, -- Reefer, Tropic
        spawn = {-2654.9, 1413.1, 7.0},
        equipment = {18}, -- Fishing rod (dildo model)
        fishTypes = {{
            name = "Tuna",
            price = 150
        }, {
            name = "Salmon",
            price = 120
        }, {
            name = "Bass",
            price = 80
        }, {
            name = "Sardine",
            price = 50
        }}
    }
}

-- Player job data
local playerJobs = {}
local activeJobs = {}

-- Get player's current job
function getPlayerJob(player)
    return getElementData(player, "job")
end

-- Set player's job
function setPlayerJob(player, jobName)
    if not jobs[jobName] then
        return false
    end

    local oldJob = getPlayerJob(player)
    if oldJob then
        quitJob(player)
    end

    setElementData(player, "job", jobName)
    setElementData(player, "jobExp", 0)
    setElementData(player, "jobLevel", 1)

    playerJobs[getPlayerName(player)] = {
        job = jobName,
        startTime = getRealTime().timestamp,
        experience = 0,
        level = 1
    }

    return true
end

-- Quit current job
function quitJob(player)
    local job = getPlayerJob(player)
    if not job then
        return false
    end

    setElementData(player, "job", nil)
    setElementData(player, "jobExp", nil)
    setElementData(player, "jobLevel", nil)

    playerJobs[getPlayerName(player)] = nil

    -- Stop any active job activities
    local playerName = getPlayerName(player)
    if activeJobs[playerName] then
        activeJobs[playerName] = nil
    end

    return true
end

-- Add job experience
function addJobExperience(player, amount)
    local currentExp = getElementData(player, "jobExp") or 0
    local currentLevel = getElementData(player, "jobLevel") or 1

    currentExp = currentExp + amount
    setElementData(player, "jobExp", currentExp)

    -- Check for level up (every 1000 exp)
    local newLevel = math.floor(currentExp / 1000) + 1
    if newLevel > currentLevel then
        setElementData(player, "jobLevel", newLevel)
        -- Level bonus
        local bonus = newLevel * 500
        givePlayerMoney(player, bonus)
        outputChatBox(COLOR_YELLOW .. "Level bonus: $" .. formatMoney(bonus), player)
    end
end

-- Job chat command
addCommandHandler("j", function(player, cmd, ...)
    local playerData = getElementData(player, "playerData") or {}

    if not playerData.job or playerData.job == "" then
        outputChatBox("❌ Bạn không có công việc.", player, 255, 100, 100)
        return
    end

    local message = table.concat({...}, " ")
    if not message or message == "" then
        outputChatBox("Sử dụng: /j [tin nhắn]", player, 255, 255, 255)
        return
    end

    local playerName = getPlayerName(player)
    local jobName = playerData.job

    -- Send to all job members
    for _, targetPlayer in ipairs(getElementsByType("player")) do
        local targetData = getElementData(targetPlayer, "playerData")
        if targetData and targetData.job == jobName then
            outputChatBox(string.format("👷 [%s] %s: %s", jobName, playerName, message), targetPlayer, 255, 255, 100)
        end
    end
end)

-- Taxi driver commands
addCommandHandler("taxi", function(player, cmd, action, playerIdOrName)
    local playerData = getElementData(player, "playerData") or {}

    if playerData.job ~= "Taxi Driver" then
        outputChatBox("❌ Bạn không phải là tài xế taxi.", player, 255, 100, 100)
        return
    end

    if not action then
        outputChatBox("Sử dụng: /taxi [accept/fare/help]", player, 255, 255, 255)
        return
    end

    if action == "accept" then
        if not playerIdOrName then
            outputChatBox("Sử dụng: /taxi accept [player_id]", player, 255, 255, 255)
            return
        end

        local targetPlayer = getPlayerFromNameOrId(playerIdOrName)
        if not targetPlayer then
            outputChatBox("❌ Không tìm thấy người chơi.", player, 255, 100, 100)
            return
        end

        local targetData = getElementData(targetPlayer, "playerData") or {}
        if not targetData.taxiRequest then
            outputChatBox("❌ Người chơi khôn gọi taxi.", player, 255, 100, 100)
            return
        end

        -- Accept taxi request
        targetData.taxiDriver = player
        playerData.taxiCustomer = targetPlayer
        setElementData(player, "playerData", playerData)
        setElementData(targetPlayer, "playerData", targetData)

        outputChatBox(string.format("✅ Đã nhận taxi request từ %s.", getPlayerName(targetPlayer)), player, 0,
            255, 0)
        outputChatBox(string.format("🚕 Taxi driver %s đã nhận request của bạn.", getPlayerName(player)),
            targetPlayer, 255, 255, 100)

    elseif action == "fare" then
        local customer = playerData.taxiCustomer
        if not customer or not isElement(customer) then
            outputChatBox("❌ Bạn không có khách hàn nào.", player, 255, 100, 100)
            return
        end

        local fare = math.random(50, 200)
        local customerData = getElementData(customer, "playerData") or {}

        if (customerData.money or 0) < fare then
            outputChatBox("❌ Khách hàng không có đủ tiền.", player, 255, 100, 100)
            return
        end

        -- Transfer money
        customerData.money = (customerData.money or 0) - fare
        playerData.money = (playerData.money or 0) + fare

        setElementData(player, "playerData", playerData)
        setElementData(customer, "playerData", customerData)

        outputChatBox(string.format("💰 Đã nhận $%d từ khách hàng.", fare), player, 0, 255, 0)
        outputChatBox(string.format("💰 Đã trả $%d cho taxi driver.", fare), customer, 255, 255, 100)

        -- Clear taxi relationship
        playerData.taxiCustomer = nil
        customerData.taxiDriver = nil
        setElementData(player, "playerData", playerData)
        setElementData(customer, "playerData", customerData)
    end
end)

-- Call taxi command
addCommandHandler("calltaxi", function(player)
    local playerData = getElementData(player, "playerData") or {}

    if playerData.taxiRequest then
        outputChatBox("❌ Bạn đã gọi taxi rồi.", player, 255, 100, 100)
        return
    end

    playerData.taxiRequest = true
    setElementData(player, "playerData", playerData)

    -- Notify all taxi drivers
    local taxiDrivers = 0
    for _, taxiDriver in ipairs(getElementsByType("player")) do
        local driverData = getElementData(taxiDriver, "playerData")
        if driverData and driverData.job == "Taxi Driver" then
            outputChatBox(string.format("🚕 TAXI REQUEST: %s (ID:%d) cần taxi!", getPlayerName(player),
                getElementData(player, "playerID") or 0), taxiDriver, 255, 255, 0)
            taxiDrivers = taxiDrivers + 1
        end
    end

    if taxiDrivers > 0 then
        outputChatBox(string.format("🚕 Đã gửi taxi request đến %d drivers.", taxiDrivers), player, 255, 255,
            100)
    else
        outputChatBox("❌ Không có taxi driver nào online.", player, 255, 100, 100)
        playerData.taxiRequest = false
        setElementData(player, "playerData", playerData)
    end
end)

-- Mechanic commands
addCommandHandler("repair", function(player, _, playerIdOrName)
    local playerData = getElementData(player, "playerData") or {}
    if playerData.job ~= "Mechanic" then
        outputChatBox("❌ Bạn không phải là thợ sửa xe.", player, 255, 0, 0)
        return
    end

    local targetPlayer = player
    if playerIdOrName then
        targetPlayer = getPlayerFromNameOrId(playerIdOrName)
    end

    if not targetPlayer then
        outputChatBox("❌ Người chơi không tìm thấy!", player, 255, 0, 0)
        return
    end

    local vehicle = getPedOccupiedVehicle(targetPlayer)
    if not vehicle then
        outputChatBox("❌ Bạn đang không ngồi trên xe.", player, 255, 0, 0)
        return
    end

    -- Check distance if repairing someone else
    if targetPlayer ~= player then
        local px, py, pz = getElementPosition(player)
        local vx, vy, vz = getElementPosition(vehicle)
        if getDistanceBetweenPoints3D(px, py, pz, vx, vy, vz) > 8 then
            outputChatBox("❌ Xe ở quá xa để sửa.", player, 255, 0, 0)
            return
        end
    end

    -- Repair vehicle
    fixVehicle(vehicle)
    setVehicleEngineState(vehicle, true)

    local fee = 200
    local targetData = getElementData(targetPlayer, "playerData") or {}

    if targetPlayer ~= player then
        if (targetData.money or 0) < fee then
            outputChatBox("❌ Khách hàng không đủ tiền ($200).", player, 255, 0, 0)
            return
        end
        -- Transfer money
        targetData.money = (targetData.money or 0) - fee
        playerData.money = (playerData.money or 0) + fee
        setElementData(targetPlayer, "playerData", targetData)
        setElementData(player, "playerData", playerData)
        outputChatBox("✅ Đã sửa xe cho " .. getPlayerName(targetPlayer) .. " và đã nhận $" .. fee .. ".",
            player, 0, 255, 0)
        outputChatBox("🔧 Xe của bạn đã được sửa bởi thợ sửa xe " .. getPlayerName(player) ..
                          " với giá $" .. fee .. ".", targetPlayer, 0, 255, 100)
    else
        outputChatBox("✅ Xe của bạn đã được sửa thành công.", player, 0, 255, 0)
    end
end)

-- Trucker commands
addCommandHandler("loadcargo", function(player)
    local playerData = getElementData(player, "playerData") or {}

    if playerData.job ~= "Trucker" then
        outputChatBox("❌ Bạn không phải là trucker.", player, 255, 100, 100)
        return
    end

    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox("❌ Bạn không ở trong xe.", player, 255, 100, 100)
        return
    end

    local vehModel = getElementModel(vehicle)
    local truckModels = {403, 414, 443, 515, 514}
    local isTruck = false
    for _, model in ipairs(truckModels) do
        if vehModel == model then
            isTruck = true
            break
        end
    end

    if not isTruck then
        outputChatBox("❌ Bạn cần xe truck để load cargo.", player, 255, 100, 100)
        return
    end

    if getElementData(vehicle, "cargo") then
        outputChatBox("❌ Xe đã có cargo rồi.", player, 255, 100, 100)
        return
    end

    -- Load cargo
    local cargoTypes = {"Food", "Electronics", "Clothing", "Furniture", "Medicine"}
    local cargoType = cargoTypes[math.random(#cargoTypes)]
    local cargoValue = math.random(500, 2000)

    setElementData(vehicle, "cargo", {
        type = cargoType,
        value = cargoValue,
        loaded = getRealTime().timestamp
    })

    outputChatBox(string.format("📦 Đã load cargo: %s (Value: $%d)", cargoType, cargoValue), player, 0, 255, 0)
end)

addCommandHandler("unloadcargo", function(player)
    local playerData = getElementData(player, "playerData") or {}

    if playerData.job ~= "Trucker" then
        outputChatBox("❌ Bạn không phải là trucker.", player, 255, 100, 100)
        return
    end

    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox("❌ Bạn không ở trong xe.", player, 255, 100, 100)
        return
    end

    local cargo = getElementData(vehicle, "cargo")
    if not cargo then
        outputChatBox("❌ Xe không có cargo.", player, 255, 100, 100)
        return
    end

    -- Pay for delivery
    local payment = cargo.value
    playerData.money = (playerData.money or 0) + payment
    setElementData(player, "playerData", playerData)

    -- Remove cargo
    removeElementData(vehicle, "cargo")

    outputChatBox(string.format("✅ Đã unload cargo và nhận $%d!", payment), player, 0, 255, 0)
end)

-- Medic commands
addCommandHandler("heal", function(player, cmd, playerIdOrName)
    local playerData = getElementData(player, "playerData") or {}

    if playerData.job ~= "Medic" then
        outputChatBox("❌ Bạn không phải là medic.", player, 255, 100, 100)
        return
    end

    local targetPlayer = player
    if playerIdOrName then
        targetPlayer = getPlayerFromNameOrId(playerIdOrName)
    end

    if not targetPlayer then
        outputChatBox("❌ Không tìm thấy người chơi.", player, 255, 100, 100)
        return
    end

    -- Check distance
    if targetPlayer ~= player then
        local px, py, pz = getElementPosition(player)
        local tx, ty, tz = getElementPosition(targetPlayer)
        if getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz) > 3 then
            outputChatBox("❌ Bạn quá xa để heal.", player, 255, 100, 100)
            return
        end
    end

    -- Heal player
    setElementHealth(targetPlayer, 100)

    local fee = 100
    local targetData = getElementData(targetPlayer, "playerData") or {}

    if targetPlayer ~= player then
        if (targetData.money or 0) < fee then
            outputChatBox("❌ Benh nhan khong co du tien ($100).", player, 255, 100, 100)
            return
        end

        -- Transfer money
        targetData.money = (targetData.money or 0) - fee
        playerData.money = (playerData.money or 0) + fee
        setElementData(targetPlayer, "playerData", targetData)
        setElementData(player, "playerData", playerData)

        outputChatBox(string.format("🏥 Da heal %s va nhan $%d.", getPlayerName(targetPlayer), fee), player, 0, 255, 0)
        outputChatBox(string.format("🏥 Ban da duoc medic %s heal voi gia $%d.", getPlayerName(player), fee),
            targetPlayer, 255, 255, 100)
    else
        outputChatBox("🏥 Da heal ban.", player, 0, 255, 0)
    end
end)

-- Pilot commands
addCommandHandler("takeoff", function(player, cmd, destination)
    local playerData = getElementData(player, "playerData") or {}

    if playerData.job ~= "Pilot" then
        outputChatBox("❌ Ban khong phai la pilot.", player, 255, 100, 100)
        return
    end

    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox("❌ Ban khong o trong aircraft.", player, 255, 100, 100)
        return
    end

    local vehModel = getElementModel(vehicle)
    local aircraftModels = {592, 577, 511, 512, 593, 520, 553, 476, 519, 460}
    local isAircraft = false
    for _, model in ipairs(aircraftModels) do
        if vehModel == model then
            isAircraft = true
            break
        end
    end

    if not isAircraft then
        outputChatBox("❌ Ban can aircraft de fly.", player, 255, 100, 100)
        return
    end

    if not destination then
        outputChatBox("Su dung: /fly [ls/sf/lv]", player, 255, 255, 255)
        return
    end

    local airports = {
        ls = {1958.2, -2181.7, 13.5, "Los Santos Airport"},
        sf = {-1212.9, -98.3, 14.1, "San Fierro Airport"},
        lv = {1685.0, 1447.8, 10.8, "Las Venturas Airport"}
    }

    local airport = airports[string.lower(destination)]
    if not airport then
        outputChatBox("❌ Invalid destination. Use: ls, sf, lv", player, 255, 100, 100)
        return
    end

    outputChatBox(string.format("✈️ Flying to %s...", airport[4]), player, 0, 255, 0)

    -- Add waypoint or auto-pilot logic here
    setElementData(vehicle, "flightDestination", {
        x = airport[1],
        y = airport[2],
        z = airport[3],
        name = airport[4]
    })
end)

outputDebugString("[AMB] Jobs system loaded - 13 commands")

-- Job command: /jobs
addCommandHandler("jobs", function(player)
    outputChatBox(COLOR_YELLOW .. "=== Available Jobs ===", player)
    local count = 0
    for jobName, jobData in pairs(jobs) do
        count = count + 1
        outputChatBox(COLOR_WHITE .. count .. ". " .. jobName .. " - " .. jobData.description .. " (Salary: $" ..
                          jobData.salary .. "/hour)", player)
    end
    outputChatBox(COLOR_GRAY .. "Use /getjob [job name] to get a job.", player)
end)

-- Job command: /getjob
addCommandHandler("getjob", function(player, _, jobName)
    if not jobName then
        outputChatBox(COLOR_YELLOW .. "Usage: /getjob [job name]", player)
        outputChatBox(COLOR_GRAY .. "Use /jobs to see available jobs.", player)
        return
    end

    -- Find job (case insensitive)
    local foundJob = nil
    for name, data in pairs(jobs) do
        if name:lower() == jobName:lower() then
            foundJob = name
            break
        end
    end

    if not foundJob then
        outputChatBox(COLOR_RED .. "Job not found! Use /jobs to see available jobs.", player)
        return
    end

    local currentJob = getPlayerJob(player)
    if currentJob then
        outputChatBox(COLOR_RED .. "You already have a job! Use /quitjob first.", player)
        return
    end

    -- Check if player is at job location
    local jobData = jobs[foundJob]
    local px, py, pz = getElementPosition(player)
    local distance = getDistance3D(px, py, pz, jobData.spawn[1], jobData.spawn[2], jobData.spawn[3])

    if distance > 50 then
        outputChatBox(COLOR_RED .. "You must be at the job location to get this job!", player)
        return
    end

    if setPlayerJob(player, foundJob) then
        outputChatBox(COLOR_GREEN .. "You got the job: " .. foundJob .. "!", player)
        outputChatBox(COLOR_YELLOW .. "Salary: $" .. jobData.salary .. "/hour", player)
        outputChatBox(COLOR_GRAY .. "Use /startwork to begin working.", player)
    end
end)

-- Job command: /quitjob
addCommandHandler("quitjob", function(player)
    local job = getPlayerJob(player)
    if not job then
        outputChatBox(COLOR_RED .. "You don't have a job!", player)
        return
    end

    if quitJob(player) then
        outputChatBox(COLOR_GREEN .. "You quit your job: " .. job, player)
    end
end)

-- Job command: /startwork
addCommandHandler("startwork", function(player)
    local job = getPlayerJob(player)
    if not job then
        outputChatBox(COLOR_RED .. "You don't have a job! Use /getjob to get one.", player)
        return
    end

    local jobData = jobs[job]
    local playerName = getPlayerName(player)

    if activeJobs[playerName] then
        outputChatBox(COLOR_RED .. "You are already working!", player)
        return
    end

    -- Start job based on type
    if job == "Trucker" then
        startTruckerJob(player, jobData)
    elseif job == "Taxi Driver" then
        startTaxiJob(player, jobData)
    elseif job == "Bus Driver" then
        startBusJob(player, jobData)
    elseif job == "Pilot" then
        startPilotJob(player, jobData)
    elseif job == "Pizza Delivery" then
        startPizzaJob(player, jobData)
    elseif job == "Farmer" then
        startFarmJob(player, jobData)
    elseif job == "Fisher" then
        startFishJob(player, jobData)
    else
        outputChatBox(COLOR_YELLOW .. "You started working as " .. job .. "!", player)
        activeJobs[playerName] = {
            job = job,
            startTime = getRealTime().timestamp
        }
    end
end)

-- Job command: /stopwork
addCommandHandler("stopwork", function(player)
    local playerName = getPlayerName(player)
    if not activeJobs[playerName] then
        outputChatBox(COLOR_RED .. "You are not working!", player)
        return
    end

    local workData = activeJobs[playerName]
    local workTime = getRealTime().timestamp - workData.startTime
    local job = getPlayerJob(player)
    local jobData = jobs[job]

    -- Calculate payment
    local payment = math.floor((workTime / 3600) * jobData.salary) -- Payment based on hours worked
    if payment > 0 then
        givePlayerMoney(player, payment)
        addJobExperience(player, math.floor(workTime / 60)) -- 1 exp per minute
        outputChatBox(COLOR_GREEN .. "Work completed! Payment: $" .. formatMoney(payment), player)
    else
        outputChatBox(COLOR_YELLOW .. "You stopped working.", player)
    end

    activeJobs[playerName] = nil
end)

-- Job command: /jobstats
addCommandHandler("jobstats", function(player)
    local job = getPlayerJob(player)
    if not job then
        outputChatBox(COLOR_RED .. "You don't have a job!", player)
        return
    end

    local level = getElementData(player, "jobLevel") or 1
    local exp = getElementData(player, "jobExp") or 0
    local nextLevelExp = level * 1000

    outputChatBox(COLOR_YELLOW .. "=== Job Statistics ===", player)
    outputChatBox(COLOR_WHITE .. "Job: " .. job, player)
    outputChatBox(COLOR_WHITE .. "Level: " .. level, player)
    outputChatBox(COLOR_WHITE .. "Experience: " .. exp .. "/" .. nextLevelExp, player)
    outputChatBox(COLOR_WHITE .. "Salary: $" .. jobs[job].salary .. "/hour", player)

    local playerName = getPlayerName(player)
    if activeJobs[playerName] then
        outputChatBox(COLOR_GREEN .. "Status: Working", player)
    else
        outputChatBox(COLOR_GRAY .. "Status: Not working", player)
    end
end)

-- Trucker job functions
function startTruckerJob(player, jobData)
    local route = jobData.routes[math.random(#jobData.routes)]
    local playerName = getPlayerName(player)

    activeJobs[playerName] = {
        job = "Trucker",
        route = route,
        startTime = getRealTime().timestamp,
        checkpoint = nil
    }

    -- Create checkpoint at route start
    local checkpoint = createMarker(route.start[1], route.start[2], route.start[3] - 1, "checkpoint", 4, 255, 255, 0,
        150)
    activeJobs[playerName].checkpoint = checkpoint

    outputChatBox(COLOR_GREEN .. "Trucker job started! Route: " .. route.name, player)
    outputChatBox(COLOR_YELLOW .. "Go to the yellow checkpoint to pick up cargo.", player)
    outputChatBox(COLOR_GRAY .. "Payment: $" .. formatMoney(route.pay), player)

    -- Create pickup event
    addEventHandler("onMarkerHit", checkpoint, function(hitPlayer)
        if hitPlayer == player then
            proceedTruckerRoute(player)
        end
    end)
end

function proceedTruckerRoute(player)
    local playerName = getPlayerName(player)
    local jobData = activeJobs[playerName]

    if not jobData or not jobData.checkpoint then
        return
    end

    -- Destroy old checkpoint
    destroyElement(jobData.checkpoint)

    -- Create delivery checkpoint
    local route = jobData.route
    local deliveryCheckpoint = createMarker(route.finish[1], route.finish[2], route.finish[3] - 1, "checkpoint", 4, 255,
        0, 0, 150)
    jobData.checkpoint = deliveryCheckpoint

    outputChatBox(COLOR_GREEN .. "Cargo loaded! Deliver to the red checkpoint.", player)

    -- Create delivery event
    addEventHandler("onMarkerHit", deliveryCheckpoint, function(hitPlayer)
        if hitPlayer == player then
            completeTruckerRoute(player)
        end
    end)
end

function completeTruckerRoute(player)
    local playerName = getPlayerName(player)
    local jobData = activeJobs[playerName]

    if not jobData then
        return
    end

    local route = jobData.route
    destroyElement(jobData.checkpoint)

    -- Payment and experience
    givePlayerMoney(player, route.pay)
    addJobExperience(player, 50)

    outputChatBox(COLOR_GREEN .. "Delivery completed! Payment: $" .. formatMoney(route.pay), player)

    activeJobs[playerName] = nil
end

-- Pizza delivery job
function startPizzaJob(player, jobData)
    local deliveryLocations = {{2040.1, -1403.5, 17.2, "Grove Street"}, {2451.7, -1957.7, 13.5, "Ganton"},
                               {2523.0, -1679.2, 15.5, "East Los Santos"}, {1940.1, -2114.8, 13.6, "Willowfield"}}

    local location = deliveryLocations[math.random(#deliveryLocations)]
    local playerName = getPlayerName(player)

    activeJobs[playerName] = {
        job = "Pizza Delivery",
        location = location,
        startTime = getRealTime().timestamp,
        checkpoint = nil
    }

    -- Create delivery checkpoint
    local checkpoint = createMarker(location[1], location[2], location[3] - 1, "checkpoint", 4, 255, 165, 0, 150)
    activeJobs[playerName].checkpoint = checkpoint

    outputChatBox(COLOR_GREEN .. "Pizza delivery started! Deliver to: " .. location[4], player)
    outputChatBox(COLOR_YELLOW .. "Payment: $" .. jobData.baseDeliveryPay, player)

    -- Create delivery event
    addEventHandler("onMarkerHit", checkpoint, function(hitPlayer)
        if hitPlayer == player then
            completePizzaDelivery(player)
        end
    end)
end

function completePizzaDelivery(player)
    local playerName = getPlayerName(player)
    local jobData = activeJobs[playerName]

    if not jobData then
        return
    end

    destroyElement(jobData.checkpoint)

    local payment = jobs["Pizza Delivery"].baseDeliveryPay
    givePlayerMoney(player, payment)
    addJobExperience(player, 25)

    outputChatBox(COLOR_GREEN .. "Pizza delivered! Payment: $" .. formatMoney(payment), player)

    activeJobs[playerName] = nil
end

-- Initialize job system
addEventHandler("onResourceStart", resourceRoot, function()
    -- Create job pickup points
    for jobName, jobData in pairs(jobs) do
        local pickup = createPickup(jobData.spawn[1], jobData.spawn[2], jobData.spawn[3], 3, 1239, 500) -- Info icon
        setElementData(pickup, "jobName", jobName)
    end

    print("Jobs system initialized with " .. tableCount(jobs) .. " job types")
end)

