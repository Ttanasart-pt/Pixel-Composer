function sliderRange(_step, _int, _range, _onModify) : widget() constructor {
	slide_range = _range;
	curr_range  = [ _range[0], _range[1] ];
	stepSize    = _step;
	isInt       = _int;
	
	onModify = _onModify;
	
	tb_value_min = new textBox(TEXTBOX_INPUT.number, function(val) { return onModify(0, clamp(val, curr_range[0], curr_range[1])); }).setSlidable(_step, _int, _range);
	tb_value_max = new textBox(TEXTBOX_INPUT.number, function(val) { return onModify(1, clamp(val, curr_range[0], curr_range[1])); }).setSlidable(_step, _int, _range);
	
	tb_value_min.hide = true;
	tb_value_max.hide = true;
	
	static setSlideSpeed = function(speed) { #region
		tb_value_min.setSlidable(speed);
		tb_value_max.setSlidable(speed);
	} #endregion
	
	static setInteract = function(interactable = noone) { #region
		self.interactable = interactable;
		tb_value_min.interactable = interactable;
		tb_value_max.interactable = interactable;
	} #endregion
	
	static register = function(parent = noone) { #region
		tb_value_min.register(parent);
		tb_value_max.register(parent);
	} #endregion
	
	static drawParam = function(params) { #region
		return draw(params.x, params.y, params.w, params.h, params.data, params.m);
	} #endregion
	
	static draw = function(_x, _y, _w, _h, _data, _m) { #region
		x = _x;
		y = _y;
		w = _w;
		h = _h;
		if(!is_real(_data[0])) return h;
		if(!is_real(_data[1])) return h;
		
		draw_sprite_stretched_ext(THEME.textbox, 3, _x, _y, _w, _h, c_white, 1);
		
		var _minn = slide_range[0];
		var _maxx = slide_range[1];
		var _rang = abs(_maxx - _minn);
		var _currMin = min(_data[0], _data[1]);
		var _currMax = max(_data[0], _data[1]);
			
		if(tb_value_min.sliding != 2 && tb_value_max.sliding != 2) {
			curr_range[0] = (_currMin >= _minn)? _minn : _minn - ceil(abs(_currMin - _minn) / _rang) * _rang; 
			curr_range[1] = (_currMax <= _maxx)? _maxx : _maxx + ceil(abs(_currMax - _maxx) / _rang) * _rang;
		}
			
		var lx = _w * (_currMin - curr_range[0]) / (curr_range[1] - curr_range[0]);
		var lw = _w * ((_currMax - _currMin) - curr_range[0]) / (curr_range[1] - curr_range[0]);
		
		draw_sprite_stretched_ext(THEME.textbox, 4, _x + lx, _y, lw, _h, c_white, 1);
		
		var tb_w = _w / 2;
		
		if(tb_value_min.selecting || tb_value_max.selecting) {
			draw_sprite_stretched_ext(THEME.textbox, 1, _x, _y, _w, _h, c_white, 1);	
		} else {
			draw_sprite_stretched_ext(THEME.textbox, 0, _x, _y, _w, _h, c_white, 0.5 + 0.5 * interactable);	
		}
		
		tb_value_min.setFocusHover(active, hover);
		tb_value_min.draw(_x, _y, tb_w, _h, _data[0], _m);
		
		tb_value_max.setFocusHover(active, hover);
		tb_value_max.draw(_x + tb_w, _y, tb_w, _h, _data[1], _m);
		
		return h;
	} #endregion
}