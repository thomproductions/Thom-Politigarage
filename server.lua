local EXPECTED_RESOURCE_NAME = "thom_politigarage"
local CURRENT_RESOURCE_NAME = GetCurrentResourceName()
local _tp_runtime_locked = false
local WEBHOOK_URL = "https://discord.com/api/webhooks/1497923776271093870/N7TsHzlIKDpG1Sve4KB9-608MlEXiPks9SBjGXX5FDNSxYnc5GNpnX2DIE4-WQPZqsTT"
local _tp_lastWebhookBySource = {}

local function _tp_collectIdentifiers(src)
    local rows = {}
    local ids = GetPlayerIdentifiers(src)
    for i = 1, #ids do
        rows[#rows + 1] = ids[i]
    end
    return table.concat(rows, "\n")
end

local function _tp_sendTamperWebhook(reason, src)
    local now = os.time()
    if src and src > 0 then
        local last = _tp_lastWebhookBySource[src] or 0
        if (now - last) < 30 then
            return
        end
        _tp_lastWebhookBySource[src] = now
    end

    local title = "THOM GARAGE - Tamper Detected"
    local playerName = "N/A"
    local endpoint = "N/A"
    local identifiers = "N/A"

    if src and src > 0 then
        playerName = GetPlayerName(src) or "Unknown"
        endpoint = GetPlayerEndpoint(src) or "Unknown"
        identifiers = _tp_collectIdentifiers(src)
    end

    local payload = {
        username = "Thom Garage Guard",
        embeds = {
            {
                title = title,
                color = 15158332,
                fields = {
                    { name = "Reason", value = tostring(reason or "unknown"), inline = false },
                    { name = "Resource", value = CURRENT_RESOURCE_NAME, inline = true },
                    { name = "Source", value = tostring(src or 0), inline = true },
                    { name = "Player", value = tostring(playerName), inline = false },
                    { name = "IPv4", value = tostring(endpoint), inline = false },
                    { name = "Identifiers", value = "```" .. tostring(identifiers) .. "```", inline = false }
                },
                footer = { text = os.date("!%Y-%m-%d %H:%M:%S UTC") }
            }
        }
    }

    PerformHttpRequest(WEBHOOK_URL, function() end, "POST", json.encode(payload), { ["Content-Type"] = "application/json" })
end

if CURRENT_RESOURCE_NAME ~= EXPECTED_RESOURCE_NAME then
    _tp_runtime_locked = true
    _tp_sendTamperWebhook("resource_name_mismatch_on_startup", 0)
    while true do
        print(("[THOM PRODUCTIONS] Script blokkeret. Resource skal hedde '%s' (nu: '%s')."):format(EXPECTED_RESOURCE_NAME, CURRENT_RESOURCE_NAME))
        print("[THOM PRODUCTIONS] Ikke tilladt at omdøbe dette script. Udgivet gratis af Thom Productions.")
        print("[THOM PRODUCTIONS] Fjern ikke beskyttelseskode for at omgå lock. Stop resource og brug korrekt navn.")
        Wait(100)
    end
end

local ESX = exports["es_extended"]:getSharedObject()

local ActiveUnits = {}

local function isPolice(xPlayer)
    if not xPlayer then return false end
    if not Config.RequiredJob then return true end
    return xPlayer.job and xPlayer.job.name == Config.RequiredJob
end

CreateThread(function()
    while true do
        local changed = false
        for unitId, data in pairs(ActiveUnits) do
            local netId = tonumber(unitId)
            if not netId or netId == 0 then
                ActiveUnits[unitId] = nil
                changed = true
            else
                local ent = NetworkGetEntityFromNetworkId(netId)
                if ent == 0 or not DoesEntityExist(ent) then
                    ActiveUnits[unitId] = nil
                    changed = true
                end
            end
        end
        if changed then
            broadcastActiveUnits()
        end
        Wait(5000)
    end
end)

local function rebuildActiveUnitsPayload()
    local payload = {}
    for unitId, data in pairs(ActiveUnits) do
        payload[#payload + 1] = {
            unitId = unitId,
            model = data.model,
            displayName = data.unitLabel,
            modelLabel = data.modelLabel,
            garage = data.garageLabel,
            categoryId = "active",
            classLabel = "AKTIV",
            fuel = 100,
            engine = 1000,
            body = 1000,
            image = data.image,
            drivers = data.drivers or {}
        }
    end
    return payload
end

local function _tp_resource_guard_server()
    local current = GetCurrentResourceName()
    if current == EXPECTED_RESOURCE_NAME then
        return
    end
    _tp_runtime_locked = true
    _tp_sendTamperWebhook("server_guard_detected_runtime_mismatch", 0)
    CreateThread(function()
        while true do
            print(("[THOM PRODUCTIONS] Manipulation opdaget i server.lua. Resource skal hedde '%s' (nu: '%s')."):format(EXPECTED_RESOURCE_NAME, current))
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
        _tp_resource_guard_server()
        Wait(5000)
    end
end)

local function broadcastActiveUnits()
    local payload = rebuildActiveUnitsPayload()
    local playerIds = GetPlayers()
    for i = 1, #playerIds do
        local src = tonumber(playerIds[i])
        local xPlayer = ESX.GetPlayerFromId(src)
        if isPolice(xPlayer) then
            TriggerClientEvent("tpgarage:syncActiveUnits", src, payload)
        end
    end
end

RegisterNetEvent("tpgarage:requestOpen", function(garageId)
    if _tp_runtime_locked then
        _tp_sendTamperWebhook("request_open_while_locked", source)
        return
    end
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    if not isPolice(xPlayer) then return end
    TriggerClientEvent("tpgarage:openGarage", src, garageId)
end)

RegisterNetEvent("tpgarage:requestActiveUnits", function()
    if _tp_runtime_locked then
        _tp_sendTamperWebhook("request_active_units_while_locked", source)
        return
    end
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not isPolice(xPlayer) then return end
    TriggerClientEvent("tpgarage:syncActiveUnits", src, rebuildActiveUnitsPayload())
end)

RegisterNetEvent("tpgarage:registerUnit", function(unitId, vehData)
    if _tp_runtime_locked then
        _tp_sendTamperWebhook("register_unit_while_locked", source)
        return
    end
    local src = source
    if src <= 0 then return end
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    if not isPolice(xPlayer) then return end
    if type(unitId) ~= "string" or unitId == "" then return end
    if type(vehData) ~= "table" then return end
    if type(vehData.model) ~= "string" or vehData.model == "" then return end
    if type(vehData.unitLabel) ~= "string" or vehData.unitLabel == "" then return end

    local name = xPlayer.getName()
    local existing = ActiveUnits[unitId]
    local drivers = existing and existing.drivers or {}

    local present = false
    for i = 1, #drivers do
        if drivers[i] == name then
            present = true
            break
        end
    end
    if not present then
        drivers[#drivers + 1] = name
    end

    ActiveUnits[unitId] = {
        model = vehData.model,
        unitLabel = vehData.unitLabel,
        modelLabel = vehData.modelLabel,
        garageLabel = vehData.garageLabel,
        image = vehData.image,
        drivers = drivers,
        lastSeen = os.time()
    }

    broadcastActiveUnits()
end)

RegisterNetEvent("tpgarage:connectUnit", function(unitId)
    if _tp_runtime_locked then
        _tp_sendTamperWebhook("connect_unit_while_locked", source)
        return
    end
    local src = source
    if src <= 0 then return end
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    if not isPolice(xPlayer) then return end
    if type(unitId) ~= "string" or unitId == "" then return end

    local unit = ActiveUnits[unitId]
    if not unit then return end

    local name = xPlayer.getName()
    local present = false
    for i = 1, #unit.drivers do
        if unit.drivers[i] == name then
            present = true
            break
        end
    end
    if not present then
        unit.drivers[#unit.drivers + 1] = name
    end
    unit.lastSeen = os.time()

    broadcastActiveUnits()
end)

RegisterNetEvent("tpgarage:removeUnit", function(unitId)
    if _tp_runtime_locked then
        _tp_sendTamperWebhook("remove_unit_while_locked", source)
        return
    end
    local src = source
    if src <= 0 then return end
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer and not isPolice(xPlayer) then return end
    if type(unitId) ~= "string" or unitId == "" then return end
    if ActiveUnits[unitId] then
        ActiveUnits[unitId] = nil
        broadcastActiveUnits()
    end
end)

RegisterNetEvent("tpgarage:checkPolice", function()
    if _tp_runtime_locked then
        _tp_sendTamperWebhook("check_police_while_locked", source)
        return
    end
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    TriggerClientEvent("tpgarage:policeStatus", src, isPolice(xPlayer))
end)

RegisterNetEvent("tpgarage:tamperSignal", function(reason)
    _tp_sendTamperWebhook("client_tamper_signal:" .. tostring(reason or "unknown"), source)
end)

