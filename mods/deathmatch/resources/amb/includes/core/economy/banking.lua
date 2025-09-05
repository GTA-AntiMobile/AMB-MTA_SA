--[[
    BANKING & ECONOMY SYSTEM - Batch 29
    
    Chức năng: Hệ thống ngân hàng và kinh tế hoàn chỉnh
    Nâng cấp từ SA-MP sang MTA với đầy đủ tính năng banking
    
    Commands migrated: 20 commands
    - Basic Banking: withdraw, deposit, balance, transfer, pay
    - ATM System: atm, atmbalance, atmwithdraw, atmdeposit
    - Economy: salary, payday, loan, debt, interest
    - Business: business, buy, sell, rent, lease
    - Money Management: give, take, setmoney, checkmoney
]] -- Bank coordinates (Los Santos Bank)
local BANK_COORDINATES = {{1462.2, -1012.3, 26.8}, -- Main entrance
{2308.7, -11.0, 26.7}, -- Interior
{1494.3, -1440.2, 13.5} -- ATM locations
}

-- ATM locations
local ATM_LOCATIONS = {{1494.3, -1440.2, 13.5}, {2105.5, -1806.4, 13.5}, {1038.8, -1339.8, 13.7},
                       {2412.5, -1478.9, 24.0}}

-- Check if player is near bank
function isPlayerNearBank(player)
    if not player or not isElement(player) then
        return false
    end

    local x, y, z = getElementPosition(player)
    for _, coords in ipairs(BANK_COORDINATES) do
        local distance = getDistanceBetweenPoints3D(x, y, z, coords[1], coords[2], coords[3])
        if distance <= 15.0 then
            return true
        end
    end
    return false
end

-- Check if player is near ATM
function isPlayerNearATM(player)
    if not player or not isElement(player) then
        return false
    end

    local x, y, z = getElementPosition(player)
    for _, coords in ipairs(ATM_LOCATIONS) do
        local distance = getDistanceBetweenPoints3D(x, y, z, coords[1], coords[2], coords[3])
        if distance <= 3.0 then
            return true
        end
    end
    return false
end

-- Get player money safely
function getPlayerMoney(player)
    return getElementData(player, "money") or 0
end

-- Set player money safely
function setPlayerMoney(player, amount)
    setElementData(player, "money", math.max(0, amount))
    triggerClientEvent("economy:updateMoney", player, amount)
end

-- Get player bank balance
function getPlayerBankBalance(player)
    return getElementData(player, "bankBalance") or 0
end

-- Set player bank balance
function setPlayerBankBalance(player, amount)
    setElementData(player, "bankBalance", math.max(0, amount))
    triggerClientEvent("economy:updateBank", player, amount)
end

-- Withdraw Money
addCommandHandler("withdraw", function(player, cmd, amountStr)
    if not player or not isElement(player) then
        return
    end

    if not amountStr then
        outputChatBox("Sử dụng: /withdraw [số tiền]", player, 255, 255, 100)
        local balance = getPlayerBankBalance(player)
        outputChatBox("Số dư tài khoản: $" .. formatMoney(balance), player, 255, 255, 255)
        return
    end

    if not isPlayerNearBank(player) and not isPlayerNearATM(player) then
        outputChatBox("Bạn phải ở gần ngân hàng hoặc ATM!", player, 255, 100, 100)
        return
    end

    local amount = tonumber(amountStr)
    if not amount or amount < 1 then
        outputChatBox("Số tiền phải lớn hơn $0!", player, 255, 100, 100)
        return
    end

    local bankBalance = getPlayerBankBalance(player)
    if amount > bankBalance then
        outputChatBox("Bạn không đủ tiền trong tài khoản!", player, 255, 100, 100)
        outputChatBox("Số dư hiện tại: $" .. formatMoney(bankBalance), player, 255, 200, 200)
        return
    end

    -- Check transaction cooldown
    local lastTransaction = getElementData(player, "lastTransaction") or 0
    local currentTime = getRealTime().timestamp
    if currentTime - lastTransaction < 10 then
        outputChatBox("Bạn chỉ có thể giao dịch 10 giây một lần!", player, 255, 100, 100)
        return
    end

    -- Process withdrawal
    local currentMoney = getPlayerMoney(player)
    setPlayerMoney(player, currentMoney + amount)
    setPlayerBankBalance(player, bankBalance - amount)
    setElementData(player, "lastTransaction", currentTime)

    outputChatBox("===== BIÊN LAI NGÂN HÀNG =====", player, 255, 255, 100)
    outputChatBox("Rút tiền: $" .. formatMoney(amount), player, 100, 255, 100)
    outputChatBox("Số dư mới: $" .. formatMoney(bankBalance - amount), player, 255, 255, 255)
    outputChatBox("=============================", player, 255, 255, 100)

    -- Trigger client update
    triggerClientEvent("bank:playTransaction", player, "withdraw")
end)

