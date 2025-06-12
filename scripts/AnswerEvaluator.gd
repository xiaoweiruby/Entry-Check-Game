class_name AnswerEvaluator
extends Node

class EvaluationResult:
    var passed: bool
    var score: int
    var message: String
    var feedback: String
    
    func _init(p: bool = false, s: int = 0, m: String = "", f: String = ""):
        passed = p
        score = s
        message = m
        feedback = f

func evaluate_answer(answer: String, question: Dictionary) -> EvaluationResult:
    var result = EvaluationResult.new()
    var answer_lower = answer.to_lower().strip_edges()
    
    # 检查空回答
    if answer_lower.length() == 0:
        result.passed = false
        result.score = 0
        result.message = "❌ 请提供回答"
        result.feedback = "请说出您的回答"
        return result
    
    # 检查禁用词
    for forbidden_word in question.forbidden:
        if forbidden_word.to_lower() in answer_lower:
            result.passed = false
            result.score = 0
            result.message = "❌ 错误回答"
            result.feedback = "避免使用: " + forbidden_word
            return result
    
    # 检查关键词
    var keyword_found = false
    var found_keywords = []
    
    for keyword in question.keywords:
        if keyword.to_lower() in answer_lower:
            keyword_found = true
            found_keywords.append(keyword)
    
    if keyword_found:
        result.passed = true
        result.score = 100
        result.message = "✅ 回答正确"
        result.feedback = "很好！找到关键词: " + ", ".join(found_keywords)
    else:
        result.passed = false
        result.score = 0
        result.message = "⚠️ 需要改进"
        result.feedback = "尝试使用这些词: " + ", ".join(question.keywords.slice(0, 3))
    
    return result

# 辅助函数：获取建议回答
func get_sample_answers(question: Dictionary) -> Array:
    var samples = []
    
    match question.text:
        "What's the purpose of your visit?":
            samples = [
                "I'm here for tourism.",
                "I'm on vacation.",
                "I'm here for business.",
                "I'm here to study."
            ]
        "Where will you stay?":
            samples = [
                "I'll stay at a hotel.",
                "I have a hotel reservation.",
                "I booked a room at Hilton.",
                "I'll stay at Marriott."
            ]
        "How long will you stay?":
            samples = [
                "I'll stay for 5 days.",
                "About one week.",
                "Two weeks.",
                "One month."
            ]
    
    return samples

# 辅助函数：获取详细反馈
func get_detailed_feedback(answer: String, question: Dictionary) -> String:
    var feedback = ""
    var answer_lower = answer.to_lower()
    
    # 分析回答内容
    if answer_lower.length() < 3:
        feedback += "回答太短，请提供更完整的答案。\n"
    
    # 检查是否包含问题相关词汇
    var question_lower = question.text.to_lower()
    if "purpose" in question_lower and not any_keyword_in_answer(["tourism", "business", "study", "vacation"], answer_lower):
        feedback += "请明确说明访问目的。\n"
    elif "stay" in question_lower and "where" in question_lower and not any_keyword_in_answer(["hotel", "booking", "reservation"], answer_lower):
        feedback += "请说明住宿安排。\n"
    elif "long" in question_lower and not any_keyword_in_answer(["day", "week", "month", "1", "2", "3", "4", "5"], answer_lower):
        feedback += "请说明停留时间。\n"
    
    if feedback == "":
        feedback = "回答内容正确，继续保持！"
    
    return feedback

func any_keyword_in_answer(keywords: Array, answer: String) -> bool:
    for keyword in keywords:
        if keyword in answer:
            return true
    return false