Config = {}

Config.checkForUpdates = true -- = uptade sur le github de https://github.com/lotso0/Sell-shop

Config.webhook = "" -- Lien du webhook discord pour les ventes

Config.SellShops = {
    { 
        coords = vec3(408.7484, 309.1052, 103.0200), -- Coords du premier magasin
        heading = 201.2,
        ped = 'a_m_m_og_boss_01',
        label = 'Vente de lockpick',
        blip = {
            enabled = true,
            sprite = 11,
            color = 11,
            scale = 0.75
        },
        items = {
            { item = 'lockpick', label = 'Lockpick', price = 12, currency = 'money', requiredJob = 'wine' },
        }
    },
    { 
        coords = vec3(411.44, 313.27, 103.01), -- Coords du deuxième magasin
        heading = 201.2,
        ped = 'a_f_m_fatbla_01',
        label = 'Sell Shop 2',
        blip = {
            enabled = true,
            sprite = 11,
            color = 11,
            scale = 0.75
        },
        items = {
            { item = 'water', label = 'Water', price = 5, currency = 'money', requiredJob = 'unicorn' },
        }
    },
    { 
    coords = vec3(-629.9275, 7595.1958, 14.9941), -- Coords du deuxième magasin
    heading = 239.2,
    ped = 'a_m_m_indian_01',
    label = 'Revendeur de  paquet cigarettes',
    blip = {
        enabled = true,
        sprite = 280,
        color = 20,
        scale = 0.75
    },
    items = {
        { item = 'cigarettes_redwood', label = ' Paquet de cigarettes  redwood', price = 5, currency = 'money', requiredJob = 'tabac' },
        { item = 'cigar', label = 'Un cigare', price = 8, currency = 'money', requiredJob = 'tabac' },
    }
},
}