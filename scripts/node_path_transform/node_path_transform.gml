function Node_Path_Transform(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Transform Path";
	setDimension(96, 48);
	
	inputs[0] = nodeValue_PathNode("Path", self, noone)
		.setVisible(true, true);
	
	newInput(1, nodeValue_Vec2("Position", self, [ 0, 0 ]));
	
	newInput(2, nodeValue_Rotation("Rotation", self, 0));
	
	newInput(3, nodeValue_Vec2("Scale", self, [ 1, 1 ]));
	
	newInput(4, nodeValue_Vec2("Anchor", self, [ 0, 0 ]));
		
	outputs[0] = nodeValue_Output("Path", self, VALUE_TYPE.pathnode, self);
	
	cached_pos = ds_map_create();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var pth = getInputData(0);
		var pos = getInputData(4);
		var px  = _x + pos[0] * _s;
		var py  = _y + pos[1] * _s;
		
		// if(pth) pth.drawOverlay(-1, false, _x, _y, _s, _mx, _my, _snx, _sny);
		
		active &= !inputs[1].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
		active &= !inputs[2].drawOverlay(hover, active, px, py, _s, _mx, _my, _snx, _sny);
		
		inputs[4].overlay_draw_text = false;
		active &= !inputs[4].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, 1);
	}
	
	static getLineCount 	= function()        { var _path = getInputData(0); return struct_has(_path, "getLineCount")?	_path.getLineCount()		: 1;  }
	static getSegmentCount	= function(ind = 0) { var _path = getInputData(0); return struct_has(_path, "getSegmentCount")? _path.getSegmentCount(ind)	: 0;  }
	static getLength		= function(ind = 0) { var _path = getInputData(0); return struct_has(_path, "getLength")?		_path.getLength(ind)		: 0;  }
	static getAccuLength	= function(ind = 0) { var _path = getInputData(0); return struct_has(_path, "getAccuLength")?	_path.getAccuLength(ind)	: []; }
	
	static getBoundary = function(ind = 0) {
		var _path = getInputData(0);
		if(!struct_has(_path, "getBoundary"))
			return new BoundingBox( 0, 0, 1, 1 );
			
		var b = _path.getBoundary(ind).clone();
		
		var _pos  = getInputData(1);
		var _rot  = getInputData(2);
		var _sca  = getInputData(3);
		var _anc  = getInputData(4);
		
		b.minx	= _anc[0] + (b.minx - _anc[0]) * _sca[0]; 
		b.miny	= _anc[1] + (b.miny - _anc[1]) * _sca[1];
		var _pp = point_rotate(b.minx, b.miny, _anc[0], _anc[1], _rot);
		b.minx	= _pp[0] + _pos[0]; 
		b.miny	= _pp[1] + _pos[1];
		
		b.maxx	= _anc[0] + (b.maxx - _anc[0]) * _sca[0]; 
		b.maxy	= _anc[1] + (b.maxy - _anc[1]) * _sca[1];
		var _pp = point_rotate(b.maxx, b.maxy, _anc[0], _anc[1], _rot);
		b.maxx	= _pp[0] + _pos[0]; 
		b.maxy	= _pp[1] + _pos[1];
		
		var _minx = min(b.minx, b.maxx);
		var _maxx = max(b.minx, b.maxx);
		var _miny = min(b.miny, b.maxy);
		var _maxy = max(b.miny, b.maxy);
		
		return new BoundingBox(_minx, _miny, _maxx, _maxy);
	}
	
	static getPointRatio = function(_rat, ind = 0, out = undefined) {
		if(out == undefined) out = new __vec2(); else { out.x = 0; out.y = 0; }
		
		var _cKey = $"{_rat},{ind}";
		if(ds_map_exists(cached_pos, _cKey)) {
			var _p = cached_pos[? _cKey];
			out.x = _p.x;
			out.y = _p.y;
			return out;
		}
		
		var _path = getInputData(0);
		var _pos  = getInputData(1);
		var _rot  = getInputData(2);
		var _sca  = getInputData(3);
		var _anc  = getInputData(4);
		
		if(is_array(_path)) {
			_path = array_safe_get_fast(_path, ind);
			ind = 0;
		}
		
		if(!is_struct(_path) || !struct_has(_path, "getPointRatio"))
			return out;
		
		var _p = _path.getPointRatio(_rat, ind).clone();
		
		_p.x = _anc[0] + (_p.x - _anc[0]) * _sca[0];
		_p.y = _anc[1] + (_p.y - _anc[1]) * _sca[1];
		
		var _pp = point_rotate(_p.x, _p.y, _anc[0], _anc[1], _rot);
		
		out.x = _pp[0] + _pos[0];
		out.y = _pp[1] + _pos[1];
		
		cached_pos[? _cKey] = out.clone();
		
		return out;
	}
	
	static getPointDistance = function(_dist, ind = 0, out = undefined) { return getPointRatio(_dist / getLength(), ind, out); }
	
	static getBoundary = function(ind = 0) {
		var _path = getInputData(0);
		var _pos  = getInputData(1);
		var _rot  = getInputData(2);
		var _sca  = getInputData(3);
		
		if(_path == noone) return [ 0, 0, 1, 1 ];
		
		var _b = _path.getBoundary(ind);
		
		var cx = (_b[0] + _b[2]) / 2;
		var cy = (_b[1] + _b[1]) / 2;
		
		_b[0] = cx + (_b[0] - cx) * _sca[0];
		_b[1] = cy + (_b[1] - cy) * _sca[1];
		_b[2] = cx + (_b[2] - cx) * _sca[0];
		_b[3] = cy + (_b[3] - cy) * _sca[1];
	}
	
	static update = function() {
		ds_map_clear(cached_pos);
		outputs[0].setValue(self);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_path_transform, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}