ESX = exports["es_extended"]:getSharedObject()

-- Fonction pour envoyer les logs au webhook
local function sendToWebhook(webhook, data)
    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({
        username = "SellShop Logs",
        embeds = {
            {
                title = "Nouvelle Vente",
                color = 3447003, -- Couleur de l'embed (en hexadécimal)
                fields = {
                    { name = "Joueur", value = data.playerName, inline = true },
                    { name = "Licence", value = data.license, inline = true },
                    { name = "Objet vendu", value = data.item, inline = true },
                    { name = "Quantité", value = tostring(data.quantity), inline = true },
                    { name = "Profit", value = "$" .. tostring(data.profit), inline = true },
                    { name = "Job", value = data.job, inline = true },
                    { name = "Position", value = string.format("X: %.2f, Y: %.2f, Z: %.2f", data.coords.x, data.coords.y, data.coords.z), inline = false },
                },
                footer = {
                    text = "SellShop System",
                    icon_url = "https://i.imgur.com/AfFp7pu.png" -- Exemple d'icône
                },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }
        }
    }), { ['Content-Type'] = 'application/json' })
end

-- Gestion de la vente des objets
lib.callback.register('lotso_sellshop:sellItem', function(source, data)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xItem = xPlayer.getInventoryItem(data.item)

    -- Vérifiez si l'objet existe dans l'inventaire
    if not xItem then
        print("[SellShop] L'objet " .. data.item .. " n'existe pas dans l'inventaire du joueur.")
        return false
    end

    -- Vérifiez si le joueur a le job requis
    if data.requiredJob and xPlayer.getJob().name ~= data.requiredJob then
        print("[SellShop] Le joueur n'a pas le job requis pour vendre cet objet.")
        return false
    end

    -- Vérifiez si le joueur a suffisamment d'objets
    if xItem.count < data.quantity then
        print("[SellShop] Le joueur n'a pas assez d'objets pour effectuer la vente.")
        return false
    end

    -- Calcul du profit
    local profit = math.floor(data.price * data.quantity)

    -- Retirer les objets du joueur
    xPlayer.removeInventoryItem(data.item, data.quantity)

    -- Ajouter de l'argent sur le compte du joueur
    xPlayer.addAccountMoney(data.currency, profit)

    -- Préparer les données pour le webhook
    local logData = {
        playerName = xPlayer.getName(),
        license = xPlayer.identifier,
        item = data.item,
        quantity = data.quantity,
        profit = profit,
        job = xPlayer.getJob().name,
        coords = GetEntityCoords(GetPlayerPed(source))
    }

    -- Envoyer les logs au webhook
    sendToWebhook(Config.webhook, logData)

    -- Retourner le montant du profit réalisé
    return profit
end)

-- Vérifie si le joueur a le job requis pour accéder au magasin
lib.callback.register('lotso_sellshop:checkWineJob', function(source, store)
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerJob = xPlayer.getJob().name

    -- Vérifie si le joueur a le job requis pour ce magasin
    for _, shop in ipairs(Config.SellShops) do
        if shop.coords == store.coords then
            for _, item in ipairs(shop.items) do
                if item.requiredJob and item.requiredJob ~= playerJob then
                    return false -- Le joueur n'a pas le job requis
                end
            end
        end
    end

    return true -- Le joueur a le bon job
end)
