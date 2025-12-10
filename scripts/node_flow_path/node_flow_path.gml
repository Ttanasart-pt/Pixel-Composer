function Node_Flow_Path(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Flow Path";
	update_on_frame = true;
	
	newActiveInput(5);
	newInput(6, nodeValue_Toggle("Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- =Surfaces
	newInput(0, nodeValue_Surface( "Surface In" ));
	newInput(1, nodeValue_Surface( "Mask"       ));
	newInput(2, nodeValue_Slider(  "Mix", 1     ));
	__init_mask_modifier(1, 3); // inputs 3, 4
	
	////- =Path
	newInput( 7, nodeValue_PathNode( "Path" ));
	newInput(10, nodeValue_Int(      "Sample",       16    ));
	newInput(13, nodeValue_Bool(     "Invert",       false ));
	newInput( 8, nodeValue_Float(    "Radius",       4     ));
	newInput(11, nodeValue_Bool(     "Apply Weight", false ));
	
	////- =Flow
	newInput( 9, nodeValue_Slider(   "Flow Rate",    1     ));
	newInput(12, nodeValue_Int(      "Flow Speed",   1     ));
	
	////- =Flowmap
	newInput(14, nodeValue_Bool(     "Tile",         false ));
	newInput(15, nodeValue_Int(      "Blur",         1     ));
	
	// input 16
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 5, 6, 
		[ "Surface", false ],  0,  1,  2,  3,  4, 
		[ "Path",    false ],  7, 10, 13,  8, 11, 
		[ "Flow",    false ],  9, 12, 
		[ "Flowmap", false ], 14, 15, 
	];
	
	////- Nodes
	
	attribute_interpolation();
	
	temp_surface = [ noone, noone ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		InputDrawOverlay(inputs[7].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny, _params));
		
		return w_hovering;
	}
	
	static draw_circle_tile = function(_tile, _x, _y, _r, _dim) {
		draw_circle_color(_x, _y, _r, c_white, c_black, false);
		if(!_tile) return;
		
		var _sw = _dim[0];
		var _sh = _dim[1];
		
		if(_y - _r < 0) {
			if(_x - _r < 0)   draw_circle_color(_x + _sw, _y + _sh, _r, c_white, c_black, false);
	                          draw_circle_color(_x,       _y + _sh, _r, c_white, c_black, false);
			if(_x + _r > _sw) draw_circle_color(_x - _sw, _y + _sh, _r, c_white, c_black, false);
		}
			
			if(_x - _r < 0)   draw_circle_color(_x + _sw, _y, _r, c_white, c_black, false);
			if(_x + _r > _sw) draw_circle_color(_x - _sw, _y, _r, c_white, c_black, false);
			
		if(_y + _r > _sh) {
			if(_x - _r < 0)   draw_circle_color(_x + _sw, _y - _sh, _r, c_white, c_black, false);
	                          draw_circle_color(_x,       _y - _sh, _r, c_white, c_black, false);
			if(_x + _r > _sw) draw_circle_color(_x - _sw, _y - _sh, _r, c_white, c_black, false);
		}
	}
	
	static draw_quad_tile = function(_tile, _x0, _y0, _x1, _y1, _x2, _y2, _x3, _y3, _dim) {
		draw_triangle_color(_x2, _y2, _x1, _y1, _x3, _y3, c_black, c_white, c_black, false);
		draw_triangle_color(_x0, _y0, _x1, _y1, _x2, _y2, c_white, c_white, c_black, false);
		if(!_tile) return; 
		
		var _sw = _dim[0];
		var _sh = _dim[1];
		
		var _minx = min(_x0, _x1, _x2, _x3);
		var _miny = min(_y0, _y1, _y2, _y3);
		var _maxx = max(_x0, _x1, _x2, _x3);
		var _maxy = max(_y0, _y1, _y2, _y3);
		
		if(_miny < 0) {
			if(_minx < 0) {
				draw_triangle_color(_x2 + _sw, _y2 + _sh, _x1 + _sw, _y1 + _sh, _x3 + _sw, _y3 + _sh, c_black, c_white, c_black, false);
				draw_triangle_color(_x0 + _sw, _y0 + _sh, _x1 + _sw, _y1 + _sh, _x2 + _sw, _y2 + _sh, c_white, c_white, c_black, false);
			}
			
				draw_triangle_color(_x2,       _y2 + _sh, _x1,       _y1 + _sh, _x3,       _y3 + _sh, c_black, c_white, c_black, false);
				draw_triangle_color(_x0,       _y0 + _sh, _x1,       _y1 + _sh, _x2,       _y2 + _sh, c_white, c_white, c_black, false);
		
			if(_maxx > _sw) {
				draw_triangle_color(_x2 - _sw, _y2 + _sh, _x1 - _sw, _y1 + _sh, _x3 - _sw, _y3 + _sh, c_black, c_white, c_black, false);
				draw_triangle_color(_x0 - _sw, _y0 + _sh, _x1 - _sw, _y1 + _sh, _x2 - _sw, _y2 + _sh, c_white, c_white, c_black, false);
			}
		}
			
			if(_minx < 0) {
				draw_triangle_color(_x2 + _sw, _y2, _x1 + _sw, _y1, _x3 + _sw, _y3, c_black, c_white, c_black, false);
				draw_triangle_color(_x0 + _sw, _y0, _x1 + _sw, _y1, _x2 + _sw, _y2, c_white, c_white, c_black, false);
			}
			
			if(_maxx > _sw) {
				draw_triangle_color(_x2 - _sw, _y2, _x1 - _sw, _y1, _x3 - _sw, _y3, c_black, c_white, c_black, false);
				draw_triangle_color(_x0 - _sw, _y0, _x1 - _sw, _y1, _x2 - _sw, _y2, c_white, c_white, c_black, false);
			}
		
		if(_maxy > _sh) {
			if(_minx < 0) {
				draw_triangle_color(_x2 + _sw, _y2 - _sh, _x1 + _sw, _y1 - _sh, _x3 + _sw, _y3 - _sh, c_black, c_white, c_black, false);
				draw_triangle_color(_x0 + _sw, _y0 - _sh, _x1 + _sw, _y1 - _sh, _x2 + _sw, _y2 - _sh, c_white, c_white, c_black, false);
			}
			
				draw_triangle_color(_x2,       _y2 - _sh, _x1,       _y1 - _sh, _x3,       _y3 - _sh, c_black, c_white, c_black, false);
				draw_triangle_color(_x0,       _y0 - _sh, _x1,       _y1 - _sh, _x2,       _y2 - _sh, c_white, c_white, c_black, false);
		
			if(_maxx > _sw) {
				draw_triangle_color(_x2 - _sw, _y2 - _sh, _x1 - _sw, _y1 - _sh, _x3 - _sw, _y3 - _sh, c_black, c_white, c_black, false);
				draw_triangle_color(_x0 - _sw, _y0 - _sh, _x1 - _sw, _y1 - _sh, _x2 - _sw, _y2 - _sh, c_white, c_white, c_black, false);
			}
		}
			
	}
	
	static processData = function(_outSurf, _data, _array_index = 0) {
		var _surf = _data[0];
		var _mask = _data[1];
		var _mix  = _data[2];
		
		var _path = _data[ 7];
		var _psam = _data[10];
		var _pinv = _data[13];
		var _weig = _data[11];
		
		var _rad  = _data[ 8];
		var _rate = _data[ 9];
		var _spd  = _data[12];
		
		var _tile = _data[14];
		var _blur = _data[15];
		
		if(!is_path(_path) || !is_surface(_surf)) return _outSurf; 
		
		var _dim = surface_get_dimension(_surf);
		temp_surface[0] = surface_verify(temp_surface[0], _dim[0], _dim[1], surface_rgba16float);
		temp_surface[1] = surface_verify(temp_surface[1], _dim[0], _dim[1], surface_rgba16float);
		
		draw_set_circle_precision(32);
		
		var _t = 1 / _psam, _prg;
		var _p = new __vec2P();
		
		var ox, oy, ow;
		var nx, ny, nw;
		
		surface_set_shader(temp_surface[0], sh_flow_path_add, true, BLEND.add);
			for( var i = 0; i <= _psam; i++ ) {
				_prg = i * _t;
				if(_pinv) _prg = 1 - _prg;
				_prg = clamp(_prg, 0, .99);
				
				_p = _path.getPointRatio(_prg, 0, _p);
				
				nx = _p.x;
				ny = _p.y;
				nw = _weig? _rad * _p.weight : _rad; 
				
				if(i) {
					
					var _dir = point_direction(ox, oy, nx, ny);
					var _dx  = lengthdir_x(ow, _dir + 90);
					var _dy  = lengthdir_y(ow, _dir + 90);
					
					var ox0 = ox + _dx, oy0 = oy + _dy;
					var ox1 = ox - _dx, oy1 = oy - _dy;
					
					var _dx  = lengthdir_x(nw, _dir - 90);
					var _dy  = lengthdir_y(nw, _dir - 90);
					
					var nx0 = nx + _dx, ny0 = ny + _dy;
					var nx1 = nx - _dx, ny1 = ny - _dy;
					
					shader_set_2("direction", [(nx - ox) / _psam, (ny - oy) / _psam]);
					shader_set_f("flowTime",   CURRENT_FRAME / TOTAL_FRAMES);
					
					draw_quad_tile(_tile, ox, oy, nx, ny, ox0, oy0, nx0, ny0, _dim);
					draw_quad_tile(_tile, ox, oy, nx, ny, ox1, oy1, nx1, ny1, _dim);
					
					draw_circle_tile(_tile, ox, oy, ow, _dim);
					draw_circle_tile(_tile, nx, ny, nw, _dim);
					
				}
	 			
				ox = nx;
				oy = ny;
				ow = nw;
			}
		surface_reset_shader();
		
		var bg = 0;
		
		repeat(_blur) {
			bg = !bg;
			surface_set_shader(temp_surface[bg], sh_flow_path_blur, true, BLEND.over);
				shader_set_2("dimension", _dim);
				shader_set_i("tile",      _tile);
				
				draw_surface(temp_surface[!bg], 0, 0);
			surface_reset_shader();
		}
		
		surface_set_shader(_outSurf, sh_flow_path_apply);
			shader_set_interpolation(_surf);			
			shader_set_surface("flowMask", temp_surface[bg]);
			
			shader_set_2("dimension",   _dim);
			shader_set_f("flowTime",    CURRENT_FRAME / TOTAL_FRAMES);
			shader_set_f("flowRate",    _rate);
			shader_set_f("flowSpeed",   _spd);
			shader_set_f("flowSample",  _psam);
			
			draw_surface(_surf, 0, 0);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _mask, _mix);
		_outSurf = channel_apply(_data[0], _outSurf, _data[6]);
		
		return _outSurf; 
	}
}