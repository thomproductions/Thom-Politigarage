Config = {}

-- Hvordan skal garagen åbnes? "radial" eller "button"
Config.AccessType = "radial"

-- Sidebar kategorier og ikoner (Font Awesome style names for NUI only)
Config.Categories = {
    {
        id = "active",
        label = "Aktive Enheder",
        icon = "ph-rss-duotone"
    },
    {
        id = "marked",
        label = "Markerede",
        icon = "ph-shield-star-duotone"
    },
    {
        id = "mc",
        label = "MC",
        icon = "ph-motorcycle-duotone"
    },
    {
        id = "civil",
        label = "Civil",
        icon = "ph-car-profile-duotone"
    },
    {
        id = "special",
        label = "Special-enhed",
        icon = "ph-target-duotone"
    }
}

-- Garage zoner og spawn points
Config.Garages = {
    {
        id = "politi_hq",
        label = "POLITI GARAGE",
        coords = vector3(452.6, -1017.4, 28.4),
        radius = 5.0,
        spawnPoints = {
            vector4(446.4865, -1025.7274, 28.6394, 32.75),
            vector4(442.5312, -1025.9894, 28.7132, 32.75),
            vector4(438.6419, -1026.8589, 28.7870, 32.75),
            vector4(435.1049, -1027.0330, 28.8497, 32.75),
            vector4(431.3217, -1027.3911, 28.9184, 32.75),
            vector4(427.8332, -1027.6592, 28.9802, 32.75)
        }
    }
}

Config.SpawnPoints = {
    vector4(446.4865, -1025.7274, 28.6394, 32.75),
    vector4(442.5312, -1025.9894, 28.7132, 32.75),
    vector4(438.6419, -1026.8589, 28.7870, 32.75),
    vector4(435.1049, -1027.0330, 28.8497, 32.75),
    vector4(431.3217, -1027.3911, 28.9184, 32.75),
    vector4(427.8332, -1027.6592, 28.9802, 32.75)
}

