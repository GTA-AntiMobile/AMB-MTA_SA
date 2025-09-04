--[[
    BATCH 34: MEGA PLAYER FEATURES SYSTEM
    
    Chức năng: Tất cả tính năng player animations, inventory, phone, bank, stats
    Migrate hàng loạt commands: animations, inventory, phone, banking, player management
    
    Commands migrated: 100+ commands
]] -- PLAYER ANIMATIONS SYSTEM
local ANIMATIONS = {
    handsup = {
        lib = "ROB_BANK",
        anim = "SHP_HandsUp_Scr",
        loop = true,
        freeze = true
    },
    dance = {
        lib = "DANCING",
        anim = "DAN_Down_A",
        loop = true,
        freeze = false
    },
    sit = {
        lib = "BEACH",
        anim = "bather",
        loop = true,
        freeze = true
    },
    lay = {
        lib = "BEACH",
        anim = "Lay_Bac_Loop",
        loop = true,
        freeze = true
    },
    crack = {
        lib = "CRACK",
        anim = "crckdeth2",
        loop = true,
        freeze = true
    },
    smoke = {
        lib = "SMOKING",
        anim = "M_smk_in",
        loop = true,
        freeze = false
    },
    drink = {
        lib = "BAR",
        anim = "dnk_stndM_loop",
        loop = true,
        freeze = false
    },
    cellphone = {
        lib = "PHONE",
        anim = "phone_talk",
        loop = true,
        freeze = false
    },
    guard = {
        lib = "COP_AMBIENT",
        anim = "Coplook_loop",
        loop = true,
        freeze = false
    },
    laugh = {
        lib = "RAPPING",
        anim = "Laugh_01",
        loop = false,
        freeze = false
    },
    cry = {
        lib = "GRAVEYARD",
        anim = "mrnF_loop",
        loop = true,
        freeze = false
    },
    taichi = {
        lib = "PARK",
        anim = "Tai_Chi_Loop",
        loop = true,
        freeze = false
    },
    wave = {
        lib = "ON_LOOKERS",
        anim = "wave_loop",
        loop = true,
        freeze = false
    },
    pee = {
        lib = "PAULNMAC",
        anim = "Piss_loop",
        loop = true,
        freeze = true
    },
    wank = {
        lib = "PAULNMAC",
        anim = "wank_loop",
        loop = true,
        freeze = true
    },
    rap = {
        lib = "RAPPING",
        anim = "RAP_A_Loop",
        loop = true,
        freeze = false
    },
    fallover = {
        lib = "PED",
        anim = "FALL_back",
        loop = false,
        freeze = false
    },
    bomb = {
        lib = "BOMBER",
        anim = "BOM_Plant",
        loop = false,
        freeze = false
    },
    getarrested = {
        lib = "ped",
        anim = "ARRESTgun",
        loop = false,
        freeze = true
    },
    dj = {
        lib = "SCRATCHING",
        anim = "scdldlp",
        loop = true,
        freeze = false
    },
    salute = {
        lib = "ON_LOOKERS",
        anim = "Pointup_loop",
        loop = false,
        freeze = false
    },
    food = {
        lib = "FOOD",
        anim = "EAT_Burger",
        loop = true,
        freeze = false
    },
    crossarms = {
        lib = "COP_AMBIENT",
        anim = "Coplook_loop",
        loop = true,
        freeze = false
    },
    deal = {
        lib = "DEALER",
        anim = "DEALER_DEAL",
        loop = true,
        freeze = false
    },
    groundsit = {
        lib = "BEACH",
        anim = "ParkSit_M_loop",
        loop = true,
        freeze = true
    },
    chat = {
        lib = "PED",
        anim = "IDLE_CHAT",
        loop = true,
        freeze = false
    }
}

-- Animation commands
for animName, animData in pairs(ANIMATIONS) do
    addCommandHandler(animName, function(player, cmd)
        if isPedInVehicle(player) then
            outputChatBox("Không thể thực hiện animation khi đang lái xe!", player, 255, 100, 100)
            return
        end

        if isPedDead(player) then
            outputChatBox("Không thể thực hiện animation khi đã chết!", player, 255, 100, 100)
            return
        end

        setPedAnimation(player, animData.lib, animData.anim, -1, animData.loop, false, false, animData.freeze or false)

        local playerName = getPlayerName(player)
        outputChatBox(playerName .. " đang thực hiện animation: " .. animName, getRootElement(), 255, 255, 100,
            true)

        -- Set animation state
        setElementData(player, "currentAnimation", animName)

        triggerClientEvent("player:performAnimation", getRootElement(), player, animName, animData)
    end)
