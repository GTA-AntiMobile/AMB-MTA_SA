-- amb_model_loader.lua
-- Cleaned version built from your original structure
-- Minimal logs: only failures + final summary

-- === DATA ===
MTA_MODEL_DATA = MTA_MODEL_DATA or {}

MTA_MODEL_DATA.SERVER_VEHICLE_MODELS = {
    { cid = 30001, baseName = "lambor", dff = "lambor.dff", txd = "lambor.txd", vehicleName = "Lamborghini Aventador" },
    { cid = 30002, baseName = "alpha",  dff = "alpha.dff",  txd = "alpha.txd",  vehicleName = "Alpha Custom" },
    { cid = 30003, baseName = "m6",     dff = "m6.dff",     txd = "m6.txd",     vehicleName = "BMW M6" },
}

MTA_MODEL_DATA.SERVER_SKIN_MODELS = {
    { baseName = "brian",         dff = "brian.dff",         txd = "brian.txd" },
    { baseName = "conmemay",      dff = "conmemay.dff",      txd = "conmemay.txd" },
    { baseName = "dylan",         dff = "dylan.dff",         txd = "dylan.txd" },
    { baseName = "lapd1",         dff = "lapd1.dff",         txd = "lapd1.txd" },
    { baseName = "nam1",          dff = "nam1.dff",          txd = "nam1.txd" },
    { baseName = "nam2",          dff = "nam2.dff",          txd = "nam2.txd" },
    { baseName = "nu1",           dff = "nu1.dff",           txd = "nu1.txd" },
    { baseName = "nu2",           dff = "nu2.dff",           txd = "nu2.txd" },
    -- army folder skins
    { baseName = "army",          dff = "army/army.dff",     txd = "army/army.txd" },
    { baseName = "army1",         dff = "army/army1.dff",    txd = "army/army1.txd" },
    { baseName = "conmemay_army", dff = "army/conmemay.dff", txd = "army/conmemay.txd" },
    { baseName = "fbi",           dff = "army/fbi.dff",      txd = "army/fbi.txd" },
    { baseName = "fbi1",          dff = "army/fbi1.dff",     txd = "army/fbi1.txd" },
    { baseName = "lafd1-1",       dff = "army/lafd1-1.dff",  txd = "army/lafd1-1.txd" },
    { baseName = "lapd1-1",       dff = "army/lapd1-1.dff",  txd = "army/lapd1-1.txd" },
    { baseName = "lapd1_army",    dff = "army/lapd1.dff",    txd = "army/lapd1.txd" },
    { baseName = "lapdm1-1",      dff = "army/lapdm1-1.dff", txd = "army/lapdm1-1.txd" },
    { baseName = "lapdm1",        dff = "army/lapdm1.dff",   txd = "army/lapdm1.txd" },
    { baseName = "lvfd1-1",       dff = "army/lvfd1-1.dff",  txd = "army/lvfd1-1.txd" },
    { baseName = "lvfd1",         dff = "army/lvfd1.dff",    txd = "army/lvfd1.txd" },
    { baseName = "lvpd1-1",       dff = "army/lvpd1-1.dff",  txd = "army/lvpd1-1.txd" },
    { baseName = "lvpd1",         dff = "army/lvpd1.dff",    txd = "army/lvpd1.txd" },
    { baseName = "sffd1-1",       dff = "army/sffd1-1.dff",  txd = "army/sffd1-1.txd" },
    { baseName = "sfpd1-1",       dff = "army/sfpd1-1.dff",  txd = "army/sfpd1-1.txd" },
    { baseName = "sfpd1",         dff = "army/sfpd1.dff",    txd = "army/sfpd1.txd" },
    { baseName = "swat",          dff = "army/swat.dff",     txd = "army/swat.txd" },
    { baseName = "swat1",         dff = "army/swat1.dff",    txd = "army/swat1.txd" },
}

MTA_MODEL_DATA.SERVER_OBJECT_MODELS = {
    { baseName = "object",     dff = "object.dff", txd = "speedo.txd" },
    { baseName = "CarDealer",  dff = "object.dff", txd = "CarDealer.txd" },
    { baseName = "GPS",        dff = "object.dff", txd = "GPS.txd" },
    { baseName = "LoginPanel", dff = "object.dff", txd = "LoginPanel.txd" },
}
customVehicleModels = customVehicleModels or {}

addEvent("onClientRegisterCustomVehicle", true)
addEventHandler("onClientRegisterCustomVehicle", resourceRoot, function(data)
    if data and data.cid and data.realId then
        customVehicleModels[data.cid] = {
            realId = data.realId,
            name   = data.baseName or ("Vehicle_" .. data.cid)
        }
        outputDebugString(("[SERVER] ✅ Map CID=%d -> realId=%d (%s)"):format(
            data.cid, data.realId, data.baseName or "nil"
        ))
    else
        outputDebugString("[SERVER] ⚠️ Invalid custom vehicle data from client")
    end
end)
