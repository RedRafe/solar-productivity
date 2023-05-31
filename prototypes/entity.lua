local SP    = require "prototypes.shared"
local sutil = require "prototypes.string-util"

-- ============================================================================

---@param prototype_name string
local function make_solar_panel_variations(prototype_name)
  if not prototype_name or not data.raw["solar-panel"][prototype_name] or not data.raw["solar-panel"][prototype_name].production then 
    log("SP: invalid SolarPanelPrototype")
    return
  end
  
  local base = data.raw["solar-panel"][prototype_name]
  local bonus = 1
  local max_bonus = #SP.BONUS
  
  for level = 1, SP.LEVELS do
    bonus = bonus + SP.BONUS[math.min(level, max_bonus)]
    local prototype = table.deepcopy(base)
    
    prototype.name            = SP.ENTITY..tostring(level).."-"..base.name
    prototype.localised_name  = {"entity-name."..base.name}
    prototype.placeable_by    = { item = base.name, count = 1 }
    prototype.production      = sutil.msv(base.production, bonus)
    
    data:extend({prototype})
  end
end

-- ============================================================================

---@param prototype_name string
local function make_accumulator_variations(prototype_name)
  if not prototype_name or not data.raw["accumulator"][prototype_name] or not data.raw["accumulator"][prototype_name].energy_source  then 
    log("SP: invalid AccumulatorPrototype")
    return
  end
  
  local base = table.deepcopy(data.raw["accumulator"][prototype_name])
  local bes = base.energy_source
  local bonus = 1
  local max_bonus = #SP.BONUS
  
  for level = 1, SP.LEVELS do
    bonus = bonus + SP.BONUS[math.min(level, max_bonus)]
    local prototype = table.deepcopy(base)
    
    prototype.name            = SP.ENTITY..tostring(level).."-"..base.name
    prototype.localised_name  = {"entity-name."..base.name}
    prototype.placeable_by    = { item = base.name, count = 1 }
    prototype.energy_source   = {
      type                    = bes.type,
      buffer_capacity         = sutil.msv(bes.buffer_capacity, bonus),
      usage_priority          = bes.usage_priority,
      input_flow_limit        = sutil.msv(bes.input_flow_limit, bonus),
      output_flow_limit       = sutil.msv(bes.output_flow_limit, bonus),
      render_no_power_icon    = bes.render_no_power_icon
    }
    
    data:extend({prototype})
  end
end

-- ============================================================================

for ___, preset in pairs(SP.COMPATIBILITY_LIST) do
  if mods[preset.mod] then
    for ___, solar in pairs(preset.solar_panels) do
      make_solar_panel_variations(solar)
    end
    for ___, accu in pairs(preset.accumulators) do
      make_accumulator_variations(accu)
    end
  end
end
