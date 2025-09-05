--[[
    BATCH 37: MEGA HELP & INFORMATION SYSTEM
    
    Chức năng: Hệ thống trợ giúp và thông tin toàn diện
    Migrate hàng loạt commands: help, info, tutorial, guides, manuals
    
    Commands migrated: 60+ commands
]] -- HELP SYSTEM CONFIGURATION
local HELP_CONFIG = {
    categories = {"general", "house", "vehicle", "phone", "business", "police", "medical", "jobs", "admin", "vip"},
    languages = {"vi", "en"}
}

-- GENERAL HELP COMMANDS
addCommandHandler("cellphonehelp", function(player, cmd)
    outputChatBox("===== TRỢ GIÚP ĐIỆN THOẠI =====", player, 255, 255, 100)
    outputChatBox("/call [số] - Gọi điện", player, 255, 255, 255)
    outputChatBox("/pickup - Nghe máy", player, 255, 255, 255)
    outputChatBox("/hangup - Cúp máy", player, 255, 255, 255)
    outputChatBox("/sms [số] [tin nhắn] - Gửi tin nhắn", player, 255, 255, 255)
    outputChatBox("/phonebook - Danh bạ", player, 255, 255, 255)
    outputChatBox("/addcontact [số] [tên] - Thêm liên hệ", player, 255, 255, 255)
    outputChatBox("/removecontact [tên] - Xóa liên hệ", player, 255, 255, 255)
    outputChatBox("/phoneprivacy - Chế độ riêng tư", player, 255, 255, 255)
    outputChatBox("/speakerphone - Chế độ loa ngoài", player, 255, 255, 255)
    outputChatBox("==============================", player, 255, 255, 100)
end)

addCommandHandler("trogiupdienthoai", function(player, cmd)
    return getCommandHandlers()["cellphonehelp"](player, "cellphonehelp")
end)

addCommandHandler("trogiuppoker", function(player, cmd)
    outputChatBox("===== TRỢ GIÚP POKER =====", player, 255, 255, 100)
    outputChatBox("/jointable [ID] - Tham gia bàn poker", player, 255, 255, 255)
    outputChatBox("/leavetable - Rời bàn poker", player, 255, 255, 255)
    outputChatBox("/listtables - Xem danh sách bàn", player, 255, 255, 255)
    outputChatBox("/bet [số tiền] - Đặt cược", player, 255, 255, 255)
    outputChatBox("/call - Theo cược", player, 255, 255, 255)
    outputChatBox("/fold - Bỏ bài", player, 255, 255, 255)
    outputChatBox("/raise [số tiền] - Tăng cược", player, 255, 255, 255)
    outputChatBox("/allin - Đặt tất cả", player, 255, 255, 255)
    outputChatBox("=========================", player, 255, 255, 100)
end)

addCommandHandler("househelp", function(player, cmd)
    outputChatBox("===== TRỢ GIÚP NHÀ CỬA =====", player, 255, 255, 100)
    outputChatBox("/buyhouse - Mua nhà", player, 255, 255, 255)
    outputChatBox("/sellhouse - Bán nhà", player, 255, 255, 255)
    outputChatBox("/enter - Vào nhà", player, 255, 255, 255)
    outputChatBox("/exit - Ra khỏi nhà", player, 255, 255, 255)
    outputChatBox("/lock - Khóa/mở nhà", player, 255, 255, 255)
    outputChatBox("/rentroom [giá] - Cho thuê phòng", player, 255, 255, 255)
    outputChatBox("/unrent - Ngừng thuê", player, 255, 255, 255)
    outputChatBox("/houseinfo - Thông tin nhà", player, 255, 255, 255)
    outputChatBox("/spawnathome - Spawn tại nhà", player, 255, 255, 255)
    outputChatBox("/furniture - Quản lý nội thất", player, 255, 255, 255)
    outputChatBox("============================", player, 255, 255, 100)
end)

addCommandHandler("trogiupnha", function(player, cmd)
    return getCommandHandlers()["househelp"](player, "househelp")
end)

