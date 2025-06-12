class_name GameManager
extends Node

# 游戏状态
enum State { READY, ASKING, LISTENING, EVALUATING, FEEDBACK, COMPLETE }
var current_state: State = State.READY
var current_question: int = 0
var score: int = 0
var wrong_count: int = 0

# 组件引用
@onready var npc: NPCController = $GameScene/NPCController
@onready var voice: VoiceRecorder = $VoiceRecorder
@onready var evaluator: AnswerEvaluator = $AnswerEvaluator
@onready var ui: MainUI = $UI

# 题库数据
var questions = [
	{
		"text": "What's the purpose of your visit?",
		"keywords": ["tourism", "tourist", "vacation", "holiday", "study", "business"],
		"forbidden": ["work", "job", "immigrate", "permanent"]
	},
	{
		"text": "Where will you stay?",
		"keywords": ["hotel", "hilton", "marriott", "booking", "reservation"],
		"forbidden": ["friend", "relative", "permanently"]
	},
	{
		"text": "How long will you stay?",
		"keywords": ["day", "week", "month", "1", "2", "3", "4", "5"],
		"forbidden": ["forever", "permanent", "long time"]
	}
]

func _ready():
	# 连接信号
	voice.answer_received.connect(_on_answer_received)
	ui.start_game_pressed.connect(_on_start_game)
	ui.restart_game_pressed.connect(_on_restart_game)
	
	# 显示开始界面
	ui.show_start_screen()

func _on_start_game():
	start_game()

func _on_restart_game():
	restart_game()

func start_game():
	current_state = State.ASKING
	current_question = 0
	score = 0
	wrong_count = 0
	ask_question()

func restart_game():
	start_game()

func ask_question():
	if current_question >= questions.size():
		game_complete()
		return
	
	var question = questions[current_question]
	npc.ask_question(question.text)
	ui.show_question(question.text)
	
	# 开始录音
	current_state = State.LISTENING
	voice.start_recording()

func _on_answer_received(answer_text: String):
	if current_state != State.LISTENING:
		return
		
	current_state = State.EVALUATING
	
	var question = questions[current_question]
	var result = evaluator.evaluate_answer(answer_text, question)
	
	show_feedback(result)
	
	if result.passed:
		score += 1
		current_question += 1
		# 延迟后问下一题
		await get_tree().create_timer(2.0).timeout
		ask_question()
	else:
		wrong_count += 1
		if wrong_count >= 2:
			game_over()
		else:
			# 重试当前题目
			await get_tree().create_timer(2.0).timeout
			ask_question()

func show_feedback(result):
	current_state = State.FEEDBACK
	npc.show_reaction(result.passed)
	ui.show_feedback(result.message, result.passed)

func game_complete():
	current_state = State.COMPLETE
	ui.show_success_screen()
	npc.show_success()

func game_over():
	current_state = State.COMPLETE
	ui.show_failure_screen()
	npc.show_failure()
