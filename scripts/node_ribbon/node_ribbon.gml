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
	newInput( 4, nodeValue_Float(    "Size",       8 )).setHotkey("S");
	newInput( 8, nodeValue_Curve(    "Size Over Length",  CURVE_DEF_11 ));
	newInput( 5, nodeValue_Rotation( "Direction", 90 ));
	newInput(15, nodeValue_Float(    "Thickness",  0 ));
	
	////- =Render
	newInput( 6, nodeValue_Gradient( "Color over Length", new gradientObject(ca_white) ));
	newInput( 7, nodeValue_Gradient( "Color Weight",      new gradientObject(ca_white) ));
	newInput(12, nodeValue_Surface(  "Texture",           noone ));
	newInput(13, nodeValue_Vec2(     "Texture Position",  [0,0] ));
	newInput(14, nodeValue_Vec2(     "Texture Scale",     [1,1] ));
	newInput( 9, nodeValue_Bool(     "Shade Side",        false ));
	// input 16
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0, 
		["Output", false], 1, 
		["Path",   false], 2, 11, 3, 10, 
		["Ribbon", false], 4, 8, 15, 5, 
		["Render", false], 6, 7, 12, 13, 14, 9, 
	];
	
	////- Nodes
	
	sizeLenMap = new curveMap(undefined, 128);
	__p  = new __vec2P();
	__p0 = new __vec2P();
	__p1 = new __vec2P();
	
	temp_surface = array_create(8);
	
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
			
			var _size    = _data[ 4];
			var _sizeLen = _data[ 8]; sizeLenMap.set(_sizeLen);
			var _dirc    = _data[ 5];
			var _thck    = _data[15];
			
			var _colLen  = _data[ 6];
			var _colWei  = _data[ 7];
			var _surface = _data[12]; var _texture = surface_get_texture_safe(_surface);
			var _textPos = _data[13];
			var _textSca = _data[14];
			var _shdSid  = _data[ 9];
		#endregion
		
		if(!is_path(_path)) return _outSurf;
		
		for( var i = 0, n = array_length(temp_surface); i < n; i++ ) {
			temp_surface[i] = surface_verify(temp_surface[i], _dim[0], _dim[1]);
			surface_clear(temp_surface[i]);
		}
		
		var ox, oy, oc, ow, ot, odx, ody, odir; 
		var nx, ny, nc, nw, nt, ndx, ndy, ndir;
		var prg;
		
		var t = 1 / _samp;
		var _useThick = _thck > 1;
		
		var _u1 = 1 - (.5 / _dim[0]);
		var cap = [];
		var _st = .5 / _samp;
		
		var _surfs = [
			temp_surface[0],
			temp_surface[1],
			temp_surface[2],
			temp_surface[3],
		];
		
		if(!_useThick) surface_set_target(temp_surface[0]);
		shader_set(sh_draw_ribbon);
			shader_set_interpolation( _surface );
			shader_set_a("position",  _textPos );
			shader_set_a("scale",     _textSca );
			
			shader_set_i( "shadeSide", _shdSid );
			shader_set_i( "useThickness",    0 );
			
			for( var i = 0; i <= _samp; i++ ) {
				prg = _invp? 1 - i * t : i * t;
				
				_path.getPointRatio(_loop? prg : clamp(prg, 0, .999), 0, __p );
				_path.getPointRatio(prg - _st, 0, __p0);
				_path.getPointRatio(prg + _st, 0, __p1);
				
				ndir = point_direction(__p0.x, __p0.y, __p1.x, __p1.y) + 90;
				
				nx = __p.x;
				ny = __p.y;
				nt = t * i;
				
				var _cLen = _colLen.eval(prg);
				var _cWei = _colWei.eval(__p.weight);
				nc = colorMultiply(_cLen, _cWei);
				
				nw  = _size * sizeLenMap.get(prg);
				ndx = lengthdir_x(nw, _dirc);
				ndy = lengthdir_y(nw, _dirc);
				
				if(i) {
					var ox0 = ox - odx, oy0 = oy - ody;
					var ox1 = ox + odx, oy1 = oy + ody;
					
					var nx0 = nx - ndx, ny0 = ny - ndy;
					var nx1 = nx + ndx, ny1 = ny + ndy;
					
					if(!_useThick) {
						shader_set_i( "passes", 0 );
						
						draw_primitive_begin_texture(pr_trianglelist, _texture);
						draw_vertex_texture_color(ox0, oy0, 0, ot, oc, 1);
						draw_vertex_texture_color(ox1, oy1, 1, ot, oc, 1);
						draw_vertex_texture_color(nx0, ny0, 0, nt, nc, 1);
						
						draw_vertex_texture_color(ox1, oy1, 1, ot, oc, 1);
						draw_vertex_texture_color(nx0, ny0, 0, nt, nc, 1);
						draw_vertex_texture_color(nx1, ny1, 1, nt, nc, 1);
						draw_primitive_end(); 
						
					} else {
						var _odrx = lengthdir_x(_thck, odir);
						var _odry = lengthdir_y(_thck, odir);
						
						var _ndrx = lengthdir_x(_thck, ndir);
						var _ndry = lengthdir_y(_thck, ndir);
						
						surface_set_target_ext(0, temp_surface[0]);
						surface_set_target_ext(1, temp_surface[1]);
						surface_set_target_ext(2, temp_surface[2]);
						surface_set_target_ext(3, temp_surface[3]);
						shader_set_i("passes", 0 );
						shader_set_i("useThickness", 1 );
						
						draw_primitive_begin_texture(pr_trianglelist, _texture);
						draw_vertex_texture_color(ox0 + _odrx, oy0 + _odry, 0, ot, oc, 1);
						draw_vertex_texture_color(ox1 + _odrx, oy1 + _odry, 1, ot, oc, 1);
						draw_vertex_texture_color(nx0 + _ndrx, ny0 + _ndry, 0, nt, nc, 1);
						
						draw_vertex_texture_color(ox1 + _odrx, oy1 + _odry, 1, ot, oc, 1);
						draw_vertex_texture_color(nx0 + _ndrx, ny0 + _ndry, 0, nt, nc, 1);
						draw_vertex_texture_color(nx1 + _ndrx, ny1 + _ndry, 1, nt, nc, 1);
						draw_primitive_end(); 
						
						shader_set_i("passes", 1 );
						draw_primitive_begin_texture(pr_trianglelist, _texture);
						draw_vertex_texture_color(ox0 - _odrx, oy0 - _odry, 0, ot, oc, 1);
						draw_vertex_texture_color(ox1 - _odrx, oy1 - _odry, 1, ot, oc, 1);
						draw_vertex_texture_color(nx0 - _ndrx, ny0 - _ndry, 0, nt, nc, 1);
						
						draw_vertex_texture_color(ox1 - _odrx, oy1 - _odry, 1, ot, oc, 1);
						draw_vertex_texture_color(nx0 - _ndrx, ny0 - _ndry, 0, nt, nc, 1);
						draw_vertex_texture_color(nx1 - _ndrx, ny1 - _ndry, 1, nt, nc, 1);
						draw_primitive_end(); 
						surface_reset_target();
						
						surface_set_target_ext(0, temp_surface[4]);
						surface_set_target_ext(1, temp_surface[5]);
						shader_set_i("passes", 0 );
						shader_set_i("useThickness", 0 );
						
						draw_primitive_begin_texture(pr_trianglelist, _texture);
						draw_vertex_texture_color(ox0 - _odrx, oy0 - _odry, 0, ot, oc, 1);
						draw_vertex_texture_color(ox0 + _odrx, oy0 + _odry, 0, ot, oc, 1);
						draw_vertex_texture_color(nx0 - _ndrx, ny0 - _ndry, 0, nt, nc, 1);
						
						draw_vertex_texture_color(nx0 - _ndrx, ny0 - _ndry, 0, ot, oc, 1);
						draw_vertex_texture_color(ox0 + _odrx, oy0 + _odry, 0, ot, oc, 1);
						draw_vertex_texture_color(nx0 + _ndrx, ny0 + _ndry, 0, nt, nc, 1);
						draw_primitive_end(); 
						
						shader_set_i("passes", 1 );
						draw_primitive_begin_texture(pr_trianglelist, _texture);
						draw_vertex_texture_color(ox1 - _odrx, oy1 - _odry, _u1, ot, oc, 1);
						draw_vertex_texture_color(ox1 + _odrx, oy1 + _odry, _u1, ot, oc, 1);
						draw_vertex_texture_color(nx1 - _ndrx, ny1 - _ndry, _u1, nt, nc, 1);
						
						draw_vertex_texture_color(nx1 - _ndrx, ny1 - _ndry, _u1, ot, oc, 1);
						draw_vertex_texture_color(ox1 + _odrx, oy1 + _odry, _u1, ot, oc, 1);
						draw_vertex_texture_color(nx1 + _ndrx, ny1 + _ndry, _u1, nt, nc, 1);
						draw_primitive_end(); 
						surface_reset_target();
						
						if(i == 1) {
							cap[0] = [
								angle_difference(_dirc, odir) < 0,
								
								[ox0 - _odrx, oy0 - _odry, 0, ot, oc, 1], 
								[ox1 - _odrx, oy1 - _odry, 1, ot, oc, 1], 
								[ox0 + _odrx, oy0 + _odry, 0, ot, oc, 1], 
								
								[ox0 + _odrx, oy0 + _odry, 0, ot, oc, 1], 
								[ox1 - _odrx, oy1 - _odry, 1, ot, oc, 1], 
								[ox1 + _odrx, oy1 + _odry, 1, ot, oc, 1], 
							];
						}
						
						if(i == _samp) {
							cap[1] = [
								angle_difference(_dirc, ndir) > 0,
								
								[nx0 - _ndrx, ny0 - _ndry, 0, nt, nc, 1],
								[nx1 - _ndrx, ny1 - _ndry, 1, nt, nc, 1],
								[nx0 + _ndrx, ny0 + _ndry, 0, nt, nc, 1],
								
								[nx0 + _ndrx, ny0 + _ndry, 0, nt, nc, 1],
								[nx1 - _ndrx, ny1 - _ndry, 1, nt, nc, 1],
								[nx1 + _ndrx, ny1 + _ndry, 1, nt, nc, 1],
							];
						}
						
					}
				}
				
				ox  = nx;
				oy  = ny;
				odx = ndx;
				ody = ndy;
				
				oc = nc;
				ow = nw;
				ot = nt;
				
				odir = ndir;
			}
			
		shader_reset();
		if(!_useThick) surface_reset_target();
		
		if(_useThick) {
			surface_set_target(temp_surface[6]);
				DRAW_CLEAR
				var c = cap[0]; 
				
				draw_primitive_begin_texture(pr_trianglelist, _texture);
				for( var i = 1, n = array_length(c); i < n; i++ )
					draw_vertex_texture_color(c[i][0], c[i][1], c[i][2], c[i][3], c[i][4], c[i][5]);
				draw_primitive_end(); 
			surface_reset_target();
			
			surface_set_target(temp_surface[7]);
				DRAW_CLEAR
				var c = cap[1]; 
				
				draw_primitive_begin_texture(pr_trianglelist, _texture);
				for( var i = 1, n = array_length(c); i < n; i++ )
					draw_vertex_texture_color(c[i][0], c[i][1], c[i][2], c[i][3], c[i][4], c[i][5]);
				draw_primitive_end(); 
			surface_reset_target();
			
			// printSurface("surface0", temp_surface[0]);
			// printSurface("surface1", temp_surface[1]);
				
			surface_set_shader(_outSurf, noone, true, BLEND.normal);
				draw_surface(temp_surface[4], 0, 0);
				
				shader_set(sh_draw_ribbon_merge);
				shader_set_s("surface0", temp_surface[0]);
				shader_set_s("surface1", temp_surface[1]);
				shader_set_s("depth0",   temp_surface[2]);
				shader_set_s("depth1",   temp_surface[3]);
				draw_empty();
				shader_reset();
				
				draw_surface(temp_surface[5], 0, 0);
				if(!_loop) {
					if(cap[0][0]) draw_surface(temp_surface[6], 0, 0);
					if(cap[1][0]) draw_surface(temp_surface[7], 0, 0);
				}
				
			surface_reset_shader();
			
		} else {
			surface_set_shader(_outSurf);
				draw_surface(temp_surface[0], 0, 0);
			surface_reset_shader();
		}
		
		return _outSurf; 
	}
}