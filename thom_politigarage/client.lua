local EXPECTED_RESOURCE_NAME = "thom_politigarage"
local CURRENT_RESOURCE_NAME = GetCurrentResourceName()

if CURRENT_RESOURCE_NAME ~= EXPECTED_RESOURCE_NAME then
    _tp_runtime_locked = true
    while true do
        print(("[THOM PRODUCTIONS] Script blokkeret. Resource skal hedde '%s' (nu: '%s')."):format(EXPECTED_RESOURCE_NAME, CURRENT_RESOURCE_NAME))
        print("[THOM PRODUCTIONS] Ikke tilladt at omdøbe dette script. Udgivet gratis af Thom Productions.")
        print("[THOM PRODUCTIONS] Fjern ikke beskyttelseskode for at omgå lock. Stop resource og brug korrekt navn.")
        Wait(100)
    end
end

local ESX = exports["es_extended"]:getSharedObject()

local currentGarageId
local nuiOpen = false
local trackedVehicles = {}
local activeUnits = {}
local radialIds = {}
local serverActiveVehicles = {}
local lastVehicle = 0
local activeBlips = {}
local createdBlips = {}
local inGarageZone = nil
local parkRadialShown = false
local openRadialShown = false
local textUiVisible = false
local textUiValue = nil
local serverSaysPolice = nil
local _tp_runtime_locked = false
local isPolice
local clearPoliceFeatures
local clearAllActiveBlips
local clearAllTrackedBlips
local clearAllCreatedBlips

CreateThread(function()
    while not ESX.PlayerData or not ESX.PlayerData.job do
        ESX.PlayerData = ESX.GetPlayerData()
        Wait(250)
    end
end)

CreateThread(function()
    local lastJob = nil
    while true do
        local data = ESX.GetPlayerData()
        local jobName = data and data.job and data.job.name or nil
        if jobName and jobName ~= lastJob then
            lastJob = jobName
            if isPolice and (not isPolice()) and clearPoliceFeatures then
                clearPoliceFeatures()
            end
        end
        Wait(1000)
    end
end)

RegisterNetEvent("esx:setJob", function(job)
    ESX.PlayerData.job = job

    if isPolice and (not isPolice()) and clearPoliceFeatures then
        clearPoliceFeatures()
    end
end)

isPolice = function()
    if not Config.RequiredJob then return true end

    local clientPolice = ESX.PlayerData
        and ESX.PlayerData.job
        and ESX.PlayerData.job.name == Config.RequiredJob

    if serverSaysPolice == false then
        return false
    end

    return clientPolice == true
end

clearPoliceFeatures = function()
    serverActiveVehicles = {}
    if clearAllActiveBlips then clearAllActiveBlips() end
    if clearAllTrackedBlips then clearAllTrackedBlips() end
    if clearAllCreatedBlips then clearAllCreatedBlips() end
    if nuiOpen then
        SendNUIMessage({ action = "updateActiveVehicles", activeVehicles = {} })
    end
    if textUiVisible then
        lib.hideTextUI()
        textUiVisible = false
        textUiValue = nil
    end
    openRadialShown = false
    parkRadialShown = false
    if inGarageZone and Config.AccessType == "radial" then
        local ids = radialIds[inGarageZone]
        if ids then
            if ids.open then pcall(function() lib.removeRadialItem(ids.open) end) end
            if ids.park then pcall(function() lib.removeRadialItem(ids.park) end) end
        end
    end
end

RegisterNetEvent("tpgarage:policeStatus", function(isPoliceBool)
    serverSaysPolice = isPoliceBool and true or false
    if not serverSaysPolice then
        clearPoliceFeatures()
    end
end)

CreateThread(function()
    while true do
        TriggerServerEvent("tpgarage:checkPolice")
        Wait(2000)
    end
end)

clearAllActiveBlips = function()
    for unitId, blip in pairs(activeBlips) do
        if blip and DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
        activeBlips[unitId] = nil
    end
end

clearAllTrackedBlips = function()
    for veh, info in pairs(trackedVehicles) do
        if info and info.blip and DoesBlipExist(info.blip) then
            RemoveBlip(info.blip)
            info.blip = nil
        end
    end
end

local function registerCreatedBlip(blip)
    if blip and blip ~= 0 then
        createdBlips[blip] = true
    end
end

clearAllCreatedBlips = function()
    for blip, _ in pairs(createdBlips) do
        if blip and DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
        createdBlips[blip] = nil
    end
