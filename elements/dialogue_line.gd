class_name DialogueLine
extends Resource

@export var speaker: NodePath
@export var text: String
@export var animation: String
@export var facing: NodePath

func _init(p_speaker = "", p_text = "", p_animation = "idle", p_facing = "") -> void:
	speaker = p_speaker
	text = p_text
	animation = p_animation
	facing = p_facing
