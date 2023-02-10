---------------------------------------------------------------------------------------------
-- EVENTS
---------------------------------------------------------------------------------------------
local RitnSurface = require(ritnlib.defines.core.class.surface)
---------------------------------------------------------------------------------------------
local events = {}
---------------------------------------------------------------------------------------------

function events.on_init(event)
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
------------------------------------------------------------------------------------------------------------
return events