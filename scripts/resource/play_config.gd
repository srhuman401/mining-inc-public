## Contains general purpose settings
## used for DLC and basegame differences mostly
class_name PlayConfiguration
extends Resource

## formats '[save_prefix]_sav_1.res' and '[save_prefix]_sav_1.meta.tres'
## useful for changing the map and seperating vanilla saves
@export var save_prefix: String = "vanilla"

## Map to load
## save files can override
@export var main_map: MapState