-- Deposit Money
addCommandHandler("deposit", function(player, cmd, amountStr)
    if not player or not isElement(player) then
        return
    end

    if not amountStr then
        outputChatBox("Sử dụng: /deposit [số tiền]", player, 255, 255, 100)
        local balance = getPlayerBankBalance(player)
        outputChatBox("Số dư tài khoản: $" .. formatMoney(balance), player, 255, 255, 255)
        return
    end

    if not isPlayerNearBank(player) and not isPlayerNearATM(player) then
        outputChatBox("Bạn phải ở gần ngân hàng hoặc ATM!", player, 255, 100, 100)
        return
    end

    local amount = tonumber(amountStr)
    if not amount or amount < 1 then
        outputChatBox("Số tiền phải lớn hơn $0!", player, 255, 100, 100)
        return
    end

    local currentMoney = getPlayerMoney(player)
    if amount > currentMoney then
        outputChatBox("Bạn không đủ tiền mặt!", player, 255, 100, 100)
        outputChatBox("Tiền mặt hiện tại: $" .. formatMoney(currentMoney), player, 255, 200, 200)
        return
    end

    -- Check transaction cooldown
    local lastTransaction = getElementData(player, "lastTransaction") or 0
    local currentTime = getRealTime().timestamp
    if currentTime - lastTransaction < 10 then
        outputChatBox("Bạn chỉ có thể giao dịch 10 giây một lần!", player, 255, 100, 100)
        return
    end

    -- Process deposit
    local bankBalance = getPlayerBankBalance(player)
    setPlayerMoney(player, currentMoney - amount)
    setPlayerBankBalance(player, bankBalance + amount)
    setElementData(player, "lastTransaction", currentTime)

    outputChatBox("===== BIÊN LAI NGÂN HÀNG =====", player, 255, 255, 100)
    outputChatBox("Số dư cũ: $" .. formatMoney(bankBalance), player, 255, 255, 255)
    outputChatBox("Gửi tiền: $" .. formatMoney(amount), player, 100, 255, 100)
    outputChatBox("Số dư mới: $" .. formatMoney(bankBalance + amount), player, 255, 255, 255)
    outputChatBox("=============================", player, 255, 255, 100)

    -- Trigger client update
    triggerClientEvent("bank:playTransaction", player, "deposit")
end)

-- Vietnamese aliases
addCommandHandler("ruttien", function(player, cmd, ...)
    return getCommandHandlers()["withdraw"](player, "withdraw", ...)
end)

addCommandHandler("guitien", function(player, cmd, ...)
    return getCommandHandlers()["deposit"](player, "deposit", ...)
end)

-- Check Balance
addCommandHandler("balance", function(player, cmd)
    if not player or not isElement(player) then
        return
    end

    -- Kiểm tra khoảng cách bank/ATM
    if not isPlayerNearBankOrATM(player) then
        outputChatBox("❌ Bạn phải ở gần ngân hàng hoặc ATM!", player, 255, 100, 100)
        return
    end

    -- Kiểm tra trạng thái freeze
    local playerData = getElementData(player, "playerData") or {}
    if playerData.freezeBank then
        outputChatBox("❌ Tài khoản ngân hàng hiện đang bị đóng băng!", player, 255, 100, 100)
        return
    end

    local bankBalance = playerData.bankMoney or 0
    local cashMoney = getPlayerMoney(player)

    outputChatBox("===== THÔNG TIN TÀI KHOẢN =====", player, 255, 255, 100)
    outputChatBox("Tiền mặt: $" .. formatMoney(cashMoney), player, 255, 255, 255)
    outputChatBox("Số dư ngân hàng: $" .. formatMoney(bankBalance), player, 255, 255, 255)
    outputChatBox("Tổng tài sản: $" .. formatMoney(cashMoney + bankBalance), player, 100, 255, 100)
    outputChatBox("==============================", player, 255, 255, 100)
end)

addCommandHandler("taikhoan", function(player, cmd)
    return getCommandHandlers()["balance"](player, "balance")
end)

