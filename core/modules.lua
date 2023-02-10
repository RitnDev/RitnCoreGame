local modules = {}
------------------------------------------------------------------------------
-- Inclus les events onInit et onLoad + les ajouts de commandes
modules.events = require(ritnlib.defines.core.modules.events)
modules.interfaces = require(ritnlib.defines.core.modules.interfaces)
----
modules.player = require(ritnlib.defines.core.modules.player)
------------------------------------------------------------------------------
return modules