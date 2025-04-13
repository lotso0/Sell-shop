-----------------For support, scripts, and more----------------
--------------- https://discord.gg/wasabiscripts  -------------
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
            if curVersion ~= repoVersion then
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

                repoVersion = data.tag_name
                repoURL = data.html_url
                repoBody = data.body
            else
                repoVersion = curVersion
                repoURL = "https://github.com/lotso0/Sell-shop"
            end
        end, "GET")

        repeat
            Wait(50)
        until (repoVersion and repoURL and repoBody)

        return repoVersion, repoURL, repoBody
    end
end