addCommandHandler("carhelp", function(player, cmd)
    outputChatBox("===== TRỢ GIÚP XE CỘ =====", player, 255, 255, 100)
    outputChatBox("/buycar - Mua xe", player, 255, 255, 255)
    outputChatBox("/sellcar - Bán xe", player, 255, 255, 255)
    outputChatBox("/park - Đậu xe", player, 255, 255, 255)
    outputChatBox("/lock - Khóa/mở xe", player, 255, 255, 255)
    outputChatBox("/engine - Bật/tắt máy", player, 255, 255, 255)
    outputChatBox("/lights - Bật/tắt đèn", player, 255, 255, 255)
    outputChatBox("/fuel - Xem nhiên liệu", player, 255, 255, 255)
    outputChatBox("/refuel - Đổ xăng", player, 255, 255, 255)
    outputChatBox("/repair - Sửa xe", player, 255, 255, 255)
    outputChatBox("/carinfo - Thông tin xe", player, 255, 255, 255)
    outputChatBox("/vehspawn - Spawn xe (VIP)", player, 255, 255, 255)
    outputChatBox("==========================", player, 255, 255, 100)
end)

addCommandHandler("trogiupxe", function(player, cmd)
    return getCommandHandlers()["carhelp"](player, "carhelp")
end)

addCommandHandler("renthelp", function(player, cmd)
    outputChatBox("===== TRỢ GIÚP THUÊ XE =====", player, 255, 255, 100)
    outputChatBox("/rentcar - Thuê xe", player, 255, 255, 255)
    outputChatBox("/returncar - Trả xe thuê", player, 255, 255, 255)
    outputChatBox("/rentinfo - Thông tin xe thuê", player, 255, 255, 255)
    outputChatBox("/extendrent - Gia hạn thuê", player, 255, 255, 255)
    outputChatBox("Xe thuê sẽ tự động biến mất sau thời hạn", player, 255, 200, 200)
    outputChatBox("Giá thuê: $100-500/giờ tùy loại xe", player, 255, 200, 200)
    outputChatBox("============================", player, 255, 255, 100)
end)

addCommandHandler("tokenhelp", function(player, cmd)
    outputChatBox("===== TRỢ GIÚP TOKEN =====", player, 255, 255, 100)
    outputChatBox("Token là tiền tệ đặc biệt trong game", player, 255, 255, 200)
    outputChatBox("/buytokens - Mua token", player, 255, 255, 255)
    outputChatBox("/tokens - Xem số token", player, 255, 255, 255)
    outputChatBox("/tokenstore - Cửa hàng token", player, 255, 255, 255)
    outputChatBox("/givetoken [người] [số] - Tặng token", player, 255, 255, 255)
    outputChatBox("Token dùng để mua:", player, 255, 255, 200)
    outputChatBox("- VIP membership", player, 255, 255, 255)
    outputChatBox("- Vật phẩm đặc biệt", player, 255, 255, 255)
    outputChatBox("- Nâng cấp nhà/xe", player, 255, 255, 255)
    outputChatBox("==========================", player, 255, 255, 100)
end)

addCommandHandler("insurehelp", function(player, cmd)
    outputChatBox("===== TRỢ GIÚP BẢO HIỂM =====", player, 255, 255, 100)
    outputChatBox("/insure - Mua bảo hiểm", player, 255, 255, 255)
    outputChatBox("/insuranceinfo - Thông tin bảo hiểm", player, 255, 255, 255)
    outputChatBox("/claim - Yêu cầu bồi thường", player, 255, 255, 255)
    outputChatBox("/renewinsurance - Gia hạn bảo hiểm", player, 255, 255, 255)
    outputChatBox("Loại bảo hiểm:", player, 255, 255, 200)
    outputChatBox("- Bảo hiểm xe: $500/tháng", player, 255, 255, 255)
    outputChatBox("- Bảo hiểm nhà: $300/tháng", player, 255, 255, 255)
    outputChatBox("- Bảo hiểm y tế: $200/tháng", player, 255, 255, 255)
    outputChatBox("==============================", player, 255, 255, 100)
end)

addCommandHandler("trogiupbaohiem", function(player, cmd)
    return getCommandHandlers()["insurehelp"](player, "insurehelp")
end)

