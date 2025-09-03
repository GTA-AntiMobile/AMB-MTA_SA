-- ================================
-- AMB MTA:SA - Shop & Services System
-- Migrated from SA-MP open.mp server - Final systems
-- ================================

-- Shop and services management systems
local shopSystem = {
    shops = {},
    rentals = {},
    toyShop = {},
    clothingShop = {},
    vehicleShops = {},
    healthCare = {},
    credits = {},
    shopNotices = true,
    rentVehicles = {},
    availableClothes = {
        {id = 1, name = "White T-Shirt", price = 50, slot = "torso"},
        {id = 2, name = "Black Jeans", price = 75, slot = "legs"},
        {id = 3, name = "Sneakers", price = 100, slot = "feet"},
        {id = 4, name = "Baseball Cap", price = 25, slot = "head"},
        {id = 5, name = "Sunglasses", price = 40, slot = "eyes"}
    },
    availableToys = {
        {id = 1, name = "Dildo", model = 321, price = 10, slot = 0},
        {id = 2, name = "Phone", model = 330, price = 50, slot = 1},
        {id = 3, name = "Camera", model = 367, price = 75, slot = 2},
        {id = 4, name = "Flower", model = 325, price = 15, slot = 3},
        {id = 5, name = "Cane", model = 333, price = 30, slot = 4}
    },
    healthPlans = {
        basic = {name = "Basic Health Plan", price = 1000, coverage = 50},
        premium = {name = "Premium Health Plan", price = 2500, coverage = 75},
        platinum = {name = "Platinum Health Plan", price = 5000, coverage = 100}
    }
}

-- Clothing shop system
addCommandHandler("trangphuc", function(player)
    outputChatBox("=== SHOP TRANG PHUC ===", player, 255, 255, 0)
    outputChatBox("Cac trang phuc co san:", player, 255, 255, 255)
    
    for _, cloth in ipairs(shopSystem.availableClothes) do
        outputChatBox(cloth.id .. ". " .. cloth.name .. " - $" .. cloth.price .. " (" .. cloth.slot .. ")", player, 200, 200, 200)
    end
    
    outputChatBox("Su dung: /muatrangphuc [ID] de mua", player, 255, 255, 255)
end)

addCommandHandler("clothes", function(player)
    executeCommandHandler("trangphuc", player)
end)

addCommandHandler("muatrangphuc", function(player, _, clothId)
    if not clothId then
        outputChatBox("Su dung: /muatrangphuc [cloth ID]", player, 255, 255, 255)
        executeCommandHandler("trangphuc", player)
        return
    end
    
    clothId = tonumber(clothId)
    local cloth = nil
    
    for _, c in ipairs(shopSystem.availableClothes) do
        if c.id == clothId then
            cloth = c
            break
        end
    end
    
    if not cloth then
        outputChatBox("Cloth ID khong hop le!", player, 255, 0, 0)
        return
    end
    
    if getPlayerMoney(player) < cloth.price then
        outputChatBox("Ban khong du tien! Can: $" .. cloth.price, player, 255, 0, 0)
        return
    end
    
    takePlayerMoney(player, cloth.price)
    
    -- Apply clothing (simplified - would need proper skin/clothing system)
    outputChatBox("Da mua " .. cloth.name .. " thanh cong!", player, 0, 255, 0)
    outputChatBox("Trang phuc da duoc ap dung", player, 255, 255, 255)
    
    -- Store in player wardrobe
    local wardrobe = getElementData(player, "player.wardrobe") or {}
    table.insert(wardrobe, cloth)
    setElementData(player, "player.wardrobe", wardrobe)
end)

addCommandHandler("buyclothes", function(player, _, clothId)
    executeCommandHandler("muatrangphuc", player, _, clothId)
end)

-- Toy shop system
addCommandHandler("toyshop", function(player)
    outputChatBox("=== SHOP DO CHOI ===", player, 255, 255, 0)
    outputChatBox("Cac do choi co san:", player, 255, 255, 255)
    
    for _, toy in ipairs(shopSystem.availableToys) do
        outputChatBox(toy.id .. ". " .. toy.name .. " - $" .. toy.price, player, 200, 200, 200)
    end
    
    outputChatBox("Su dung: /muadochoi [ID] de mua", player, 255, 255, 255)
    outputChatBox("Su dung: /toys de xem do choi cua ban", player, 255, 255, 255)
end)

