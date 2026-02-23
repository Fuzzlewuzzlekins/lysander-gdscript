extends Area2D

#signal assign(task: CheckBox)
signal turn_in(task: CheckBox)
signal turn_in_warn(task: CheckBox)
signal turn_in_unwarn(task: CheckBox)

@export var target_player: Area2D
@export var dullness: float = 0.8
@export_file("*.tscn") var next_scene: String
@export var next_scene_hint: String = "Leave"
@export var prerequisites: Array[CheckBox]
@export var lock_message: String
#var assignment: CheckBox


func _ready() -> void:
	modulate.a = dullness
	$Label.modulate.a = 0.0


func _on_player_interact(area: Area2D) -> void:
	if self == area:
		# Check if I am a turn-in point for any tasks
		for i in range(Gamestate.active_tasks.size()):
			var task = Gamestate.active_tasks.get(i)
			if task.turn_in == self:
				turn_in.emit(task)
		# If not locked, let player change scene
		if prerequisites.size() == 0 and !lock_message:
			# Freeze current scene state
			var current_scene_name = get_tree().current_scene.name
			Gamestate.frozen_scenes.get_or_add(current_scene_name)
			Gamestate.frozen_scenes[current_scene_name] = PackedScene.new()
			Gamestate.frozen_scenes[current_scene_name].pack(get_tree().current_scene)
			# Check to see if my next_scene has a frozen variant
			var next_scene_packed = load(next_scene)
			var next_scene_name = next_scene_packed.get_state().get_node_name(0)
			if Gamestate.frozen_scenes.has(next_scene_name):
				next_scene_packed = Gamestate.frozen_scenes[next_scene_name]
			get_tree().change_scene_to_packed(next_scene_packed)


func _on_player_highlight(area: Area2D) -> void:
	if self == area:
		if prerequisites.size() > 0 or lock_message:
			$Label.text = lock_message
		else:
			$Label.text = next_scene_hint
		var tween = get_tree().create_tween()
		tween.tween_property(self, "modulate:a", 1.0, 0.2)
		tween.parallel().tween_property($Label, "modulate:a", 1.0, 0.2)
		# Check if I am a turn-in point for any tasks
		for i in range(Gamestate.active_tasks.size()):
			var task = Gamestate.active_tasks.get(i)
			if task.turn_in == self:
				turn_in_warn.emit(task)


func _on_player_unhighlight(area: Area2D) -> void:
	if self == area:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "modulate:a", dullness, 0.2)
		tween.parallel().tween_property($Label, "modulate:a", 0.0, 0.2)
		# Check if I am a turn-in point for any tasks
		for i in range(Gamestate.active_tasks.size()):
			var task = Gamestate.active_tasks.get(i)
			if task.turn_in == self:
				turn_in_unwarn.emit(task)


func _on_entity_turn_in(task: CheckBox) -> void:
	# First let's restore any lost prereqs. 
	# (Would prefer to run this on _ready(), but it conflicts w/ HUD)
	for i in prerequisites.size():
		if prerequisites[i] == null:
			# Task pointer was lost in scene reload. Let's find it.
			for old_task in Gamestate.active_tasks:
				var task_data = Gamestate.active_tasks_data[old_task.name]
				if task_data["unlocks"].has(get_path()):
					# I'm flagged as "unlockable" by this task. I'll put this task back in my prereqs.
					prerequisites[i] = old_task
	# Now let's see if we can mark a prereq as complete
	if prerequisites.has(task):
		prerequisites.erase(task)
		print("Cleared task: " + task.name)
		if prerequisites.size() == 0:
			lock_message = ""
	else:
		print("Turned in " + task.name + " but didn't find it.")
