function measure(func, header = "") {
	var t = current_time;
	func();
	show_debug_message(header + string(t) + " ms");
}