-- RitnCoreEvent
----------------------------------------------------------------
local string = require(ritnlib.defines.string)
----------------------------------------------------------------
--- CLASSE DEFINES
----------------------------------------------------------------
RitnCoreEvent = ritnlib.classFactory.newclass(RitnLibEvent, function(self, event)
    RitnLibEvent.init(self, event, ritnlib.defines.core.name)
    log(string.defaultValue(self.object_name, "titi"))
    log(string.defaultValue(self.name, "tata"))
    --------------------------------------------------
    self.prefix_lobby = ritnlib.defines.core.names.prefix.lobby
    self.FORCE_DEFAULT_NAME = ritnlib.defines.core.names.force_default
    --------------------------------------------------
end)

----------------------------------------------------------------

-- Override : getSurface()
function RitnCoreEvent:getSurface()
    return RitnCoreSurface(self.surface)
end


-- Override : getForce()
function RitnCoreEvent:getForce()
    return RitnCoreForce(self.force)
end


-- Override : getPlayer()
function RitnCoreEvent:getPlayer()
    return RitnCorePlayer(self.player)
end



function RitnCoreEvent:generateLobby()
    local tv = {}
    local tab_tiles = {}
    local tx
    local base_tile = 1

    -- seulement si la map commence par : "lobby~"
    if string.sub(self.surface.name,1,6) == self.prefix_lobby then 
  
        for x = self.area.left_top.x, self.area.right_bottom.x do 
            for y= self.area.left_top.y, self.area.right_bottom.y do
                if((x>-2 and x<1) and (y>-2 and y<1))then
                    tx = tx or {} table.insert(tx, {name="refined-concrete", position={x,y}} )
                else
                    local tile="out-of-map"
                    table.insert(tab_tiles, { name = tile, position = {x, y}}) tv[x]=tv[x] or {} tv[x][y] = true
                end
            end
        end
    
        self.surface.destroy_decoratives{area = self.area}
        if tx then self.surface.set_tiles(tx) end
        self.surface.set_tiles(tab_tiles)
        --delete all entities (not character)
        for k,v in pairs(self.surface.find_entities_filtered{type = "character", invert = true, area=self.area}) do v.destroy{raise_destroy = true} end
    end
end



-- Créé une équipe enemy associé pour la surface : "enemy~"..SURFACE_NAME
function RitnCoreEvent:createForceDefault()
    log('> '..string.defaultValue(self.object_name, "RitnCoreEvent")..':createForceDefault() -> '..string.defaultValue(self.name))

    -- Création d'une force par défaut "ritn~default" si elle n'existe pas déjà
    if RitnCoreForce.exists(self.FORCE_DEFAULT_NAME) == false then
        log('> Create force : ' .. self.FORCE_DEFAULT_NAME)
        local LuaForce = game.create_force(self.FORCE_DEFAULT_NAME)
        LuaForce.reset()
        LuaForce.reset_evolution()

        -- On désactive toute les recettes
        for _,recipe in pairs(LuaForce.recipes) do
            if recipe.enabled then
                recipe.enabled = false
            end
        end

        -- on implémente la nouvelle sur la donnée RitnCoreEvent
        self.force = LuaForce
    end

    return self
end



--return RitnCoreEvent