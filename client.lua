-- ████████╗██╗███████╗██╗ ██████╗ ██╗   ██╗███████╗███████╗
-- ╚══██╔══╝██║██╔════╝██║██╔═══██╗██║   ██║██╔════╝██╔════╝
--    ██║   ██║█████╗  ██║██║   ██║██║   ██║███████╗█████╗  
--    ██║   ██║██╔══╝  ██║██║   ██║██║   ██║╚════██║██╔══╝  
--    ██║   ██║██║     ██║╚██████╔╝╚██████╔╝███████║███████╗
--    ╚═╝   ╚═╝╚═╝     ╚═╝ ╚═════╝  ╚═════╝ ╚══════╝╚══════╝

ESX = exports["es_extended"]:getSharedObject()

local Base = Config.Gardener.Base
local Garage = Config.Gardener.Garage
local Marker = Config.Gardener.DefaultMarker
local GarageSpawnPoint = Config.Gardener.GarageSpawnPoint
local Type = nil
local AmountPayout = 0
local done = 0
local PlayerData = {}
local salary = nil

onDuty = false
hasCar = false
inGarageMenu = false
inMenu = false
wasTalked = false
appointed = false
waitingDone = false
CanWork = false
Paycheck = false

hasOpenDoor = false
hasBlower = false
hasTrimmer = false
hasLawnMower = false
hasBackPack = false

RegisterCommand('1', function()
	ESX.ShowAdvancedNotification('~p~Appel d\'urgence - 2061', '~p~Central', "~p~Localisation:~s~\n<b><span style='font-weight: 500;'>Groove Street (15m)</span></b>\n~p~Infos:~s~\n<b><span style='font-weight: 500'>Tire à feux</span></b>", '#b19bd9', 'call', 7)
end)


RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
end)

