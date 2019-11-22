extends Node2D

func self_destruct():
	self.queue_free()
	