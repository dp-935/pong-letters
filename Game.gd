extends Node2D

var target_word := "PONG"
var current_index := 0
var word_completed := false
var is_game_over := false
var game_started := false
var demo_active := false
var on_start_screen := true
var score := 0

var paddle_speed := 650.0
var dodge_speed := 2400.0
var dodge_distance_from_bottom := 125.0
var button_spacing := 130.0

var master_key_enabled := true

var timeout_message_active := false
var current_timeout_message := ""

var jumpscare_playing := false

var default_button_color := Color(1, 1, 1, 1)
var correct_button_color := Color(0.35, 1.0, 0.35, 1)
var wrong_button_color := Color(1.0, 0.25, 0.25, 1)

var timeout_messages = [
	"you suck",
	"get better",
	"boo!",
	"granny",
	"unc",
	"skill issue",
	"washed",
	"too slow",
	"bro sold",
	"pack it up",
	"yikes",
	"NPC timing",
	"not locked in",
	"fumbled",
	"cooked",
	"try again lil bro",
	"zero motion",
	"be serious",
	"sleepy taps",
	"grandma speed"
]

@onready var start_screen_music = $StartScreenMusic
@onready var correct_letter_sound = $CorrectLetterSound
@onready var wrong_letter_sound = $WrongLetterSound
@onready var game_over_sound = $GameOverSound

@onready var start_panel = $UI/StartPanel
@onready var start_button = $UI/StartPanel/StartButton

@onready var tutorial_overlay = $UI/TutorialOverlay
@onready var corner_touch_zone = $UI/CornerTouchZone

@onready var progress_label = $UI/ProgressLabel
@onready var game_over_label = $UI/GameOverLabel
@onready var final_score_label = $UI/FinalScoreLabel
@onready var score_label = $UI/ScoreLabel
@onready var countdown_label = $UI/CountdownLabel
@onready var return_timer_label = $UI/ReturnTimerLabel
@onready var restart_button = $UI/RestartButton
@onready var main_menu_button = $UI/MainMenuButton

@onready var p_button = $UI/PButton
@onready var o_button = $UI/OButton
@onready var n_button = $UI/NButton
@onready var g_button = $UI/GButton

@onready var top_paddle = $TopPaddle
@onready var bottom_paddle = $BottomPaddle
@onready var ball = $Ball

func _ready():
	randomize()

	on_start_screen = true
	game_started = false
	demo_active = false
	is_game_over = false
	jumpscare_playing = false

	start_panel.visible = true
	start_panel.position = Vector2.ZERO
	start_button.disabled = false

	tutorial_overlay.visible = false
	corner_touch_zone.visible = true

	game_over_label.visible = false
	final_score_label.visible = false
	countdown_label.visible = false
	score_label.visible = false
	return_timer_label.visible = false
	restart_button.visible = false
	main_menu_button.visible = false

	set_word_ui_visible(false)

	current_index = 0
	word_completed = false
	score = 0

	update_progress_label()
	update_score_label()
	reset_button_colors()

	ball.reset_to_demo_start()

	start_button.pressed.connect(start_game_from_start_screen)
	restart_button.pressed.connect(restart_game)
	main_menu_button.pressed.connect(go_to_main_menu)
	corner_touch_zone.pressed.connect(show_tutorial_overlay)

	play_music_muffled()

func start_game_from_start_screen():
	make_music_clear()
	start_button.disabled = true
	corner_touch_zone.visible = false

	score = 0
	current_index = 0
	word_completed = false
	is_game_over = false
	game_started = false
	demo_active = false
	timeout_message_active = false
	current_timeout_message = ""
	jumpscare_playing = false

	game_over_label.visible = false
	final_score_label.visible = false
	countdown_label.visible = false
	score_label.visible = true
	return_timer_label.visible = false
	restart_button.visible = false
	main_menu_button.visible = false
	tutorial_overlay.visible = false

	update_progress_label()
	update_score_label()
	reset_button_colors()

	await slide_start_screen_away()

	start_panel.visible = false
	on_start_screen = false

	start_intro_sequence()

