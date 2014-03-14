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
  type = "technique/tireless-combatant",
  name = "Tireless Combatant",
  allow_random = true,
  description = "Your will carries you through the most difficult struggles, allowing you to fight on when others would have collapsed from exhaustion.",
}

newTalent {
  short_name = "SKIRMISHER_BREATHING_ROOM",
  name = "Breathing Room",
  type = {"technique/tireless-combatant", 1},
  require = lowReqGen("wil", 1),
  mode = "passive",
  points = 5,
  
  getRestoreRate = function(self, t)
    return 1.5 * self:getTalentLevel(t)
  end,
  callbackOnAct = function(self, t)
    
    -- Remove the existing regen rate
    if self.temp_skirmisherBreathingStamina then
      self:removeTemporaryValue("stamina_regen", self.temp_skirmisherBreathingStamina)
    end
    if self.temp_skirmisherBreathingLife then
      self:removeTemporaryValue("life_regen", self.temp_skirmisherBreathingLife)
    end
    self.temp_skirmisherBreathingStamina = nil
    self.temp_skirmisherBreathingLife = nil

    -- Calculate surrounding enemies
    local nb_foes = 0
    local act
    for i = 1, #self.fov.actors_dist do
      act = self.fov.actors_dist[i]
      -- Possible bug with this formula, copied from cunning/tactical
      if act and game.level:hasEntity(act) and self:reactionToward(act) < 0 and self:canSee(act) and act["__sqdist"] <= 2 then nb_foes = nb_foes + 1 end
    end
    
    -- Add new regens if needed
    if nb_foes == 0 then
      self.temp_skirmisherBreathingStamina = self:addTemporaryValue("stamina_regen", t.getRestoreRate(self, t))
      if self:getTalentLevel(t) >= 3 then
        self.temp_skirmisherBreathingLife = self:addTemporaryValue("life_regen", t.getRestoreRate(self, t))
      end
    end
    
  end,
  
  info = function(self, t)
    local stamina = t.getRestoreRate(self, t)
    return ([[Any time you do not have an opponent in a square adjacent to you, you gain %0.1f Stamina regen. At talent level 3 you also gain an equal amount of life regen when Breathing Room is active.]])
      :format(stamina)
  end,
}

newTalent {
  short_name = "SKIRMISHER_PACE_YOURSELF",
  name = "Pace Yourself",
  type = {"technique/tireless-combatant", 2},
  mode = "sustained",
  points = 5,
  cooldown = 10,
  sustain_stamina = 0,
  no_energy = true,
  require = lowReqGen("wil", 2),
  tactical = { STAMINA = 2 },
  random_ego = "utility",
  
  activate = function(self, t)
    return {
      speed = self:addTemporaryValue("global_speed_add", -t.getSlow(self, t)),
    }
  end,
  deactivate = function(self, t, p)
    self:removeTemporaryValue("global_speed_add", p.speed)
    return true
  end,
  getSlow = function(self, t)
    return .125 - self:getTalentLevelRaw(t) * .025
  end,
  getReduction = function(self, t)
    return self:combatTalentScale(t, 15, 40)
  end,
  
  info = function(self, t)
    local slow = t.getSlow(self, t) * 100
    local reduction = t.getReduction(self, t)
    return ([[Control your movements to conserve your energy. While Pace Yourself is activated you are globally slowed by %0.1f%%, but receive a %0.1f%% discount on all Stamina based abilities.]])
      :format(slow, reduction)
  end,
}

newTalent {
  short_name = "SKIRMISHER_DAUNTLESS_CHALLENGER",
  name = "Dauntless Challenger",
  type = {"technique/tireless-combatant", 3},
  require = lowReqGen("wil", 3),
  mode = "passive",
  points = 5,
  
  getStaminaRate = function(self, t)
    return .5 * self:getTalentLevel(t)
  end,
  getLifeRate = function(self, t)
    return 1 * self:getTalentLevel(t)
  end,
  callbackOnAct = function(self, t)
    
    -- Remove the existing regen rate
    if self.temp_skirmisherDauntlessStamina then
      self:removeTemporaryValue("stamina_regen", self.temp_skirmisherDauntlessStamina)
    end
    if self.temp_skirmisherDauntlessLife then
      self:removeTemporaryValue("life_regen", self.temp_skirmisherDauntlessLife)
    end
    self.temp_skirmisherDauntlessStamina = nil
    self.temp_skirmisherDauntlessLife = nil

    -- Calculate visible enemies
		local nb_foes = 0
		local act
		for i = 1, #self.fov.actors_dist do
			act = self.fov.actors_dist[i]
			if act and self:reactionToward(act) < 0 and self:canSee(act) then nb_foes = nb_foes + 1 end
		end
    
    -- Add new regens if needed
    if nb_foes >= 1 then
      if nb_foes > 4 then nb_foes = 4 end
      self.temp_skirmisherDauntlessStamina = self:addTemporaryValue("stamina_regen", t.getStaminaRate(self, t) * nb_foes)
      if self:getTalentLevel(t) >= 3 then
        self.temp_skirmisherDauntlessLife = self:addTemporaryValue("life_regen", t.getLifeRate(self, t) * nb_foes)
      end
    end
    
  end,
  
  info = function(self, t)
    local stamina = t.getStaminaRate(self, t)
    local health = t.getLifeRate(self, t)
    return ([[When the going gets tough, you get tougher. You gain %0.1f Stamina regen per enemy in sight, and beginning at talent level 3, you also gain %0.1f life regen per enemy. The bonuses cap at 4 enemies.]])
      :format(stamina, health)
  end,
}