-- SOLAR PRODUCTIVITY API

local SOL_PROD = require "prototypes.shared"

SolarProductivity = {}

-- SolarProductivity.register_solar_panel(solar_panel_name)
-- Will register the prototype and create upgraded variations of it
-- Must reference to a SolarPanelPrototype and have valid .production field
-- @ solar_panel_name: String
function SolarProductivity.register_solar_panel(solar_panel_name)
  if type(solar_panel_name) ~= "string" then error("SP: prototype name expected, got "..type(solar_panel_name)) end
  SOL_PROD.make_solar_panel_variations(solar_panel_name)
end

-- SolarProductivity.register_accumulator(accumulator_name)
-- Will register the prototype and create upgraded variations of it
-- Must reference to an AccumuatorPrototype and have valid .energy_source field
-- @ accumulator_name: String
function SolarProductivity.register_accumulator(accumulator_name)
  if type(accumulator_name) ~= "string" then error("SP: prototype name expected, got "..type(accumulator_name)) end
  SOL_PROD.make_accumulator_variations(accumulator_name)
end