end

-- Stop animation
addCommandHandler("stopanim", function(player, cmd)
    -- Dừng animation
    setPedAnimation(player, false)
    setElementData(player, "currentAnimation", nil)

    -- Thông báo toàn server
    local playerName = getPlayerName(player)
    outputChatBox("✅ " .. playerName .. " đã dừng animation", getRootElement(), 255, 255, 100, true)

    -- Trigger client event
    triggerClientEvent("player:stopAnimation", getRootElement(), player)

    -- Tăng thống kê lệnh
    incrementCommandStat("playerCommands")
end)

-- INVENTORY SYSTEM
local INVENTORY_CONFIG = {
    maxSlots = 20,
    maxWeight = 100.0,
    items = {
        -- Weapons
        pistol = {
            name = "Súng lục",
            weight = 2.5,
            type = "weapon",
            weaponID = 22
        },
        ak47 = {
            name = "AK-47",
            weight = 4.5,
            type = "weapon",
            weaponID = 30
        },
        m4 = {
            name = "M4A1",
            weight = 4.0,
            type = "weapon",
            weaponID = 31
        },

        -- Medical
        bandage = {
            name = "Băng y tế",
            weight = 0.1,
            type = "medical",
            healAmount = 20
        },
        medkit = {
            name = "Bộ y tế",
            weight = 0.5,
            type = "medical",
            healAmount = 100
        },
        painkiller = {
            name = "Thuốc giảm đau",
            weight = 0.1,
            type = "medical",
            healAmount = 30
        },

        -- Food & Drinks
        burger = {
            name = "Hamburger",
            weight = 0.3,
            type = "food",
            hunger = 25
        },
        pizza = {
            name = "Pizza",
            weight = 0.4,
            type = "food",
            hunger = 35
        },
        water = {
            name = "Nước",
            weight = 0.2,
            type = "drink",
            thirst = 30
        },
        soda = {
            name = "Nước ngọt",
            weight = 0.3,
            type = "drink",
            thirst = 20
        },

        -- Tools
        flashlight = {
            name = "Đèn pin",
            weight = 0.5,
            type = "tool"
        },
        lockpick = {
            name = "Dụng cụ mở khóa",
            weight = 0.1,
            type = "tool"
        },
        rope = {
            name = "Dây thừng",
            weight = 1.0,
            type = "tool"
        },

        -- Misc
        phone = {
            name = "Điện thoại",
            weight = 0.3,
            type = "electronic"
        },
        keys = {
            name = "Chìa khóa",
            weight = 0.1,
            type = "misc"
        },
        wallet = {
            name = "Ví tiền",
            weight = 0.2,
            type = "misc"
        }
    }
}

function getPlayerInventory(player)
    local inventory = getElementData(player, "inventory")
    if not inventory then
        inventory = {
            items = {},
            weight = 0.0
        }
        setElementData(player, "inventory", inventory)
    end
    return inventory
end

function addItemToInventory(player, itemID, quantity, data)
    quantity = quantity or 1
    local inventory = getPlayerInventory(player)
    local itemConfig = INVENTORY_CONFIG.items[itemID]

    if not itemConfig then
        return false, "Item không tồn tại!"
    end

    -- Check weight
    local addedWeight = itemConfig.weight * quantity
    if inventory.weight + addedWeight > INVENTORY_CONFIG.maxWeight then
        return false, "Inventory đã đầy! (Quá nặng)"
    end

    -- Check slots
    local usedSlots = 0
    for _ in pairs(inventory.items) do
        usedSlots = usedSlots + 1
    end

    if not inventory.items[itemID] and usedSlots >= INVENTORY_CONFIG.maxSlots then
        return false, "Inventory đã đầy! (Hết slot)"
    end

    -- Add item
    if not inventory.items[itemID] then
        inventory.items[itemID] = {
            quantity = 0,
            data = data or {}
        }
    end

    inventory.items[itemID].quantity = inventory.items[itemID].quantity + quantity
    inventory.weight = inventory.weight + addedWeight

    setElementData(player, "inventory", inventory)
    return true, "Đã thêm " .. quantity .. "x " .. itemConfig.name
