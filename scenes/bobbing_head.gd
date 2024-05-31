extends Node2D

@onready var audio: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	audio.play()

func _process(delta: float) -> void:
	audio.stream
	audio.get_stream_playback()
	audio.get_playback_position()