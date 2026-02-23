extends Node

@export var current_day: int = 0
@export var current_time: int = 420 # in minutes, this is 7am
@export var current_energy: int = 90
@export var active_tasks: Array[CheckBox]
@export var active_tasks_data: Dictionary
@export var frozen_scenes: Dictionary
