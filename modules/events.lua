---------------------------------------------------------------------------------------------
-- EVENTS
---------------------------------------------------------------------------------------------
local migration = require("core.migrations")
---------------------------------------------------------------------------------------------
local function on_init_mod()
    log('RitnCoreGame -> on_init')

    remote.call("RitnCoreGame", "init_data", "player", {
        index = 0,
        object_name = "RitnDataPlayer",
        name = "",
        origine = "",
        surface = "",
        force = "",
        connected = false
    })
    remote.call("RitnCoreGame", "init_data", "surface", {
        index = 0,
        object_name = "RitnDataSurface",
        name = "",
        seed = 0,   -- TODO enregistré la seed ici 
        exception = true,
        origine = "",
        players = {},
        map_used = false,
        finish = false,
    })
    remote.call("RitnCoreGame", "init_data", "force", {
        index = 0,
        object_name = "RitnDataForce",
        name = "",
        exception = true,
        players = {},
        inventories = {},
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
    storage.core.cheatModeActivated = false
    storage.core.multiplayer = game.is_multiplayer()
    ---------------------------------
    remote.call("RitnCoreGame", "init_data", "force", {
        index = 0,
        object_name = "RitnDataForce",
        name = "",
        exception = true,
        players = {},
        inventories = {},
        force_used = false,
        finish = false,
    })
    remote.call("RitnCoreGame", "init_data", "force_player", { name = ""})
    log('on_configuration_changed : RitnCoreGame -> finish !')
    migration.version(0,6,6)
end

---------------------------------------------------------------------------------------------
local module = {events = {}}
---------------------------------------------------------------------------------------------
-- events :
module.on_init = on_init_mod
module.on_configuration_changed = on_configuration_changed
---------------------------------------------------------------------------------------------
return module