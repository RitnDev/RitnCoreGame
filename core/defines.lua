--------  INIT DATA DEFINES CORE  ----------
--------------------------------------------
if not ritnlib then require("__RitnLib__.defines") end
--------------------------------------------
local name = "RitnCoreGame"
local mod_name = "__"..name.."__"

local defines = {
    name = name,
    directory = mod_name,

    -- classes
    class = {
        event = mod_name .. ".classes.RitnEvent",
        player = mod_name .. ".classes.RitnPlayer",
        surface = mod_name .. ".classes.RitnSurface",
        force = mod_name .. ".classes.RitnForce",
        gui = mod_name .. ".classes.RitnGui",
    },

    -- setup-classes
    setup = mod_name .. ".core.setup-classes",


    -- modules
    modules = {
        core = mod_name .. ".core.modules",
        ----
        storage = mod_name .. ".modules.storage",
        events = mod_name .. ".modules.events",
        commands = mod_name .. ".modules.commands",
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
        },
        force_default = "force~default",
    }
}

--------------------------------------------
ritnlib.defines.core = defines
log('declare : ritnlib.defines.core | '.. ritnlib.defines.core.name ..' -> finish !')
--------------------------------------------