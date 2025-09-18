extends Node

@export var displayer : Node
@export var questions : Array[QuizQuestion] = []
var easy_questions : Array[QuizQuestion] = []
var question_idx : int = 0
var trouble_numbers : Array[String]

var limit : int = 50

func _ready() -> void:
	var parser = XMLParser.new()
	parser.open("res://qs_and_as.xml")
	var question : QuizQuestion = null
	var reading_node_name : String = ''
	while parser.read() != ERR_FILE_EOF:
		match parser.get_node_type():
			XMLParser.NODE_ELEMENT:
				reading_node_name = parser.get_node_name()
				if reading_node_name == "question":
					if question != null: push_error("two questions why")
					question = QuizQuestion.new()
			XMLParser.NODE_ELEMENT_END:
				reading_node_name = ''
				if parser.get_node_name() == "question":
					if question == null: push_error("add same question twice why")
					if question.sectionid == 0: push_error("incomplete question definition (number)")
					if question.subid == 0: push_error("incomplete question definition (number)")
					if question.qtext == "": push_error("incomplete question definition (qtext)")
					if question.a1 == "": push_error("incomplete question definition (a1)")
					if question.a2 == "": push_error("incomplete question definition (a2)")
					if question.a3 == "": push_error("incomplete question definition (a3)")
					if question.a4 == "": push_error("incomplete question definition (a4)")
					if question.correct_a == 0: push_error("incomplete question definition (correct_a)")
					
					var question_number = "%d.%02d" % [question.sectionid,question.subid]
					if trouble_numbers.has(question_number):
						questions.append(question)
					else:
						questions.append(question)
						#easy_questions.append(question)
					question = null
			XMLParser.NODE_TEXT:
				var node_data = parser.get_node_data()
				match reading_node_name:
					"trouble":
						trouble_numbers.append(node_data)
					"answers":
						pass
					"number":
						if question.sectionid != 0: push_error("bad xml (number redef)")
						if question.subid != 0: push_error("bad xml (number redef)")
						var numbersplit = node_data.split(".",true,1)
						question.sectionid = int(numbersplit[0])
						question.subid = int(numbersplit[1])
					"qtext":
						if question.qtext != "": push_error("bad xml (qtext redef)")
						question.qtext = node_data
					"answer1":
						if question.a1 != "": push_error("bad xml (a1 redef) %s = %s" % [question.a1, node_data])
						question.a1 = node_data
					"answer2":
						if question.a2 != "": push_error("bad xml (a2 redef)")
						question.a2 = node_data
					"answer3":
						if question.a3 != "": push_error("bad xml (a3 redef)")
						question.a3 = node_data
					"answer4":
						if question.a4 != "": push_error("bad xml (a4 redef)")
						question.a4 = node_data
					"correct":
						if question.correct_a != 0: push_error("bad xml (correct_a redef)")
						question.correct_a = int(node_data)
					_:
						if node_data.replace("\n","").replace("\t",""):
							push_warning("ignoring node data %s (%s)" % [node_data, reading_node_name])
				#reading_node_name = ''
	
	prints("found %d questions" % len(questions))
	
	if limit > len(questions):
		limit = len(questions)
	displayer.limit = limit;
	
	questions.shuffle()
	next()

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		next()

func next():
	displayer.end_displaying_question()
	if question_idx < limit:
		displayer.display_question(question_idx, questions[question_idx])
		question_idx += 1
	else:
		get_tree().change_scene_to_file("res://done.tscn")
		return
	#print("#%d.%02d" % [questions[question_idx].sectionid, questions[question_idx].subid])

func qtostr(q:QuizQuestion) -> String:
	var answers = [q.a1,q.a2,q.a3,q.a4]
	var order = [0, 1, 2, 3]
	order.shuffle()
	answers[q.correct_a-1] += " ***CORRECT***"
	return (
		q.qtext + "\n\n" +
		"1. %s\n\n2. %s\n\n3. %s\n\n4. %s" % [
			answers[order[0]],
			answers[order[1]],
			answers[order[2]],
			answers[order[3]],
		]
	)
