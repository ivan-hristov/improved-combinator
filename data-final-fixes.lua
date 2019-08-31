local constants = require("constants")

table.insert( 
    data.raw["technology"]["circuit-network"].effects, {type = "unlock-recipe", recipe = constants.name}
)
