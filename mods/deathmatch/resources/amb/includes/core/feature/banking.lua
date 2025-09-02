-- ================================
-- AMB MTA:SA - Banking & Business System  
-- Migrated from SA-MP open.mp server
-- ================================

-- Banking and business management systems
local bankingSystem = {
    accounts = {},
    transactions = {},
    businesses = {},
    atmLocations = {
        {x = 1481.0, y = -1749.2, z = 15.3, name = "Grove Street ATM"},
        {x = 1368.5, y = -1279.8, z = 13.5, name = "Jefferson ATM"},  
        {x = 2495.2, y = -1691.3, z = 14.7, name = "Ganton ATM"},
        {x = 1553.1, y = -1675.6, z = 16.2, name = "Glen Park ATM"}
    },
    businessTypes = {
        shop = {name = "General Shop", income = 1000, maxItems = 50},
        restaurant = {name = "Restaurant", income = 1500, maxItems = 30},
        gas_station = {name = "Gas Station", income = 2000, maxItems = 20},
        gun_shop = {name = "Gun Shop", income = 3000, maxItems = 15},
        car_dealership = {name = "Car Dealership", income = 5000, maxItems = 10}
    },
    transferFee = 50,
    withdrawFee = 10,
    dailyInterest = 0.01 -- 1% daily interest
}

-- Initialize player banking account
function initPlayerBankAccount(player)
    local accountName = getElementData(player, "account.name")
    if not bankingSystem.accounts[accountName] then
        bankingSystem.accounts[accountName] = {
            balance = 1000, -- Starting balance
            pin = "0000", -- Default PIN
            frozen = false,
            lastLogin = getRealTime().timestamp,
            transactions = {}
        }
    end
    
    setElementData(player, "player.bankBalance", bankingSystem.accounts[accountName].balance)
end

-- ATM/Banking commands
addCommandHandler("taikhoan", function(player)
    local accountName = getElementData(player, "account.name")
    local bankAccount = bankingSystem.accounts[accountName]
    
    if not bankAccount then
        initPlayerBankAccount(player)
        bankAccount = bankingSystem.accounts[accountName]
    end
    
    outputChatBox("=== TAI KHOAN NGAN HANG ===", player, 255, 255, 0)
    outputChatBox("So du: $" .. bankAccount.balance, player, 255, 255, 255)
    outputChatBox("Tien mat: $" .. getPlayerMoney(player), player, 255, 255, 255)
    outputChatBox("Trang thai: " .. (bankAccount.frozen and "Bi dong bang" or "Hoat dong"), player, 255, 255, 255)
    
    local lastLogin = os.date("%d/%m/%Y %H:%M", bankAccount.lastLogin)
    outputChatBox("Lan cuoi truy cap: " .. lastLogin, player, 200, 200, 200)
    
    outputChatBox("Lenh ngan hang:", player, 255, 255, 255)
    outputChatBox("/guitien [amount] - Gui tien vao ngan hang", player, 200, 200, 200)
    outputChatBox("/ruttien [amount] - Rut tien tu ngan hang", player, 200, 200, 200)
    outputChatBox("/chuyentien [player] [amount] - Chuyen tien", player, 200, 200, 200)
end)

addCommandHandler("balance", function(player)
    executeCommandHandler("taikhoan", player)
end)

