local SP    = require "prototypes.shared"
local sutil = require "prototypes.string-util"

-- ============================================================================

--- init global.level index for the force
---@param force LuaForce
local function init_force(force)
  global.levels = global.levels or {}
  global.levels[force.index] = 0
end

-- ============================================================================

--- add new force to global.levels index
--- @param e EventData.on_force_created
local function on_force_created(e)
  init_force(e.force)
end

-- ============================================================================

--- update the global.levels for the force
---@param force LuaForce
local function update_force_level(force)
  if not force or not force.valid or not force.index then return end

  --return _max
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

  global.levels = global.levels or {}
  global.levels[force.index] = _max
end

-- ============================================================================

--- updates the global.levels for each force
local function update_force_levels()
  for ___, force in pairs(game.forces) do
    update_force_level(force)
  end
end

-- ============================================================================

--- upgrade prototype to the higher level
---@param old LuaEntity
local function update_prototype(old)
  if not old or not old.valid then return end

  local force = old.force
  local level = global.levels[force.index]
  if not level or level == 0 then return end
  -- TODO: replace all solars to "vanilla" if prod-1 is unresearched

  local old_name  = old.name
  local new_name  = SP.ENTITY..level.."-"..sutil.base(old_name)

  if old_name == new_name then return end
  if not game.entity_prototypes[new_name] then return end

  local surface   = old.surface
  local position  = old.position
  local player    = old.last_user
  local damage    = old.prototype.max_health - old.health
  
  local connections = nil;
  if old.circuit_connected_entities ~= nil then
    connections = {}
    for ___, connection in pairs(old.circuit_connection_definitions) do
      table.insert(connections, connection)
    end
  end

  old.destroy()

  local new = surface.create_entity({
    name = new_name,
    position = position,
    force = force,
    player = player,
    create_build_effect_smoke = false,
    raise_built = true,
  })
  
  if connections ~= nil then
    for ___, connection in pairs(connections) do
      local connected = new.connect_neighbour(connection);
    end
  end

  if new and new.valid and damage > 0 then
    new.damage(damage, game.forces.neutral)
  end
end

-- ============================================================================

--- updates forces levels & entities on new solar productivity researched
---@param event EventData.on_research_finished
local function on_research_finished(event)
  local research = event.research
  if not research or not research.valid then return end

  local name = research.name
  local force = research.force

  if not sutil.starts_with(name, SP.TECHNOLOGY) then return end
  
  update_force_level(force)

  for ___, surface in pairs(game.surfaces) do
    local entities = surface.find_entities_filtered{
      force = force,
      type = {"solar-panel", "accumulator"}
    }
    for ___, entity in pairs(entities) do update_prototype(entity) end
  end
end

-- ============================================================================

--- updates forces levels & entities on solar productivity reversed
local function on_research_reversed(event)
  local research = event.research
  if not research or not research.valid then return end

  local name = research.name
  local force = research.force

  if not sutil.starts_with(name, SP.TECHNOLOGY) then return end

  update_force_level(force)

  for ___, surface in pairs(game.surfaces) do
    local entities = surface.find_entities_filtered{
      force = force,
      type = {"solar-panel", "accumulator"}
    }
    for ___, entity in pairs(entities) do update_prototype(entity) end
  end
end

-- ============================================================================

--- upgrade the entity to higher tier if possible
---@param event EventData.on_built_entity
local function on_built(event)
  local entity = event.created_entity
  if not entity or not entity.valid then return end
  
  local name = entity.name
  
  update_prototype(entity)
end

-- ============================================================================

--- will upgrade each entity, if posssible
local function update_entities()
  for ___, surface in pairs(game.surfaces) do
    local entities = surface.find_entities_filtered{
      type = {"solar-panel", "accumulator"}
    }
    for ___, entity in pairs(entities) do update_prototype(entity) end
  end
end

-- ============================================================================

--- downgrade prototype to the base prototype
---@param old LuaEntity
local function downgrade_prototype(old)
  if not old or not old.valid then return end

  local old_name  = old.name
  local new_name  = sutil.base(old_name)

  if old_name == new_name then return end
  if not game.entity_prototypes[new_name] then return end

  local force     = old.force
  local surface   = old.surface
  local position  = old.position
  local player    = old.last_user
  local damage    = old.prototype.max_health - old.health

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

-- ============================================================================

--- replaces higher tiers with the base one
local function replace_all_upgrades()
  for ___, surface in pairs(game.surfaces) do
    local entities = surface.find_entities_filtered{
      type = {"solar-panel", "accumulator"}
    }
    for ___, entity in pairs(entities) do downgrade_prototype(entity) end
  end
end

-- ============================================================================

local function set_filters()
  local upgrader_filter = {{filter = "type", type = "solar-panel"}, {mode = "or", filter = "type", type = "accumulator"}}
  script.set_event_filter(defines.events.on_built_entity        --[[@as uint]], upgrader_filter)
  script.set_event_filter(defines.events.on_entity_cloned       --[[@as uint]], upgrader_filter)
  script.set_event_filter(defines.events.on_robot_built_entity  --[[@as uint]], upgrader_filter)
  script.set_event_filter(defines.events.script_raised_built    --[[@as uint]], upgrader_filter)
  script.set_event_filter(defines.events.script_raised_revive   --[[@as uint]], upgrader_filter)
end

-- ============================================================================

---@class ScriptLib
local Upgrader = {}

Upgrader.events = {
  [defines.events.on_force_created]       = on_force_created,
  [defines.events.on_research_finished]   = on_research_finished,
  [defines.events.on_research_reversed]   = on_research_reversed,
  [defines.events.on_built_entity]        = on_built,
  [defines.events.on_entity_cloned]       = on_built,
  [defines.events.on_robot_built_entity]  = on_built,
  [defines.events.script_raised_built]    = on_built,
  [defines.events.script_raised_revive]   = on_built,
}

Upgrader.on_init = function()
  global.levels = {}

  set_filters()
  for _, force in pairs(game.forces) do
    init_force(force)
  end
end

Upgrader.on_load = function ()
  set_filters()
end

Upgrader.on_configuration_changed = function()
  set_filters()
  update_force_levels()
  update_entities()
end

Upgrader.add_commands = function ()
  -- Usage: type "/sp-update" in game console
  -- Forces the game to upgrade all entities, if possible
  commands.add_command("sp-update", {"command-help.sp-update"}, function()
    update_force_levels()
    update_entities()
  end)
  -- Usage: type "/sp-transition" in game console
  -- Removes all upgraded and places back the  base prototype
  commands.add_command("sp-transition", {"command-help.sp-transition"}, function()
    replace_all_upgrades()
  end)
end

Upgrader.add_remote_interface = function () end

return Upgrader