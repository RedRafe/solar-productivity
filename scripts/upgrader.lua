local SP    = require 'prototypes.shared'
local sutil = require 'prototypes.string-util'
local Queue = require 'scripts.queue'
local size  = Queue.size
local push  = Queue.push
local pop   = Queue.pop
local ceil  = math.ceil

-- ============================================================================

--- init storage.level index for the force
---@param force LuaForce
local function init_force(force)
  storage.levels = storage.levels or {}
  storage.levels[force.index] = 0
end

-- ============================================================================

--- add new force to storage.levels index
--- @param e EventData.on_force_created
local function on_force_created(e)
  init_force(e.force)
end

-- ============================================================================
local function update_settings()
	storage.interval = (settings.global['sp-interval'].value or 5) * 60
end

-- ============================================================================

--- update the storage.levels for the force
---@param force LuaForce
local function update_force_level(force)
  if not force or not force.valid or not force.index then
    return
  end

  -- return _max
  -- loop trough all techs. Cannot be optimized 
  -- because SE requires to loop through all of them
  local _max = 0
  local researched = true
  local l = 1
  while (researched == true and l <= SP.LEVELS) do
    local tech_name = SP.TECHNOLOGY .. l
    local tech = force.technologies[tech_name]
    if tech then
      if tech.researched then
        _max = math.max(_max, tech.level)
      else
        researched = false
        if tech.level then
          _max = math.max(_max, tech.level - 1)
        end
      end
    end
    l = l + 1
  end

  storage.levels = storage.levels or {}
  storage.levels[force.index] = _max
end

-- ============================================================================

--- updates the storage.levels for each force
local function update_forces_levels()
  for ___, force in pairs(game.forces) do
    update_force_level(force)
  end
end

-- ============================================================================

local function transfer_properties(old, new)
  if old.energy then
    new.energy = old.energy
  end

  local damage = old.prototype.get_max_health(old.quality) - old.health
  if damage > 0 then
    new.damage(damage, game.forces.neutral)
  end

  for wire_id, connector in pairs(old.get_wire_connectors(false)) do
    local link = new.get_wire_connector(wire_id, true)
    for _, v in pairs(connector.connections) do
      link.connect_to(v.target, false, v.origin)
    end
  end

  local old_cb = old.get_control_behavior()
  if old_cb and old_cb.valid then
    local new_cb = new.get_or_create_control_behavior()
    new_cb.read_charge = old_cb.read_charge
    new_cb.output_signal = old_cb.output_signal
  end
end

--- upgrade prototype to the higher level
---@param old LuaEntity
local function update_prototype(old)
  if not (old and old.valid) then
    return
  end

  local force = old.force
  local level = storage.levels[force.index]
  if not level or level == 0 then
    return
  end
  -- TODO: replace all solars to "vanilla" if prod-1 is unresearched

  local old_name = old.name
  local new_name = SP.ENTITY .. level .. '-' .. sutil.base(old_name)

  if old_name == new_name then
    return
  end
  if not prototypes.entity[new_name] then
    return
  end

  local new = old.surface.create_entity({
    name = new_name,
    position = old.position,
    force = old.force,
    player = old.last_user,
    quality = old.quality,
    create_build_effect_smoke = false,
    raise_built = false,
  })

  if not (new and new.valid) then
    return
  end

  transfer_properties(old, new)
  old.destroy()
end

-- ============================================================================

--- updates forces levels & entities on new solar productivity researched
---@param event EventData.on_research_finished
local function on_research_finished(event)
  local research = event.research
  if not research or not research.valid then
    return
  end

  local name = research.name
  local force = research.force

  if not sutil.starts_with(name, SP.TECHNOLOGY) then
    return
  end

  update_force_level(force)
  local to_update = storage.to_update

  for ___, surface in pairs(game.surfaces) do
    local entities = surface.find_entities_filtered { force = force, type = { 'solar-panel', 'accumulator' } }
    for ___, entity in pairs(entities) do
      push(to_update, entity)
    end
  end
end

-- ============================================================================

--- updates forces levels & entities on solar productivity reversed
local function on_research_reversed(event)
  local research = event.research
  if not research or not research.valid then
    return
  end

  local name = research.name
  local force = research.force

  if not sutil.starts_with(name, SP.TECHNOLOGY) then
    return
  end

  update_force_level(force)
  local to_update = storage.to_update

  for ___, surface in pairs(game.surfaces) do
    local entities = surface.find_entities_filtered { force = force, type = { 'solar-panel', 'accumulator' } }
    for ___, entity in pairs(entities) do
      push(to_update, entity)
    end
  end