addCommandHandler("guitien", function(player, _, amount)
    if not amount then
        outputChatBox("Su dung: /guitien [so tien]", player, 255, 255, 255)
        return
    end
    
    local depositAmount = tonumber(amount)
    if not depositAmount or depositAmount <= 0 then
        outputChatBox("So tien phai lon hon 0!", player, 255, 0, 0)
        return
    end
    
    if getPlayerMoney(player) < depositAmount then
        outputChatBox("Ban khong du tien mat!", player, 255, 0, 0)
        return
    end
    
    -- Check if near ATM
    local nearATM = false
    local x, y, z = getElementPosition(player)
    
    for _, atm in ipairs(bankingSystem.atmLocations) do
        local distance = getDistanceBetweenPoints3D(x, y, z, atm.x, atm.y, atm.z)
        if distance <= 3 then
            nearATM = atm
            break
        end
    end
    
    if not nearATM then
        outputChatBox("Ban can o gan ATM de gui tien!", player, 255, 0, 0)
        outputChatBox("Cac vi tri ATM:", player, 255, 255, 255)
        for _, atm in ipairs(bankingSystem.atmLocations) do
            outputChatBox("- " .. atm.name, player, 200, 200, 200)
        end
        return
    end
    
    local accountName = getElementData(player, "account.name")
    local bankAccount = bankingSystem.accounts[accountName]
    
    if not bankAccount then
        initPlayerBankAccount(player)
        bankAccount = bankingSystem.accounts[accountName]
    end
    
    if bankAccount.frozen then
        outputChatBox("Tai khoan cua ban bi dong bang!", player, 255, 0, 0)
        return
    end
    
    takePlayerMoney(player, depositAmount)
    bankAccount.balance = bankAccount.balance + depositAmount
    setElementData(player, "player.bankBalance", bankAccount.balance)
    
    -- Record transaction
    table.insert(bankAccount.transactions, {
        type = "deposit",
        amount = depositAmount,
        time = getRealTime().timestamp,
        location = nearATM.name
    })
    
    outputChatBox("Da gui $" .. depositAmount .. " vao tai khoan", player, 0, 255, 0)
    outputChatBox("So du moi: $" .. bankAccount.balance, player, 255, 255, 255)
end)

addCommandHandler("deposit", function(player, _, amount)
    executeCommandHandler("guitien", player, _, amount)
end)

addCommandHandler("ruttien", function(player, _, amount)
    if not amount then
        outputChatBox("Su dung: /ruttien [so tien]", player, 255, 255, 255)
        return
    end
    
    local withdrawAmount = tonumber(amount)
    if not withdrawAmount or withdrawAmount <= 0 then
        outputChatBox("So tien phai lon hon 0!", player, 255, 0, 0)
        return
    end
    
    -- Check if near ATM
    local nearATM = false
    local x, y, z = getElementPosition(player)
    
    for _, atm in ipairs(bankingSystem.atmLocations) do
        local distance = getDistanceBetweenPoints3D(x, y, z, atm.x, atm.y, atm.z)
        if distance <= 3 then
            nearATM = atm
            break
        end
    end
    
    if not nearATM then
        outputChatBox("Ban can o gan ATM de rut tien!", player, 255, 0, 0)
        return
    end
    
    local accountName = getElementData(player, "account.name")
    local bankAccount = bankingSystem.accounts[accountName]
    
    if not bankAccount then
        outputChatBox("Ban chua co tai khoan ngan hang!", player, 255, 0, 0)
        return
    end
    
    if bankAccount.frozen then
        outputChatBox("Tai khoan cua ban bi dong bang!", player, 255, 0, 0)
        return
    end
    
    local totalCost = withdrawAmount + bankingSystem.withdrawFee
    if bankAccount.balance < totalCost then
        outputChatBox("So du khong du! Can: $" .. totalCost .. " (bao gom phi $" .. bankingSystem.withdrawFee .. ")", player, 255, 0, 0)
        return
    end
    
    bankAccount.balance = bankAccount.balance - totalCost
    setElementData(player, "player.bankBalance", bankAccount.balance)
    givePlayerMoney(player, withdrawAmount)
    
    -- Record transaction
    table.insert(bankAccount.transactions, {
        type = "withdraw",
        amount = withdrawAmount,
        fee = bankingSystem.withdrawFee,
        time = getRealTime().timestamp,
        location = nearATM.name
    })
    
    outputChatBox("Da rut $" .. withdrawAmount .. " (phi $" .. bankingSystem.withdrawFee .. ")", player, 0, 255, 0)
    outputChatBox("So du moi: $" .. bankAccount.balance, player, 255, 255, 255)
end)

