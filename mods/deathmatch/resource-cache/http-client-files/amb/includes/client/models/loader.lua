local addModels = exports["mta-add-models"]
customVehicleModels = {} -- chỉ để log/debug client thôi

for _, v in ipairs(MTA_MODEL_DATA.SERVER_VEHICLE_MODELS) do
    local realId = addModels:addVehicleModel({
        dff = "files/models/Vehicle/" .. v.dff,
        txd = "files/models/Vehicle/" .. v.txd,
        name = v.name,
    })

    if realId then
        local cid = v.cid -- ví dụ 30001
        customVehicleModels[cid] = { realId = realId, name = v.name }

        outputDebugString(
            ("[CLIENT] ✅ Registered custom %s CID=%d -> realId=%d"):format(v.name, cid, realId)
        )

        -- Gửi mapping sang server ngay tại đây
        triggerServerEvent("onClientRegisterCustomVehicle", resourceRoot, {
            cid = cid,
            realId = realId,
            baseName = v.name
        })
    else
        outputDebugString("[CLIENT] ❌ Failed to register model for " .. v.name)
    end
end