function Randomize(tb)
	local keys = {}
	for k in pairs(tb) do table.insert(keys, k) end
	return tb[keys[math.random(#keys)]]
end

-- BASE
Citizen.CreateThread(function()
    while true do
        local sleep = 500
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        if PlayerData.job ~= nil and PlayerData.job.grade_name == 'gardener' then
            if (GetDistanceBetweenCoords(coords, Base.Pos.x, Base.Pos.y, Base.Pos.z, true) < 8) then
                sleep = 5
                DrawMarker(Base.Type, Base.Pos.x, Base.Pos.y, Base.Pos.z - 0.95, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Base.Size.x, Base.Size.y, Base.Size.z, Base.Color.r, Base.Color.g, Base.Color.b, 100, false, true, 2, false, false, false, false)
                
                if (GetDistanceBetweenCoords(coords, Base.Pos.x, Base.Pos.y, Base.Pos.z, true) < 1.2) then
                    if not onDuty then
                        sleep = 5
                        DrawText3Ds(Base.Pos.x, Base.Pos.y, Base.Pos.z + 0.4, '~y~[E]~s~ - Changer de vêtements de travail')
                        if IsControlJustPressed(0, Keys["E"]) then
                            exports.TFS_progress:Custom({
                                Duration = 2500,
                                Label = "Vous changez de vêtements...",
                                Animation = {
                                    scenario = "WORLD_HUMAN_CLIPBOARD",  -- Scénario pour simuler le changement de vêtements
                                    animationDictionary = nil,             -- Pas besoin d'un dictionnaire d'animation ici
                                },
                                DisableControls = {
                                    Mouse = false,
                                    Player = true,
                                    Vehicle = true
                                }
                            })
                            Citizen.Wait(2500)
                            ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
                                if skin.sex == 0 then
                                    TriggerEvent('skinchanger:loadClothes', skin, Config.Clothes.male)
                                elseif skin.sex == 1 then
                                    TriggerEvent('skinchanger:loadClothes', skin, Config.Clothes.female)
                                end
                            end)
                            ESX.ShowNotification("~b~Jardinier~s~</br>Vous avez commencé à travailler !", "#5fa05d")
                            onDuty = true
                            addGarageBlip()
                            ESX.ShowNotification("~b~Jardinier~s~</br>Pour ouvrir le menu de travail, appuyez sur <b>[DEL]</b>", "#b19bd9")
                        end
                    elseif onDuty then
                        sleep = 5
                        DrawText3Ds(Base.Pos.x, Base.Pos.y, Base.Pos.z + 0.4, '~r~[E]~s~ - Changer en vêtements de citoyen')
                        if IsControlJustPressed(0, Keys["E"]) then
                            exports.TFS_progress:Custom({
                                Duration = 2500,
                                Label = "Vous changez de vêtements...",
                                Animation = {
                                    scenario = "WORLD_HUMAN_COP_IDLES",
                                    animationDictionary = "idle_a",
                                },
                                DisableControls = {
                                    Mouse = false,
                                    Player = true,
                                    Vehicle = true
                                }
                            })
                            Citizen.Wait(2500)
                            ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
                                TriggerEvent('skinchanger:loadSkin', skin)
                            end)
                            ESX.ShowNotification("~b~Jardinier~s~</br>Vous avez terminé votre service !", "#FF0000")
                            onDuty = false
                            removeGarageBlip()
                        end
                    end
                end
            end
        end
        Citizen.Wait(sleep)
    end
end)


Citizen.CreateThread(function()
    while true do

        local sleep = 500
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

            if PlayerData.job ~= nil and PlayerData.job.grade_name == 'gardener' then
                if onDuty then
                    if not inMenu then
                        sleep = 2
                        if IsControlJustPressed(0, Keys["DEL"]) then
                            inMenu = true
                        end
                    elseif inMenu then
                        sleep = 2
                        DrawText3Dss(coords.x, coords.y, coords.z + 1.0, '~y~[Y]~s~ - Chercher une course | ~r~[X]~s~ - Annuler la course')
                        if IsControlJustPressed(0, Keys["DEL"]) then
                            inMenu = false
                        elseif IsControlJustPressed(0, Keys["Y"]) then 
                            if Type == nil then
                                inMenu = false
                                ESX.ShowNotification("~b~Jardinier~s~</br>Recherche d'une course...", "#5fa05d")
                                Citizen.Wait(15000)
                                Gardens = Randomize(Config.Gardens)
                                CreateWork(Gardens.StreetHouse)
                                ESX.ShowNotification("~b~Jardinier~s~</br>Localisation GPS définie ! Conduisez vers " ..Gardens.StreetHouse, "#5fa05d")
                                salary = math.random(300, 900)
                                if Type == "Rockford Hills" then
                                    for i, v in ipairs(Config.RockfordHills) do
                                        SetNewWaypoint(v.x, v.y, v.z)
                                    end
                                elseif Type == "West Vinewood" then
                                    for i, v in ipairs(Config.WestVinewood) do
                                        SetNewWaypoint(v.x, v.y, v.z)
                                    end
                                elseif Type == "Vinewood Hills" then
                                    for i, v in ipairs(Config.VinewoodHills) do
                                        SetNewWaypoint(v.x, v.y, v.z)
                                    end
                                elseif Type == "El Burro Heights" then
                                    for i, v in ipairs(Config.ElBurroHeights) do
                                        SetNewWaypoint(v.x, v.y, v.z)
                                    end
                                elseif Type == "Richman" then
                                    for i, v in ipairs(Config.Richman) do
                                        SetNewWaypoint(v.x, v.y, v.z)
                                    end
                                elseif Type == "Mirror Park" then
                                    for i, v in ipairs(Config.MirrorPark) do
                                        SetNewWaypoint(v.x, v.y, v.z)
                                    end
                                elseif Type == "East Vinewood" then
                                    for i, v in ipairs(Config.EastVinewood) do
                                        SetNewWaypoint(v.x, v.y, v.z)
                                    end
                                end
                            else
                                ESX.ShowNotification("~b~Jardinier~s~</br>Vous avez déjà une course en cours !", "#FF0000")
                            end
                        elseif IsControlJustPressed(0, Keys["X"]) then
                            if Type then
                                CancelWork()
                                DeleteWaypoint()
                                ESX.ShowNotification("~b~Jardinier~s~</br>Vous avez annulé un rendez-vous avec un client", "#FF0000")
                            elseif not Type then
                                ESX.ShowNotification("~b~Jardinier~s~</br>Vous n'avez actuellement aucun rendez-vous", "#FF0000")
                            end
                        end
                    end
                end
            end
        Citizen.Wait(sleep)
    end
end)

-- GARAGE MENU
Citizen.CreateThread(function()
    -- Création du PNJ à la position du garage
    local npcModel = `s_m_m_gardener_01`
    RequestModel(npcModel)
    while not HasModelLoaded(npcModel) do
        Wait(1)
    end
    
    local npc = CreatePed(4, npcModel, Garage.Pos.x, Garage.Pos.y, Garage.Pos.z - 1, false, true)
    
    -- Rendre le PNJ statique
    SetEntityInvincible(npc, true)
    FreezeEntityPosition(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    SetEntityVisible(npc, true)
    SetEntityHeading(npc, 270.0) 

    while true do
        local sleep = 500
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local vehicle = GetVehiclePedIsIn(ped, false)

        if PlayerData.job ~= nil and PlayerData.job.grade_name == 'gardener' then
            if onDuty then
                local distanceToNPC = GetDistanceBetweenCoords(coords, Garage.Pos.x, Garage.Pos.y, Garage.Pos.z, true)
                
                if distanceToNPC < 10 then -- Rayon de 10
                    sleep = 5
                    DrawMarker(Marker.Type, Garage.Pos.x, Garage.Pos.y, Garage.Pos.z - 0.95, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Garage.Size.x, Garage.Size.y, Garage.Size.z, Garage.Color.r, Garage.Color.g, Garage.Color.b, 100, false, true, 2, false, false, false, false)
                    
                    if distanceToNPC < 3.0 then -- Rayon d'interaction
                        if IsPedInAnyVehicle(ped, false) then
                            sleep = 5
                            DrawText3Ds(Garage.Pos.x, Garage.Pos.y, Garage.Pos.z + 0.4, '~r~[E]~s~ - Rendre le véhicule')
                            if IsControlJustReleased(0, Keys["E"]) then
                                if hasCar then
                                    TriggerServerEvent('TFS_gardener:returnVehicle', source)
                                    ReturnVehicle()
                                    ESX.ShowNotification("~b~Jardinier~s~</br>Vous avez reçu " ..Config.DepositPrice.. "$ pour avoir rendu le véhicule", "#5fa05d")
                                    hasCar = false
                                    Plate = nil
                                else
                                    ESX.ShowNotification("~b~Jardinier~s~</br>Vous n'avez pas payé la caution pour ce véhicule !", "#FF0000")
                                end
                            end
                        elseif not IsPedInAnyVehicle(ped, false) then
                            sleep = 5
                            if not inGarageMenu then
                                DrawText3Ds(Garage.Pos.x, Garage.Pos.y, Garage.Pos.z + 0.4, '~y~[E]~s~ - Ouvrir le menu du garage')
                                if IsControlJustReleased(0, Keys["E"]) then
                                    if not inMenu then
                                        FreezeEntityPosition(ped, true)
                                        inGarageMenu = true
                                        ESX.ShowNotification("~b~Jardinier~s~</br>Sélectionnez une place de parking", "#5fa05d")
                                    elseif inMenu then
                                        ESX.ShowNotification("~b~Jardinier~s~</br>Fermez le menu de travail !", "#FF0000")
                                    end
                                end
                            elseif inGarageMenu then
                                DrawText3DMenu(Garage.Pos.x - 0.8, Garage.Pos.y, Garage.Pos.z + 0.8, '~y~[W]~s~ - Place de parking #1\n~y~[X]~s~ - Place de parking #2\n~r~[E]~s~ - Fermer le menu du garage')
                                if IsControlJustReleased(0, Keys["E"]) then
                                    inGarageMenu = false
                                    FreezeEntityPosition(ped, false)
                                elseif IsControlJustReleased(0, Keys["W"]) then
                                    if not hasCar then
                                        ESX.TriggerServerCallback('TFS_gardener:checkMoney', function(hasMoney)
                                        if hasMoney then
                                            ESX.Game.SpawnVehicle(Config.CompanyVehicle, vector3(GarageSpawnPoint.Pos1.x, GarageSpawnPoint.Pos1.y, GarageSpawnPoint.Pos1.z), GarageSpawnPoint.Pos1.h, function(vehicle)
                                            SetVehicleNumberPlateText(vehicle, "GRD"..tostring(math.random(1000, 9999)))
                                            SetVehicleEngineOn(vehicle, true, true)
                                            ESX.ShowNotification("~b~Jardinier~s~</br>Vous avez payé " ..Config.DepositPrice.. "$ pour sortir le véhicule", "#5fa05d")
                                            hasCar = true
                                            Plate = GetVehicleNumberPlateText(vehicle)
                                            end)
                                            inGarageMenu = false
                                            FreezeEntityPosition(ped, false)
                                        else
                                            ESX.ShowNotification("~b~Jardinier~s~</br>Vous n'avez pas assez d'argent !", "#FF0000")
                                            inGarageMenu = false
                                            FreezeEntityPosition(ped, false)
                                        end
                                        end)
                                    elseif hasCar then
                                        ESX.ShowNotification("~b~Jardinier~s~</br>Posez d'abord le véhicule que vous avez sorti", "#FF0000")
                                    end
                                elseif IsControlJustReleased(0, Keys["X"]) then
                                    if not hasCar then
                                        ESX.TriggerServerCallback('TFS_gardener:checkMoney', function(hasMoney)
                                        if hasMoney then
                                            ESX.Game.SpawnVehicle(Config.CompanyVehicle, vector3(GarageSpawnPoint.Pos2.x, GarageSpawnPoint.Pos2.y, GarageSpawnPoint.Pos2.z), GarageSpawnPoint.Pos2.h, function(vehicle)
                                            SetVehicleNumberPlateText(vehicle, "GRD"..tostring(math.random(1000, 9999)))
                                            SetVehicleEngineOn(vehicle, true, true)
                                            ESX.ShowNotification("~b~Jardinier~s~</br>Vous avez payé " ..Config.DepositPrice.. "$ pour sortir le véhicule", "#5fa05d")
                                            hasCar = true
                                            Plate = GetVehicleNumberPlateText(vehicle)
                                            end)
                                            inGarageMenu = false
                                            FreezeEntityPosition(ped, false)
                                        else
                                            ESX.ShowNotification("~b~Jardinier~s~</br>Vous n'avez pas assez d'argent !", "#FF0000")
                                            inGarageMenu = false
                                            FreezeEntityPosition(ped, false)
                                        end
                                        end)
                                    elseif hasCar then
                                        ESX.ShowNotification("~b~Jardinier~s~</br>Posez d'abord le véhicule que vous avez sorti", "#FF0000")
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        Citizen.Wait(sleep)
    end
end)





-- OPENING VAN DOORS
Citizen.CreateThread(function()
    while true do

        local sleep = 500
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), true)

        if hasCar then
            if not IsPedInAnyVehicle(ped, false) then
                if Plate == GetVehicleNumberPlateText(vehicle) then
                    local trunkpos = GetOffsetFromEntityInWorldCoords(vehicle, 0, -2.0, 0)
                    if (GetDistanceBetweenCoords(coords.x, coords.y, coords.z, trunkpos.x, trunkpos.y, trunkpos.z, true) < 2) then
                        if not hasOpenDoor then
                            sleep = 5
                            DrawText3Ds(trunkpos.x, trunkpos.y, trunkpos.z + 0.4, "~y~[G]~s~ - Ouvrir les portes")
                            if IsControlJustReleased(0, Keys["G"]) then
                                exports.TFS_progress:Custom({
                                    Duration = 1500,
                                    Label = "Vous ouvrez les portes arrière",
                                    DisableControls = {
                                        Mouse = false,
                                        Player = true,
                                        Vehicle = true
                                    }
                                })
                                Citizen.Wait(1500)
                                SetVehicleDoorOpen(vehicle, 3, false, false)
                                SetVehicleDoorOpen(vehicle, 2, false, false)
                                hasOpenDoor = true
                            end
                        elseif hasOpenDoor then
                            if not hasBlower and not hasLawnMower and not hasTrimmer and not hasBackPack then
                                sleep = 5
                                DrawText3Ds(trunkpos.x, trunkpos.y, trunkpos.z + 0.7, "~y~[E]~s~ - Souffleur de feuilles | ~y~[H]~s~ Sac à dos")
                                DrawText3Ds(trunkpos.x, trunkpos.y, trunkpos.z + 0.5, "~y~[W]~s~ - Taille-haies | ~y~[X]~s~ Tondeuse à gazon")
                                DrawText3Ds(trunkpos.x, trunkpos.y, trunkpos.z + 0.3, "~r~[G]~s~ - Fermer les portes")
                                if IsControlJustReleased(0, Keys["G"]) then
                                    exports.TFS_progress:Custom({
                                        Duration = 1500,
                                        Label = "Vous fermez les portes arrière",
                                        DisableControls = {
                                            Mouse = false,
                                            Player = true,
                                            Vehicle = true
                                        }
                                    })
                                    Citizen.Wait(1500)
                                    SetVehicleDoorShut(vehicle, 3, false)
                                    SetVehicleDoorShut(vehicle, 2, false)
                                    hasOpenDoor = false
                                elseif IsControlJustReleased(0, Keys["E"]) then
                                    exports.TFS_progress:Custom({
                                        Duration = 1500,
                                        Label = "Vous sortez le souffleur de feuilles...",
                                        DisableControls = {
                                            Mouse = false,
                                            Player = true,
                                            Vehicle = true
                                        }
                                    })
                                    Citizen.Wait(1500)
                                    addLeafBlower()
                                    hasBlower = true
                                elseif IsControlJustReleased(0, Keys["H"]) then
                                    exports.TFS_progress:Custom({
                                        Duration = 1500,
                                        Label = "Vous sortez le sac à dos...",
                                        DisableControls = {
                                            Mouse = false,
                                            Player = true,
                                            Vehicle = true
                                        }
                                    })
                                    Citizen.Wait(1500)
                                    addBackPack()
                                    hasBackPack = true
                                elseif IsControlJustReleased(0, Keys["W"]) then
                                    exports.TFS_progress:Custom({
                                        Duration = 1500,
                                        Label = "Vous sortez le taille-haies...",
                                        DisableControls = {
                                            Mouse = false,
                                            Player = true,
                                            Vehicle = true
                                        }
                                    })
                                    Citizen.Wait(1500)
                                    addTrimmer()
                                    hasTrimmer = true
                                elseif IsControlJustReleased(0, Keys["X"]) then
                                    exports.TFS_progress:Custom({
                                        Duration = 1500,
                                        Label = "Vous sortez la tondeuse à gazon...",
                                        DisableControls = {
                                            Mouse = false,
                                            Player = true,
                                            Vehicle = true
                                        }
                                    })
                                    Citizen.Wait(1500)
                                    addLawnMower()
                                    hasLawnMower = true
                                end
                            elseif hasLawnMower or hasBlower or hasBackPack or hasTrimmer then
                                sleep = 5
                                DrawText3Ds(trunkpos.x, trunkpos.y, trunkpos.z + 0.5, "~y~[E]~s~ - Ranger l'outil dans le coffre")
                                if IsControlJustReleased(0, Keys["E"]) then
                                    exports.TFS_progress:Custom({
                                        Duration = 1500,
                                        Label = "Vous rangez l'outil dans le coffre...",
                                        DisableControls = {
                                            Mouse = false,
                                            Player = true,
                                            Vehicle = true
                                        }
                                    })
                                    Citizen.Wait(1500)
                                    removeLawnMower()
                                    removeBackPack()
                                    removeLeafBlower()
                                    removeTrimmer()
                                    hasLawnMower = false
                                    hasBlower = false
                                    hasTrimmer = false
                                    hasBackPack = false
                                    ClearPedTasks(ped)
                                end
                            end
                        end
                    end
                end
            end
        end
        Citizen.Wait(sleep)
    end
end)


