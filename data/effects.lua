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

local normalize_direction = function(direction)
  local pi2 = math.pi * 2
  while direction > pi2 do
    direction = direction - pi2
  end
  while direction < 0 do
    direction = direction + pi2
  end
  return direction
end

local in_angle = function(angle, min, max)
  if min <= max then
    return min <= angle and angle <= max
  else
    return min <= angle or angle <= max
  end
end

newEffect {
  name = "SKIRMISHER_DIRECTED_SPEED",
  desc = "Directed Speed",
  type = "physical",
  subtype = {speed = true},
  parameters = {
    -- Movement direction in radians.
    direction = 0,
    -- Allowed deviation from movement direction in radians.
    leniency = math.pi * 0.1,
    -- Movement speed bonus
    move_speed_bonus = 1.00
  },
  status = "beneficial",
  on_lose = function(self, eff) return "#Target# loses speed.", "-Directed Speed" end,
  callbackOnMove = function(self, eff, moved, force, ox, oy)
    local angle_start = normalize_direction(math.atan2(self.y - eff.start_y, self.x - eff.start_x))
    local angle_last = normalize_direction(math.atan2(self.y - eff.last_y, self.x - eff.last_x))
    if ((self.x ~= eff.start_x or self.y ~= eff.start_y) and
          not in_angle(angle_start, eff.min_angle_start, eff.max_angle_start)) or
      ((self.x ~= eff.last_x or self.y ~= eff.last_y) and
         not in_angle(angle_last, eff.min_angle_last, eff.max_angle_last))
    then
      self:removeEffect(self.EFF_SKIRMISHER_DIRECTED_SPEED)
    end
    eff.last_x = self.x
    eff.last_y = self.y
    eff.min_angle_last = normalize_direction(angle_last - eff.leniency_last)
    eff.max_angle_last = normalize_direction(angle_last + eff.leniency_last)
  end,
  activate = function(self, eff)
    self:effectTemporaryValue(eff, "movement_speed", eff.move_speed_bonus)
    eff.leniency_last = math.max(math.pi * 0.25, eff.leniency)

    eff.start_x = self.x
    eff.start_y = self.y
    eff.min_angle_start = normalize_direction(eff.direction - eff.leniency)
    eff.max_angle_start = normalize_direction(eff.direction + eff.leniency)
    eff.last_x = self.x
    eff.last_y = self.y
    eff.min_angle_last = normalize_direction(eff.direction - eff.leniency_last)
    eff.max_angle_last = normalize_direction(eff.direction + eff.leniency_last)

    -- AI won't use talents while active.
    if self.ai_state then
      self:effectTemporaryValue(eff, "ai_state", {no_talents=1})
    end
  end,
  long_desc = function(self, eff)
    return ([[Target is currently moving with %d%% in a single direction. Stopping or changing directions will remove this effect.]])
      :format(eff.move_speed_bonus * 100)
  end,
}

-- If they don't have stun, stun them. If they do, increase its
-- duration.
newEffect {
  name = "SKIRMISHER_STUN_INCREASE",
  desc = "Stun Lengthen",
  type = "physical",
  subtype = {stun = true},
  status = "detrimental",
  on_gain = function(self, eff)
    local stun = self:hasEffect(self.EFF_STUNNED)
    if stun and stun.dur and stun.dur > 1 then
      return ("#Target# is stunned further! (now %d turns)"):format(stun.dur), "Stun Lengthened"
    end
  end,
  activate = function(self, eff)
    local stun = self:hasEffect(self.EFF_STUNNED)
    if stun then
      stun.dur = stun.dur + eff.dur
    else
      self:setEffect(self.EFF_STUNNED, eff.dur, {})
    end
    self:removeEffect(self.EFF_SKIRMISHER_STUN_INCREASE)
  end,
}

newEffect {
  name = "SKIRMISHER_ETERNAL_WARRIOR",
  desc = "Eternal Warrior",
  image = "talents/skirmisher_the_eternal_warrior.png",
  type = "mental",
	subtype = { morale=true },
	status = "beneficial",
  parameters = {
    -- Resist all increase
    res=.5,
    -- Resist caps increase
    cap=.5,
    -- Maximum stacking applications
    max=5 },
  on_gain = function(self, err) return nil, "+Eternal Warrior" end,
  on_lose = function(self, err) return nil, "-Eternal Warrior" end,

	long_desc = function(self, eff)
    return ("The target stands strong, increasing all resistances %0.1f%% and resistance caps by %0.1f%%."):
      format(eff.res, eff.cap)
  end,
  activate = function(self, eff)
    eff.res_id = self:addTemporaryValue("resists", {all = eff.res})
    eff.cap_id = self:addTemporaryValue("resists_cap", {all = eff.cap})
  end,
  on_merge = function(self, old_eff, new_eff)
    self:removeTemporaryValue("resists", old_eff.res_id)
		self:removeTemporaryValue("resists_cap", old_eff.cap_id)
    new_eff.res = math.min(new_eff.res + old_eff.res, new_eff.res * new_eff.max)
    new_eff.cap = math.min(new_eff.cap + old_eff.cap, new_eff.cap * new_eff.max)
    new_eff.res_id = self:addTemporaryValue("resists", {all = new_eff.res})
    new_eff.cap_id = self:addTemporaryValue("resists_cap", {all = new_eff.cap})
    return new_eff
  end,
  deactivate = function(self, eff)
    self:removeTemporaryValue("resists", eff.res_id)
    self:removeTemporaryValue("resists_cap", eff.cap_id)
  end,
}

newEffect {
  name = "SKIRMISHER_TACTICAL_POSITION",
  desc = "Tactical Position",
  type = "physical",
	subtype = {tactic = true},
	status = "beneficial",
  parameters = {combat_physcrit = 10},
  long_desc = function(self, eff)
    return ([[The target has relocated to a favorable position, giving them +%d%% physical critical chance.]])
      :format(eff.combat_physcrit)
  end,
  on_gain = function(self, eff) return "#Target# is poised to strike!" end,
  activate = function(self, eff)
    self:effectTemporaryValue(eff, "combat_physcrit", eff.combat_physcrit)
  end,
}
