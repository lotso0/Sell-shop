ESX = exports['es_extended']:getSharedObject()

local MenuOuvert = false
local mainMenu = RageUI.CreateMenu("Revente", "Sélectionne un objet à vendre")
local currentStore = nil
local selectedItem = nil
local quantityInput = 1
local showHelpText = true -- Variable pour contrôler l'affichage du texte UI
local isInShopZone = false
local wasInShopZone = false 

-- Ouvre le menu
function OpenSellShopMenu(store)
    lib.callback('lotso_sellshop:checkWineJob', false, function(hasWineJob)
        if not hasWineJob then
            -- Récupère le job requis depuis la configuration
            local requiredJob = store.items[1].requiredJob or "inconnu"
            lib.notify({
                title = 'Accès refusé',
                description = 'Vous devez être "' .. requiredJob .. '" pour accéder à ce magasin.',
                type = 'error'
            })
            return
        end

        if MenuOuvert then return end
        MenuOuvert = true
        currentStore = store

        -- Désactiver le texte UI
        showHelpText = false
        ClearHelp(true)

        RageUI.Visible(mainMenu, true)

        CreateThread(function()
            while MenuOuvert do
                RageUI.IsVisible(mainMenu, function()
                    RageUI.Separator(store.label)
                    for i = 1, #store.items do
                        local item = store.items[i]
                        RageUI.Button(item.label .. " - $" .. item.price, "Prix unitaire: $" .. item.price, {}, true, {
                            onSelected = function()
                                AskQuantityAndSell(item)
                            end
                        })
                    end
                end)

                if not RageUI.Visible(mainMenu) then
                    MenuOuvert = false
                    showHelpText = true -- Réactiver le texte UI après la fermeture du menu
                end

                Wait(0)
            end
        end)
    end, store)
end

-- Ferme le menu
function CloseMenu()
    RageUI.Visible(mainMenu, false)
    MenuOuvert = false
    currentStore = nil
end

-- Demande la quantité et lance la vente
function AskQuantityAndSell(item)
    local input = lib.inputDialog('Combien voulez-vous vendre ?', {'Quantité'})
    if input then
        quantityInput = math.floor(tonumber(input[1]) or 0)
        if quantityInput < 1 or quantityInput > 5 then
            lib.notify({
                title = 'Erreur',
                description = 'La quantité doit être comprise entre 1 et 5 !',
                type = 'error'
            })
            return
        end

        -- Animation
        local playerPed = PlayerPedId()
        lib.requestAnimDict('mp_common', 100)
        TaskPlayAnim(playerPed, 'mp_common', 'givetake1_a', 8.0, 8.0, -1, 49, 0, false, false, false)

        -- Barre de progression
        local progress = lib.progressBar({
            duration = 3000,
            label = 'Vente en cours...',
            useWhileDead = false,
            canCancel = false,
            disable = {
                car = true,
                move = true,
                combat = true
            }
        })

        ClearPedTasks(playerPed)

        if not progress then
            lib.notify({
                title = 'Annulé',
                description = 'Vente annulée.',
                type = 'error'
            })
            return
        end

        -- Envoi au serveur pour traiter la vente
        local result = lib.callback.await('lotso_sellshop:sellItem', 100, {
            item = item.item,
            price = item.price,
            quantity = quantityInput,
            currency = item.currency
        })

        if not result or type(result) ~= "number" then
            lib.notify({
                title = 'Erreur',
                description = 'Vous n\'avez pas assez d\'objets ou une erreur s\'est produite.',
                type = 'error'
            })
        else
            -- Affiche le profit gagné
            lib.notify({
                title = 'Succès',
                description = 'Vous avez gagné $'..addCommas(result),
                type = 'success'
            })
        end
    else
        lib.notify({
            title = 'Erreur',
            description = 'Veuillez entrer une quantité valide.',
            type = 'error'
        })
    end
end

-- Ouvre le menu via l’event
RegisterNetEvent('lotso_sellshop:interact', function(data)
    OpenSellShopMenu(data.store)
end)

