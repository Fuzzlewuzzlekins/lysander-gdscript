extends CheckBox

@export var time_cost: int = 10
@export var energy_cost: int = 10
@export var turn_in: Area2D
@export_multiline var rich_text: String = "Complete task"

func _ready() -> void:
	$Label.text = rich_text
