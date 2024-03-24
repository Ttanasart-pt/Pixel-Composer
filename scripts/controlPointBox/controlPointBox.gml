enum PUPPET_CONTROL {
	mode,
	cx,
	cy,
	fx,
	fy,
	width,
	height
}

enum PUPPET_FORCE_MODE {
	move,
	wind,
	puppet, 
}

function controlPointBox(_onModify) : widget() constructor {
	onModify = _onModify;
	onSurfaceSize = -1;
	
	tbCx = new textBox(TEXTBOX_INPUT.number, function(val) { return onModify(PUPPET_CONTROL.cx,     toNumber(val)); });			tbCx.hide = true; tbCx.slidable = true;
	tbCy = new textBox(TEXTBOX_INPUT.number, function(val) { return onModify(PUPPET_CONTROL.cy,     toNumber(val)); });			tbCy.hide = true; tbCy.slidable = true;
	tbFx = new textBox(TEXTBOX_INPUT.number, function(val) { return onModify(PUPPET_CONTROL.fx,     toNumber(val)); });			tbFx.hide = true; tbFx.slidable = true;
	tbFy = new textBox(TEXTBOX_INPUT.number, function(val) { return onModify(PUPPET_CONTROL.fy,     toNumber(val)); });			tbFy.hide = true; tbFy.slidable = true;
	tbW  = new textBox(TEXTBOX_INPUT.number, function(val) { return onModify(PUPPET_CONTROL.width,  max(0, toNumber(val))); });	tbW.hide  = true; tbW.slidable  = true;
	tbH  = new textBox(TEXTBOX_INPUT.number, function(val) { return onModify(PUPPET_CONTROL.height, max(0, toNumber(val))); });	tbH.hide  = true; tbH.slidable  = true;
	rot  = new rotator(function(val) { return onModify(PUPPET_CONTROL.fy, toNumber(val)); });
	
	sW   = new textBox(TEXTBOX_INPUT.number, function(val) { onModify(PUPPET_CONTROL.width,  toNumber(val)); })
			.setSlidable(0.01, false, [ 1, 32 ]);
	
	sMode = [
		__txtx("widget_control_point_move",   "Move"), 
		__txtx("widget_control_point_wind",   "Wind"), 
	];
	
	scMode = new scrollBox(
		sMode, 
		function(val) { onModify(PUPPET_CONTROL.mode, toNumber(val)); }
	);
	
	widgets = [ scMode, tbCx, tbCy, tbFx, tbFy, tbW, tbH, rot, sW ];
	
	static setInteract = function(interactable = noone) { 
		self.interactable = interactable;
		
		for( var i = 0, n = array_length(widgets); i < n; i++ ) 
			widgets[i].setInteract(interactable);
	}
	
	static register = function(parent = noone) {
		for( var i = 0, n = array_length(widgets); i < n; i++ ) 
			widgets[i].register(parent); 
	}
	
	static drawParam = function(params) {
		return draw(params.x, params.y, params.w, params.data, params.m, params.rx, params.ry);
	}
	
	static draw = function(_x, _y, _w, _data, _m, _rx, _ry) {
		x = _x;
		y = _y;
		
		var _mode = array_safe_get(_data, PUPPET_CONTROL.mode);
		var _cx   = array_safe_get(_data, PUPPET_CONTROL.cx);
		var _cy   = array_safe_get(_data, PUPPET_CONTROL.cy);
		var _fx   = array_safe_get(_data, PUPPET_CONTROL.fx);
		var _fy   = array_safe_get(_data, PUPPET_CONTROL.fy);
		var _wid  = array_safe_get(_data, PUPPET_CONTROL.width);
		
		if(is_array(_mode) || is_array(_cx) || is_array(_cy) || is_array(_fx) || is_array(_fy) || is_array(_wid))
			return 0;
		
		for( var i = 0, n = array_length(widgets); i < n; i++ )
			widgets[i].setFocusHover(active, hover);
		
		var yy = _y;
		
		scMode.draw(_x, yy, _w, TEXTBOX_HEIGHT, sMode[_mode], _m, _rx, _ry);
		yy += TEXTBOX_HEIGHT + ui(8);
		
		var _ww = _w / 2;
		var _wh = TEXTBOX_HEIGHT;
		
		draw_sprite_stretched_ext(THEME.textbox, 3, _x, yy, _w, _wh, c_white, 1);
		draw_sprite_stretched_ext(THEME.textbox, 0, _x, yy, _w, _wh, c_white, 0.5 + 0.5 * interactable);	
		
		draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text_sub);
		draw_set_alpha(0.5);
		draw_text(_x       + ui(8),	yy + _wh / 2, "cx");
		draw_text(_x + _ww + ui(8), yy + _wh / 2, "cy");
		draw_set_alpha(1);
		
		tbCx.draw(_x,	    yy, _ww, _wh, _cx, _m);
		tbCy.draw(_x + _ww, yy, _ww, _wh, _cy, _m);
		yy += _wh + ui(8);
		
		switch(_mode) {
			case PUPPET_FORCE_MODE.move: 
			case PUPPET_FORCE_MODE.puppet: 
			
				draw_sprite_stretched_ext(THEME.textbox, 3, _x, yy, _w, _wh, c_white, 1);
				draw_sprite_stretched_ext(THEME.textbox, 0, _x, yy, _w, _wh, c_white, 0.5 + 0.5 * interactable);	
		
				draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text_sub);
				draw_set_alpha(0.5);
				draw_text(_x       + ui(8),	yy + _wh / 2, "fx");
				draw_text(_x + _ww + ui(8), yy + _wh / 2, "fy");
				draw_set_alpha(1);
				
				tbFx.draw(_x,		yy, _ww, _wh, _fx, _m);
				tbFy.draw(_x + _ww,	yy, _ww, _wh, _fy, _m);
				yy += _wh + ui(8);
				
				if(_mode == PUPPET_FORCE_MODE.move) {
					sW.draw(_x, yy, _w, _wh, _wid, _m);
					
					draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text);
					draw_set_alpha(0.5);
					draw_text(_x + ui(8), yy + _wh / 2, __txt("radius"));
					draw_set_alpha(1);
					
					yy += _wh + ui(8);
				}
				break;
				
			case PUPPET_FORCE_MODE.wind: 
			
				draw_sprite_stretched_ext(THEME.textbox, 3, _x, yy, _w, _wh, c_white, 1);
				draw_sprite_stretched_ext(THEME.textbox, 0, _x, yy, _w, _wh, c_white, 0.5 + 0.5 * interactable);	
		
				draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text_sub);
				draw_set_alpha(0.5);
				draw_text(_x       + ui(8), yy + _wh / 2, __txt("strength"));
				draw_text(_x + _ww + ui(8), yy + _wh / 2, __txt("width"));
				draw_set_alpha(1);
				
				tbFx.draw(_x,       yy, _ww, _wh, _fx, _m);
				tbW.draw( _x + _ww, yy, _ww, _wh, _wid, _m);
				yy += _wh + ui(8);
				
				var _rh = rot.draw(_x, yy, _w, _fy, _m);
				yy += _rh + ui(8);
				break;
		}
		
		resetFocus();
		return yy - _y;
	}
}