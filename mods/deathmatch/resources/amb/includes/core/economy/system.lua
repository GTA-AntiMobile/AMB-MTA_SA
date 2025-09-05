-- ================================
-- AMB MTA:SA - Economy & Banking Commands
-- Mass migration of economy and banking commands
-- ================================

-- ATM system
addCommandHandler("atm", function(player, cmd, action, amount)
    -- Check if near ATM
    local px, py, pz = getElementPosition(player)
    local atms = {
        {1494.3, -1029.2, 23.8}, -- Los Santos
        {2225.2, -1153.4, 25.7}, -- Los Santos 2
        {-2439.0, 518.9, 30.0}, -- San Fierro
        {2844.2, 1292.5, 11.4}, -- Las Venturas
        {1928.5, 960.1, 10.8} -- Las Venturas 2
    }
    
    local atATM = false
    for _, atm in ipairs(atms) do
        if getDistanceBetweenPoints3D(px, py, pz, atm[1], atm[2], atm[3]) < 3 then
            atATM = true
            break
        end
    end
    
    if not atATM then
        outputChatBox("❌ Ban can o gan ATM.", player, 255, 100, 100)
        return
    end
    
    local playerData = getElementData(player, "playerData") or {}
    
    if not action then
        outputChatBox("🏦 ===== ATM MENU =====", player, 255, 255, 0)
        outputChatBox("• /atm balance - Xem so du", player, 255, 255, 255)
        outputChatBox("• /atm deposit [amount] - Gui tien", player, 255, 255, 255)
        outputChatBox("• /atm withdraw [amount] - Rut tien", player, 255, 255, 255)
        outputChatBox("• /atm transfer [player] [amount] - Chuyen tien", player, 255, 255, 255)
        outputChatBox(string.format("• Current Cash: $%d", playerData.money or 0), player, 255, 255, 255)
        outputChatBox(string.format("• Bank Balance: $%d", playerData.bankMoney or 0), player, 255, 255, 255)
        return
    end
    
    if action == "balance" then
        local bankBalance = playerData.bankMoney or 0
        local cashBalance = playerData.money or 0
        outputChatBox(string.format("🏦 Bank Balance: $%d", bankBalance), player, 0, 255, 0)
        outputChatBox(string.format("💰 Cash Balance: $%d", cashBalance), player, 0, 255, 0)
        
    elseif action == "deposit" then
        if not amount then
            outputChatBox("Su dung: /atm deposit [amount]", player, 255, 255, 255)
            return
        end
        
        local depositAmount = tonumber(amount)
        if not depositAmount or depositAmount <= 0 then
            outputChatBox("❌ So tien khong hop le.", player, 255, 100, 100)
            return
        end
        
        if (playerData.money or 0) < depositAmount then
            outputChatBox("❌ Ban khong co du tien mat.", player, 255, 100, 100)
            return
        end
        
        playerData.money = (playerData.money or 0) - depositAmount
        playerData.bankMoney = (playerData.bankMoney or 0) + depositAmount
        setElementData(player, "playerData", playerData)
        
        outputChatBox(string.format("🏦 Da gui $%d vao bank. Balance: $%d", depositAmount, playerData.bankMoney), player, 0, 255, 0)
        
    elseif action == "withdraw" then
        if not amount then
            outputChatBox("Su dung: /atm withdraw [amount]", player, 255, 255, 255)
            return
        end
        
        local withdrawAmount = tonumber(amount)
        if not withdrawAmount or withdrawAmount <= 0 then
            outputChatBox("❌ So tien khong hop le.", player, 255, 100, 100)
            return
        end
        
        if (playerData.bankMoney or 0) < withdrawAmount then
            outputChatBox("❌ Bank balance khong du.", player, 255, 100, 100)
            return
        end
        
        playerData.bankMoney = (playerData.bankMoney or 0) - withdrawAmount
        playerData.money = (playerData.money or 0) + withdrawAmount
        setElementData(player, "playerData", playerData)
        
        outputChatBox(string.format("🏦 Da rut $%d tu bank. Balance: $%d", withdrawAmount, playerData.bankMoney), player, 0, 255, 0)
        
    elseif action == "transfer" then
        local targetName = amount -- Using amount param as target name
        local transferAmount = tonumber(cmd) -- This will be the third parameter
        
        if not targetName or not transferAmount then
            outputChatBox("Su dung: /atm transfer [player] [amount]", player, 255, 255, 255)
            return
        end
        
        local targetPlayer = getPlayerFromNameOrId(targetName)
        if not targetPlayer then
            outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
            return
        end
        
        if targetPlayer == player then
            outputChatBox("❌ Ban khong the transfer cho chinh minh.", player, 255, 100, 100)
            return
        end
        
        if transferAmount <= 0 then
            outputChatBox("❌ So tien khong hop le.", player, 255, 100, 100)
            return
        end
        
        if (playerData.bankMoney or 0) < transferAmount then
            outputChatBox("❌ Bank balance khong du.", player, 255, 100, 100)
            return
        end
        
        local targetData = getElementData(targetPlayer, "playerData") or {}
        
        playerData.bankMoney = (playerData.bankMoney or 0) - transferAmount
        targetData.bankMoney = (targetData.bankMoney or 0) + transferAmount
        
        setElementData(player, "playerData", playerData)
        setElementData(targetPlayer, "playerData", targetData)
        
        outputChatBox(string.format("🏦 Da transfer $%d cho %s.", transferAmount, getPlayerName(targetPlayer)), player, 0, 255, 0)
        outputChatBox(string.format("🏦 Nhan $%d tu %s via bank transfer.", transferAmount, getPlayerName(player)), targetPlayer, 0, 255, 0)
    end
end)

