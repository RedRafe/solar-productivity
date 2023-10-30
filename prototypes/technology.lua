local SP = require "prototypes.shared"

local technology_icons = function()
  return {
    {
      icon = "__base__/graphics/technology/solar-energy.png",
      icon_size = 256, 
      icon_mipmaps = 4
    },
    {
      icon = "__core__/graphics/icons/technology/constants/constant-mining-productivity.png",
      icon_size = 128,
      icon_mipmaps = 3,
      shift = {100, 100}
    }
  }
end

data:extend({
  -- SP-1
  {
    type = "technology",
    name = SP.TECHNOLOGY.."1",
    icon_size = 256,
    icon_mipmaps = 4,
    icons = technology_icons(),    
    effects =
    {
      {
        type = "nothing",
        effect_description = {"effect-description.solar-productivity-1"}
      },
    },
    prerequisites = {"solar-energy", "electric-energy-accumulators"},
    unit =
    {
      count = 250,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1}
      },
      time = 60
    },
    upgrade = true,
    order = "sp-1"
  },
  -- SP-2
  {
    type = "technology",
    name = SP.TECHNOLOGY.."2",
    icon_size = 256,
    icon_mipmaps = 4,
    icons = technology_icons(), 
    effects =
    {
      {
        type = "nothing",
        effect_description = {"effect-description.solar-productivity-2"}
      },
    },
    prerequisites = {SP.TECHNOLOGY.."1"},
    unit =
    {
      count = 500,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1}
      },
      time = 60
    },
    upgrade = true,
    order = "sp-2"
  },
  -- SP-3
  {
    type = "technology",
    name = SP.TECHNOLOGY.."3",
    icon_size = 256,
    icon_mipmaps = 4,
    icons = technology_icons(), 
    effects =
    {
      {
        type = "nothing",
        effect_description = {"effect-description.solar-productivity-3"}
      },
    },
    prerequisites = {SP.TECHNOLOGY.."2"},
    unit =
    {
      count = 1000,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1}
      },
      time = 60
    },
    upgrade = true,
    order = "sp-3"
  },
  -- SP-4
  {
    type = "technology",
    name = SP.TECHNOLOGY.."4",
    icon_size = 256,
    icon_mipmaps = 4,
    icons = technology_icons(),
    effects =
    {
      {
        type = "nothing",
        effect_description = {"effect-description.solar-productivity-4"}
      },
    },
    prerequisites = {SP.TECHNOLOGY.."3", "space-science-pack"},
    unit =
    {
      count_formula = "2500*(L - 3)",
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
        {"space-science-pack", 1}
      },
      time = 60
    },
    max_level = SP.LEVELS,
    upgrade = true,
    order = "sp-4",
  }
})
