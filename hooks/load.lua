-- Skirmisher, a class for Tales of Maj'Eyal 1.1.5
-- contact: psy_wombats@wombatrpgs.net
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.


local class = require("engine.class")
local Birther = require("engine.Birther")
local ActorTalents = require "engine.interface.ActorTalents"
local DamageType = require "engine.DamageType"

class:bindHook("ToME:load",
	function(self, data)
		--ActorTalents:loadDefinition("/data-skirmisher/talents.lua")
		Birther:loadDefinition("/data-skirmisher/birth/classes/warrior.lua")
		--DamageType:loadDefinition("/data-skirmisher/new_damage_types.lua")
	end
)


--[[if not config.settings.tome.haunted_npc_classes then
	config.settings.tome.haunted_npc_classes = "yes"
end]]--


-- artifacts and egos
class:bindHook("Entity:loadList", function(self, data)
	--[[if config.settings.tome.haunted_artifacts == 'yes' then
		if data.file == "/data/general/objects/world-artifacts.lua" then
			self:loadList("/data-haunted/artifacts.lua", data.no_default, data.res, data.mod, data.loaded)
		end
	end
	if config.settings.tome.haunted_egos == 'yes' then
		if data.file == "/data/general/objects/egos/gloves.lua" then
			self:loadList("/data-haunted/general/gloves.lua", data.no_default, data.res, data.mod, data.loaded)
		end
		if data.file == "/data/general/objects/egos/rings.lua" then
			self:loadList("/data-haunted/general/rings.lua", data.no_default, data.res, data.mod, data.loaded)
		end
		if data.file == "/data/general/objects/egos/weapon.lua" then
			self:loadList("/data-haunted/general/gloves.lua", data.no_default, data.res, data.mod, data.loaded)
		end
		if data.file == "/data/general/objects/egos/wizard-hat.lua" then
			self:loadList("/data-haunted/general/wizard-hat.lua", data.no_default, data.res, data.mod, data.loaded)
		end
	end]]--
end)


-- game options, urghhh
class:bindHook('GameOptions:tabs', function(self, data)
	data.tab('Skirmisher', function(self)
		local Dialog = require 'engine.ui.Dialog'
		local Textzone = require "engine.ui.Textzone"
		self.list = {}

		local class_zone = Textzone.new {
			width = self.c_desc.w,
			height = self.c_desc.h,
			text = string.toTString [[Allows you to disable some aspects of the Skirmisher class addon.]],
		}

		--[[self.list[#self.list+1] = {
			zone = class_zone,
			name = string.toTString "#GOLD##{bold}#Can NPCs use the Haunted class?#WHITE##{normal}#",
			status = function(item)
				return tostring(config.settings.tome.haunted_npc_classes)
			end,
		
			fct = function(item)
				local cb = function(sel)
					if not sel or not sel.name then return end
					game:saveSettings('config.settings.tome.haunted_npc_classes', ("config.settings.tome.haunted_npc_classes = %q\n"):format(sel.name))
					config.settings.tome.haunted_npc_classes = sel.name
					self.c_list:drawItem(item)
				end
				local entries = { { name='yes' }, { name='no' }, }
				Dialog:listPopup('Change Selection', 'Should the game allow NPCs based on the Haunted class? #GOLD#If you change this option, you will need to restart the game to see it take effect.#LAST#', entries, 300, 200, cb)
			end,
		}
		
		self.list[#self.list+1] = {
			zone = class_zone,
			name = string.toTString "#GOLD##{bold}#Generate egos associated with the Haunted class?#WHITE##{normal}#",
			status = function(item)
				return tostring(config.settings.tome.haunted_npc_classes)
			end,
		
			fct = function(item)
				local cb = function(sel)
					if not sel or not sel.name then return end
					game:saveSettings('config.settings.tome.haunted_egos', ("config.settings.tome.haunted_egos = %q\n"):format(sel.name))
					config.settings.tome.haunted_egos = sel.name
					self.c_list:drawItem(item)
				end
				local entries = { { name='yes' }, { name='no' }, }
				Dialog:listPopup('Change Selection', 'Generate egos associated with the Haunted class? #GOLD#If you change this option, you will need to restart the game to see it take effect.#LAST#', entries, 300, 200, cb)
			end,
		}
		
		self.list[#self.list+1] = {
			zone = class_zone,
			name = string.toTString "#GOLD##{bold}#Generate artifacts associated with the Haunted class?#WHITE##{normal}#",
			status = function(item)
				return tostring(config.settings.tome.haunted_npc_classes)
			end,
		
			fct = function(item)
				local cb = function(sel)
					if not sel or not sel.name then return end
					game:saveSettings('config.settings.tome.haunted_artifacts', ("config.settings.tome.haunted_artifacts = %q\n"):format(sel.name))
					config.settings.tome.haunted_artifacts = sel.name
					self.c_list:drawItem(item)
				end
				local entries = { { name='yes' }, { name='no' }, }
				Dialog:listPopup('Change Selection', 'Generate artifacts associated with the Haunted class? #GOLD#If you change this option, you will need to restart the game to see it take effect.#LAST#', entries, 300, 200, cb)
			end,
		}
		
		self.list[#self.list+1] = {
			zone = class_zone,
			name = string.toTString "#GOLD##{bold}#Remove willpower requirements from Cursed/Cursed Form?#WHITE##{normal}#",
			status = function(item)
				return tostring(config.settings.tome.haunted_remove_reqs)
			end,
		
			fct = function(item)
				local cb = function(sel)
					if not sel or not sel.name then return end
					game:saveSettings('config.settings.tome.haunted_remove_reqs', ("config.settings.tome.haunted_remove_reqs = %q\n"):format(sel.name))
					config.settings.tome.haunted_remove_reqs = sel.name
					self.c_list:drawItem(item)
				end
				local entries = { { name='yes' }, { name='no' }, }
				Dialog:listPopup('Change Selection', 'Remove willpower requirements from Cursed/Cursed Form? #GOLD#If you change this option, you will need to restart the game to see it take effect.#LAST#', entries, 300, 200, cb)
			end,
		}]]--
		
	end)
end)
