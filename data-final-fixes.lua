local lib = require 'prototypes.entity'

local solar_panels, accumulators = {}, {}

for name, _ in pairs(data.raw['solar-panel']) do
  solar_panels[#solar_panels + 1] = name
end
for name, _ in pairs(data.raw['accumulator']) do
  accumulators[#accumulators + 1] = name
end

for _, name in pairs(solar_panels) do
  lib.make_solar_panel_variations(name)
end
for _, name in pairs(accumulators) do
  lib.make_accumulator_variations(name)
end
