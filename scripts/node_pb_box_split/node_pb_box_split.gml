function Node_PB_Box_Split(_x, _y, _group = noone) : Node_PB_Box(_x, _y, _group) constructor {
	name = "Split";
	batch_output = false;
	
	inputs[1] = nodeValue("pBox", self, JUNCTION_CONNECT.input, VALUE_TYPE.pbBox, noone )
		.setVisible(true, true);
		
	inputs[2] = nodeValue_Enum_Scroll("Type", self,  0 , [ "Ratio", "Fix Left", "Fix Right" ]);
	
	inputs[3] = nodeValue_Float("Ratio", self, 0.5 )
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[4] = nodeValue_Int("Fix width", self, 8 )
	
	inputs[5] = nodeValue_Enum_Button("Axis", self,  0 , [ "X", "Y" ]);
	
	inputs[6] = nodeValue_Bool("Mirror", self, 0 )
	
	outputs[0] = nodeValue_Output("pBox Left", self, VALUE_TYPE.pbBox, noone );
	
	outputs[1] = nodeValue_Output("pBox Right", self, VALUE_TYPE.pbBox, noone );
	
	input_display_list = [ 0, 1,
		["Split",	false], 5, 2, 3, 4, 6, 
	]
	
	static step = function() {
		if(array_empty(current_data)) return noone;
		
		var _typ = current_data[2];
		var _axs = current_data[5];
		
		inputs[3].setVisible(_typ == 0);
		inputs[4].setVisible(_typ != 0);
		
		if(_axs == 0) {
			inputs[2].editWidget.data_list = [ "Ratio", "Fix Left", "Fix Right" ];
			inputs[4].name = "Fix Width";
		} else {
			inputs[2].editWidget.data_list = [ "Ratio", "Fix Up", "Fix Down" ];
			inputs[4].name = "Fix Height";
		}
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _layr = _data[0];
		var _pbox = _data[1];
		var _type = _data[2];
		var _rati = _data[3];
		var _fixx = _data[4];
		var _axis = _data[5];
		var _mirr = _data[6];
		
		if(_pbox == noone) return noone;
		
		var _nbox    = _pbox.clone();
		_nbox.layer += _layr;
		
		if(_axis == 0) {
			var _w;
			
			switch(_type) {
				case 0 : _w = _nbox.w * _rati;	break;
				case 1 : _w = _fixx;			break;
				case 2 : _w = _nbox.w - _fixx;	break;
			}
			
			if(_nbox.mirror_h) {
				_output_index = !_output_index;
				_w = _nbox.w - _w;
			}
			
			if(_output_index == 0) {
				_nbox.w = round(_w);
				
				if(is_surface(_pbox.mask)) {
					_nbox.mask = surface_verify(_nbox.mask, _nbox.w, _nbox.h);
					surface_set_target(_nbox.mask);
						DRAW_CLEAR
						draw_surface_safe(_pbox.mask);
					surface_reset_target();
				}
				
				if(is_surface(_pbox.content)) {
					_nbox.content = surface_verify(_nbox.content, _nbox.w, _nbox.h);
					surface_set_target(_nbox.content);
						DRAW_CLEAR
						draw_surface_safe(_pbox.content);
					surface_reset_target();
				}
			} else if(_output_index == 1) {
				_w = _nbox.w - _w;
				
				var shf  = _nbox.w - round(_w);
				_nbox.x += shf;
				_nbox.w  = round(_w);
				
				if(_mirr) _nbox.mirror_h = !_nbox.mirror_h;
				
				if(is_surface(_pbox.mask)) {
					_nbox.mask = surface_verify(_nbox.mask, _nbox.w, _nbox.h);
					surface_set_target(_nbox.mask);
						DRAW_CLEAR
						if(_mirr) 
							draw_surface_ext_safe(_pbox.mask, _nbox.w + shf, 0, -1, 1, 0, c_white, 1);
						else 
							draw_surface_safe(_pbox.mask, -shf, 0);
					surface_reset_target();
				}
				
				if(is_surface(_pbox.content)) {
					_nbox.content = surface_verify(_nbox.content, _nbox.w, _nbox.h);
					surface_set_target(_nbox.content);
						DRAW_CLEAR
						if(_mirr) 
							draw_surface_ext_safe(_pbox.content, _nbox.w + shf, 0, -1, 1, 0, c_white, 1);
						else 
							draw_surface_safe(_pbox.content, -shf, 0);
					surface_reset_target();
				}
			}
		} else {
			var _h;
			
			switch(_type) {
				case 0 : _h = _nbox.h * _rati;	break;
				case 1 : _h = _fixx;			break;
				case 2 : _h = _nbox.h - _fixx;	break;
			}
		
			if(_nbox.mirror_v) {
				_output_index = !_output_index;
				_h = _nbox.h - _h;
			}
			
			if(_output_index == 0) {
				_nbox.h = round(_h);
				
				if(is_surface(_pbox.mask)) {
					_nbox.mask = surface_verify(_nbox.mask, _nbox.w, _nbox.h);
					surface_set_target(_nbox.mask);
						DRAW_CLEAR
						draw_surface_safe(_pbox.mask);
					surface_reset_target();
				}
				
				if(is_surface(_pbox.content)) {
					_nbox.content = surface_verify(_nbox.content, _nbox.w, _nbox.h);
					surface_set_target(_nbox.content);
						DRAW_CLEAR
						draw_surface_safe(_pbox.content);
					surface_reset_target();
				}
			} else if(_output_index == 1) {
				_h = _nbox.h - _h;
			
				var shf  = _nbox.h - round(_h);
				_nbox.y += shf;
				_nbox.h  = round(_h);
				
				if(_mirr) _nbox.mirror_v = !_nbox.mirror_v;
				
				if(is_surface(_pbox.mask)) {
					_nbox.mask = surface_verify(_nbox.mask, _nbox.w, _nbox.h);
					surface_set_target(_nbox.mask);
						DRAW_CLEAR
						if(_mirr) 
							draw_surface_ext_safe(_pbox.mask, 0, _nbox.h + shf, 1, -1, 0, c_white, 1);
						else 
							draw_surface_safe(_pbox.mask, 0, -shf);
					surface_reset_target();
				}
				
				if(is_surface(_pbox.content)) {
					_nbox.content = surface_verify(_nbox.content, _nbox.w, _nbox.h);
					surface_set_target(_nbox.content);
						DRAW_CLEAR
						if(_mirr) 
							draw_surface_ext_safe(_pbox.content, 0, _nbox.h + shf, 1, -1, 0, c_white, 1);
						else 
							draw_surface_safe(_pbox.content, 0, -shf);
					surface_reset_target();
				}
			}
		}
		
		return _nbox;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var _axs = current_data[5];
		var bbox = drawGetBbox(xx, yy, _s)
			.toSquare()
			.pad(8);
		
		draw_set_color(c_white);
		draw_rectangle_border(bbox.x0, bbox.y0, bbox.x1, bbox.y1, 2);
		
		if(_axs == 0) draw_line(bbox.xc, bbox.y0, bbox.xc, bbox.y1);
		else          draw_line(bbox.x0, bbox.yc, bbox.x1, bbox.yc);
	}
}