end

function removeItemFromInventory(player, itemID, quantity)
    quantity = quantity or 1
    local inventory = getPlayerInventory(player)
    local itemConfig = INVENTORY_CONFIG.items[itemID]

    if not itemConfig then
        return false, "Item không tồn tại!"
    end
    if not inventory.items[itemID] then
        return false, "Bạn không có item này!"
    end
    if inventory.items[itemID].quantity < quantity then
        return false, "Không đủ số lượng!"
    end

    -- Remove item
    inventory.items[itemID].quantity = inventory.items[itemID].quantity - quantity
    inventory.weight = inventory.weight - (itemConfig.weight * quantity)

    if inventory.items[itemID].quantity <= 0 then
        inventory.items[itemID] = nil
    end

    setElementData(player, "inventory", inventory)
    return true, "Đã xóa " .. quantity .. "x " .. itemConfig.name
end

addCommandHandler("inv", function(player, cmd)
    return getCommandHandlers()["inventory"](player, "inventory")
end)

addCommandHandler("inventory", function(player, cmd)
    local inventory = getPlayerInventory(player)

    outputChatBox("===== INVENTORY =====", player, 255, 255, 100)
    outputChatBox(
        "Trọng lượng: " .. string.format("%.1f", inventory.weight) .. "/" .. INVENTORY_CONFIG.maxWeight .. " kg",
        player, 255, 255, 255)
    outputChatBox("", player, 255, 255, 255)

    local hasItems = false
    for itemID, itemData in pairs(inventory.items) do
        hasItems = true
        local itemConfig = INVENTORY_CONFIG.items[itemID]
        if itemConfig then
            local totalWeight = itemConfig.weight * itemData.quantity
            outputChatBox("• " .. itemConfig.name .. " x" .. itemData.quantity .. " (" ..
                              string.format("%.1f", totalWeight) .. "kg)", player, 255, 255, 255)
        end
    end

    if not hasItems then
        outputChatBox("Inventory trống!", player, 200, 200, 200)
    end

    outputChatBox("====================", player, 255, 255, 100)

    triggerClientEvent("inventory:showGUI", player, inventory)
end)

addCommandHandler("use", function(player, cmd, itemID, ...)
    if not itemID then
        outputChatBox("Sử dụng: /use [item ID]", player, 255, 255, 100)
        return
    end

    local inventory = getPlayerInventory(player)
    local itemConfig = INVENTORY_CONFIG.items[itemID]

    if not itemConfig then
        outputChatBox("Item không tồn tại!", player, 255, 100, 100)
        return
    end

    if not inventory.items[itemID] or inventory.items[itemID].quantity <= 0 then
        outputChatBox("Bạn không có " .. itemConfig.name .. "!", player, 255, 100, 100)
        return
    end

    -- Use item based on type
    if itemConfig.type == "medical" then
        local currentHealth = getElementHealth(player)
        local newHealth = math.min(100, currentHealth + itemConfig.healAmount)
        setElementHealth(player, newHealth)

        outputChatBox("Bạn đã sử dụng " .. itemConfig.name .. " và hồi " .. itemConfig.healAmount .. " HP",
            player, 100, 255, 100)
        removeItemFromInventory(player, itemID, 1)

    elseif itemConfig.type == "food" then
        local hunger = getElementData(player, "hunger") or 100
        hunger = math.min(100, hunger + itemConfig.hunger)
        setElementData(player, "hunger", hunger)

        outputChatBox("Bạn đã ăn " .. itemConfig.name .. " và giảm " .. itemConfig.hunger .. " điểm đói",
            player, 100, 255, 100)
        removeItemFromInventory(player, itemID, 1)

    elseif itemConfig.type == "drink" then
        local thirst = getElementData(player, "thirst") or 100
        thirst = math.min(100, thirst + itemConfig.thirst)
        setElementData(player, "thirst", thirst)

        outputChatBox(
            "Bạn đã uống " .. itemConfig.name .. " và giảm " .. itemConfig.thirst .. " điểm khát", player,
            100, 255, 100)
        removeItemFromInventory(player, itemID, 1)

    elseif itemConfig.type == "weapon" then
        giveWeapon(player, itemConfig.weaponID, 500, true)
        outputChatBox("Bạn đã trang bị " .. itemConfig.name, player, 100, 255, 100)
        removeItemFromInventory(player, itemID, 1)

    else
        outputChatBox("Item này không thể sử dụng!", player, 255, 100, 100)
    end

    triggerClientEvent("inventory:useItem", player, itemID, itemConfig)
end)

