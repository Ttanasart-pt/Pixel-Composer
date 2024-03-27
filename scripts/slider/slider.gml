enum SLIDER_UPDATE {
	realtime,
	release,
	none,
}

function slider(_min, _max, _step, _onModify = noone, _onRelease = noone) {
	return new textBox( TEXTBOX_INPUT.number, _onModify )
				.setSlidable(_step / 10, false, [ _min, _max ])
				.setOnRelease(_onRelease);
}