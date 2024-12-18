-- MODULE : SURFACE
---------------------------------------------------------------------------------------------


-- Si la map créée est un lobby alors on doit là cacher à toute les forces
local function on_surface_created(e)
    local rEvent = RitnCoreEvent(e)
    local rSurface = RitnCoreSurface(rEvent.surface)
    -- la surface est bien de type "lobby"
    if rSurface.isLobby then 
        for _,force in pairs(game.forces) do 
            log('> force.name: '.. force.name .. ' -> hidden surface: '.. rSurface.name)
            force.set_surface_hidden(rSurface.name, true)
        end
    end
    log('on_surface_created')
end


---------------------------------------------------------------------------------------------
local module = {events = {}}
---------------------------------------------------------------------------------------------
-- Events Surface
module.events[defines.events.on_surface_created] = on_surface_created
---------------------------------------------------------------------------------------------
return module