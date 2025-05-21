function Node_Path_Blend(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name   = "Blend Path";
	setDimension(96, 48);
	length = 0;
	
	newInput(0, nodeValue_PathNode("Path 1"))
		.setVisible(true, true)
		.rejectArray();
	
	newInput(1, nodeValue_PathNode("Path 2"))
		.setVisible(true, true)
		.rejectArray();
	
	newInput(2, nodeValue_Float("Ratio", 0))
		.setDisplay(VALUE_DISPLAY.slider)
		.rejectArray();
	
	newOutput(0, nodeValue_Output("Path", VALUE_TYPE.pathnode, noone));
	
	function _blendedPath() constructor {
		cached_pos = {};
		
		curr_path1 = noone;
		curr_path2 = noone;
		curr_lerp  = noone;
		
		is_path1 = false;
		is_path2 = false;
		
		static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
			
			if(is_path1 && struct_has(curr_path1, "drawOverlay")) curr_path1.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
			if(is_path2 && struct_has(curr_path2, "drawOverlay")) curr_path2.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
			
			draw_set_color(COLORS._main_icon);
			
			var _amo = getLineCount();
			for( var i = 0; i < _amo; i++ ) {
				var _len = getLength(_amo);
				var _stp = 1 / clamp(_len * _s, 1, 64);
				var ox, oy, nx, ny;
				var _p = new __vec2P();
				
				for( var j = 0; j < 1; j += _stp ) {
					_p = getPointRatio(j, i, _p);
					nx = _x + _p.x * _s;
					ny = _y + _p.y * _s;
					
					if(j > 0) draw_line_width(ox, oy, nx, ny, 3);
	
					ox = nx;
					oy = ny;
				}
			}
		}
		
		static getLineCount = function() { return is_path1? curr_path1.getLineCount() : 1; }
		
		static getSegmentCount = function(ind = 0) {
			
			if(!is_path1 && !is_path2) return 0;
			if( is_path1 && !is_path2) return curr_path1.getSegmentCount(ind);
			if(!is_path1 &&  is_path2) return curr_path2.getSegmentCount(ind);
			
			return max(curr_path1.getSegmentCount(ind), curr_path2.getSegmentCount(ind));
		}
		
		static getLength = function(ind = 0) {
			
			if(!is_path1 && !is_path2) return 0;
			if( is_path1 && !is_path2) return curr_path1.getLength(ind);
			if(!is_path1 &&  is_path2) return curr_path2.getLength(ind);
			
			var _p1 = curr_path1.getLength(ind);
			var _p2 = curr_path2.getLength(ind);
			
			return lerp(_p1, _p2, curr_lerp);
		}
		
		static getAccuLength = function(ind = 0) {
			
			if(!is_path1 && !is_path2) return 0;
			if( is_path1 && !is_path2) return curr_path1.getAccuLength(ind);
			if(!is_path1 &&  is_path2) return curr_path2.getAccuLength(ind);
			
			var _p1 = curr_path1.getAccuLength(ind);
			var _p2 = curr_path2.getAccuLength(ind);
			
			var len = max(array_length(_p1), array_length(_p2));
			var res = [];
			
			for( var i = 0; i < len; i++ ) {
				var _l1 = array_get_decimal(_p1, i);
				var _l2 = array_get_decimal(_p2, i);
				res[i] = lerp(_l1, _l2, curr_lerp);
			}
			
			return res;
		}
		
		static getPointRatio = function(_rat, ind = 0, out = undefined) {
			if(out == undefined) out = new __vec2P(); else { out.x = 0; out.y = 0; }
			
			var _cKey = $"{string_format(_rat, 0, 6)},{ind}";
			if(struct_has(cached_pos, _cKey)) {
				var _p = cached_pos[$ _cKey];
				out.x = _p.x;
				out.y = _p.y;
				out.weight = _p.weight;
				return out;
			}
			
			if(!is_path1 && !is_path2) return out;
			if( is_path1 && !is_path2) return curr_path1.getPointRatio(_rat, ind, out);
			if(!is_path1 &&  is_path2) return curr_path2.getPointRatio(_rat, ind, out);
			
			var _p1 = curr_path1.getPointRatio(_rat, ind);
			var _p2 = curr_path2.getPointRatio(_rat, ind);
			
			out.x = lerp(_p1.x, _p2.x, curr_lerp);
			out.y = lerp(_p1.y, _p2.y, curr_lerp);
			out.weight = lerp(_p1.weight, _p2.weight, curr_lerp);
			
			cached_pos[$ _cKey] = new __vec2P(out.x, out.y, out.weight);
			
			return out;
		}
		
		static getPointDistance = function(_dist, ind = 0, out = undefined) { return getPointRatio(_dist / getLength(ind), ind, out); }
		
		static getBoundary = function(ind = 0) {
			
			if(!is_path1 && !is_path2) return new BoundingBox();
			if( is_path1 && !is_path2) return curr_path1.getBoundary(ind);
			if(!is_path1 &&  is_path2) return curr_path2.getBoundary(ind);
			
			var _p1 = curr_path1.getBoundary(ind);
			var _p2 = curr_path2.getBoundary(ind);
			
			return _p1.lerpTo(_p2, curr_lerp);
		}
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _path = getSingleValue(0, preview_index, true);
		if(struct_has(_path, "drawOverlay")) _path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static processData = function(_outData, _data, _array_index = 0) { 
		
		if(!is(_outData, _blendedPath)) 
			_outData = new _blendedPath();
		
		_outData.cached_pos = {};
		_outData.curr_path1 = _data[0];
		_outData.curr_path2 = _data[1];
		_outData.curr_lerp  = _data[2];
		
		_outData.is_path1 = struct_has(_outData.curr_path1, "getPointRatio");
		_outData.is_path2 = struct_has(_outData.curr_path2, "getPointRatio");
		
		return _outData;
		
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_path_blend, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}