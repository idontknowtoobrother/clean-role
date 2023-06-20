
CreateThread = Citizen.CreateThread
Wait = Citizen.Wait

local tag = GetCurrentResourceName() .. ':'
local registerEvet = RegisterNetEvent
regEvent = function(name, handler)
    return registerEvet(tag .. name, handler)
end

PlayerState = {}
PlayerState.closestZone = {}
PlayerState.isTakingShower = false
PlayerState.getCleanPedStatus = 100
PlayerState.dirtyPlayersPed = {}
ESX = nil







function isList(table)
    for k, _ in pairs(table) do
        return k == 1
    end
end
function PlayerState:canTakeShower()
    local playerInventory = ESX.GetPlayerData().inventory
    local isList = isList(playerInventory)
    if isList then
        for _, item in ipairs(playerInventory) do
            if item and item.name == Settings.takeShowerItem and item.count > 0 then
                return true
            end
        end
        Notify.dontHaveItem()
        return false
    end
    local canTakeShower = playerInventory[Settings.takeShowerItem] and playerInventory[Settings.takeShowerItem].count > 0
    if not canTakeShower then
        Notify.dontHaveItem()
    end
    return canTakeShower
end

function PlayerState:checkCanShowerServerSide(cb)

    self.cb = cb
    TriggerServerEvent(tag.. 'isCanTakeShower')


end

function loadPtfxAsset(dict)
    if not HasNamedPtfxAssetLoaded(dict) then
		RequestNamedPtfxAsset(dict)
		while not HasNamedPtfxAssetLoaded(dict) do
			Wait(1)
		end
	end
    return true
end

function PlayerState:startTakeShower()
    if self.isTakingShower then return end
    self.isTakingShower = true

    self.playerSkin = ESX.GetPlayerData().skin
    local showerSkin = self.playerSkin.sex == 0 and Clothes.onTakeShower.male or Clothes.onTakeShower.female
    TriggerEvent('skinchanger:loadClothes', self.playerSkin, showerSkin)

    local coords = GetEntityCoords(PlayerPedId())
	FreezeEntityPosition((PlayerPedId()), true)
    loadPtfxAsset("core")

	TaskStartScenarioInPlace((PlayerPedId()), "PROP_HUMAN_STAND_IMPATIENT", 0, true)
    
	timer = Settings.takeShowerTime
    if Settings.blurScreen then
        TriggerScreenblurFadeIn(300)
    end
    Functions.progressbar(timer)

    self.particles = StartParticleFxLoopedAtCoord(
        "ent_sht_water",
        coords.x,
        coords.y,
        coords.z + 1.5,
        0.0,
        180.0,
        0.0,
        5.0,
        false,
        false,
        false,
        false
    )

    CreateThread(function()
		while self.isTakingShower do
			Wait(0)
            Functions.showHelpCancelTakeShower()
			if IsControlJustPressed(0, Settings.keyControl.stop) then
                Notify.stop()
                PlayerState:stopShower()
            end
		end
	end)

	CreateThread(function()
		while self.isTakingShower do
			Wait(1000)
			if(timer > 0)then
				timer = timer - 1
                if not self.isTakingShower then return end
				StopParticleFxLooped(self.particles, 0) 
                UseParticleFxAssetNextCall("core")
                self.particles = StartParticleFxLoopedAtCoord(
                    "ent_sht_water",
                    coords.x,
                    coords.y,
                    coords.z + 1.5,
                    0.0,
                    180.0,
                    0.0,
                    5.0,
                    false,
                    false,
                    false,
                    false
                )
                Functions.addStatus()
			elseif (timer == 0) then
				Notify.done()
                PlayerState:stopShower()
			end
		end
	end)


end

function PlayerState:stopShower()
    if not self.isTakingShower then return end
    self.isTakingShower = false

    Functions.clearProgressbar()
    if Settings.blurScreen then
        TriggerScreenblurFadeOut(300)
    end
    StopParticleFxLooped(self.particles, 0) 
    TriggerEvent('skinchanger:loadSkin', self.playerSkin)
    FreezeEntityPosition((PlayerPedId()), false)
    ClearPedTasksImmediately(PlayerPedId()) 

    CreateThread(initialThread)
end

regEvent('response', function(pass)
    if not PlayerState.cb then return end
    if not pass then
        Notify.dontHaveItem()
    end
    PlayerState.cb(pass)
    PlayerState.cb = nil
end)


