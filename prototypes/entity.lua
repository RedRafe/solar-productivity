local SOL_PROD = require "prototypes.shared"

for ___, params in pairs(SOL_PROD.compatibility_list) do
  if mods[params.mod] then
    for ___, solar in pairs(params.solar_panels) do
      SOL_PROD.make_solar_panel_variations(solar)
    end
    for ___, accu in pairs(params.accumulators) do
      SOL_PROD.make_accumulator_variations(accu)
    end
  end
end
