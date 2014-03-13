-- Skirmisher, a class for Tales of Maj'Eyal 1.1.5
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

newBirthDescriptor{
  type = "subclass",
  name = "Skirmisher",
  desc = {
    "While able to take maximum advantage of their Sling by using deft movements to avoid and confuse enemies that try to get close, the Skirmisher truly excels when fighting other ranged users.",
    "They have mastered the use of their Shield as well as their Sling and are nearly impossible to defeat in a standoff.",
    "Their most important stats are: Dexterity and Cunning",
    "#GOLD#Stat modifiers:",
    "#LIGHT_BLUE# * +0 Strength, +4 Dexterity, +0 Constitution",
    "#LIGHT_BLUE# * +0 Magic, +1 Willpower, +4 Cunning",
    "#GOLD#Life per level:#LIGHT_BLUE# +0",
  },
  power_source = {technique=true},
  stats = {dex = 4, cun = 4, wil = 1},
  talents_types = {

    -- class
    ["technique/skirmisher-slings"]={true, 0.3},
    ["technique/buckler-training"]={true, 0.3},
    ["cunning/called-shots"]={true, 0.3},
    ["cunning/trapping"]={false, 0.1},

    -- generic
    ["technique/acrobatics"]={true, 0.3},
    ["cunning/survival"]={true, 0.3},
    ["technique/combat-training"]={true, 0.3},
    ["technique/field-control"]={false, 0.1},

  },
  unlockable_talents_types = {
    ["cunning/poisons"]={false, 0.2, "rogue_poisons"},
  },
  talents = {
    [ActorTalents.T_WEAPON_COMBAT] = 1,
    [ActorTalents.T_SHOOT] = 1,
    [ActorTalents.T_SKIRMISHER_SLING_SUPREMACY] = 1,
    [ActorTalents.T_SKIRMISHER_KNEECAPPER] = 1,
    [ActorTalents.T_SKIRMISHER_BASH_AND_SMASH] = 1,
  },
  copy = {
    resolvers.equip{
      id=true,
      {type="armor", subtype="light", name="rough leather armour", autoreq=true,ego_chance=-1000},
      {type="weapon", subtype="sling", name="rough leather sling", autoreq=true, ego_chance=-1000},
      {type="ammo", subtype="shot", name="pouch of iron shots", autoreq=true, ego_chance=-1000},
    },
  },
  copy_add = {
    life_rating = 0,
  },
}

-- Add to warrior
getBirthDescriptor("class", "Warrior").descriptor_choices.subclass.Skirmisher = "allow"