addCommandHandler("withdraw", function(player, _, amount)
    executeCommandHandler("ruttien", player, _, amount)
end)

addCommandHandler("chuyentien", function(player, _, playerIdOrName, amount)
    if not playerIdOrName or not amount then
        outputChatBox("Su dung: /chuyentien [player] [so tien]", player, 255, 255, 255)
        return
    end
    
    local transferAmount = tonumber(amount)
    if not transferAmount or transferAmount <= 0 then
        outputChatBox("So tien phai lon hon 0!", player, 255, 0, 0)
        return
    end
    
    local target = getPlayerFromName(playerIdOrName)
    if not target then
        outputChatBox("Khong tim thay player!", player, 255, 0, 0)
        return
    end
    
    if target == player then
        outputChatBox("Ban khong the chuyen tien cho chinh minh!", player, 255, 0, 0)
        return
    end
    
    local accountName = getElementData(player, "account.name")
    local targetAccountName = getElementData(target, "account.name")
    
    local senderAccount = bankingSystem.accounts[accountName]
    if not senderAccount then
        outputChatBox("Ban chua co tai khoan ngan hang!", player, 255, 0, 0)
        return
    end
    
    if not bankingSystem.accounts[targetAccountName] then
        initPlayerBankAccount(target)
    end
    local targetAccount = bankingSystem.accounts[targetAccountName]
    
    if senderAccount.frozen then
        outputChatBox("Tai khoan cua ban bi dong bang!", player, 255, 0, 0)
        return
    end
    
    local totalCost = transferAmount + bankingSystem.transferFee
    if senderAccount.balance < totalCost then
        outputChatBox("So du khong du! Can: $" .. totalCost .. " (bao gom phi $" .. bankingSystem.transferFee .. ")", player, 255, 0, 0)
        return
    end
    
    -- Process transfer
    senderAccount.balance = senderAccount.balance - totalCost
    targetAccount.balance = targetAccount.balance + transferAmount
    
    setElementData(player, "player.bankBalance", senderAccount.balance)
    setElementData(target, "player.bankBalance", targetAccount.balance)
    
    -- Record transactions
    table.insert(senderAccount.transactions, {
        type = "transfer_out",
        amount = transferAmount,
        fee = bankingSystem.transferFee,
        target = getPlayerName(target),
        time = getRealTime().timestamp
    })
    
    table.insert(targetAccount.transactions, {
        type = "transfer_in",
        amount = transferAmount,
        sender = getPlayerName(player),
        time = getRealTime().timestamp
    })
    
    outputChatBox("Da chuyen $" .. transferAmount .. " cho " .. getPlayerName(target) .. " (phi $" .. bankingSystem.transferFee .. ")", player, 0, 255, 0)
    outputChatBox("So du moi: $" .. senderAccount.balance, player, 255, 255, 255)
    
    outputChatBox("Ban nhan duoc $" .. transferAmount .. " tu " .. getPlayerName(player), target, 0, 255, 0)
    outputChatBox("So du moi: $" .. targetAccount.balance, target, 255, 255, 255)
end)

addCommandHandler("wiretransfer", function(player, _, playerIdOrName, amount)
    executeCommandHandler("chuyentien", player, _, playerIdOrName, amount)
end)

