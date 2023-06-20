ESX = nil
ServerState = {}
TriggerEvent(Framework.getLibs, function(lib)
    ESX = lib
end)

GlobalState.dirtyPlayersPed = {}
ServerState.dirtyPlayersPed = {}

local tag = GetCurrentResourceName() .. ':'
local registerEvet = RegisterServerEvent
regEvent = function(name, handler)
    return registerEvet(tag .. name, handler)
end


regEvent('isCanTakeShower', function()
    local _source = source
    local player = ESX.GetPlayerFromId(_source)
    local playerItemShower = player.getInventoryItem(Settings.takeShowerItem)
    if not playerItemShower or (playerItemShower and playerItemShower.count <= 0) then 
        TriggerClientEvent(tag .. 'response', _source, false)
        return
    end

    player.removeInventoryItem(Settings.takeShowerItem, 1)
    TriggerClientEvent(tag .. 'response', _source, true)
end)


regEvent('setmedirty', function()
    local _source = source
    local strSource = tostring(source)
    ServerState.dirtyPlayersPed[strSource] = _source
    GlobalState.dirtyPlayersPed = ServerState.dirtyPlayersPed
end)    

regEvent('setmeclean', function()
    local _source = source
    local strSource = tostring(source)
    if ServerState.dirtyPlayersPed[strSource] then
        ServerState.dirtyPlayersPed[strSource] = nil
        GlobalState.dirtyPlayersPed = ServerState.dirtyPlayersPed
        TriggerClientEvent(tag .. 'removedirtyplayer', -1, strSource)
    end

end)    

AddEventHandler('playerDropped', function()
    local _source = source
    local strSource = tostring(source)
    if ServerState.dirtyPlayersPed[strSource] then
        ServerState.dirtyPlayersPed[strSource] = nil
        GlobalState.dirtyPlayersPed = ServerState.dirtyPlayersPed
    end
end)