addCommandHandler("muadochoi", function(player, _, toyId)
    if not toyId then
        outputChatBox("Su dung: /muadochoi [toy ID]", player, 255, 255, 255)
        executeCommandHandler("toyshop", player)
        return
    end
    
    toyId = tonumber(toyId)
    local toy = nil
    
    for _, t in ipairs(shopSystem.availableToys) do
        if t.id == toyId then
            toy = t
            break
        end
    end
    
    if not toy then
        outputChatBox("Toy ID khong hop le!", player, 255, 0, 0)
        return
    end
    
    if getPlayerMoney(player) < toy.price then
        outputChatBox("Ban khong du tien! Can: $" .. toy.price, player, 255, 0, 0)
        return
    end
    
    takePlayerMoney(player, toy.price)
    
    -- Add toy to player inventory
    local toys = getElementData(player, "player.toys") or {}
    table.insert(toys, toy)
    setElementData(player, "player.toys", toys)
    
    outputChatBox("Da mua " .. toy.name .. " thanh cong!", player, 0, 255, 0)
    outputChatBox("Su dung /toys de xem va su dung do choi", player, 255, 255, 255)
end)

addCommandHandler("buytoys", function(player, _, toyId)
    executeCommandHandler("muadochoi", player, _, toyId)
end)

addCommandHandler("toys", function(player)
    local toys = getElementData(player, "player.toys") or {}
    
    if #toys == 0 then
        outputChatBox("Ban khong co do choi nao! Su dung /toyshop de mua", player, 255, 255, 0)
        return
    end
    
    outputChatBox("=== DO CHOI CUA BAN ===", player, 255, 255, 0)
    for i, toy in ipairs(toys) do
        outputChatBox(i .. ". " .. toy.name .. " (Model: " .. toy.model .. ")", player, 255, 255, 255)
    end
    
    outputChatBox("Su dung: /wt [toy ID] de deo do choi", player, 255, 255, 255)
    outputChatBox("Su dung: /dt [toy ID] de thao do choi", player, 255, 255, 255)
end)

addCommandHandler("wt", function(player, _, toyIndex) -- Wear toy
    if not toyIndex then
        outputChatBox("Su dung: /wt [toy index]", player, 255, 255, 255)
        return
    end
    
    local toys = getElementData(player, "player.toys") or {}
    toyIndex = tonumber(toyIndex)
    
    if not toys[toyIndex] then
        outputChatBox("Toy index khong hop le!", player, 255, 0, 0)
        return
    end
    
    local toy = toys[toyIndex]
    
    -- Create toy object attached to player (simplified)
    outputChatBox("Da deo " .. toy.name, player, 0, 255, 0)
    setElementData(player, "player.currentToy", toy)
end)

addCommandHandler("dt", function(player, _, toyIndex) -- Remove toy
    if not toyIndex then
        outputChatBox("Su dung: /dt [toy index]", player, 255, 255, 255)
        return
    end
    
    setElementData(player, "player.currentToy", nil)
    outputChatBox("Da thao do choi", player, 255, 255, 0)
end)

