class_name Behavior
extends Resource

@export var animation: String
@export var speed: float
@export var flip_h: bool
@export var duration: float

func _init(p_animation = "idle", p_speed = 0.0, p_flip_h = false, p_duration = 1.0) -> void:
	animation = p_animation
	speed = p_speed
	flip_h = p_flip_h
	duration = p_duration
