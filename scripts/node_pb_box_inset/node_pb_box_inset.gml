function Node_PB_Box_Inset(_x, _y, _group = noone) : Node_PB_Box(_x, _y, _group) constructor {
	name = "Inset";
	batch_output = false;
	
	inputs[| 1] = nodeValue("pBox", self, JUNCTION_CONNECT.input, VALUE_TYPE.pbBox, noone )
		.setVisible(true, true);
		
	inputs[| 2] = nodeValue("Inset", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 2, 2, 2, 2 ] )
		.setDisplay(VALUE_DISPLAY.padding);
		
	inputs[| 3] = nodeValue("Type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Padding", "Ratio" ]);
		
	inputs[| 4] = nodeValue("Width", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5 )
		.setDisplay(VALUE_DISPLAY.slider);
		
	inputs[| 5] = nodeValue("Height", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5 )
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 6] = nodeValue("Horizontal alignment", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5 )
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 7] = nodeValue("Vertical alignment", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5 )
		.setDisplay(VALUE_DISPLAY.slider);
		
	outputs[| 0] = nodeValue("pBox Inset", self, JUNCTION_CONNECT.output, VALUE_TYPE.pbBox, noone );
	
	outputs[| 1] = nodeValue("pBox Frame", self, JUNCTION_CONNECT.output, VALUE_TYPE.pbBox, noone );
	
	input_display_list = [ 0, 1,
		["Inset",	false], 3, 2, 4, 5, 6, 7, 
	]
	
	static step = function() {
		if(array_empty(current_data)) return;
		
		var _type = current_data[3];
		
		inputs[| 2].setVisible(_type == 0);
		inputs[| 4].setVisible(_type == 1);
		inputs[| 5].setVisible(_type == 1);
		inputs[| 6].setVisible(_type == 1);
		inputs[| 7].setVisible(_type == 1);
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _layr = _data[0];
		var _pbox = _data[1];
		var _inst = _data[2];
		var _type = _data[3];
		var _widt = _data[4];
		var _high = _data[5];
		var _hali = _data[6];
		var _vali = _data[7];
		
		if(_pbox == noone) return noone;
		
		var _nbox = _pbox.clone();
		
		var x0, y0, w, h;
		
		if(_type == 0) {
			if(_nbox.mirror_h)	x0 = _nbox.x + _inst[0];
			else				x0 = _nbox.x + _inst[2];
			
			if(_nbox.mirror_v)	y0 = _nbox.y + _inst[3];
			else				y0 = _nbox.y + _inst[1];
			
			w  = _nbox.w - (_inst[0] + _inst[2]);
			h  = _nbox.h - (_inst[1] + _inst[3]);
		} else if(_type == 1) {
			w  = round(_nbox.w * _widt);
			h  = round(_nbox.h * _high);
			
			x0 = round(_nbox.x + (_nbox.w - w) * (_nbox.mirror_h? 1. - _hali : _hali));
			y0 = round(_nbox.y + (_nbox.h - h) * (_nbox.mirror_v? 1. - _vali : _vali));
		}
		
		if(_output_index == 0) {
			_nbox.layer += _layr;
			_nbox.x = x0;
			_nbox.y = y0;
			_nbox.w = w; 
			_nbox.h = h; 
			
			if(is_surface(_pbox.mask)) {
				if(_type == 0) {
					_nbox.mask = surface_verify(_nbox.mask, _nbox.w, _nbox.h);
					surface_set_shader(_nbox.mask, sh_pb_mask_inset);
						shader_set_dim(, _pbox.mask);
						shader_set_f("inset", _inst);
					
						draw_surface_safe(_pbox.mask, -_inst[2], -_inst[1]);
					surface_reset_shader();
				} else if(_type == 1)
					_nbox.mask = surface_stretch(_pbox.mask, _nbox.w, _nbox.h);
			}
			
			if(is_surface(_pbox.content)) {
				if(_type == 0) {
					_nbox.content = surface_verify(_nbox.content, _nbox.w, _nbox.h);
					surface_set_shader(_nbox.content, sh_pb_mask_inset);
						shader_set_dim(, _pbox.content);
						shader_set_f("inset", _inst);
					
						draw_surface_safe(_pbox.content, -_inst[2], -_inst[1]);
					surface_reset_shader();
				} else if(_type == 1)
					_nbox.content = surface_stretch(_pbox.content, _nbox.w, _nbox.h);
			}
		} else if(_output_index == 1) { 
			_nbox.mask    = surface_create_valid(_nbox.w, _nbox.h);
			_nbox.content = surface_create_valid(_nbox.w, _nbox.h);
			
			var _x = x0 - _nbox.x;
			var _y = y0 - _nbox.y;
			var _w = w;
			var _h = h;
			
			surface_set_target(_nbox.mask);
				if(is_surface(_pbox.mask)) {
					draw_clear_alpha(0, 0);
					draw_surface_safe(_pbox.mask, 0, 0);
				} else 
					draw_clear(c_white);
				
				var _msk = outputs[| 0].getValue();
				if(is_array(_msk)) _msk = array_safe_get_fast(_msk, _array_index);
				
				BLEND_SUBTRACT
					if(is_surface(_msk.mask))
						draw_surface_safe(_msk.mask, _x, _y);
					else {
						draw_set_color(c_white);
						draw_rectangle(_x, _y, _x + _w - 1, _y + _h - 1, false);
					}
				BLEND_NORMAL
			surface_reset_target();
		}
		
		return _nbox;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s)
			.toSquare()
			.pad(8);
		
		draw_set_color(c_white);
		draw_rectangle_border(bbox.x0, bbox.y0, bbox.x1, bbox.y1, 2);
		
		bbox.pad(8);
		draw_rectangle_border(bbox.x0, bbox.y0, bbox.x1, bbox.y1, 1);
	}
}