local SOL_PROD = {}

local SU = require "prototypes.string-util"

-- Max number of levels for technology & prototypes
SOL_PROD.LEVELS = 50

-- Bonus for each level
SOL_PROD.BONUS = {
  [1] = 0.40,
  [2] = 0.30,
  [3] = 0.20,
  [4] = 0.15
}

SOL_PROD.compatibility_list = require "prototypes.compatibility"

SOL_PROD.DB = {}

local function getUpgradeLevel(force)
  if force.technologies["solar-productivity-4"].researched == true then
    return force.technologies["solar-productivity-4"].level
  end
  for n = 3, 1, -1 do
    if force.technologies["solar-productivity-"..n].researched == true then
      return n
    end
  end
  return 0
end

local function getUpgradedPrototype(name, level)
  if not SOL_PROD.DB[name] then return name end

  local base = SOL_PROD.DB[name]
  local upgrade = "sp-"..tostring(level).."-"..base
  
  if SOL_PROD.DB[upgrade] == base then 
    return upgrade 
  else 
    return name
  end
end

local function replace_prototype(old)
  if not old or not old.valid then return end

  local old_name = old.name
  if not SOL_PROD.DB[old_name] then return end

  local force = old.force
  local level = getUpgradeLevel(force)
  if level == 0 then return end

  local new_name = getUpgradedPrototype(old_name, level)
  if old_name == new_name then return end

  local surface  = old.surface
  local position = old.position
  local player   = old.last_user
  local damage   = old.prototype.max_health - old.health

  old.destroy()

  local new = surface.create_entity({
    name = new_name,
    position = position,
    force = force,
    player = player,
    create_build_effect_smoke = false,
    raise_built = true,
  })

  if new and new.valid and damage > 0 then
    new.damage(damage, game.forces.neutral)
  end
end

function SOL_PROD.make_solar_panel_variations(prototype_name)
  if not prototype_name or not data.raw["solar-panel"][prototype_name] or not data.raw["solar-panel"][prototype_name].production then 
    log("SP: invalid SolarPanelPrototype")
    return
  end

  SOL_PROD.DB[prototype_name] = prototype_name
  
  local base = data.raw["solar-panel"][prototype_name]
  local bonus = 1
  local max_bonus = #SOL_PROD.BONUS
  
  for level = 1, SOL_PROD.LEVELS do
    local prototype = table.deepcopy(base)
    bonus = bonus + SOL_PROD.BONUS[math.min(level, max_bonus)]
    prototype.name = "sp-"..tostring(level).."-"..base.name
    prototype.localised_name = {"item-name."..base.name}
    prototype.placeable_by = { item = base.name, count = 1 }
    prototype.production = SU.msv(base.production, bonus)
    data:extend({prototype})
    SOL_PROD.DB[prototype.name] = prototype_name
  end
end

function SOL_PROD.make_accumulator_variations(prototype_name)
  if not prototype_name or not data.raw["accumulator"][prototype_name] or not data.raw["accumulator"][prototype_name].energy_source  then 
    log("SP: invalid AccumulatorPrototype")
    return
  end
  
  SOL_PROD.DB[prototype_name] = prototype_name
  
  local base = table.deepcopy(data.raw["accumulator"][prototype_name])
  local bes = base.energy_source
  local bonus = 1
  local max_bonus = #SOL_PROD.BONUS
  
  for level = 1, SOL_PROD.LEVELS do
    local prototype = table.deepcopy(base)
    bonus = bonus + SOL_PROD.BONUS[math.min(level, max_bonus)]
    prototype.name = "sp-"..tostring(level).."-"..base.name
    prototype.localised_name = {"item-name."..base.name}
    prototype.placeable_by = { item = base.name, count = 1 }
    prototype.energy_source = {
      type = bes.type,
      buffer_capacity = SU.msv(bes.buffer_capacity, bonus),
      usage_priority = bes.usage_priority,
      input_flow_limit = SU.msv(bes.input_flow_limit, bonus),
      output_flow_limit = SU.msv(bes.output_flow_limit, bonus),
      render_no_power_icon = bes.render_no_power_icon
    }
    data:extend({prototype})
    SOL_PROD.DB[prototype.name] = prototype_name
  end
end

function SOL_PROD.register_entity(entity_name)
  if not entity_name or type(entity_name) ~= "string" then
    log("SP: prototype name expected, got "..type(entity_name))
    return
  end
  if not SOL_PROD.DB then SOL_PROD.DB = {} end
  SOL_PROD.DB[entity_name] = entity_name
  for level = 1, SOL_PROD.LEVELS do
    local new = "sp-"..tostring(level).."-"..entity_name
    SOL_PROD.DB[new] = entity_name
  end
end

function SOL_PROD.on_init()
  for ___, params in pairs(SOL_PROD.compatibility_list) do
    if script.active_mods[params.mod] then
      for ___, entity in pairs(params.solar_panels) do
        SOL_PROD.register_entity(entity)
      end
      for ___, entity in pairs(params.accumulators) do
        SOL_PROD.register_entity(entity)
      end
    end
  end
end

function SOL_PROD.on_built(event)
  local entity = event.created_entity
  if not entity or not entity.valid then return end
  
  local name = entity.name
  if not SOL_PROD.DB[name] then return end
  
  replace_prototype(entity)
end

function SOL_PROD.on_research_finished(event)
  local research = event.research
  if not research or not research.valid then return end

  local name = research.name
  local force = research.force

  if not SU.starts_with(name, "solar-productivity") then return end
  
  for ___, surface in pairs(game.surfaces) do
    local entities = surface.find_entities_filtered{
      force = force,
      type = {"solar-panel", "accumulator"}
    }
    for ___, entity in pairs(entities) do replace_prototype(entity) end
  end
end

return SOL_PROD