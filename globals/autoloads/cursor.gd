extends Node

const CURSOR_ALT 	:= preload("uid://b73ovnnghpc2c")
const CURSOR_BASE 	:= CURSOR_ALT # preload("uid://dplwroo5uo08r")
const CURSOR_IBEAM 	:= preload("uid://ccnqtq1ue1u0j")
const CURSOR_MOVE 	:= preload("uid://nr11jssskpxa")
const CURSOR_LDIAG 	:= preload("uid://dikaghrf0ibqr")
const CURSOR_RDIAG 	:= preload("uid://dv7ky6h6n0th4")
const CURSOR_LR 	:= preload("uid://kq70tkl5nu1u")
const CURSOR_UD 	:= preload("uid://cs14b66fatb4d")

const OFFSET := Vector2(5, 5)

func _ready() -> void:
	set_cursor()

func set_cursor() -> void:
	Input.set_custom_mouse_cursor(CURSOR_BASE, Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(CURSOR_ALT, Input.CURSOR_POINTING_HAND, OFFSET)
	Input.set_custom_mouse_cursor(CURSOR_IBEAM, Input.CURSOR_IBEAM, OFFSET)
	Input.set_custom_mouse_cursor(CURSOR_MOVE, Input.CURSOR_MOVE, OFFSET)
	Input.set_custom_mouse_cursor(CURSOR_LDIAG, Input.CURSOR_FDIAGSIZE, OFFSET)
	Input.set_custom_mouse_cursor(CURSOR_RDIAG, Input.CURSOR_BDIAGSIZE, OFFSET)
	Input.set_custom_mouse_cursor(CURSOR_LR, Input.CURSOR_HSIZE, OFFSET)
	Input.set_custom_mouse_cursor(CURSOR_UD, Input.CURSOR_VSIZE, OFFSET)
