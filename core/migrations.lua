-- MIGRATIONS
------------------------------------------------------------------------

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

-- migration selon la version
local function version(major, minor, patch)
    if major <= 0 then 
        if minor <= 3 then 
            if patch <= 9 then 
                migration_0_3_9()
            else return
            end
        else return
        end
    else return
    end
end

------------------------------------------------------------------------
local migration = {}
------------------------------------------------------------------------
migration.version = version 
------------------------------------------------------------------------
return migration