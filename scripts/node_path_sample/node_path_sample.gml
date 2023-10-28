function Node_Path_Sample(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name		= "Sample Path";
	previewable = false;
	
	w = 96;
	
	inputs[| 0] = nodeValue("Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.pathnode, noone)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Ratio", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0);
	
	inputs[| 2] = nodeValue("Type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Loop", "Ping pong" ]);
	
	outputs[| 0] = nodeValue("Position", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	outputs[| 1] = nodeValue("Direction", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	
	static processData = function(_output, _data, _output_index, _array_index = 0) {  
		var _path = _data[0];
		var _rat  = _data[1];
		var _mod  = _data[2];
		
		if(_path == noone)						return [ 0, 0 ];
		if(!struct_has(_path, "getPointRatio")) return [ 0, 0 ];
		if(!is_real(_rat))						return [ 0, 0 ];
		var inv = false;
		
		switch(_mod) {
			case 0 : 
				_rat = frac(_rat);
				break;
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
			
		if(_output_index == 0)
			return _path.getPointRatio(_rat).toArray();
		else if(_output_index == 1) {
			var r0 = clamp(_rat - 0.0001, 0, 1);
			var r1 = clamp(_rat + 0.0001, 0, 1);
			
			var p0 = _path.getPointRatio(r0);
			var p1 = _path.getPointRatio(r1);
			
			var dir = inv? p1.directionTo(p0) : p0.directionTo(p1);
			return dir;
		} 
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(THEME.node_draw_path, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}