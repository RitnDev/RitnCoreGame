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
    remote.call("RitnCoreGame", "init_data", "force", {
        index = 0,
        name = "",
        exception = true,
        players = {},
        force_used = false,
        finish = false,
    })
    remote.call("RitnCoreGame", "init_data", "surface_player", { name = ""})
    remote.call("RitnCoreGame", "init_data", "force_player", { name = ""})

    log('on_init : RitnCoreGame -> finish !')
end


local function on_configuration_changed()
    log('RitnCoreGame -> on_configuration_changed')
    ---------------------------------
    global.core.cheatModeActivated = false
    global.core.multiplayer = game.is_multiplayer()
    ---------------------------------
    remote.call("RitnCoreGame", "init_data", "force", {
        index = 0,
        name = "",
        exception = true,
        players = {},
        force_used = false,
        finish = false,
    })
    remote.call("RitnCoreGame", "init_data", "force_player", { name = ""})
    log('on_configuration_changed : RitnCoreGame -> finish !')
end

------------------------------------------------------------------------------------------------------------
-- events :
script.on_init(on_init_mod)
script.on_configuration_changed(on_configuration_changed)
---------------------------------------------------------------------------------------------
return {}