-- ================================
-- AMB MTA:SA - Animation & Entertainment Commands
-- Mass migration of animation and entertainment commands
-- ================================
-- Dance commands
addCommandHandler("dance", function(player, cmd, danceType)
    if not danceType then
        outputChatBox("Su dung: /dance [1-4] hoac /dance stop", player, 255, 255, 255)
        return
    end

    if danceType == "stop" then
        setPedAnimation(player, false)
        outputChatBox("💃 Da dung dance.", player, 255, 255, 100)
        return
    end

    local danceNum = tonumber(danceType)
    if not danceNum or danceNum < 1 or danceNum > 4 then
        outputChatBox("❌ Dance type 1-4 only.", player, 255, 100, 100)
        return
    end

    local dances = {
        [1] = {"DANCING", "dance_loop"},
        [2] = {"DANCING", "DAN_Down_A"},
        [3] = {"DANCING", "DAN_Left_A"},
        [4] = {"DANCING", "DAN_Loop_A"}
    }

    local dance = dances[danceNum]
    setPedAnimation(player, dance[1], dance[2], -1, true, false, false)

    outputChatBox(string.format("💃 Bat dau dance style %d!", danceNum), player, 255, 255, 100)

    -- Notify nearby players
    local x, y, z = getElementPosition(player)
    for _, nearPlayer in ipairs(getElementsByType("player")) do
        if nearPlayer ~= player then
            local nx, ny, nz = getElementPosition(nearPlayer)
            if getDistanceBetweenPoints3D(x, y, z, nx, ny, nz) < 20 then
                outputChatBox(string.format("💃 %s dang dance!", getPlayerName(player)), nearPlayer, 255, 255, 100)
            end
        end
    end
end)

-- Sit command
addCommandHandler("sit", function(player)
    setPedAnimation(player, "BEACH", "bather", -1, true, false, false)
    outputChatBox("🪑 Da ngoi xuong.", player, 255, 255, 100)
end)

-- Lay down command
addCommandHandler("lay", function(player)
    setPedAnimation(player, "BEACH", "Lay_Bac_Loop", -1, true, false, false)
    outputChatBox("🛏️ Da nam xuong.", player, 255, 255, 100)
end)

-- Smoke command
addCommandHandler("smoke", function(player)
    setPedAnimation(player, "SMOKING", "M_smklean_loop", -1, true, false, false)
    outputChatBox("🚬 Bat dau hut thuoc.", player, 255, 255, 100)
end)

-- Drink command
addCommandHandler("drink", function(player)
    setPedAnimation(player, "BAR", "dnk_stndM_loop", -1, true, false, false)
    outputChatBox("🍺 Bat dau uong.", player, 255, 255, 100)
end)

-- Eat command
addCommandHandler("eat", function(player)
    setPedAnimation(player, "FOOD", "EAT_Burger", -1, true, false, false)
    outputChatBox("🍔 Bat dau an.", player, 255, 255, 100)
end)

-- Piss command
addCommandHandler("piss", function(player)
    setPedAnimation(player, "PAULNMAC", "Piss_loop", -1, true, false, false)
    outputChatBox("🚾 Dang di tieu...", player, 255, 255, 100)
end)

-- Cry command
addCommandHandler("cry", function(player)
    setPedAnimation(player, "GRAVEYARD", "mrnF_loop", -1, true, false, false)
    outputChatBox("😭 Bat dau khoc.", player, 255, 255, 100)
end)

-- Laugh command
addCommandHandler("laugh", function(player)
    setPedAnimation(player, "RAPPING", "Laugh_01", -1, true, false, false)
    outputChatBox("😂 Bat dau cuoi.", player, 255, 255, 100)
end)

-- Applaud command
addCommandHandler("clap", function(player)
    setPedAnimation(player, "GANGS", "prtial_gngtlkD", -1, true, false, false)
    outputChatBox("👏 Vỗ tay.", player, 255, 255, 100)
end)

-- Wave command
addCommandHandler("wave", function(player)
    setPedAnimation(player, "ON_LOOKERS", "wave_loop", -1, true, false, false)
    outputChatBox("👋 Vay tay chao.", player, 255, 255, 100)
end)

-- Taichi command
addCommandHandler("taichi", function(player)
    setPedAnimation(player, "PARK", "Tai_Chi_Loop", -1, true, false, false)
    outputChatBox("🧘 Bat dau tap Tai Chi.", player, 255, 255, 100)
end)

