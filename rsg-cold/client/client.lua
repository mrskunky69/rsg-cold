RSGCore = exports['rsg-core']:GetCoreObject()
local hascold = false
local roundtemp = 0
local ped = PlayerPedId()

local ClothesCats = {
    0x9925C067, --hat
    0x2026C46D, --shirt
    0x1D4C528A, -- pants
    0x777EC6EF, -- boots 
    0xE06D30CE, -- coat
    0x662AC34, --open coat
    0xEABE0032, --gloves 
    0x485EE834, --vest
    0xAF14310B, -- poncho
}

RegisterNetEvent('rsg-cold:cure')
AddEventHandler('rsg-cold:cure', function()
    local ped = PlayerPedId()
    local src = source
    if hascold then
        RSGCore.Functions.Progressbar("take_cold_medicine", "Using Cold Medicine..", 4000, false, true, {
            disableMovement = false,
            disableCarMovement = false,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = "mech_inventory@drinking@champagne",
            anim = "action",
            flags = 1,
        }, {}, {}, function() 
            hascold = false
            TriggerServerEvent('rsg-cold:removemedicine', source)
            StopAnimTask(ped, "mech_inventory@drinking@champagne", "action", 1.0)
            RSGCore.Functions.Notify('You took the medicine!', 'success')
            local chanceToDie = math.random(0, 100)          
        end, function() 
            StopAnimTask(ped, "mech_inventory@drinking@champagne", "action", 1.0)
            RSGCore.Functions.Notify('You canceled the medicine!', 'success')
        end)
    else
        RSGCore.Functions.Notify('You don\'t have a cold!', 'error')
    end
end)

local function SpreadCold()
    if Config.ColdSpread and hascold then
        local closestPlayer, closestDistance = RSGCore.Functions.GetClosestPlayer()
        if closestPlayer ~= -1 and closestDistance < 4.0 then
            TriggerServerEvent('rsg-cold:spreadPlayer', GetPlayerServerId(closestPlayer))
        end
    end
end

local function ApplyColdEffects()
    RSGCore.Functions.GetPlayerData(function(PlayerData)
        PlayerJob = PlayerData.job
        onDuty = PlayerData.job.onduty

        if PlayerJob.name == "police" or PlayerJob.name == "medic" then
            return
        else
            hascold = true 
        end
    end)
end

RegisterNetEvent('rsg-cold:spread')
AddEventHandler('rsg-cold:spread', function(source)
    ApplyColdEffects(source)
    if Config.Debug then
		print('You received the cold')
    end
end)
    

Citizen.CreateThread(function()
	while true do
        Wait(100)                 
		if hascold then
            Citizen.Wait(math.random(Config.SicktickMin, Config.SicktickMax))
            local ped = PlayerPedId()
            local sicklook = math.random(0,100)
            loadAnimDict('amb_misc@world_human_vomit@male_a@idle_b')
            TaskPlayAnim(PlayerPedId(), "amb_misc@world_human_vomit@male_a@idle_b", "idle_f", 8.0, -8.0, -1, 31, 0, true, 0, false, 0, false)
            SpreadCold()    
			Citizen.Wait(8000)
            RemoveAnimDict('amb_misc@world_human_vomit@male_a@idle_b')               
			Citizen.Wait(1000)
			SetEntityHealth(ped, GetEntityHealth(ped) - Config.Healthtake)
			ClearPedSecondaryTask(ped)
			local chanceToRagdoll = math.random(0, 100)
			RSGCore.Functions.Notify('You have a dangerous cold!', 'error')
            if Config.Debug then
			    print('You have a cold')
            end
			if chanceToRagdoll > (100 - Config.chanceToRagdoll) then
				SetPedToRagdoll(ped, 6000, 6000, 0, 0, 0, 0)
			end
		end
	end
end)

Citizen.CreateThread(function()
    while true do
        Wait(10000)   
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local temp = Citizen.InvokeNative(0xB98B78C3768AF6E0,coords.x,coords.y,coords.z) 
        local coldchance = math.random(0, 100)
        
        for k,v in pairs(ClothesCats) do
            local IsWearingClothes = Citizen.InvokeNative(0xFB4891BD7578CDC1 ,PlayerPedId(), v)
            if IsWearingClothes then 
                temp = temp + 1
                roundtemp = temp
                if roundtemp < 0 then
                    if coldchance > Config.Sickchance then
		                 hascold = true
                    end
                end
            end
        end
    end
end)

function loadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(100)
    end
end