-- Vehicle rental system
addCommandHandler("thuexe", function(player, _, vehicleType, hours)
    if not vehicleType then
        outputChatBox("Su dung: /thuexe [car/bike/boat] [hours]", player, 255, 255, 255)
        outputChatBox("Gia thue:", player, 255, 255, 255)
        outputChatBox("- Car: $100/hour", player, 200, 200, 200)
        outputChatBox("- Bike: $50/hour", player, 200, 200, 200)
        outputChatBox("- Boat: $200/hour", player, 200, 200, 200)
        return
    end
    
    hours = tonumber(hours) or 1
    if hours <= 0 or hours > 24 then
        outputChatBox("So gio thue phai tu 1-24!", player, 255, 0, 0)
        return
    end
    
    local rentalPrices = {car = 100, bike = 50, boat = 200}
    local price = rentalPrices[vehicleType]
    
    if not price then
        outputChatBox("Loai xe khong hop le! (car/bike/boat)", player, 255, 0, 0)
        return
    end
    
    local totalCost = price * hours
    if getPlayerMoney(player) < totalCost then
        outputChatBox("Ban khong du tien! Can: $" .. totalCost, player, 255, 0, 0)
        return
    end
    
    -- Check if player already has rental
    if shopSystem.rentVehicles[player] then
        outputChatBox("Ban da thue xe roi! Su dung /stoprentacar de tra xe truoc", player, 255, 0, 0)
        return
    end
    
    takePlayerMoney(player, totalCost)
    
    -- Spawn rental vehicle
    local x, y, z = getElementPosition(player)
    local vehicleModels = {
        car = {400, 401, 404, 405, 410},
        bike = {481, 509, 510, 521, 522},
        boat = {452, 453, 454, 472, 473}
    }
    
    local model = vehicleModels[vehicleType][math.random(#vehicleModels[vehicleType])]
    local vehicle = createVehicle(model, x + 3, y, z)
    
    shopSystem.rentVehicles[player] = {
        vehicle = vehicle,
        type = vehicleType,
        endTime = getRealTime().timestamp + (hours * 3600),
        hours = hours
    }
    
    outputChatBox("Da thue " .. vehicleType .. " thanh cong!", player, 0, 255, 0)
    outputChatBox("Thoi gian: " .. hours .. " gio - Chi phi: $" .. totalCost, player, 255, 255, 255)
    outputChatBox("Su dung /stoprentacar de tra xe truoc han", player, 255, 255, 255)
    
    -- Auto return timer
    setTimer(function()
        if shopSystem.rentVehicles[player] and isElement(vehicle) then
            destroyElement(vehicle)
            shopSystem.rentVehicles[player] = nil
            if isElement(player) then
                outputChatBox("Thoi gian thue xe da het!", player, 255, 255, 0)
            end
        end
    end, hours * 3600 * 1000, 1)
end)

addCommandHandler("rentacar", function(player, _, vehicleType, hours)
    executeCommandHandler("thuexe", player, _, vehicleType, hours)
end)

addCommandHandler("stoprentacar", function(player)
    if not shopSystem.rentVehicles[player] then
        outputChatBox("Ban khong co xe thue nao!", player, 255, 0, 0)
        return
    end
    
    local rental = shopSystem.rentVehicles[player]
    if isElement(rental.vehicle) then
        destroyElement(rental.vehicle)
    end
    
    shopSystem.rentVehicles[player] = nil
    outputChatBox("Da tra xe thue thanh cong", player, 255, 255, 0)
    
    -- Refund remaining time (50% refund)
    local remainingTime = rental.endTime - getRealTime().timestamp
    if remainingTime > 0 then
        local refund = math.floor((remainingTime / 3600) * 50) -- 50% of hourly rate
        givePlayerMoney(player, refund)
        outputChatBox("Hoan lai: $" .. refund, player, 0, 255, 0)
    end
end)

-- Health care system
addCommandHandler("chamsocsuckhoe", function(player)
    local healthPlan = getElementData(player, "player.healthPlan")
    
    outputChatBox("=== CHAM SOC SUC KHOE ===", player, 255, 255, 0)
    if healthPlan then
        local plan = shopSystem.healthPlans[healthPlan]
        outputChatBox("Goi hien tai: " .. plan.name, player, 255, 255, 255)
        outputChatBox("Bao hiem: " .. plan.coverage .. "%", player, 255, 255, 255)
    else
        outputChatBox("Ban chua co goi cham soc suc khoe", player, 255, 255, 255)
    end
    
    outputChatBox("Cac goi co san:", player, 255, 255, 255)
    for planId, plan in pairs(shopSystem.healthPlans) do
        outputChatBox("- " .. plan.name .. " ($" .. plan.price .. ", " .. plan.coverage .. "% bao hiem)", player, 200, 200, 200)
    end
    
    outputChatBox("Su dung: /buyhealthcare [basic/premium/platinum]", player, 255, 255, 255)
end)

addCommandHandler("buyhealthcare", function(player, _, planType)
    if not planType then
        executeCommandHandler("chamsocsuckhoe", player)
        return
    end
    
    local plan = shopSystem.healthPlans[planType]
    if not plan then
        outputChatBox("Goi cham soc khong hop le!", player, 255, 0, 0)
        return
    end
    
    if getPlayerMoney(player) < plan.price then
        outputChatBox("Ban khong du tien! Can: $" .. plan.price, player, 255, 0, 0)
        return
    end
    
    takePlayerMoney(player, plan.price)
    setElementData(player, "player.healthPlan", planType)
    
    outputChatBox("Da mua " .. plan.name .. " thanh cong!", player, 0, 255, 0)
    outputChatBox("Bao hiem: " .. plan.coverage .. "% chi phi y te", player, 255, 255, 255)
end)

addCommandHandler("togglehealthcare", function(player)
    local enabled = getElementData(player, "player.healthCareEnabled") or false
    setElementData(player, "player.healthCareEnabled", not enabled)
    
    local status = enabled and "TAT" or "BAT"
    outputChatBox("Auto health care da duoc " .. status, player, 255, 255, 0)
end)

-- Shop vehicle systems
addCommandHandler("carshop", function(player)
    outputChatBox("=== CAR SHOP ===", player, 255, 255, 0)
    outputChatBox("Cac xe co ban:", player, 255, 255, 255)
    outputChatBox("1. Greenwood - $15,000", player, 200, 200, 200)
    outputChatBox("2. Admiral - $25,000", player, 200, 200, 200)
    outputChatBox("3. Elegant - $35,000", player, 200, 200, 200)
    outputChatBox("4. Washington - $45,000", player, 200, 200, 200)
    outputChatBox("5. Stretch - $100,000", player, 200, 200, 200)
    outputChatBox("Su dung: /buycar [1-5]", player, 255, 255, 255)
end)

addCommandHandler("boatshop", function(player)
    outputChatBox("=== BOAT SHOP ===", player, 255, 255, 0)
    outputChatBox("Cac thuyen co ban:", player, 255, 255, 255)
    outputChatBox("1. Dinghy - $5,000", player, 200, 200, 200)
    outputChatBox("2. Jetmax - $15,000", player, 200, 200, 200)
    outputChatBox("3. Marquis - $25,000", player, 200, 200, 200)
    outputChatBox("4. Predator - $50,000", player, 200, 200, 200)
    outputChatBox("Su dung: /buyboat [1-4]", player, 255, 255, 255)
end)

addCommandHandler("planeshop", function(player)
    outputChatBox("=== PLANE SHOP ===", player, 255, 255, 0)
    outputChatBox("Cac may bay co ban:", player, 255, 255, 255)
    outputChatBox("1. Dodo - $50,000", player, 200, 200, 200)
    outputChatBox("2. Nevada - $100,000", player, 200, 200, 200)
    outputChatBox("3. Shamal - $200,000", player, 200, 200, 200)
    outputChatBox("4. Hydra - $500,000", player, 200, 200, 200)
    outputChatBox("Su dung: /buyplane [1-4]", player, 255, 255, 255)
end)

-- Credits system
addCommandHandler("credits", function(player)
    local credits = getElementData(player, "player.credits") or 0
    outputChatBox("Credits cua ban: " .. credits, player, 255, 255, 0)
    outputChatBox("Su dung credits de mua cac vat pham dac biet", player, 255, 255, 255)
    outputChatBox("/sellcredits [amount] - Ban credits lay tien", player, 200, 200, 200)
end)

addCommandHandler("givecredits", function(player, _, playerIdOrName, amount)
    if not hasPermission(player, "admin", 3) then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end
    
    if not playerIdOrName or not amount then
        outputChatBox("Su dung: /givecredits [player] [amount]", player, 255, 255, 255)
        return
    end
    
    local target = getPlayerFromNameOrId(playerIdOrName)
    if not target then
        outputChatBox("Khong tim thay player!", player, 255, 0, 0)
        return
    end
    
    local creditAmount = tonumber(amount)
    if not creditAmount or creditAmount <= 0 then
        outputChatBox("So credits phai lon hon 0!", player, 255, 0, 0)
        return
    end
    
    local currentCredits = getElementData(target, "player.credits") or 0
    setElementData(target, "player.credits", currentCredits + creditAmount)
    
    outputChatBox("Da give " .. creditAmount .. " credits cho " .. getPlayerName(target), player, 0, 255, 0)
    outputChatBox("Admin " .. getPlayerName(player) .. " da give ban " .. creditAmount .. " credits!", target, 255, 255, 0)
end)

addCommandHandler("sellcredits", function(player, _, amount)
    if not amount then
        outputChatBox("Su dung: /sellcredits [amount]", player, 255, 255, 255)
        outputChatBox("Gia: 1 credit = $100", player, 255, 255, 255)
        return
    end
    
    local sellAmount = tonumber(amount)
    if not sellAmount or sellAmount <= 0 then
        outputChatBox("So credits phai lon hon 0!", player, 255, 0, 0)
        return
    end
    
    local currentCredits = getElementData(player, "player.credits") or 0
    if currentCredits < sellAmount then
        outputChatBox("Ban khong du credits!", player, 255, 0, 0)
        return
    end
    
    setElementData(player, "player.credits", currentCredits - sellAmount)
    givePlayerMoney(player, sellAmount * 100)
    
    outputChatBox("Da ban " .. sellAmount .. " credits lay $" .. (sellAmount * 100), player, 0, 255, 0)
end)

-- Music and entertainment
addCommandHandler("music", function(player, _, action, url)
    if not action then
        outputChatBox("Su dung: /music [play/stop] [url]", player, 255, 255, 255)
        outputChatBox("Vi du: /music play http://example.com/song.mp3", player, 255, 255, 255)
        return
    end
    
    if action == "play" then
        if not url then
            outputChatBox("Can URL de phat nhac!", player, 255, 0, 0)
            return
        end
        
        -- Play music for player (would need client-side implementation)
        outputChatBox("Dang phat nhac: " .. url, player, 0, 255, 0)
        setElementData(player, "player.currentMusic", url)
        
    elseif action == "stop" then
        setElementData(player, "player.currentMusic", nil)
        outputChatBox("Da dung phat nhac", player, 255, 255, 0)
    else
        outputChatBox("Action khong hop le! (play/stop)", player, 255, 0, 0)
    end
end)

addCommandHandler("mp3", function(player, _, ...)
    if not ... then
        outputChatBox("Su dung: /mp3 [search keywords]", player, 255, 255, 255)
        outputChatBox("Tim kiem va phat nhac MP3", player, 255, 255, 255)
        return
    end
    
    local keywords = table.concat({...}, " ")
    outputChatBox("Dang tim kiem nhac: " .. keywords, player, 255, 255, 0)
    outputChatBox("Tinh nang nay can ket noi API ben ngoai", player, 200, 200, 200)
end)

-- Boxing and fighting
addCommandHandler("fight", function(player, _, playerIdOrName)
    if not playerIdOrName then
        outputChatBox("Su dung: /fight [player]", player, 255, 255, 255)
        return
    end
    
    local target = getPlayerFromNameOrId(playerIdOrName)
    if not target then
        outputChatBox("Khong tim thay player!", player, 255, 0, 0)
        return
    end
    
    if target == player then
        outputChatBox("Ban khong the danh chinh minh!", player, 255, 0, 0)
        return
    end
    
    local x, y, z = getElementPosition(player)
    local tx, ty, tz = getElementPosition(target)
    local distance = getDistanceBetweenPoints3D(x, y, z, tx, ty, tz)
    
    if distance > 5 then
        outputChatBox("Ban can o gan " .. getPlayerName(target) .. " de fight!", player, 255, 0, 0)
        return
    end
    
    outputChatBox(getPlayerName(player) .. " muon fight voi " .. getPlayerName(target), root, 255, 255, 0)
    outputChatBox("Su dung /acceptfight de chap nhan", target, 255, 255, 255)
    
    setElementData(target, "pendingFight", player)
    
    -- Auto cancel after 30 seconds
    setTimer(function()
        if getElementData(target, "pendingFight") == player then
            setElementData(target, "pendingFight", nil)
            outputChatBox("Loi moi fight da het han", player, 255, 255, 0)
        end
    end, 30000, 1)
end)

addCommandHandler("acceptfight", function(player)
    local challenger = getElementData(player, "pendingFight")
    if not challenger or not isElement(challenger) then
        outputChatBox("Khong co loi moi fight nao!", player, 255, 0, 0)
        return
    end
    
    setElementData(player, "pendingFight", nil)
    
    -- Start boxing match
    outputChatBox("Fight bat dau giua " .. getPlayerName(challenger) .. " va " .. getPlayerName(player) .. "!", root, 255, 255, 0)
    
    -- Set fighting style and remove weapons
    setPedFightingStyle(challenger, 6) -- Boxing
    setPedFightingStyle(player, 6)
    takeAllWeapons(challenger)
    takeAllWeapons(player)
    
    setElementData(challenger, "inFight", true)
    setElementData(player, "inFight", true)
end)

-- Service requests
addCommandHandler("dichvu", function(player)
    outputChatBox("=== DICH VU ===", player, 255, 255, 0)
    outputChatBox("Cac dich vu co san:", player, 255, 255, 255)
    outputChatBox("1. Sua xe - /callmechanic", player, 200, 200, 200)
    outputChatBox("2. Taxi - /calltaxi", player, 200, 200, 200)
    outputChatBox("3. Y te - /callmedic", player, 200, 200, 200)
    outputChatBox("4. Luat su - /calllawyer", player, 200, 200, 200)
    outputChatBox("5. Yeu cau tro giup - /yeucautrogiup", player, 200, 200, 200)
end)

addCommandHandler("yeucautrogiup", function(player, _, ...)
    if not ... then
        outputChatBox("Su dung: /yeucautrogiup [van de can tro giup]", player, 255, 255, 255)
        return
    end
    
    local request = table.concat({...}, " ")
    
    -- Send to helpers/admins
    local sentTo = 0
    for _, helper in ipairs(getElementsByType("player")) do
        if hasPermission(helper, "helper") or hasPermission(helper, "admin", 1) then
            outputChatBox("=== YEU CAU TRO GIUP ===", helper, 255, 255, 0)
            outputChatBox("Tu: " .. getPlayerName(player), helper, 255, 255, 255)
            outputChatBox("Van de: " .. request, helper, 255, 255, 255)
            outputChatBox("Su dung /tr [player] [message] de tra loi", helper, 200, 200, 200)
            sentTo = sentTo + 1
        end
    end
    
    if sentTo > 0 then
        outputChatBox("Yeu cau tro giup da duoc gui den " .. sentTo .. " helper/admin", player, 0, 255, 0)
        outputChatBox("Ho se tra loi ban som", player, 255, 255, 255)
    else
        outputChatBox("Khong co helper/admin nao online!", player, 255, 0, 0)
    end
end)

addCommandHandler("tr", function(player, _, playerIdOrName, ...)
    if not hasPermission(player, "helper") and not hasPermission(player, "admin", 1) then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end
    
    if not playerIdOrName or not ... then
        outputChatBox("Su dung: /tr [player] [message]", player, 255, 255, 255)
        return
    end
    
    local target = getPlayerFromNameOrId(playerIdOrName)
    if not target then
        outputChatBox("Khong tim thay player!", player, 255, 0, 0)
        return
    end
    
    local message = table.concat({...}, " ")
    
    outputChatBox("=== TRA LOI TRO GIUP ===", target, 255, 255, 0)
    outputChatBox("Tu Helper " .. getPlayerName(player) .. ": " .. message, target, 255, 255, 255)
    
    outputChatBox("Da tra loi " .. getPlayerName(target), player, 0, 255, 0)
end)

-- Shop statistics and help
addCommandHandler("shopstats", function(player)
    if not hasPermission(player, "admin", 2) then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end
    
    outputChatBox("=== SHOP STATISTICS ===", player, 255, 255, 0)
    outputChatBox("Active rental vehicles: " .. table.size(shopSystem.rentVehicles), player, 255, 255, 255)
    
    local totalCredits = 0
    local totalTokens = 0
    for _, p in ipairs(getElementsByType("player")) do
        totalCredits = totalCredits + (getElementData(p, "player.credits") or 0)
        totalTokens = totalTokens + (getElementData(p, "player.tokens") or 0)
    end
    
    outputChatBox("Total credits in circulation: " .. totalCredits, player, 255, 255, 255)
    outputChatBox("Total tokens in circulation: " .. totalTokens, player, 255, 255, 255)
end)

addCommandHandler("shophelp", function(player)
    outputChatBox("=== SHOP HELP ===", player, 255, 255, 0)
    outputChatBox("Clothing: /trangphuc, /muatrangphuc", player, 255, 255, 255)
    outputChatBox("Toys: /toyshop, /muadochoi, /toys", player, 255, 255, 255)
    outputChatBox("Vehicles: /carshop, /boatshop, /planeshop", player, 255, 255, 255)
    outputChatBox("Rental: /thuexe, /stoprentacar", player, 255, 255, 255)
    outputChatBox("Health: /chamsocsuckhoe, /buyhealthcare", player, 255, 255, 255)
    outputChatBox("Credits: /credits, /sellcredits", player, 255, 255, 255)
    outputChatBox("Music: /music, /mp3", player, 255, 255, 255)
    outputChatBox("Services: /dichvu, /yeucautrogiup", player, 255, 255, 255)
end)

-- Helper function for table size
function table.size(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

print("Shop & Services System loaded: clothing, toys, rentals, healthcare, credits, music, help")