-- Pushup command
addCommandHandler("pushup", function(player)
    setPedAnimation(player, "GYMNASIUM", "gym_tread_02", -1, true, false, false)
    outputChatBox("💪 Bat dau tap push-up.", player, 255, 255, 100)
end)

-- Workout command
addCommandHandler("workout", function(player, cmd, exerciseType)
    if not exerciseType then
        outputChatBox("Su dung: /workout [pushup/situp/weights/bike]", player, 255, 255, 255)
        return
    end

    local exercises = {
        pushup = {"GYMNASIUM", "gym_tread_02", "💪 Tap push-up"},
        situp = {"GYMNASIUM", "gym_tread_01", "💪 Tap sit-up"},
        weights = {"GYMNASIUM", "gym_walk_falloff", "💪 Nang ta"},
        bike = {"GYMNASIUM", "gym_bike_01", "🚴 Tap xe dap"}
    }

    local exercise = exercises[exerciseType]
    if not exercise then
        outputChatBox("❌ Exercises: pushup, situp, weights, bike", player, 255, 100, 100)
        return
    end

    setPedAnimation(player, exercise[1], exercise[2], -1, true, false, false)
    outputChatBox(exercise[3], player, 255, 255, 100)
end)

-- Rap command
addCommandHandler("rap", function(player)
    setPedAnimation(player, "RAPPING", "RAP_A_Loop", -1, true, false, false)
    outputChatBox("🎤 Bat dau rap.", player, 255, 255, 100)
end)

-- Robman command
addCommandHandler("robman", function(player)
    setPedAnimation(player, "SHOP", "ROB_Loop_Threat", -1, true, false, false)
    outputChatBox("🔫 Doa hiep nguoi khac.", player, 255, 255, 100)
end)

-- Strip command
addCommandHandler("strip", function(player, cmd, stripType)
    if not stripType then
        outputChatBox("Su dung: /strip [1-3] hoac /strip stop", player, 255, 255, 255)
        return
    end

    if stripType == "stop" then
        setPedAnimation(player, false)
        outputChatBox("💃 Da dung strip dance.", player, 255, 255, 100)
        return
    end

    local stripNum = tonumber(stripType)
    if not stripNum or stripNum < 1 or stripNum > 3 then
        outputChatBox("❌ Strip type 1-3 only.", player, 255, 100, 100)
        return
    end

    local strips = {
        [1] = {"STRIP", "strip_A"},
        [2] = {"STRIP", "strip_B"},
        [3] = {"STRIP", "strip_C"}
    }

    local strip = strips[stripNum]
    setPedAnimation(player, strip[1], strip[2], -1, true, false, false)
    outputChatBox(string.format("💃 Bat dau strip dance %d!", stripNum), player, 255, 255, 100)
end)

-- Handsup command
addCommandHandler("handsup", function(player)
    setPedAnimation(player, "ROB_BANK", "SHP_HandsUp_Scr", -1, true, false, false)
    outputChatBox("🙌 Dua tay len.", player, 255, 255, 100)
end)

-- Surrender command
addCommandHandler("surrender", function(player)
    setPedAnimation(player, "ped", "handsup", -1, false, false, false)
    outputChatBox("🏳️ Dau hang.", player, 255, 255, 100)
end)

-- Cellin command (cellphone)
addCommandHandler("cellin", function(player)
    setPedAnimation(player, "PED", "phone_in", -1, true, false, false)
    outputChatBox("📱 Nhan dien thoai.", player, 255, 255, 100)
end)

-- Cellout command
addCommandHandler("cellout", function(player)
    setPedAnimation(player, "PED", "phone_out", -1, true, false, false)
    outputChatBox("📱 Cat dien thoai.", player, 255, 255, 100)
end)

-- Crossarms command
addCommandHandler("crossarms", function(player)
    setPedAnimation(player, "COP_AMBIENT", "Coplook_loop", -1, true, false, false)
    outputChatBox("💪 Khoanh tay.", player, 255, 255, 100)
end)