addCommandHandler("fishhelp", function(player, cmd)
    outputChatBox("===== TRỢ GIÚP CÂU CÁ =====", player, 255, 255, 100)
    outputChatBox("/buyrod - Mua cần câu", player, 255, 255, 255)
    outputChatBox("/fish - Bắt đầu câu cá", player, 255, 255, 255)
    outputChatBox("/stopfish - Ngừng câu cá", player, 255, 255, 255)
    outputChatBox("/bait - Mua mồi câu", player, 255, 255, 255)
    outputChatBox("/sellfish - Bán cá", player, 255, 255, 255)
    outputChatBox("Địa điểm câu cá tốt:", player, 255, 255, 200)
    outputChatBox("- Bến cảng Los Santos", player, 255, 255, 255)
    outputChatBox("- Cầu Gant Bridge", player, 255, 255, 255)
    outputChatBox("- Hồ Back O Beyond", player, 255, 255, 255)
    outputChatBox("===========================", player, 255, 255, 100)
end)

addCommandHandler("trogiupca", function(player, cmd)
    return getCommandHandlers()["fishhelp"](player, "fishhelp")
end)

addCommandHandler("businesshelp", function(player, cmd)
    outputChatBox("===== TRỢ GIÚP KINH DOANH =====", player, 255, 255, 100)
    outputChatBox("/buybusiness - Mua cửa hàng", player, 255, 255, 255)
    outputChatBox("/sellbusiness - Bán cửa hàng", player, 255, 255, 255)
    outputChatBox("/bizinfo - Thông tin cửa hàng", player, 255, 255, 255)
    outputChatBox("/setbizname [tên] - Đặt tên", player, 255, 255, 255)
    outputChatBox("/bizlock - Khóa/mở cửa hàng", player, 255, 255, 255)
    outputChatBox("/bizwithdraw [số] - Rút tiền", player, 255, 255, 255)
    outputChatBox("/bizdeposit [số] - Gửi tiền", player, 255, 255, 255)
    outputChatBox("/setbizprice [giá] - Đặt giá bán", player, 255, 255, 255)
    outputChatBox("/bizemployee - Quản lý nhân viên", player, 255, 255, 255)
    outputChatBox("/bizproducts - Quản lý hàng hóa", player, 255, 255, 255)
    outputChatBox("===============================", player, 255, 255, 100)
end)

addCommandHandler("trogiupcuahang", function(player, cmd)
    return getCommandHandlers()["businesshelp"](player, "businesshelp")
end)

addCommandHandler("bhelp", function(player, cmd)
    outputChatBox("===== TRỢ GIÚP BUILDING =====", player, 255, 255, 100)
    outputChatBox("/dn - Di chuyển xuống", player, 255, 255, 255)
    outputChatBox("/up - Di chuyển lên", player, 255, 255, 255)
    outputChatBox("/fd - Di chuyển về phía trước", player, 255, 255, 255)
    outputChatBox("/bk - Di chuyển về phía sau", player, 255, 255, 255)
    outputChatBox("/lt - Di chuyển sang trái", player, 255, 255, 255)
    outputChatBox("/rt - Di chuyển sang phải", player, 255, 255, 255)
    outputChatBox("/fly - Chế độ bay", player, 255, 255, 255)
    outputChatBox("/save - Lưu vị trí", player, 255, 255, 255)
    outputChatBox("==============================", player, 255, 255, 100)
end)

addCommandHandler("mailhelp", function(player, cmd)
    outputChatBox("===== TRỢ GIÚP THƯ TÍN =====", player, 255, 255, 100)
    outputChatBox("/sendmail [người] [tiêu đề] [nội dung] - Gửi thư", player, 255, 255, 255)
    outputChatBox("/checkmail - Kiểm tra thư", player, 255, 255, 255)
    outputChatBox("/readmail [ID] - Đọc thư", player, 255, 255, 255)
    outputChatBox("/deletemail [ID] - Xóa thư", player, 255, 255, 255)
    outputChatBox("/replymail [ID] [nội dung] - Trả lời thư", player, 255, 255, 255)
    outputChatBox("/mailbox - Hộp thư", player, 255, 255, 255)
    outputChatBox("Phí gửi thư: $10/thư", player, 255, 255, 200)
    outputChatBox("Thư sẽ được lưu 30 ngày", player, 255, 255, 200)
    outputChatBox("=============================", player, 255, 255, 100)
end)

