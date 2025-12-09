function Node_PB_Box_Mirror(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "PBBox Mirror";
	color = COLORS.node_blend_feedback;
	setDimension(96, 48);
	setDrawIcon(s_node_pb_box_mirror);
	
	newInput(0, nodeValue_Pbbox("Mirror PBBOX"));
	newInput(1, nodeValue_Pbbox("PBBOX"));
	
	newInput(2, nodeValue_Toggle("Axis", 0, { data: [ "X", "Y" ] }));
	
	newOutput(0, nodeValue_Output("PBBOX", VALUE_TYPE.pbBox, noone));
	
	input_display_list = [
		["Layout", false], 0, 1, 
		["Mirror", false], 2, 
	]
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var _pbase = getSingleValue(0);
		var _pbbox = getSingleValue(1);
		var _axis  = getSingleValue(2);
		
		if(is(_pbase, __pbBox)) {
			draw_set_color(COLORS._main_icon);
			_pbase.drawOverlayBBOX(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, self);
			
			var _basebox = _pbase.getBBOX();
			if(_axis & 0b01) {
				var _mr = (_basebox[0] + _basebox[2]) / 2;
				draw_line_dashed(
					_x + _s * _mr, 
					_y + _s * _basebox[1],
					_x + _s * _mr, 
					_y + _s * _basebox[3],
				);
			}
			
			if(_axis & 0b10) {
				var _mr = (_basebox[1] + _basebox[3]) / 2;
				draw_line_dashed(
					_x + _s * _basebox[0],
					_y + _s * _mr, 
					_x + _s * _basebox[2],
					_y + _s * _mr, 
				);
			}
			
		}
		
		if(is(_pbbox, __pbBox)) {
			draw_set_color(COLORS._main_icon_light);
			_pbbox.drawOverlayBBOX(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, self);
		}
		
		var _pbres = getSingleValue(0,, true);
		if(is(_pbres, __pbBox)) _pbres.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, self);
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _dim   = group.dimension;
		var _pbase = _data[0];
		var _pbbox = _data[1];
		var _axis  = _data[2];
		
		if(inputs[0].value_from == noone) _pbase.base_bbox = [ 0, 0, _dim[0], _dim[1] ];
		var _basebox = _pbase.getBBOX();
		var _forebox = _pbbox.getBBOX();
		var _mirrbox = array_clone(_forebox);
		
		if(_axis & 0b01) {
			var _mr = (_basebox[0] + _basebox[2]) / 2;
			
			_mirrbox[0] = _forebox[2] + (_mr - _forebox[2]) * 2;
			_mirrbox[2] = _forebox[0] + (_mr - _forebox[0]) * 2;
		}
		
		if(_axis & 0b10) {
			var _mr = (_basebox[1] + _basebox[3]) / 2;
			
			_mirrbox[1] = _forebox[3] + (_mr - _forebox[3]) * 2;
			_mirrbox[3] = _forebox[1] + (_mr - _forebox[1]) * 2;
		}
		
		var _mbox = _pbbox.clone();
		_mbox.setBBOX(_mirrbox);
		
		return _mbox;
	}
	
}