-- Bank system
addCommandHandler("bank", function(player)
    -- Check if at bank
    local px, py, pz = getElementPosition(player)
    local banks = {
        {1462.1, -1012.0, 26.8}, -- Los Santos
        {-2443.2, 518.9, 30.0}, -- San Fierro
        {2844.2, 1292.5, 11.4} -- Las Venturas
    }
    
    local atBank = false
    for _, bank in ipairs(banks) do
        if getDistanceBetweenPoints3D(px, py, pz, bank[1], bank[2], bank[3]) < 5 then
            atBank = true
            break
        end
    end
    
    if not atBank then
        outputChatBox("❌ Ban can o trong bank.", player, 255, 100, 100)
        return
    end
    
    local playerData = getElementData(player, "playerData") or {}
    
    outputChatBox("🏦 ===== BANK SERVICES =====", player, 255, 255, 0)
    outputChatBox("• Su dung ATM de deposit/withdraw/transfer", player, 255, 255, 255)
    outputChatBox("• /loan [amount] - Vay tien", player, 255, 255, 255)
    outputChatBox("• /payloan [amount] - Tra no", player, 255, 255, 255)
    outputChatBox("• /loaninfo - Thong tin loan", player, 255, 255, 255)
    outputChatBox(string.format("• Bank Balance: $%d", playerData.bankMoney or 0), player, 255, 255, 255)
    outputChatBox(string.format("• Outstanding Loan: $%d", playerData.loan or 0), player, 255, 255, 255)
end)

-- Loan system
addCommandHandler("loan", function(player, cmd, amount)
    local px, py, pz = getElementPosition(player)
    local banks = {
        {1462.1, -1012.0, 26.8}, -- Los Santos
        {-2443.2, 518.9, 30.0}, -- San Fierro
        {2844.2, 1292.5, 11.4} -- Las Venturas
    }
    
    local atBank = false
    for _, bank in ipairs(banks) do
        if getDistanceBetweenPoints3D(px, py, pz, bank[1], bank[2], bank[3]) < 5 then
            atBank = true
            break
        end
    end
    
    if not atBank then
        outputChatBox("❌ Ban can o trong bank de vay tien.", player, 255, 100, 100)
        return
    end
    
    if not amount then
        outputChatBox("Su dung: /loan [amount] (max: $50000)", player, 255, 255, 255)
        return
    end
    
    local loanAmount = tonumber(amount)
    if not loanAmount or loanAmount <= 0 or loanAmount > 50000 then
        outputChatBox("❌ So tien vay khong hop le (max: $50000).", player, 255, 100, 100)
        return
    end
    
    local playerData = getElementData(player, "playerData") or {}
    
    if (playerData.loan or 0) > 0 then
        outputChatBox("❌ Ban da co loan roi. Tra no truoc.", player, 255, 100, 100)
        return
    end
    
    -- Give loan with 10% interest
    local totalLoan = math.floor(loanAmount * 1.1)
    playerData.loan = totalLoan
    playerData.bankMoney = (playerData.bankMoney or 0) + loanAmount
    setElementData(player, "playerData", playerData)
    
    outputChatBox(string.format("🏦 Da vay $%d. Can tra $%d (bao gom 10%% interest).", loanAmount, totalLoan), player, 0, 255, 0)
end)

