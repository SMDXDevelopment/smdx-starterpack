local QBCore = exports['qb-core']:GetCoreObject()
local spawnedPed = nil

local function Notify(msg, type, time)
    if Config.NotificationSystem == "ox" then
        lib.notify({
            title = 'Notification',
            description = msg,
            type = type,
            duration = time or 5000 -- Standard tid om ingen tid anges
        })
    elseif Config.NotificationSystem == "qb" then
        QBCore.Functions.Notify(msg, type, time or 5000)
    end
end


local function spawnPed()
    local pedModel = GetHashKey(Config.PedModel)

    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do
        Wait(0)
    end

    spawnedPed = CreatePed(4, pedModel, Config.PedCoords.x, Config.PedCoords.y, Config.PedCoords.z, Config.PedCoords.w, false, true)
    SetEntityInvincible(spawnedPed, true)
    SetBlockingOfNonTemporaryEvents(spawnedPed, true)
    TaskStartScenarioInPlace(spawnedPed, Config.Scenario, 0, true)

    if Config.TargetSystem == "qb" then
        exports['qb-target']:AddTargetEntity(spawnedPed, {
            options = {
                {
                    type = "client",
                    event = "smdx-pack:getPack",
                    icon = "fas fa-box",
                    label = Config.Targetlabel,
                }
            },
            distance = 2.5
        })
    elseif Config.TargetSystem == "ox" then
        exports.ox_target:addLocalEntity(spawnedPed, {
            {
                name = 'smdx-pack:getPack',
                event = 'smdx-pack:getPack',
                icon = 'fas fa-box',
                label = Config.Targetlabel,
                distance = 2.5,
            }
        })
    end
end


local function playPedAnimation(ped)
    RequestAnimDict("mp_common")
    while not HasAnimDictLoaded("mp_common") do
        Wait(0)
    end
    TaskPlayAnim(ped, "mp_common", "givetake1_a", 8.0, -8, -1, 49, 0, false, false, false)
end

local function showVehicleMenu()
    local menuOptions = {}
    for _, vehicle in pairs(Config.StarterVehicles) do
        table.insert(menuOptions, {
            header = vehicle.label,
            txt = Config.ChooseVehicle,
            params = {
                event = "smdx-pack:selectVehicle",
                args = {
                    vehicleModel = vehicle.model
                }
            }
        })
    end
    if Config.Menu == "qb" then
        local qbMenuOptions = {}
        for _, option in ipairs(menuOptions) do
            table.insert(qbMenuOptions, {
                header = option.header,
                txt = option.txt,
                params = option.params
            })
        end
        exports['qb-menu']:openMenu(qbMenuOptions)
    elseif Config.Menu == "ox" then
        local oxMenuOptions = {}
        for _, option in ipairs(menuOptions) do
            table.insert(oxMenuOptions, {
                title = option.header, 
                description = option.txt, 
                event = option.params.event,
                args = option.params.args
            })
        end
        lib.registerContext({
            id = 'vehicle_menu',
            title = Config.ChooseVehicle,
            menu = 'previous_menu', 
            onBack = function()
                print('Backed!')
            end,
            options = oxMenuOptions
        })

        lib.showContext('vehicle_menu')
    end
end



RegisterNetEvent('smdx-pack:selectVehicle')
AddEventHandler('smdx-pack:selectVehicle', function(data)
    local vehicleModel = data.vehicleModel
    local plate = QBCore.Functions.GetPlate()

    TriggerServerEvent('smdx-starterpack:GetPack', vehicleModel, plate)
end)

RegisterNetEvent('smdx-pack:spawnVehicle')
AddEventHandler('smdx-pack:spawnVehicle', function(vehicleModel, plate)
    local spawnCoords = Config.VehicleSpawnCoords
    local vehicleHash = GetHashKey(vehicleModel)

    if not IsModelInCdimage(vehicleHash) or not IsModelAVehicle(vehicleHash) then
        Notify(Config.invalidvehicle, 'error', 5000)
        return
    end

    RequestModel(vehicleHash)
    while not HasModelLoaded(vehicleHash) do
        Wait(0)
    end

    local vehicle = CreateVehicle(vehicleHash, spawnCoords.x, spawnCoords.y, spawnCoords.z, spawnCoords.w, true, false)

    SetVehicleNumberPlateText(vehicle, plate)

    if DoesEntityExist(vehicle) then
        if Config.Keys == "sk" then
            exports['sk-keys']:buyvehicle(plate, vehicleModel)
        elseif Config.Keys == "qb" then
            TriggerEvent("vehiclekeys:client:SetOwner", plate)
        end

        TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
    else
        Notify(Config.Couldnotspawn, 'error', 5000)
    end

    SetModelAsNoLongerNeeded(vehicleHash)
end)

RegisterNetEvent('smdx-pack:getPack')
AddEventHandler('smdx-pack:getPack', function()
    local playerPed = PlayerPedId()
    playPedAnimation(spawnedPed)
    if Config.Progressbar == "qb" then
        QBCore.Functions.Progressbar("give_pack", Config.FreePack, 5000, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {}, {}, {}, function() 
            ClearPedTasks(spawnedPed)
            showVehicleMenu()
        end, function() 
            ClearPedTasks(spawnedPed)
            Notify(Config.Canceled, 'error', 5000)
        end)
        elseif Config.Progressbar == "ox" then
        if lib.progressBar({
            duration = 5000,
            label = Config.FreePack,
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = true,
                combat = true,
                move = true,
            },
            anim = {
                dict = 'mp_common',
                clip = 'givetake1_a'
                
            },
        }) then 
            ClearPedTasks(spawnedPed)
            showVehicleMenu()
        else 
            ClearPedTasks(spawnedPed)
            Notify(Config.Canceled, 'error', 5000)
        end
    end
end)


CreateThread(function()
    spawnPed()
end)

local function AddBlip()
    if not Config.BlipSettings.enabled then return end
    local settings = Config.BlipSettings
    local blip = AddBlipForCoord(Config.PedCoords)
    SetBlipSprite(blip, settings.sprite)
    SetBlipDisplay(blip, settings.display)
    SetBlipScale(blip, settings.scale)
    SetBlipColour(blip, settings.color)
    SetBlipAsShortRange(blip, settings.shortRange)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(settings.label)
    EndTextCommandSetBlipName(blip)
end

Citizen.CreateThread(AddBlip)