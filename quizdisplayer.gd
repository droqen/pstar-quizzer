extends Node

@export var instant_checker : bool = true

var q:QuizQuestion
var my_answer:int = -1
var wrongs:int = 0
var rights:int = 0
var limit:int = -1
@export var count_label : Label
@export var question_label : Label
@export var answers : Array[Button]
var order : Array[int] = [0,1,2,3]

func _ready() -> void:
	for i in range(4):
		answers[i].pressed.connect(
			func():
				check_answer(
					answers[i], order[i]+1)
		)

func _physics_process(_delta: float) -> void:
	for i in range(4):
		if Input.is_action_just_pressed("a"+str(i+1)):
			check_answer(answers[i], order[i]+1)

func check_answer(button:Button,aidx:int):
	if instant_checker:
		if aidx == q.correct_a:
			if button.modulate == Color.WHITE:
				for a in answers:
					a.modulate = Color.DIM_GRAY
				button.modulate = Color.GREEN;
				rights += 1
				printscore()
			else:
				button.modulate = Color.DARK_GREEN
		else:
			if button.modulate == Color.WHITE:
				for a in answers:
					a.modulate = Color.DIM_GRAY
				button.modulate = Color.RED;
				wrongs += 1
				printscore()
			else:
				button.modulate = Color.DARK_RED
	else:
		for a in answers:
			a.modulate = Color.DIM_GRAY
		button.modulate = Color.WHITE
		my_answer = aidx

func end_displaying_question() -> void:
	if !instant_checker and q:
		if my_answer>=0:
			if my_answer == q.correct_a:
				rights += 1
				print("#%d.%02d - a%d" %
				[q.sectionid, q.subid, my_answer])
			else:
				wrongs += 1
				print("#%d.%02d - a%d\t(X - a%d)" %
				[q.sectionid, q.subid, my_answer,
					q.correct_a])
			printscore()
		else:
			print("#%d.%02d - skipped" %
			[q.sectionid, q.subid])
	my_answer = -1
	self.q = null

func display_question(qnum : int, newq : QuizQuestion) -> void:
	count_label.text = "Question #"+str(qnum+1)+" of "+str(limit)
	
	self.q = newq
	for a in answers:
		a.modulate = Color.WHITE
	question_label.text = q.qtext
	var aaaa = [q.a1, q.a2, q.a3, q.a4]
	order.shuffle()
	for i in range(4):	
		answers[i].text = "{%s}.\t"%[i+1]+aaaa[order[i]]

func printscore():
	print("\t\t\t\t%d/%d" % [
		rights,
		rights+wrongs,
	])
