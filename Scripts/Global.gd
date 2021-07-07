extends Node

export var light_color = "ffd6d6"
enum game_states {PREGAME, PREROUND, ROUND, POSTROUND}
var game_state = game_states.PREROUND
var current_round := 0
