-- RitnPlayer
----------------------------------------------------------------
local class = require(ritnlib.defines.class.core)
----
local crashSite = require(ritnlib.defines.vanilla.crash_site)
local util = require(ritnlib.defines.vanilla.util)
----
local LibPlayer = require(ritnlib.defines.class.luaClass.player)
local libInventory = require(ritnlib.defines.class.ritnClass.inventory)
----
local seablock = require(ritnlib.defines.core.mods.seablock)
----------------------------------------------------------------
local RitnSurface = require(ritnlib.defines.core.class.surface)
local RitnForce = require(ritnlib.defines.core.class.force)
----------------------------------------------------------------




----------------------------------------------------------------
--- CLASSE DEFINES
----------------------------------------------------------------
local RitnPlayer = class.newclass(LibPlayer, function(base, LuaPlayer)
    if LuaPlayer == nil then return end
    if LuaPlayer.valid == false then return end
    if LuaPlayer.is_player() == false then return end
    if LuaPlayer.object_name ~= "LuaPlayer" then return end
    LibPlayer.init(base, LuaPlayer)
    --------------------------------------------------
    base.data = remote.call('RitnCoreGame', 'get_players')
    base.data_player = remote.call("RitnCoreGame", "get_data", "player")
    base.data_player.name = base.name
    base.data_player.surface = base.surface.name
    base.data_player.force = base.force.name
    ----
    base.gui_action = {}
    base.lobby_name = ritnlib.defines.core.names.prefix.lobby .. base.name
    ----
    base.clear_item = true          -- option    
    --------------------------------------------------
end)
----------------------------------------------------------------



-- Override : getSurface()
function RitnPlayer:getSurface()
    return RitnSurface(self.surface)
end

-- Override : getForce()
function RitnPlayer:getForce()
    return RitnForce(self.force)
end


function RitnPlayer:changeSurface()
    if self.data[self.index] == nil then return self end  
    self.data[self.index].surface = self.surface.name 
    self:update()
    log('> ' .. self.object_name ..':changeSurface() : ' .. self.surface.name)
    return self
end


function RitnPlayer:changeForce()
    if self.data[self.index] == nil then return self end  
    self.data[self.index].force = self.force.name 
    self:update()
    log('> ' .. self.object_name ..':changeForce()')
    return self
end


function RitnPlayer:init()
    if self.data[self.index] ~= nil then return self end 

    self.data[self.index] = self.data_player
    self.data[self.index].connected = self.player.connected

    local nb_players = remote.call('RitnCoreGame', 'get_values', 'players') + 1
    remote.call('RitnCoreGame', 'set_values', 'players', nb_players)

    self:update()

    return self
end




function RitnPlayer:new(teleport)
    log('> '..self.object_name..':new() -> '..self.name)
    if self.data[self.index] ~= nil then return self end 

    self:init()
    self:createLobby(teleport)   

    return self
end


function RitnPlayer:online()
    if self.data[self.index] == nil then return self end 
    log('> '..self.object_name..':online()')
    self.data[self.index].connected = self.player.connected
    self:update()
    return self
end

function RitnPlayer:setOrigine(origine)
    if type(origine) ~= 'string' then return self end
    local surfaces = remote.call("RitnCoreGame", "get_surfaces")
    if surfaces[origine] == nil then return self end
    if self.data[self.index] == nil then return self end 

    log('> '..self.object_name..':setOrigine('..origine..')')

    self.data[self.index].origine = origine
 
    self:update()
    return self
end

-- retourne une position selon l'index joueur
function RitnPlayer:positionTP(pointOrigine)
    local point = 0.0
    if pointOrigine ~= nil then point = pointOrigine end
    point = point + (0.3 * self.index)
    return point
end


-- create surface lobby
function RitnPlayer:createLobby(teleport)
    if script.level.level_name == "freeplay" then
        log('> '..self.object_name..':createLobby(teleport)')

        local goTeleport = true
        if teleport ~= nil then 
            goTeleport = teleport 
            log('> '..self.object_name..':createLobby(teleport) -> teleport = ' .. tostring(goTeleport))
        end

        local LuaSurface = game.surfaces[self.lobby_name]
        local tiles = {}
        
        -- creation de la surface lobby si elle n'existe pas déjà
        if not LuaSurface then LuaSurface = game.create_surface(self.lobby_name) end
        -- préparation de la téléportation
        for x=-1,1 do
            for y=-1,1 do
                table.insert(tiles, {name = "lab-white", position = {x, y}})
            end
        end

        LuaSurface.set_tiles(tiles) 
         
        if goTeleport then 
            self:teleportLobby()
        end
        
    end
end





-- Creation de la surface et force du joueur
function RitnPlayer:createSurface()
    log('> '..self.object_name..':createSurface() -> '..self.name)
  
    --return map_gen_settings
    local map_gen = remote.call("RitnCoreGame", "save_map_settings")

    local LuaSurface = game.create_surface(self.name, map_gen)  
    local tiles = {}
    
    for x=-1,1 do
        for y=-1,1 do
            table.insert(tiles, {name = "lab-white", position = {x, y}})
        end
    end
    
    LuaSurface.set_tiles(tiles)
  
    --seablock options generated map
    if game.active_mods["SeaBlock"] then  
        seablock.startMap(LuaSurface)
    end

    -- init RitnSurface
    RitnSurface(LuaSurface):setAdmin(self.admin):new():setOrigine(self.name)
    self:setOrigine(self.name)

    -- init RitnForce
    log('> '..self.object_name..':createSurface() => RitnForce:create('..self.name..')')
    RitnForce:create(self.name)
    
    -- Teleportation du personnage sur la nouvelle surface
    local origine = self.data[self.index].origine
    self:teleport({0,0}, origine) 
    
    if script.level.level_name ~= "freeplay" then return self end

    --active le site de crash s'il est actif
    if remote.call('freeplay', 'get_disable_crashsite') then
        local surface = game.surfaces[origine]
        surface.daytime = 0.7
        crashSite.create_crash_site(surface, {-5,-6}, nil, util.copy(global.crashed_debris_items), util.copy(global.crashed_ship_parts))
    end

    return self
end


-- set character active if character existe
function RitnPlayer:setActive(value)
    if type(value) ~= "boolean" then return self end 

    if self.player.character then
        self.player.character.active = value
    end

    return self
end



function RitnPlayer:teleport(position, surface, optDecalage, pointOrigine) 
    local option = false
    local decalage = 0.0
    if optDecalage ~= nil then option = optDecalage end
    if option then decalage = self:positionTP(pointOrigine) end

    if position.x and position.y then 
        self.player.teleport({position.x + decalage, position.y + decalage}, surface)
    else
        self.player.teleport({position[1] + decalage, position[2] + decalage}, surface)
    end

    return self
end


function RitnPlayer:teleportLobby()
    self:teleport({0,0}, self.lobby_name)
end



function RitnPlayer:update()
    remote.call("RitnCoreGame", "set_players", self.data) 
end

------------------------------------------------------------
return RitnPlayer