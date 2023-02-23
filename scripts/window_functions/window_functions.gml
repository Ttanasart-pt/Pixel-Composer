function window_close() {
	if(MODIFIED && !READONLY) {
		dialogCall(o_dialog_exit);
	} else {
		PREF_SAVE();
		game_end();
	}
}