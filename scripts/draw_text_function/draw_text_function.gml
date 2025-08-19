function draw_text_line(_x, _y, _text, _sep, _w, forceCut = false) {
	INLINE
	__draw_text_ext_transformed(_x, _y, _text, _sep, _w, 1, 1, 0, forceCut);
}

function draw_text_add(_x, _y, _text, scale = 1) {
	INLINE
	BLEND_ALPHA_MULP
	// BLEND_OVERRIDE
	if(scale == 1) draw_text(round(_x), round(_y), _text);
	else           draw_text_transformed(round(_x), round(_y), _text, scale, scale, 0);
	BLEND_NORMAL
}

function draw_text_transform_add(_x, _y, _text, scale = 1, _rot = 0) {
	INLINE
	BLEND_ALPHA_MULP
	draw_text_transformed(round(_x), round(_y), _text, scale, scale, _rot);
	BLEND_NORMAL
}

function draw_text_alpha(_x, _y, _text, scale = 1) {
	INLINE
	BLEND_ALPHA
	if(scale == 1) draw_text(round(_x), round(_y), _text);
	else           draw_text_transformed(round(_x), round(_y), _text, scale, scale, 0);
	BLEND_NORMAL
}

function draw_text_over(_x, _y, _text, scale = 1) {
	INLINE
	BLEND_OVERRIDE
	draw_text_transformed(round(_x), round(_y), _text, scale, scale, 0);
	BLEND_NORMAL
}

function draw_text_add_float(_x, _y, _text, scale = 1) {
	INLINE
	
	BLEND_ADD
	if(scale == 1) draw_text(_x, _y, _text); else draw_text_transformed(_x, _y, _text, scale, scale, 0);
	BLEND_NORMAL
	if(scale == 1) draw_text(_x, _y, _text); else draw_text_transformed(_x, _y, _text, scale, scale, 0);
}

function draw_text_bm_add(_x, _y, _text, scale = 1) {
	INLINE
		
	if(scale == 1) {
		gpu_set_colorwriteenable(1, 1, 1, 0);
			BLEND_OVERRIDE
			draw_text(_x, _y, _text);
			BLEND_NORMAL
			
		gpu_set_colorwriteenable(1, 1, 1, 1);
			draw_text(_x, _y, _text);
		
	} else {
		gpu_set_colorwriteenable(1, 1, 1, 0);
			BLEND_OVERRIDE
			draw_text_transformed(_x, _y, _text, scale, scale, 0);
			BLEND_NORMAL
			
		gpu_set_colorwriteenable(1, 1, 1, 1);
			draw_text_transformed(_x, _y, _text, scale, scale, 0);
		
	}
}

function draw_text_ext_add(_x, _y, _text, _sep, _w, scale = 1, forceCut = false) {
	INLINE
	BLEND_ALPHA_MULP
	if(!forceCut) {
		draw_text_ext_transformed(_x, _y, _text, _sep, _w, scale, scale, 0);
		BLEND_NORMAL
		return string_height_ext(_text, _sep, _w) * scale;
	}
	
	var h = __draw_text_ext_transformed(_x, _y, _text, _sep, _w, scale, scale, 0, forceCut);
	BLEND_NORMAL
	return h;
}

function draw_text_ext_alpha(_x, _y, _text, _sep, _w, scale = 1, forceCut = false) {
	INLINE
	BLEND_ALPHA
	if(!forceCut) {
		draw_text_ext_transformed(_x, _y, _text, _sep, _w, scale, scale, 0);
		BLEND_NORMAL
		return string_height_ext(_text, _sep, _w) * scale;
	}
	
	var h = __draw_text_ext_transformed(_x, _y, _text, _sep, _w, scale, scale, 0, forceCut);
	BLEND_NORMAL
	return h;
}

function draw_text_bbox(bbox, text, scale = 1) {
	INLINE
	var ss = min(bbox.w / string_width(text), bbox.h / string_height(text));
	if(ss <= 0) return;
	
	draw_set_halign(fa_center);
	draw_set_valign(fa_center);
	
	draw_text_add(bbox.xc, bbox.yc, text, ss * scale);
}

