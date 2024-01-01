---------------------------------------------------------------------------------------------
-- GLOBALS
---------------------------------------------------------------------------------------------
if global.core == nil then 
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
        start = false,
        cheatModeActivated = false,
        multiplayer = false,
    }
end
---------------------------------------------------------------------------------------------
-- REMOTE FUNCTIONS INTERFACE
---------------------------------------------------------------------------------------------
local spaceblock = require(ritnlib.defines.core.mods.spaceblock)
---------------------------------------------------------------------------------------------
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
    --cheatModeActivated
    isCheatModeActivated = function() 
        if global.core.cheatModeActivated == nil then
            global.core.cheatModeActivated = false            
        end
        return global.core.cheatModeActivated
    end,
    cheatModeActivated = function() 
        global.core.cheatModeActivated = true 
    end,
    --multiplayer
    isMultiplayer = function() 
        if global.core.multiplayer == nil then
            global.core.multiplayer = false            
        end
        return global.core.multiplayer
    end,
    setMultiplayer = function() 
        global.core.multiplayer = true 
    end,
    -- spaceblock
    spaceblock = function(event) spaceblock.on_chunk_generated(event) end,
    ---- DATAS ----
    init_data = function(data_name, data_value) global.core.datas[data_name] = data_value end, 
    get_data = function(parameter) return global.core.datas[parameter] end,
    add_param_data = function(data_name, param_name, value) global.core.datas[data_name][param_name] = value end, 
}
remote.add_interface("RitnCoreGame", core_interface)
---------------------------------------------------------------------------------------------
return {}