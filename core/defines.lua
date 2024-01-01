--------  INIT DATA DEFINES CORE  ----------
ritnlib.defines.core = {}
--------------------------------------------
local name = "RitnCoreGame"
local mod_name = "__"..name.."__"

local defines = {
    name = name,
    directory = mod_name,

    class = {
        event = mod_name .. ".classes.RitnEvent",
        player = mod_name .. ".classes.RitnPlayer",
        surface = mod_name .. ".classes.RitnSurface",
        force = mod_name .. ".classes.RitnForce",
        gui = mod_name .. ".classes.RitnGui",
    },

    modules = {
        core = mod_name .. ".core.modules",
        ----
        globals = mod_name .. ".modules.globals",
        events = mod_name .. ".modules.events",
        ----
        player = mod_name .. ".modules.player",
    },

    functions = mod_name .. ".core.functions",

    mods = {
        seablock = mod_name .. ".mods.seablock",
        spaceblock = mod_name .. ".mods.spaceblock"
    },

    sounds = {
        none = mod_name .. ".sounds.none.ogg",
    },



    names = {
        prefix = {
            enemy = "enemy~",
            lobby = "lobby~",
        }
    }
}

--------------------------------------------
ritnlib.defines.core = defines
log('declare : ritnlib.defines.core | '.. ritnlib.defines.core.name ..' -> finish !')
--------------------------------------------