func restart_game():
	make_music_clear()

	score = 0
	current_index = 0
	word_completed = false
	is_game_over = false
	game_started = false
	demo_active = true
	on_start_screen = false
	timeout_message_active = false
	current_timeout_message = ""
	jumpscare_playing = false

	corner_touch_zone.visible = false

	game_over_label.visible = false
	final_score_label.visible = false
	countdown_label.visible = false
	return_timer_label.visible = false
	restart_button.visible = false
	main_menu_button.visible = false
	score_label.visible = true
	tutorial_overlay.visible = false

	set_word_ui_visible(false)

	update_progress_label()
	update_score_label()
	reset_button_colors()

	start_intro_sequence()

func go_to_main_menu():
	score = 0
	current_index = 0
	word_completed = false
	is_game_over = false
	game_started = false
	demo_active = false
	on_start_screen = true
	timeout_message_active = false
	current_timeout_message = ""
	jumpscare_playing = false

	game_over_label.visible = false
	final_score_label.visible = false
	countdown_label.visible = false
	score_label.visible = false
	return_timer_label.visible = false
	restart_button.visible = false
	main_menu_button.visible = false
	tutorial_overlay.visible = false

	set_word_ui_visible(false)

	update_progress_label()
	update_score_label()
	reset_button_colors()

	ball.reset_to_demo_start()

	start_panel.visible = true
	start_panel.position = Vector2.ZERO
	start_button.disabled = false
	corner_touch_zone.visible = true

	play_music_muffled()

func slide_start_screen_away():
	var screen_size = get_viewport_rect().size

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(
		start_panel,
		"position",
		Vector2(-screen_size.x, 0),
		0.8
	)

	await tween.finished

func play_music_muffled():
	start_screen_music.bus = "MuffledMusic"
	start_screen_music.volume_db = -8

	if not start_screen_music.playing:
		start_screen_music.play()

func make_music_clear():
	start_screen_music.bus = "Music"
	start_screen_music.volume_db = -4

	if not start_screen_music.playing:
		start_screen_music.play()

func stop_music():
	start_screen_music.stop()

func play_correct_sound():
	correct_letter_sound.stop()
	correct_letter_sound.play()

func play_wrong_sound():
	wrong_letter_sound.stop()
	wrong_letter_sound.play()

func play_game_over_sound():
	game_over_sound.stop()
	game_over_sound.play()

func show_tutorial_overlay():
	if jumpscare_playing:
		return

	if not on_start_screen:
		return

	jumpscare_playing = true

	set_word_ui_visible(false)
	return_timer_label.visible = false

	stop_music()

	tutorial_overlay.visible = true
	tutorial_overlay.play()

	await tutorial_overlay.finished

	tutorial_overlay.stop()
	tutorial_overlay.visible = false

	jumpscare_playing = false

	if on_start_screen:
		play_music_muffled()

func _input(event):
	if not master_key_enabled:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_M:
			complete_word_for_testing()

func complete_word_for_testing():
	if is_game_over:
		return

	if on_start_screen:
		return

	if not game_started:
		return

	if word_completed:
		return

	current_index = target_word.length()
	word_completed = true
	update_progress_label()
	set_word_ui_visible(false)
	return_timer_label.visible = false
	timeout_message_active = false
	current_timeout_message = ""

	print("MASTER KEY: PONG completed")

func start_intro_sequence():
	demo_active = true
	game_started = false
	is_game_over = false
	timeout_message_active = false
	current_timeout_message = ""

	ball.reset_to_demo_start()

	await get_tree().create_timer(2.0).timeout

	if is_game_over or on_start_screen:
		return

	countdown_label.visible = true

	countdown_label.text = "3"
	await get_tree().create_timer(1.0).timeout

	if is_game_over or on_start_screen:
		return

	countdown_label.text = "2"
	await get_tree().create_timer(1.0).timeout

	if is_game_over or on_start_screen:
		return

	countdown_label.text = "1"
	await get_tree().create_timer(1.0).timeout

	if is_game_over or on_start_screen:
		return

	countdown_label.text = "GO!"
	await get_tree().create_timer(0.5).timeout

	if is_game_over or on_start_screen:
		return

	countdown_label.visible = false

	current_index = 0
	word_completed = false
	update_progress_label()
	reset_button_colors()

	set_word_ui_visible(true)
	shuffle_buttons()

	demo_active = false
	game_started = true

