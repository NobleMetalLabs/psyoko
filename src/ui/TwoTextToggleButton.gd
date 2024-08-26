extends Button

@export var on_text : String = "On"
@export var off_text : String = "Off"

func _ready():
	self.toggled.connect(func toggle_text(on : bool) -> void:
		self.text = on_text if on else off_text
	)
