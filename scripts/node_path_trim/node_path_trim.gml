function Node_Path_Trim(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Trim Path";
	setDimension(96, 48);
	
	newInput(0, nodeValue_PathNode("Path", self, noone))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Slider_Range("Range", self, [ 0, 1 ]));
	
	newOutput(0, nodeValue_Output("Path", self, VALUE_TYPE.pathnode, noone));
	
	function _trimmedPath() constructor {
		curr_path  = noone;
		curr_range = noone;
		is_path    = false;
		
		static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
			if(curr_path && struct_has(curr_path, "drawOverlay")) 
				curr_path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
			
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
		
		static getLineCount    = function(   ) /*=>*/ {return is_path? curr_path.getLineCount()     : 1};
		static getSegmentCount = function(i=0) /*=>*/ {return is_path? curr_path.getSegmentCount(i) : 0};
		static getLength       = function(i=0) /*=>*/ {return is_path? curr_path.getLength(i)       : 0};
		static getAccuLength   = function(i=0) /*=>*/ {return is_path? curr_path.getAccuLength(i)   : []};
		static getBoundary     = function(i=0) /*=>*/ {return is_path? curr_path.getBoundary(i)     : new BoundingBox( 0, 0, 1, 1 )};
			
		static getPointRatio = function(_rat, ind = 0, out = undefined) {
			if(!is_path) return out;
			
			_rat = lerp(curr_range[0], curr_range[1], _rat);
			return curr_path.getPointRatio(_rat, ind, out);
		}
		
		static getPointDistance = function(_dist, ind = 0, out = undefined) { return getPointRatio(_dist / getLength(), ind, out); }
	}
		
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _path = getSingleValue(0, preview_index, true);
		if(struct_has(_path, "drawOverlay")) _path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static processData = function(_outData, _data, _output_index, _array_index = 0) { 
		
		if(!is(_outData, _trimmedPath)) 
			_outData = new _trimmedPath();
		
		_outData.cached_pos = {};
		_outData.curr_path  = _data[0];
		_outData.curr_range = _data[1];
		_outData.is_path    = struct_has(_outData.curr_path, "getPointRatio");
		
		return _outData;
		
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_path_trim, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}