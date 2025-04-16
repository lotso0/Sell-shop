-----------------For support, scripts, and more----------------
--------------- https://discord.gg/darksiderp  -------------
---------------------------------------------------------------

local curVersion = GetResourceMetadata(GetCurrentResourceName(), "version")
local resourceName = "sellshop_lotso"

if Config.checkForUpdates then
    CreateThread(function()
        if GetCurrentResourceName() ~= "sellshop_lotso" then
            resourceName = "sellshop_lotso (" .. GetCurrentResourceName() .. ")"
        end
    end)

    CreateThread(function()
        while true do
            PerformHttpRequest("https://api.github.com/repos/lotso0/Sell-shop/releases/latest", CheckVersion, "GET")
            Wait(3600000)
        end
    end)

    CheckVersion = function(err, responseText, headers)
        local repoVersion, repoURL, repoBody = GetRepoInformations()

        CreateThread(function()
            -- Normalisation des versions pour éviter les erreurs de comparaison
            local normalizedCurVersion = tostring(curVersion):gsub("%s+", ""):lower()
            local normalizedRepoVersion = tostring(repoVersion):gsub("%s+", ""):lower()

            if normalizedCurVersion ~= normalizedRepoVersion then
                Wait(4000)
                print("^0[^3AVERTISSEMENT^0] " .. resourceName .. " n'est ^1PAS ^0à jour !")
                print("^0[^3AVERTISSEMENT^0] Votre version : ^2" .. curVersion .. "^0")
                print("^0[^3AVERTISSEMENT^0] Dernière version : ^2" .. repoVersion .. "^0")
                print("^0[^3AVERTISSEMENT^0] Obtenez la dernière version ici : ^2" .. repoURL .. "^0")
                print("^0[^3AVERTISSEMENT^0] Journal des modifications :^0")
                print("^1" .. repoBody .. "^0")
            else
                Wait(4000)
                print("^0[^2INFO^0] " .. resourceName .. " est à jour ! (^2" .. curVersion .. "^0)")
            end
        end)
    end

    GetRepoInformations = function()
        local repoVersion, repoURL, repoBody = nil, nil, nil

        PerformHttpRequest("https://api.github.com/repos/lotso0/Sell-shop/releases/latest", function(err, response, headers)
            if err == 200 then
                local data = json.decode(response)

                -- Vérifiez si la version est valide
                if data and data.tag_name and data.tag_name:match("^%d+%.%d+%.%d+$") then
                    repoVersion = data.tag_name
                elseif data and data.name and data.name:match("%d+%.%d+%.%d+") then
                    -- Si tag_name est invalide, essayez d'extraire la version depuis le champ "name"
                    repoVersion = data.name:match("%d+%.%d+%.%d+")
                else
                    print("^1[ERREUR]^0 Impossible de récupérer une version valide depuis le dépôt GitHub.")
                    repoVersion = curVersion -- Utilisez la version actuelle comme fallback
                end

                repoURL = data.html_url or "https://github.com/lotso0/Sell-shop"
                repoBody = data.body or "Aucune information disponible."
            else
                print("^1[ERREUR]^0 Échec de la requête HTTP pour récupérer les informations du dépôt.")
                repoVersion = curVersion -- Utilisez la version actuelle comme fallback
                repoURL = "https://github.com/lotso0/Sell-shop"
                repoBody = "Aucune information disponible."
            end
        end, "GET")

        repeat
            Wait(50)
        until (repoVersion and repoURL and repoBody)

        return repoVersion, repoURL, repoBody
    end
end
