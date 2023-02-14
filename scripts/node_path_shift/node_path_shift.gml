function Node_Path_Shift(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name		= "Shift Path";
	previewable = false;
	
	w = 96;
	
	inputs[| 0] = nodeValue("Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.pathnode, noone)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Distance", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0);
	
	outputs[| 0] = nodeValue("Path", self, JUNCTION_CONNECT.output, VALUE_TYPE.pathnode, self);
	
	static getPointRatio = function(_rat) {
		var _path = inputs[| 0].getValue();
		var _shf  = inputs[| 1].getValue();
		
		if(!is_struct(_path) || !struct_has(_path, "getPointRatio"))
			return [ 0, 0 ];
		
		var _p0 = _path.getPointRatio(clamp(_rat - 0.001, 0, 0.999999));
		var _p  = _path.getPointRatio(_rat);
		var _p1 = _path.getPointRatio(clamp(_rat + 0.001, 0, 0.999999));
		
		var dir = point_direction(_p0[0], _p0[1], _p1[0], _p1[1]) + 90;
		
		_p[0] = _p[0] + lengthdir_x(_shf, dir);
		_p[1] = _p[1] + lengthdir_y(_shf, dir);
		
		return _p;
	}
	
	function update() { 
		outputs[| 0].setValue(self);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(THEME.node_draw_path, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}