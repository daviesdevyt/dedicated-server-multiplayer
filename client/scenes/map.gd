extends Node2D


func update_kills(kills):
	$CanvasLayer/kills/count.text = str(kills)

func update_highest(kills):
	$CanvasLayer/highestkills/count.text = str(kills)
