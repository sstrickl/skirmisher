_M = loadPrevious(...)

-- Directed Speed will be cancelled by non-movement actions.
local breakStepUp = _M.breakStepUp
function _M:breakStepUp()
  breakStepUp(self)
  if self:hasEffect(self.EFF_SKIRMISHER_DIRECTED_SPEED) then
    self:removeEffect(self.EFF_SKIRMISHER_DIRECTED_SPEED)
  end
end

return _M
