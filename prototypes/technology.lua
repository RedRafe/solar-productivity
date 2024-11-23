local SP = require 'prototypes.shared'
local str = tostring

data:extend({
  -- SP-1
  {
    type = 'technology',
    name = SP.TECHNOLOGY..'1',
    icons = util.technology_icon_constant_productivity('__base__/graphics/technology/solar-energy.png'),
    localised_description = {'technology-description.solar-productivity', str(SP.BONUS[1] * 100)},
    effects =
    {
      {
        type = 'nothing',
        effect_description = {'effect-description.solar-productivity', str(SP.BONUS[1] * 100)}
      },
    },
    prerequisites = {'solar-energy', 'electric-energy-accumulators'},
    unit =
    {
      count = 250,
      ingredients =
      {
        {'automation-science-pack', 1},
        {'logistic-science-pack', 1}
      },
      time = 60
    },
    upgrade = true,
    order = 'sp-1'
  },
  -- SP-2
  {
    type = 'technology',
    name = SP.TECHNOLOGY..'2',
    icons = util.technology_icon_constant_productivity('__base__/graphics/technology/solar-energy.png'),
    localised_description = {'technology-description.solar-productivity', str(SP.BONUS[2] * 100)},
    effects =
    {
      {
        type = 'nothing',
        effect_description = {'effect-description.solar-productivity', str(SP.BONUS[2] * 100)}
      },
    },
    prerequisites = {SP.TECHNOLOGY..'1', 'chemical-science-pack'},
    unit =
    {
      count = 500,
      ingredients =
      {
        {'automation-science-pack', 1},
        {'logistic-science-pack', 1},
        {'chemical-science-pack', 1}
      },
      time = 60
    },
    upgrade = true,
    order = 'sp-2'
  },
  -- SP-3
  {
    type = 'technology',
    name = SP.TECHNOLOGY..'3',
    icons = util.technology_icon_constant_productivity('__base__/graphics/technology/solar-energy.png'),
    localised_description = {'technology-description.solar-productivity', str(SP.BONUS[3] * 100)},
    effects =
    {
      {
        type = 'nothing',
        effect_description = {'effect-description.solar-productivity', str(SP.BONUS[3] * 100)}
      },
    },
    prerequisites = {SP.TECHNOLOGY..'2', 'production-science-pack','utility-science-pack'},
    unit =
    {
      count = 1000,
      ingredients =
      {
        {'automation-science-pack', 1},
        {'logistic-science-pack', 1},
        {'chemical-science-pack', 1},
        {'production-science-pack', 1},
        {'utility-science-pack', 1}
      },
      time = 60
    },
    upgrade = true,
    order = 'sp-3'
  },
  -- SP-4
  {
    type = 'technology',
    name = SP.TECHNOLOGY..'4',
    icons = util.technology_icon_constant_productivity('__base__/graphics/technology/solar-energy.png'),
    localised_description = {'technology-description.solar-productivity', str(SP.BONUS[4] * 100)},
    effects =
    {
      {
        type = 'nothing',
        effect_description = {'effect-description.solar-productivity', str(SP.BONUS[4] * 100)}
      },
    },
    prerequisites = {SP.TECHNOLOGY..'3', 'space-science-pack'},
    unit =
    {
      count_formula = '2500*(L - 3)',
      ingredients = {
        {'automation-science-pack', 1},
        {'logistic-science-pack', 1},
        {'chemical-science-pack', 1},
        {'production-science-pack', 1},
        {'utility-science-pack', 1},
        {'space-science-pack', 1}
      },
      time = 60
    },
    max_level = SP.LEVELS,
    upgrade = true,
    order = 'sp-4',
  }
})
