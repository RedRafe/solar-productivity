local multiplier = settings.startup['sp-multiplier'] and settings.startup['sp-multiplier'].value or 3

local SOL_PROD = {}

-- Max number of levels for technology & prototypes
SOL_PROD.LEVELS = 50

-- Bonus for each level
SOL_PROD.BONUS = {
  [1] = 0.15 * multiplier,
  [2] = 0.10 * multiplier,
  [3] = 0.05 * multiplier,
  [4] = 0.05 * multiplier,
}

SOL_PROD.ENTITY = 'sp-'

SOL_PROD.TECHNOLOGY = 'solar-productivity-'

SOL_PROD.TECHNOLOGY_ICON = '__base__/graphics/technology/solar-energy.png'

SOL_PROD.COMPATIBILITY_LIST = require 'prototypes.compatibility'

SOL_PROD.PACKS = {
  automation = {'automation-science-pack', 1},
  logistic   = {'logistic-science-pack',   1},
  chemical   = {'chemical-science-pack',   1},
  production = {'production-science-pack', 1},
  utility    = {'utility-science-pack',    1},
  space      = {'space-science-pack',      1},
}

return SOL_PROD
