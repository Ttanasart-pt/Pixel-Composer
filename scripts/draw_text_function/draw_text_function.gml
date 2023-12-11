function draw_text_line(_x, _y, _text, _sep, _w) { #region
	INLINE
	__draw_text_ext_transformed(_x, _y, _text, _sep, _w, 1, 1, 0);
} #endregion

function draw_text_add(_x, _y, _text, scale = 1) { #region
	INLINE
	BLEND_ALPHA_MULP;
	if(scale == 1) draw_text(round(_x), round(_y), _text);
	else           draw_text_transformed(round(_x), round(_y), _text, scale, scale, 0);
	BLEND_NORMAL;
} #endregion

function draw_text_over(_x, _y, _text, scale = 1) { #region
	INLINE
	BLEND_OVERRIDE;
	draw_text_transformed(round(_x), round(_y), _text, scale, scale, 0);
	BLEND_NORMAL;
} #endregion

function draw_text_lang_add(_x, _y, _text, scale = 1) { #region
	INLINE
	BLEND_ALPHA_MULP;
	draw_text_lang(_x, _y, _text, scale);
	BLEND_NORMAL;
} #endregion

function draw_text_lang_over(_x, _y, _text, scale = 1) { #region
	INLINE
	BLEND_OVERRIDE;
	draw_text_lang(_x, _y, _text, scale);
	BLEND_NORMAL;
} #endregion

function draw_text_lang(_x, _y, _text, scale = 1) { #region
	var _w = string_width(_text);
	var _h = string_height(_text);
	
	var _ha = draw_get_halign();
	switch(_ha) {
		case fa_left :    break;
		case fa_center : _x -= _w / 2;  break;
		case fa_right :  _x -= _w;      break;
	}
	draw_set_halign(fa_left);
	
	var amo   = string_length(_text);
	var _f    = draw_get_font();
	var _font = _f;
	var _gMap = GLYPH_MAP[$ _f];
	var gly, _g , _ff;
	
	for( var i = 1; i <= amo; i++ ) {
		gly = string_char_at(_text, i);
		
		if(struct_has(_gMap, gly)) {
			_ff = _gMap[$ gly];
			_g  = gly;
		} else {
			_ff = _f;
			_g  = "?";
		}
		
		if(_font != _ff) draw_set_font(_ff);
		_font = _ff;
		draw_text_transformed(round(_x), round(_y), _g, scale, scale, 0);
		_x += string_width(_g) * scale;
	}
	
	draw_set_font(_f);
	draw_set_halign(_ha);
} #endregion

function draw_text_ext_add(_x, _y, _text, _sep, _w, scale = 1, forceCut = false) { #region
	INLINE
	BLEND_ALPHA_MULP;
	var h = __draw_text_ext_transformed(_x, _y, _text, _sep, _w, scale, scale, 0, forceCut);
	BLEND_NORMAL;
	return h;
} #endregion

function draw_text_bbox(bbox, text) { #region
	INLINE
	var ss = min(bbox.w / string_width(text), bbox.h / string_height(text));
	    ss = max(0.5, ss);
	
	draw_set_halign(fa_center);
	draw_set_valign(fa_center);
	
	draw_text_cut(bbox.xc, bbox.yc, text, bbox.w, ss);
} #endregion

function draw_text_cut(x, y, str, w, scale = 1) { #region
	INLINE
	BLEND_ALPHA_MULP;
	draw_text_transformed(round(x), round(y), string_cut(str, w,, scale), scale, scale, 0);
	BLEND_NORMAL;
} #endregion

function draw_text_int(x, y, str) { #region
	INLINE
	draw_text(round(x), round(y), str);
} #endregion

function __draw_text_ext_transformed(_x, _y, _text, _sep, _w, sx, sy, rotation, forceCut = false) { #region
	INLINE
	_x = round(_x);
	_y = round(_y);
	
	if(!LOCALE.config.per_character_line_break && !forceCut) {
		BLEND_ALPHA_MULP;
		draw_text_ext_transformed(_x, _y, _text, _sep, _w, sx, sy, rotation);
		BLEND_NORMAL;
		
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
	var hh = string_height("M") * array_length(lines) * sy;
	
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	
	switch(va) {
		case fa_top :    yy = _y;			break;
		case fa_middle : yy = _y - hh / 2;	break;
		case fa_bottom : yy = _y - hh;		break;
	}
	
	BLEND_ALPHA_MULP;
	for( var i = 0, n = array_length(lines); i < n; i++ ) {
		var lw = string_width(lines[i]) * sx;
		
		switch(ha) {
			case fa_left :   xx = _x;			break;
			case fa_center : xx = _x - lw / 2;	break;
			case fa_right :  xx = _x - lw;		break;
		}
		
		draw_text_transformed(xx, yy, lines[i], sx, sy, rotation);
		yy += string_height("M") * sy;
	}
	BLEND_NORMAL;
	
	draw_set_halign(ha);
	draw_set_valign(va);
	
	return hh;
} #endregion

#macro _string_width_ext string_width_ext
#macro string_width_ext __string_width_ext

function __string_width_ext(text, sep, w) { #region
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
} #endregion

#macro _string_height_ext string_height_ext
#macro string_height_ext __string_height_ext

function __string_height_ext(text, sep, w, _break = LOCALE.config.per_character_line_break) { #region
	INLINE
	if(!_break)
		return _string_height_ext(text, sep, w);
	
	var lw  = 0;
	var amo = string_length(text);
	if(amo == 0) return 0;
	
	var hh  = string_height("M");
	
	for( var i = 1; i <= amo; i++ ) {
		var ch = string_char_at(text, i);
		var ww = string_width(ch);
		
		if(lw + ww > w) {
			hh += string_height("M");
			lw = ww;
		} else 
			lw += ww;
	}
	
	return hh;
} #endregion