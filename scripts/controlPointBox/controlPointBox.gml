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
	
	tbCx = new textBox(TEXTBOX_INPUT.number, function(val) { return onModify(toNumber(val),         PUPPET_CONTROL.cx    ); });	tbCx.hide = true; tbCx.slidable = true;
	tbCy = new textBox(TEXTBOX_INPUT.number, function(val) { return onModify(toNumber(val),         PUPPET_CONTROL.cy    ); });	tbCy.hide = true; tbCy.slidable = true;
	tbFx = new textBox(TEXTBOX_INPUT.number, function(val) { return onModify(toNumber(val),         PUPPET_CONTROL.fx    ); });	tbFx.hide = true; tbFx.slidable = true;
	tbFy = new textBox(TEXTBOX_INPUT.number, function(val) { return onModify(toNumber(val),         PUPPET_CONTROL.fy    ); });	tbFy.hide = true; tbFy.slidable = true;
	tbW  = new textBox(TEXTBOX_INPUT.number, function(val) { return onModify(max(0, toNumber(val)), PUPPET_CONTROL.width ); });	tbW.hide  = true; tbW.slidable  = true;
	tbH  = new textBox(TEXTBOX_INPUT.number, function(val) { return onModify(max(0, toNumber(val)), PUPPET_CONTROL.height); });	tbH.hide  = true; tbH.slidable  = true;
	rot  = new rotator(function(val) { return onModify(toNumber(val), PUPPET_CONTROL.fy); });
	
	sW   = new textBox(TEXTBOX_INPUT.number, function(val) { onModify(toNumber(val), PUPPET_CONTROL.width); })
			.setSlidable(0.01, false, [ 1, 32 ]);
	
	tbCx.label = "cx";
	tbCy.label = "cy";
		
	sMode = [
		__txtx("widget_control_point_move",   "Move"), 
		__txtx("widget_control_point_wind",   "Wind"), 
	];
	
	scMode = new scrollBox(
		sMode, 
		function(val) { onModify(toNumber(val), PUPPET_CONTROL.mode); }
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
	
	static isHovering = function() { 
		for( var i = 0, n = array_length(widgets); i < n; i++ ) if(widgets[i].isHovering()) return true;
		return false;
	}
	
	static drawParam = function(params) { #region
		setParam(params);
		tbCx.setParam(params);
		tbCy.setParam(params);
		tbFx.setParam(params);
		tbFy.setParam(params);
		tbW.setParam(params);
		tbH.setParam(params);
		rot.setParam(params);
		sW.setParam(params);setParam(params);
		scMode.setParam(params);
		
		return draw(params.x, params.y, params.w, params.h, params.data, params.m, params.rx, params.ry); 
	} #endregion
	
	static draw = function(_x, _y, _w, _h, _data, _m, _rx, _ry) {
		x = _x;
		y = _y;
		
		var _mode = array_safe_get_fast(_data, PUPPET_CONTROL.mode);
		var _cx   = array_safe_get_fast(_data, PUPPET_CONTROL.cx);
		var _cy   = array_safe_get_fast(_data, PUPPET_CONTROL.cy);
		var _fx   = array_safe_get_fast(_data, PUPPET_CONTROL.fx);
		var _fy   = array_safe_get_fast(_data, PUPPET_CONTROL.fy);
		var _wid  = array_safe_get_fast(_data, PUPPET_CONTROL.width);
		
		if(is_array(_mode) || is_array(_cx) || is_array(_cy) || is_array(_fx) || is_array(_fy) || is_array(_wid))
			return 0;
		
		for( var i = 0, n = array_length(widgets); i < n; i++ )
			widgets[i].setFocusHover(active, hover);
		
		var yy = _y;
		
		scMode.draw(_x, yy, _w, _h, sMode[_mode], _m, _rx, _ry);
		yy += _h + ui(4);
		
		var _ww = _w / 2;
		var _wh = _h;
		
		draw_sprite_stretched_ext(THEME.textbox, 3, _x, yy, _w, _wh, c_white, 1);
		draw_sprite_stretched_ext(THEME.textbox, 0, _x, yy, _w, _wh, c_white, 0.5 + 0.5 * interactable);	
		
		tbCx.draw(_x,	    yy, _ww, _wh, _cx, _m);
		tbCy.draw(_x + _ww, yy, _ww, _wh, _cy, _m);
		yy += _wh + ui(4);
		
		switch(_mode) {
			case PUPPET_FORCE_MODE.move: 
			case PUPPET_FORCE_MODE.puppet: 
			
				draw_sprite_stretched_ext(THEME.textbox, 3, _x, yy, _w, _wh, c_white, 1);
				draw_sprite_stretched_ext(THEME.textbox, 0, _x, yy, _w, _wh, c_white, 0.5 + 0.5 * interactable);	
		
				tbFx.label = "fx";
				tbFy.label = "fy";
				
				tbFx.draw(_x,		yy, _ww, _wh, _fx, _m);
				tbFy.draw(_x + _ww,	yy, _ww, _wh, _fy, _m);
				yy += _wh + ui(4);
				
				if(_mode == PUPPET_FORCE_MODE.move) {
					sW.label = __txt("radius");
					sW.draw(_x, yy, _w, _wh, _wid, _m);
					
					yy += _wh + ui(4);
				}
				break;
				
			case PUPPET_FORCE_MODE.wind: 
			
				draw_sprite_stretched_ext(THEME.textbox, 3, _x, yy, _w, _wh, c_white, 1);
				draw_sprite_stretched_ext(THEME.textbox, 0, _x, yy, _w, _wh, c_white, 0.5 + 0.5 * interactable);	
		
				tbFx.label = __txt("strength");
				tbW.label  = __txt("width");
				
				tbFx.draw(_x,       yy, _ww, _wh, _fx, _m);
				tbW.draw( _x + _ww, yy, _ww, _wh, _wid, _m);
				yy += _wh + ui(4);
				
				var _rh = rot.draw(_x, yy, _w, _wh, _fy, _m);
				yy += _rh + ui(4);
				break;
		}
		
		resetFocus();
		return yy - _y;
	}
	
	static clone = function() { #region
		var cln = new controlPointBox(onModify);
		
		return cln;
	} #endregion
}