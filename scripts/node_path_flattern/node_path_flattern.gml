function Node_Path_Flattern(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Path Flatten";
	setDimension(96, 48);
	
	newInput(0, nodeValue_PathNode( "Path" ));
	newInput(1, nodeValue_Bool(     "Reverse",   false ));
	newInput(2, nodeValue_Bool(     "Ping Pong", false ));
	
	newOutput(0, nodeValue_Output(  "Path", VALUE_TYPE.pathnode, noone));
	
	input_display_list = [ 0, 1, 2 ];
	
	////- Nodes
	
	function _flatternPath(_path, _node) : Path(_node) constructor {
		curr_path  = _path;
		reverse    = 0;
		pingpong   = 0;
		cached_pos = {};
		
		#region path
			segments    = 0;
			lengths     = [];
			lengthAccs  = [];
			lengthTotal = 0;
			boundary    = new BoundingBox();
			
			var _lines  = curr_path.getLineCount();
			
			for( var i = 0; i < _lines; i++ ) {
				var _len = curr_path.getLength();
				
				lengths[i]    = _len;
				lengthTotal  += _len;
				lengthAccs[i] = lengthTotal;
				segments     += curr_path.getSegmentCount();
			}
			
		#endregion
		
		static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
			var hovering = false;
			
			if(has(curr_path, "drawOverlay")) {
				var hv = curr_path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params);
				hovering = hovering || hv;
			}
			
			return hovering;
		}
		
		static getLineCount    = function(   ) /*=>*/ {return 1};
		static getSegmentCount = function(i=0) /*=>*/ {return segments};
		static getLength       = function(   ) /*=>*/ {return lengthTotal};
		static getAccuLength   = function(i=0) /*=>*/ {return lengthAccs};
		static getBoundary     = function(i=0) /*=>*/ {return boundary};
		
		static getPointRatio = function(_rat, ind = 0, out = undefined) { return getPointDistance(_rat * getLength(), ind, out); }
		
		static getPointDistance = function(_dist, ind = 0, out = undefined) { 
			if(out == undefined) out = new __vec2P(); else { out.x = 0; out.y = 0; }
			if(!is_path(curr_path)) return out;
			
			var _cKey  = _dist;
			if(struct_has(cached_pos, _cKey)) {
				var _cachep = cached_pos[$ _cKey];
				out.x = _cachep.x;
				out.y = _cachep.y;
				out.weight = _cachep.weight;
				return out;
			}
			
			var _dst = _dist;
			var _rev = reverse;
			var _res = false;
			
			for( var i = 0, n = array_length(lengths); i < n; i++ ) {
				var _l = lengths[i];
				if(_l >= _dst) {
					if(_rev) _dst = _l - _dst;
					
					curr_path.getPointDistance(_dst, i, out);
					_res = true;
					break;
				}
				
				_dst -= _l;
				if(pingpong) _rev  = !_rev;
			}
			
			if(!_res) curr_path.getPointDistance(getLength(), 0, out);
			cached_pos[$ _cKey] = new __vec2P(out.x, out.y, out.weight);
			
			return out;
		}
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		InputDrawOverlay(outputs[0].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params));
		return w_hovering;
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var path = getInputData(0); 
		if(!is_path(path)) return;
		
		var flat = new _flatternPath(path, self);
		flat.reverse  = getInputData(1); 
		flat.pingpong = getInputData(2); 
		
		outputs[0].setValue(flat);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		draw_sprite_fit(s_node_path_flattern, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}
