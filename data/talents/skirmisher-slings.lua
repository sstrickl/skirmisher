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
  type = "technique/skirmisher-slings",
  name = "Skirmisher - Slings",
  allow_random = true,
  description = "Slings! Pow Pow!",
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

-- Hack in Sling Supremacy to affect reload rate.
local reload = Talents:getTalentFromId("T_RELOAD")
local old_shots_per_turn = reload.shots_per_turn
reload.shots_per_turn = function(self, t)
  local old_spt = old_shots_per_turn(self, t)
  local sling_supremacy = Talents:getTalentFromId("T_SKIRMISHER_SLING_SUPREMACY")
  local new_spt = self:getTalentLevelRaw(t) +
    (self:attr("ammo_reload_speed") or 0) +
    sling_supremacy.reload_bonus(self, sling_supremacy)
  return math.max(old_spt, new_spt)
end

-- Currently just a copy of Sling Mastery.
-- TODO Make unique.
newTalent {
  short_name = "SKIRMISHER_SLING_SUPREMACY",
  name = "Sling Supremacy",
  type = {"technique/skirmisher-slings", 1},
  require = { stat = { dex=function(level) return 12 + level * 6 end }, },
  points = 5,
  mode = "passive",
  reload_bonus = function(self, t)
    local level = self:getTalentLevelRaw(t)
    if level >= 5 then return 3 end
    if level >= 4 then return 2 end
    if level >= 2 then return 1 end
    return 0
  end,
	getDamage = function(self, t) return self:getTalentLevel(t) * 10 end,
	getPercentInc = function(self, t) return math.sqrt(self:getTalentLevel(t) / 5) / 2 end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local inc = t.getPercentInc(self, t)
		return ([[Increases Physical Power by %d and increases weapon damage by %d%% when using slings.
		Also, when using Reload:
		At level 2, it grants one more reload per turn.
		At level 4, it grants two more reloads per turn.
		At level 5, it grants three more reloads per turn.
		]]):
		format(damage, inc * 100)
	end,
}

newTalent {
  short_name = "SKIRMISHER_SWIFT_SHOT",
  name = "Swift Shot",
  type = {"technique/skirmisher-slings", 2},
  require = lowReqGen("dex", 2),
  points = 5,
  no_energy = "fake",
  random_ego = "attack",
  tactical = {ATTACK = {weapon = 2}},
  range = archery_range,
  cooldown = 5,
  stamina = 10,
	on_pre_use = function(self, t, silent) return sling_equipped(self, silent) end,
  getDamage = function(self, t)
    return self:combatTalentWeaponDamage(t, 1.4, 2.4)
  end,
  callbackOnMove = function(self, t, moved, force, ox, oy)
    local cooldown = self.talents_cd[t.id] or 0
    if cooldown > 0 then
      self.talents_cd[t.id] = math.max(cooldown - 1, 0)
    end
  end,
  action = function(self, t)
    local old_speed = self.combat_physspeed
    self.combat_physspeed = old_speed * 2

		local targets = self:archeryAcquireTargets(nil, {one_shot=true})
		if not targets then
      self.combat_physspeed = old_speed
      return
    end

		self:archeryShoot(targets, t, nil, {mult=t.getDamage(self, t)})

    -- Cooldown Hurricane Shot by 1.
    local hurricane_cd = self.talents_cd["T_SKIRMISHER_HURRICANE_SHOT"]
    if hurricane_cd then
      self.talents_cd["T_SKIRMISHER_HURRICANE_SHOT"] = math.max(0, hurricane_cd - 1)
    end

    self.combat_physspeed = old_speed
    return true
  end,
	info = function(self, t)
		return ([[Fire off a quick sling bullet for %d%% damage, at double your normal attack speed. Moving lowers the cooldown by 1.]])
      :format(t.getDamage(self, t) * 100)
	end,
}

newTalent {
  short_name = "SKIRMISHER_HURRICANE_SHOT",
  name = "Hurricane Shot",
  type = {"technique/skirmisher-slings", 3},
  require = lowReqGen("dex", 3),
  points = 5,
  no_energy = "fake",
  random_ego = "attack",
  tactical = {ATTACKALL = {weapon = 3}},
  range = 0,
  radius = archery_range,
  cooldown = 7,
  stamina = 40,
  target = function(self, t)
    return {
      type = "cone",
      range = self:getTalentRange(t),
      radius = self:getTalentRadius(t),
      selffire = false,
      talent = t,
      --cone_angle = 50, -- degrees
    }
  end,
	on_pre_use = function(self, t, silent) return sling_equipped(self, silent) end,
  damage_multiplier = function(self, t)
    return self:combatTalentWeaponDamage(t, 0.8, 1.0)
  end,
  -- Maximum number of shots fired.
  limit_shots = function(self, t)
    return math.floor(2 + self:getTalentLevel(t))
  end,
  action = function(self, t)
    local tg = self:getTalentTarget(t)
    local limit_shots = t.limit_shots(self, t)

    -- Do targeting.
    local old_target_forced = game.target.forced
    local x, y, target = self:getTarget(tg)
    game.target.forced = {x, y, target}

    local params = {mult = t.damage_multiplier(self, t)}

    -- First round of bullets.
    local targets = self:archeryAcquireTargets(tg, {limit_shots = limit_shots})
    if not targets then
      game.target.forced = old_target_forced
      return
    end
    self:archeryShoot(targets, t, nil, params)
    limit_shots = limit_shots - #targets

    -- Second round of bullets.
    local targets = self:archeryAcquireTargets(tg, {limit_shots = limit_shots})
    if not targets then
      game.target_forced = old_target_forced
      return true
    end
    self:archeryShoot(targets, t, nil, params)

    game.target.forced = old_target_forced
    return true
  end,
  info = function(self, t)
    return ([[Take aim and unload %d shots for %d%% weapon damage each against enemies inside a cone. Each enemy can only be targeted two times at most. Using Swift Shot lowers the cooldown by 1.]])
      :format(t.limit_shots(self, t),
              t.damage_multiplier(self, t) * 100)
  end,
}
