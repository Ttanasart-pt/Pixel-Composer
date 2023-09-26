function Node_Path_Wave(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "Wave Path";
	previewable = false;
	
	w = 96;
	
	inputs[| 0] = nodeValue("Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.pathnode, noone)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Frequency", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 4);
	
	inputs[| 2] = nodeValue("Size", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 4);
	
	inputs[| 3] = nodeValue("Shift", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0);
	
	inputs[| 4] = nodeValue("Smooth", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	outputs[| 0] = nodeValue("Path", self, JUNCTION_CONNECT.output, VALUE_TYPE.pathnode, self);
	
	input_display_list = [
		["Path",	 true], 0,
		["Wave",	false], 1, 2, 3, 4, 
	]
	
	current_data = [];
	
	static getLineCount = function() { 
		var _path = current_data[0];
		return struct_has(_path, "getLineCount")? _path.getLineCount() : 1; 
	}
	
	static getSegmentCount = function(ind = 0) { 
		var _path = current_data[0];
		return struct_has(_path, "getSegmentCount")? _path.getSegmentCount(ind) : 0; 
	}
	
	static getLength = function(ind = 0) { 
		var _path = current_data[0];
		var _fre  = current_data[1];
		var _amo  = current_data[2];
		
		var _len  = struct_has(_path, "getLength")? _path.getLength(ind) : 0;
		_len *= _fre * sqrt(_amo + 1 / _fre);
		
		return _len; 
	}
	
	static getAccuLength = function(ind = 0) { 
		var _path = current_data[0];
		var _fre  = current_data[1];
		var _amo  = current_data[2];
		
		var _len  = struct_has(_path, "getAccuLength")? _path.getAccuLength(ind) : [];
		var _mul  = _fre * sqrt(_amo + 1 / _fre);
		
		for( var i = 0, n = array_length(_len); i < n; i++ ) 
			_len[i] *= _mul;
		
		return _len; 
	}
		
	static getPointRatio = function(_rat, ind = 0) {
		var _path = current_data[0];
		var _fre  = current_data[1];
		var _amo  = current_data[2];
		var _shf  = current_data[3];
		var _smt  = current_data[4];
		
		if(is_array(_path)) {
			_path = array_safe_get(_path, ind);
			ind = 0;
		}
		
		if(!is_struct(_path) || !struct_has(_path, "getPointRatio"))
			return new __vec2();
		
		var _p0 = _path.getPointRatio(clamp(_rat - 0.001, 0, 0.999999), ind);
		var _p  = _path.getPointRatio(_rat, ind).clone();
		var _p1 = _path.getPointRatio(clamp(_rat + 0.001, 0, 0.999999), ind);
		
		var dir = point_direction(_p0.x, _p0.y, _p1.x, _p1.y) + 90;
		var prg;
		
		if(_smt) prg = cos((_shf + _rat * _fre) * pi * 2);
		else	 prg = (abs(frac(_shf + _rat * _fre) * 2 - 1) - 0.5) * 2;
		
		_p.x = _p.x + lengthdir_x(prg * _amo, dir);
		_p.y = _p.y + lengthdir_y(prg * _amo, dir);
		
		return _p;
	}
	
	static getPointDistance = function(_dist, ind = 0) {
		return getPointRatio(_dist / getLength(), ind);
	}
	
	static getBoundary = function(ind = 0) { 
		var _path = current_data[0];
		return struct_has(_path, "getBoundary")? _path.getBoundary(ind) : new BoundingBox( 0, 0, 1, 1 ); 
	}
	
	static update = function() { 
		for( var i = 0, n = ds_list_size(inputs); i < n; i++ )
			current_data[i] = inputs[| i].getValue();
		
		outputs[| 0].setValue(self);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_path_wave, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}