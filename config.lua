Config = {} -- Support will always be provided by SMDX if needed.

Config.Lang = "eng" -- "eng" for English, "swe" for swedish. Add your own lang at the bottom.

Config.WebhookURL = "YOUR_WEBHOOK_URL_HERE" -- Add your own Discord Webhook here for discord logs.

Config.PackItems = { -- Find all items in qb-core/shared/items.lua
    {item = "phone", amount = 1},
    {item = "water", amount = 5}
}

Config.StarterVehicles = { -- You can find all vehicles in qb-core/shared/vehicles.lua
    {model = "panto", label = "Panto"},
    {model = "faggio", label = "Faggio"},
    {model = "blista", label = "Blista"}
}

Config.PedModel = "a_m_m_business_01" -- Find more peds here, https://forge.plebmasters.de/peds
Config.PedCoords = vector4(-322.36, -775.11, 32.96, 46.05) 
Config.Scenario = "WORLD_HUMAN_STAND_IMPATIENT" -- Find more scenarios here, https://github.com/DioneB/gtav-scenarios 

Config.VehicleSpawnCoords = vector4(-327.35, -770.41, 33.29, 34.84) 

Config.Keys = "qb" -- "qb" for qb-vehiclekeys, "sk" for sk-keys (i use sk-keys that's why)

Config.BlipSettings = {
    enabled = true, -- If you don't want a blip, Turn this to false.
    coords = Config.PedCoords,
    label = Config.BlipName,
    sprite = 745, -- https://docs.fivem.net/docs/game-references/blips/
    color = 40,
    display = 4,
    scale = 0.8,
    shortRange = true,
}

if Config.Lang == "swe" then
    Config.BlipName = "Startpaket"
    Config.Targetlabel = "Få startpack"
    Config.invalidvehicle = "Ogiltigt fordon"
    Config.Couldnotspawn = "Kunde inte skapa fordonet"
    Config.FreePack = "Hämtar gratis pack..."
    Config.Canceled = "Avbruten!"
    Config.Claimed = "Du har hämtat ditt gratispaket!"
    Config.AlreadyClaimed = "Du har redan hämtat ditt gratis pack!"
    Config.PickedUp = "har hämtat sitt starter pack."
    Config.TriedAgain = "försökte hämta ett paket igen, men har redan gjort det."

elseif Config.Lang == "eng" then
    Config.BlipName = "Starter pack"
    Config.Targetlabel = "Get starter pack"
    Config.invalidvehicle = "Invalid vehicle"
    Config.Couldnotspawn = "Could not spawn the vehicle"
    Config.FreePack = "Getting free pack..."
    Config.Canceled = "Canceled!"
    Config.Claimed = "You have claimed your free pack!"
    Config.AlreadyClaimed = "You have already claimed your free pack!"
    Config.PickedUp = "has picked up their starter pack."
    Config.TriedAgain = "tried to claim a pack again, but has already done it."
end