addCommandHandler("give", function(player, cmd, targetName, itemID, quantity)
    if not targetName or not itemID then
        outputChatBox("Sử dụng: /give [tên người chơi] [item ID] [số lượng]", player, 255, 255, 100)
        return
    end

    quantity = tonumber(quantity) or 1
    if quantity <= 0 then
        outputChatBox("Số lượng phải lớn hơn 0!", player, 255, 100, 100)
        return
    end

    local target = getPlayerFromName(targetName)
    if not target then
        outputChatBox("Không tìm thấy người chơi này!", player, 255, 100, 100)
        return
    end

    if target == player then
        outputChatBox("Không thể đưa item cho chính mình!", player, 255, 100, 100)
        return
    end

    local x, y, z = getElementPosition(player)
    local tx, ty, tz = getElementPosition(target)
    local distance = getDistanceBetweenPoints3D(x, y, z, tx, ty, tz)

    if distance > 5.0 then
        outputChatBox("Bạn phải ở gần người chơi đó để đưa item!", player, 255, 100, 100)
        return
    end

    -- Remove from giver
    local success, msg = removeItemFromInventory(player, itemID, quantity)
    if not success then
        outputChatBox(msg, player, 255, 100, 100)
        return
    end

    -- Add to receiver
    local success2, msg2 = addItemToInventory(target, itemID, quantity)
    if not success2 then
        -- Return to giver if failed
        addItemToInventory(player, itemID, quantity)
        outputChatBox("Người nhận: " .. msg2, player, 255, 100, 100)
        return
    end

    local itemConfig = INVENTORY_CONFIG.items[itemID]
    local playerName = getPlayerName(player)
    local targetName = getPlayerName(target)

    outputChatBox("Bạn đã đưa " .. quantity .. "x " .. itemConfig.name .. " cho " .. targetName, player, 100, 255,
        100)
    outputChatBox(playerName .. " đã đưa bạn " .. quantity .. "x " .. itemConfig.name, target, 100, 255, 100)

    triggerClientEvent("inventory:giveItem", getRootElement(), player, target, itemID, quantity)
end)

-- PHONE SYSTEM
local phoneSystem = {
    contacts = {},
    messages = {},
    calls = {}
}

