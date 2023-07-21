function Node_PB_Box_Split(_x, _y, _group = noone) : Node_PB_Box(_x, _y, _group) constructor {
	name = "Split";
	
	inputs[| 1] = nodeValue("pBox", self, JUNCTION_CONNECT.input, VALUE_TYPE.pbBox, noone )
		.setVisible(true, true);
		
	inputs[| 2] = nodeValue("Type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Ratio", "Fix Left", "Fix Right" ]);
	
	inputs[| 3] = nodeValue("Ratio", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5 )
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 1, 0.01 ]);
	
	inputs[| 4] = nodeValue("Fix width", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 8 )
	
	inputs[| 5] = nodeValue("Axis", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.setDisplay(VALUE_DISPLAY.enum_button, [ "X", "Y" ]);
	
	inputs[| 6] = nodeValue("Mirror", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, 0 )
	
	outputs[| 0] = nodeValue("pBox Left", self, JUNCTION_CONNECT.output, VALUE_TYPE.pbBox, noone );
	
	outputs[| 1] = nodeValue("pBox Right", self, JUNCTION_CONNECT.output, VALUE_TYPE.pbBox, noone );
	
	input_display_list = [ 0, 1,
		["Split",	false], 5, 2, 3, 4, 6, 
	]
	
	static step = function() {
		var _typ = current_data[2];
		var _axs = current_data[5];
		
		inputs[| 3].setVisible(_typ == 0);
		inputs[| 4].setVisible(_typ != 0);
		
		if(_axs == 0) {
			inputs[| 2].editWidget.data_list = [ "Ratio", "Fix Left", "Fix Right" ];
			inputs[| 4].name = "Fix Width";
		} else {
			inputs[| 2].editWidget.data_list = [ "Ratio", "Fix Up", "Fix Down" ];
			inputs[| 4].name = "Fix Height";
		}
	}
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _b0 = outputs[| 0].getValue();
		var _b1 = outputs[| 1].getValue();
		
		if(!is_array(_b0)) _b0 = [ _b0 ];
		if(!is_array(_b1)) _b1 = [ _b1 ];
		
		for( var i = 0; i < array_length(_b0); i++ ) {
			var _b0x0 = _x    + _b0[i].x * _s;
			var _b0y0 = _y    + _b0[i].y * _s;
			var _b0x1 = _b0x0 + _b0[i].w * _s;
			var _b0y1 = _b0y0 + _b0[i].h * _s;
		
			draw_set_color(c_red);
			draw_rectangle(_b0x0, _b0y0, _b0x1, _b0y1, true);
		}
		
		for( var i = 0; i < array_length(_b1); i++ ) {
			var _b1x0 = _x    + _b1[i].x * _s;
			var _b1y0 = _y    + _b1[i].y * _s;
			var _b1x1 = _b1x0 + _b1[i].w * _s;
			var _b1y1 = _b1y0 + _b1[i].h * _s;
		
			draw_set_color(c_blue);
			draw_rectangle(_b1x0, _b1y0, _b1x1, _b1y1, true);
		}
	}
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _layr = _data[0];
		var _pbox = _data[1];
		var _type = _data[2];
		var _rati = _data[3];
		var _fixx = _data[4];
		var _axis = _data[5];
		var _mirr = _data[6];
		
		if(_pbox == noone) return noone;
		
		_pbox = _pbox.clone();
		_pbox.layer += _layr;
		
		if(_axis == 0) {
			var _w;
			
			switch(_type) {
				case 0 : _w = _pbox.w * _rati;	break;
				case 1 : _w = _fixx;			break;
				case 2 : _w = _pbox.w - _fixx;	break;
			}
			
			if(_pbox.mirror_h) {
				_output_index = !_output_index;
				_w = _pbox.w - _w;
			}
			
			if(_output_index == 0) {
				_pbox.w = round(_w);
			} else if(_output_index == 1) {
				_w = _pbox.w - _w;
				
				_pbox.x += _pbox.w - round(_w);
				_pbox.w  = round(_w);
				
				if(_mirr) _pbox.mirror_h = !_pbox.mirror_h;
			}
		} else {
			var _h;
			
			switch(_type) {
				case 0 : _h = _pbox.h * _rati;	break;
				case 1 : _h = _fixx;			break;
				case 2 : _h = _pbox.h - _fixx;	break;
			}
			
			if(_pbox.mirror_v) {
				_output_index = !_output_index;
				_h = _pbox.h - _h;
			}
			
			if(_output_index == 0) {
				_pbox.h = round(_h);
			} else if(_output_index == 1) {
				_h = _pbox.h - _h;
			
				_pbox.y += _pbox.h - round(_h);
				_pbox.h  = round(_h);
				
				if(_mirr) _pbox.mirror_v = !_pbox.mirror_v;
			}
		}
		
		return _pbox;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var _axs = current_data[5];
		var bbox = drawGetBbox(xx, yy, _s)
			.toSquare()
			.pad(8);
		
		draw_set_color(c_white);
		draw_rectangle_border(bbox.x0, bbox.y0, bbox.x1, bbox.y1, 2);
		
		if(_axs == 0)
			draw_line(bbox.xc, bbox.y0, bbox.xc, bbox.y1);
		else 
			draw_line(bbox.x0, bbox.yc, bbox.x1, bbox.yc);
	}
}