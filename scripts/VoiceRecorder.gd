class_name VoiceRecorder
extends Node

signal answer_received(text: String)

# 语音识别组件 (使用Whisper插件)
var whisper_node: Node
var is_recording: bool = false
var fallback_input: LineEdit
var record_button: Button
var status_label: Label

func _ready():
	# 初始化Whisper插件
	setup_whisper()
	setup_fallback_input()
	setup_ui_controls()

func setup_whisper():
	# 尝试加载Whisper插件
	# 由于插件可能不可用，我们主要使用文本输入方案
	print("语音识别系统初始化中...")
	# whisper_node = load_whisper_addon()
	# if whisper_node:
	#     whisper_node.transcription_completed.connect(_on_transcription_completed)
	# else:
	print("使用文本输入备用方案")

func setup_fallback_input():
	# 创建文本输入备用方案
	fallback_input = LineEdit.new()
	fallback_input.placeholder_text = "请输入您的英文回答..."
	fallback_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fallback_input.text_submitted.connect(_on_text_submitted)
	add_child(fallback_input)
	fallback_input.hide()

func setup_ui_controls():
	# 创建录音按钮
	record_button = Button.new()
	record_button.text = "🎤 开始录音"
	record_button.pressed.connect(_on_record_button_pressed)
	add_child(record_button)
	record_button.hide()
	
	# 创建状态标签
	status_label = Label.new()
	status_label.text = "准备就绪"
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(status_label)
	status_label.hide()

func start_recording():
	show_recording_ui()
	
	if whisper_node and whisper_node.has_method("is_available") and whisper_node.is_available():
		# 使用语音识别
		is_recording = true
		whisper_node.start_recording()
		status_label.text = "🎤 正在录音... (10秒后自动停止)"
		record_button.text = "⏹️ 停止录音"
		
		# 10秒超时
		get_tree().create_timer(10.0).timeout.connect(_on_recording_timeout)
	else:
		# 使用文本输入备用方案
		show_text_input()

func stop_recording():
	if is_recording and whisper_node:
		is_recording = false
		whisper_node.stop_recording()
		status_label.text = "🔄 正在识别..."
		record_button.text = "🎤 开始录音"

func show_recording_ui():
	record_button.show()
	status_label.show()
	fallback_input.hide()

func show_text_input():
	fallback_input.show()
	fallback_input.grab_focus()
	status_label.text = "💬 请输入您的回答"
	record_button.hide()

func hide_all_ui():
	record_button.hide()
	status_label.hide()
	fallback_input.hide()

func _on_record_button_pressed():
	if is_recording:
		stop_recording()
	else:
		if whisper_node and whisper_node.has_method("start_recording"):
			is_recording = true
			whisper_node.start_recording()
			status_label.text = "🎤 正在录音..."
			record_button.text = "⏹️ 停止录音"
		else:
			show_text_input()

func _on_transcription_completed(text: String):
	is_recording = false
	record_button.text = "🎤 开始录音"
	
	if text.length() > 0:
		status_label.text = "✅ 识别完成: " + text
		hide_all_ui()
		answer_received.emit(text)
	else:
		# 识别失败，显示文本输入
		status_label.text = "❌ 识别失败，请手动输入"
		show_text_input()

func _on_text_submitted(text: String):
	if text.strip_edges().length() > 0:
		hide_all_ui()
		fallback_input.clear()
		answer_received.emit(text.strip_edges())
	else:
		status_label.text = "⚠️ 请输入有效回答"

func _on_recording_timeout():
	if is_recording:
		stop_recording()
		# 等待一秒后如果还没有结果就显示文本输入
		await get_tree().create_timer(1.0).timeout
		if not answer_received.is_connected(_on_answer_received):
			show_text_input()

func _on_answer_received(_text: String):
	# 处理超时等情况
	pass
