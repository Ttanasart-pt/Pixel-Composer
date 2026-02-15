function Node_Path_Smoothen(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Smoothen Path";
	setDimension(96, 48);
	setDrawIcon(s_node_path_smoothen);
	
	////- =Path
	newInput( 0, nodeValue_PathNode( "Path" ));
	newInput( 1, nodeValue_Range(    "Range",       [0,1] ));
	newInput( 2, nodeValue_Bool(     "Clamp Curve", false ));
	
	////- =Smoothen
	newInput( 3, nodeValue_Slider( "Span",  .02, [0,.1,.001] ));
	newInput( 4, nodeValue_Slider( "Blend",   1 ));
	newInput( 5, nodeValue_Int(    "Step",    1 ));
	// input 6
	
	newOutput(0, nodeValue_Output("Path", VALUE_TYPE.pathnode, noone));
	
	input_display_list = [ 
		[ "Path",      true ],  0,  1,  2, 
		[ "Smoothen", false ],  3,  4,  5, 
	];
	
	////- Node
	
	function _smoothenPath(_node) : Path(_node) constructor {
		range = [0,1];
		range_clamp = false;
		
		span  = 0; 
		blend = 0;
		sstep = 1;
		
		cached_pos = {};
		curr_path  = noone;
		
		p  = new __vec2P();
		p0 = new __vec2P();
		p1 = new __vec2P();
		
		static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
			var hovering = false;
			
			if(is_path(curr_path)) {
				var hv = curr_path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params);
				hovering = hovering || hv;
			}
			
			PathDrawOverlay(self, _x, _y, _s);
			
			return hovering;
		}
		
		static getLineCount    = function(   ) /*=>*/ {return is_path(curr_path)? curr_path.getLineCount()     : 1};
		static getSegmentCount = function(i=0) /*=>*/ {return is_path(curr_path)? curr_path.getSegmentCount(i) : 0};
		static getBoundary     = function(i=0) /*=>*/ {return is_path(curr_path)? curr_path.getBoundary(i)     : new BoundingBox( 0, 0, 1, 1 )};
		
		static getLength = function(ind = 0) {
			if(!is_path(curr_path)) return 0;
			return curr_path.getLength(ind);
		}
		
		static getPointRatio = function(_rat, ind = 0, out = undefined) {
			if(out == undefined) out = new __vec2P(); else { out.x = 0; out.y = 0; }
			
			if(!is_path(curr_path)) return out;
			var _cKey = $"{string_format(_rat, 0, 6)},{ind}";
			if(struct_has(cached_pos, _cKey)) {
				var _p = cached_pos[$ _cKey];
				out.x = _p.x;
				out.y = _p.y;
				out.weight = _p.weight;
				return out;
			}
			
			var _path = curr_path;
			
			if(_rat < range[0] || _rat > range[1]) {
				p = _path.getPointRatio(_rat, ind, p);
				out.x = p.x;
				out.y = p.y;
				out.weight = p.weight;
				
				cached_pos[$ _cKey] = new __vec2P(out.x, out.y, out.weight);
				return out;
			}
			
			p  = _path.getPointRatio(_rat, ind, p);
			
			var sx = 0, sy = 0;
			var amp = 1;
			var wei = 0;
			var spn = span;
			
			repeat(sstep) {
				p0  = _path.getPointRatio(frac(frac(_rat - spn) + 1), ind, p0);
				sx += p0.x * amp;
				sy += p0.y * amp;
				
				p0  = _path.getPointRatio(frac(frac(_rat + spn) + 1), ind, p0);
				sx += p0.x * amp;
				sy += p0.y * amp;
				
				wei += amp * 2;
				spn += span;
				amp *= .5;
			}
			
			sx /= wei;
			sy /= wei;

			out.x = lerp(p.x, sx, blend);
			out.y = lerp(p.y, sy, blend);
			out.weight = p.weight;
			
			cached_pos[$ _cKey] = new __vec2P(out.x, out.y, out.weight);
			
			return out;
		}
		
		static getPointDistance = function(_dist, ind = 0, out = undefined) { return getPointRatio(_dist / getLength(), ind, out); }
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		InputDrawOverlay(outputs[0].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params));
		
		return w_hovering;
	}
	
	static processData = function(_outData, _data, _array_index = 0) { 
		if(!is(_outData, _smoothenPath)) 
			_outData = new _smoothenPath(self);
		
		_outData.cached_pos = {};
		_outData.curr_path  = _data[ 0];
		_outData.range      = _data[ 1];
		_outData.range_clamp= _data[ 2];
		
		_outData.span  = _data[ 3];
		_outData.blend = _data[ 4];
		_outData.sstep = _data[ 5];
		
		return _outData;
	}
	
}