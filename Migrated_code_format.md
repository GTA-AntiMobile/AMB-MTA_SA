# 📘 Quy trình chuẩn hóa lệnh MTA Server

## 🎯 Mục tiêu

Chuẩn hóa toàn bộ command trong server để:

- Đồng nhất cách đặt tên biến, hàm và cấu trúc folder.
- Hỗ trợ tìm kiếm player bằng cả ID hoặc Name (`getPlayerFromNameOrId`).
- Tối ưu code, loại bỏ biến thừa hoặc lỗi cảnh báo.
- Merge các phiên bản command từ source thành 1 file duy nhất.
- Kiểm tra event server ↔ client đảm bảo an toàn dữ liệu.
- Loại bỏ tất cả hàm bị trùng và chỉ giữ 1 hàm cuối cùng hoàn chỉnh trong repo source code LUA project.

---

## 📂 Cấu trúc folder chuẩn

server/
│
├── config/
├── data/
│ ├── properties/
│ └── vehicles/
├── databases/
├── files/
│ ├── audio/
│ ├── config/
│ ├── images/
│ ├── sounds/
│ │ └── vehicles/
│ └── videos/
├── includes/
│ ├── client/
│ │ ├── admin/
│ │ ├── faction/
│ │ └── fly/
│ └── core/
│ ├── vehicle/
│ │ └── commands/ # Lưu tất cả lệnh /car, /repair, /lock, /setarmor, ...
│ └── ... # Các module khác
├── logs/
└── shared/

yaml
Copy code

---

## 📐 Quy tắc chuẩn hóa code

### 1. Biến player

- Luôn dùng `playerIdOrName` khi input player (cả ID và name).
- Convert bằng hàm `getPlayerFromNameOrId`.

```lua
-- ❌ Sai:
local target = getPlayerFromNameOrId(playerName)

-- ✅ Đúng:
local target = getPlayerFromNameOrId(playerIdOrName)
2. Hàm tìm player
Thay thế toàn bộ getPlayerFromNameOrId bằng:

lua
Copy code
function getPlayerFromNameOrId(playerIdOrName)
    if not playerIdOrName or playerIdOrName == "" then return nil end

    local id = tonumber(playerIdOrName)
    if id then
        for _, p in ipairs(getElementsByType("player")) do
            if getElementData(p, "playerId") == id then
                return p
            end
        end
    end

    playerIdOrName = string.lower(playerIdOrName)
    for _, p in ipairs(getElementsByType("player")) do
        if string.find(string.lower(getPlayerName(p)), playerIdOrName, 1, true) then
            return p
        end
    end

    return nil
end
3. Xử lý unused variable cmd
Nếu cmd không dùng trong addCommandHandler → đổi thành _.

lua
Copy code
-- ❌ Sai:
addCommandHandler("car", function(player, cmd, subcmd)
    -- logic
end)

-- ✅ Đúng:
addCommandHandler("car", function(player, _, subcmd)
    -- logic
end)
4. Đặt tên biến chuẩn
Trường hợp	Tên biến chuẩn
Player id hoặc name	playerIdOrName
Vehicle	veh
Engine state	engineState
Lights state	lightsState
Locked state	lockedState

5. Chuẩn hóa command example
/car command
lua
Copy code
addCommandHandler("car", function(player, _, subcmd)
    if not subcmd then
        outputChatBox("Sử dụng: /car [engine/lights/lock/windows]", player, 255, 255, 255)
        return
    end

    local veh = getPedOccupiedVehicle(player)
    if not veh then
        outputChatBox("Bạn phải ở trong xe để dùng lệnh này.", player, 255, 0, 0)
        return
    end

    if subcmd == "engine" then
        local engineState = getVehicleEngineState(veh)
        setVehicleEngineState(veh, not engineState)
        outputChatBox("Động cơ: " .. (engineState and "TẮT" or "BẬT"), player, 0, 255, 0)
    elseif subcmd == "lights" then
        local lightsState = getVehicleOverrideLights(veh)
        setVehicleOverrideLights(veh, lightsState == 2 and 1 or 2)
        outputChatBox("Đèn xe đã được chuyển trạng thái.", player, 0, 255, 0)
    elseif subcmd == "lock" then
        local lockedState = isVehicleLocked(veh)
        setVehicleLocked(veh, not lockedState)
        outputChatBox("Xe đã được " .. (lockedState and "mở khóa" or "khóa"), player, 0, 255, 0)
    elseif subcmd == "windows" then
        local state = getElementData(veh, "windows") or "up"
        setElementData(veh, "windows", state == "up" and "down" or "up")
        outputChatBox("Kính xe đã được " .. (state == "up" and "hạ xuống" or "nâng lên") .. ".", player, 0, 255, 0)
    else
        outputChatBox("Subcommand không hợp lệ!", player, 255, 0, 0)
    end
end)
6. Kiểm tra Event Server ↔ Client
Mỗi command cần kiểm tra xem có event nào từ client liên quan không.

Kiểm tra addEvent / addEventHandler ở server trùng với triggerServerEvent từ client.

Convention tên event: <module>:<action>.

Nếu command dùng vehicle/player data, validate playerId / vehicleId từ client.

Luôn kiểm tra dữ liệu trước khi xử lý (type check, nil check, quyền).

7. Checklist chuẩn hóa
Hạng mục	Trạng thái
Folder đúng chuẩn	✅
Sử dụng playerIdOrName	✅
Đổi sang getPlayerFromNameOrId	✅
Loại bỏ getPlayerFromNameOrId	✅
cmd unused → đổi thành _	✅
Tin nhắn tiếng Việt chuẩn	✅
Merge nhiều phiên bản command	✅
Event server ↔ client validate	✅

8. Tóm tắt
Dùng playerIdOrName + getPlayerFromNameOrId để chuẩn hóa tìm player.

Tối ưu cảnh báo: cmd không dùng → đổi _.

Folder chuẩn: includes/core/<module>/commands/.

Merge nhiều phiên bản lệnh, chọn bản chuẩn nhất làm gốc.

Kiểm tra event client → server đảm bảo an toàn dữ liệu.