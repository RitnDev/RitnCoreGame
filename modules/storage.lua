---------------------------------------------------------------------------------------------
-- GLOBALS
---------------------------------------------------------------------------------------------
-- Teste de migration de la variable "global"
if global ~= nil then storage = global end

if storage.core == nil then 
    storage.core = {
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
local flib = require(ritnlib.defines.core.functions)
---------------------------------------------------------------------------------------------
local core_interface = {
    --players
    get_players = function() return storage.core.players end,
    set_players = function(players) storage.core.players = players end,
    --surfaces
    get_surfaces = function() return storage.core.surfaces end,
    set_surfaces = function(surfaces) storage.core.surfaces = surfaces end,
    --forces
    get_forces = function() return storage.core.forces end,
    set_forces = function(forces) storage.core.forces = forces end,
    --enemy
    get_enemy = function() return storage.core.enemy end,
    set_enemy = function(enemy) storage.core.enemy = enemy end,
    --map_settings
    get_map_settings = function() return storage.core.map_settings end,
    set_map_settings = function(map_settings) storage.core.map_settings = map_settings end,
    --map_gen_settings
    get_map_gen_settings = function() return storage.core.map_gen_settings end,
    set_map_gen_settings = function(map_gen_settings) storage.core.map_gen_settings = map_gen_settings end,
    --options
    get_options = function() return storage.core.options end,
    set_options = function(options) storage.core.options = options end,
    get_option = function(option) return storage.core.options[option] end,
    --values
    get_values = function(parameter) return storage.core.values[parameter] end,
    set_values = function(parameter, value) storage.core.values[parameter] = value end,
    --start
    isStart = function() return storage.core.start end,
    starting = function() storage.core.start = true end,
    -- save_map_settings
    save_map_settings = function()     
        local new_seed = storage.core.options.custom_map_settings.new_seed
        log('> storage.core.options.custom_map_settings.new_seed = ' .. tostring(new_seed))
        return flib.saveMapSettings(new_seed)
    end,
    --cheatModeActivated
    isCheatModeActivated = function() 
        if storage.core.cheatModeActivated == nil then
            storage.core.cheatModeActivated = false            
        end
        return storage.core.cheatModeActivated
    end,
    cheatModeActivated = function() 
        storage.core.cheatModeActivated = true 
    end,
    --multiplayer
    isMultiplayer = function() 
        if storage.core.multiplayer == nil then
            storage.core.multiplayer = false            
        end
        return storage.core.multiplayer
    end,
    setMultiplayer = function() 
        storage.core.multiplayer = true 
    end,
    -- spaceblock
    spaceblock = function(event) spaceblock.on_chunk_generated(event) end,
    ---- DATAS ----
    init_data = function(data_name, data_value) storage.core.datas[data_name] = data_value end, 
    get_data = function(parameter) return storage.core.datas[parameter] end,
    add_param_data = function(data_name, param_name, value) storage.core.datas[data_name][param_name] = value end, 
}
remote.add_interface("RitnCoreGame", core_interface)
---------------------------------------------------------------------------------------------
return {}