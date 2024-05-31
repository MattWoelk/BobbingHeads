extends Node2D

## The sound to play
@export var audio_file: AudioStream

## The name of the audio bus that we want to play this sound in.
@export var bus: String

## The index of that audio bus (you must make it match). 0-indexed.
@export var bus_index: int

## The effect index on that bus of the Spectrum Analyzer (make one, then set this to match). 0-indexed.
@export var bus_effect_index: int

## The max scale to set this sprite when animating
@export var max_scale: float = 2.0

## The lerp half-life, in seconds
@export var lerp_half_life: float = 0.05

## Raise the volume to this power to get a different animation
## Set this to 1 to have it do nothing
@export var pow_amount: float = 1.0

## 1.5 means we increase the animation force of values above 0.2 (and shrink those below)
## 2.0 means we do a classic smoothstep, so values below 0.5 are muted, and above are increased
## 3.2 means the value threshold is 0.8
@export var smooth_step_constant: float = 1.5

## The audio file you want to play.
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer

## The sprite you want to animate
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	audio.stream = audio_file
	audio.bus = bus
	audio.play()

func _process(delta: float) -> void:
	var spectrum: AudioEffectInstance = AudioServer.get_bus_effect_instance(bus_index, bus_effect_index)
	var spec: AudioEffectSpectrumAnalyzerInstance = spectrum as AudioEffectSpectrumAnalyzerInstance
	var mag: float = spec.get_magnitude_for_frequency_range(0, 10000).length()
	mag = pow(mag, pow_amount)
	mag = smooth_step(mag, smooth_step_constant)

	var animated_scale: float = lerpf(1.0, max_scale, mag)
	var current_scale: float = sprite.scale.x
	var new_scale: float = lerp_smooth(current_scale, animated_scale, delta, lerp_half_life)
	sprite.scale = Vector2(new_scale, new_scale)

# From https://mastodon.social/@acegikmo/111931616951667619
func lerp_smooth(start: float, goal: float, delta_time: float, half_life: float) -> float:
	return goal + ((start - goal) * pow(2, ( - delta_time / half_life)))

func smooth_step(x: float, c: float) -> float:
	return ((c + 1) * pow(x, c)) - (c * pow(x, c + 1))