func set_word_ui_visible(value: bool):
	progress_label.visible = value
	p_button.visible = value
	o_button.visible = value
	n_button.visible = value
	g_button.visible = value

func reset_button_colors():
	p_button.modulate = default_button_color
	o_button.modulate = default_button_color
	n_button.modulate = default_button_color
	g_button.modulate = default_button_color

func get_button_for_letter(letter: String) -> Button:
	if letter == "P":
		return p_button
	elif letter == "O":
		return o_button
	elif letter == "N":
		return n_button
	else:
		return g_button

func flash_wrong_button(button: Button):
	button.modulate = wrong_button_color
	await get_tree().create_timer(0.2).timeout
	reset_button_colors()

func update_return_timer(ball_position: Vector2, ball_velocity_y: float):
	if on_start_screen:
		return_timer_label.visible = false
		timeout_message_active = false
		return

	if demo_active:
		return_timer_label.visible = false
		timeout_message_active = false
		return

	if not game_started:
		return_timer_label.visible = false
		timeout_message_active = false
		return

	if is_game_over:
		return_timer_label.visible = false
		timeout_message_active = false
		return

	if word_completed:
		return_timer_label.visible = false
		timeout_message_active = false
		return

	if ball_velocity_y <= 0:
		return_timer_label.visible = false
		timeout_message_active = false
		return

	var screen_size = get_viewport_rect().size
	var dodge_y = screen_size.y - dodge_distance_from_bottom
	var distance_until_dodge = dodge_y - ball_position.y

	if distance_until_dodge <= 0:
		if not timeout_message_active:
			current_timeout_message = timeout_messages.pick_random()
			timeout_message_active = true

		return_timer_label.text = current_timeout_message
		return_timer_label.visible = true
		return

	timeout_message_active = false
	current_timeout_message = ""

	var time_left = distance_until_dodge / ball_velocity_y
	return_timer_label.text = "Time: " + str(snapped(time_left, 0.1))
	return_timer_label.visible = true

func move_paddles_toward_ball(ball_position: Vector2, ball_velocity_y: float, delta: float):
	if on_start_screen:
		return

	var screen_size = get_viewport_rect().size

	var top_target_x = ball_position.x - top_paddle.size.x / 2

	top_paddle.position.x = move_toward(
		top_paddle.position.x,
		top_target_x,
		paddle_speed * delta
	)

	var bottom_target_x: float
	var bottom_move_speed := paddle_speed

	if demo_active:
		bottom_target_x = ball_position.x - bottom_paddle.size.x / 2
	else:
		if word_completed:
			bottom_target_x = ball_position.x - bottom_paddle.size.x / 2
			bottom_move_speed = paddle_speed
		else:
			var ball_is_moving_down = ball_velocity_y > 0
			var ball_is_almost_at_bottom = ball_position.y > screen_size.y - dodge_distance_from_bottom

			if ball_is_moving_down and ball_is_almost_at_bottom:
				if ball_position.x < screen_size.x / 2:
					bottom_target_x = screen_size.x - bottom_paddle.size.x
				else:
					bottom_target_x = 0

				bottom_move_speed = dodge_speed
			else:
				bottom_target_x = ball_position.x - bottom_paddle.size.x / 2
				bottom_move_speed = paddle_speed

	bottom_paddle.position.x = move_toward(
		bottom_paddle.position.x,
		bottom_target_x,
		bottom_move_speed * delta
	)

	top_paddle.position.x = clamp(top_paddle.position.x, 0, screen_size.x - top_paddle.size.x)
	bottom_paddle.position.x = clamp(bottom_paddle.position.x, 0, screen_size.x - bottom_paddle.size.x)

