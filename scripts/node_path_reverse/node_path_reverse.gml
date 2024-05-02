function Node_Path_Reverse(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Reverse Path";
	setDimension(96, 48);;
	
	inputs[| 0] = nodeValue("Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.pathnode, noone)
		.setVisible(true, true);
	
	outputs[| 0] = nodeValue("Path", self, JUNCTION_CONNECT.output, VALUE_TYPE.pathnode, self);
	
	cached_pos = ds_map_create();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		var _path = getInputData(0);
		if(_path && struct_has(_path, "drawOverlay")) _path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
	} #endregion
	
	static getLineCount = function() { #region
		var _path = getInputData(0);
		return struct_has(_path, "getLineCount")? _path.getLineCount() : 1; 
	} #endregion
	
	static getSegmentCount = function(ind = 0) { #region
		var _path = getInputData(0);
		return struct_has(_path, "getSegmentCount")? _path.getSegmentCount(ind) : 0; 
	} #endregion
	
	static getLength = function(ind = 0) { #region
		var _path = getInputData(0);
		return struct_has(_path, "getLength")? _path.getLength(ind) : 0; 
	} #endregion
		
	static getAccuLength = function(ind = 0) { #region
		var _path = getInputData(0);
		return struct_has(_path, "getAccuLength")? array_reverse(_path.getAccuLength(ind)) : []; 
	} #endregion
	
	static getBoundary = function(ind = 0) { #region
		var _path = getInputData(0);
		return struct_has(_path, "getBoundary")? _path.getBoundary(ind) : new BoundingBox(0, 0, 1, 1); 
	} #endregion
		
	static getPointRatio = function(_rat, ind = 0, out = undefined) { #region
		if(out == undefined) out = new __vec2(); else { out.x = 0; out.y = 0; }
		var _path = getInputData(0);
		
		if(!is_struct(_path) || !struct_has(_path, "getPointRatio"))
			return out;
		return _path.getPointRatio(1 - _rat, ind, out);
	} #endregion
	
	static getPointDistance = function(_dist, ind = 0, out = undefined) { return getPointRatio(_dist / getLength(), ind, out); }
	
	static update = function() { #region
		ds_map_clear(cached_pos);
		outputs[| 0].setValue(self);
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_path_trim, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	} #endregion
}