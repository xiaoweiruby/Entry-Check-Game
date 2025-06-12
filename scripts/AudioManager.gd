class_name AudioManager
extends Node

# 音频播放器节点
@onready var music_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var sfx_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var voice_player: AudioStreamPlayer = AudioStreamPlayer.new()

# 音频资源路径
const AUDIO_PATH = "res://audio/"
const MUSIC_PATH = AUDIO_PATH + "music/"
const SFX_PATH = AUDIO_PATH + "sfx/"
const VOICE_PATH = AUDIO_PATH + "voice/"

# 音量设置
var master_volume: float = 1.0
var music_volume: float = 0.7
var sfx_volume: float = 0.8
var voice_volume: float = 1.0

# 音频状态
var is_music_enabled: bool = true
var is_sfx_enabled: bool = true
var is_voice_enabled: bool = true

# 当前播放的音乐
var current_music: String = ""

func _ready():
    # 添加音频播放器到场景树
    add_child(music_player)
    add_child(sfx_player)
    add_child(voice_player)
    
    # 设置音频播放器属性
    music_player.name = "MusicPlayer"
    sfx_player.name = "SFXPlayer"
    voice_player.name = "VoicePlayer"
    
    # 音乐播放器设置为循环
    music_player.finished.connect(_on_music_finished)
    
    # 设置初始音量
    update_volumes()
    
    # 加载音频设置
    load_audio_settings()

func _on_music_finished():
    # 音乐播放完毕后重新播放（循环）
    if is_music_enabled and not current_music.is_empty():
        play_music(current_music)

# 播放背景音乐
func play_music(music_name: String, fade_in: bool = true):
    if not is_music_enabled:
        return
    
    var music_path = MUSIC_PATH + music_name + ".ogg"
    var audio_stream = load(music_path) as AudioStream
    
    if audio_stream == null:
        print("警告：无法加载音乐文件: ", music_path)
        return
    
    current_music = music_name
    music_player.stream = audio_stream
    
    if fade_in:
        music_player.volume_db = -80.0
        music_player.play()
        
        var tween = create_tween()
        var target_volume = linear_to_db(music_volume * master_volume)
        tween.tween_property(music_player, "volume_db", target_volume, 1.0)
    else:
        music_player.play()

# 停止背景音乐
func stop_music(fade_out: bool = true):
    if not music_player.playing:
        return
    
    if fade_out:
        var tween = create_tween()
        tween.tween_property(music_player, "volume_db", -80.0, 1.0)
        tween.tween_callback(music_player.stop)
        tween.tween_callback(func(): current_music = "")
    else:
        music_player.stop()
        current_music = ""

# 播放音效
func play_sfx(sfx_name: String, volume_scale: float = 1.0):
    if not is_sfx_enabled:
        return
    
    var sfx_path = SFX_PATH + sfx_name + ".ogg"
    var audio_stream = load(sfx_path) as AudioStream
    
    if audio_stream == null:
        print("警告：无法加载音效文件: ", sfx_path)
        return
    
    # 创建临时音频播放器用于播放音效
    var temp_player = AudioStreamPlayer.new()
    add_child(temp_player)
    temp_player.stream = audio_stream
    temp_player.volume_db = linear_to_db(sfx_volume * master_volume * volume_scale)
    temp_player.play()
    
    # 播放完毕后删除临时播放器
    temp_player.finished.connect(func(): temp_player.queue_free())

# 播放语音
func play_voice(voice_name: String, callback: Callable = Callable()):
    if not is_voice_enabled:
        if callback.is_valid():
            callback.call()
        return
    
    var voice_path = VOICE_PATH + voice_name + ".ogg"
    var audio_stream = load(voice_path) as AudioStream
    
    if audio_stream == null:
        print("警告：无法加载语音文件: ", voice_path)
        if callback.is_valid():
            callback.call()
        return
    
    voice_player.stream = audio_stream
    voice_player.play()
    
    # 播放完毕后执行回调
    if callback.is_valid():
        voice_player.finished.connect(callback, CONNECT_ONE_SHOT)

# 停止语音播放
func stop_voice():
    if voice_player.playing:
        voice_player.stop()

# 预定义的音效播放函数
func play_button_click():
    play_sfx("button_click")

func play_correct_answer():
    play_sfx("correct_answer")

func play_wrong_answer():
    play_sfx("wrong_answer")

func play_question_appear():
    play_sfx("question_appear")

func play_success_sound():
    play_sfx("success", 1.2)

func play_failure_sound():
    play_sfx("failure", 1.2)

func play_warning_sound():
    play_sfx("warning")

func play_typing_sound():
    play_sfx("typing", 0.5)

func play_page_turn():
    play_sfx("page_turn")

func play_stamp_sound():
    play_sfx("stamp")

# 预定义的音乐播放函数
func play_menu_music():
    play_music("menu_theme")

func play_game_music():
    play_music("game_theme")

func play_success_music():
    play_music("success_theme")

func play_failure_music():
    play_music("failure_theme")