Citizen.CreateThread(function()
    while true do

        local sleep = 500
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

            if Type == 'Rockford Hills' then
                for i, v in ipairs(Config.RockfordHills) do
                    local coordsNPC = GetEntityCoords(v.ped, false)
                    sleep = 5
                    if not IsPedInAnyVehicle(ped, false) then
                        if not wasTalked then
                            if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 2.5) then
                                DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 1.05, 'Salut, tu veux nettoyer mon jardin pour ~y~' ..salary.. '$~s~?')
                                DrawText3Ds(coords.x, coords.y, coords.z + 1.0, '~y~[W]~s~ - Ouais, bien sûr | ~r~[X]~s~ - Non merci')
                                if IsControlJustReleased(0, Keys["W"]) then
                                    wasTalked = true
                                    appointed = true
                                    CanWork = true
                                    FreezeEntityPosition(v.ped, false)
                                    TaskGoToCoordAnyMeans(v.ped, v.houseX, v.houseY, v.houseZ, 1.3)
                                    ESX.ShowNotification("<b>Gardener</b></br>Enlevez les mauvaises herbes de la cour")
                                    BlipsWorkingRH()
                                elseif IsControlJustReleased(0, Keys["X"]) then
                                    wasTalked = true
                                    appointed = false
                                    FreezeEntityPosition(v.ped, false)
                                    TaskGoToCoordAnyMeans(v.ped, v.houseX, v.houseY, v.houseZ, 1.3)
                                end
                            end
                        elseif wasTalked then
                            if not appointed then
                                if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 3.5) then
                                    DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 1.05, "D'accord, je trouverai un meilleur jardinier!")
                                elseif (GetDistanceBetweenCoords(coordsNPC, v.houseX, v.houseY, v.houseZ, true) < 0.35) then
                                    CancelWork()
                                end
                            elseif appointed then
                                if not waitingDone then
                                    if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 2.5) then
                                        DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 1.05, "Super ! Quand tu auras fini, fais-le moi savoir, je serai à la porte d'entrée.")
                                    end
                                    if (GetDistanceBetweenCoords(coordsNPC, v.houseX, v.houseY, v.houseZ, true) < 0.35) then
                                        ClearPedTasksImmediately(v.ped)
                                        FreezeEntityPosition(v.ped, true)
                                        SetEntityCoords(v.ped, v.houseX, v.houseY, v.houseZ - 1.0)
                                        SetEntityHeading(v.ped, v.houseH)
                                        waitingDone = true
                                    end
                                elseif waitingDone then
                                    if not Paycheck then
                                        if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 2.5) then
                                            DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 0.95, "Vous n'avez pas fini de nettoyer le jardin.")
                                        end
                                    elseif Paycheck then
                                        if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 1.5) then
                                            DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 0.95, "Maintenant le jardin a fière allure, voici votre argent.")
                                            DrawText3Ds(coords.x, coords.y, coords.z + 1.0, '~y~[E]~s~ - Prendre l\'argent')
                                            if IsControlJustReleased(0, Keys["E"]) then
                                                TaskTurnPedToFaceEntity(v.ped, ped, 0.2)
                                                TriggerServerEvent('TFS_gardener:Payout', salary, AmountPayout)
                                                ESX.ShowNotification("<b>Gardener</b></br>Tu as gagné " ..salary.. "$ !")
                                                ESX.Streaming.RequestAnimDict('mp_common', function()
                                                    TaskPlayAnim(ped, 'mp_common', 'givetake1_a', 8.0, -8.0, -1, 2, 0, false, false, false)
                                                end)
                                                ESX.Streaming.RequestAnimDict('mp_common', function()
                                                    TaskPlayAnim(v.ped, 'mp_common', 'givetake1_a', 8.0, -8.0, -1, 2, 0, false, false, false)
                                                end)
                                                Citizen.Wait(3500)
                                                ClearPedTasks(ped)
                                                CancelWork()
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                if CanWork then
                    for i, v in ipairs(Config.RockfordHillsWork) do
                        if not v.taked then
                            if (GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < 8) then
                                sleep = 5
                                DrawMarker(Marker.Type, v.x, v.y, v.z - 0.90, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Marker.Size.x, Marker.Size.y, Marker.Size.z, Marker.Color.r, Marker.Color.g, Marker.Color.b, 100, false, true, 2, false, false, false, false)
                                if (GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < 1.2) then
                                    sleep = 5
                                    DrawText3Ds(v.x, v.y, v.z + 0.4, "~y~[E]~s~ - Arracher l'herbe")
                                    if IsControlJustReleased(0, Keys["E"]) then
                                        ESX.Streaming.RequestAnimDict('amb@world_human_gardener_plant@male@enter', function()
                                            TaskPlayAnim(ped, 'amb@world_human_gardener_plant@male@enter', 'enter', 8.0, -8.0, -1, 2, 0, false, false, false)
                                        end)
                                        exports.TFS_progress:Custom({
                                            Duration = 3500,
                                            Label = "Déchirant la mauvaise herbe...",
                                            DisableControls = {
                                                Mouse = false,
                                                Player = true,
                                                Vehicle = true
                                            }
                                        })
                                        Citizen.Wait(3500)
                                        v.taked = true
                                        RemoveBlip(v.blip)
                                        done = done + 1
                                        ClearPedTasks(ped)
                                        if done == #Config.RockfordHillsWork then
                                            Paycheck = true
                                            done = 0
                                            AmountPayout = AmountPayout + 1
                                            ESX.ShowNotification("<b>Gardener</b></br>Le jardin est propre, allez chercher votre argent.")
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            elseif Type == "West Vinewood" then
                for i, v in ipairs(Config.WestVinewood) do
                    local coordsNPC = GetEntityCoords(v.ped, false)
                    sleep = 5
                    if not IsPedInAnyVehicle(ped, false) then
                        if not wasTalked then
                            if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 2.5) then
                                DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 1.05, 'Bonjour, veux-tu planter des arbres pour ~y~' ..salary.. '$~s~ ?')
                                DrawText3Ds(coords.x, coords.y, coords.z + 1.0, '~y~[W]~s~ - Bien sûr | ~r~[X]~s~ - Pas question')
                                if IsControlJustReleased(0, Keys["W"]) then
                                    wasTalked = true
                                    appointed = true
                                    CanWork = true
                                    FreezeEntityPosition(v.ped, false)
                                    TaskGoToCoordAnyMeans(v.ped, v.houseX, v.houseY, v.houseZ, 1.3)
                                    ESX.ShowNotification("<b>Jardinier</b></br>Plante des arbres dans l'allée")
                                    BlipsWorkingWV()
                                elseif IsControlJustReleased(0, Keys["X"]) then
                                    wasTalked = true
                                    appointed = false
                                    FreezeEntityPosition(v.ped, false)
                                    TaskGoToCoordAnyMeans(v.ped, v.houseX, v.houseY, v.houseZ, 1.3)
                                end
                            end
                        elseif wasTalked then
                            if not appointed then
                                if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 3.5) then
                                    DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 1.05, "D'accord, je n'ai plus besoin de toi !")
                                elseif (GetDistanceBetweenCoords(coordsNPC, v.houseX, v.houseY, v.houseZ, true) < 0.35) then
                                    CancelWork()
                                end
                            elseif appointed then
                                if not waitingDone then
                                    if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 2.5) then
                                        DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 1.05, "J'attendrai près de la piscine avec l'argent")
                                    end
                                    if (GetDistanceBetweenCoords(coordsNPC, v.houseX, v.houseY, v.houseZ, true) < 0.35) then
                                        ClearPedTasksImmediately(v.ped)
                                        FreezeEntityPosition(v.ped, true)
                                        SetEntityCoords(v.ped, v.houseX, v.houseY, v.houseZ - 1.0)
                                        SetEntityHeading(v.ped, v.houseH)
                                        waitingDone = true
                                    end
                                elseif waitingDone then
                                    if not Paycheck then
                                        if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 2.5) then
                                            DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 0.95, "Tu n'as pas planté tous les arbres")
                                        end
                                    elseif Paycheck then
                                        if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 1.5) then
                                            DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 0.95, "Attends juste qu'ils poussent ! Prends ton salaire")
                                            DrawText3Ds(coords.x, coords.y, coords.z + 1.0, '~y~[E]~s~ - Prendre l\'argent')
                                            if IsControlJustReleased(0, Keys["E"]) then
                                                TaskTurnPedToFaceEntity(v.ped, ped, 0.2)
                                                TriggerServerEvent('TFS_gardener:Payout', salary, AmountPayout)
                                                ESX.ShowNotification("<b>Jardinier</b></br>Tu as gagné " ..salary.. "$ !")
                                                ESX.Streaming.RequestAnimDict('mp_common', function()
                                                    TaskPlayAnim(ped, 'mp_common', 'givetake1_a', 8.0, -8.0, -1, 2, 0, false, false, false)
                                                end)
                                                ESX.Streaming.RequestAnimDict('mp_common', function()
                                                    TaskPlayAnim(v.ped, 'mp_common', 'givetake1_a', 8.0, -8.0, -1, 2, 0, false, false, false)
                                                end)
                                                Citizen.Wait(3500)
                                                ClearPedTasks(ped)
                                                CancelWork()
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                if CanWork then
                    for i, v in ipairs(Config.WestVinewoodWork) do
                        if not v.taked then
                            if (GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < 8) then
                                sleep = 5
                                DrawMarker(Marker.Type, v.x, v.y, v.z - 0.90, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Marker.Size.x, Marker.Size.y, Marker.Size.z, Marker.Color.r, Marker.Color.g, Marker.Color.b, 100, false, true, 2, false, false, false, false)
                                if (GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < 1.2) then
                                    sleep = 5
                                    DrawText3Ds(v.x, v.y, v.z + 0.4, "~y~[E]~s~ - Planter un arbre")
                                    if IsControlJustReleased(0, Keys["E"]) then
                                        exports.TFS_progress:Custom({
                                            Duration = 5500,
                                            Label = "Plantation de l'arbre...",
                                            Animation = {
                                                scenario = "WORLD_HUMAN_GARDENER_PLANT",
                                                animationDictionary = "enter",
                                            },
                                            DisableControls = {
                                                Mouse = false,
                                                Player = true,
                                                Vehicle = true
                                            }
                                        })
                                        ClearPedTasks(ped)
                                        v.taked = true
                                        RemoveBlip(v.blip)
                                        done = done + 1
                                        if done == #Config.WestVinewoodWork then
                                            Paycheck = true
                                            done = 0
                                            AmountPayout = AmountPayout + 1
                                            ESX.ShowNotification("<b>Jardinier</b></br>Tous les arbres sont plantés, prends ton salaire")
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            elseif Type == "Vinewood Hills" then
                for i, v in ipairs(Config.VinewoodHills) do
                    local coordsNPC = GetEntityCoords(v.ped, false)
                    sleep = 5
                    if not IsPedInAnyVehicle(ped, false) then
                        if not wasTalked then
                            if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 2.5) then
                                DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 1.05, 'Bonjour Monsieur, voulez-vous gagner ~y~' ..salary.. '$~s~ ?')
                                DrawText3Ds(coords.x, coords.y, coords.z + 1.0, '~y~[W]~s~ - Volontiers | ~r~[X]~s~ - Pas du tout')
                                if IsControlJustReleased(0, Keys["W"]) then
                                    wasTalked = true
                                    appointed = true
                                    CanWork = true
                                    FreezeEntityPosition(v.ped, false)
                                    TaskGoToCoordAnyMeans(v.ped, v.houseX, v.houseY, v.houseZ, 1.3)
                                    ESX.ShowNotification("<b>Gardener</b></br>Sortez le souffleur de feuilles du coffre et soufflez les feuilles du jardin")
                                    BlipsWorkingVH()
                                elseif IsControlJustReleased(0, Keys["X"]) then
                                    wasTalked = true
                                    appointed = false
                                    FreezeEntityPosition(v.ped, false)
                                    TaskGoToCoordAnyMeans(v.ped, v.houseX, v.houseY, v.houseZ, 1.3)
                                end
                            end
                        elseif wasTalked then
                            if not appointed then
                                if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 3.5) then
                                    DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 1.05, "Allez-vous-en !")
                                elseif (GetDistanceBetweenCoords(coordsNPC, v.houseX, v.houseY, v.houseZ, true) < 0.35) then
                                    CancelWork()
                                end
                            elseif appointed then
                                if not waitingDone then
                                    if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 2.5) then
                                        DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 1.05, "J'attends sur la terrasse avec l'argent")
                                    end
                                    if (GetDistanceBetweenCoords(coordsNPC, v.houseX, v.houseY, v.houseZ, true) < 0.35) then
                                        ClearPedTasksImmediately(v.ped)
                                        FreezeEntityPosition(v.ped, true)
                                        SetEntityCoords(v.ped, v.houseX, v.houseY, v.houseZ - 1.0)
                                        SetEntityHeading(v.ped, v.houseH)
                                        waitingDone = true
                                    end
                                elseif waitingDone then
                                    if not Paycheck then
                                        if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 2.5) then
                                            DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 0.95, "Vous n'avez pas soufflé toutes les feuilles")
                                        end
                                    elseif Paycheck then
                                        if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 1.5) then
                                            DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 0.95, "Bien joué, prenez l'argent")
                                            DrawText3Ds(coords.x, coords.y, coords.z + 1.0, '~y~[E]~s~ - Prenez l\'argent')
                                            if IsControlJustReleased(0, Keys["E"]) then
                                                if not hasBlower then
                                                    TaskTurnPedToFaceEntity(v.ped, ped, 0.2)
                                                    TriggerServerEvent('TFS_gardener:Payout', salary, AmountPayout)
                                                    ESX.ShowNotification("<b>Gardener</b></br>Vous avez gagné " ..salary.. "$ !")
                                                    ESX.Streaming.RequestAnimDict('mp_common', function()
                                                        TaskPlayAnim(ped, 'mp_common', 'givetake1_a', 8.0, -8.0, -1, 2, 0, false, false, false)
                                                    end)
                                                    ESX.Streaming.RequestAnimDict('mp_common', function()
                                                        TaskPlayAnim(v.ped, 'mp_common', 'givetake1_a', 8.0, -8.0, -1, 2, 0, false, false, false)
                                                    end)
                                                    Citizen.Wait(3500)
                                                    ClearPedTasks(ped)
                                                    CancelWork()
                                                elseif hasBlower then
                                                    ESX.ShowNotification("<b>Gardener</b></br>Mettez le souffleur de feuilles dans le coffre")
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                if CanWork then
                    for i, v in ipairs(Config.VinewoodHillsWork) do
                        if not v.taked then
                            if (GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < 8) then
                                sleep = 5
                                DrawMarker(Marker.Type, v.x, v.y, v.z - 0.90, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Marker.Size.x, Marker.Size.y, Marker.Size.z, Marker.Color.r, Marker.Color.g, Marker.Color.b, 100, false, true, 2, false, false, false, false)
                                if (GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < 1.2) then
                                    sleep = 5
                                    DrawText3Ds(v.x, v.y, v.z + 0.4, "~y~[E]~s~ - Soufflez les feuilles")
                                    if IsControlJustReleased(0, Keys["E"]) then
                                        if hasBlower then
                                            ESX.Streaming.RequestAnimDict('amb@world_human_gardener_leaf_blower@idle_a', function()
                                                TaskPlayAnim(ped, 'amb@world_human_gardener_leaf_blower@idle_a', 'idle_a', 8.0, -8.0, -1, 2, 0, false, false, false)
                                            end)
                                            exports.TFS_progress:Custom({
                                                Duration = 5500,
                                                Label = "Souffler les feuilles...",
                                                DisableControls = {
                                                    Mouse = false,
                                                    Player = true,
                                                    Vehicle = true
                                                }
                                            })
                                            Citizen.Wait(5500)
                                            ClearPedTasks(ped)
                                            v.taked = true
                                            RemoveBlip(v.blip)
                                            done = done + 1
                                            if done == #Config.VinewoodHillsWork then
                                                Paycheck = true
                                                done = 0
                                                AmountPayout = AmountPayout + 1
                                                ESX.ShowNotification("<b>Gardener</b></br>Toutes les feuilles nettoyées, prenez l'argent du client")
                                            end
                                        elseif not hasBlower then
                                            ESX.ShowNotification("<b>Gardener</b></br>Vous n'avez pas de souffleur de feuilles")
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            elseif Type == "El Burro Heights" then
                for i, v in ipairs(Config.ElBurroHeights) do
                    local coordsNPC = GetEntityCoords(v.ped, false)
                    sleep = 5
                    if not IsPedInAnyVehicle(ped, false) then
                        if not wasTalked then
                            if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 2.5) then
                                DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 1.05, 'Bonjour Monsieur, voulez-vous gagner ~y~' ..salary.. '$~s~?')
                                DrawText3Ds(coords.x, coords.y, coords.z + 1.0, '~y~[W]~s~ - Oui | ~r~[X]~s~ - Lâche ça')
                                if IsControlJustReleased(0, Keys["W"]) then
                                    wasTalked = true
                                    appointed = true
                                    CanWork = true
                                    FreezeEntityPosition(v.ped, false)
                                    TaskGoToCoordAnyMeans(v.ped, v.houseX, v.houseY, v.houseZ, 1.3)
                                    ESX.ShowNotification("<b>Jardinier</b></br>Sortez le souffleur et soufflez les feuilles du jardin")
                                    BlipsWorkingVH()
                                elseif IsControlJustReleased(0, Keys["X"]) then
                                    wasTalked = true
                                    appointed = false
                                    FreezeEntityPosition(v.ped, false)
                                    TaskGoToCoordAnyMeans(v.ped, v.houseX, v.houseY, v.houseZ, 1.3)
                                end
                            end
                        elseif wasTalked then
                            if not appointed then
                                if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 3.5) then
                                    DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 1.05, "Va t'en !")
                                elseif (GetDistanceBetweenCoords(coordsNPC, v.houseX, v.houseY, v.houseZ, true) < 0.35) then
                                    CancelWork()
                                end
                            elseif appointed then
                                if not waitingDone then
                                    if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 2.5) then
                                        DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 1.05, "J'attends sur la terrasse avec l'argent")
                                    end
                                    if (GetDistanceBetweenCoords(coordsNPC, v.houseX, v.houseY, v.houseZ, true) < 0.35) then
                                        ClearPedTasksImmediately(v.ped)
                                        FreezeEntityPosition(v.ped, true)
                                        SetEntityCoords(v.ped, v.houseX, v.houseY, v.houseZ - 1.0)
                                        SetEntityHeading(v.ped, v.houseH)
                                        waitingDone = true
                                    end
                                elseif waitingDone then
                                    if not Paycheck then
                                        if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 2.5) then
                                            DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 0.95, "Vous n'avez pas soufflé toutes les feuilles")
                                        end
                                    elseif Paycheck then
                                        if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 1.5) then
                                            DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 0.95, "Bien joué, prends l'argent")
                                            DrawText3Ds(coords.x, coords.y, coords.z + 1.0, '~y~[E]~s~ - Prends l\'argent')
                                            if IsControlJustReleased(0, Keys["E"]) then
                                                if not hasBlower then
                                                    TaskTurnPedToFaceEntity(v.ped, ped, 0.2)
                                                    TriggerServerEvent('TFS_gardener:Payout', salary, AmountPayout)
                                                    ESX.ShowNotification("<b>Jardinier</b></br>Vous avez gagné " ..salary.. "$ !")
                                                    ESX.Streaming.RequestAnimDict('mp_common', function()
                                                        TaskPlayAnim(ped, 'mp_common', 'givetake1_a', 8.0, -8.0, -1, 2, 0, false, false, false)
                                                    end)
                                                    ESX.Streaming.RequestAnimDict('mp_common', function()
                                                        TaskPlayAnim(v.ped, 'mp_common', 'givetake1_a', 8.0, -8.0, -1, 2, 0, false, false, false)
                                                    end)
                                                    Citizen.Wait(3500)
                                                    ClearPedTasks(ped)
                                                    CancelWork()
                                                elseif hasBlower then
                                                    ESX.ShowNotification("<b>Jardinier</b></br>Rangez le souffleur dans le coffre")
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                if CanWork then
                    for i, v in ipairs(Config.VinewoodHillsWork) do
                        if not v.taked then
                            if (GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < 8) then
                                sleep = 5
                                DrawMarker(Marker.Type, v.x, v.y, v.z - 0.90, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Marker.Size.x, Marker.Size.y, Marker.Size.z, Marker.Color.r, Marker.Color.g, Marker.Color.b, 100, false, true, 2, false, false, false, false)
                                if (GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < 1.2) then
                                    sleep = 5
                                    DrawText3Ds(v.x, v.y, v.z + 0.4, "~y~[E]~s~ - Soufflez les feuilles")
                                    if IsControlJustReleased(0, Keys["E"]) then
                                        if hasBlower then
                                            ESX.Streaming.RequestAnimDict('amb@world_human_gardener_leaf_blower@idle_a', function()
                                                TaskPlayAnim(ped, 'amb@world_human_gardener_leaf_blower@idle_a', 'idle_a', 8.0, -8.0, -1, 2, 0, false, false, false)
                                            end)
                                            exports.TFS_progress:Custom({
                                                Duration = 5500,
                                                Label = "Soufflage des feuilles...",
                                                DisableControls = {
                                                    Mouse = false,
                                                    Player = true,
                                                    Vehicle = true
                                                }
                                            })
                                            Citizen.Wait(5500)
                                            ClearPedTasks(ped)
                                            v.taked = true
                                            RemoveBlip(v.blip)
                                            done = done + 1
                                            if done == #Config.VinewoodHillsWork then
                                                Paycheck = true
                                                done = 0
                                                AmountPayout = AmountPayout + 1
                                                ESX.ShowNotification("<b>Jardinier</b></br>Toutes les feuilles sont dégagées, prenez l’argent du client")
                                            end
                                        elseif not hasBlower then
                                            ESX.ShowNotification("<b>Jardinier</b></br>Vous n'avez pas de souffleur")
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            elseif Type == "Richman" then
                for i, v in ipairs(Config.Richman) do
                    local coordsNPC = GetEntityCoords(v.ped, false)
                    sleep = 5
                    if not IsPedInAnyVehicle(ped, false) then
                        if not wasTalked then
                            if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 2.5) then
                                DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 1.05, 'Bonjour mon pote, tu veux devenir riche avec ~y~' ..salary.. '$~s~ ?')
                                DrawText3Ds(coords.x, coords.y, coords.z + 1.0, '~y~[W]~s~ - D\'accord | ~r~[X]~s~ - Je n\'ai pas le temps')
                                if IsControlJustReleased(0, Keys["W"]) then
                                    wasTalked = true
                                    appointed = true
                                    CanWork = true
                                    FreezeEntityPosition(v.ped, false)
                                    TaskGoToCoordAnyMeans(v.ped, v.houseX, v.houseY, v.houseZ, 1.3)
                                    ESX.ShowNotification("<b>Jardinier</b></br>Sortez le taille-haie du coffre et taillez la haie du client")
                                    BlipsWorkingRM()
                                elseif IsControlJustReleased(0, Keys["X"]) then
                                    wasTalked = true
                                    appointed = false
                                    FreezeEntityPosition(v.ped, false)
                                    TaskGoToCoordAnyMeans(v.ped, v.houseX, v.houseY, v.houseZ, 1.3)
                                end
                            end
                        elseif wasTalked then
                            if not appointed then
                                if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 3.5) then
                                    DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 1.05, "Pas de problème, bonne journée")
                                elseif (GetDistanceBetweenCoords(coordsNPC, v.houseX, v.houseY, v.houseZ, true) < 0.35) then
                                    CancelWork()
                                end
                            elseif appointed then
                                if not waitingDone then
                                    if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 2.5) then
                                        DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 1.05, "Je vais attendre à la porte")
                                    end
                                    if (GetDistanceBetweenCoords(coordsNPC, v.houseX, v.houseY, v.houseZ, true) < 0.35) then
                                        ClearPedTasksImmediately(v.ped)
                                        FreezeEntityPosition(v.ped, true)
                                        SetEntityCoords(v.ped, v.houseX, v.houseY, v.houseZ - 1.0)
                                        SetEntityHeading(v.ped, v.houseH)
                                        waitingDone = true
                                    end
                                elseif waitingDone then
                                    if not Paycheck then
                                        if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 2.5) then
                                            DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 0.95, "Tu n'as pas taillé toute la haie")
                                        end
                                    elseif Paycheck then
                                        if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 1.5) then
                                            DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 0.95, "Voici l'argent, tu es le meilleur !")
                                            DrawText3Ds(coords.x, coords.y, coords.z + 1.0, '~y~[E]~s~ - Prendre l\'argent')
                                            if IsControlJustReleased(0, Keys["E"]) then
                                                if not hasTrimmer then
                                                    TaskTurnPedToFaceEntity(v.ped, ped, 0.2)
                                                    TriggerServerEvent('TFS_gardener:Payout', salary, AmountPayout)
                                                    ESX.ShowNotification("<b>Jardinier</b></br>Vous avez gagné " ..salary.. "$ !")
                                                    ESX.Streaming.RequestAnimDict('mp_common', function()
                                                        TaskPlayAnim(ped, 'mp_common', 'givetake1_a', 8.0, -8.0, -1, 2, 0, false, false, false)
                                                    end)
                                                    ESX.Streaming.RequestAnimDict('mp_common', function()
                                                        TaskPlayAnim(v.ped, 'mp_common', 'givetake1_a', 8.0, -8.0, -1, 2, 0, false, false, false)
                                                    end)
                                                    Citizen.Wait(3500)
                                                    ClearPedTasks(ped)
                                                    CancelWork()
                                                elseif hasTrimmer then
                                                    ESX.ShowNotification("<b>Jardinier</b></br>Rangez le taille-haie dans le coffre")
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                if CanWork then
                    for i, v in ipairs(Config.RichmanWork) do
                        if not v.taked then
                            if (GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < 8) then
                                sleep = 5
                                DrawMarker(Marker.Type, v.x, v.y, v.z - 0.90, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Marker.Size.x, Marker.Size.y, Marker.Size.z, Marker.Color.r, Marker.Color.g, Marker.Color.b, 100, false, true, 2, false, false, false, false)
                                if (GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < 1.2) then
                                    sleep = 5
                                    DrawText3Ds(v.x, v.y, v.z + 0.4, "~y~[E]~s~ - Tailler la haie")
                                    if IsControlJustReleased(0, Keys["E"]) then
                                        if hasTrimmer then
                                            ESX.Streaming.RequestAnimDict('anim@mp_radio@garage@high', function()
                                                TaskPlayAnim(ped, 'anim@mp_radio@garage@high', 'idle_a', 8.0, -8.0, -1, 2, 0, false, false, false)
                                            end)
                                            exports.TFS_progress:Custom({
                                                Duration = 5500,
                                                Label = "Taille de la haie...",
                                                DisableControls = {
                                                    Mouse = false,
                                                    Player = true,
                                                    Vehicle = true
                                                }
                                            })
                                            Citizen.Wait(5500)
                                            ClearPedTasks(ped)
                                            v.taked = true
                                            RemoveBlip(v.blip)
                                            done = done + 1
                                            if done == #Config.RichmanWork then
                                                Paycheck = true
                                                done = 0
                                                AmountPayout = AmountPayout + 1
                                                ESX.ShowNotification("<b>Jardinier</b></br>La haie est faite, prenez votre salaire")
                                            end
                                        elseif not hasTrimmer then
                                            ESX.ShowNotification("<b>Jardinier</b></br>Vous n'avez pas de taille-haie")
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            elseif Type == "Mirror Park" then
                for i, v in ipairs(Config.MirrorPark) do
                    local coordsNPC = GetEntityCoords(v.ped, false)
                    sleep = 5
                    if not IsPedInAnyVehicle(ped, false) then
                        if not wasTalked then
                            if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 2.5) then
                                DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 1.05, "Salut, tu ne veux pas tondre la pelouse pour ~y~" ..salary.. '$~s~ ?')
                                DrawText3Ds(coords.x, coords.y, coords.z + 1.0, "~y~[W]~s~ - D'accord | ~r~[X]~s~ - Je suis pressé")
                                if IsControlJustReleased(0, Keys["W"]) then
                                    wasTalked = true
                                    appointed = true
                                    CanWork = true
                                    FreezeEntityPosition(v.ped, false)
                                    TaskGoToCoordAnyMeans(v.ped, v.houseX, v.houseY, v.houseZ, 1.3)
                                    ESX.ShowNotification("<b>Jardinier</b></br>Sortez la tondeuse du coffre et tondre l'herbe sur la propriété du client")
                                    BlipsWorkingMP()
                                elseif IsControlJustReleased(0, Keys["X"]) then
                                    wasTalked = true
                                    appointed = false
                                    FreezeEntityPosition(v.ped, false)
                                    TaskGoToCoordAnyMeans(v.ped, v.houseX, v.houseY, v.houseZ, 1.3)
                                end
                            end
                        elseif wasTalked then
                            if not appointed then
                                if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 3.5) then
                                    DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 1.05, "C'est bien qu'il y ait beaucoup de jardiniers dans cette ville, p*tain...")
                                elseif (GetDistanceBetweenCoords(coordsNPC, v.houseX, v.houseY, v.houseZ, true) < 0.35) then
                                    CancelWork()
                                end
                            elseif appointed then
                                if not waitingDone then
                                    if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 2.5) then
                                        DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 1.05, "Quand tu as terminé, viens pour le paiement")
                                    end
                                    if (GetDistanceBetweenCoords(coordsNPC, v.houseX, v.houseY, v.houseZ, true) < 0.35) then
                                        ClearPedTasksImmediately(v.ped)
                                        FreezeEntityPosition(v.ped, true)
                                        SetEntityCoords(v.ped, v.houseX, v.houseY, v.houseZ - 1.0)
                                        SetEntityHeading(v.ped, v.houseH)
                                        waitingDone = true
                                    end
                                elseif waitingDone then
                                    if not Paycheck then
                                        if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 2.5) then
                                            DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 0.95, "Tu n'as pas tondu toute l'herbe")
                                        end
                                    elseif Paycheck then
                                        if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 1.5) then
                                            DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 0.95, "Maintenant ce jardin a du sens, prends l'argent promis")
                                            DrawText3Ds(coords.x, coords.y, coords.z + 1.0, '~y~[E]~s~ - Prends l\'argent')
                                            if IsControlJustReleased(0, Keys["E"]) then
                                                if not hasLawnMower then
                                                    TaskTurnPedToFaceEntity(v.ped, ped, 0.2)
                                                    TriggerServerEvent('TFS_gardener:Payout', salary, AmountPayout)
                                                    ESX.ShowNotification("<b>Jardinier</b></br>Vous avez gagné " ..salary.. "$ !")
                                                    ESX.Streaming.RequestAnimDict('mp_common', function()
                                                        TaskPlayAnim(ped, 'mp_common', 'givetake1_a', 8.0, -8.0, -1, 2, 0, false, false, false)
                                                    end)
                                                    ESX.Streaming.RequestAnimDict('mp_common', function()
                                                        TaskPlayAnim(v.ped, 'mp_common', 'givetake1_a', 8.0, -8.0, -1, 2, 0, false, false, false)
                                                    end)
                                                    Citizen.Wait(3500)
                                                    ClearPedTasks(ped)
                                                    CancelWork()
                                                elseif hasLawnMower then
                                                    ESX.ShowNotification("<b>Jardinier</b></br>Rangez la tondeuse dans le coffre")
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                if CanWork then
                    for i, v in ipairs(Config.MirrorParkWork) do
                        if not v.taked then
                            if (GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < 8) then
                                sleep = 5
                                DrawMarker(Marker.Type, v.x, v.y, v.z - 0.90, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Marker.Size.x, Marker.Size.y, Marker.Size.z, Marker.Color.r, Marker.Color.g, Marker.Color.b, 100, false, true, 2, false, false, false, false)
                                if (GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < 1.2) then
                                    sleep = 5
                                    DrawText3Ds(v.x, v.y, v.z + 0.4, "~y~[E]~s~ - Tondre l'herbe")
                                    if IsControlJustReleased(0, Keys["E"]) then
                                        if hasLawnMower then
                                            v.taked = true
                                            RemoveBlip(v.blip)
                                            done = done + 1
                                            if done == #Config.MirrorParkWork then
                                                Paycheck = true
                                                done = 0
                                                AmountPayout = AmountPayout + 1
                                                ESX.ShowNotification("<b>Jardinier</b></br>La pelouse est faite, prends ton salaire")
                                            end
                                        elseif not hasLawnMower then
                                            ESX.ShowNotification("<b>Jardinier</b></br>Vous n'avez pas de tondeuse")
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            elseif Type == "East Vinewood" then
                for i, v in ipairs(Config.EastVinewood) do
                    local coordsNPC = GetEntityCoords(v.ped, false)
                    sleep = 5
                    if not IsPedInAnyVehicle(ped, false) then
                        if not wasTalked then
                            if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 2.5) then
                                DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 1.05, "Yo, tu ne veux pas arroser mes plantes pour ~y~" ..salary.. '$~s~ ?')
                                DrawText3Ds(coords.x, coords.y, coords.z + 1.0, "~y~[W]~s~ - Je suis intéressé | ~r~[X]~s~ - Je ne suis pas intéressé")
                                if IsControlJustReleased(0, Keys["W"]) then
                                    wasTalked = true
                                    appointed = true
                                    CanWork = true
                                    FreezeEntityPosition(v.ped, false)
                                    TaskGoToCoordAnyMeans(v.ped, v.houseX, v.houseY, v.houseZ, 1.3)
                                    ESX.ShowNotification("<b>Jardinier</b></br>Sortir le sac à dos du coffre et arroser les plantes dans le jardin du client.")
                                    BlipsWorkingEV()
                                elseif IsControlJustReleased(0, Keys["X"]) then
                                    wasTalked = true
                                    appointed = false
                                    FreezeEntityPosition(v.ped, false)
                                    TaskGoToCoordAnyMeans(v.ped, v.houseX, v.houseY, v.houseZ, 1.3)
                                end
                            end
                        elseif wasTalked then
                            if not appointed then
                                if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 3.5) then
                                    DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 1.05, "C'est ta perte, tu vas le regretter")
                                elseif (GetDistanceBetweenCoords(coordsNPC, v.houseX, v.houseY, v.houseZ, true) < 0.35) then
                                    CancelWork()
                                end
                            elseif appointed then
                                if not waitingDone then
                                    if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 2.5) then
                                        DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 1.05, "Quand tu as terminé, viens pour ton paiement")
                                    end
                                    if (GetDistanceBetweenCoords(coordsNPC, v.houseX, v.houseY, v.houseZ, true) < 0.35) then
                                        ClearPedTasksImmediately(v.ped)
                                        FreezeEntityPosition(v.ped, true)
                                        SetEntityCoords(v.ped, v.houseX, v.houseY, v.houseZ - 1.0)
                                        SetEntityHeading(v.ped, v.houseH)
                                        waitingDone = true
                                    end
                                elseif waitingDone then
                                    if not Paycheck then
                                        if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 2.5) then
                                            DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 0.95, "Tu n'as pas arrosé toutes les plantes")
                                        end
                                    elseif Paycheck then
                                        if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 1.5) then
                                            DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 0.95, "Elles vont pousser à tout moment... Prends ton argent")
                                            DrawText3Ds(coords.x, coords.y, coords.z + 1.0, '~y~[E]~s~ - Prendre l\'argent')
                                            if IsControlJustReleased(0, Keys["E"]) then
                                                if not hasBackPack then
                                                    TaskTurnPedToFaceEntity(v.ped, ped, 0.2)
                                                    TriggerServerEvent('TFS_gardener:Payout', salary, AmountPayout)
                                                    ESX.ShowNotification("<b>Jardinier</b></br>Tu as gagné " ..salary.. "$ !")
                                                    ESX.Streaming.RequestAnimDict('mp_common', function()
                                                        TaskPlayAnim(ped, 'mp_common', 'givetake1_a', 8.0, -8.0, -1, 2, 0, false, false, false)
                                                    end)
                                                    ESX.Streaming.RequestAnimDict('mp_common', function()
                                                        TaskPlayAnim(v.ped, 'mp_common', 'givetake1_a', 8.0, -8.0, -1, 2, 0, false, false, false)
                                                    end)
                                                    Citizen.Wait(3500)
                                                    ClearPedTasks(ped)
                                                    CancelWork()
                                                elseif hasBackPack then
                                                    ESX.ShowNotification("<b>Jardinier</b></br>Met le sac à dos dans le coffre")
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                if CanWork then
                    for i, v in ipairs(Config.EastVinewoodWork) do
                        if not v.taked then
                            if (GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < 8) then
                                sleep = 5
                                DrawMarker(Marker.Type, v.x, v.y, v.z - 0.90, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Marker.Size.x, Marker.Size.y, Marker.Size.z, Marker.Color.r, Marker.Color.g, Marker.Color.b, 100, false, true, 2, false, false, false, false)
                                if (GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < 1.2) then
                                    sleep = 5
                                    DrawText3Ds(v.x, v.y, v.z + 0.4, "~y~[E]~s~ - Arroser les plantes")
                                    if IsControlJustReleased(0, Keys["E"]) then
                                        if hasBackPack then
                                            ESX.Streaming.RequestAnimDict('missarmenian3_gardener', function()
                                                TaskPlayAnim(ped, 'missarmenian3_gardener', 'blower_idle_a', 8.0, -8.0, -1, 2, 0, false, false, false)
                                            end)
                                            exports.TFS_progress:Custom({
                                                Duration = 5500,
                                                Label = "Arrosage des plantes...",
                                                DisableControls = {
                                                    Mouse = false,
                                                    Player = true,
                                                    Vehicle = true
                                                }
                                            })
                                            Citizen.Wait(5500)
                                            ClearPedTasks(ped)
                                            v.taked = true
                                            RemoveBlip(v.blip)
                                            done = done + 1
                                            if done == #Config.EastVinewoodWork then
                                                Paycheck = true
                                                done = 0
                                                AmountPayout = AmountPayout + 1
                                                ESX.ShowNotification("<b>Jardinier</b></br>Tu as arrosé toutes les plantes, il est temps de payer")
                                            end
                                        elseif not hasBackPack then
                                            ESX.ShowNotification("<b>Jardinier</b></br>Tu n'as pas de sac à dos")
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        Citizen.Wait(sleep)
    end
