---------------------------------------------------------------------------------------------
-- EVENTS
---------------------------------------------------------------------------------------------
local RitnSurface = require(ritnlib.defines.core.class.surface)
local spaceblock = require(ritnlib.defines.core.mods.spaceblock)
---------------------------------------------------------------------------------------------
local events = {}
---------------------------------------------------------------------------------------------

local function on_init(event)
    global.core = {
        datas = {},
        players = {},
        surfaces = {},
        forces = {},
        map_settings = {},
        map_gen_settings = {},
        enemy = {},
        options = {},
        values = {
            players = 0,
            surfaces = 0,
            forces = 0
        },
        start = false
    }
    log('on_init : RitnCoreGame -> finish !')

    -- create remote interfaces
    local core_interface = {
        --players
        get_players = function() return global.core.players end,
        set_players = function(players) global.core.players = players end,
        --surfaces
        get_surfaces = function() return global.core.surfaces end,
        set_surfaces = function(surfaces) global.core.surfaces = surfaces end,
        --forces
        get_forces = function() return global.core.forces end,
        set_forces = function(forces) global.core.forces = forces end,
        --enemy
        get_enemy = function() return global.core.enemy end,
        set_enemy = function(enemy) global.core.enemy = enemy end,
        --map_settings
        get_map_settings = function() return global.core.map_settings end,
        set_map_settings = function(map_settings) global.core.map_settings = map_settings end,
        --map_gen_settings
        get_map_gen_settings = function() return global.core.map_gen_settings end,
        set_map_gen_settings = function(map_gen_settings) global.core.map_gen_settings = map_gen_settings end,
        --options
        get_options = function() return global.core.options end,
        set_options = function(options) global.core.options = options end,
        get_option = function(option) return global.core.options[option] end,
        --values
        get_values = function(parameter) return global.core.values[parameter] end,
        set_values = function(parameter, value) global.core.values[parameter] = value end,
        --start
        isStart = function() return global.core.start end,
        starting = function() global.core.start = true end,
        -- spaceblock
        spaceblock = function(event) spaceblock.on_chunk_generated(event) end,
        ---- DATAS ----
        init_data = function(data_name, data_value) global.core.datas[data_name] = data_value end, 
        get_data = function(parameter) return global.core.datas[parameter] end,
        add_param_data = function(data_name, param_name, value) global.core.datas[data_name][param_name] = value end, 
    }
    remote.add_interface("RitnCoreGame", core_interface)
    ----------------------------------------------------
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
end

------------------------------------------------------------------------------------------------------------
-- Créer une surface nauvis si on charge une partie ne comportant pas RitnTP à la base.
local function on_tick_loadGame(e) 
    if e.tick > 3600 then    -- 3600 ?
      local surfaces = global.core.surfaces
        if not surfaces["nauvis"] then
            -- Creation de la structure de map dans les données
            RitnSurface(game.surfaces.nauvis):new()
            log('on_tick : RitnBaseGame | init nauvis -> finish !')
        end
    end
end
------------------------------------------------------------------------------------------------------------
-- event : on_tick
script.on_event({defines.events.on_tick},function(e)
    on_tick_loadGame(e) 
end)
-- event : on_init
script.on_init(on_init)
------------------------------------------------------------------------------------------------------------
return events