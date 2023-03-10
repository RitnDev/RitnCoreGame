---------------------------------------------------------------------------------------------
-- EVENTS
---------------------------------------------------------------------------------------------
local function on_init_mod()
    log('RitnCoreGame -> on_init')

    remote.call("RitnCoreGame", "init_data", "player", {
        name = "",
        origine = "",
        surface = "",
        force = "",
        connected = false
    })
    remote.call("RitnCoreGame", "init_data", "surface", {
        name = "",
        exception = true,
        origine = "",
        players = {},
        last_use = 0,
        map_used = false,
        finish = false,
    })
    remote.call("RitnCoreGame", "init_data", "surface_player", { name = ""})

    log('on_init : RitnCoreGame -> finish !')
end
------------------------------------------------------------------------------------------------------------
-- events :
script.on_init(on_init_mod)
---------------------------------------------------------------------------------------------
return {}