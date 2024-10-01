local QBCore = exports['qb-core']:GetCoreObject()
local spawnedPed = nil

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

    exports['qb-target']:AddTargetEntity(spawnedPed, {
        options = {
            {
                type = "client",
                event = "smdx-pack:getPack",
                icon = "fas fa-box",
                label = Config.Targetlabel,
            },
        },
        distance = 2.5
    })
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
            txt = "Välj detta fordon",
            params = {
                event = "smdx-pack:selectVehicle",
                args = {
                    vehicleModel = vehicle.model
                }
            }
        })
    end

    exports['qb-menu']:openMenu(menuOptions)
end

RegisterNetEvent('smdx-pack:selectVehicle')
AddEventHandler('smdx-pack:selectVehicle', function(data)
    local vehicleModel = data.vehicleModel
    local plate = QBCore.Functions.GetPlate()

    TriggerServerEvent('smdx-pack:getPackFromServer', vehicleModel, plate)
end)

RegisterNetEvent('smdx-pack:spawnVehicle')
AddEventHandler('smdx-pack:spawnVehicle', function(vehicleModel, plate)
    local spawnCoords = Config.VehicleSpawnCoords
    local vehicleHash = GetHashKey(vehicleModel)

    if not IsModelInCdimage(vehicleHash) or not IsModelAVehicle(vehicleHash) then
        TriggerEvent('QBCore:Notify', Config.invalidvehicle, 'error')
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
        TriggerEvent('QBCore:Notify', Config.Couldnotspawn, 'error')
    end

    SetModelAsNoLongerNeeded(vehicleHash)
end)

RegisterNetEvent('smdx-pack:getPack')
AddEventHandler('smdx-pack:getPack', function()
    local playerPed = PlayerPedId()

    playPedAnimation(spawnedPed)

    QBCore.Functions.Progressbar("give_pack", Config.FreePack, 5000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() 
        showVehicleMenu()
    end, function() 
        TriggerEvent('QBCore:Notify', Config.Canceled, 'error')
    end)
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