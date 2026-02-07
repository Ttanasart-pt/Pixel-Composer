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
	always_break_line = true;
	onModify          = _onModify;
	onSurfaceSize     = -1;
	
	sMode = [
		__txtx("widget_control_point_move",   "Move"), 
		__txtx("widget_control_point_wind",   "Wind"), 
	];
	
	tbCx   = textBox_Number( function(val) /*=>*/ {return onModify(toNumber(val),         PUPPET_CONTROL.cx     )}).setHide(1).setLabel("cx");
	tbCy   = textBox_Number( function(val) /*=>*/ {return onModify(toNumber(val),         PUPPET_CONTROL.cy     )}).setHide(1).setLabel("cy");
	tbFx   = textBox_Number( function(val) /*=>*/ {return onModify(toNumber(val),         PUPPET_CONTROL.fx     )}).setHide(1);
	tbFy   = textBox_Number( function(val) /*=>*/ {return onModify(toNumber(val),         PUPPET_CONTROL.fy     )}).setHide(1);
	tbW    = textBox_Number( function(val) /*=>*/ {return onModify(max(0, toNumber(val)), PUPPET_CONTROL.width  )}).setHide(1);
	tbH    = textBox_Number( function(val) /*=>*/ {return onModify(max(0, toNumber(val)), PUPPET_CONTROL.height )}).setHide(1);
	sW     = textBox_Number( function(val) /*=>*/ {return onModify(toNumber(val),         PUPPET_CONTROL.width  )})//.setHide(1);
	rot    = new rotator(    function(val) /*=>*/ {return onModify(toNumber(val),         PUPPET_CONTROL.fy     )})//.setHide(1);
	scMode = new scrollBox( sMode, function(val) /*=>*/ {return onModify(toNumber(val),   PUPPET_CONTROL.mode   )});
	
	widgets   = [ scMode, tbCx, tbCy, tbFx, tbFy, tbW, tbH, rot, sW ];
	widgetLen = array_length(widgets);
	
	static setInteract = function(n = noone) /*=>*/ { interactable = n; for( var i = 0; i < widgetLen; i++ ) widgets[i].setInteract(n); }
	static register    = function(p = noone) /*=>*/ {                   for( var i = 0; i < widgetLen; i++ ) widgets[i].register(p);    }
	static isHovering  = function() /*=>*/ {return array_any(widgets, function(w) /*=>*/ {return w.isHovering()})};
	
	static fetchHeight = function(params) { return params.h + ui(4) + params.h * 2; }
	static drawParam   = function(params) {
		setParam(params);
		for( var i = 0; i < widgetLen; i++ ) widgets[i].setParam(params);
		
		return draw(params.x, params.y, params.w, params.h, params.data, params.m, params.rx, params.ry); 
	}
	
	static draw = function(_x, _y, _w, _h, _data, _m, _rx, _ry) {
		x = _x;
		y = _y;
		
		var _mode = array_safe_get_fast( _data, PUPPET_CONTROL.mode  );
		var _cx   = array_safe_get_fast( _data, PUPPET_CONTROL.cx    );
		var _cy   = array_safe_get_fast( _data, PUPPET_CONTROL.cy    );
		var _fx   = array_safe_get_fast( _data, PUPPET_CONTROL.fx    );
		var _fy   = array_safe_get_fast( _data, PUPPET_CONTROL.fy    );
		var _wid  = array_safe_get_fast( _data, PUPPET_CONTROL.width );
		
		if(is_array(_mode) || is_array(_cx) || is_array(_cy) || is_array(_fx) || is_array(_fy) || is_array(_wid))
			return 0;
		
		var yy = _y;
		var w2 = _w / 2;
		var ww = _w / 4;
		var lh = _h;
		h = _h + ui(4) + lh;
		
		for( var i = 0; i < widgetLen; i++ )
			widgets[i].setFocusHover(active, hover);
		
		scMode.draw(_x, yy, w2 - ui(2), _h, sMode[_mode], _m, _rx, _ry);
		yy += _h + ui(4);
		
		if(hide == 0) {
			draw_sprite_stretched_ext(THEME.textbox, 3, _x, yy, _w, lh, boxColor,  1);
			draw_sprite_stretched_ext(THEME.textbox, 0, _x, yy, _w, lh, boxColor, .5 + .5 * interactable);	
		}
		
		tbCx.draw(_x,      yy, ww, _h, _cx, _m);
		tbCy.draw(_x + ww, yy, ww, _h, _cy, _m);
		
		switch(_mode) {
			case PUPPET_FORCE_MODE.move   : 
			case PUPPET_FORCE_MODE.puppet : 
				tbFx.label = "fx";
				tbFy.label = "fy";
				
				tbFx.draw(_x + ww * 2, yy, ww, _h, _fx, _m);
				tbFy.draw(_x + ww * 3, yy, ww, _h, _fy, _m);
				yy += _h;
				
				if(_mode == PUPPET_FORCE_MODE.move) {
					sW.label = __txt("radius");
					sW.draw(_x + w2, _y, w2, _h, _wid, _m);
					
					yy += _h;
				}
				break;
				
			case PUPPET_FORCE_MODE.wind : 
				tbFx.label = __txt("strength");
				tbW.label  = __txt("width");
				
				tbFx.draw(_x + ww * 2, yy, ww, _h, _fx,  _m);
				tbW.draw( _x + ww * 3, yy, ww, _h, _wid, _m);
				yy += _h;
				
				rot.draw(_x + w2, _y, w2, _h, _fy, _m);
				yy += _h;
				break;
		}
		
		resetFocus();
		return h;
	}
	
	static clone = function() { return new controlPointBox(onModify); }

	static free = function() {
		for( var i = 0, n = widgetLen; i < n; i++ ) 
			widgets[i].free();
	}
}