-- Pay loan
addCommandHandler("payloan", function(player, cmd, amount)
    local playerData = getElementData(player, "playerData") or {}
    
    if (playerData.loan or 0) <= 0 then
        outputChatBox("❌ Ban khong co loan nao.", player, 255, 100, 100)
        return
    end
    
    if not amount then
        outputChatBox(string.format("Su dung: /payloan [amount] (Outstanding: $%d)", playerData.loan), player, 255, 255, 255)
        return
    end
    
    local payAmount = tonumber(amount)
    if not payAmount or payAmount <= 0 then
        outputChatBox("❌ So tien khong hop le.", player, 255, 100, 100)
        return
    end
    
    if (playerData.bankMoney or 0) < payAmount then
        outputChatBox("❌ Bank balance khong du.", player, 255, 100, 100)
        return
    end
    
    local currentLoan = playerData.loan
    local actualPay = math.min(payAmount, currentLoan)
    
    playerData.bankMoney = (playerData.bankMoney or 0) - actualPay
    playerData.loan = currentLoan - actualPay
    setElementData(player, "playerData", playerData)
    
    if playerData.loan <= 0 then
        outputChatBox("🏦 Da tra het loan! Ban khong con no nua.", player, 0, 255, 0)
    else
        outputChatBox(string.format("🏦 Da tra $%d. Con lai: $%d", actualPay, playerData.loan), player, 0, 255, 0)
    end
end)

-- Loan info
addCommandHandler("loaninfo", function(player)
    local playerData = getElementData(player, "playerData") or {}
    
    if (playerData.loan or 0) <= 0 then
        outputChatBox("🏦 Ban khong co loan nao.", player, 0, 255, 0)
        return
    end
    
    outputChatBox("🏦 ===== LOAN INFO =====", player, 255, 255, 0)
    outputChatBox(string.format("• Outstanding Amount: $%d", playerData.loan), player, 255, 255, 255)
    outputChatBox("• Interest Rate: 10%", player, 255, 255, 255)
    outputChatBox("• Use /payloan [amount] to pay", player, 255, 255, 255)
end)

-- Salary system
addCommandHandler("salary", function(player)
    local playerData = getElementData(player, "playerData") or {}
    
    local lastSalary = playerData.lastSalary or 0
    local currentTime = getRealTime().timestamp
    
    -- Check if 24 hours have passed (86400 seconds)
    if currentTime - lastSalary < 86400 then
        local timeLeft = 86400 - (currentTime - lastSalary)
        local hoursLeft = math.floor(timeLeft / 3600)
        local minutesLeft = math.floor((timeLeft % 3600) / 60)
        outputChatBox(string.format("⏰ Can cho %d gio %d phut nua de nhan salary.", hoursLeft, minutesLeft), player, 255, 255, 100)
        return
    end
    
    -- Calculate salary based on job and level
    local baseSalary = 1000
    local jobMultiplier = 1
    local levelBonus = (playerData.level or 1) * 50
    
    if playerData.job then
        local jobMultipliers = {
            ["Police"] = 1.5,
            ["Medic"] = 1.4,
            ["Taxi Driver"] = 1.2,
            ["Mechanic"] = 1.3,
            ["Trucker"] = 1.25,
            ["Pilot"] = 1.6
        }
        jobMultiplier = jobMultipliers[playerData.job] or 1
    end
    
    local totalSalary = math.floor((baseSalary * jobMultiplier) + levelBonus)
    
    playerData.money = (playerData.money or 0) + totalSalary
    playerData.lastSalary = currentTime
    setElementData(player, "playerData", playerData)
    
    outputChatBox(string.format("💰 Da nhan salary $%d! (Base: $%d, Job: x%.1f, Level bonus: $%d)", 
        totalSalary, baseSalary, jobMultiplier, levelBonus), player, 0, 255, 0)
end)

