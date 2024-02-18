---------------------------------------------------------------------------------------------
-- EVENTS
---------------------------------------------------------------------------------------------
local migration = require("core.migrations")
---------------------------------------------------------------------------------------------
local function on_init_mod()
    log('RitnCoreGame -> on_init')

    remote.call("RitnCoreGame", "init_data", "player", {
        index = 0,
        name = "",
        origine = "",
        surface = "",
        force = "",
        connected = false
    })
    remote.call("RitnCoreGame", "init_data", "surface", {
        index = 0,
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
    ---------------------------------
    local options = remote.call("RitnCoreGame", "get_options")
    options.custom_map_settings = {
        new_seed = false
    }
    remote.call("RitnCoreGame", "set_options", options)
    ---------------------------------

    log('on_init : RitnCoreGame -> finish !')
end


local function on_configuration_changed()
    log('RitnCoreGame -> on_configuration_changed')
    ---------------------------------
    local options = remote.call("RitnCoreGame", "get_options")
    if options.custom_map_settings == nil then
        options.custom_map_settings = {
            new_seed = false
        }
    end
    remote.call("RitnCoreGame", "set_options", options)
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
    migration.version(0,3,9)
end

------------------------------------------------------------------------------------------------------------
-- events :
script.on_init(on_init_mod)
script.on_configuration_changed(on_configuration_changed)
---------------------------------------------------------------------------------------------
return {}