-- Ajoute les zones ox_target et crée les blips
CreateThread(function()
    for i = 1, #Config.SellShops do
        local shop = Config.SellShops[i]

        -- Ajoute la zone ox_target pour chaque magasin
        exports.ox_target:addBoxZone({
            coords = shop.coords,
            size = vec3(1, 1, 2),
            rotation = shop.heading,
            debug = false,
            options = {
                {
                    name = "sell_shop_" .. i,
                    icon = "fas fa-hand-paper",
                    label = "Vendre des objets",
                    onSelect = function()
                        TriggerEvent('lotso_sellshop:interact', { store = shop })
                    end
                }
            }
        })

        -- Crée le blip pour chaque magasin
        if shop.blip.enabled then
            CreateBlip(shop.coords, shop.blip.sprite, shop.blip.color, shop.label, shop.blip.scale)
        end
    end
end)

-- Crée les blips
function CreateBlip(coords, sprite, colour, text, scale)
    local blip = AddBlipForCoord(coords)
    SetBlipSprite(blip, sprite)
    SetBlipColour(blip, colour)
    SetBlipAsShortRange(blip, true)
    SetBlipScale(blip, scale)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(text)
    EndTextCommandSetBlipName(blip)
end

-- Ajoute les virgules aux prix
function addCommas(n)
    return tostring(math.floor(n)):reverse():gsub("(%d%d%d)", "%1,")
    :gsub(",(%-?)$", "%1"):reverse()
end

-- Dessine les markers et gère l'interaction
CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local sleep = 500

        for i = 1, #Config.SellShops do
            local shop = Config.SellShops[i]
            local distance = #(playerCoords - shop.coords)

            -- Si le joueur est proche du magasin, dessine le marker
            if distance < 10.0 then
                sleep = 0
                DrawMarker(
                    25,
                    shop.coords.x, shop.coords.y, shop.coords.z - 0.98,
                    0.0, 0.0, 0.0,
                    0.0, 0.0, 0.0,
                    0.8, 0.8, 0.2,
                    0, 0, 139, 150,
                    false, true, 2,
                    nil, nil, false
                )

                -- Si le joueur est assez proche, affiche un message et détecte l'appui sur la touche E
                if distance < 1.0 then
                    ESX.ShowHelpNotification("Appuyez sur ~INPUT_CONTEXT~ pour accéder au magasin.")
                    if IsControlJustReleased(0, 38) then
                        ClearHelp(true)
                        OpenSellShopMenu(shop)
                    end
                end
            end
        end

        Wait(sleep)
    end
end)

-- Gestion de l'affichage du texte UI
CreateThread(function()
    while true do
        local sleep = 500
        if showHelpText and currentStore and not RageUI.Visible(mainMenu) then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local distance = #(playerCoords - currentStore.coords)

            if distance < 1.5 then
                sleep = 0
                ESX.ShowHelpNotification("Appuyez sur ~INPUT_CONTEXT~ pour accéder au magasin.")
            end
        end
        Wait(sleep)
    end
end)

-- Spawn les peds
function SpawnShopPed(pedModel, coords, heading)
    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do
        Wait(100)
    end

    local ped = CreatePed(4, pedModel, coords.x, coords.y, coords.z - 1.0, heading, false, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, true)
    return ped
end

-- Crée tous les peds des shops au spawn
CreateThread(function()
    for i = 1, #Config.SellShops do
        local shop = Config.SellShops[i]
        SpawnShopPed(shop.ped, shop.coords, shop.heading)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        isInShopZone = false

        for _, shop in ipairs(Config.SellShops) do
            local distance = #(playerCoords - shop.coords)
            if distance < 2.0 then -- Distance pour détecter l'entrée dans le magasin
                isInShopZone = true
                if not wasInShopZone then -- Affiche la notification uniquement si le joueur vient d'entrer
                    ESX.ShowHelpNotification("Appuyez sur ~INPUT_CONTEXT~ pour accéder au magasin.")
                end
                if IsControlJustReleased(0, 38) then -- INPUT_CONTEXT (E par défaut)
                    OpenSellShopMenu(shop) -- Ouvre le menu du magasin
                end
                break
            end
        end

        if not isInShopZone and wasInShopZone then
            ClearHelp(true) -- Ferme la notification si le joueur quitte la zone
        end

        -- Vérification après la fermeture du menu ou si le joueur s'éloigne
        if MenuOuvert then
            local distanceFromShop = #(playerCoords - currentStore.coords)
            if distanceFromShop > 5.0 then -- Si le joueur s'éloigne à plus de 5 mètres
                RageUI.CloseAll() -- Ferme tous les menus RageUI
                MenuOuvert = false
                ESX.ShowNotification("Vous vous êtes éloigné du magasin.") -- Notification pour informer le joueur
            end
        end

        wasInShopZone = isInShopZone -- Met à jour l'état précédent
    end
end)