-- Admin banking commands
addCommandHandler("aguitien", function(player, _, playerIdOrName, amount)
    if not hasPermission(player, "admin", 3) then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end
    
    if not playerIdOrName or not amount then
        outputChatBox("Su dung: /aguitien [player] [amount]", player, 255, 255, 255)
        return
    end
    
    local target = getPlayerFromName(playerIdOrName)
    if not target then
        outputChatBox("Khong tim thay player!", player, 255, 0, 0)
        return
    end
    
    local addAmount = tonumber(amount)
    if not addAmount then
        outputChatBox("So tien khong hop le!", player, 255, 0, 0)
        return
    end
    
    local targetAccountName = getElementData(target, "account.name")
    if not bankingSystem.accounts[targetAccountName] then
        initPlayerBankAccount(target)
    end
    
    local targetAccount = bankingSystem.accounts[targetAccountName]
    targetAccount.balance = targetAccount.balance + addAmount
    setElementData(target, "player.bankBalance", targetAccount.balance)
    
    outputChatBox("Da them $" .. addAmount .. " vao tai khoan cua " .. getPlayerName(target), player, 0, 255, 0)
    outputChatBox("Admin " .. getPlayerName(player) .. " da them $" .. addAmount .. " vao tai khoan cua ban", target, 255, 255, 0)
end)

addCommandHandler("aruttien", function(player, _, playerIdOrName, amount)
    if not hasPermission(player, "admin", 3) then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end
    
    if not playerIdOrName or not amount then
        outputChatBox("Su dung: /aruttien [player] [amount]", player, 255, 255, 255)
        return
    end
    
    local target = getPlayerFromName(playerIdOrName)
    if not target then
        outputChatBox("Khong tim thay player!", player, 255, 0, 0)
        return
    end
    
    local removeAmount = tonumber(amount)
    if not removeAmount then
        outputChatBox("So tien khong hop le!", player, 255, 0, 0)
        return
    end
    
    local targetAccountName = getElementData(target, "account.name")
    if not bankingSystem.accounts[targetAccountName] then
        outputChatBox("Player khong co tai khoan ngan hang!", player, 255, 0, 0)
        return
    end
    
    local targetAccount = bankingSystem.accounts[targetAccountName]
    targetAccount.balance = math.max(0, targetAccount.balance - removeAmount)
    setElementData(target, "player.bankBalance", targetAccount.balance)
    
    outputChatBox("Da tru $" .. removeAmount .. " tu tai khoan cua " .. getPlayerName(target), player, 0, 255, 0)
    outputChatBox("Admin " .. getPlayerName(player) .. " da tru $" .. removeAmount .. " tu tai khoan cua ban", target, 255, 255, 0)
end)

addCommandHandler("ataikhoan", function(player, _, playerIdOrName)
    if not hasPermission(player, "admin", 2) then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end
    
    if not playerIdOrName then
        outputChatBox("Su dung: /ataikhoan [player]", player, 255, 255, 255)
        return
    end
    
    local target = getPlayerFromName(playerIdOrName)
    if not target then
        outputChatBox("Khong tim thay player!", player, 255, 0, 0)
        return
    end
    
    local targetAccountName = getElementData(target, "account.name")
    local targetAccount = bankingSystem.accounts[targetAccountName]
    
    if not targetAccount then
        outputChatBox("Player khong co tai khoan ngan hang!", player, 255, 0, 0)
        return
    end
    
    outputChatBox("=== TAI KHOAN CUA " .. getPlayerName(target) .. " ===", player, 255, 255, 0)
    outputChatBox("So du ngan hang: $" .. targetAccount.balance, player, 255, 255, 255)
    outputChatBox("Tien mat: $" .. getPlayerMoney(target), player, 255, 255, 255)
    outputChatBox("Trang thai: " .. (targetAccount.frozen and "Bi dong bang" or "Hoat dong"), player, 255, 255, 255)
    
    -- Show recent transactions
    outputChatBox("5 giao dich gan nhat:", player, 255, 255, 255)
    local transactionCount = 0
    for i = #targetAccount.transactions, math.max(1, #targetAccount.transactions - 4), -1 do
        local transaction = targetAccount.transactions[i]
        local timeStr = os.date("%d/%m %H:%M", transaction.time)
        
        if transaction.type == "deposit" then
            outputChatBox("[" .. timeStr .. "] Gui: +$" .. transaction.amount, player, 0, 255, 0)
        elseif transaction.type == "withdraw" then
            outputChatBox("[" .. timeStr .. "] Rut: -$" .. transaction.amount .. " (phi: $" .. transaction.fee .. ")", player, 255, 255, 0)
        elseif transaction.type == "transfer_out" then
            outputChatBox("[" .. timeStr .. "] Chuyen cho " .. transaction.target .. ": -$" .. transaction.amount, player, 255, 0, 0)
        elseif transaction.type == "transfer_in" then
            outputChatBox("[" .. timeStr .. "] Nhan tu " .. transaction.sender .. ": +$" .. transaction.amount, player, 0, 255, 0)
        end
        
        transactionCount = transactionCount + 1
        if transactionCount >= 5 then break end
    end
end)

