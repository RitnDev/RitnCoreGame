-- MIGRATIONS
------------------------------------------------------------------------
local updates_mod = {
    [0] = {
        [3] = {
            [9] = {}
        }
    }
}


local function migration_0_3_9()
    log('> migration 0.3.9')
    -- mise à jour des index des players déjà présents
    for player_index,_ in pairs(global.core.players) do 
        if game.players[player_index] then 
            log('> player_index: ' .. player_index .. ' -> migrate !')
            global.core.players[player_index].index = game.players[player_index].index
        end
    end
    -- mise à jour des index des surfaces déjà présentes
    for surface_name ,_ in pairs(global.core.surfaces) do 
        if game.surfaces[surface_name] then 
            log('> surface_name: ' .. surface_name .. ' -> migrate !')
            global.core.surfaces[surface_name].index = game.surfaces[surface_name].index
        end
    end
end 


local function migration_0_3_10()
    log('> migration 0.3.10')
    local forces = remote.call("RitnCoreGame", "get_forces")
    for _,force in pairs(forces) do 
        if force.inventories == nil then 
            force.inventories = {}
        end
        log('> force-name: ' .. force.name .. ' -> migrate !')
    end
    remote.call("RitnCoreGame", "set_forces", forces)
end

------------------------------------------------------------------------
local updates_mod = {
    [0] = {
        [3] = {
            [9] = migration_0_3_9,
            [10] = {
                migration_0_3_9,
                migration_0_3_10
            },
        },
        [4] = {
            [0] = {
                migration_0_3_9,
                migration_0_3_10
            },
        }
    }
}
------------------------------------------------------------------------
-- migration selon la version
local function version(major, minor, patch)
    log('>>> MIGRATION RitnCoreGame start !')
    if updates_mod[major] ~= nil then 
        if updates_mod[major][minor] ~= nil then 
            if updates_mod[major][minor][patch] ~= nil then 
                for _, migration in pairs(updates_mod[major][minor][patch]) do 
                    migration()
                end
            end
        end
    end
    log('>>> MIGRATION RitnCoreGame finish !')
end






------------------------------------------------------------------------
local migration = {}
------------------------------------------------------------------------
migration.version = version 
------------------------------------------------------------------------
return migration