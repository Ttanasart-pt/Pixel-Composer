function dynaSurf_circle_fill(_x, _y, ss) {
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
		case 3 : 
			draw_point(_x,     _y);
			draw_point(_x - 1, _y);
			draw_point(_x + 1, _y);
			draw_point(_x,     _y + 1);
			draw_point(_x,     _y - 1);
			break;
		default : 
			draw_circle(_x, _y, ss - 2, false);
			break;
	}
}