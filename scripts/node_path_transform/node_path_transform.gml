function Node_Path_Transform(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Transform Path";
	setDimension(96, 48);
	dimension_index = -1;
	setDrawIcon(s_node_path_transform);
	
	newInput(0, nodeValue_PathNode( "Path" ));
	
	newInput(1, nodeValue_Vec2(     "Position", [0,0] )).setHotkey("G").setUnitSimple();
	newInput(2, nodeValue_Rotation( "Rotation",  0    )).setHotkey("R");
	newInput(3, nodeValue_Vec2(     "Scale",    [1,1] ));
	newInput(4, nodeValue_Vec2(     "Anchor",   [0,0] )).setUnitSimple();
	//input 5
	
	newOutput(0, nodeValue_Output("Path", VALUE_TYPE.pathnode, noone));
	
	b_center = button(function() /*=>*/ {return setCenter()}).setIcon(THEME.icon_center_canvas, 0, COLORS._main_icon, .5).setText("Center");
	
	input_display_list = [ 0, 
		[ "Transform", false ], 1, 2, 3, 4, b_center, 
	]
	
	function _transformedPath(_node) : Path(_node) constructor {
		path       = noone;
		cached_pos = {};
		
		pos  = [ 0, 0 ];
		rot  = 0;
		sca  = [ 1, 1 ];
		anc  = [ 0, 0 ];
		p    = new __vec2P();
		
		static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
			var hovering = false;
			
			if(struct_has(path, "drawOverlay")) {
				var hv = path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params);
				hovering = hovering || hv;
			}
			
			PathDrawOverlay(self, _x, _y, _s);
			
			return hovering;
		}
		
		static getLineCount 	= function()    /*=>*/ { return struct_has(path, "getLineCount")?      path.getLineCount()     : 1;  }
		static getSegmentCount	= function(i=0) /*=>*/ { return struct_has(path, "getSegmentCount")?   path.getSegmentCount(i) : 0;  }
		static getLength		= function(i=0) /*=>*/ { return struct_has(path, "getLength")?		   path.getLength(i)       : 0;  }
		static getAccuLength	= function(i=0) /*=>*/ { return struct_has(path, "getAccuLength")?	   path.getAccuLength(i)   : []; }
		
		static getBoundary = function(ind = 0) {
			if(!struct_has(path, "getBoundary"))
				return new BoundingBox( 0, 0, 1, 1 );
				
			var b = path.getBoundary(ind).clone();
			
			b.minx	= _anc[0] + (b.minx - _anc[0]) * sca[0]; 
			b.miny	= _anc[1] + (b.miny - _anc[1]) * sca[1];
			var _pp = point_rotate(b.minx, b.miny, _anc[0], _anc[1], rot);
			b.minx	= _pp[0] + pos[0]; 
			b.miny	= _pp[1] + pos[1];
			
			b.maxx	= _anc[0] + (b.maxx - _anc[0]) * sca[0]; 
			b.maxy	= _anc[1] + (b.maxy - _anc[1]) * sca[1];
			var _pp = point_rotate(b.maxx, b.maxy, _anc[0], _anc[1], rot);
			b.maxx	= _pp[0] + pos[0]; 
			b.maxy	= _pp[1] + pos[1];
			
			var _minx = min(b.minx, b.maxx);
			var _maxx = max(b.minx, b.maxx);
			var _miny = min(b.miny, b.maxy);
			var _maxy = max(b.miny, b.maxy);
			
			return new BoundingBox(_minx, _miny, _maxx, _maxy);
		}
		
		static getPointRatio = function(_rat, ind = 0, out = undefined) {
			out ??= new __vec2P();
			
			var _cKey = $"{string_format(_rat, 0, 6)},{ind}";
			if(struct_has(cached_pos, _cKey)) {
				var _p = cached_pos[$ _cKey];
				out.x = _p.x;
				out.y = _p.y;
				out.weight = _p.weight;
				return out;
			}
			
			if(is_array(path)) {
				path = array_safe_get_fast(path, ind);
				ind  = 0;
			}
			
			if(!is_struct(path) || !is_path(path))
				return out;
			
			var _p = path.getPointRatio(_rat, ind);
			
			_p.x = anc[0] + (_p.x - anc[0]) * sca[0];
			_p.y = anc[1] + (_p.y - anc[1]) * sca[1];
			
			var _pp = point_rotate(_p.x, _p.y, anc[0], anc[1], rot);
			
			out.x = _pp[0] + pos[0];
			out.y = _pp[1] + pos[1];
			out.weight = _p.weight;
			
			cached_pos[$ _cKey] = new __vec2P(out.x, out.y, out.weight);
			return out;
		}
		
		static getPointDistance = function(_dist, ind = 0, out = undefined) { return getPointRatio(_dist / getLength(), ind, out); }
		
	}
	
	static setCenter = function() /*=>*/ {
		var _path = getInputSingle(0);
		if(!is_path(_path)) return;
		
		var _bbox = _path.getBoundary();
		if(!is(_bbox, BoundingBox)) return;
		
		var _cx = (_bbox.minx + _bbox.maxx) / 2;
		var _cy = (_bbox.miny + _bbox.maxy) / 2;
		
		inputs[4].setValue([_cx, _cy]);
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		InputDrawOverlay(outputs[0].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params));
		
		var _ori = getInputSingle(4);
		var ox = _x + _ori[0] * _s;
		var oy = _y + _ori[1] * _s;
		
		var _pos = getInputSingle(1);
		var  px  = ox + _pos[0] * _s;
		var  py  = oy + _pos[1] * _s;
		
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, ox, oy, _s, _mx, _my, _snx, _sny));
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my, _snx, _sny));
		
		inputs[4].overlay_draw_text = false;
		InputDrawOverlay(inputs[4].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny, 1));
		return w_hovering;
	}
	
	static processData = function(_outData, _data, _array_index = 0) { 
		var _path = _data[0];
		
		if(!is(_outData, _transformedPath)) 
			_outData = new _transformedPath(self);
		
		_outData.cached_pos = {};
		_outData.path = _path;
		_outData.pos  = _data[1];
		_outData.rot  = _data[2];
		_outData.sca  = _data[3];
		_outData.anc  = _data[4];
		
		return _outData
		
	}
}