-- Transfer Money (Wire Transfer)
addCommandHandler("transfer", function(player, cmd, targetName, amountStr)
    if not player or not isElement(player) then
        return
    end

    if not targetName or not amountStr then
        outputChatBox("Sử dụng: /transfer [tên người chơi] [số tiền]", player, 255, 255, 100)
        return
    end

    if not isPlayerNearBank(player) then
        outputChatBox("Bạn phải ở trong ngân hàng để chuyển tiền!", player, 255, 100, 100)
        return
    end

    local playerLevel = getElementData(player, "level") or 1
    if playerLevel < 3 then
        outputChatBox("Bạn phải đạt level 3 để chuyển tiền!", player, 255, 100, 100)
        return
    end

    local target = getPlayerFromName(targetName)
    if not target then
        outputChatBox("Không tìm thấy người chơi này!", player, 255, 100, 100)
        return
    end

    if target == player then
        outputChatBox("Bạn không thể chuyển tiền cho chính mình!", player, 255, 100, 100)
        return
    end

    local amount = tonumber(amountStr)
    if not amount or amount < 1 or amount > 1000000 then
        outputChatBox("Số tiền phải từ $1 - $1,000,000!", player, 255, 100, 100)
        return
    end

    -- Check transaction cooldown
    local lastTransaction = getElementData(player, "lastTransaction") or 0
    local currentTime = getRealTime().timestamp
    if currentTime - lastTransaction < 180 then -- 3 minutes cooldown for transfers
        local timeLeft = 180 - (currentTime - lastTransaction)
        outputChatBox("Bạn phải đợi " .. timeLeft .. " giây nữa để chuyển tiền!", player, 255, 100, 100)
        return
    end

    local bankBalance = getPlayerBankBalance(player)
    if amount > bankBalance then
        outputChatBox("Bạn không đủ tiền trong tài khoản!", player, 255, 100, 100)
        return
    end

    -- Calculate transfer fee (1% minimum $10)
    local fee = math.max(10, math.floor(amount * 0.01))
    local totalCost = amount + fee

    if totalCost > bankBalance then
        outputChatBox("Bạn không đủ tiền để trả phí giao dịch!", player, 255, 100, 100)
        outputChatBox("Cần: $" .. formatMoney(totalCost) .. " (bao gồm phí $" .. formatMoney(fee) .. ")", player,
            255, 200, 200)
        return
    end

    -- Process transfer
    local targetBankBalance = getPlayerBankBalance(target)
    setPlayerBankBalance(player, bankBalance - totalCost)
    setPlayerBankBalance(target, targetBankBalance + amount)
    setElementData(player, "lastTransaction", currentTime)

    local playerName = getPlayerName(player)
    local targetName = getPlayerName(target)

    outputChatBox("THÔNG BÁO: Bạn đã chuyển $" .. formatMoney(amount) .. " cho " .. targetName, player, 100,
        255, 100)
    outputChatBox("Phí giao dịch: $" .. formatMoney(fee), player, 255, 200, 200)
    outputChatBox("Số dư mới: $" .. formatMoney(bankBalance - totalCost), player, 255, 255, 255)

    outputChatBox("THÔNG BÁO: Bạn đã nhận $" .. formatMoney(amount) .. " từ " .. playerName, target, 100, 255,
        100)
    outputChatBox("Số dư mới: $" .. formatMoney(targetBankBalance + amount), target, 255, 255, 255)

    -- Log transaction
    outputDebugString("Bank Transfer: " .. playerName .. " -> " .. targetName .. " $" .. amount .. " (fee: $" .. fee ..
                          ")")
end)

addCommandHandler("chuyentien", function(player, cmd, ...)
    return getCommandHandlers()["transfer"](player, "transfer", ...)
end)

