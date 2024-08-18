function Node_Path_Sample(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Sample Path";
	batch_output = false;
	setDimension(96, 48);
	
	inputs[0] = nodeValue_PathNode("Path", self, noone)
		.setVisible(true, true);
	
	newInput(1, nodeValue_Float("Ratio", self, 0));
	
	newInput(2, nodeValue_Enum_Scroll("Type", self,  0, [ "Loop", "Ping pong" ]));
	
	outputs[0] = nodeValue_Output("Position", self, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	outputs[1] = nodeValue_Output("Direction", self, VALUE_TYPE.float, 0);
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		var _path = getInputData(0);
		if(_path && struct_has(_path, "drawOverlay")) _path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
		
		var _pnt = outputs[0].getValue();
		if(process_amount == 1) _pnt = [ _pnt ];
		
		draw_set_color(COLORS._main_accent);
		for( var i = 0, n = array_length(_pnt); i < n; i++ ) {
			var _p  = _pnt[i];
			var _px = _x + _p[0] * _s;
			var _py = _y + _p[1] * _s;
			
			draw_circle(_px, _py, 4, false);
		}
	} #endregion
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { #region
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
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(THEME.node_draw_path, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	} #endregion
}