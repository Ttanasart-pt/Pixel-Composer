enum SLIDER_UPDATE {
	realtime,
	release,
	none,
}

function slider(_min = 0, _max = 1, _step = .01, _onModify = noone, _onRelease = noone) {
	return new textBox( TEXTBOX_INPUT.number, _onModify )
				.setSlideRange(_min, _max)
				.setSlideStep(_step)
				.setOnRelease(_onRelease);
}