-- Business system
addCommandHandler("shopbusinessname", function(player, _, ...)
    if not ... then
        outputChatBox("Su dung: /shopbusinessname [business name]", player, 255, 255, 255)
        return
    end
    
    local businessName = table.concat({...}, " ")
    local playerBusinesses = getElementData(player, "player.businesses") or {}
    
    if #playerBusinesses == 0 then
        outputChatBox("Ban khong so huu business nao!", player, 255, 0, 0)
        return
    end
    
    -- Set name for the first business (simplified)
    local businessId = playerBusinesses[1]
    if bankingSystem.businesses[businessId] then
        bankingSystem.businesses[businessId].name = businessName
        setElementData(player, "business.name." .. businessId, businessName)
        outputChatBox("Da dat ten business thanh: " .. businessName, player, 0, 255, 0)
    else
        outputChatBox("Business khong ton tai!", player, 255, 0, 0)
    end
end)

addCommandHandler("shophouse", function(player)
    outputChatBox("=== CUA HANG & NHA ===", player, 255, 255, 0)
    outputChatBox("Cac business co san:", player, 255, 255, 255)
    
    for businessType, info in pairs(bankingSystem.businessTypes) do
        outputChatBox("- " .. info.name .. " (Thu nhap: $" .. info.income .. "/ngay)", player, 200, 200, 200)
    end
    
    outputChatBox("Su dung /buybusiness [type] de mua business", player, 255, 255, 255)
    outputChatBox("Su dung /sellbusiness de ban business", player, 255, 255, 255)
end)

-- Token and shopping system  
addCommandHandler("shoptokens", function(player)
    local tokens = getElementData(player, "player.tokens") or 0
    
    outputChatBox("=== SHOP TOKENS ===", player, 255, 255, 0)
    outputChatBox("Token cua ban: " .. tokens, player, 255, 255, 255)
    outputChatBox("Cac vat pham co the mua:", player, 255, 255, 255)
    outputChatBox("1. Extra Health - 50 tokens", player, 200, 200, 200)
    outputChatBox("2. Armor Vest - 75 tokens", player, 200, 200, 200)
    outputChatBox("3. Weapon Package - 100 tokens", player, 200, 200, 200)
    outputChatBox("4. Vehicle Repair Kit - 25 tokens", player, 200, 200, 200)
    outputChatBox("5. Teleport Pass - 30 tokens", player, 200, 200, 200)
    outputChatBox("Su dung: /buytoken [item number]", player, 255, 255, 255)
end)

