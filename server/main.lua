local QBCore = exports['qb-core']:GetCoreObject()

local webhookURL = Config.WebhookURL 

local function sendToDiscordLog(title, message, color)
    local connect = {
        {
            ["color"] = color,
            ["title"] = title,
            ["description"] = message,
            ["footer"] = {
                ["text"] = os.date("%Y-%m-%d %H:%M:%S")
            },
        }
    }
    
    PerformHttpRequest(webhookURL, function(err, text, headers) end, 'POST', json.encode({username = "StarterPack Log", embeds = connect}), { ['Content-Type'] = 'application/json' })
end

local function hasReceivedStarterPack(citizenid, cb)
    exports.oxmysql:scalar('SELECT citizenid FROM skap_starterpack WHERE citizenid = ?', { citizenid }, function(result)
        cb(result ~= nil)
    end)
end

local function registerStarterPack(citizenid)
    exports.oxmysql:insert('INSERT INTO skap_starterpack (citizenid) VALUES (?)', { citizenid })
end

local function GeneratePlate()
    local plate = QBCore.Shared.RandomInt(1) .. QBCore.Shared.RandomStr(2) .. QBCore.Shared.RandomInt(3) .. QBCore.Shared.RandomStr(2)
    local result = exports.oxmysql:scalarSync('SELECT plate FROM player_vehicles WHERE plate = ?', { plate })
    if result then
        return GeneratePlate() 
    else
        return plate:upper()
    end
end

local function registerVehicleInDatabase(Player, model)
    local citizenid = Player.PlayerData.citizenid
    local license = Player.PlayerData.license
    local vehicleHash = GetHashKey(model)
    local plate = GeneratePlate() 

    exports.oxmysql:insert('INSERT INTO player_vehicles (citizenid, license, vehicle, hash, plate, garage, fuel, engine, body, state, depotprice, balance, paymentamount, paymentsleft, financetime) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', {
        citizenid,
        license,
        model, 
        tostring(vehicleHash),
        plate,
        "impound", 
        100, 
        1000, 
        1000, 
        0, 
        0, 
        0, 
        0, 
        0,
        0 
    }, function(id)
        if id then
            print('Fordonet har lagts till i databasen med ID: ' .. id)
            sendToDiscordLog("Starter Pack", "Spelaren med citizenid: " .. citizenid .. " fick fordonet med regnummer: " .. plate, 3066993) 
        else
            print('Ett fel uppstod när fordonet skulle läggas till i databasen.')
            sendToDiscordLog("Fel", "Kunde inte registrera fordon för spelare med citizenid: " .. citizenid, 15158332) 
        end
    end)

    return plate
end

RegisterNetEvent('smdx-pack:getPackFromServer')
AddEventHandler('smdx-pack:getPackFromServer', function(vehicleModel, plate)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local citizenid = Player.PlayerData.citizenid
    local playerName = Player.PlayerData.name

    hasReceivedStarterPack(citizenid, function(hasReceived)
        if hasReceived then
            TriggerClientEvent('QBCore:Notify', src, Config.AlreadyClaimed, 'error')
            sendToDiscordLog("Starter Pack", playerName .. " (citizenid: " .. citizenid .. ") försökte hämta ett paket igen, men har redan gjort det.", 15158332)
        else
            for _, item in pairs(Config.PackItems) do
                Player.Functions.AddItem(item.item, item.amount)
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item.item], "add")
            end
            local plate = registerVehicleInDatabase(Player, vehicleModel)
            TriggerClientEvent('smdx-pack:spawnVehicle', src, vehicleModel, plate)
            registerStarterPack(citizenid)
            sendToDiscordLog("Starter Pack", playerName .. " (citizenid: " .. citizenid .. ") har hämtat sitt startpaket.", 3066993)
        end
    end)
end)