func is_ball_over_top_paddle(ball_x: float) -> bool:
	return ball_x >= top_paddle.position.x and ball_x <= top_paddle.position.x + top_paddle.size.x

func is_ball_over_bottom_paddle(ball_x: float) -> bool:
	return ball_x >= bottom_paddle.position.x and ball_x <= bottom_paddle.position.x + bottom_paddle.size.x

func press_letter(letter: String):
	if is_game_over:
		return

	if on_start_screen:
		return

	if not game_started:
		return

	if word_completed:
		return

	var clicked_button = get_button_for_letter(letter)
	var needed_letter = target_word[current_index]

	if letter == needed_letter:
		play_correct_sound()
		clicked_button.modulate = correct_button_color
		current_index += 1
	else:
		play_wrong_sound()
		current_index = 0
		flash_wrong_button(clicked_button)

	if current_index >= target_word.length():
		word_completed = true
		update_progress_label()
		set_word_ui_visible(false)
		return_timer_label.visible = false
		timeout_message_active = false
		current_timeout_message = ""
		return

	update_progress_label()

func update_progress_label():
	var progress_text := ""

	for i in range(target_word.length()):
		if i < current_index:
			progress_text += target_word[i] + " "
		else:
			progress_text += "_ "

	progress_label.text = progress_text

func reset_word():
	current_index = 0
	word_completed = false
	timeout_message_active = false
	current_timeout_message = ""
	update_progress_label()
	reset_button_colors()
	shuffle_buttons()
	set_word_ui_visible(true)

func add_score():
	score += 1
	update_score_label()

func update_score_label():
	score_label.text = "Score: " + str(score)

func update_final_score_label():
	final_score_label.text = "Final Score: " + str(score)

func shuffle_buttons():
	var buttons = [p_button, o_button, n_button, g_button]
	var screen_size = get_viewport_rect().size

	var randomness = clamp(score / 10.0, 0.0, 1.0)

	var easy_positions: Array[Vector2] = [
		Vector2(screen_size.x * 0.18, screen_size.y * 0.35),
		Vector2(screen_size.x * 0.62, screen_size.y * 0.35),
		Vector2(screen_size.x * 0.18, screen_size.y * 0.65),
		Vector2(screen_size.x * 0.62, screen_size.y * 0.65)
	]

	easy_positions.shuffle()

	var placed_positions: Array[Vector2] = []

	var min_x := 60
	var max_x := int(screen_size.x - 160)
	var min_y := 220
	var max_y := int(screen_size.y - 320)

	for i in range(buttons.size()):
		var final_position: Vector2 = easy_positions[i]
		var found_safe_position := false

		for attempt in range(50):
			var random_position := Vector2(
				randi_range(min_x, max_x),
				randi_range(min_y, max_y)
			)

			var mixed_position: Vector2 = easy_positions[i].lerp(random_position, randomness)

			if is_button_position_safe(mixed_position, placed_positions):
				final_position = mixed_position
				found_safe_position = true
				break

		if not found_safe_position:
			final_position = easy_positions[i]

		buttons[i].position = final_position
		placed_positions.append(final_position)

func is_button_position_safe(new_position: Vector2, placed_positions: Array[Vector2]) -> bool:
	for placed_position in placed_positions:
		if new_position.distance_to(placed_position) < button_spacing:
			return false

	return true

func game_over():
	if is_game_over:
		return

	if on_start_screen:
		return

	is_game_over = true
	update_final_score_label()

	stop_music()
	play_game_over_sound()

	game_over_label.visible = true
	final_score_label.visible = true
	restart_button.visible = true
	main_menu_button.visible = true
	return_timer_label.visible = false

	set_word_ui_visible(false)
	print("GAME OVER")

func _on_p_button_pressed():
	press_letter("P")

func _on_o_button_pressed():
	press_letter("O")

func _on_n_button_pressed():
	press_letter("N")

func _on_g_button_pressed():
	press_letter("G")
