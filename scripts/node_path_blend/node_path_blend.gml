function Node_Path_Blend(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name   = "Blend Path";
	setDimension(96, 48);
	length = 0;
	
	////- =Paths
	newInput(0, nodeValue_PathNode( "Path 1" ));
	newInput(1, nodeValue_PathNode( "Path 2" ));
	
	////- =Paths
	newInput(3, nodeValue_Enum_Scroll( "Mode",   0, [ "Lerp", "Add", "Subtract", "Multiply" ] ));
	newInput(2, nodeValue_Slider(      "Amount", 0 ));
	//input 4
	
	newOutput(0, nodeValue_Output("Path", VALUE_TYPE.pathnode, noone));
	
	for( var i = 0, n = array_length(inputs); i < n; i++ ) inputs[i].rejectArray();
	
	input_display_list = [
		[ "Paths", false ], 0, 1, 
		[ "Blend", false ], 3, 2, 
	]
	
	function _blendedPath() constructor {
		cached_pos = {};
		
		curr_path1 = noone;
		curr_path2 = noone;
		
		blend_mode  = 0;
		blend_lerp  = 0;
		
		is_path1 = false;
		is_path2 = false;
		
		accu_lengths = [];
		total_length = [];
		
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
					_p = getPointRatio(clamp(j, 0., .99), i, _p);
					nx = _x + _p.x * _s;
					ny = _y + _p.y * _s;
					
					if(j > 0) draw_line_width(ox, oy, nx, ny, 3);
	
					ox = nx;
					oy = ny;
				}
			}
		}
		
		////- Data
		
		static getLineCount = function() { return is_path1? curr_path1.getLineCount() : 1; }
		
		static getSegmentCount = function(ind = 0) {
			
			if(!is_path1 && !is_path2) return 0;
			if( is_path1 && !is_path2) return curr_path1.getSegmentCount(ind);
			if(!is_path1 &&  is_path2) return curr_path2.getSegmentCount(ind);
			
			return max(curr_path1.getSegmentCount(ind), curr_path2.getSegmentCount(ind));
		}
		
		static getLength     = function(i=0) /*=>*/ {return array_safe_get(total_length, i, 0)};
		static getAccuLength = function(i=0) /*=>*/ {return array_safe_get(accu_lengths, i, [])};
		
		static setLength = function() {
			if(!is_path1 || !is_path2) return;
			var _amo = getLineCount();
			
			accu_lengths = array_create(_amo);
			total_length = array_create(_amo);
			
			for( var i = 0; i < _amo; i++ ) {
				var _p1_acc = curr_path1.getAccuLength(i);
				var _p2_acc = curr_path2.getAccuLength(i);
				
				var len = max(array_length(_p1_acc), array_length(_p2_acc));
				var res = [];
				
				for( var j = 0; j < len; j++ ) {
					var _l1 = array_get_decimal(_p1_acc, j);
					var _l2 = array_get_decimal(_p2_acc, j);
					
					switch(blend_mode) {
						case 0 : res[j] = lerp(_l1, _l2, blend_lerp); break;
						case 1 : 
						case 2 : 
						case 3 : res[j] = max(_l1, _l2); break;
					}
				}	
				
				accu_lengths[i] = res;
				
				var _p1_len = curr_path1.getLength(i);
				var _p2_len = curr_path2.getLength(i);
				
				switch(blend_mode) {
					case 0 : total_length[i] = lerp(_p1_len, _p2_len, blend_lerp); break;
					case 1 : 
					case 2 : 
					case 3 : total_length[i] = _p1_len + _p2_len; break;
				}
			}
		}
		
		////- Get
		
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
			
			switch(blend_mode) {
				case 0 :
					out.x = lerp(_p1.x, _p2.x, blend_lerp);
					out.y = lerp(_p1.y, _p2.y, blend_lerp);
					out.weight = lerp(_p1.weight, _p2.weight, blend_lerp);
					break;
				
				case 1 :
					out.x = _p1.x + _p2.x * blend_lerp;
					out.y = _p1.y + _p2.y * blend_lerp;
					out.weight = _p1.weight + _p2.weight * blend_lerp;
					break;
				
				case 2 :
					out.x = _p1.x - _p2.x * blend_lerp;
					out.y = _p1.y - _p2.y * blend_lerp;
					out.weight = _p1.weight - _p2.weight * blend_lerp;
					break;
					
				case 3 :
					var _p10 = curr_path1.getPointRatio(clamp(_rat - .01, 0, .999), ind);
					var _p11 = curr_path1.getPointRatio(clamp(_rat + .01, 0, .999), ind);
					var _dir = point_direction(_p10.x, _p10.y, _p11.x, _p11.y);
					var _dis = _p2.y * blend_lerp;
					
					out.x = _p1.x + lengthdir_x(_dis, _dir + 90);
					out.y = _p1.y + lengthdir_y(_dis, _dir + 90);
					
					out.weight = lerp(_p1.weight, _p2.weight, blend_lerp);
					break;
					
			}
			
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
			
			return _p1.lerpTo(_p2, blend_lerp);
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
		
		_outData.blend_mode  = _data[3];
		_outData.blend_lerp  = _data[2];
		
		_outData.is_path1 = is_path(_outData.curr_path1, "getPointRatio");
		_outData.is_path2 = is_path(_outData.curr_path2, "getPointRatio");
		
		_outData.setLength();
		
		return _outData;
		
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_path_blend, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}