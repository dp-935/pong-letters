extends Area2D

var velocity := Vector2(230, 430)
var ball_radius := 15

var speed_increase := 1.03
var max_ball_speed := 720.0

var min_bounce_angle := 15.0
var max_bounce_angle := 42.0

@onready var ball_hit_sound = get_parent().get_node("BallHitSound")

func _ready():
	reset_to_demo_start()

func reset_to_demo_start():
	var screen_size = get_viewport_rect().size
	position = Vector2(screen_size.x / 2, screen_size.y / 2)
	velocity = Vector2(230, 430)

func play_ball_hit_sound():
	ball_hit_sound.stop()
	ball_hit_sound.play()

func increase_ball_speed():
	var new_speed = velocity.length() * speed_increase

	if new_speed > max_ball_speed:
		new_speed = max_ball_speed

	velocity = velocity.normalized() * new_speed

func bounce_with_random_angle(y_direction: int, should_speed_up: bool):
	var speed = velocity.length()

	if should_speed_up:
		speed *= speed_increase

	if speed > max_ball_speed:
		speed = max_ball_speed

	var angle_degrees = randf_range(min_bounce_angle, max_bounce_angle)
	var angle_radians = deg_to_rad(angle_degrees)

	var x_direction = 1

	if randf() < 0.5:
		x_direction = -1

	var new_x = sin(angle_radians) * speed * x_direction
	var new_y = cos(angle_radians) * speed * y_direction

	velocity = Vector2(new_x, new_y)

func add_wall_bounce_variation():
	velocity.y += randf_range(-45.0, 45.0)

	if velocity.length() > max_ball_speed:
		velocity = velocity.normalized() * max_ball_speed

func _process(delta):
	var game = get_parent()

	if game.jumpscare_playing:
		return

	if game.on_start_screen:
		return

	if game.is_game_over:
		return

	if not game.demo_active and not game.game_started:
		return

	position += velocity * delta

	var screen_size = get_viewport_rect().size

	game.update_return_timer(position, velocity.y)
	game.move_paddles_toward_ball(position, velocity.y, delta)

	if position.x <= ball_radius:
		position.x = ball_radius
		velocity.x *= -1
		add_wall_bounce_variation()

	if position.x >= screen_size.x - ball_radius:
		position.x = screen_size.x - ball_radius
		velocity.x *= -1
		add_wall_bounce_variation()

	if position.y <= 90:
		position.y = 90

		if game.is_ball_over_top_paddle(position.x):
			play_ball_hit_sound()

			if game.demo_active:
				bounce_with_random_angle(1, false)
			else:
				bounce_with_random_angle(1, true)

				if game.word_completed:
					game.reset_word()
		else:
			if game.demo_active:
				bounce_with_random_angle(1, false)
			else:
				game.game_over()

	if position.y >= screen_size.y - 90:
		position.y = screen_size.y - 90

		if game.demo_active:
			play_ball_hit_sound()
			bounce_with_random_angle(-1, false)
		else:
			if game.word_completed and game.is_ball_over_bottom_paddle(position.x):
				play_ball_hit_sound()
				bounce_with_random_angle(-1, true)
				game.add_score()
			else:
				game.game_over()
