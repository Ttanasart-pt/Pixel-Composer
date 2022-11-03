function buffer_get_color(buffer, _x, _y, w, h) {
	buffer_seek(buffer, buffer_seek_start, (w * _y + _x) * 4);
	var c = buffer_read(buffer, buffer_u32);
	
	return c;
}