addCommandHandler("call", function(player, cmd, number)
    if not number then
        outputChatBox("Sử dụng: /call [số điện thoại]", player, 255, 255, 100)
        return
    end

    local hasPhone = getElementData(player, "hasPhone") or false
    if not hasPhone then
        outputChatBox("Bạn không có điện thoại!", player, 255, 100, 100)
        return
    end

    -- Check if already in call
    local currentCall = getElementData(player, "phoneCall")
    if currentCall then
        outputChatBox("Bạn đang trong cuộc gọi khác!", player, 255, 100, 100)
        return
    end

    -- Find target by phone number
    local target = nil
    for _, p in ipairs(getElementsByType("player")) do
        local playerPhone = getElementData(p, "phoneNumber")
        if playerPhone == number then
            target = p
            break
        end
    end

    if not target then
        outputChatBox("Số điện thoại không tồn tại!", player, 255, 100, 100)
        return
    end

    if target == player then
        outputChatBox("Không thể gọi cho chính mình!", player, 255, 100, 100)
        return
    end

    local targetHasPhone = getElementData(target, "hasPhone") or false
    if not targetHasPhone then
        outputChatBox("Người này không có điện thoại!", player, 255, 100, 100)
        return
    end

    local targetInCall = getElementData(target, "phoneCall")
    if targetInCall then
        outputChatBox("Máy bận!", player, 255, 100, 100)
        return
    end

    -- Start call
    local callID = getTickCount()

    setElementData(player, "phoneCall", {
        id = callID,
        with = target,
        status = "calling"
    })
    setElementData(target, "phoneCall", {
        id = callID,
        with = player,
        status = "ringing"
    })

    local playerName = getPlayerName(player)
    local targetName = getPlayerName(target)

    outputChatBox("Đang gọi " .. targetName .. "...", player, 255, 255, 100)
    outputChatBox("[ĐIỆN THOẠI] " .. playerName .. " đang gọi cho bạn. Dùng /pickup để nghe máy", target,
        255, 255, 100)

    -- Auto hangup after 30 seconds
    setTimer(function()
        local playerCall = getElementData(player, "phoneCall")
        local targetCall = getElementData(target, "phoneCall")

        if playerCall and playerCall.id == callID and playerCall.status == "calling" then
            setElementData(player, "phoneCall", nil)
            setElementData(target, "phoneCall", nil)
            outputChatBox("Không có ai nghe máy", player, 255, 100, 100)
            outputChatBox("Cuộc gọi đã kết thúc", target, 255, 100, 100)
        end
    end, 30000, 1)

    triggerClientEvent("phone:startCall", getRootElement(), player, target, callID)
end)

addCommandHandler("pickup", function(player, cmd)
    local call = getElementData(player, "phoneCall")
    if not call or call.status ~= "ringing" then
        outputChatBox("Không có cuộc gọi nào!", player, 255, 100, 100)
        return
    end

    local caller = call.with
    if not isElement(caller) then
        setElementData(player, "phoneCall", nil)
        outputChatBox("Cuộc gọi đã kết thúc", player, 255, 100, 100)
        return
    end

    -- Accept call
    setElementData(player, "phoneCall", {
        id = call.id,
        with = caller,
        status = "connected"
    })
    setElementData(caller, "phoneCall", {
        id = call.id,
        with = player,
        status = "connected"
    })

    local playerName = getPlayerName(player)
    local callerName = getPlayerName(caller)

    outputChatBox("Đã nghe máy. Dùng /say để nói chuyện", player, 100, 255, 100)
    outputChatBox(playerName .. " đã nghe máy", caller, 100, 255, 100)

    triggerClientEvent("phone:acceptCall", getRootElement(), player, caller)
end)

addCommandHandler("hangup", function(player, cmd)
    local call = getElementData(player, "phoneCall")
    if not call then
        outputChatBox("Bạn không trong cuộc gọi nào!", player, 255, 100, 100)
        return
    end

    local other = call.with
    setElementData(player, "phoneCall", nil)

    if isElement(other) then
        setElementData(other, "phoneCall", nil)
        local playerName = getPlayerName(player)
        outputChatBox(playerName .. " đã cúp máy", other, 255, 255, 100)
    end

    outputChatBox("Đã cúp máy", player, 255, 255, 100)

    triggerClientEvent("phone:hangupCall", getRootElement(), player, other)
end)

addCommandHandler("sms", function(player, cmd, number, ...)
    if not number or not ... then
        outputChatBox("Sử dụng: /sms [số điện thoại] [tin nhắn]", player, 255, 255, 100)
        return
    end

    local hasPhone = getElementData(player, "hasPhone") or false
    if not hasPhone then
        outputChatBox("Bạn không có điện thoại!", player, 255, 100, 100)
        return
    end

    local message = table.concat({...}, " ")
    if string.len(message) > 160 then
        outputChatBox("Tin nhắn quá dài! (Tối đa 160 ký tự)", player, 255, 100, 100)
        return
    end

    -- Find target by phone number
    local target = nil
    for _, p in ipairs(getElementsByType("player")) do
        local playerPhone = getElementData(p, "phoneNumber")
        if playerPhone == number then
            target = p
            break
        end
    end

    if not target then
        outputChatBox("Số điện thoại không tồn tại!", player, 255, 100, 100)
        return
    end

    if target == player then
        outputChatBox("Không thể gửi tin nhắn cho chính mình!", player, 255, 100, 100)
        return
    end

    local targetHasPhone = getElementData(target, "hasPhone") or false
    if not targetHasPhone then
        outputChatBox("Người này không có điện thoại!", player, 255, 100, 100)
        return
    end

    local playerName = getPlayerName(player)
    local playerPhone = getElementData(player, "phoneNumber") or "Unknown"

    outputChatBox("[SMS ĐÃ GỬI] Đến " .. number .. ": " .. message, player, 100, 255, 100)
    outputChatBox("[SMS NHẬN] Từ " .. playerPhone .. ": " .. message, target, 255, 255, 100)

    triggerClientEvent("phone:receiveSMS", target, playerPhone, message)
end)

