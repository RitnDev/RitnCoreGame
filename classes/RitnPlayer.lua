-- RitnCorePlayer
----------------------------------------------------------------
local crashSite = require(ritnlib.defines.vanilla.crash_site)
local util = require(ritnlib.defines.vanilla.util)
local string = require(ritnlib.defines.string)
local flib = require(ritnlib.defines.other)
----------------------------------------------------------------
local seablock = require(ritnlib.defines.core.mods.seablock)
----------------------------------------------------------------
--- CLASSE DEFINES
----------------------------------------------------------------
RitnCorePlayer = ritnlib.classFactory.newclass(RitnLibPlayer, function(self, LuaPlayer)
    RitnLibPlayer.init(self, LuaPlayer)
    --------------------------------------------------
    self.data = remote.call('RitnCoreGame', 'get_players')
    self.data_player = remote.call("RitnCoreGame", "get_data", "player")
    self.data_player.index = self.index
    self.data_player.name = self.name
    self.data_player.surface = self.surface.name
    self.data_player.force = self.force.name
    ----
    self.gui_action = {}
    self.lobby_name = ritnlib.defines.core.names.prefix.lobby .. self.name
    ----
    self.clear_item = true          -- option    
    --------------------------------------------------
end)
----------------------------------------------------------------



-- Override : getSurface()
function RitnCorePlayer:getSurface()
    return RitnCoreSurface(self.surface)
end

-- Override : getForce()
function RitnCorePlayer:getForce()
    return RitnCoreForce(self.force)
end


function RitnCorePlayer:changeSurface()
    if self.data[self.index] == nil then return self end  
    self.data[self.index].surface = self.surface.name 
    self:update()
    log('> ' .. self.object_name ..':changeSurface() : ' .. self.surface.name)
    return self
end


function RitnCorePlayer:changeForce()
    if self.data[self.index] == nil then return self end  
    self.data[self.index].force = self.force.name 
    self:update()
    log('> ' .. self.object_name ..':changeForce()')
    return self
end


function RitnCorePlayer:init()
    if self.data[self.index] ~= nil then return self end 

    self.data[self.index] = self.data_player
    self.data[self.index].connected = self.player.connected

    local nb_players = remote.call('RitnCoreGame', 'get_values', 'players') + 1
    remote.call('RitnCoreGame', 'set_values', 'players', nb_players)

    self:update()

    return self
end




function RitnCorePlayer:new(teleport)
    log('> '..self.object_name..':new() -> '..self.name)
    if self.data[self.index] ~= nil then return self end 

    self:init()
    self:createLobby(teleport)   

    return self
end


function RitnCorePlayer:online()
    if self.data[self.index] == nil then return self end 
    log('> '..self.object_name..':online()')
    self.data[self.index].connected = self.player.connected
    self:update()
    return self
end

function RitnCorePlayer:setOrigine(origine)
    if type(origine) ~= 'string' then return self end
    local surfaces = remote.call("RitnCoreGame", "get_surfaces")
    if surfaces[origine] == nil then return self end
    if self.data[self.index] == nil then return self end 

    log('> '..self.object_name..':setOrigine('..origine..')')

    self.data[self.index].origine = origine
 
    self:update()
    return self
end


-- Retourne la map d'origine
function RitnCorePlayer:getOrigine()
    if self.data[self.index] == nil then return "" end 
    log('> '..self.object_name..':getOrigine() -> ' .. tostring(self.data[self.index].origine))
    return self.data[self.index].origine 
end


-- Est ce que le joueur est propriétaire de sa map d'origine ?
function RitnCorePlayer:isOwner()
    if self.data[self.index] == nil then return false end
    log('> '..self.object_name..':isOwner()')
    local origine = string.defaultValue(self.data[self.index].origine)
    local player_name = string.defaultValue(self.data[self.index].name)
  
    return flib.ifElse(string.isEmptyString(origine) or string.isEmptyString(player_name), false, (origine == player_name))
end



-- retourne une position selon l'index joueur
function RitnCorePlayer:positionTP(pointOrigine)
    local point = 0.0
    if pointOrigine ~= nil then point = pointOrigine end
    point = point + (0.3 * self.index)
    return point
end


-- create surface lobby
function RitnCorePlayer:createLobby(teleport)
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
function RitnCorePlayer:createSurface()
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

    -- init RitnCoreSurface
    RitnCoreSurface(LuaSurface):setAdmin(self.admin):new():setOrigine(self.name)
    self:setOrigine(self.name)

    -- init RitnCoreForce
    log('> '..self.object_name..':createSurface() => RitnForce:create('..self.name..')')
    RitnCoreForce:create(self.name)
    
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
function RitnCorePlayer:setActive(value)
    if type(value) ~= "boolean" then return self end 

    if self.player.character then
        self.player.character.active = value
    end

    return self
end



function RitnCorePlayer:teleport(position, surface, optDecalage, pointOrigine) 
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


function RitnCorePlayer:teleportLobby()
    self:teleport({0,0}, self.lobby_name)
end



function RitnCorePlayer:update()
    remote.call("RitnCoreGame", "set_players", self.data) 
end

------------------------------------------------------------
--return RitnCorePlayer