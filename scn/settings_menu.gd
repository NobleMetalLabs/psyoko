class_name SettingsMenu
extends Control

@onready var save_button : Button = $"%SAVE-BUTTON"

func _ready():
	setup_custom_input_field_maps()
	setup_setting_updates()
	_load_settings_menu()
	save_button.pressed.connect(Psyoko.settings.save_settings_to_disk)
	
	main_audio_slider.mouse_exited.connect(main_audio_slider.release_focus)
	game_audio_slider.mouse_exited.connect(game_audio_slider.release_focus)
	ambient_audio_slider.mouse_exited.connect(ambient_audio_slider.release_focus)

	$"%SETTINGS-TABS".tab_changed.connect(
		func(tab_idx : int) -> void:
			if tab_idx == 1:
				$"AudioDemo".fade_in() 
			else:
				$"AudioDemo".fade_out()
	)

@onready var resolution_option_button : OptionButton = $"%RESOLUTION-OPTION-BUTTON"
@onready var borderless_toggle_button : Button = $"%BORDERLESS-TOGGLE-BUTTON"

@onready var main_audio_slider : HSlider = $"%MAIN-AUDIO-SLIDER"
@onready var game_audio_slider : HSlider = $"%GAME-AUDIO-SLIDER"
@onready var ambient_audio_slider : HSlider = $"%AMBIENT-AUDIO-SLIDER"

@onready var input_scheme_option_button : OptionButton = $"%INPUTSCHEME-OPTION-BUTTON"
@onready var input_custom_input_field_stack : VBoxContainer = $"%CUSTOM-INPUT-FIELD-STACK"

var action_key_to_custom_field : Dictionary = {}

func setup_custom_input_field_maps() -> void:
	for child : Node in input_custom_input_field_stack.get_children():
		var action_key : String = child.get_name().to_lower()
		var button : Button = child.get_node("Button")
		action_key_to_custom_field[action_key] = button

func setup_setting_updates() -> void:
	
	resolution_option_button.item_selected.connect(
		func(index : int) -> void:
			var res_text : String = resolution_option_button.get_item_text(index)
			var res := Vector2i(res_text.left(res_text.find("x")).to_int(), res_text.right(res_text.find("x") + 1).to_int())
			
			Psyoko.settings.set_setting("resolution", res)
			#self.scale = Psyoko.SCREEN_SCALE / 5.0
	)
	
	borderless_toggle_button.toggled.connect(
		func(toggled_on : bool) -> void:
			Psyoko.settings.set_setting("borderless", toggled_on)
	)
	
	main_audio_slider.value_changed.connect(
		func(value : float) -> void:
			Psyoko.settings.set_setting("main", value)
	)
	game_audio_slider.value_changed.connect(
		func(value : float) -> void:
			Psyoko.settings.set_setting("game", value)
	)
	ambient_audio_slider.value_changed.connect(
		func(value : float) -> void:
			Psyoko.settings.set_setting("ambient", value)
	)
	
	input_scheme_option_button.item_selected.connect(
		func (index : int) -> void:
			Psyoko.settings.set_setting("scheme", index)
			refresh_custom_input_fields()
	)

	for action_key : StringName in action_key_to_custom_field.keys():
		var custom_input_field_button : Button = action_key_to_custom_field[action_key]
		custom_input_field_button.pressed.connect(
			func() -> void:
				custom_input_key_to_set = action_key
				latch_key_input = true 
		)

var custom_input_key_to_set : StringName = ""
var latch_key_input : bool = false
func _input(event: InputEvent) -> void:
	if not latch_key_input: return
	if not event is InputEventKey: return
	var key_event : InputEventKey = event as InputEventKey
	if key_event.is_pressed():
		var dropdown_index : int = Psyoko.settings.get_setting("scheme")
		Psyoko.settings.set_setting("input_%s_pl_%s_keycode" % [dropdown_index, custom_input_key_to_set], key_event.keycode)
		latch_key_input = false
		refresh_custom_input_fields()

func refresh_custom_input_fields() -> void:
	var dropdown_index : int = Psyoko.settings.get_setting("scheme")
	var custom_fields_disabled : bool = (dropdown_index < (input_scheme_option_button.item_count - 1))
	for action_key : StringName in action_key_to_custom_field.keys():
		var field_button : Button = action_key_to_custom_field[action_key]
		var action_keycode : Key = Psyoko.settings.get_setting("input_%s_pl_%s_keycode" % [dropdown_index, action_key])
		var d_event : InputEventKey = InputEventKey.new()
		d_event.keycode = action_keycode
		field_button.text = d_event.as_text_keycode()
		field_button.disabled = custom_fields_disabled
		if not latch_key_input: field_button.button_pressed = false

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

	var scheme_value : int = Psyoko.settings.get_setting("scheme")
	input_scheme_option_button.select(scheme_value)
	refresh_custom_input_fields()
	
	#self.scale = Psyoko.SCREEN_SCALE / 5
