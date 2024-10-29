local SOL_PROD = {}

-- Max number of levels for technology & prototypes
SOL_PROD.LEVELS = 50

-- Bonus for each level
SOL_PROD.BONUS = {
  [1] = 0.15,
  [2] = 0.1,
  [3] = 0.1,
  [4] = 0.05
}

SOL_PROD.ENTITY = "sp-"

SOL_PROD.TECHNOLOGY = "solar-productivity-"

SOL_PROD.COMPATIBILITY_LIST = require "prototypes.compatibility"

return SOL_PROD