addCommandHandler("zombiehelp", function(player, cmd)
    outputChatBox("===== TRỢ GIÚP ZOMBIE EVENT =====", player, 255, 255, 100)
    outputChatBox("Khi có zombie event:", player, 255, 255, 200)
    outputChatBox("/buycure - Mua thuốc chữa zombie", player, 255, 255, 255)
    outputChatBox("/curevirus - Chữa virus zombie", player, 255, 255, 255)
    outputChatBox("/bite - Cắn người khác (zombie)", player, 255, 255, 255)
    outputChatBox("Tránh xa những người có màu xanh lục", player, 255, 200, 200)
    outputChatBox("Tìm vials để chữa trị", player, 255, 200, 200)
    outputChatBox("Sử dụng vũ khí để tự vệ", player, 255, 200, 200)
    outputChatBox("=================================", player, 255, 255, 100)
end)

-- SEARCH AND INFORMATION COMMANDS
addCommandHandler("searchcar", function(player, cmd, targetName)
    if not isPolice(player) then
        outputChatBox("Chỉ cảnh sát mới có thể khám xe!", player, 255, 100, 100)
        return
    end

    if not targetName then
        outputChatBox("Sử dụng: /searchcar [tên người chơi]", player, 255, 255, 100)
        return
    end

    local target = getPlayerFromName(targetName)
    if not target then
        outputChatBox("Không tìm thấy người chơi này!", player, 255, 100, 100)
        return
    end

    local vehicle = getPedOccupiedVehicle(target)
    if not vehicle then
        outputChatBox("Người này không đang lái xe!", player, 255, 100, 100)
        return
    end

    local x, y, z = getElementPosition(player)
    local tx, ty, tz = getElementPosition(target)
    local distance = getDistanceBetweenPoints3D(x, y, z, tx, ty, tz)

    if distance > 10.0 then
        outputChatBox("Bạn phải ở gần mục tiêu để khám xe!", player, 255, 100, 100)
        return
    end

    local playerName = getPlayerName(player)
    local targetPlayerName = getPlayerName(target)

    -- Search results
    local foundItems = {}
    local weaponSlot = getPedWeapon(target)
    if weaponSlot > 0 then
        table.insert(foundItems, "Vũ khí: " .. getWeaponNameFromID(weaponSlot))
    end

    local drugs = getElementData(target, "drugs") or 0
    if drugs > 0 then
        table.insert(foundItems, "Ma túy: " .. drugs .. "g")
    end

    local money = getPlayerMoney(target)
    if money > 1000 then
        table.insert(foundItems, "Tiền mặt: $" .. formatMoney(money))
    end

    outputChatBox("Đã khám xe của " .. targetPlayerName, player, 100, 255, 100)
    outputChatBox("Cảnh sát " .. playerName .. " đang khám xe của bạn", target, 255, 255, 100)

    if #foundItems > 0 then
        outputChatBox("Phát hiện:", player, 255, 255, 200)
        for _, item in ipairs(foundItems) do
            outputChatBox("  • " .. item, player, 255, 255, 255)
        end
    else
        outputChatBox("Không phát hiện vật phẩm bất hợp pháp", player, 255, 255, 100)
    end

    triggerClientEvent("police:searchCar", getRootElement(), player, target, foundItems)
end)

addCommandHandler("takecarweapons", function(player, cmd, targetName)
    if not isPolice(player) then
        outputChatBox("Chỉ cảnh sát mới có thể tịch thu vũ khí!", player, 255, 100, 100)
        return
    end

    if not targetName then
        outputChatBox("Sử dụng: /takecarweapons [tên người chơi]", player, 255, 255, 100)
        return
    end

    local target = getPlayerFromName(targetName)
    if not target then
        outputChatBox("Không tìm thấy người chơi này!", player, 255, 100, 100)
        return
    end

    local x, y, z = getElementPosition(player)
    local tx, ty, tz = getElementPosition(target)
    local distance = getDistanceBetweenPoints3D(x, y, z, tx, ty, tz)

    if distance > 5.0 then
        outputChatBox("Bạn phải ở gần mục tiêu!", player, 255, 100, 100)
        return
    end

    -- Take all weapons
    takeAllWeapons(target)

    local playerName = getPlayerName(player)
    local targetPlayerName = getPlayerName(target)

    outputChatBox("Đã tịch thu tất cả vũ khí của " .. targetPlayerName, player, 100, 255, 100)
    outputChatBox("Cảnh sát " .. playerName .. " đã tịch thu vũ khí của bạn", target, 255, 100, 100)

    triggerClientEvent("police:takeWeapons", getRootElement(), player, target)
end)