end

-- ============================================================================

--- upgrade the entity to higher tier if possible
---@param event EventData.on_built_entity
local function on_built(event)
  local entity = event.created_entity or event.entity or event.destination
  if not entity or not entity.valid then
    return
  end
  push(storage.to_update, entity)
end

-- ============================================================================

--- will upgrade each entity, if posssible
local function update_entities()
  local to_update = storage.to_update

  for ___, surface in pairs(game.surfaces) do
    local entities = surface.find_entities_filtered { type = { 'solar-panel', 'accumulator' } }
    for ___, entity in pairs(entities) do
      push(to_update, entity)
    end
  end
end

-- ============================================================================

--- downgrade prototype to the base prototype
---@param old LuaEntity
local function downgrade_prototype(old)
  if not (old and old.valid) then
    return
  end

  local old_name = old.name
  local new_name = sutil.base(old_name)

  if old_name == new_name then
    return
  end
  if not prototypes.entity[new_name] then
    return
  end

  local new = old.surface.create_entity({
    name = new_name,
    position = old.position,
    force = old.force,
    player = old.last_user,
    quality = old.quality,
    create_build_effect_smoke = false,
    raise_built = false,
  })

  if not (new and new.valid) then
    return
  end

  transfer_properties(old, new)
  old.destroy()
end

-- ============================================================================

--- replaces higher tiers with the base one
local function replace_all_upgrades()
  local to_downgrade = storage.to_downgrade

  for ___, surface in pairs(game.surfaces) do
    local entities = surface.find_entities_filtered { type = { 'solar-panel', 'accumulator' } }
    for ___, entity in pairs(entities) do
      push(to_downgrade, entity)
    end
  end
end

-- ============================================================================

local function set_filters()
  local upgrader_filter = { { filter = 'type', type = 'solar-panel' }, { mode = 'or', filter = 'type', type = 'accumulator' } }
  script.set_event_filter(defines.events.on_built_entity --[[@as uint]] , upgrader_filter)
  script.set_event_filter(defines.events.on_entity_cloned --[[@as uint]] , upgrader_filter)
  script.set_event_filter(defines.events.on_robot_built_entity --[[@as uint]] , upgrader_filter)
  script.set_event_filter(defines.events.script_raised_built --[[@as uint]] , upgrader_filter)
  script.set_event_filter(defines.events.script_raised_revive --[[@as uint]] , upgrader_filter)
end

-- ============================================================================

local function on_tick()
  local to_update = storage.to_update
  local to_downgrade = storage.to_downgrade

  local u_size = ceil(size(to_update) / storage.interval)
  local d_size = ceil(size(to_downgrade) / storage.interval)

  while u_size > 0 do
    update_prototype(pop(to_update))
    u_size = u_size - 1
  end

  while d_size > 0 do
    downgrade_prototype(pop(to_downgrade))
    d_size = d_size - 1
  end
end

-- ============================================================================

---@class ScriptLib
local Upgrader = {}

Upgrader.events = {
  [defines.events.on_tick]               = on_tick,
  [defines.events.on_force_created]      = on_force_created,
  [defines.events.on_research_finished]  = on_research_finished,
  [defines.events.on_research_reversed]  = on_research_reversed,
  [defines.events.on_built_entity]       = on_built,
  [defines.events.on_entity_cloned]      = on_built,
  [defines.events.on_robot_built_entity] = on_built,
  [defines.events.script_raised_built]   = on_built,
  [defines.events.script_raised_revive]  = on_built,
  [defines.events.on_runtime_mod_setting_changed] = update_settings,
}

Upgrader.on_init = function()
  storage.levels = {}
  storage.to_update = Queue.new()
  storage.to_downgrade = Queue.new()

  set_filters()
  update_settings()
  for _, force in pairs(game.forces) do
    init_force(force)
  end
end

Upgrader.on_load = function()
  set_filters()
end

Upgrader.on_configuration_changed = function()
  set_filters()
  update_settings()
  update_forces_levels()
  update_entities()
end

Upgrader.add_commands = function()
  -- Usage: type "/sp-update" in game console
  -- Forces the game to upgrade all entities, if possible
  commands.add_command('sp-update', { 'command-help.sp-update' }, function()
    update_forces_levels()
    update_entities()
  end)
  -- Usage: type "/sp-transition" in game console
  -- Removes all upgraded and places back the  base prototype
  commands.add_command('sp-transition', { 'command-help.sp-transition' }, function()
    replace_all_upgrades()
  end)
end

Upgrader.add_remote_interface = function()
end

return Upgrader