end

local function removeGarageBlipsBySignature()
    local sprite = Config.BlipSprite
    local blip = GetFirstBlipInfoId(sprite)
    while blip and blip ~= 0 do
        if DoesBlipExist(blip) then
            local colour = GetBlipColour(blip)
            if colour == Config.BlipColor then
                RemoveBlip(blip)
            end
        end
        blip = GetNextBlipInfoId(sprite)
    end
end

local function showGarageTextUI(text, icon)
    local ok = pcall(function()
        lib.showTextUI(text, {
            position = "right-center",
            icon = icon,
            style = {
                borderRadius = 8,
                backgroundColor = "rgba(6,10,20,0.9)",
                color = "#ffffff"
            }
        })
    end)
    if not ok then
        pcall(function()
            lib.showTextUI(text)
        end)
    end
end

local function setFuelFull(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return end
    SetVehicleFuelLevel(vehicle, 100.0)
    local ent = Entity(vehicle)
    if ent and ent.state then
        ent.state:set("fuel", 100.0, true)
    end
end

local function getGarageById(id)
    for i = 1, #Config.Garages do
        if Config.Garages[i].id == id then
            return Config.Garages[i]
        end
    end
end

local function _tp_resource_guard_client()
    local current = GetCurrentResourceName()
    if current == EXPECTED_RESOURCE_NAME then
        return
    end
    _tp_runtime_locked = true
    TriggerServerEvent("tpgarage:tamperSignal", "client_guard_detected_runtime_mismatch")
    if clearPoliceFeatures then clearPoliceFeatures() end
    closeNui()
    CreateThread(function()
        while true do
            print(("[THOM PRODUCTIONS] Manipulation opdaget i client.lua. Resource skal hedde '%s' (nu: '%s')."):format(EXPECTED_RESOURCE_NAME, current))
            print("[THOM PRODUCTIONS] Forsøg ikke at fjerne kode for at bypass'e beskyttelsen.")
            Wait(1000)
        end
    end)
    while true do
        Wait(1000)
    end
end

CreateThread(function()
    while true do
        _tp_resource_guard_client()
        Wait(5000)
    end
end)

local function closeNui()
    if not nuiOpen then return end
    nuiOpen = false
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    SendNUIMessage({
        action = "close"
    })
end

local function parkCurrentVehicle()
    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped, false) then
        lib.notify({
            title = "Politi Garage",
            description = "Du skal sidde i et køretøj for at parkere",
            type = "error"
        })
        return
    end

    local veh = GetVehiclePedIsIn(ped, false)
    if veh == 0 or not DoesEntityExist(veh) then return end

    local info = trackedVehicles[veh]
    if not info then
        lib.notify({
            title = "Politi Garage",
            description = "Dette køretøj er ikke en aktiv enhed fra garagen",
            type = "error"
        })
        return
    end

    TaskLeaveVehicle(ped, veh, 0)

    local ok = lib.progressCircle({
        duration = 5000,
        label = "Parkerer køretøjet",
        position = "bottom",
        useWhileDead = false,
        canCancel = false,
        disable = { car = true, move = true, combat = true }
    })

    if not ok then return end

    if info.blip and DoesBlipExist(info.blip) then
        RemoveBlip(info.blip)
    end

    if info.unitId then
        TriggerServerEvent("tpgarage:removeUnit", info.unitId)
    end

    trackedVehicles[veh] = nil
    activeUnits[veh] = nil

    SetEntityAsMissionEntity(veh, true, true)
    DeleteEntity(veh)

    lib.notify({
        title = "Politi Garage",
        description = "Køretøj parkeret",
        type = "success"
    })
end

local function openNui(garageId)
    if nuiOpen then return end
    local garage = getGarageById(garageId)
    if not garage then return end
    currentGarageId = garageId
    nuiOpen = true
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)
    TriggerServerEvent("tpgarage:requestActiveUnits")
    SendNUIMessage({
        action = "open",
        garage = {
            id = garage.id,
            label = garage.label
        },
        categories = Config.Categories,
        vehicles = Config.Vehicles,
        unitCategories = Config.UnitCategories,
        activeVehicles = serverActiveVehicles
    })
end

RegisterNetEvent("tpgarage:openGarage", function(garageId)
    if _tp_runtime_locked then return end
    openNui(garageId)
end)

RegisterNUICallback("close", function(_, cb)
    if _tp_runtime_locked then cb({}); return end
    closeNui()
    cb({})
end)

