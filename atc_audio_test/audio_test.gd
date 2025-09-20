extends Control

@export var label : Label
@export var play_button : Button
@export var stream_player : AudioStreamPlayer

const TIMES =[ 4.91, 12.74, 20.23, 30.05, 37.26, 47.99, 58.56, 67.48, 76.99, 83.80, 90.80, 100.98, 106.47, 111.41, 121.36, 129, 133, 137.56, 143.7, 148.6, 156.2, 164.5, 173.3, 187.5, 192.8, 199.8, 208.7, 213, 224.8, ]

var time_clips_count
var times_deck
var times_deck_index = 0
var times_deck_count
var endtime : float = -1

func _ready() -> void:
	time_clips_count = len(TIMES)
	times_deck = range(len(TIMES))
	times_deck.shuffle()
	times_deck_count = len(times_deck)
	play_button.connect("pressed",func():
		if times_deck_index < times_deck_count:
			var i = times_deck[times_deck_index]
			times_deck_index += 1
			if i+1 < time_clips_count:
				endtime = TIMES[i+1]
			else:
				endtime = -1
			if times_deck_index > times_deck_count:
				play_button.disabled = true
			stream_player.play(TIMES[i])
		else:
			push_error("no more times left")
		label.text = "ATC clip #%d/%d" % [times_deck_index,times_deck_count]
	)
func _physics_process(_delta: float) -> void:
	if stream_player.playing:
		if endtime >= 0 and stream_player.get_playback_position() > endtime:
			stream_player.stop()
