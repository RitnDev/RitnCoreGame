----------------------------------------------------------------
-- FUNCTIONS
----------------------------------------------------------------

-- Le tableau est plein ?
local function tableBusy(T)
    for k,v in pairs(T) do
        if T[k] ~= nil then 
            return true
        end
    end
    return false
end



-- Recupération des settings de la map (nauvis)
local function saveMapSettings(generate_seed)
    local new_seed = false 
    if generate_seed ~= nil then new_seed = generate_seed end

    local map_settings = remote.call('RitnCoreGame', 'get_map_settings')
    local map_gen_settings = remote.call('RitnCoreGame', 'get_map_gen_settings')
    local enemy = remote.call('RitnCoreGame', "get_enemy")

    if map_settings.pollution == nil then 
        local map_settings_game = game.map_settings
        map_settings.pollution = { enabled = map_settings_game.pollution.enabled}

        map_settings.enemy_evolution = {
            enabled = enemy.active,
            time_factor = map_settings_game.enemy_evolution.time_factor,
            destroy_factor = map_settings_game.enemy_evolution.destroy_factor,
            pollution_factor = map_settings_game.enemy_evolution.pollution_factor,
        }
        map_settings.enemy_expansion = {enabled = map_settings_game.enemy_expansion.enabled}
    end
    remote.call('RitnCoreGame', 'set_map_settings', map_settings)
    local enemy = remote.call('RitnCoreGame', 'get_enemy')

    if not map_gen_settings.seed then 
        game.map_settings.enemy_evolution.time_factor = 0
        game.map_settings.enemy_evolution.pollution_factor = 0
        map_gen_settings = game.surfaces.nauvis.map_gen_settings

        -- forcage de la désactivation des enemy dans la partie
        local force_disable = false
        if enemy.force_disable ~= nil then 
            force_disable = enemy.force_disable
        end

        -- si on force la désactivation de la force enemy on met à 0 la création de base
        if force_disable then 
            map_gen_settings["autoplace_controls"]["enemy-base"].size = 0
        end

        -- si la création de base est à 0, cela veut dire que les ennemies sont désactivés
        if map_gen_settings["autoplace_controls"]["enemy-base"].size == 0 then 
            enemy.active = false
        else
            enemy.active = true
        end

        remote.call('RitnCoreGame', 'set_enemy', enemy)
    end


    if new_seed == true and game.is_multiplayer() then
        -- Change la seed
        map_gen_settings.seed = math.random(1,4294967290)
    end

    remote.call('RitnCoreGame', 'set_map_gen_settings', map_gen_settings)

    return map_gen_settings

end


----------------------------------------------------------------
local flib = {}
----------------------------------------------------------------
flib.tableBusy = tableBusy
flib.saveMapSettings = saveMapSettings
----------------------------------------------------------------
return flib