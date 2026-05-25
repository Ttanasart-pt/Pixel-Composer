function Node_Path_Remap(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Path UV Remap";
	setDimension(96, 48);
	setDrawIcon();
	
	newInput( 0, nodeValue_PathNode( "Path" ));
	
	////- =Mapping
	newInput( 1, nodeValue_Surface( "UV Map"    ));
	newInput( 2, nodeValue_Slider(  "Amount", 1 ));
	// input 8
	
	newOutput(0, nodeValue_Output("Path", VALUE_TYPE.pathnode, self));
	
	input_display_list = [ 0, 
		[ "Mapping", false ], 1, 2, 
	];
	
	////- Node
	
	cached_pos = ds_map_create();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) {  
		var _toType = getInputSingle(4);
		
		switch(_toType) {
			case 0 : InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my)); break;
			
			case 1 : 
				var _tdim = getInputSingle(5);
				draw_set_color(COLORS._main_accent);
				draw_rectangle(
					_x + 0 * _s,
					_y + 0 * _s,
					_x + _tdim[0] * _s,
					_y + _tdim[1] * _s,
					true
				);
				break;
			
			case 2 : 
				var _tbox = getInputSingle(7);
				draw_set_color(COLORS._main_accent);
				draw_rectangle(
					_x + _tbox[0] * _s,
					_y + _tbox[1] * _s,
					_x + _tbox[2] * _s,
					_y + _tbox[3] * _s,
					true
				);
				break;
				
		}
		
		PathDrawOverlay(outputs[0].getValue(), _x, _y, _s);
		InputDrawOverlay(inputs[0].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _params));
		
		return w_hovering;
	}
	
	function _uvMappedPath(_node) : Path(_node) constructor {
		path      = noone;
		uvSampler = new Surface_sampler();
		mapAmount = 1;
		
		uvWidth  = 1;
		uvHeight = 1;
		
		static getLineCount    = function(   ) /*=>*/ {return path.getLineCount()};
		static getSegmentCount = function(i=0) /*=>*/ {return path.getSegmentCount(i)};
		static getLength       = function(   ) /*=>*/ {return path.getLength()};
		static getAccuLength   = function(i=0) /*=>*/ {return path.getAccuLength(i)};
		static getBoundary     = function(i=0) /*=>*/ {return path.getBoundary(i)};
		
		static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
			var hovering = false;
			if(has(path, "drawOverlay")) {
				var hv = path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _params);
				hovering = hovering || hv;
			}
			
			return hovering;
		}
		
		static getPointRatio = function(_rat, ind = 0, out = undefined) {
			if(out == undefined) out = new __vec2P(); else { out.x = 0; out.y = 0; }
			
			var _p = path.getPointRatio(_rat, ind);
			var _val = uvSampler.getPixel(_p.x, _p.y);
			var vx, vy;
			
			if(is_array(_val)) {
				vx = _val[0] * uvWidth;
				vy = _val[1] * uvHeight;
				
			} else {
				vx = _color_get_r(_val) * uvWidth;
				vy = _color_get_g(_val) * uvHeight;
				
			}
			
			out.x = lerp(_p.x, vx, mapAmount);
			out.y = lerp(_p.y, vy, mapAmount);
			
			return out;
		}
		
		static getPointDistance = function(_dist, ind = 0, out = undefined) { return getPointRatio(_dist / getLength(), ind, out); }
		
	}
	
	static processData = function(_outData, _data, _array_index = 0) { 
		#region data
			var _path  = _data[0];
			
			var _uvmap = _data[1];
			var _uvamo = _data[2];
			
			if(!is_surface(_uvmap)) return;
			if(!is_path(_path)) return _outData;
		#endregion
		
		if(!is(_outData, _uvMappedPath)) 
			_outData = new _uvMappedPath();
		
		_outData.path = _path;
		_outData.uvSampler.setSurface(_uvmap);
		_outData.mapAmount = _uvamo;
		
		_outData.uvWidth  = surface_get_width(_uvmap);
		_outData.uvHeight = surface_get_height(_uvmap);
		
		return _outData;
	}
}