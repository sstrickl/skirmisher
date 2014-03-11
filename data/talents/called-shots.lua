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
  type = "cunning/called-shots",
  name = "Called Shots",
  allow_random = true,
  description = "Inflict maximum pain to specific places on your enemies.",
}

local sling_equipped = function(self, silent)
  if not self:hasArcheryWeapon("sling") then
    if not silent then
      game.logPlayer(self, "You must weild a sling!")
    end
    return false
  end
  return true
end

newTalent {
  short_name = "SKIRMISHER_KNEECAPPER",
  name = "Kneecapper",
  type = {"cunning/called-shots", 1},
  require = lowReqGen('cun', 1),
  points = 5,
  no_energy = "fake",
  random_ego = "attack",
  tactical = {ATTACK = {weapon = 1}, DISABLE = 1},
  stamina = 10,
  cooldown = 8,
  requires_target = true,
  range = archery_range,
	on_pre_use = function(self, t, silent) return sling_equipped(self, silent) end,
  pin_duration = function(self, t)
    return math.floor(1 + self:getTalentLevel(t) * 0.2)
  end,
  slow_duration = function(self, t)
    return math.floor(3 + self:getTalentLevel(t) / 3)
  end,
  slow_power = function(self, t)
    return math.min(0.6, 0.1 + self:getCun(1.0, true) * self:combatTalentScale(t, 0.1, 0.5))
  end,
  archery_onhit = function(self, t, target, x, y)
    target:setEffect(target.EFF_SLOW_MOVE, t.slow_duration(self, t), {
                       power = t.slow_power(self, t),
                       apply_power = self:combatAttack()})
    if target:canBe("pin") then
      target:setEffect(target.EFF_PINNED, t.pin_duration(self, t), {
                         apply_power = self:combatAttack()})
    else
      game.logSeen(target, "%s resists being knocked down.", target.name:capitalize())
    end
  end,
  damage_multiplier = function(self, t)
    return self:combatTalentWeaponDamage(t, 1.5, 1.9)
  end,
	action = function(self, t)
		local targets = self:archeryAcquireTargets(nil, {one_shot=true})
		if not targets then return end
		self:archeryShoot(targets, t, nil, {mult = t.damage_multiplier(self, t)})
		return true
	end,
	info = function(self, t)
		return ([[Nail your opponent in the knee for %d%% weapon damage, knocking them down (%d turn pin) and slowing their movement by %d%% for %d turns afterwards.]])
      :format(t.damage_multiplier(self, t) * 100,
              t.pin_duration(self, t),
              t.slow_power(self, t) * 100,
              t.slow_duration(self, t))
	end,
}
