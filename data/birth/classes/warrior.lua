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

local Particles = require "engine.Particles"

newBirthDescriptor{
	type = "subclass",
	name = "Skirmisher",
	desc = {
		"Skirmisher fluff",
		"Skirmisher fluff",
		"Their most important stats are: Strength and Cunning",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +5 Strength, +0 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +0 Magic, +0 Willpower, +4 Cunning",
		"#GOLD#Life per level:#LIGHT_BLUE# +2",
	},
	--power_source = {psionic=true, technique=true},
	random_rarity = 3,
	--not_on_random_boss = ("no" == config.settings.tome.haunted_npc_classes),
	--[[birth_example_particles = {
		function(actor)
			if not actor:addShaderAura("entrancing", "awesomeaura", {time_factor=8000, alpha=0.5}, "particles_images/purple.png") then
				actor:addParticles(Particles.new("entrancing", 1))
			end
		end,
	},]]--
	stats = { str=5, cun=4 },
	talents_types = {
   
		-- class
		["technique/grappling"]={true, 0.3},

		-- generics
		["technique/combat-training"]={true, 0.1},

	},

	talents = {

	},
	copy = {
		resolvers.equip{ id=true,
			--{type="armor", subtype="heavy", name="iron mail armour", autoreq=true, ego_chance=-1000, ego_chance=-1000},
		},
	},
	copy_add = {
		life_rating = 2,
	},
}

-- add to base class
getBirthDescriptor("class","Warrior").descriptor_choices.subclass.Skirmisher = "allow"