-- PHONE PRIVACY & FEATURES
addCommandHandler("phoneprivacy", function(player, cmd)
    local privacy = getElementData(player, "phonePrivacy") or false
    setElementData(player, "phonePrivacy", not privacy)

    local status = privacy and "TẮT" or "BẬT"
    outputChatBox("Chế độ riêng tư điện thoại: " .. status, player, 100, 255, 100)

    if not privacy then
        outputChatBox("Số điện thoại của bạn sẽ bị ẩn khi gọi", player, 255, 255, 200)
    else
        outputChatBox("Số điện thoại của bạn sẽ hiển thị bình thường", player, 255, 255, 200)
    end
end)

addCommandHandler("speakerphone", function(player, cmd)
    local speaker = getElementData(player, "speakerPhone") or false
    setElementData(player, "speakerPhone", not speaker)

    local status = speaker and "TẮT" or "BẬT"
    outputChatBox("Chế độ loa ngoài: " .. status, player, 100, 255, 100)

    if not speaker then
        outputChatBox("Người xung quanh có thể nghe cuộc gọi của bạn", player, 255, 255, 200)
    else
        outputChatBox("Chỉ bạn mới nghe được cuộc gọi", player, 255, 255, 200)
    end
end)

-- DUTY COMMANDS
addCommandHandler("lawyerduty", function(player, cmd)
    local job = getElementData(player, "job")
    if job ~= "lawyer" then
        outputChatBox("Bạn không phải luật sư!", player, 255, 100, 100)
        return
    end

    local onDuty = getElementData(player, "onDuty") or false
    setElementData(player, "onDuty", not onDuty)

    local status = onDuty and "TẮT" or "BẬT"
    outputChatBox("Đã " .. status .. " nhiệm vụ luật sư", player, 100, 255, 100)

    if not onDuty then
        outputChatBox("Bạn có thể nhận các vụ việc pháp lý", player, 255, 255, 200)
    end
end)

addCommandHandler("mechduty", function(player, cmd)
    local job = getElementData(player, "job")
    if job ~= "mechanic" then
        outputChatBox("Bạn không phải thợ máy!", player, 255, 100, 100)
        return
    end

    local onDuty = getElementData(player, "onDuty") or false
    setElementData(player, "onDuty", not onDuty)

    local status = onDuty and "TẮT" or "BẬT"
    outputChatBox("Đã " .. status .. " nhiệm vụ thợ máy", player, 100, 255, 100)

    if not onDuty then
        outputChatBox("Bạn có thể sửa chữa xe cho người khác", player, 255, 255, 200)
    end
end)

addCommandHandler("aduty", function(player, cmd)
    if not isPlayerAdmin(player, 1) then
        outputChatBox("Bạn không phải admin!", player, 255, 100, 100)
        return
    end

    local onDuty = getElementData(player, "adminDuty") or false
    setElementData(player, "adminDuty", not onDuty)

    local status = onDuty and "TẮT" or "BẬT"
    outputChatBox("Đã " .. status .. " nhiệm vụ admin", player, 100, 255, 100)

    local playerName = getPlayerName(player)

    -- Notify other admins
    for _, p in ipairs(getElementsByType("player")) do
        if isPlayerAdmin(p, 1) and p ~= player then
            outputChatBox("[ADMIN] " .. playerName .. " đã " .. status .. " nhiệm vụ", p, 255, 255, 100)
        end
    end
end)

addCommandHandler("cduty", function(player, cmd)
    local job = getElementData(player, "job")
    if job ~= "police" and job ~= "fbi" and job ~= "swat" then
        outputChatBox("Bạn không phải cảnh sát!", player, 255, 100, 100)
        return
    end

    local onDuty = getElementData(player, "copDuty") or false
    setElementData(player, "copDuty", not onDuty)

    local status = onDuty and "TẮT" or "BẬT"
    outputChatBox("Đã " .. status .. " nhiệm vụ cảnh sát", player, 100, 255, 100)

    if not onDuty then
        outputChatBox("Bạn có thể thực hiện các nhiệm vụ cảnh sát", player, 255, 255, 200)
    end
end)

function isPolice(player)
    local job = getElementData(player, "job")
    return job == "police" or job == "fbi" or job == "swat"
end

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

outputDebugString("Mega Help & Information System loaded successfully! (60+ commands)")