-- Køretøjer
-- image: filnavn placeret i nui/images/
-- categoryId: skal matche et af Config.Categories ids
Config.Vehicles = {
    {
        id = "stratos_marked",
        model = "stratos_marked",
        displayName = "Markeret Stratos",
        garage = "Politi",
        categoryId = "marked",
        classLabel = "POLITI",
        fuel = 100,
        engine = 1000,
        body = 1000,
        image = "stratos.png"
    },
    {
        id = "gxb_marked",
        model = "gxb_marked",
        displayName = "Markeret GXB",
        garage = "Politi",
        categoryId = "marked",
        classLabel = "POLITI",
        fuel = 100,
        engine = 1000,
        body = 1000,
        image = "gxb.png"
    },
    {
        id = "polaris_marked",
        model = "p",
        displayName = "Markeret Polaris",
        garage = "Politi",
        categoryId = "marked",
        classLabel = "POLITI",
        fuel = 100,
        engine = 1000,
        body = 1000,
        image = "polaris.png"
    },
    {
        id = "bike1",
        model = "bike1",
        displayName = "Motorcykel Enhed",
        garage = "Politi",
        categoryId = "mc",
        classLabel = "POLITI",
        fuel = 100,
        engine = 1000,
        body = 1000,
        image = "bike1.png"
    },
    {
        id = "stratos_civil",
        model = "stratos_civil",
        displayName = "Stratos Civil",
        garage = "Politi",
        categoryId = "civil",
        classLabel = "POLITI",
        fuel = 100,
        engine = 1000,
        body = 1000,
        image = "stratosc.png"
    },
    {
        id = "polaris_civil",
        model = "polaris_civil",
        displayName = "Polaris Civil",
        garage = "Politi",
        categoryId = "civil",
        classLabel = "POLITI",
        fuel = 100,
        engine = 1000,
        body = 1000,
        image = "polarisc.png"
    },
    {
        id = "gxb_civil",
        model = "gxb_civil",
        displayName = "GXB Civil",
        garage = "Politi",
        categoryId = "civil",
        classLabel = "POLITI",
        fuel = 100,
        engine = 1000,
        body = 1000,
        image = "gxbc.png"
    },
    {
        id = "unmarked",
        model = "unmarked",
        displayName = "Civil Enhed",
        garage = "Politi",
        categoryId = "civil",
        classLabel = "POLITI",
        fuel = 100,
        engine = 1000,
        body = 1000,
        image = "glb.png"
    },
    {
        id = "iq4",
        model = "iq4",
        displayName = "Markeret IQ4",
        garage = "Politi",
        categoryId = "marked",
        classLabel = "POLITI",
        fuel = 100,
        engine = 1000,
        body = 1000,
        image = "id4.png"
    },
    {
        id = "argento_marked",
        model = "argento_marked",
        displayName = "Markeret Argento",
        garage = "Politi",
        categoryId = "marked",
        classLabel = "POLITI",
        fuel = 100,
        engine = 1000,
        body = 1000,
        image = "argento.png"
    },
    {
        id = "rhinehart_marked",
        model = "rhinehart_marked",
        displayName = "Markeret Rhinehart",
        garage = "Politi",
        categoryId = "marked",
        classLabel = "POLITI",
        fuel = 100,
        engine = 1000,
        body = 1000,
        image = "rhinehart.png"
    },
    {
        id = "rebla_marked",
        model = "rebla_marked",
        displayName = "Markeret Rebla",
        garage = "Politi",
        categoryId = "marked",
        classLabel = "POLITI",
        fuel = 100,
        engine = 1000,
        body = 1000,
        image = "rebla.png"
    },
    {
        id = "buffalo_marked",
        model = "buffalo_marked",
        displayName = "Markeret Buffalo",
        garage = "Politi",
        categoryId = "marked",
        classLabel = "POLITI",
        fuel = 100,
        engine = 1000,
        body = 1000,
        image = "buffalo.png"
    },
    {
        id = "xls_marked",
        model = "xls_marked",
        displayName = "Markeret XLS",
        garage = "Politi",
        categoryId = "marked",
        classLabel = "POLITI",
        fuel = 100,
        engine = 1000,
        body = 1000,
        image = "xls.png"
    },
    {
        id = "iwagen_marked",
        model = "iwagen_marked",
        displayName = "Markeret I-Wagen",
        garage = "Politi",
        categoryId = "marked",
        classLabel = "POLITI",
        fuel = 100,
        engine = 1000,
        body = 1000,
        image = "iwagen.png"
    },
    {
        id = "caracara_marked",
        model = "caracara_marked",
        displayName = "Markeret Caracara",
        garage = "Politi",
        categoryId = "marked",
        classLabel = "POLITI",
        fuel = 100,
        engine = 1000,
        body = 1000,
        image = "caracara.png"
    },
    {
        id = "bf400_marked",
        model = "bf400_marked",
        displayName = "Markeret BF400",
        garage = "Politi",
        categoryId = "marked",
        classLabel = "POLITI",
        fuel = 100,
        engine = 1000,
        body = 1000,
        image = "bf400.png"
    },
    {
        id = "naga1300",
        model = "naga1300",
        displayName = "Naga 1300",
        garage = "Politi",
        categoryId = "mc",
        classLabel = "POLITI",
        fuel = 100,
        engine = 1000,
        body = 1000,
        image = "naga1300.png"
    },
    {
        id = "shinobi",
        model = "shinobi",
        displayName = "Shinobi",
        garage = "Politi",
        categoryId = "mc",
        classLabel = "POLITI",
        fuel = 100,
        engine = 1000,
        body = 1000,
        image = "shinobi.png"
    },
    {
        id = "indsatsleder",
        model = "indsatsleder",
        displayName = "Indsatsleder",
        garage = "Politi",
        categoryId = "special",
        classLabel = "POLITI",
        fuel = 100,
        engine = 1000,
        body = 1000,
        image = "streiter.png"
    },
    {
        id = "indsatsleder_v2",
        model = "indsatsleder_v2",
        displayName = "Indsatsleder V2",
        garage = "Politi",
        categoryId = "special",
        classLabel = "POLITI",
        fuel = 100,
        engine = 1000,
        body = 1000,
        image = "indsatslederv2.png"
    },
    {
        id = "gruppevogn",
        model = "gruppevogn",
        displayName = "Gruppevogn",
        garage = "Politi",
        categoryId = "special",
        classLabel = "POLITI",
        fuel = 100,
        engine = 1000,
        body = 1000,
        image = "transferc.png"
    },
    {
        id = "transfer",
        model = "transfer",
        displayName = "Transfer",
        garage = "Politi",
        categoryId = "special",
        classLabel = "POLITI",
        fuel = 100,
        engine = 1000,
        body = 1000,
        image = "transfer.png"
    },
    {
        id = "brute",
        model = "brute",
        displayName = "Brute",
        garage = "Politi",
        categoryId = "special",
        classLabel = "POLITI",
        fuel = 100,
        engine = 1000,
        body = 1000,
        image = "brute.png"
    },
    {
        id = "swat",
        model = "swat",
        displayName = "Special-enhed",
        garage = "Politi",
        categoryId = "special",
        classLabel = "POLITI",
        fuel = 100,
        engine = 1000,
        body = 1000,
        image = "brutec.png"
    }
}

-- Enhedskategori dropdown-valg i spawn-dialogen
Config.UnitCategories = {
    { id = "Bravo", label = "Bravo" },
    { id = "Mike", label = "Mike" },
    { id = "Mike Kilo", label = "Mike Kilo" },
    { id = "Kilo", label = "Kilo" },
    { id = "Lima", label = "Lima" },
    { id = "Træning", label = "Træning" }
}

-- Blip indstillinger
Config.BlipSprite = 225 -- bil icon
Config.BlipColor = 3 -- blå
Config.BlipScale = 0.9

-- ESX job krav for adgang til garage
Config.RequiredJob = "police"

