function rangeBox(_type, _onModify) : widget() constructor {
	onModify = _onModify;
	linked   = false;
	
	disp_w = 0;
	
	tooltip	= new tooltipSelector("Value Type", [
		__txtx("widget_range_random",   "Random Range"),
		__txtx("widget_range_constant", "Constant"),
	]);
	
	onModifyIndex = function(index, val) { 
		var modi = false;
		
		if(linked) {
			for( var i = 0; i < 2; i++ )
				modi |= onModify(i, toNumber(val)); 
			return modi;
		}
		
		return onModify(index, toNumber(val)); 
	}
	
	labels = [ "min", "max" ];
	onModifySingle[0] = function(val) { return onModifyIndex(0, toNumber(val)); }
	onModifySingle[1] = function(val) { return onModifyIndex(1, toNumber(val)); }
	
	extras = -1;
	
	for(var i = 0; i < 2; i++) {
		tb[i] = new textBox(_type, onModifySingle[i]);
		tb[i].slidable = true;
		tb[i].hide     = true;
		tb[i].label    = labels[i];
	}
	
	static setSlideSpeed = function(speed) {
		tb[0].setSlidable(speed);
		tb[1].setSlidable(speed);
	}
	
	static setInteract = function(interactable = noone) { 
		self.interactable = interactable;
		
		tb[0].interactable = interactable;
		if(!linked) 
			tb[1].interactable = interactable;
	}
	
	static register = function(parent = noone) {
		tb[0].register(parent);
		if(!linked)
			tb[1].register(parent);
	}
	
	static drawParam = function(params) {
		setParam(params);
		for(var i = 0; i < 2; i++) tb[i].setParam(params);
		
		return draw(params.x, params.y, params.w, params.h, params.data, params.display_data, params.m);
	}
	
	static draw = function(_x, _y, _w, _h, _data, _display_data, _m) {
		x = _x;
		y = _y;
		w = _w;
		h = _h;
		if(struct_has(_display_data, "linked"))	   linked	  = _display_data.linked;
		tooltip.index = linked;
		
		var _icon_blend = linked? COLORS._main_accent : COLORS._main_icon;
		var _bs = min(_h, ui(32));
		
		if(side_button) {
			side_button.setFocusHover(active, hover);
			side_button.draw(_x + _w - _bs, _y + _h / 2 - _bs / 2, _bs, _bs, _m, THEME.button_hide);
			_w -= _bs + ui(4);
		}
		
		var bx  = _x;
		var by  = _y + _h / 2 - _bs / 2;
		
		if(buttonInstant(THEME.button_hide, bx, by, _bs, _bs, _m, active, hover, tooltip, THEME.value_link, linked, _icon_blend) == 2) {
			linked = !linked;
			_display_data.linked = linked;
			
			if(linked) {
				onModify(0, _data[0]);
				onModify(1, _data[0]);
			}
		}
		
		_x += _bs + ui(4);
		_w -= _bs + ui(4);
		
		var ww = linked? _w : _w / 2;
		disp_w = disp_w == 0? ww : lerp_float(disp_w, ww, 5);
		
		draw_sprite_stretched_ext(THEME.textbox, 3, _x, _y, _w, _h, c_white, 1);
		draw_sprite_stretched_ext(THEME.textbox, 0, _x, _y, _w, _h, c_white, 0.5 + 0.5 * interactable);	
			
		if(linked) {
			tb[0].setFocusHover(active, hover);
			tb[0].draw(_x, _y, disp_w, _h, _data[0], _m);
			
		} else if(is_array(_data) && array_length(_data) >= 2) {
			for(var i = 0; i < 2; i++) {
				tb[i].setFocusHover(active, hover);
				
				var bx  = _x + disp_w * i;
				tb[i].draw(bx, _y, disp_w, _h, _data[i], _m);
			}
		}
		
		resetFocus();
		
		return h;
	}
}