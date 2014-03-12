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

newTalent {
  short_name = "SKIRMISHER_BUCKLER_EXPERTISE",
  name = "Buckler Expertise",
  type = {"technique/buckler-training", 1},
  require = lowReqGen('dex', 1),
  points = 5,
  no_unlearn_last = true,
  mode = "passive",
  
  chance = function(self, t)
    return util.bound(self:getTalentLevel(t)*5, 0, 40);
  end,
  -- called by _M:combatArmorHardiness
  getHardiness = function(self, t)
    return 0 --self:getTalentLevel(t) * 4;
  end,
  
  shouldEvade = function(self, t)
    return rng.percent(t.chance(self, t)) and self:hasShield() and not self:hasHeavyArmor()
  end,

	info = function(self, t)
    local block = t.chance(self, t)
    local armor = t.getHardiness(self, t)
		return ([[Allows shields to be equipped, regardless of normal stat or talent requirements.
			When you are attacked in melee, you have a %d%% chance to deflect the attack with your shield, completely evading it.]])
      :format(block, armor)
	end,
}

newTalent{
  short_name = "SKIRMISHER_BASH_AND_SMASH",
  name = "Bash and Smash",
  type = {"technique/buckler-training", 2},
  require = lowReqGen('dex', 2),
  points = 5,
  random_ego = "attack",
  cooldown = 8,
  stamina = 15,
	requires_target = true,
  tactical = { ATTACK = 2, ESCAPE = { knockback = 1 }, DISABLE = { knockback = 1 } },
  
  on_pre_use = function(self, t, silent)
    if not self:hasShield() or not self:hasArcheryWeapon() then
      if not silent then game.logPlayer(self, "You require a ranged weapon and a shield to use this talent.") end
      return false
    end
    return true
  end,
  
  getDist = function(self, t)
    if self:getTalentLevel(t) >= 3 then
      return 3
    else
      return 2
    end
  end,
  getShieldMult = function(self, t)
    return self:combatTalentWeaponDamage(t, 1, 2)
  end,
  getSlingMult = function(self, t)
    return self:combatTalentWeaponDamage(t, 1.5, 3)
  end,
  
  action = function(self, t)
    local shield = self:hasShield()
    local sling = self:hasArcheryWeapon()
    if not shield or not sling then
      game.logPlayer(self, "You require a ranged weapon and a shield to use this talent.")
      return nil
    end

    local tg = {type="hit", range=self:getTalentRange(t)}
    local x, y, target = self:getTarget(tg)
    if not x or not y or not target then return nil end
    if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

    -- First attack with shield
    local speed, hit = self:attackTargetWith(target, shield.special_combat, nil, t.getShieldMult(self, t))
    -- At talent levels >= 5, attack twice
    if self:getTalentLevel(t) >= 5 then
      local speed, hit = self:attackTargetWith(target, shield.special_combat, nil, t.getShieldMult(self, t))
    end

		-- Knockback
		if hit then
      if target:canBe("knockback") then
        local dist = t.getDist(self, t)
        target:knockback(self.x, self.y, dist)
			else
        game.logSeen(target, "%s resists the knockback!", target.name:capitalize())
      end
    end
    
    -- Ranged attack
    local targets = self:archeryAcquireTargets(nil, {one_shot=true, x=target.x, y=target.y})
    if targets then
      --game.logSeen(self, "%s follows up with a shot from %s!", self.name:capitalize(), sling:getName())
      self:archeryShoot(targets, t, nil, {mult=t.getSlingMult(self, t)})
    end

    return true
	end,
  info = function(self, t)
    local shieldMult = t.getShieldMult(self, t) * 100
    local tiles = t.getDist(self, t)
    local slingMult = t.getSlingMult(self, t) * 100
    return ([[Bash an enemy in melee range with your shield, doing %d%% damage and knocking back %d squares. You follow with a deadly short-range sling attack, dealing %d%% damage.
		At talent level 5, you will strike with your shield twice.]])
		:format(shieldMult, tiles, slingMult)
	end,
}
