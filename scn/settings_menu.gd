class_name SettingsMenu
extends Control

var config : ConfigFile = ConfigFile.new()

@onready var save_button : Button = $"%SAVE-BUTTON"

func _ready():
	config = Psyoko.settings_config
	setup_setting_updates()
	_load_settings()
	save_button.pressed.connect(_save_settings)

@onready var resolution_option_button : OptionButton = $"%RESOLUTION-OPTION-BUTTON"
@onready var borderless_toggle_button : Button = $"%BORDERLESS-TOGGLE-BUTTON"

@onready var main_audio_slider : HSlider = $"%MAIN-AUDIO-SLIDER"
@onready var game_audio_slider : HSlider = $"%GAME-AUDIO-SLIDER"
@onready var ambient_audio_slider : HSlider = $"%AMBIENT-AUDIO-SLIDER"

@onready var input_scheme_option_button : OptionButton = $"%INPUTSCHEME-OPTION-BUTTON"


func setup_setting_updates() -> void:
	pass


func _load_settings() -> void:
	var res : Vector2 = config.get_value("video", "resolution", Vector2(960, 540))
	var res_text : String = "%d x %d" % [res.x, res.y]
	var res_option_texts : Array[String] = []
	for idx in range(resolution_option_button.item_count):
		res_option_texts.append(resolution_option_button.get_item_text(idx))
	resolution_option_button.select(res_option_texts.find(res_text))
	borderless_toggle_button.button_pressed = config.get_value("video", "borderless", false)

	main_audio_slider.value = config.get_value("audio", "main", 0.5)
	game_audio_slider.value = config.get_value("audio", "game", 0.5)
	ambient_audio_slider.value = config.get_value("audio", "ambient", 0.5)

	input_scheme_option_button.select(config.get_value("input", "scheme", 0))

func _save_settings() -> void:
	var res_text : String = resolution_option_button.get_item_text(resolution_option_button.selected)
	var res : Vector2 = Vector2(res_text.left(res_text.find("x")).to_int(), res_text.right(res_text.find("x") + 1).to_int())
	config.set_value("video", "resolution", res)
	config.set_value("video", "borderless", borderless_toggle_button.button_pressed)

	config.set_value("audio", "main", main_audio_slider.value)
	config.set_value("audio", "game", game_audio_slider.value)
	config.set_value("audio", "ambient", ambient_audio_slider.value)

	config.set_value("input", "scheme", input_scheme_option_button.selected)

	Psyoko.settings_config = config
	var err = config.save("user://settings.cfg")
	if err != OK:
		printerr("Error saving settings.cfg: %s" % err)
		return