RegisterNUICallback("spawnVehicle", function(data, cb)
    if _tp_runtime_locked then cb({}); return end
    cb({})
    closeNui()

    lib.progressBar({
        duration = 3000,
        label = "Henter køretøj",
        useWhileDead = false,
        canCancel = false,
        disable = { move = true, combat = true, car = true }
    })

    local garage = getGarageById(currentGarageId)
    if not garage then return end
    local model = data and data.model
    if type(model) ~= "string" or model == "" then return end
    local vehConfig
    for i = 1, #Config.Vehicles do
        if Config.Vehicles[i].model == model then
            vehConfig = Config.Vehicles[i]
            break
        end
    end
    if not vehConfig then return end
    local spawnPoints = garage.spawnPoints or Config.SpawnPoints
    if type(spawnPoints) ~= "table" or #spawnPoints == 0 then return end
    local chosenIndex
    for i = 1, #spawnPoints do
        local sp = spawnPoints[i]
        local free = true
        local vehicles = GetGamePool("CVehicle")
        local spCoords = vector3(sp.x, sp.y, sp.z)
        for j = 1, #vehicles do
            local veh = vehicles[j]
            if #(GetEntityCoords(veh) - spCoords) < 3.0 then
                free = false
                break
            end
        end
        if free then
            chosenIndex = i
            break
        end
    end
    if not chosenIndex then
        lib.notify({
            title = "Politi Garage",
            description = "Alle parkeringspladser er optaget",
            type = "error"
        })
        return
    end
    local spawnPoint = spawnPoints[chosenIndex]
    local modelHash = joaat(model)
    if not IsModelInCdimage(modelHash) or not IsModelAVehicle(modelHash) then return end
    lib.requestModel(modelHash)
    local ped = PlayerPedId()

    ClearAreaOfVehicles(spawnPoint.x, spawnPoint.y, spawnPoint.z, 6.0, false, false, false, false, false)
    local vehicle = CreateVehicle(modelHash, spawnPoint.x, spawnPoint.y, spawnPoint.z, spawnPoint.w, true, false)
    SetEntityAsMissionEntity(vehicle, true, true)
    NetworkRegisterEntityAsNetworked(vehicle)
    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    if netId and netId ~= 0 then
        SetNetworkIdExistsOnAllMachines(netId, true)
        SetNetworkIdCanMigrate(netId, true)
    end
    SetVehicleOnGroundProperly(vehicle)
    SetVehicleFixed(vehicle)
    SetVehicleDeformationFixed(vehicle)
    SetVehicleDirtLevel(vehicle, 0.0)
    SetVehicleUndriveable(vehicle, false)
    SetVehicleEngineCanDegrade(vehicle, false)
    SetDisableVehicleEngineFires(vehicle, true)
    SetVehicleTyresCanBurst(vehicle, false)
    SetVehicleEngineHealth(vehicle, math.max(1000.0, tonumber(vehConfig.engine) or 1000.0))
    SetVehicleBodyHealth(vehicle, math.max(1000.0, tonumber(vehConfig.body) or 1000.0))
    SetVehiclePetrolTankHealth(vehicle, 1000.0)
    setFuelFull(vehicle)
    SetVehicleModKit(vehicle, 0)
    SetVehicleEngineOn(vehicle, false, true, false)
    SetVehicleDoorsLocked(vehicle, 1)
    SetVehicleHasBeenOwnedByPlayer(vehicle, true)
    SetVehRadioStation(vehicle, "OFF")
    SetModelAsNoLongerNeeded(modelHash)
    local withGps = data and data.withGps
    if withGps then
        local unitCategory = data.unitCategory or "Bravo"
        local unitNumber = tonumber(data.unitNumber) or 1
        if unitNumber < 1 then unitNumber = 1 end
        if unitNumber > 99 then unitNumber = 99 end
        local unitLabel = ("%s %02d"):format(unitCategory, unitNumber)
        local blip = 0
        if isPolice() then
            blip = AddBlipForEntity(vehicle)
            registerCreatedBlip(blip)
            SetBlipSprite(blip, Config.BlipSprite)
            SetBlipColour(blip, Config.BlipColor)
            SetBlipScale(blip, Config.BlipScale)
            SetBlipAsShortRange(blip, false)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(unitLabel)
            EndTextCommandSetBlipName(blip)
        end
        trackedVehicles[vehicle] = {
            blip = blip,
            config = vehConfig,
            unitLabel = unitLabel,
            unitId = tostring(netId)
        }
        activeUnits[vehicle] = true
        TriggerServerEvent("tpgarage:registerUnit", tostring(netId), {
            model = vehConfig.model,
            unitLabel = unitLabel,
            modelLabel = vehConfig.displayName,
            garageLabel = vehConfig.displayName or vehConfig.garage,
            image = vehConfig.image
        })
        lib.notify({
            title = "Politi Garage",
            description = ("Kategori %s tilføjet til GPS"):format(unitLabel),
            type = "success"
        })
    end
end)

CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local veh = GetVehiclePedIsIn(ped, false)
        if veh ~= 0 and DoesEntityExist(veh) and veh ~= lastVehicle then
            lastVehicle = veh
            if trackedVehicles[veh] then
                SetVehicleUndriveable(veh, false)
                SetVehicleEngineOn(veh, true, true, false)
                SetVehicleEngineHealth(veh, math.max(1000.0, GetVehicleEngineHealth(veh)))
                SetVehiclePetrolTankHealth(veh, 1000.0)
                setFuelFull(veh)
            end
        elseif veh == 0 then
            lastVehicle = 0
        end
        Wait(250)
    end
end)

RegisterNUICallback("connectUnit", function(data, cb)
    if _tp_runtime_locked then cb({}); return end
    cb({})
    local unitId = data and data.unitId
    if type(unitId) ~= "string" or unitId == "" then return end
    TriggerServerEvent("tpgarage:connectUnit", unitId)
    lib.notify({
        title = "Politi Garage",
        description = "Koblet på enhed",
        type = "success"
    })
end)

RegisterNetEvent("tpgarage:syncActiveUnits", function(activeVehiclesPayload)
    if _tp_runtime_locked then return end
    if not isPolice() then
        serverActiveVehicles = {}
        clearAllActiveBlips()
        if nuiOpen then
            SendNUIMessage({ action = "updateActiveVehicles", activeVehicles = {} })
        end
        return
    end

    serverActiveVehicles = type(activeVehiclesPayload) == "table" and activeVehiclesPayload or {}

    local stillActive = {}
    for i = 1, #serverActiveVehicles do
        stillActive[serverActiveVehicles[i].unitId] = true
    end
    for unitId, blip in pairs(activeBlips) do
        if not stillActive[unitId] then
            if blip and DoesBlipExist(blip) then
                RemoveBlip(blip)
            end
            activeBlips[unitId] = nil
        end
    end

    if nuiOpen then
        SendNUIMessage({
            action = "updateActiveVehicles",
            activeVehicles = serverActiveVehicles
        })
    end
end)

CreateThread(function()
    while true do
        if isPolice() and #serverActiveVehicles > 0 then
            for i = 1, #serverActiveVehicles do
                local unit = serverActiveVehicles[i]
                local unitId = unit.unitId
                if unitId and not activeBlips[unitId] then
                    local entity = NetworkGetEntityFromNetworkId(tonumber(unitId) or 0)
                    if entity ~= 0 and DoesEntityExist(entity) then
                        local blip = AddBlipForEntity(entity)
                        registerCreatedBlip(blip)
                        SetBlipSprite(blip, Config.BlipSprite)
                        SetBlipColour(blip, Config.BlipColor)
                        SetBlipScale(blip, Config.BlipScale)
                        SetBlipAsShortRange(blip, false)
                        BeginTextCommandSetBlipName("STRING")
                        AddTextComponentString(unit.displayName or "Politi")
                        EndTextCommandSetBlipName(blip)
                        activeBlips[unitId] = blip
                    end
                end
            end
        end
        Wait(1000)
    end
end)

CreateThread(function()
    while true do
        if not isPolice() then
            clearPoliceFeatures()
            removeGarageBlipsBySignature()
        end
        Wait(1000)
    end
end)