addCommandHandler("buytoken", function(player, _, itemId)
    if not itemId then
        executeCommandHandler("shoptokens", player)
        return
    end
    
    local tokens = getElementData(player, "player.tokens") or 0
    itemId = tonumber(itemId)
    
    local items = {
        {name = "Extra Health", cost = 50, action = function(p) setElementHealth(p, 100) end},
        {name = "Armor Vest", cost = 75, action = function(p) setPedArmor(p, 100) end},
        {name = "Weapon Package", cost = 100, action = function(p) 
            giveWeapon(p, 31, 500) -- M4
            giveWeapon(p, 24, 200) -- Desert Eagle
        end},
        {name = "Vehicle Repair Kit", cost = 25, action = function(p)
            local vehicle = getPedOccupiedVehicle(p)
            if vehicle then
                fixVehicle(vehicle)
                outputChatBox("Xe da duoc sua chua!", p, 0, 255, 0)
            else
                outputChatBox("Ban can o trong xe!", p, 255, 0, 0)
            end
        end},
        {name = "Teleport Pass", cost = 30, action = function(p)
            setElementData(p, "player.teleportPasses", (getElementData(p, "player.teleportPasses") or 0) + 1)
            outputChatBox("Ban nhan duoc 1 teleport pass!", p, 0, 255, 0)
        end}
    }
    
    local item = items[itemId]
    if not item then
        outputChatBox("Item ID khong hop le! (1-5)", player, 255, 0, 0)
        return
    end
    
    if tokens < item.cost then
        outputChatBox("Ban khong du token! Can: " .. item.cost .. " tokens", player, 255, 0, 0)
        return
    end
    
    setElementData(player, "player.tokens", tokens - item.cost)
    item.action(player)
    
    outputChatBox("Da mua " .. item.name .. " voi " .. item.cost .. " tokens!", player, 0, 255, 0)
    outputChatBox("Token con lai: " .. (tokens - item.cost), player, 255, 255, 255)
end)

-- Token giving system
addCommandHandler("givetoken", function(player, _, playerIdOrName, amount)
    if not hasPermission(player, "admin", 2) then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end
    
    if not playerIdOrName or not amount then
        outputChatBox("Su dung: /givetoken [player] [amount]", player, 255, 255, 255)
        return
    end
    
    local target = getPlayerFromName(playerIdOrName)
    if not target then
        outputChatBox("Khong tim thay player!", player, 255, 0, 0)
        return
    end
    
    local tokenAmount = tonumber(amount)
    if not tokenAmount or tokenAmount <= 0 then
        outputChatBox("So luong token phai lon hon 0!", player, 255, 0, 0)
        return
    end
    
    local currentTokens = getElementData(target, "player.tokens") or 0
    setElementData(target, "player.tokens", currentTokens + tokenAmount)
    
    outputChatBox("Da give " .. tokenAmount .. " tokens cho " .. getPlayerName(target), player, 0, 255, 0)
    outputChatBox("Admin " .. getPlayerName(player) .. " da give ban " .. tokenAmount .. " tokens!", target, 255, 255, 0)
    outputChatBox("Token cua ban: " .. (currentTokens + tokenAmount), target, 255, 255, 255)
end)

-- Daily interest system
setTimer(function()
    for accountName, account in pairs(bankingSystem.accounts) do
        if not account.frozen and account.balance > 0 then
            local interest = math.floor(account.balance * bankingSystem.dailyInterest)
            if interest > 0 then
                account.balance = account.balance + interest
                
                -- Notify if player is online
                for _, player in ipairs(getElementsByType("player")) do
                    if getElementData(player, "account.name") == accountName then
                        setElementData(player, "player.bankBalance", account.balance)
                        outputChatBox("Lai suat hang ngay: +$" .. interest, player, 0, 255, 0)
                        break
                    end
                end
                
                -- Record transaction
                table.insert(account.transactions, {
                    type = "interest",
                    amount = interest,
                    time = getRealTime().timestamp
                })
            end
        end
    end
end, 24 * 60 * 60 * 1000, 0) -- Every 24 hours

-- Initialize bank account on player join
addEventHandler("onPlayerJoin", root, function()
    setTimer(function()
        if isElement(source) then
            initPlayerBankAccount(source)
        end
    end, 1000, 1)
end)

print("Banking & Business System loaded: ATM, accounts, transfers, businesses, tokens, interest")
