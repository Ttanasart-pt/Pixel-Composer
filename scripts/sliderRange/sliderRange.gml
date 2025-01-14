function sliderRange(_step, _int, _range, _onModify) : widget() constructor {
	stepSize    = _step;
	slide_range = _range;
	isInt       = _int;
	curr_range  = [ _range[0], _range[1] ];
	
	onModify = _onModify;
	
	tb_value_min = new textBox(TEXTBOX_INPUT.number, function(val) /*=>*/ {return onModify(val, 0)})
		.setSlideType(_int).setSlideStep(_step).setSlideRange(_range[0], _range[1]);
		
	tb_value_max = new textBox(TEXTBOX_INPUT.number, function(val) /*=>*/ {return onModify(val, 1)})
		.setSlideType(_int).setSlideStep(_step).setSlideRange(_range[0], _range[1]);
	
	tb_value_min.hide = true;
	tb_value_max.hide = true;
	
	static setInteract = function(interactable = noone) {
		self.interactable = interactable;
		tb_value_min.interactable = interactable;
		tb_value_max.interactable = interactable;
	}
	
	static register = function(parent = noone) {
		tb_value_min.register(parent);
		tb_value_max.register(parent);
	}
	
	static isHovering = function() { return tb_value_min.hovering || tb_value_max.hovering; }
	
	static drawParam = function(params) {
		setParam(params);
		tb_value_min.setParam(params);
		tb_value_max.setParam(params);
		
		return draw(params.x, params.y, params.w, params.h, params.data, params.m);
	}
	
	static draw = function(_x, _y, _w, _h, _data, _m) {
		x = _x;
		y = _y;
		w = _w;
		h = _h;
		if(!is_real(_data[0])) return h;
		if(!is_real(_data[1])) return h;
		
		draw_sprite_stretched_ext(THEME.textbox, 3, _x, _y, _w, _h, boxColor, 1);
		
		var _minn = slide_range[0];
		var _maxx = slide_range[1];
		var _rang = abs(_maxx - _minn);
		var _currMin = min(_data[0], _data[1]);
		var _currMax = max(_data[0], _data[1]);
			
		if(tb_value_min.sliding != 2 && tb_value_max.sliding != 2) {
			curr_range[0] = (_currMin >= _minn)? _minn : _minn - ceil(abs(_currMin - _minn) / _rang) * _rang; 
			curr_range[1] = (_currMax <= _maxx)? _maxx : _maxx + ceil(abs(_currMax - _maxx) / _rang) * _rang;
		}
			
		var lx = _w * ((_currMin           ) - curr_range[0]) / (curr_range[1] - curr_range[0]);
		var lw = _w * ((_currMax - _currMin) - curr_range[0]) / (curr_range[1] - curr_range[0]);
		
		draw_sprite_stretched_ext(THEME.textbox, 4, _x + lx, _y, lw, _h, boxColor, 1);
		
		var tb_w = _w / 2;
		
		if(tb_value_min.selecting || tb_value_max.selecting)
			draw_sprite_stretched_ext(THEME.textbox, 1, _x, _y, _w, _h, boxColor, 1);	
		else
			draw_sprite_stretched_ext(THEME.textbox, 0, _x, _y, _w, _h, boxColor, 0.5 + 0.5 * interactable);	
		
		tb_value_min.curr_range[0] = curr_range[0];
		tb_value_min.curr_range[1] = curr_range[1];
		
		tb_value_min.setFocusHover(active, hover);
		tb_value_min.draw(_x, _y, tb_w, _h, _data[0], _m);
		
		tb_value_max.curr_range[0] = curr_range[0];
		tb_value_max.curr_range[1] = curr_range[1];
		
		tb_value_max.setFocusHover(active, hover);
		tb_value_max.draw(_x + tb_w, _y, tb_w, _h, _data[1], _m);
		
		return h;
	}
		
	static clone = function() {
		var cln = new sliderRange(stepSize, isInt, slide_range, onModify);
		
		return cln;
	}

	static free = function() {
		tb_value_min.free();
		tb_value_max.free();
	}
}