function mouse_click(mouse, focus = true) {
	return focus && mouse_check_button(mouse);
}

function mouse_press(mouse, focus = true) {
	return focus && mouse_check_button_pressed(mouse);
}

function mouse_release(mouse, focus = true) {
	return focus && mouse_check_button_released(mouse);
}