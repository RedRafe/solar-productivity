local SOL_PROD = require "prototypes.shared"

remote.add_interface("sp-register-entity", { register_entity = SOL_PROD.register_entity })
remote.add_interface("sp-force-update", { sp_force_update = SOL_PROD.force_update })

script.on_init(SOL_PROD.on_init)
script.on_load(SOL_PROD.on_init)
script.on_configuration_changed(SOL_PROD.on_configuration_changed)

script.on_event(
  {
    defines.events.on_built_entity,
    defines.events.on_entity_cloned,
    defines.events.on_robot_built_entity,
    defines.events.script_raised_built,
    defines.events.script_raised_revive,
  },
  SOL_PROD.on_built
)

script.on_event(
  defines.events.on_research_finished,
  SOL_PROD.on_research_finished
)