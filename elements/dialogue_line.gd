class_name DialogueLine
extends Resource

@export var speaker: NodePath
@export var text: String
@export var animation: String

func _init(p_speaker = "", p_text = "", p_animation = "idle") -> void:
	speaker = p_speaker
	text = p_text
	animation = p_animation
