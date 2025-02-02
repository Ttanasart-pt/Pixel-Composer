function Node_Path_Transform(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Transform Path";
	setDimension(96, 48);
	
	newInput(0, nodeValue_PathNode("Path", self, noone))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Vec2("Position", self, [ 0, 0 ]))
		.setUnitRef(function() /*=>*/ {return DEF_SURF}, VALUE_UNIT.reference);
	
	newInput(2, nodeValue_Rotation("Rotation", self, 0));
	
	newInput(3, nodeValue_Vec2("Scale", self, [ 1, 1 ]));
	
	newInput(4, nodeValue_Vec2("Anchor", self, [ 0, 0 ]))
		.setUnitRef(function() /*=>*/ {return DEF_SURF}, VALUE_UNIT.reference);
	
	newOutput(0, nodeValue_Output("Path", self, VALUE_TYPE.pathnode, noone));
	
	function _transformedPath() constructor {
		path       = noone;
		cached_pos = {};
		
		pos  = [ 0, 0 ];
		rot  = 0;
		sca  = [ 1, 1 ];
		anc  = [ 0, 0 ];
		p    = new __vec2P();
		
		static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
			if(struct_has(path, "drawOverlay")) 
				path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
			
			draw_set_color(COLORS._main_icon);
			var _amo = getLineCount();
			for( var i = 0; i < _amo; i++ ) {
				var _len = getLength(i);
				var _stp = 1 / clamp(_len * _s, 1, 64);
				
				var ox, oy, nx, ny;
				
				for( var j = 0; j < 1; j += _stp ) {
					p = getPointRatio(j, i, p);
					nx = _x + p.x * _s;
					ny = _y + p.y * _s;
					
					if(j > 0) draw_line_width(ox, oy, nx, ny, 1);
					
					ox = nx;
					oy = ny;
				}
			}
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
			
			if(!is_struct(path) || !struct_has(path, "getPointRatio"))
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
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _path = getSingleValue(0, preview_index, true);
		if(struct_has(_path, "drawOverlay")) _path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
		
		var _pos = getSingleValue(1);
		var px  = _x + _pos[0] * _s;
		var py  = _y + _pos[1] * _s;
		
		active &= !inputs[1].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
		active &= !inputs[2].drawOverlay(hover, active, px, py, _s, _mx, _my, _snx, _sny);
		
		inputs[4].overlay_draw_text = false;
		active &= !inputs[4].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, 1);
	}
	
	static processData = function(_outData, _data, _output_index, _array_index = 0) { 
		var _path = _data[0];
		
		if(!is(_outData, _transformedPath)) 
			_outData = new _transformedPath();
		
		_outData.cached_pos = {};
		_outData.path = _path;
		_outData.pos  = _data[1];
		_outData.rot  = _data[2];
		_outData.sca  = _data[3];
		_outData.anc  = _data[4];
		
		return _outData
		
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_path_transform, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}