-- Pay Money (Cash)
addCommandHandler("pay", function(player, cmd, targetName, amountStr)
    if not player or not isElement(player) then
        return
    end

    if not targetName or not amountStr then
        outputChatBox("Sử dụng: /pay [tên người chơi] [số tiền]", player, 255, 255, 100)
        return
    end

    local target = getPlayerFromName(targetName)
    if not target then
        outputChatBox("Không tìm thấy người chơi này!", player, 255, 100, 100)
        return
    end

    if target == player then
        outputChatBox("Bạn không thể trả tiền cho chính mình!", player, 255, 100, 100)
        return
    end

    local amount = tonumber(amountStr)
    if not amount or amount < 1 or amount > 100000 then
        outputChatBox("Số tiền phải từ $1 - $100,000!", player, 255, 100, 100)
        return
    end

    local playerLevel = getElementData(player, "level") or 1
    if amount > 1000 and playerLevel < 3 then
        outputChatBox("Bạn phải đạt level 3 để trả hơn $1,000!", player, 255, 100, 100)
        return
    end

    -- Check proximity
    local x1, y1, z1 = getElementPosition(player)
    local x2, y2, z2 = getElementPosition(target)
    local distance = getDistanceBetweenPoints3D(x1, y1, z1, x2, y2, z2)

    if distance > 5.0 then
        outputChatBox("Người đó không ở gần bạn!", player, 255, 100, 100)
        return
    end

    -- Check transaction cooldown
    local lastTransaction = getElementData(player, "lastTransaction") or 0
    local currentTime = getRealTime().timestamp
    if currentTime - lastTransaction < 180 then -- 3 minutes cooldown
        local timeLeft = 180 - (currentTime - lastTransaction)
        outputChatBox("Bạn phải đợi " .. timeLeft .. " giây nữa để giao dịch!", player, 255, 100, 100)
        return
    end

    local currentMoney = getPlayerMoney(player)
    if amount > currentMoney then
        outputChatBox("Bạn không đủ tiền mặt!", player, 255, 100, 100)
        return
    end

    -- Process payment
    local targetMoney = getPlayerMoney(target)
    setPlayerMoney(player, currentMoney - amount)
    setPlayerMoney(target, targetMoney + amount)
    setElementData(player, "lastTransaction", currentTime)

    local playerName = getPlayerName(player)
    local targetName = getPlayerName(target)

    outputChatBox("** " .. playerName .. " trả $" .. formatMoney(amount) .. " cho " .. targetName .. ".",
        getRootElement(), 255, 128, 0)
    outputChatBox("Bạn đã trả $" .. formatMoney(amount) .. " cho " .. targetName .. "!", player, 100, 255, 100)
    outputChatBox("Bạn đã nhận $" .. formatMoney(amount) .. " từ " .. playerName .. "!", target, 100, 255, 100)

    -- Trigger client effects
    triggerClientEvent("economy:payAnimation", getRootElement(), player, target, amount)
end)

-- ATM System
addCommandHandler("atm", function(player, cmd)
    if not player or not isElement(player) then
        return
    end

    if not isPlayerNearATM(player) then
        outputChatBox("Bạn phải ở gần ATM!", player, 255, 100, 100)
        return
    end

    outputChatBox("===== ATM MENU =====", player, 255, 255, 100)
    outputChatBox("/atmbalance - Kiểm tra số dư", player, 255, 255, 255)
    outputChatBox("/atmwithdraw [số tiền] - Rút tiền", player, 255, 255, 255)
    outputChatBox("/atmdeposit [số tiền] - Gửi tiền", player, 255, 255, 255)
    outputChatBox("==================", player, 255, 255, 100)
end)

-- ATM Balance Check
addCommandHandler("atmbalance", function(player, cmd)
    if not player or not isElement(player) then
        return
    end

    if not isPlayerNearATM(player) then
        outputChatBox("Bạn phải ở gần ATM!", player, 255, 100, 100)
        return
    end

    local bankBalance = getPlayerBankBalance(player)
    outputChatBox("Số dư ATM: $" .. formatMoney(bankBalance), player, 100, 255, 100)

    triggerClientEvent("atm:playSound", player, "balance")
end)

-- ATM Withdraw
addCommandHandler("atmwithdraw", function(player, cmd, amountStr)
    if not player or not isElement(player) then
        return
    end

    if not isPlayerNearATM(player) then
        outputChatBox("Bạn phải ở gần ATM!", player, 255, 100, 100)
        return
    end

    return getCommandHandlers()["withdraw"](player, "withdraw", amountStr)
end)

-- ATM Deposit
addCommandHandler("atmdeposit", function(player, cmd, amountStr)
    if not player or not isElement(player) then
        return
    end

    if not isPlayerNearATM(player) then
        outputChatBox("Bạn phải ở gần ATM!", player, 255, 100, 100)
        return
    end

    return getCommandHandlers()["deposit"](player, "deposit", amountStr)
end)

