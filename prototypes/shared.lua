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

SOL_PROD.COMPATIBILITY_LIST = require 'prototypes.compatibility'

return SOL_PROD