-- Lottery system
addCommandHandler("lottery", function(player, cmd, action, numbers)
    if not action then
        outputChatBox("🎰 ===== LOTTERY =====", player, 255, 255, 0)
        outputChatBox("• /lottery buy [6 numbers] - Mua ve so", player, 255, 255, 255)
        outputChatBox("• /lottery check - Kiem tra ket qua", player, 255, 255, 255)
        outputChatBox("• /lottery info - Thong tin jackpot", player, 255, 255, 255)
        outputChatBox("• Gia ve: $100, Jackpot hien tai: $50000", player, 255, 255, 255)
        return
    end
    
    if action == "buy" then
        if not numbers then
            outputChatBox("Su dung: /lottery buy [6 numbers] (vd: 123456)", player, 255, 255, 255)
            return
        end
        
        if string.len(numbers) ~= 6 then
            outputChatBox("❌ Can dung 6 so.", player, 255, 100, 100)
            return
        end
        
        local playerData = getElementData(player, "playerData") or {}
        if (playerData.money or 0) < 100 then
            outputChatBox("❌ Ban can $100 de mua ve so.", player, 255, 100, 100)
            return
        end
        
        playerData.money = (playerData.money or 0) - 100
        playerData.lotteryNumbers = numbers
        setElementData(player, "playerData", playerData)
        
        outputChatBox(string.format("🎰 Da mua ve so voi so %s ($100).", numbers), player, 0, 255, 0)
        
    elseif action == "check" then
        local playerData = getElementData(player, "playerData") or {}
        if not playerData.lotteryNumbers then
            outputChatBox("❌ Ban chua mua ve so nao.", player, 255, 100, 100)
            return
        end
        
        -- Generate random winning numbers
        local winningNumbers = ""
        for i = 1, 6 do
            winningNumbers = winningNumbers .. math.random(0, 9)
        end
        
        outputChatBox(string.format("🎰 So trung thuong: %s", winningNumbers), player, 255, 255, 0)
        outputChatBox(string.format("🎰 So cua ban: %s", playerData.lotteryNumbers), player, 255, 255, 0)
        
        -- Check matches
        local matches = 0
        for i = 1, 6 do
            if string.sub(playerData.lotteryNumbers, i, i) == string.sub(winningNumbers, i, i) then
                matches = matches + 1
            end
        end
        
        local prizes = {
            [6] = 50000, [5] = 10000, [4] = 2000, [3] = 500, [2] = 100
        }
        
        if prizes[matches] then
            playerData.money = (playerData.money or 0) + prizes[matches]
            setElementData(player, "playerData", playerData)
            outputChatBox(string.format("🎉 CHUC MUNG! %d so trung, nhan $%d!", matches, prizes[matches]), player, 0, 255, 0)
        else
            outputChatBox(string.format("❌ Chi trung %d so. Khong co giai.", matches), player, 255, 100, 100)
        end
        
        playerData.lotteryNumbers = nil
        setElementData(player, "playerData", playerData)
        
    elseif action == "info" then
        outputChatBox("🎰 ===== LOTTERY INFO =====", player, 255, 255, 0)
        outputChatBox("• 6 so trung: $50,000", player, 255, 255, 255)
        outputChatBox("• 5 so trung: $10,000", player, 255, 255, 255)
        outputChatBox("• 4 so trung: $2,000", player, 255, 255, 255)
        outputChatBox("• 3 so trung: $500", player, 255, 255, 255)
        outputChatBox("• 2 so trung: $100", player, 255, 255, 255)
    end
end)

-- Money drop
addCommandHandler("dropmoney", function(player, cmd, amount)
    if not amount then
        outputChatBox("Su dung: /dropmoney [amount]", player, 255, 255, 255)
        return
    end
    
    local dropAmount = tonumber(amount)
    if not dropAmount or dropAmount <= 0 then
        outputChatBox("❌ So tien khong hop le.", player, 255, 100, 100)
        return
    end
    
    local playerData = getElementData(player, "playerData") or {}
    if (playerData.money or 0) < dropAmount then
        outputChatBox("❌ Ban khong co du tien.", player, 255, 100, 100)
        return
    end
    
    playerData.money = (playerData.money or 0) - dropAmount
    setElementData(player, "playerData", playerData)
    
    -- Create money pickup
    local x, y, z = getElementPosition(player)
    local pickup = createPickup(x, y, z, 3, 1212, 0, dropAmount) -- Money icon
    setElementData(pickup, "moneyAmount", dropAmount)
    
    outputChatBox(string.format("💰 Da drop $%d.", dropAmount), player, 255, 255, 100)
    
    -- Auto destroy after 10 minutes
    setTimer(function()
        if isElement(pickup) then
            destroyElement(pickup)
        end
    end, 600000, 1)
end)

-- Money pickup handler
addEventHandler("onPickupHit", getResourceRootElement(), function(player)
    if getElementType(player) == "player" then
        local moneyAmount = getElementData(source, "moneyAmount")
        if moneyAmount then
            local playerData = getElementData(player, "playerData") or {}
            playerData.money = (playerData.money or 0) + moneyAmount
            setElementData(player, "playerData", playerData)
            
            outputChatBox(string.format("💰 Da nhat $%d!", moneyAmount), player, 0, 255, 0)
            destroyElement(source)
        end
    end
end)

outputDebugString("[AMB] Economy & Banking system loaded - 8 commands")
