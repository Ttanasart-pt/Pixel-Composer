function dynaSurf_square_outline(_x, _y, ss) {
	switch(round(ss)) {
		case 0 : 
		case 1 : 
			draw_point(_x, _y);
			break;
		case 2 : 
			draw_point(_x + 0, _y + 0);
			draw_point(_x + 1, _y + 0);
			draw_point(_x + 0, _y + 1);
			draw_point(_x + 1, _y + 1);
			break;
		default : 
			draw_rectangle(_x - ss / 2, _y - ss / 2, _x + ss / 2, _y + ss / 2, true);
			break;
	}
}