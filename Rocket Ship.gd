extends Sprite
var anim = ""

func start_hover():
	var new_anim = "Flying"
	if new_anim != anim:
		anim = new_anim
		($AnimationPlayer).play(anim)

func fly_out():
	var new_anim = "Fly out"
	if new_anim != anim:
		anim = new_anim
		($AnimationPlayer).play(anim)

func fly_down():
	var new_anim = "Fly out"
	if new_anim != anim:
		anim = new_anim
		($AnimationPlayer).play(anim)
