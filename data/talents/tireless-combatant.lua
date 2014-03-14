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
  callbackOnAct = function(self, t, moved, force, ox, oy)
    
    -- Remove the existing regen rate
    if t.staminaID then
      self:removeTemporaryValue("stamina_regen", t.staminaID)
    end
    if t.lifeID then
      self:removeTemporaryValue("life_regen", t.lifeID)
    end
    t.staminaID = nil
    t.lifeID = nil

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
      t.staminaID = self:addTemporaryValue("stamina_regen", t.getRestoreRate(self, t))
      if self:getTalentLevel(t) >= 3 then
        t.lifeID = self:addTemporaryValue("life_regen", t.getRestoreRate(self, t))
      end
    end
    
  end,
  
  info = function(self, t)
    local stamina = t.getRestoreRate(self, t)
    return ([[Any time you do not have an opponent in a square adjacent to you, you restore %0.1f Stamina at start of your turn. At rank 3 you also restore an equal amount of health any time Breathing Room activates.]])
      :format(stamina)
  end,
}