CreateThread(function()
    while true do
        if inGarageZone and isPolice() then
            local ped = PlayerPedId()
            local inVeh = IsPedInAnyVehicle(ped, false)
            local desiredText = inVeh and "Parker køretøj" or "Politi garage"
            if not textUiVisible or textUiValue ~= desiredText then
                showGarageTextUI(desiredText, inVeh and "square-parking" or "car")
                textUiVisible = true
                textUiValue = desiredText
            end

            if Config.AccessType == "radial" then
            if not openRadialShown then
                local ids = radialIds[inGarageZone]
                if ids and ids.open then
                    lib.addRadialItem({
                        id = ids.open,
                        label = "Åben Politi Garage",
                        icon = "car",
                        onSelect = function()
                            TriggerServerEvent("tpgarage:requestOpen", inGarageZone)
                        end
                    })
                    openRadialShown = true
                end
            end
            if inVeh and not parkRadialShown then
                local ids = radialIds[inGarageZone]
                if ids and ids.park then
                    lib.addRadialItem({
                        id = ids.park,
                        label = "Parker køretøj",
                        icon = "square-parking",
                        onSelect = function()
                            parkCurrentVehicle()
                        end
                    })
                    parkRadialShown = true
                end
            elseif (not inVeh) and parkRadialShown then
                local ids = radialIds[inGarageZone]
                if ids and ids.park then
                    lib.removeRadialItem(ids.park)
                end
                parkRadialShown = false
            end
            end
        else
            if openRadialShown and Config.AccessType == "radial" and inGarageZone then
                local ids = radialIds[inGarageZone]
                if ids and ids.open then
                    lib.removeRadialItem(ids.open)
                end
                openRadialShown = false
            end
            if parkRadialShown and Config.AccessType == "radial" and inGarageZone then
                local ids = radialIds[inGarageZone]
                if ids and ids.park then
                    lib.removeRadialItem(ids.park)
                end
                parkRadialShown = false
            end
            if textUiVisible then
            lib.hideTextUI()
            textUiVisible = false
            textUiValue = nil
            end
        end
        Wait(300)
    end
end)

CreateThread(function()
    while true do
        if next(trackedVehicles) ~= nil then
            for veh, info in pairs(trackedVehicles) do
                if DoesEntityExist(veh) then
                    if info.blip and DoesBlipExist(info.blip) then
                        local coords = GetEntityCoords(veh)
                        SetBlipCoords(info.blip, coords.x, coords.y, coords.z)
                    end
                else
                    if info.blip and DoesBlipExist(info.blip) then
                        RemoveBlip(info.blip)
                    end
                    if info.unitId then
                        TriggerServerEvent("tpgarage:removeUnit", info.unitId)
                    end
                    trackedVehicles[veh] = nil
                    activeUnits[veh] = nil
                end
            end
        end
        Wait(1000)
    end
end)

local function createGaragePoints()
    for i = 1, #Config.Garages do
        local garage = Config.Garages[i]
        local baseRadius = garage.radius or 5.0
        local uiRadius = baseRadius + 12.0
        local point = lib.points.new({
            coords = garage.coords,
            distance = uiRadius,
            id = garage.id
        })
        function point:onEnter()
            if _tp_runtime_locked then return end
            if Config.AccessType == "radial" then
                local openId = "tpgarage_" .. garage.id
                local parkId = "tpgarage_park_" .. garage.id
                radialIds[garage.id] = { open = openId, park = parkId }
                inGarageZone = garage.id
                parkRadialShown = false
                openRadialShown = false
            else
                lib.showTextUI('Tryk [E] for at tilgå garagen', {
                    position = "left-center",
                    icon = "car",
                    style = {
                        borderRadius = 8,
                        backgroundColor = "rgba(6,10,20,0.9)",
                        color = "#ffffff"
                    }
                })
            end
        end
        function point:onExit()
            if _tp_runtime_locked then return end
            SetTimeout(1200, function()
                local ped = PlayerPedId()
                local coords = GetEntityCoords(ped)
                if #(coords - garage.coords) <= uiRadius then
                    return
                end

                if Config.AccessType == "radial" then
                    local ids = radialIds[garage.id]
                    if ids then
                        if ids.open then lib.removeRadialItem(ids.open) end
                        if ids.park then lib.removeRadialItem(ids.park) end
                        radialIds[garage.id] = nil
                    end
                    if inGarageZone == garage.id then
                        inGarageZone = nil
                        parkRadialShown = false
                        openRadialShown = false
                    end
                else
                    lib.hideTextUI()
                end
            end)
        end
        function point:nearby()
            if _tp_runtime_locked then return end
            if Config.AccessType == "button" then
                if IsControlJustReleased(0, 38) then
                    TriggerServerEvent("tpgarage:requestOpen", garage.id)
                end
            end
        end
    end
end

CreateThread(function()
    createGaragePoints()
end)

RegisterCommand("closepolicegarage", function()
    closeNui()
end, false)

RegisterKeyMapping("closepolicegarage", "Luk Politi Garage NUI", "keyboard", "ESCAPE")