end)

function CreateWork(type)

    if type == "Rockford Hills" then
        for i, v in ipairs(Config.RockfordHills) do
            v.blip = AddBlipForCoord(v.x, v.y, v.z)
            SetBlipSprite(v.blip, 205)
            SetBlipColour(v.blip, 43)
            SetBlipScale(v.blip, 0.5)
            SetBlipAsShortRange(v.blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString('[Jardinier] Lieu de travail')
            EndTextCommandSetBlipName(v.blip)

            local ped_hash = GetHashKey(Config.NPC['Peds'][math.random(1,#Config.NPC['Peds'])].ped)
            RequestModel(ped_hash)
            while not HasModelLoaded(ped_hash) do
                Citizen.Wait(1)
            end
            v.ped = CreatePed(1, ped_hash, v.x, v.y, v.z-0.96, v.h, false, true)
            SetBlockingOfNonTemporaryEvents(v.ped, true)
            SetPedDiesWhenInjured(v.ped, false)
            SetPedCanPlayAmbientAnims(v.ped, true)
            SetPedCanRagdollFromPlayerImpact(v.ped, false)
            SetEntityInvincible(v.ped, true)
            FreezeEntityPosition(v.ped, true)
        end
    elseif type == "West Vinewood" then
        for i, v in ipairs(Config.WestVinewood) do
            v.blip = AddBlipForCoord(v.x, v.y, v.z)
            SetBlipSprite(v.blip, 205)
            SetBlipColour(v.blip, 43)
            SetBlipScale(v.blip, 0.5)
            SetBlipAsShortRange(v.blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString('[Jardinier] Lieu de travail')
            EndTextCommandSetBlipName(v.blip)

            local ped_hash = GetHashKey(Config.NPC['Peds'][math.random(1,#Config.NPC['Peds'])].ped)
            RequestModel(ped_hash)
            while not HasModelLoaded(ped_hash) do
                Citizen.Wait(1)
            end
            v.ped = CreatePed(1, ped_hash, v.x, v.y, v.z-0.96, v.h, false, true)
            SetBlockingOfNonTemporaryEvents(v.ped, true)
            SetPedDiesWhenInjured(v.ped, false)
            SetPedCanPlayAmbientAnims(v.ped, true)
            SetPedCanRagdollFromPlayerImpact(v.ped, false)
            SetEntityInvincible(v.ped, true)
            FreezeEntityPosition(v.ped, true)
        end
    elseif type == "Vinewood Hills" then
        for i, v in ipairs(Config.VinewoodHills) do
            v.blip = AddBlipForCoord(v.x, v.y, v.z)
            SetBlipSprite(v.blip, 205)
            SetBlipColour(v.blip, 43)
            SetBlipScale(v.blip, 0.5)
            SetBlipAsShortRange(v.blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString('[Jardinier] Lieu de travail')
            EndTextCommandSetBlipName(v.blip)

            local ped_hash = GetHashKey(Config.NPC['Peds'][math.random(1,#Config.NPC['Peds'])].ped)
            RequestModel(ped_hash)
            while not HasModelLoaded(ped_hash) do
                Citizen.Wait(1)
            end
            v.ped = CreatePed(1, ped_hash, v.x, v.y, v.z-0.96, v.h, false, true)
            SetBlockingOfNonTemporaryEvents(v.ped, true)
            SetPedDiesWhenInjured(v.ped, false)
            SetPedCanPlayAmbientAnims(v.ped, true)
            SetPedCanRagdollFromPlayerImpact(v.ped, false)
            SetEntityInvincible(v.ped, true)
            FreezeEntityPosition(v.ped, true)
        end
    elseif type == "El Burro Heights" then
        for i, v in ipairs(Config.ElBurroHeights) do
            v.blip = AddBlipForCoord(v.x, v.y, v.z)
            SetBlipSprite(v.blip, 205)
            SetBlipColour(v.blip, 43)
            SetBlipScale(v.blip, 0.5)
            SetBlipAsShortRange(v.blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString('[Jardinier] Lieu de travail')
            EndTextCommandSetBlipName(v.blip)

            local ped_hash = GetHashKey(Config.NPC['Peds'][math.random(1,#Config.NPC['Peds'])].ped)
            RequestModel(ped_hash)
            while not HasModelLoaded(ped_hash) do
                Citizen.Wait(1)
            end
            v.ped = CreatePed(1, ped_hash, v.x, v.y, v.z-0.96, v.h, false, true)
            SetBlockingOfNonTemporaryEvents(v.ped, true)
            SetPedDiesWhenInjured(v.ped, false)
            SetPedCanPlayAmbientAnims(v.ped, true)
            SetPedCanRagdollFromPlayerImpact(v.ped, false)
            SetEntityInvincible(v.ped, true)
            FreezeEntityPosition(v.ped, true)
        end
    elseif type == "Richman" then
        for i, v in ipairs(Config.Richman) do
            v.blip = AddBlipForCoord(v.x, v.y, v.z)
            SetBlipSprite(v.blip, 205)
            SetBlipColour(v.blip, 43)
            SetBlipScale(v.blip, 0.5)
            SetBlipAsShortRange(v.blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString('[Jardinier] Lieu de travail')
            EndTextCommandSetBlipName(v.blip)

            local ped_hash = GetHashKey(Config.NPC['Peds'][math.random(1,#Config.NPC['Peds'])].ped)
            RequestModel(ped_hash)
            while not HasModelLoaded(ped_hash) do
                Citizen.Wait(1)
            end
            v.ped = CreatePed(1, ped_hash, v.x, v.y, v.z-0.96, v.h, false, true)
            SetBlockingOfNonTemporaryEvents(v.ped, true)
            SetPedDiesWhenInjured(v.ped, false)
            SetPedCanPlayAmbientAnims(v.ped, true)
            SetPedCanRagdollFromPlayerImpact(v.ped, false)
            SetEntityInvincible(v.ped, true)
            FreezeEntityPosition(v.ped, true)
        end
    elseif type == "Mirror Park" then
        for i, v in ipairs(Config.MirrorPark) do
            v.blip = AddBlipForCoord(v.x, v.y, v.z)
            SetBlipSprite(v.blip, 205)
            SetBlipColour(v.blip, 43)
            SetBlipScale(v.blip, 0.5)
            SetBlipAsShortRange(v.blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString('[Jardinier] Lieu de travail')
            EndTextCommandSetBlipName(v.blip)

            local ped_hash = GetHashKey(Config.NPC['Peds'][math.random(1,#Config.NPC['Peds'])].ped)
            RequestModel(ped_hash)
            while not HasModelLoaded(ped_hash) do
                Citizen.Wait(1)
            end
            v.ped = CreatePed(1, ped_hash, v.x, v.y, v.z-0.96, v.h, false, true)
            SetBlockingOfNonTemporaryEvents(v.ped, true)
            SetPedDiesWhenInjured(v.ped, false)
            SetPedCanPlayAmbientAnims(v.ped, true)
            SetPedCanRagdollFromPlayerImpact(v.ped, false)
            SetEntityInvincible(v.ped, true)
            FreezeEntityPosition(v.ped, true)
        end
    elseif type == "East Vinewood" then
        for i, v in ipairs(Config.EastVinewood) do
            v.blip = AddBlipForCoord(v.x, v.y, v.z)
            SetBlipSprite(v.blip, 205)
            SetBlipColour(v.blip, 43)
            SetBlipScale(v.blip, 0.5)
            SetBlipAsShortRange(v.blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString('[Jardinier] Lieu de travail')
            EndTextCommandSetBlipName(v.blip)

            local ped_hash = GetHashKey(Config.NPC['Peds'][math.random(1,#Config.NPC['Peds'])].ped)
            RequestModel(ped_hash)
            while not HasModelLoaded(ped_hash) do
                Citizen.Wait(1)
            end
            v.ped = CreatePed(1, ped_hash, v.x, v.y, v.z-0.96, v.h, false, true)
            SetBlockingOfNonTemporaryEvents(v.ped, true)
            SetPedDiesWhenInjured(v.ped, false)
            SetPedCanPlayAmbientAnims(v.ped, true)
            SetPedCanRagdollFromPlayerImpact(v.ped, false)
            SetEntityInvincible(v.ped, true)
            FreezeEntityPosition(v.ped, true)
        end
    end
    Type = type
end

function CancelWork()

    if Type == "Rockford Hills" then
        for i, v in ipairs(Config.RockfordHills) do
            RemoveBlip(v.blip)
            DeletePed(v.ped)
        end
        for i, v in ipairs(Config.RockfordHillsWork) do
            v.taked = false
            RemoveBlip(v.blip)
        end
    elseif Type == "West Vinewood" then
        for i, v in ipairs(Config.WestVinewood) do
            RemoveBlip(v.blip)
            DeletePed(v.ped)
        end
        for i, v in ipairs(Config.WestVinewoodWork) do
            v.taked = false
            RemoveBlip(v.blip)
        end
    elseif Type == "Vinewood Hills" then
        for i, v in ipairs(Config.VinewoodHills) do
            RemoveBlip(v.blip)
            DeletePed(v.ped)
        end
        for i, v in ipairs(Config.VinewoodHillsWork) do
            v.taked = false
            RemoveBlip(v.blip)
        end
    elseif Type == "El Burro Heights" then
        for i, v in ipairs(Config.ElBurroHeights) do
            RemoveBlip(v.blip)
            DeletePed(v.ped)
        end
        for i, v in ipairs(Config.ElBurroHeightsWork) do
            v.taked = false
            RemoveBlip(v.blip)
        end
    elseif Type == "Richman" then
        for i, v in ipairs(Config.Richman) do
            RemoveBlip(v.blip)
            DeletePed(v.ped)
        end
        for i, v in ipairs(Config.RichmanWork) do
            v.taked = false
            RemoveBlip(v.blip)
        end
    elseif Type == "Mirror Park" then
        for i, v in ipairs(Config.MirrorPark) do
            RemoveBlip(v.blip)
            DeletePed(v.ped)
        end
        for i, v in ipairs(Config.MirrorParkWork) do
            v.taked = false
            RemoveBlip(v.blip)
        end
    elseif Type == "East Vinewood" then
        for i, v in ipairs(Config.EastVinewood) do
            RemoveBlip(v.blip)
            DeletePed(v.ped)
        end
        for i, v in ipairs(Config.EastVinewoodWork) do
            v.taked = false
            RemoveBlip(v.blip)
        end
    end
    Type = nil
    appointed = false
    wasTalked = false
    waitingDone = false
    CanWork = false
    Paycheck = false
    salary = nil
    AmountPayout = 0
    done = 0
end

function BlipsWorkingRH()
    for i, v in ipairs(Config.RockfordHillsWork) do
        v.blip = AddBlipForCoord(v.x, v.y, v.z)
        SetBlipSprite(v.blip, 1)
        SetBlipColour(v.blip, 24)
        SetBlipScale(v.blip, 0.4)
        SetBlipAsShortRange(v.blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName('[Jardinier] Mauvaises herbes')
        EndTextCommandSetBlipName(v.blip)
    end
end

function BlipsWorkingWV()
    for i, v in ipairs(Config.WestVinewoodWork) do
        v.blip = AddBlipForCoord(v.x, v.y, v.z)
        SetBlipSprite(v.blip, 1)
        SetBlipColour(v.blip, 24)
        SetBlipScale(v.blip, 0.4)
        SetBlipAsShortRange(v.blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName('[Jardinier] Arbres')
        EndTextCommandSetBlipName(v.blip)
    end
end

function BlipsWorkingVH()
    for i, v in ipairs(Config.VinewoodHillsWork) do
        v.blip = AddBlipForCoord(v.x, v.y, v.z)
        SetBlipSprite(v.blip, 1)
        SetBlipColour(v.blip, 24)
        SetBlipScale(v.blip, 0.4)
        SetBlipAsShortRange(v.blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName('[Jardinier] Feuilles')
        EndTextCommandSetBlipName(v.blip)
    end
end

function BlipsWorkingEBH()
    for i, v in ipairs(Config.ElBurroHeightsWork) do
        v.blip = AddBlipForCoord(v.x, v.y, v.z)
        SetBlipSprite(v.blip, 1)
        SetBlipColour(v.blip, 24)
        SetBlipScale(v.blip, 0.4)
        SetBlipAsShortRange(v.blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName('[Jardinier] Herbe')
        EndTextCommandSetBlipName(v.blip)
    end
end

function BlipsWorkingRM()
    for i, v in ipairs(Config.RichmanWork) do
        v.blip = AddBlipForCoord(v.x, v.y, v.z)
        SetBlipSprite(v.blip, 1)
        SetBlipColour(v.blip, 24)
        SetBlipScale(v.blip, 0.4)
        SetBlipAsShortRange(v.blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName('[Jardinier] Haie')
        EndTextCommandSetBlipName(v.blip)
    end
end

function BlipsWorkingMP()
    for i, v in ipairs(Config.MirrorParkWork) do
        v.blip = AddBlipForCoord(v.x, v.y, v.z)
        SetBlipSprite(v.blip, 1)
        SetBlipColour(v.blip, 24)
        SetBlipScale(v.blip, 0.4)
        SetBlipAsShortRange(v.blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName('[Jardinier] Herbe à tondre')
        EndTextCommandSetBlipName(v.blip)
    end
end

function BlipsWorkingEV()
    for i, v in ipairs(Config.EastVinewoodWork) do
        v.blip = AddBlipForCoord(v.x, v.y, v.z)
        SetBlipSprite(v.blip, 1)
        SetBlipColour(v.blip, 24)
        SetBlipScale(v.blip, 0.4)
        SetBlipAsShortRange(v.blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName('[Jardinier] Arroser les plantes')
        EndTextCommandSetBlipName(v.blip)
    end
end

function addBackPack()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    backpack = CreateObject(GetHashKey('prop_spray_backpack_01'), coords.x, coords.y, coords.z,  true,  true, true)
    AttachEntityToEntity(backpack, ped, GetPedBoneIndex(ped, 56604), 0.0, -0.12, 0.28, 0.0, 0.0, 180.0, true, true, false, true, 1, true)
end

function removeBackPack()
    local ped = PlayerPedId()

    DeleteEntity(backpack)
end

function addLawnMower()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    RequestAnimDict("anim@heists@box_carry@")
    while (not HasAnimDictLoaded("anim@heists@box_carry@")) do
        Citizen.Wait(7)
    end
    TaskPlayAnim(ped, "anim@heists@box_carry@" ,"idle", 5.0, -1, -1, 50, 0, false, false, false)
    lawnmower = CreateObject(GetHashKey('prop_lawnmower_01'), coords.x, coords.y, coords.z,  true,  true, true)
    AttachEntityToEntity(lawnmower, ped, GetPedBoneIndex(ped, 56604), -0.05, 1.0, -0.85, 0.0, 0.0, 180.0, true, true, false, true, 1, true)
end

function removeLawnMower()
    local ped = PlayerPedId()

    DeleteEntity(lawnmower)
end

function addTrimmer()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    trimmer = CreateObject(GetHashKey('prop_hedge_trimmer_01'), coords.x, coords.y, coords.z,  true,  true, true)
    AttachEntityToEntity(trimmer, ped, GetPedBoneIndex(ped, 57005), 0.09, 0.02, 0.01, -121.0, 181.0, 187.0, true, true, false, true, 1, true)
end

function removeTrimmer()
    local ped = PlayerPedId()

    DeleteEntity(trimmer)
end

function addLeafBlower()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    leafblower = CreateObject(GetHashKey('prop_leaf_blower_01'), coords.x, coords.y, coords.z,  true,  true, true)
    AttachEntityToEntity(leafblower, ped, GetPedBoneIndex(ped, 57005), 0.14, 0.02, 0.0, -40.0, -40.0, 0.0, true, true, false, true, 1, true)
end

function removeLeafBlower()
    local ped = PlayerPedId()

    DeleteEntity(leafblower)
end

-- RETURNING VEHICLE
function ReturnVehicle()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped)

    ESX.Game.DeleteVehicle(vehicle)
end

-- MAIN BLIP
Citizen.CreateThread(function()
    baseBlip = AddBlipForCoord(Base.Pos.x, Base.Pos.y, Base.Pos.z)
    SetBlipSprite(baseBlip, Base.BlipSprite)
    SetBlipDisplay(baseBlip, 4)
    SetBlipScale(baseBlip, Base.BlipScale)
    SetBlipAsShortRange(baseBlip, true)
    SetBlipColour(baseBlip, Base.BlipColor)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(Base.BlipLabel)
    EndTextCommandSetBlipName(baseBlip)
end)

-- ADDING GARAGES BLIPS
function addGarageBlip()
    garageBlip = AddBlipForCoord(Garage.Pos.x, Garage.Pos.y, Garage.Pos.z)
    SetBlipSprite(garageBlip, Garage.BlipSprite)
    SetBlipDisplay(garageBlip, 4)
    SetBlipScale(garageBlip, Garage.BlipScale)
    SetBlipAsShortRange(garageBlip, true)
    SetBlipColour(garageBlip, Garage.BlipColor)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(Garage.BlipLabel)
    EndTextCommandSetBlipName(garageBlip)
end

-- REMOVING GARAGES BLIPS
function removeGarageBlip()
    RemoveBlip(garageBlip)
end

function DrawText3Ds(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

function DrawText3DMenu(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.02+0.0125, -0.14+ factor, 0.08, 0, 0, 0, 75)
    ClearDrawOrigin()
end

function DrawText3Dss(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.008+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

-- ████████╗██╗███████╗██╗ ██████╗ ██╗   ██╗███████╗███████╗
-- ╚══██╔══╝██║██╔════╝██║██╔═══██╗██║   ██║██╔════╝██╔════╝
--    ██║   ██║█████╗  ██║██║   ██║██║   ██║███████╗█████╗  
--    ██║   ██║██╔══╝  ██║██║   ██║██║   ██║╚════██║██╔══╝  
--    ██║   ██║██║     ██║╚██████╔╝╚██████╔╝███████║███████╗
--    ╚═╝   ╚═╝╚═╝     ╚═╝ ╚═════╝  ╚═════╝ ╚══════╝╚══════╝