# 音量控制
func set_master_volume(volume: float):
    master_volume = clamp(volume, 0.0, 1.0)
    update_volumes()
    save_audio_settings()

func set_music_volume(volume: float):
    music_volume = clamp(volume, 0.0, 1.0)
    update_volumes()
    save_audio_settings()

func set_sfx_volume(volume: float):
    sfx_volume = clamp(volume, 0.0, 1.0)
    update_volumes()
    save_audio_settings()

func set_voice_volume(volume: float):
    voice_volume = clamp(volume, 0.0, 1.0)
    update_volumes()
    save_audio_settings()

func update_volumes():
    if music_player:
        music_player.volume_db = linear_to_db(music_volume * master_volume)
    if voice_player:
        voice_player.volume_db = linear_to_db(voice_volume * master_volume)

# 音频开关控制
func toggle_music(enabled: bool):
    is_music_enabled = enabled
    if not enabled:
        stop_music()
    save_audio_settings()

func toggle_sfx(enabled: bool):
    is_sfx_enabled = enabled
    save_audio_settings()

func toggle_voice(enabled: bool):
    is_voice_enabled = enabled
    if not enabled:
        stop_voice()
    save_audio_settings()

# 获取当前音频状态
func get_audio_status() -> Dictionary:
    return {
        "master_volume": master_volume,
        "music_volume": music_volume,
        "sfx_volume": sfx_volume,
        "voice_volume": voice_volume,
        "music_enabled": is_music_enabled,
        "sfx_enabled": is_sfx_enabled,
        "voice_enabled": is_voice_enabled,
        "current_music": current_music,
        "music_playing": music_player.playing if music_player else false
    }

# 保存音频设置
func save_audio_settings():
    var config = ConfigFile.new()
    config.set_value("audio", "master_volume", master_volume)
    config.set_value("audio", "music_volume", music_volume)
    config.set_value("audio", "sfx_volume", sfx_volume)
    config.set_value("audio", "voice_volume", voice_volume)
    config.set_value("audio", "music_enabled", is_music_enabled)
    config.set_value("audio", "sfx_enabled", is_sfx_enabled)
    config.set_value("audio", "voice_enabled", is_voice_enabled)
    
    config.save("user://audio_settings.cfg")

# 加载音频设置
func load_audio_settings():
    var config = ConfigFile.new()
    var err = config.load("user://audio_settings.cfg")
    
    if err != OK:
        print("无法加载音频设置，使用默认设置")
        return
    
    master_volume = config.get_value("audio", "master_volume", 1.0)
    music_volume = config.get_value("audio", "music_volume", 0.7)
    sfx_volume = config.get_value("audio", "sfx_volume", 0.8)
    voice_volume = config.get_value("audio", "voice_volume", 1.0)
    is_music_enabled = config.get_value("audio", "music_enabled", true)
    is_sfx_enabled = config.get_value("audio", "sfx_enabled", true)
    is_voice_enabled = config.get_value("audio", "voice_enabled", true)
    
    update_volumes()

# 创建音频文件夹结构（开发时使用）
func create_audio_folders():
    if not DirAccess.dir_exists_absolute(AUDIO_PATH):
        DirAccess.open("res://").make_dir("audio")
    if not DirAccess.dir_exists_absolute(MUSIC_PATH):
        DirAccess.open(AUDIO_PATH).make_dir("music")
    if not DirAccess.dir_exists_absolute(SFX_PATH):
        DirAccess.open(AUDIO_PATH).make_dir("sfx")
    if not DirAccess.dir_exists_absolute(VOICE_PATH):
        DirAccess.open(AUDIO_PATH).make_dir("voice")

# 检查音频文件是否存在
func check_audio_file(file_path: String) -> bool:
    return FileAccess.file_exists(file_path)

# 获取所有可用的音频文件
func get_available_audio_files() -> Dictionary:
    var files = {
        "music": [],
        "sfx": [],
        "voice": []
    }
    
    # 扫描音乐文件
    var music_dir = DirAccess.open(MUSIC_PATH)
    if music_dir:
        music_dir.list_dir_begin()
        var file_name = music_dir.get_next()
        while file_name != "":
            if file_name.ends_with(".ogg") or file_name.ends_with(".mp3"):
                files["music"].append(file_name.get_basename())
            file_name = music_dir.get_next()
    
    # 扫描音效文件
    var sfx_dir = DirAccess.open(SFX_PATH)
    if sfx_dir:
        sfx_dir.list_dir_begin()
        var file_name = sfx_dir.get_next()
        while file_name != "":
            if file_name.ends_with(".ogg") or file_name.ends_with(".mp3"):
                files["sfx"].append(file_name.get_basename())
            file_name = sfx_dir.get_next()
    
    # 扫描语音文件
    var voice_dir = DirAccess.open(VOICE_PATH)
    if voice_dir:
        voice_dir.list_dir_begin()
        var file_name = voice_dir.get_next()
        while file_name != "":
            if file_name.ends_with(".ogg") or file_name.ends_with(".mp3"):
                files["voice"].append(file_name.get_basename())
            file_name = voice_dir.get_next()
    
    return files