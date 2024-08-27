class_name SettingsMenu
extends Control

@onready var save_button : Button = $"%SAVE-BUTTON"

func _ready():
	setup_setting_updates()
	_load_settings_menu()
	save_button.pressed.connect(Psyoko.settings.save_settings_to_disk)
	
	main_audio_slider.mouse_exited.connect(main_audio_slider.release_focus)
	game_audio_slider.mouse_exited.connect(game_audio_slider.release_focus)
	ambient_audio_slider.mouse_exited.connect(ambient_audio_slider.release_focus)

@onready var resolution_option_button : OptionButton = $"%RESOLUTION-OPTION-BUTTON"
@onready var borderless_toggle_button : Button = $"%BORDERLESS-TOGGLE-BUTTON"

@onready var main_audio_slider : HSlider = $"%MAIN-AUDIO-SLIDER"
@onready var game_audio_slider : HSlider = $"%GAME-AUDIO-SLIDER"
@onready var ambient_audio_slider : HSlider = $"%AMBIENT-AUDIO-SLIDER"

@onready var input_scheme_option_button : OptionButton = $"%INPUTSCHEME-OPTION-BUTTON"


func setup_setting_updates() -> void:
	
	resolution_option_button.item_selected.connect(
		func(index):
			var res_text : String = resolution_option_button.get_item_text(resolution_option_button.selected)
			var res := Vector2i(res_text.left(res_text.find("x")).to_int(), res_text.right(res_text.find("x") + 1).to_int())
			
			Psyoko.settings.set_setting("resolution", res)
			#self.scale = Psyoko.SCREEN_SCALE / 5.0
	)
	
	borderless_toggle_button.toggled.connect(
		func(toggled_on):
			Psyoko.settings.set_setting("borderless", toggled_on)
	)
	
	main_audio_slider.value_changed.connect(
		func(value):
			Psyoko.settings.set_setting("main", value)
	)
	game_audio_slider.value_changed.connect(
		func(value):
			Psyoko.settings.set_setting("game", value)
	)
	ambient_audio_slider.value_changed.connect(
		func(value):
			Psyoko.settings.set_setting("ambient", value)
	)
	
	input_scheme_option_button.item_selected.connect(
		func(index):
			Psyoko.settings.set_setting("scheme", index)
	)


func _load_settings_menu() -> void:
	var res : Vector2 = Psyoko.settings.get_setting("resolution")
	var res_text : String = "%d x %d" % [res.x, res.y]
	var res_option_texts : Array[String] = []
	for idx in range(resolution_option_button.item_count):
		res_option_texts.append(resolution_option_button.get_item_text(idx))
	resolution_option_button.select(res_option_texts.find(res_text))
	borderless_toggle_button.button_pressed = Psyoko.settings.get_setting("borderless")

	main_audio_slider.value = Psyoko.settings.get_setting("main")
	game_audio_slider.value = Psyoko.settings.get_setting("game")
	ambient_audio_slider.value = Psyoko.settings.get_setting("ambient")

	input_scheme_option_button.select(Psyoko.settings.get_setting("scheme"))
	
	#self.scale = Psyoko.SCREEN_SCALE / 5
