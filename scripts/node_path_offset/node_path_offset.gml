function Node_Path_Offset(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Offset Path";
	setDimension(96, 48);
	
	newInput(0, nodeValue_PathNode( "Path" )).setVisible(true, true);
	newInput(1, nodeValue_Slider(   "Offset", 0, [-1, 1, 0.01] ));
	newInput(2, nodeValue_Bool(     "Clamp",  false));
	
	newOutput(0, nodeValue_Output("Path", VALUE_TYPE.pathnode, noone));
	
	function _offsetedPath() constructor {
		curr_path  = noone;
		offset     = 0;
		clampRat   = false;
		
		static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
			if(curr_path && struct_has(curr_path, "drawOverlay")) 
				curr_path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
		}
		
		static getLineCount    = function(   ) /*=>*/ {return is_path(curr_path)? curr_path.getLineCount()                  : 1};
		static getSegmentCount = function(i=0) /*=>*/ {return is_path(curr_path)? curr_path.getSegmentCount(i)              : 0};
		static getLength       = function(i=0) /*=>*/ {return is_path(curr_path)? curr_path.getLength(i)                    : 0};
		static getAccuLength   = function(i=0) /*=>*/ {return is_path(curr_path)? array_reverse(curr_path.getAccuLength(i)) : []};
		static getBoundary     = function(i=0) /*=>*/ {return is_path(curr_path)? curr_path.getBoundary(i)                  : new BoundingBox(0, 0, 1, 1)};
		
		static getPointRatio = function(_rat, ind = 0, out = undefined) {
			if(out == undefined) out = new __vec2P(); else { out.x = 0; out.y = 0; }
			if(!is_path(curr_path)) return out;
			
			var _o = is_array(offset)? array_safe_get_fast(offset, ind, 0) : offset;
			
			var _s = _rat + _o;
			    _s = clampRat? clamp(_s, 0, 1) : frac(frac(_s) + 1);
			    
			return curr_path.getPointRatio(_s, ind, out);
		}
		
		static getPointDistance = function(_dist, ind = 0, out = undefined) { return getPointRatio(_dist / getLength(), ind, out); }
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _path = getSingleValue(0, preview_index, true);
		if(struct_has(_path, "drawOverlay")) _path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static processData = function(_outData, _data, _array_index = 0) { 
		
		if(!is(_outData, _offsetedPath)) 
			_outData = new _offsetedPath();
		
		_outData.curr_path = _data[0];
		_outData.offset    = _data[1];
		_outData.clampRat  = _data[2];
		
		// _outData.offset = array_create_ext(10, (i) => random_range(-1,1));
		
		return _outData;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_path_offset, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}