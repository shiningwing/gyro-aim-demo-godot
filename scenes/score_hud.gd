extends Control


@export var timer_length: float = 60.0

var timer: float = 0.0
var timer_running := false
var timer_finished := false
var timer_ticker: float = 0.0

var score: int = 0
var score_streak: int = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	$VersionLabel.text = str(ProjectSettings.get_setting("application/config/version"))
	$StartSection.visible = true
	$ScoreTimerSection.visible = false
	$FinalScore.visible = false
	$FinalScore/Title.text = str("Final Score - ", timer_length,  " Second Game")
	$StartSection/Value.text = str("The game will last ", timer_length, " seconds.")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if timer_running:
		if timer < timer_length:
			timer += delta
			$ScoreTimerSection/ScoreContainer/Value.text = str(score)
			$FinalScore/Value.text = str(score)
			$ScoreTimerSection/StreakContainer/Value.text = str("x", score_streak)
			$ScoreTimerSection/TimerContainer/Value.text = str(
					ceili(timer_length -timer))
			if (timer_length - timer) <= 6.0:
				timer_ticker += delta
				if timer_ticker >= 1.0:
					$TickerSound.play()
					timer_ticker = 0.0
		else:
			timer_ticker = 0.0
			timer_running = false
			timer_finished = true
			$ScoreTimerSection.visible = false
			$FinalScore.visible = true
			$FinishedSound.play()

func start_timer():
	$StartSection.visible = false
	$FinalScore.visible = false
	$ScoreTimerSection.visible = true
	timer_running = true
	
