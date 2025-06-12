class_name QuestionData
extends Resource

# 问题数据结构
@export var question_text: String = ""
@export var correct_keywords: Array[String] = []
@export var forbidden_words: Array[String] = []
@export var sample_answer: String = ""
@export var difficulty: int = 1  # 1-简单, 2-中等, 3-困难
@export var category: String = "general"  # 问题分类
@export var time_limit: float = 30.0  # 回答时间限制（秒）

# 构造函数
func _init(text: String = "", keywords: Array[String] = [], forbidden: Array[String] = [], sample: String = "", diff: int = 1, cat: String = "general", time: float = 30.0):
    question_text = text
    correct_keywords = keywords
    forbidden_words = forbidden
    sample_answer = sample
    difficulty = diff
    category = cat
    time_limit = time

# 静态方法：获取默认问题库
static func get_default_questions() -> Array[QuestionData]:
    var questions: Array[QuestionData] = []
    
    # 基础入境问题
    questions.append(QuestionData.new(
        "您来中国的目的是什么？",
        ["旅游", "商务", "工作", "学习", "探亲", "访友", "会议", "培训"],
        ["非法", "偷渡", "走私", "犯罪"],
        "我来中国旅游，想参观一些著名景点。",
        1,
        "purpose",
        25.0
    ))
    
    questions.append(QuestionData.new(
        "您计划在中国停留多长时间？",
        ["天", "周", "月", "一周", "两周", "三天", "五天", "十天", "短期", "临时"],
        ["永久", "定居", "移民", "很久", "不确定"],
        "我计划停留一周时间。",
        1,
        "duration",
        20.0
    ))
    
    questions.append(QuestionData.new(
        "您在中国期间住在哪里？",
        ["酒店", "宾馆", "朋友家", "亲戚家", "民宿", "招待所", "旅馆"],
        ["不知道", "随便", "街上", "没地方"],
        "我会住在市中心的酒店。",
        1,
        "accommodation",
        25.0
    ))
    
    questions.append(QuestionData.new(
        "您携带了多少现金？",
        ["人民币", "美元", "欧元", "现金", "钱", "元", "块", "千", "万", "少量", "足够"],
        ["很多", "大量", "无数", "数不清"],
        "我携带了5000人民币现金。",
        2,
        "money",
        30.0
    ))
    
    questions.append(QuestionData.new(
        "您是否携带需要申报的物品？",
        ["没有", "无", "不", "否", "没", "申报", "合法", "正常"],
        ["有", "是", "违禁", "私带", "隐瞒"],
        "没有，我没有携带需要申报的物品。",
        2,
        "declaration",
        25.0
    ))
    
    # 进阶问题
    questions.append(QuestionData.new(
        "您的职业是什么？",
        ["工程师", "教师", "医生", "学生", "商人", "律师", "设计师", "程序员", "经理", "职员"],
        ["无业", "失业", "不工作", "没工作"],
        "我是一名软件工程师。",
        2,
        "occupation",
        30.0
    ))
    
    questions.append(QuestionData.new(
        "您之前来过中国吗？",
        ["是", "有", "来过", "第一次", "没有", "无", "不", "否"],
        ["偷渡", "非法", "黑户"],
        "这是我第一次来中国。",
        1,
        "history",
        20.0
    ))
    
    questions.append(QuestionData.new(
        "您会说中文吗？",
        ["会", "一点", "不会", "学习", "简单", "基础", "流利", "中文", "汉语"],
        ["拒绝", "不想说"],
        "我会说一点简单的中文。",
        1,
        "language",
        20.0
    ))
    
    # 困难问题
    questions.append(QuestionData.new(
        "请详细说明您的行程安排。",
        ["北京", "上海", "广州", "深圳", "杭州", "西安", "成都", "景点", "参观", "游览", "计划", "安排"],
        ["不知道", "随便", "没计划", "看情况"],
        "我计划先在北京停留三天，参观故宫和长城，然后去上海两天。",
        3,
        "itinerary",
        45.0
    ))
    
    questions.append(QuestionData.new(
        "您如何证明您有足够的资金支持此次旅行？",
        ["银行", "存款", "工资", "收入", "证明", "资金", "财力", "账单", "流水"],
        ["借钱", "没钱", "贷款", "欠债"],
        "我有银行存款证明和工资收入证明。",
        3,
        "financial",
        40.0
    ))
    
    return questions

# 根据难度筛选问题
static func get_questions_by_difficulty(difficulty: int) -> Array[QuestionData]:
    var all_questions = get_default_questions()
    var filtered_questions: Array[QuestionData] = []
    
    for question in all_questions:
        if question.difficulty == difficulty:
            filtered_questions.append(question)
    
    return filtered_questions

# 根据分类筛选问题
static func get_questions_by_category(category: String) -> Array[QuestionData]:
    var all_questions = get_default_questions()
    var filtered_questions: Array[QuestionData] = []
    
    for question in all_questions:
        if question.category == category:
            filtered_questions.append(question)
    
    return filtered_questions

# 随机获取指定数量的问题
static func get_random_questions(count: int, max_difficulty: int = 3) -> Array[QuestionData]:
    var all_questions = get_default_questions()
    var available_questions: Array[QuestionData] = []
    
    # 筛选符合难度要求的问题
    for question in all_questions:
        if question.difficulty <= max_difficulty:
            available_questions.append(question)
    
    # 随机打乱
    available_questions.shuffle()
    
    # 返回指定数量的问题
    var selected_questions: Array[QuestionData] = []
    var actual_count = min(count, available_questions.size())
    
    for i in range(actual_count):
        selected_questions.append(available_questions[i])
    
    return selected_questions

# 验证问题数据的完整性
func is_valid() -> bool:
    if question_text.is_empty():
        return false
    if correct_keywords.is_empty():
        return false
    if sample_answer.is_empty():
        return false
    if difficulty < 1 or difficulty > 3:
        return false
    if time_limit <= 0:
        return false
    return true

# 获取问题的显示信息
func get_display_info() -> Dictionary:
    return {
        "text": question_text,
        "difficulty": difficulty,
        "category": category,
        "time_limit": time_limit,
        "keyword_count": correct_keywords.size(),
        "forbidden_count": forbidden_words.size()
    }

# 检查答案是否包含关键词
func has_keywords(answer: String) -> bool:
    var answer_lower = answer.to_lower()
    for keyword in correct_keywords:
        if answer_lower.contains(keyword.to_lower()):
            return true
    return false

# 检查答案是否包含禁用词
func has_forbidden_words(answer: String) -> bool:
    var answer_lower = answer.to_lower()
    for forbidden in forbidden_words:
        if answer_lower.contains(forbidden.to_lower()):
            return true
    return false

# 获取匹配的关键词
func get_matched_keywords(answer: String) -> Array[String]:
    var matched: Array[String] = []
    var answer_lower = answer.to_lower()
    
    for keyword in correct_keywords:
        if answer_lower.contains(keyword.to_lower()):
            matched.append(keyword)
    
    return matched

# 获取匹配的禁用词
func get_matched_forbidden_words(answer: String) -> Array[String]:
    var matched: Array[String] = []
    var answer_lower = answer.to_lower()
    
    for forbidden in forbidden_words:
        if answer_lower.contains(forbidden.to_lower()):
            matched.append(forbidden)
    
    return matched