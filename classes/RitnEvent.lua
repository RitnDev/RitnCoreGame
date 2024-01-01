-- RitnEvent
----------------------------------------------------------------
local class = require(ritnlib.defines.class.core)
local LibEvent = require(ritnlib.defines.class.luaClass.event)
----------------------------------------------------------------
local RitnPlayer = require(ritnlib.defines.core.class.player)
local RitnSurface = require(ritnlib.defines.core.class.surface)
local RitnForce = require(ritnlib.defines.core.class.force)
----------------------------------------------------------------


----------------------------------------------------------------
--- CLASSE DEFINES
----------------------------------------------------------------
local RitnEvent = class.newclass(LibEvent, function(base, event)
    if event == nil then return end
    LibEvent.init(base, event, ritnlib.defines.core.name)
    --------------------------------------------------
    base.prefix_lobby = ritnlib.defines.core.names.prefix.lobby
    --------------------------------------------------
end)

----------------------------------------------------------------

-- Override : getSurface()
function RitnEvent:getSurface()
    return RitnSurface(self.surface)
end


-- Override : getForce()
function RitnEvent:getForce()
    return RitnForce(self.force)
end


-- Override : getPlayer()
function RitnEvent:getPlayer()
    return RitnPlayer(self.player)
end



function RitnEvent:generateLobby()
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



return RitnEvent