--[ @ Draw 3D Text Label
function draw3DText(label, coords, myCoords)
    RegisterFontFile(Others.fontName)
    local fontId = RegisterFontId(Others.fontName) or 1
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    local dist       = GetDistanceBetweenCoords(px, py, pz, coords.x, coords.y, coords.z, 1)    
    local scale      = (1 / dist) * 20
    local fov        = (1 / GetGameplayCamFov()) * 100
    scale            = scale * fov   
    SetTextScale(Others.fontSize * scale, Others.fontSize * scale)
    SetTextFont(fontId)
    SetTextProportional(1)
    local opc = math.floor(255/#(coords-myCoords)*4)
    SetTextColour(255, 255, 255, opc > 255 and 255 or opc)
    SetTextDropshadow(15, 1, 1, 1, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextOutline()
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(label)
    SetDrawOrigin(coords.x, coords.y, coords.z + 1.05, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

function pullClosestZone()
    while true do
        Wait(1000)
        local closestZones = {}
        for _, coords in ipairs(Zones.showers) do
            local pedCoords = GetEntityCoords(PlayerPedId())
            if #(pedCoords - coords) < 50.0 then
                table.insert(closestZones, coords)
            end
        end
        
        PlayerState.closestZone = closestZones
    end
end

function initialThread()
    while true do
        while #PlayerState.closestZone > 0 do
            Wait(0)
            local playerCoords = GetEntityCoords(PlayerPedId())
            for _, coords in ipairs(PlayerState.closestZone) do
                draw3DText(Others.label3DText, coords, playerCoords)
                if #(playerCoords - coords) < 2.0 then
                    Functions.showHelpTextNotification()
                    if IsControlJustPressed(0, Settings.keyControl.start) and PlayerState:canTakeShower() then
                        local passed = nil
                        PlayerState:checkCanShowerServerSide(function(pass) 
                            passed = pass
                        end)
                        while passed == nil do
                            Wait(0)
                        end
                        if passed then
                            return PlayerState:startTakeShower()
                        end
                    end
                end
            end
        end
        Wait(1000)
    end    
end

function dirtyThread()
    while true do

        Functions.getCleanPedStatus(function(percent)
            PlayerState.cleanValue = percent
            print(PlayerState.cleanValue)
        end)

        if PlayerState.cleanValue < Settings.dirtyEffectStartBelow and not PlayerState.dirty then
            PlayerState.dirty = true
            TriggerServerEvent(tag..'setmedirty') 
        elseif PlayerState.dirty and PlayerState.cleanValue > Settings.dirtyEffectStartBelow then
            PlayerState.dirty = false
            TriggerServerEvent(tag..'setmeclean') 
        end
        Wait(1000)
    end
end


function PlayerState:malangwan(pedCoords)
    loadPtfxAsset("core")
    SetPtfxAssetNextCall("core")
    self.malangwanParticles = StartParticleFxLoopedAtCoord(
        "ent_amb_fly_swarm",
        ped.x, 
        ped.y, 
        ped.z, 
        0.0, 
        0.0, 
        0.0, 
        5.3, 
        0, 
        0, 
        0, 
        false
    )
end

local dirtiedPlayers = {}

function dirtyOthersThread()
    loadPtfxAsset("core")
    while true do
        for strId, id in pairs(PlayerState.dirtyPlayersPed) do
            if not dirtiedPlayers[strId] then
                local targetPed = GetPlayerPed(GetPlayerFromServerId(id))
                local targetCoords = GetEntityCoords(targetPed)
                local myCoords = GetEntityCoords(PlayerPedId())
                if #(myCoords - targetCoords) < 5.0 then
                    SetPtfxAssetNextCall("core")
                    dirtiedPlayers[strId] = StartParticleFxLoopedOnEntity('ent_amb_fly_swarm', targetPed, 0, 0, 0.2, 0, 0, 0, 0.8, false, false, false)
                    CreateThread(function()
                        Wait(3000)
                        StopParticleFxLooped(dirtiedPlayers[strId])
                        dirtiedPlayers[strId] = nil
                    end)
                    Wait(1)
                end
            end
        end
        Wait(1000)
    end
end

regEvent('removedirtyplayer', function(strId)
    StopParticleFxLooped(dirtiedPlayers[strId], false)
    dirtiedPlayers[strId] = nil
end)

AddStateBagChangeHandler('dirtyPlayersPed', 'global', function(bagName, key, dirtyPlayersPed) 
    PlayerState.dirtyPlayersPed = dirtyPlayersPed
end)




CreateThread(dirtyThread)
CreateThread(initialThread)
CreateThread(pullClosestZone)
CreateThread(function()
    while not ESX do
        TriggerEvent(Framework.getLibs, function(lib)
            ESX = lib
        end) 
        Wait(0)
    end
    while not ESX.IsPlayerLoaded() do
        Wait(0) 
    end

    Wait(1000)

    PlayerState.dirtyPlayersPed = GlobalState.dirtyPlayersPed
    CreateThread(dirtyOthersThread)
    print('Initial Framework :D')
end)

