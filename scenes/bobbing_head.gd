@tool
extends Node2D

## The sound to play
@export var audio_file: AudioStream

## The image to display
@export var image: Texture2D

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

## Any amplitudes below this are not considered when animating
@export var audio_mute_threshold: float = 0.0

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

var previous_mag: float = 0.0

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	audio.stream = audio_file
	audio.bus = bus
	audio.play()

	sprite.texture = image

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		sprite.texture = image
		return

	var spectrum: AudioEffectInstance = AudioServer.get_bus_effect_instance(bus_index, bus_effect_index)
	var spec: AudioEffectSpectrumAnalyzerInstance = spectrum as AudioEffectSpectrumAnalyzerInstance
	var mag: float = spec.get_magnitude_for_frequency_range(0, 10000).length()

	# mute the low end
	mag = (mag - audio_mute_threshold) / (1.0 - audio_mute_threshold)
	mag = clampf(mag, 0.0, 1.0)

	# use pow to increase overall volume without bringing up the low end
	mag = pow(mag, pow_amount)

	# increase high values and lower low values
	if smooth_step_constant != 0.0:
		mag = smooth_step(mag, smooth_step_constant)

	var lerped_mag: float = lerp_smooth(previous_mag, mag, delta, lerp_half_life)

	var new_scale: float = lerpf(1.0, max_scale, lerped_mag)
	sprite.scale = Vector2(new_scale, new_scale)

	var mat: ShaderMaterial = sprite.material
	mat.set_shader_parameter("saturation", lerped_mag)

	previous_mag = lerped_mag

# From https://mastodon.social/@acegikmo/111931616951667619
func lerp_smooth(start: float, goal: float, delta_time: float, half_life: float) -> float:
	return goal + ((start - goal) * pow(2, ( - delta_time / half_life)))

func smooth_step(x: float, c: float) -> float:
	return ((c + 1) * pow(x, c)) - (c * pow(x, c + 1))
