function Node_Path_Flattern(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Path Flatten";
	setDimension(96, 48);
	setDrawIcon();
	
	newInput(0, nodeValue_Path( "Path" ));
	newInput(1, nodeValue_Bool(     "Reverse",   false ));
	newInput(2, nodeValue_Bool(     "Ping Pong", false ));
	
	newOutput(0, nodeValue_Output(  "Path", VALUE_TYPE.pathnode, noone));
	
	input_display_list = [  
		[ "Flatten", false ],  1,  2, 
		[ "Paths",   false ],  0, 
	];
	
	function createNewInput(index = array_length(inputs)) {
		newInput(index, nodeValue_Path( "Path" )).setVisible(true, true);
		array_push(input_display_list, index);
		return inputs[index];
	} setDynamicInput(1);
	
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
			
			lengthPath  = [];
			
			var _lines  = 0;
			
			for( var i = 0, n = array_length(curr_path); i < n; i++ ) {
				var _pth = curr_path[i];
				var lamo = _pth.getLineCount();
				_lines += lamo;
				
				for( var j = 0; j < lamo; j++ ) {
					var _len = _pth.getLength();
					
					array_push(lengths,    _len);
					array_push(lengthPath, _pth);
					
					lengthTotal += _len;
					array_push(lengthAccs, lengthTotal);
					
					segments += _pth.getSegmentCount();
				}
			}
			
		#endregion
		
		static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
			var hovering = false;
			
			for( var i = 0, n = array_length(curr_path); i < n; i++ ) {
				var _path = curr_path[i];
				if(has(_path, "drawOverlay")) {
					var hv = _path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _params);
					hovering = hovering || hv;
				}
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
					
					var _pth = lengthPath[i];
					_pth.getPointDistance(_dst, i, out);
					_res = true;
					break;
				}
				
				_dst -= _l;
				if(pingpong) _rev  = !_rev;
			}
			
			if(!_res) array_last(curr_path).getPointDistance(getLength(), 0, out);
			cached_pos[$ _cKey] = new __vec2P(out.x, out.y, out.weight);
			
			return out;
		}
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		drawOverlayInput(outputs[0].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _params));
		return w_hovering;
	}
	
	static update = function(frame = CURRENT_FRAME) {
		#region data
			var path = getInputData(0); 
			if(!is_path(path)) return;
			
		#endregion
		
		var _paths = [ path ];
		for( var i = input_fix_len; i < array_length(inputs); i++ ) {
			var pth = getInputData(i); 
			if(is_path(pth)) array_push(_paths, pth);
		}
		
		var flat = new _flatternPath(_paths, self);
		flat.reverse  = getInputData(1); 
		flat.pingpong = getInputData(2); 
		
		outputs[0].setValue(flat);
	}
}
