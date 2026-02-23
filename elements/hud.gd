extends CanvasLayer

@export var task_scene: PackedScene
@export var task_fade_speed: float = 1.0
var task_current_warning: CheckBox
var task_warn_tween: Tween

func _ready() -> void:
	$TopRightPanel/EnergyBarBase.value = Gamestate.current_energy
	$TopRightPanel/EnergyBarBase/EnergyBarOverlay.value = Gamestate.current_energy
	Gamestate.active_tasks.clear()
	for task_name in Gamestate.active_tasks_data:
		var task = task_scene.instantiate()
		task.name = task_name
		var task_data = Gamestate.active_tasks_data[task_name]
		task.time_cost = task_data["time_cost"]
		task.energy_cost = task_data["energy_cost"]
		task.turn_in = get_node(task_data["turn_in"])
		task.rich_text = task_data["rich_text"]
		Gamestate.active_tasks.append(task)
		$TopRightPanel/TaskList.add_child(task)


func _on_entity_assign(task: CheckBox) -> void:
	# Add task to Gamestate
	Gamestate.active_tasks.append(task)
	Gamestate.active_tasks_data.get_or_add(task.name)
	Gamestate.active_tasks_data[task.name]  = {
		"time_cost": task.time_cost,
		"energy_cost": task.energy_cost,
		"turn_in": task.turn_in.get_path(),
		"rich_text": task.rich_text,
		"unlocks": []
	}
	var exits = get_tree().current_scene.find_children("Exit*")
	for exit in exits:
		print("Checking exit " + exit.name)
		if exit.prerequisites.has(task):
			print("Exit has " + task.name + " as prereq")
			Gamestate.active_tasks_data[task.name]["unlocks"].append(exit.get_path())
	task.reparent($TopRightPanel/TaskList, false)
	task.show()
	var tween = get_tree().create_tween()
	tween.tween_property(task, "modulate:a", 0, 0.0)
	tween.tween_property(task, "modulate:a", 1, task_fade_speed)


func _on_entity_turn_in(task: CheckBox) -> void:
	# Spend energy, kill warn animation
	task_current_warning = null
	if task_warn_tween:
		task_warn_tween.kill()
		task_warn_tween = null
	Gamestate.current_energy -= task.energy_cost
	$TopRightPanel/EnergyBarBase.value = Gamestate.current_energy
	$TopRightPanel/EnergyBarBase.self_modulate = Color.WHITE
	$TopRightPanel/EnergyBarBase/EnergyBarOverlay.value = Gamestate.current_energy
	task.modulate.a = 1.0
	# Clear task
	Gamestate.active_tasks.erase(task)
	Gamestate.active_tasks_data.erase(task.name)
	task.button_pressed = true
	task.disabled = true
	var tween = get_tree().create_tween()
	tween.tween_interval(0.5)
	tween.tween_property(task, "modulate:a", 0, task_fade_speed)
	tween.tween_callback(task.queue_free)


func _on_entity_turn_in_warn(task: CheckBox) -> void:
	task_current_warning = task
	if task.energy_cost > 0:
		# If the task cost is > 0, flash the base and shorten the overlay.
		$TopRightPanel/EnergyBarBase/EnergyBarOverlay.value -= task.energy_cost
		task_warn_tween = get_tree().create_tween().set_loops()
		task_warn_tween.tween_property($TopRightPanel/EnergyBarBase, "self_modulate:a", 0.0, 0.5)
		task_warn_tween.parallel().tween_property(task, "modulate:a", 0.5, 0.5)
		task_warn_tween.tween_property($TopRightPanel/EnergyBarBase, "self_modulate:a", 1.0, 0.5)
		task_warn_tween.parallel().tween_property(task, "modulate:a", 1.0, 0.5)
		if task.energy_cost > Gamestate.current_energy:
			$TopRightPanel/EnergyBarBase.self_modulate = Color.RED
	elif task.energy_cost < 0:
		# If the task cost is < 0 (a recovery), extend the base and flash it GREEN.
		$TopRightPanel/EnergyBarBase.value -= task.energy_cost
		task_warn_tween = get_tree().create_tween().set_loops()
		task_warn_tween.tween_property($TopRightPanel/EnergyBarBase, "self_modulate:a", 0.0, 0.5)
		task_warn_tween.parallel().tween_property(task, "modulate:a", 0.5, 0.5)
		task_warn_tween.tween_property($TopRightPanel/EnergyBarBase, "self_modulate:a", 1.0, 0.5)
		task_warn_tween.parallel().tween_property(task, "modulate:a", 1.0, 0.5)
		$TopRightPanel/EnergyBarBase.self_modulate = Color.GREEN


func _on_entity_turn_in_unwarn(task: CheckBox) -> void:
	if task_current_warning == task:
		task_current_warning = null
		if task_warn_tween:
			task_warn_tween.kill()
			task_warn_tween = null
		$TopRightPanel/EnergyBarBase.value = Gamestate.current_energy
		$TopRightPanel/EnergyBarBase.self_modulate = Color.WHITE
		$TopRightPanel/EnergyBarBase/EnergyBarOverlay.value = Gamestate.current_energy
		task.modulate.a = 1.0