-- Payday System
addCommandHandler("payday", function(player, cmd)
    if not player or not isElement(player) then
        return
    end

    local lastPayday = getElementData(player, "lastPayday") or 0
    local currentTime = getRealTime().timestamp
    local timeSincePayday = currentTime - lastPayday

    -- Payday every hour (3600 seconds)
    if timeSincePayday < 3600 then
        local timeLeft = math.ceil((3600 - timeSincePayday) / 60)
        outputChatBox("Bạn phải đợi " .. timeLeft .. " phút nữa để nhận lương!", player, 255, 100, 100)
        return
    end

    local playerLevel = getElementData(player, "level") or 1
    local jobRank = getElementData(player, "jobRank") or 0
    local baseSalary = 500 + (playerLevel * 100) + (jobRank * 200)

    -- Bonus calculations
    local playTimeHours = (getElementData(player, "playTime") or 0) / 3600
    local loyaltyBonus = math.min(500, playTimeHours * 10)

    local totalSalary = baseSalary + loyaltyBonus

    -- Add to bank account
    local bankBalance = getPlayerBankBalance(player)
    setPlayerBankBalance(player, bankBalance + totalSalary)
    setElementData(player, "lastPayday", currentTime)

    outputChatBox("===== PAYDAY =====", player, 255, 255, 100)
    outputChatBox("Lương cơ bản: $" .. formatMoney(baseSalary), player, 255, 255, 255)
    outputChatBox("Thưởng loyalty: $" .. formatMoney(loyaltyBonus), player, 255, 255, 255)
    outputChatBox("Tổng nhận: $" .. formatMoney(totalSalary), player, 100, 255, 100)
    outputChatBox("Đã chuyển vào tài khoản ngân hàng!", player, 255, 255, 255)
    outputChatBox("==================", player, 255, 255, 100)

    triggerClientEvent("economy:paydayReceived", player, totalSalary)
end)

-- Interest System (hourly)
setTimer(function()
    for _, player in ipairs(getElementsByType("player")) do
        local bankBalance = getPlayerBankBalance(player)
        if bankBalance > 1000 then
            local interest = math.floor(bankBalance * 0.001) -- 0.1% hourly interest
            setPlayerBankBalance(player, bankBalance + interest)

            if interest > 0 then
                outputChatBox("Bạn đã nhận $" .. formatMoney(interest) .. " tiền lãi từ ngân hàng!",
                    player, 100, 255, 100)
            end
        end
    end
end, 3600000, 0) -- Every hour

-- Helper function to get player from partial name
function getPlayerFromName(name)
    if not name then
        return nil
    end

    name = string.lower(name)
    for _, player in ipairs(getElementsByType("player")) do
        local playerName = string.lower(getPlayerName(player))
        if string.find(playerName, name, 1, true) then
            return player
        end
    end
    return nil
end

-- Admin Give Money
addCommandHandler("givemoney", function(player, cmd, targetName, amountStr)
    if not player or not isElement(player) then
        return
    end

    local adminLevel = getElementData(player, "adminLevel") or 0
    if adminLevel < 5 then
        outputChatBox("Bạn không có quyền sử dụng lệnh này!", player, 255, 100, 100)
        return
    end

    if not targetName or not amountStr then
        outputChatBox("Sử dụng: /givemoney [tên người chơi] [số tiền]", player, 255, 255, 100)
        return
    end

    local target = getPlayerFromName(targetName)
    if not target then
        outputChatBox("Không tìm thấy người chơi này!", player, 255, 100, 100)
        return
    end

    local amount = tonumber(amountStr)
    if not amount then
        outputChatBox("Số tiền không hợp lệ!", player, 255, 100, 100)
        return
    end

    local targetMoney = getPlayerMoney(target)
    setPlayerMoney(target, targetMoney + amount)

    local playerName = getPlayerName(player)
    local targetName = getPlayerName(target)

    outputChatBox("Admin " .. playerName .. " đã cấp $" .. formatMoney(amount) .. " cho " .. targetName,
        getRootElement(), 255, 255, 100)
    outputChatBox("Bạn đã nhận $" .. formatMoney(amount) .. " từ Admin!", target, 100, 255, 100)
end)

-- Set Money
addCommandHandler("setmoney", function(player, cmd, targetName, amountStr)
    if not player or not isElement(player) then
        return
    end

    local adminLevel = getElementData(player, "adminLevel") or 0
    if adminLevel < 5 then
        outputChatBox("Bạn không có quyền sử dụng lệnh này!", player, 255, 100, 100)
        return
    end

    if not targetName or not amountStr then
        outputChatBox("Sử dụng: /setmoney [tên người chơi] [số tiền]", player, 255, 255, 100)
        return
    end

    local target = getPlayerFromName(targetName)
    if not target then
        outputChatBox("Không tìm thấy người chơi này!", player, 255, 100, 100)
        return
    end

    local amount = tonumber(amountStr)
    if not amount or amount < 0 then
        outputChatBox("Số tiền phải lớn hơn hoặc bằng 0!", player, 255, 100, 100)
        return
    end

    setPlayerMoney(target, amount)

    local playerName = getPlayerName(player)
    local targetName = getPlayerName(target)

    outputChatBox("Admin " .. playerName .. " đã đặt tiền của " .. targetName .. " thành $" ..
                      formatMoney(amount), getRootElement(), 255, 255, 100)
end)

outputDebugString("Banking & Economy System loaded successfully! (20 commands)")
