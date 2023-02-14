function Node_Path_Wave(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
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
	
	static getPointRatio = function(_rat) {
		var _path = inputs[| 0].getValue();
		var _fre  = inputs[| 1].getValue();
		var _amo  = inputs[| 2].getValue();
		var _shf  = inputs[| 3].getValue();
		var _smt  = inputs[| 4].getValue();
		
		if(!is_struct(_path) || !struct_has(_path, "getPointRatio"))
			return [ 0, 0 ];
		
		var _p0 = _path.getPointRatio(clamp(_rat - 0.001, 0, 0.999999));
		var _p  = _path.getPointRatio(_rat);
		var _p1 = _path.getPointRatio(clamp(_rat + 0.001, 0, 0.999999));
		
		var dir = point_direction(_p0[0], _p0[1], _p1[0], _p1[1]) + 90;
		var prg;
		
		if(_smt) prg = cos((_shf + _rat * _fre) * pi * 2);
		else	 prg = (abs(frac(_shf + _rat * _fre) * 2 - 1) - 0.5) * 2;
		
		_p[0] = _p[0] + lengthdir_x(prg * _amo, dir);
		_p[1] = _p[1] + lengthdir_y(prg * _amo, dir);
		
		return _p;
	}
	
	function update() { 
		outputs[| 0].setValue(self);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_path_wave, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}