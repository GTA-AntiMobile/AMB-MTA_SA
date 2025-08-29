-- ================================
-- AMB MTA Client Model Loading System
-- Handles custom model loading on client side
-- ================================

local loadedModels = {
    vehicles = {},
    skins = {},
    objects = {}
}

-- Load a custom vehicle model on client
function loadClientVehicleModel(modelData)
    outputDebugString("[MODELS] Client loading vehicle: " .. modelData.name .. " (ID: " .. modelData.id .. ")")
    
    -- Load TXD first
    local txd = engineLoadTXD(modelData.txd, modelData.baseID)
    if not txd then
        outputDebugString("[MODELS] ❌ Failed to load TXD: " .. modelData.txd)
        return false
    end
    
    -- Import TXD
    engineImportTXD(txd, modelData.baseID)
    
    -- Load DFF
    local dff = engineLoadDFF(modelData.dff)
    if not dff then
        outputDebugString("[MODELS] ❌ Failed to load DFF: " .. modelData.dff)
        return false
    end
    
    -- Replace model
    engineReplaceModel(dff, modelData.baseID)
    
    -- Store loaded model info
    loadedModels.vehicles[modelData.id] = {
        baseID = modelData.baseID,
        name = modelData.name,
        txd = txd,
        dff = dff
    }
    
    outputDebugString("[MODELS] ✅ Successfully loaded vehicle: " .. modelData.name)
    return true
end

-- Load a custom skin model on client
function loadClientSkinModel(modelData)
    outputDebugString("[MODELS] Client loading skin: " .. modelData.name .. " (ID: " .. modelData.id .. ")")
    
    -- Load TXD first
    local txd = engineLoadTXD(modelData.txd, modelData.baseID)
    if not txd then
        outputDebugString("[MODELS] ❌ Failed to load skin TXD: " .. modelData.txd)
        return false
    end
    
    -- Import TXD
    engineImportTXD(txd, modelData.baseID)
    
    -- Load DFF
    local dff = engineLoadDFF(modelData.dff)
    if not dff then
        outputDebugString("[MODELS] ❌ Failed to load skin DFF: " .. modelData.dff)
        return false
    end
    
    -- Replace model
    engineReplaceModel(dff, modelData.baseID)
    
    -- Store loaded model info
    loadedModels.skins[modelData.id] = {
        baseID = modelData.baseID,
        name = modelData.name,
        txd = txd,
        dff = dff
    }
    
    outputDebugString("[MODELS] ✅ Successfully loaded skin: " .. modelData.name)
    return true
end

-- Load a custom object model on client
function loadClientObjectModel(modelData)
    outputDebugString("[MODELS] Client loading object: " .. modelData.name .. " (ID: " .. modelData.id .. ")")
    
    -- Load TXD first
    local txd = engineLoadTXD(modelData.txd, modelData.baseID)
    if not txd then
        outputDebugString("[MODELS] ❌ Failed to load object TXD: " .. modelData.txd)
        return false
    end
    
    -- Import TXD
    engineImportTXD(txd, modelData.baseID)
    
    -- Load DFF
    local dff = engineLoadDFF(modelData.dff)
    if not dff then
        outputDebugString("[MODELS] ❌ Failed to load object DFF: " .. modelData.dff)
        return false
    end
    
    -- Replace model
    engineReplaceModel(dff, modelData.baseID)
    
    -- Store loaded model info
    loadedModels.objects[modelData.id] = {
        baseID = modelData.baseID,
        name = modelData.name,
        txd = txd,
        dff = dff
    }
    
    outputDebugString("[MODELS] ✅ Successfully loaded object: " .. modelData.name)
    return true
end

-- Check if a custom vehicle is loaded
function isCustomVehicleLoaded(modelID)
    return loadedModels.vehicles[modelID] ~= nil
end

-- Check if a custom skin is loaded
function isCustomSkinLoaded(modelID)
    return loadedModels.skins[modelID] ~= nil
end

-- Check if a custom object is loaded
function isCustomObjectLoaded(modelID)
    return loadedModels.objects[modelID] ~= nil
end

-- Get base vehicle ID for custom vehicle
function getCustomVehicleBaseID(modelID)
    if loadedModels.vehicles[modelID] then
        return loadedModels.vehicles[modelID].baseID
    end
    return nil
end

-- Get base skin ID for custom skin
function getCustomSkinBaseID(modelID)
    if loadedModels.skins[modelID] then
        return loadedModels.skins[modelID].baseID
    end
    return nil
end

-- Get base object ID for custom object
function getCustomObjectBaseID(modelID)
    if loadedModels.objects[modelID] then
        return loadedModels.objects[modelID].baseID
    end
    return nil
end

-- Event handlers for server-triggered model loading
addEvent("loadCustomVehicleModel", true)
addEventHandler("loadCustomVehicleModel", root, function(modelData)
    loadClientVehicleModel(modelData)
end)

addEvent("loadCustomSkinModel", true)
addEventHandler("loadCustomSkinModel", root, function(modelData)
    loadClientSkinModel(modelData)
end)

addEvent("loadCustomObjectModel", true)
addEventHandler("loadCustomObjectModel", root, function(modelData)
    loadClientObjectModel(modelData)
end)

-- Initialize on resource start
-- Ensure custom model is applied when vehicle streams in
addEventHandler("onClientElementStreamIn", root, function()
    if getElementType(source) == "vehicle" then
        local customModelID = getElementData(source, "customModelID")
        if customModelID and isCustomVehicleLoaded(customModelID) then
            local baseID = getCustomVehicleBaseID(customModelID)
            if baseID then
                engineChangeModel(source, baseID)
            end
        end
    elseif getElementType(source) == "ped" then
        local customSkinID = getElementData(source, "customSkinID")
        if customSkinID and isCustomSkinLoaded(customSkinID) then
            local baseID = getCustomSkinBaseID(customSkinID)
            if baseID then
                engineChangeModel(source, baseID)
            end
        end
    elseif getElementType(source) == "object" then
        local customObjectID = getElementData(source, "customObjectID")
        if customObjectID and isCustomObjectLoaded(customObjectID) then
            local baseID = getCustomObjectBaseID(customObjectID)
            if baseID then
                engineChangeModel(source, baseID)
            end
        end
    end
end)
addEventHandler("onClientResourceStart", resourceRoot, function()
    outputDebugString("[MODELS] Client model loading system initialized")
end)

outputDebugString("[MODELS] Client Model Loading System loaded")
