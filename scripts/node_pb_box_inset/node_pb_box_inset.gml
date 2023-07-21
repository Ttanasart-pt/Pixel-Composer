function Node_PB_Box_Inset(_x, _y, _group = noone) : Node_PB_Box(_x, _y, _group) constructor {
	name = "Inset";
	
	inputs[| 1] = nodeValue("pBox", self, JUNCTION_CONNECT.input, VALUE_TYPE.pbBox, noone )
		.setVisible(true, true);
		
	inputs[| 2] = nodeValue("Inset", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 2, 2, 2, 2 ] )
		.setDisplay(VALUE_DISPLAY.padding);
		
	inputs[| 3] = nodeValue("Type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Padding", "Ratio" ]);
		
	inputs[| 4] = nodeValue("Width", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5 )
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 1, 0.01 ]);
		
	inputs[| 5] = nodeValue("Height", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5 )
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 1, 0.01 ]);
	
	inputs[| 6] = nodeValue("Horizontal alignment", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5 )
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 1, 0.01 ]);
	
	inputs[| 7] = nodeValue("Vertical alignment", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5 )
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 1, 0.01 ]);
		
	outputs[| 0] = nodeValue("pBox Inset", self, JUNCTION_CONNECT.output, VALUE_TYPE.pbBox, noone );
	
	outputs[| 1] = nodeValue("pBox Frame", self, JUNCTION_CONNECT.output, VALUE_TYPE.pbBox, noone );
	
	input_display_list = [ 0, 1,
		["Inset",	false], 3, 2, 4, 5, 6, 7, 
	]
		
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _b0 = outputs[| 0].getValue();
		
		var _b0x0 = _x    + _b0.x * _s;
		var _b0y0 = _y    + _b0.y * _s;
		var _b0x1 = _b0x0 + _b0.w * _s;
		var _b0y1 = _b0y0 + _b0.h * _s;
		
		draw_set_color(c_red);
		draw_rectangle(_b0x0, _b0y0, _b0x1, _b0y1, true);
	}
	
	static step = function() {
		var _type = current_data[3];
		
		inputs[| 2].setVisible(_type == 0);
		inputs[| 4].setVisible(_type == 1);
		inputs[| 5].setVisible(_type == 1);
		inputs[| 6].setVisible(_type == 1);
		inputs[| 7].setVisible(_type == 1);
	}
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _layr = _data[0];
		var _pbox = _data[1];
		var _inst = _data[2];
		var _type = _data[3];
		var _widt = _data[4];
		var _high = _data[5];
		var _hali = _data[6];
		var _vali = _data[7];
		
		if(_pbox == noone) return noone;
		
		_pbox = _pbox.clone();
		
		var x0, y0, w, h;
		
		if(_type == 0) {
			if(_pbox.mirror_h)	x0 = _pbox.x + _inst[0];
			else				x0 = _pbox.x + _inst[2];
			
			if(_pbox.mirror_v)	y0 = _pbox.y + _inst[3];
			else				y0 = _pbox.y + _inst[1];
			
			w  = _pbox.w - (_inst[0] + _inst[2]);
			h  = _pbox.h - (_inst[1] + _inst[3]);
		} else if(_type == 1) {
			w  = round(_pbox.w * _widt);
			h  = round(_pbox.h * _high);
			
			x0 = _pbox.x + (_pbox.w - w) * (_pbox.mirror_h? 1. - _hali : _hali);
			y0 = _pbox.y + (_pbox.h - h) * (_pbox.mirror_v? 1. - _vali : _vali);
		}
		
		if(_output_index == 0) {
			_pbox.layer += _layr;
			_pbox.x = x0;
			_pbox.y = y0;
			_pbox.w = w; 
			_pbox.h = h; 
		} else if(_output_index == 1) { 
			_pbox.mask = surface_create_valid(_pbox.w, _pbox.h);
			
			var _x = x0 - _pbox.x;
			var _y = y0 - _pbox.y;
			var _w = w;
			var _h = h;
			
			surface_set_target(_pbox.mask);
				draw_clear(c_white);
				
				draw_set_color(c_white);
				BLEND_SUBTRACT
					draw_rectangle(_x, _y, _x + _w - 1, _y + _h - 1, false);
				BLEND_NORMAL
			surface_reset_target();
		}
		
		return _pbox;
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