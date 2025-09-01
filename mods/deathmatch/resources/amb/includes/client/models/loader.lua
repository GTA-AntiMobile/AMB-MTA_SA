local addModels = exports["mta-add-models"]
customVehicleModels = {} -- chỉ để log/debug client thôi

outputDebugString("[CLIENT] Model loader script started")

-- Delay để đảm bảo resource đã load hoàn toàn
addEventHandler("onClientResourceStart", resourceRoot, function()
    outputDebugString("[CLIENT] onClientResourceStart triggered")
    
    -- Đợi thêm 1 giây để đảm bảo mọi thứ đã sẵn sàng
    setTimer(function()
        outputDebugString("[CLIENT] Starting custom vehicle registration...")
        
        if not MTA_MODEL_DATA then
            outputDebugString("[CLIENT] ❌ MTA_MODEL_DATA is nil!")
            return
        end
        
        if not MTA_MODEL_DATA.SERVER_VEHICLE_MODELS then
            outputDebugString("[CLIENT] ❌ MTA_MODEL_DATA.SERVER_VEHICLE_MODELS is nil!")
            return
        end
        
        outputDebugString("[CLIENT] Found " .. #MTA_MODEL_DATA.SERVER_VEHICLE_MODELS .. " vehicle models to register")
        
        for _, v in ipairs(MTA_MODEL_DATA.SERVER_VEHICLE_MODELS) do
            local vehicleName = v.vehicleName or v.baseName or ("Vehicle_" .. v.cid)
            outputDebugString("[CLIENT] Attempting to register: " .. vehicleName .. " (CID: " .. v.cid .. ")")
            
            local success, realId = pcall(function()
                return addModels:addVehicleModel({
                    dff = "files/models/Vehicle/" .. v.dff,
                    txd = "files/models/Vehicle/" .. v.txd,
                    name = vehicleName,
                })
            end)

            if success and realId then
                local cid = v.cid -- ví dụ 30001
                customVehicleModels[cid] = { realId = realId, name = vehicleName }

                outputDebugString(
                    ("[CLIENT] ✅ Registered custom %s CID=%d -> realId=%d"):format(vehicleName, cid, realId)
                )

                -- Gửi mapping sang server ngay tại đây
                triggerServerEvent("onClientRegisterCustomVehicle", resourceRoot, {
                    cid = cid,
                    realId = realId,
                    baseName = vehicleName
                })
            else
                outputDebugString("[CLIENT] ❌ Failed to register model for " .. vehicleName .. " - Error: " .. tostring(realId))
            end
        end
        
        outputDebugString("[CLIENT] Custom vehicle registration completed!")
    end, 2000, 1) -- Tăng delay lên 2 giây
end)
