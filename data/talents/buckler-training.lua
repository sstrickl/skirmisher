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

newTalentType {
  type = "technique/buckler-training",
  name = "Buckler Training",
  allow_random = true,
  description = "Mastery over their shields separates Skirmishers from Archers, and gives them an edge.",
}

-- this is apparently being overhauled?
newTalent {
  short_name = "SKIRMISHER_BUCKLER_EXPERTISE",
  name = "Buckler Expertise",
  type = {"technique/buckler-training", 1},
  require = lowReqGen('dex', 1),
  points = 5,
  no_unlearn_last = true,
  mode = "passive",
  
  chance = function(self, t)
    return 10 + self:getDex(1.0, true) * self:combatTalentScale(t, 0, 20)
  end,
  -- called by _M:combatArmorHardiness
  getHardiness = function(self, t)
    return self:getTalentLevel(t) * 4;
  end,
  
  onMelee = function(self, t)
    if rng.percent(t.chance(self, t)) and self:hasShield() then
      self:forceUseTalent(self.T_BLOCK, {ignore_cd=true, ignore_energy=true, ignore_ressources=true})
    end
  end,

	info = function(self, t)
    local block = t.chance(self, t)
    local armor = t.getHardiness(self, t)
		return ([[Allows shields to be equipped, regardless of normal stat or talent requirements.
			When you are attacked in melee, you have a %d%% to block, automatically triggering your Block talent. The chance scales with your Dexterity.
			You also gain %d%% Armor Hardiness.]])
      :format(block, armor)
	end,
}
