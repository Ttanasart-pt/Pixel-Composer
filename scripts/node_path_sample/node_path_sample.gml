function Node_Path_Sample(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Sample Path";
	setDimension(96, 48);
	
	newInput(0, nodeValue_PathNode("Path"));
	
	newInput(1, nodeValue_Float("Ratio", 0));
	
	newInput(2, nodeValue_Enum_Scroll("Type",  0, [ "Loop", "Ping pong" ]));
	
	newOutput(0, nodeValue_Output("Position", VALUE_TYPE.float, [ 0, 0 ]))
		.setDisplay(VALUE_DISPLAY.vector);
	
	newOutput(1, nodeValue_Output("Direction", VALUE_TYPE.float, 0));
	
	newOutput(2, nodeValue_Output("Weight", VALUE_TYPE.float, 0));
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var _path = getInputData(0);
		if(has(_path, "drawOverlay")) InputDrawOverlay(_path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny));
		
		var _pnt = outputs[0].getValue();
		if(process_amount == 1) _pnt = [ _pnt ];
		
		draw_set_color(COLORS._main_accent);
		for( var i = 0, n = array_length(_pnt); i < n; i++ ) {
			var _p  = _pnt[i];
			var _px = _x + _p[0] * _s;
			var _py = _y + _p[1] * _s;
			
			draw_circle(_px, _py, 4, false);
		}
	}
	
	__temp_p  = new __vec2P();
	__temp_p0 = new __vec2P();
	__temp_p1 = new __vec2P();
	
	static processData = function(_output, _data, _array_index = 0) {
		var _path = _data[0];
		var _rat  = _data[1];
		var _mod  = _data[2];
		
		if(_path == noone)						return _output;
		if(!struct_has(_path, "getPointRatio")) return _output;
		if(!is_real(_rat))						return _output;
		var inv = false;
		
		switch(_mod) {
			case 0 : _rat = frac(_rat); break;
				
			case 1 : 
				var fl = floor(_rat);
				var fr = frac(_rat);
				
				if(fl % 2 == 1 && fr != 0) {
					fr = 1 - fr;
					inv = true;
				}
				_rat = fr;
				break;
		}
		
		_path.getPointRatio(_rat, 0, __temp_p);
		
		var _px = __temp_p.x;
		var _py = __temp_p.y;
		var _pw = __temp_p.weight;
		
		var r0 = clamp(_rat - 0.0001, 0, 1);
		var r1 = clamp(_rat + 0.0001, 0, 1);
		
		_path.getPointRatio(r0, 0, __temp_p0);
		_path.getPointRatio(r1, 0, __temp_p1);
		
		var dir = inv? __temp_p1.directionTo(__temp_p0) : __temp_p0.directionTo(__temp_p1);
		
		return [
			[ _px, _py ],
			dir,
			_pw
		];
		
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_bbox_uniform(s_node_path_sample, 0, bbox);
	}
}