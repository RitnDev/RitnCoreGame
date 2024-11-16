-- MIGRATIONS
------------------------------------------------------------------------

local function migration_0_6_1()

    -- update players on RitnCoreGame
    local players = remote.call("RitnCoreGame", "get_players")
    for _,player in pairs(players) do 
        player.object_name = "RitnDataPlayer"
    end
    remote.call("RitnCoreGame", "set_players", players)

    -- update surfaces on RitnCoreGame
    local surfaces = remote.call("RitnCoreGame", "get_surfaces")
    for _,surface in pairs(surfaces) do 
        surface.object_name = "RitnDataSurface"
    end
    remote.call("RitnCoreGame", "set_surfaces", surfaces)

    -- update forces on RitnCoreGame
    local forces = remote.call("RitnCoreGame", "get_forces")
    for _,force in pairs(forces) do 
        force.object_name = "RitnDataForce"
    end
    remote.call("RitnCoreGame", "set_forces", forces)
end


------------------------------------------------------------------------
local updates_mod = {
    [0] = {
        [6] = {
            [0] = {},
            [1] = {
                migration_0_6_1
            }
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