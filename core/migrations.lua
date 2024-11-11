-- MIGRATIONS
------------------------------------------------------------------------
---
------------------------------------------------------------------------
local updates_mod = {
    [0] = {
        [6] = {
            [0] = {},
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