-- Fuck command
addCommandHandler("fuck", function(player, cmd, playerIdOrName)
    if not playerIdOrName then
        setPedAnimation(player, "PAULNMAC", "wank_loop", -1, true, false, false)
        outputChatBox("🍆 Tu suong...", player, 255, 255, 100)
        return
    end

    local targetPlayer = getPlayerFromNameOrId(playerIdOrName)
    if not targetPlayer then
        outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
        return
    end

    -- Check distance
    local px, py, pz = getElementPosition(player)
    local tx, ty, tz = getElementPosition(targetPlayer)
    if getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz) > 3 then
        outputChatBox("❌ Ban qua xa.", player, 255, 100, 100)
        return
    end

    -- Both players need to consent
    local targetData = getElementData(targetPlayer, "playerData") or {}
    targetData.fuckRequest = {
        from = player,
        time = getRealTime().timestamp
    }
    setElementData(targetPlayer, "playerData", targetData)

    outputChatBox(string.format("🍆 Da gui fuck request den %s.", getPlayerName(targetPlayer)), player, 255, 255, 100)
    outputChatBox(string.format("🍆 %s muon fuck ban. Su dung /faccept hoac tu choi.", getPlayerName(player)),
        targetPlayer, 255, 255, 100)
end)

-- Accept fuck request
addCommandHandler("faccept", function(player)
    local playerData = getElementData(player, "playerData") or {}

    if not playerData.fuckRequest then
        outputChatBox("❌ Ban khong co fuck request.", player, 255, 100, 100)
        return
    end

    local requester = playerData.fuckRequest.from
    if not isElement(requester) then
        outputChatBox("❌ Request da expired.", player, 255, 100, 100)
        playerData.fuckRequest = nil
        setElementData(player, "playerData", playerData)
        return
    end

    -- Start fucking animation
    setPedAnimation(player, "PAULNMAC", "wank_loop", -1, true, false, false)
    setPedAnimation(requester, "PAULNMAC", "wank_loop", -1, true, false, false)

    playerData.fuckRequest = nil
    setElementData(player, "playerData", playerData)

    outputChatBox("🍆 Dang fuck...", player, 255, 100, 100)
    outputChatBox("🍆 Dang fuck...", requester, 255, 100, 100)

    -- Stop after 10 seconds
    setTimer(function()
        if isElement(player) and isElement(requester) then
            setPedAnimation(player, false)
            setPedAnimation(requester, false)
            outputChatBox("🍆 Da xong.", player, 255, 255, 100)
            outputChatBox("🍆 Da xong.", requester, 255, 255, 100)
        end
    end, 10000, 1)
end)

-- Puke command
addCommandHandler("puke", function(player)
    setPedAnimation(player, "FOOD", "EAT_Vomit_P", -1, true, false, false)
    outputChatBox("🤮 Dang oi...", player, 255, 255, 100)
end)

-- Slap animation
addCommandHandler("slapanim", function(player, cmd, playerIdOrName)
    if not playerIdOrName then
        outputChatBox("Su dung: /slapanim [player_id]", player, 255, 255, 255)
        return
    end

    local targetPlayer = getPlayerFromNameOrId(playerIdOrName)
    if not targetPlayer then
        outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
        return
    end

    -- Check distance
    local px, py, pz = getElementPosition(player)
    local tx, ty, tz = getElementPosition(targetPlayer)
    if getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz) > 3 then
        outputChatBox("❌ Ban qua xa.", player, 255, 100, 100)
        return
    end

    setPedAnimation(player, "SWEET", "sweet_ass_slap", -1, true, false, false)
    outputChatBox(string.format("👋 Da tat %s!", getPlayerName(targetPlayer)), player, 255, 255, 100)
    outputChatBox(string.format("👋 %s da tat ban!", getPlayerName(player)), targetPlayer, 255, 100, 100)
end)

-- Football (soccer) tricks
addCommandHandler("football", function(player, cmd, trickType)
    if not trickType then
        outputChatBox("Su dung: /football [around/up/kick/stop]", player, 255, 255, 255)
        return
    end

    if trickType == "stop" then
        setPedAnimation(player, false)
        outputChatBox("⚽ Da dung choi bong.", player, 255, 255, 100)
        return
    end

    local tricks = {
        around = {"FOOTBALL", "samp_fball_runR_o", "⚽ Choi bong quanh chan"},
        up = {"FOOTBALL", "samp_fball_up", "⚽ Nem bong len"},
        kick = {"FOOTBALL", "samp_fball_kick", "⚽ Sut bong"}
    }

    local trick = tricks[trickType]
    if not trick then
        outputChatBox("❌ Tricks: around, up, kick, stop", player, 255, 100, 100)
        return
    end

    setPedAnimation(player, trick[1], trick[2], -1, true, false, false)
    outputChatBox(trick[3], player, 255, 255, 100)
end)

outputDebugString("[AMB] Animation & Entertainment system loaded - 25 commands")
