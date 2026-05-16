local SP = require '__solar-productivity__.prototypes.shared'
local str = tostring

local function create_sp_technology(level, overrides)
  local base = {
    type  = 'technology',
    name  = SP.TECHNOLOGY .. level,
    icons = util.technology_icon_constant_productivity(SP.TECHNOLOGY_ICON),
    localised_description = {'technology-description.solar-productivity', str(SP.BONUS[level] * 100)},
    effects = {
      {
        type = 'nothing',
        effect_description = {'effect-description.solar-productivity', str(SP.BONUS[level] * 100)},
      },
    },
    upgrade = true,
    order = 'sp-' .. level,
  }

  for k, v in pairs(overrides) do
    base[k] = v
  end

  return base
end

data:extend({
  -- SP-1
  create_sp_technology(
    1,
    {
      prerequisites = {'solar-energy', 'electric-energy-accumulators'},
      unit = {
        count = 250,
        ingredients = {SP.PACKS.automation, SP.PACKS.logistic},
        time = 60,
      }
    }
  ),
  -- SP-2
  create_sp_technology(
    2,
    {
      prerequisites = {SP.TECHNOLOGY..'1', 'chemical-science-pack'},
      unit = {
        count = 500,
        ingredients = {SP.PACKS.automation, SP.PACKS.logistic, SP.PACKS.chemical},
        time = 60,
      }
    }
  ),
  -- SP-3
  create_sp_technology(
    3,
    {
      prerequisites = {SP.TECHNOLOGY..'2', 'production-science-pack','utility-science-pack'},
      unit = {
        count = 1000,
        ingredients = {SP.PACKS.automation, SP.PACKS.logistic, SP.PACKS.chemical, SP.PACKS.production, SP.PACKS.utility},
        time = 60,
      }
    }
  ),
  -- SP-4
  create_sp_technology(
    4,
    {
      prerequisites = {SP.TECHNOLOGY..'3', 'space-science-pack'},
      unit = {
        count_formula = '2500*(L - 3)',
        ingredients = {SP.PACKS.automation, SP.PACKS.logistic, SP.PACKS.chemical, SP.PACKS.production, SP.PACKS.utility, SP.PACKS.space},
        time = 60,
      },
      max_level = SP.LEVELS,
    }
  )
})