function draw_text_bbox_cut(bbox, text, scale = 1) {
	INLINE
	var ss = min(bbox.w / string_width(text), bbox.h / string_height(text));
	if(ss <= 0) return;
	
	draw_set_halign(fa_center);
	draw_set_valign(fa_center);
	
	var _scis = gpu_get_scissor();
	gpu_set_scissor(bbox.x0, bbox.y0, bbox.w, bbox.h);
	draw_text_transform_add(bbox.xc, bbox.yc, text, ss * scale);
	gpu_set_scissor(_scis);
}

function draw_text_int(x, y, str) {
	INLINE
	draw_text(round(x), round(y), str);
}

function __draw_text_ext_transformed(_x, _y, _text, _sep, _w, sx = 1, sy = 1, rotation = 0, _break = LOCALE.config.per_character_line_break) {
	INLINE
	_x = round(_x);
	_y = round(_y);
	
	if(!_break) {
		BLEND_ALPHA_MULP
		draw_text_ext_transformed(_x, _y, _text, _sep, _w, sx, sy, rotation);
		BLEND_NORMAL
		
		return string_height_ext(_text, _sep, _w) * sy;
	}
	
	var lines  = [];
	var line   = "";
	var line_w = 0;
	var amo    = string_length(_text);
	
	for( var i = 1; i <= amo; i++ ) {
		var ch = string_char_at(_text, i);
		var ww = string_width(ch) * sx;
		
		if(ch == "\n" || line_w + ww > _w) {
			array_push(lines, line);
			if(ch != "\n") {
				line = ch;
				line_w = ww;
			} else {
				line = "";
				line_w = 0;
			}
		} else if(ch != "\n") {
			line += ch;
			line_w += ww;
		}
	}
	
	if(line != "") array_push(lines, line);
	
	var ha = draw_get_halign();
	var va = draw_get_valign();
	var xx = _x, yy = _y;
	var lh = line_get_height();
	var hh = lh * array_length(lines) * sy;
	
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	
	switch(va) {
		case fa_top :    yy = _y;			break;
		case fa_middle : yy = _y - hh / 2;	break;
		case fa_bottom : yy = _y - hh;		break;
	}
	
	BLEND_ALPHA_MULP
	for( var i = 0, n = array_length(lines); i < n; i++ ) {
		var lw = string_width(lines[i]) * sx;
		
		switch(ha) {
			case fa_left :   xx = _x;			break;
			case fa_center : xx = _x - lw / 2;	break;
			case fa_right :  xx = _x - lw;		break;
		}
		
		draw_text_transformed(xx, yy, lines[i], sx, sy, rotation);
		yy += lh * sy;
	}
	BLEND_NORMAL
	
	draw_set_halign(ha);
	draw_set_valign(va);
	
	return hh;
}

#macro _string_width_ext string_width_ext
#macro string_width_ext __string_width_ext

function __string_width_ext(text, sep, w) {
	INLINE
	if(!LOCALE.config.per_character_line_break)
		return _string_width_ext(text, sep, w);
	
	var mxw = 0;
	var lw  = 0;
	var amo = string_length(text);
	
	for( var i = 1; i <= amo; i++ ) {
		var ch = string_char_at(text, i);
		var ww = string_width(ch);
		
		if(lw + ww > w) {
			mxw = max(mxw, lw);
			lw = ww;
		} else 
			lw += ww;
	}
	
	mxw = max(mxw, lw);
	return mxw;
}

#macro _string_height_ext string_height_ext
#macro string_height_ext __string_height_ext

function __string_height_ext(text, sep, w, _break = LOCALE.config.per_character_line_break) {
	INLINE
	if(!_break) return _string_height_ext(text, sep, w);
	
	var lw  = 0;
	var amo = string_length(text);
	if(amo == 0) return 0;
	
	var lh = line_get_height();
	var hh = lh;
	
	for( var i = 1; i <= amo; i++ ) {
		var ch = string_char_at(text, i);
		var ww = string_width(ch);
		
		if(lw + ww > w) {
			hh += lh;
			lw = ww;
		} else 
			lw += ww;
	}
	
	return hh;
}
