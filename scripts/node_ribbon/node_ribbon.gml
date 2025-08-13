function Node_Ribbon(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Draw Ribbon";
	dimension_index = 1;
	
	newInput(0, nodeValueSeed());
	
	////- =Output
	newInput(1, nodeValue_Dimension());
	
	////- =Path
	newInput( 2, nodeValue_PathNode( "Path"          ));
	newInput(11, nodeValue_Bool(     "Loop",   false ));
	newInput( 3, nodeValue_Int(      "Sample", 64    ));
	newInput(10, nodeValue_Bool(     "Invert", false ));
	
	////- =Ribbon
	newInput(4, nodeValue_Float(    "Size",      8 )).setHotkey("S");
	newInput(8, nodeValue_Curve(    "Size Over Length",  CURVE_DEF_11 ));
	newInput(5, nodeValue_Rotation( "Direction", 90 ));
	
	////- =Render
	newInput( 6, nodeValue_Gradient( "Color over Length", new gradientObject(ca_white) ));
	newInput( 7, nodeValue_Gradient( "Color Weight",      new gradientObject(ca_white) ));
	newInput(12, nodeValue_Surface(  "Texture",           noone ));
	newInput( 9, nodeValue_Bool(     "Shade Side",        false ));
	// input 13
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0, 
		["Output", false], 1, 
		["Path",   false], 2, 11, 3, 10, 
		["Ribbon", false], 4, 8, 5, 
		["Render", false], 6, 7, 12, 9, 
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		InputDrawOverlay(inputs[2].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params));
		
		var _dim = getDimension();
		var _cx = _x + _dim[0] / 2 * _s;
		var _cy = _y + _dim[1] / 2 * _s;
		
		InputDrawOverlay(inputs[4].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my, _snx, _sny));
		
	}
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
			var _seed    = _data[0];
			var _dim     = _data[1];
			
			var _path    = _data[ 2];
			var _loop    = _data[11];
			var _samp    = _data[ 3]; _samp = max(2, _samp);
			var _invp    = _data[10];
			
			var _size    = _data[4];
			var _sizeLen = _data[8]; var _sizeLenMap = new curveMap(_sizeLen, 128);
			var _dirc    = _data[5];
			
			var _colLen  = _data[ 6];
			var _colWei  = _data[ 7];
			var _texture = _data[12];
			var _shdSid  = _data[ 9];
		#endregion
		
		if(!is_path(_path)) return _outSurf;
		
		var ox, oy, oc, ow, ot, odx, ody; 
		var nx, ny, nc, nw, nt, ndx, ndy;
		var prg;
		
		var t = 1 / (_samp - 1);
		var p = new __vec2P();
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			
			draw_primitive_begin_texture(pr_trianglelist, surface_get_texture_safe(_texture));
			
			for( var i = 0; i < _samp; i++ ) {
				prg = i * t;
				if(_invp) prg = 1 - prg;
				
				p   = _path.getPointRatio(_loop? prg : clamp(prg, 0, .99), 0, p);
				
				nx = p.x;
				ny = p.y;
				nt = t * i;
				
				var _cLen = _colLen.eval(prg);
				var _cWei = _colWei.eval(p.weight);
				nc = colorMultiply(_cLen, _cWei);
				
				nw  = _size * _sizeLenMap.get(prg);
				ndx = lengthdir_x(nw, _dirc);
				ndy = lengthdir_y(nw, _dirc);
				
				if(i) {
					var ox0 = ox - odx, oy0 = oy - ody;
					var ox1 = ox + odx, oy1 = oy + ody;
					
					var nx0 = nx - ndx, ny0 = ny - ndy;
					var nx1 = nx + ndx, ny1 = ny + ndy;
					
					if(_shdSid) {
						draw_vertex_texture_color(ox0, oy0,  0, ot,  0, 1);
						draw_vertex_texture_color(ox , oy,  .5, ot, oc, 1);
						draw_vertex_texture_color(nx0, ny0,  0, nt,  0, 1);
						
						draw_vertex_texture_color(ox , oy,   0, ot, oc, 1);
						draw_vertex_texture_color(nx0, ny0, .5, nt,  0, 1);
						draw_vertex_texture_color(nx , ny,   0, nt, nc, 1);
						
						
						draw_vertex_texture_color(ox , oy,  .5, ot, oc, 1);
						draw_vertex_texture_color(ox1, oy1,  1, ot,  0, 1);
						draw_vertex_texture_color(nx , ny,  .5, nt, nc, 1);
						
						draw_vertex_texture_color(ox1, oy1,  1, ot,  0, 1);
						draw_vertex_texture_color(nx , ny,  .5, nt, nc, 1);
						draw_vertex_texture_color(nx1, ny1,  1, nt,  0, 1);
						
					} else {
						draw_vertex_texture_color(ox0, oy0, 0, ot, oc, 1);
						draw_vertex_texture_color(ox1, oy1, 1, ot, oc, 1);
						draw_vertex_texture_color(nx0, ny0, 0, nt, nc, 1);
						
						draw_vertex_texture_color(ox1, oy1, 1, ot, oc, 1);
						draw_vertex_texture_color(nx0, ny0, 0, nt, nc, 1);
						draw_vertex_texture_color(nx1, ny1, 1, nt, nc, 1);
						
					}
				}
				
				ox  = nx;
				oy  = ny;
				odx = ndx;
				ody = ndy;
				
				oc = nc;
				ow = nw;
				ot = nt;
				
				if(i && i % 32 == 0) {
					draw_primitive_end();
					draw_primitive_begin_texture(pr_trianglelist, surface_get_texture_safe(_texture));
				}
			}
			
			draw_primitive_end();
		surface_reset_target();
		
		return _outSurf; 
	}
}