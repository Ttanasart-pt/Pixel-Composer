function Node_PB_Fx_Highlight(_x, _y, _group = noone) : Node_PB_Fx(_x, _y, _group) constructor {
	name = "Highlight";
	
	inputs[| 1] = nodeValue("Highlight Area", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, array_create(9) )
		.setDisplay(VALUE_DISPLAY.kernel);
		
	inputs[| 2] = nodeValue("Light Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white );
		
	inputs[| 3] = nodeValue("Shadow Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_black );
		
	inputs[| 4] = nodeValue("Roughness", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0 )
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 1, 0.01 ]);
		
	inputs[| 5] = nodeValue("Roughness Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1 );
		
	inputs[| 6] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, irandom_range(100000, 999999) );
	
	holding_side = noone;
	
	side_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		var _size  = 32;
		var _space = 8;
		var ww     = (_size * 3) + (_space * 2); 
		var hh     = ww + ui(16);
		
		var _x0 = _x + _w / 2 - ww / 2;
		var _y0 = _y + ui(8);
		
		var _side  = inputs[| 1].getValue();
		
		if(holding_side != noone && mouse_release(mb_left))
			holding_side = noone;
		
		for( var i = 0; i < 3; i++ ) 
		for( var j = 0; j < 3; j++ ) {
			var ind = i * 3 + j;
			var _sx = _x0 + j * (_space + _size);
			var _sy = _y0 + i * (_space + _size);
			
			if(_hover && point_in_rectangle(_m[0], _m[1], _sx, _sy, _sx + _size, _sy + _size)) {
				draw_sprite_stretched(THEME.button, 1, _sx, _sy, _size, _size);
				
				if(mouse_click(mb_left, _focus)) {
					draw_sprite_stretched(THEME.button, 2, _sx, _sy, _size, _size);
					
					if(holding_side != noone) {
						_side[ind] = holding_side;
						inputs[| 1].setValue(_side);
					}
				}
					
				if(mouse_press(mb_left, _focus)) {
					if(ind == 4)
						_side[ind] = !_side[ind];
					else
						_side[ind] = (_side[ind] + 2) % 3 - 1;
					inputs[| 1].setValue(_side);
					
					holding_side = _side[ind];
				}
			} else
				draw_sprite_stretched(THEME.button, 0, _sx, _sy, _size, _size);
			
			if(ind == 4) {
				if(_side[ind]) draw_sprite_stretched_ext(THEME.color_picker_box, 1, _sx + ui(2), _sy + ui(2), _size - ui(4), _size - ui(4), COLORS._main_accent, 1);
			} else {
				switch(_side[ind]) {
					case  1 : draw_sprite_stretched_ext(THEME.color_picker_box, 1, _sx + ui(2), _sy + ui(2), _size - ui(4), _size - ui(4), c_white, 1); break;
					case -1 : draw_sprite_stretched_ext(THEME.color_picker_box, 1, _sx + ui(2), _sy + ui(2), _size - ui(4), _size - ui(4), c_black, 1); break;
				}
			}
		}
		
		return hh;
	});
	
	input_display_list = [ 0, 
		["Effect",		false], side_renderer, 2, 3, 
		["Roughness",	false], 4, 5, 6, 
	];
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _surf = _data[0];
		var _high = _data[1];
		var _chig = _data[2];
		var _csha = _data[3];
		var _roug = _data[4];
		var _rSca = _data[5];
		var _seed = _data[6];
		
		surface_set_shader(_outSurf, sh_pb_highlight);
			shader_set_dim(, _surf);
			shader_set_i("sides", _high);
			
			shader_set_color("highlightColor", _chig);
			shader_set_color("shadowColor", _csha);
			shader_set_f("roughness", _roug);
			shader_set_f("roughScale", _rSca);
			shader_set_f("seed", _seed);
			DRAW_CLEAR
			
			draw_surface_safe(_surf, 0, 0);
		surface_reset_shader();
		
		return _outSurf;
	}
}