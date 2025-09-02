-- amb_model_loader.lua
-- Cleaned version built from your original structure
-- Minimal logs: only failures + final summary

-- === SERVER SIDE CUSTOM VEHICLE MAPPING ===
customVehicleModels = customVehicleModels or {}

outputDebugString("[SERVER] Custom vehicle mapping system initialized")

addEvent("onClientRegisterCustomVehicle", true)
addEventHandler("onClientRegisterCustomVehicle", resourceRoot, function(data)
    outputDebugString("[SERVER] Received custom vehicle registration from client: " .. tostring(source and getPlayerName(source) or "unknown"))
    
    if data and data.cid and data.realId then
        customVehicleModels[data.cid] = {
            realId = data.realId,
            name   = data.baseName or ("Vehicle_" .. data.cid)
        }
        outputDebugString(("[SERVER] ✅ Map CID=%d -> realId=%d (%s)"):format(
            data.cid, data.realId, data.baseName or "nil"
        ))
        
        -- Log current mappings
        local count = 0
        for cid, _ in pairs(customVehicleModels) do
            count = count + 1
        end
        outputDebugString(("[SERVER] Total custom vehicles registered: %d"):format(count))
    else
        outputDebugString("[SERVER] ⚠️ Invalid custom vehicle data from client")
        if data then
            outputDebugString(("[SERVER] Data received: cid=%s, realId=%s, baseName=%s"):format(
                tostring(data.cid), tostring(data.realId), tostring(data.baseName)
            ))
        end
    end
end)