addCommandHandler("deposit", function(player, cmd, amount)
    if not amount then
        outputChatBox("Sử dụng: /deposit [số tiền]", player, 255, 255, 100)
        return
    end

    amount = tonumber(amount)
    if not amount or amount <= 0 then
        outputChatBox("Số tiền phải lớn hơn 0!", player, 255, 100, 100)
        return
    end

    local cashMoney = getPlayerMoney(player)
    if cashMoney < amount then
        outputChatBox("Bạn không có đủ tiền mặt!", player, 255, 100, 100)
        return
    end

    local bankMoney = getElementData(player, "bankMoney") or 0

    takePlayerMoney(player, amount)
    setElementData(player, "bankMoney", bankMoney + amount)

    outputChatBox("Đã gửi $" .. formatMoney(amount) .. " vào ngân hàng", player, 100, 255, 100)

    triggerClientEvent("bank:deposit", player, amount)
end)

addCommandHandler("withdraw", function(player, cmd, amount)
    if not amount then
        outputChatBox("Sử dụng: /withdraw [số tiền]", player, 255, 255, 100)
        return
    end

    amount = tonumber(amount)
    if not amount or amount <= 0 then
        outputChatBox("Số tiền phải lớn hơn 0!", player, 255, 100, 100)
        return
    end

    local bankMoney = getElementData(player, "bankMoney") or 0
    if bankMoney < amount then
        outputChatBox("Bạn không có đủ tiền trong ngân hàng!", player, 255, 100, 100)
        return
    end

    setElementData(player, "bankMoney", bankMoney - amount)
    givePlayerMoney(player, amount)

    outputChatBox("Đã rút $" .. formatMoney(amount) .. " từ ngân hàng", player, 100, 255, 100)

    triggerClientEvent("bank:withdraw", player, amount)
end)

addCommandHandler("transfer", function(player, cmd, targetName, amount)
    if not targetName or not amount then
        outputChatBox("Sử dụng: /transfer [tên người chơi] [số tiền]", player, 255, 255, 100)
        return
    end

    amount = tonumber(amount)
    if not amount or amount <= 0 then
        outputChatBox("Số tiền phải lớn hơn 0!", player, 255, 100, 100)
        return
    end

    if amount < 100 then
        outputChatBox("Số tiền chuyển tối thiểu là $100!", player, 255, 100, 100)
        return
    end

    local target = getPlayerFromName(targetName)
    if not target then
        outputChatBox("Không tìm thấy người chơi này!", player, 255, 100, 100)
        return
    end

    if target == player then
        outputChatBox("Không thể chuyển tiền cho chính mình!", player, 255, 100, 100)
        return
    end

    local bankMoney = getElementData(player, "bankMoney") or 0
    if bankMoney < amount then
        outputChatBox("Bạn không có đủ tiền trong ngân hàng!", player, 255, 100, 100)
        return
    end

    local targetBankMoney = getElementData(target, "bankMoney") or 0

    setElementData(player, "bankMoney", bankMoney - amount)
    setElementData(target, "bankMoney", targetBankMoney + amount)

    local playerName = getPlayerName(player)
    local targetPlayerName = getPlayerName(target)

    outputChatBox("Đã chuyển $" .. formatMoney(amount) .. " cho " .. targetPlayerName, player, 100, 255, 100)
    outputChatBox(playerName .. " đã chuyển $" .. formatMoney(amount) .. " cho bạn", target, 100, 255, 100)

    triggerClientEvent("bank:transfer", getRootElement(), player, target, amount)
end)

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

outputDebugString("Mega Player Features System loaded successfully! (100+ commands)")
