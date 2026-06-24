function Node_MK_Jigsaw(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK Jigsaw";
	
	newInput( 3, nodeValueSeed());
	newInput( 0, nodeValue_Surface( "Surface In" ));
	
	////- =Pattern
	newInput( 1, nodeValue_EScroll( "Pattern",    0, [ "Grid", "Polar" ] ));
	newInput( 2, nodeValue_IVec2(   "Subdivide", [4,4] ));
	
	////- =Pieces
	newInput( 4, nodeValue_Float(   "Gap",    2 ));
	
	////- =Tabs
	newInput( 5, nodeValue_EScroll( "Shape",   0, [ "Circular", "Rectangle" ] ));
	newInput( 6, nodeValue_Vec2(    "Size",    [.33,.25] ));
	newInput( 7, nodeValue_Float(   "Recess",  .5 ));
	newInput( 8, nodeValue_Float(   "Extends",  0 ));
	
	////- =Output
	newInput( 9, nodeValue_Bool(    "Separate", false ));
	// 10
	
	newOutput( 0, nodeValue_Output( "Combined", VALUE_TYPE.surface, noone ));
	newOutput( 1, nodeValue_Output( "Pieces",   VALUE_TYPE.surface, []    ));
	newOutput( 2, nodeValue_Output( "Atlas",    VALUE_TYPE.surface, []    ));
	
	input_display_list = [  3,  0, 
		[ "Pattern", false ],  1,  2, 
		[ "Pieces",  false ],  4, 
		[ "Tabs",    false ],  5,  6,  7,  8, 
		[ "Output",  false ],  9, 
	];
	
	////- Nodes
	
	temp_surface = [ noone, noone, noone ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		
	}
	
	static cutSegment = function(x0, y0, x1, y1) {
		var c = choose(-1, 1);
		if(c == 0) { draw_line_width(x0, y0, x1, y1, gapp); return; }
		
		var g  = gapp;
		var g2 = g / 2;
		
		var _dirr = point_direction(x0, y0, x1, y1);
		var _diss = point_distance(x0, y0, x1, y1);
		
		var dx = lengthdir_x(1, _dirr);
		var dy = lengthdir_y(1, _dirr);
		var px = lengthdir_x(1, _dirr + 90 * c);
		var py = lengthdir_y(1, _dirr + 90 * c);
		var cw = csiz[0] * _diss;
		var ch = csiz[1] * _diss;
		
		var xc = (x0 + x1) / 2 - px * tres;
		var yc = (y0 + y1) / 2 - py * tres;
		
		var lx0 = xc - dx * (cw/2) * (1+extn);
		var ly0 = yc - dy * (cw/2) * (1+extn);
		var lx1 = xc + dx * (cw/2) * (1+extn);
		var ly1 = yc + dy * (cw/2) * (1+extn);
		
		draw_line_width(x0, y0, lx0, ly0, g);
		draw_line_width(lx1, ly1, x1, y1, g);
		
		if(conn == 0) {
			var nx, ny;
			var an  = _dirr;
			var tcx = xc + px * ch;
			var tcy = yc + py * ch;
			
			var ox = tcx + lengthdir_x(cw/2, an) * c;
			var oy = tcy + lengthdir_y(cw/2, an) * c;
			
			if(c) {
				if(g > 1) draw_line_round(ox, oy, lx1, ly1, g);
				else      draw_line(ox, oy, lx1, ly1);
			} else {
				if(g > 1) draw_line_round(ox, oy, lx0, ly0, g);
				else      draw_line(ox, oy, lx0, ly0);
			}
			
			var sp = 8;
			var st = 180 / sp;
			
			repeat(sp) {
				an += st;
				nx = tcx + lengthdir_x(cw/2, an) * c;
				ny = tcy + lengthdir_y(cw/2, an) * c;
				
				if(g > 1) draw_line_round(ox, oy, nx, ny, g);
				else      draw_line(ox, oy, nx, ny);
				
				ox = nx;
				oy = ny;
			}
			
			if(c) {
				if(g > 1) draw_line_round(ox, oy, lx0, ly0, g);
				else      draw_line(ox, oy, lx0, ly0);
			} else {
				if(g > 1) draw_line_round(ox, oy, lx1, ly1, g);
				else      draw_line(ox, oy, lx1, ly1);
			}
			
		} else if(conn == 1) {
			draw_line_width(lx0 + px*ch, ly0 + py*ch, lx1 + px*ch,         ly1 + py*ch,         g);
			draw_line_width(lx0 - px*g2, ly0 - py*g2, lx0 + px*ch + px*g2, ly0 + py*ch + py*g2, g);
			draw_line_width(lx1 - px*g2, ly1 - py*g2, lx1 + px*ch + px*g2, ly1 + py*ch + py*g2, g);
		}
					
	}
	
	static processData = function(_outData, _data, _array_index = 0) { 
		#region data
			var _seed = _data[ 3];
			var _surf = _data[ 0];
			
			var _patt = _data[ 1];
			var _subd = _data[ 2];
			
			var _gapp = _data[ 4]; gapp = _gapp;
			
			var _conn = _data[ 5]; conn = _conn;
			var _csiz = _data[ 6]; csiz = _csiz;
			var _tres = _data[ 7]; tres = _tres;
			var _extn = _data[ 8]; extn = _extn;
			
			var _sepp = _data[ 9];
			
			var _outSurf  = _outData[0];
			var _outPiece = _outData[1];
			var _outAtlas = _outData[2];
			
			if(!is_surface(_surf)) return _outData;
		#endregion
		
		var sw  = surface_get_width(_surf);
		var sh  = surface_get_height(_surf);
		
		var col = _subd[0];
		var row = _subd[1];
		var pw = sw / col;
		var ph = sh / row;
		hgap = _gapp / 2;
		
		temp_surface[0] = surface_verify(temp_surface[0], sw, sh);
		temp_surface[1] = surface_verify(temp_surface[1], sw, sh, surface_rgba32float);
		temp_surface[2] = surface_verify(temp_surface[2], sw, sh, surface_rgba32float);
		
		random_set_seed(_seed);
		
		var _segs = [];
		
		if(_patt == 0) {
			var cw = (sw - (_gapp * (col - 1))) / col;
			var ch = (sh - (_gapp * (row - 1))) / row;
			
			var cnw = _csiz[0] * cw;
			var cnh = _csiz[1] * ch;
			
			for( var i = 1; i < row; i++ ) {
				var ly = (ch + _gapp) * i - _gapp / 2;
				for( var j = 0; j < col; j++ ) {
					var lx0 = j * pw - 1;
					var lx1 = lx0 + pw + 2;
					array_push(_segs, [lx0, ly, lx1, ly]);
				}
			}
			
			for( var i = 1; i < col; i++ ) {
				var lx = (cw + _gapp) * i - _gapp / 2;
				for( var j = 0; j < row; j++ ) {
					var ly0 = j * ph - 1;
					var ly1 = ly0 + ph + 2;
					array_push(_segs, [lx, ly0, lx, ly1]);
				}
			}
			
		} else if(_patt == 1) {
			var rad = min(sw, sh) / 2;
			var ox, oy, nx, ny;
			
			var rcol = rad / (col - 1);
			
			for( var i = 0; i < row; i++ ) {
				var a  = i / row * 360;
				var dx = lengthdir_x(1, a);
				var dy = lengthdir_y(1, a);
				
				for( var j = 0; j < col; j++ ) {
					var l = j * rcol;
					
					nx = sw/2 + dx * l;
					ny = sh/2 + dy * l;
					
					if(j) array_push(_segs, [ox, oy, nx, ny]);
					
					ox = nx;
					oy = ny;
				}
			}
			
			for( var i = 0; i < col; i++ ) {
				var l = i * rcol;
				
				for( var j = 0; j <= row; j++ ) {
					var a  = j / row * 360;
					
					nx = sw/2 + lengthdir_x(l, a);
					ny = sh/2 + lengthdir_y(l, a);
					
					if(j) array_push(_segs, [ox, oy, nx, ny]);
					
					ox = nx;
					oy = ny;
				}
			}
			
		}
		
		surface_set_target(temp_surface[0]);
			draw_clear(c_white);
			
			draw_set_color(c_white);
			BLEND_SUBTRACT
			for( var i = 0, n = array_length(_segs); i < n; i++ ) 
				cutSegment(_segs[i][0], _segs[i][1], _segs[i][2], _segs[i][3]);
			BLEND_NORMAL
		surface_reset_target();
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			draw_surface(temp_surface[0], 0, 0);
			BLEND_MULTIPLY
			draw_surface(_surf, 0, 0);
			BLEND_NORMAL
		surface_reset_target();
		
		_outData[0] = _outSurf;
		
		if(!_sepp) return _outData;
		
		#region region indexing
			surface_set_shader(temp_surface[2], sh_seperate_shape_index);
				shader_set_i( "mode",      1      );
				shader_set_i( "ignore",    1      );
				shader_set_f( "dimension", sw, sh );
				draw_empty();
			surface_reset_shader();
			
			shader_set(sh_seperate_shape_ite);
				shader_set_i( "mode",      1      );
				shader_set_i( "ignore",    1      );
				shader_set_f( "dimension", sw, sh );
				shader_set_f( "threshold", 0      );
				shader_set_i( "diagonal",  0      );
				shader_set_s( "map",       temp_surface[0] );
			shader_reset();
		
			var res_index = 0, iteration = sw + sh;
			for(var i = 0; i <= iteration; i++) {
				var bg = i % 2;
				var fg = !bg;
				
				surface_set_shader(temp_surface[1+bg], sh_seperate_shape_ite,, BLEND.over);
					draw_surface_safe(temp_surface[1+fg]);
				surface_reset_shader();
				res_index = 1+bg;
			}
			
		#endregion
		
		#region count and match color
			var pxc = sw * sh;
			var reg = ds_map_create();
			var i = 0;
			
			var buff = buffer_create(pxc * 16, buffer_fixed, 1);
			buffer_get_surface(buff, temp_surface[res_index], 0);
			buffer_seek(buff, buffer_seek_start, 0);
			
			repeat(pxc) {
				var _r = buffer_read(buff, buffer_f32);
				var _g = buffer_read(buff, buffer_f32);
				var _b = buffer_read(buff, buffer_f32);
				var _a = buffer_read(buff, buffer_f32);
				
				if(_r == 0 && _g == 0 && _b == 0 && _a == 0) continue;
				reg[? _g * sw + _r] = [ _r, _g, _b, _a ];
			}
			
			buffer_delete(buff);
			var px = ds_map_size(reg);
		#endregion
		
		#region extract region
			_outPiece = surface_array_verify(_outPiece, px);
			_outAtlas = array_verify(_outAtlas, px);
			
			var key    = ds_map_keys_to_array(reg);
			var _ind   = 0;
			
			for(var i = 0; i < px; i++) {
				var _k  = key[i];
				var _cc = reg[? _k];
				
				var min_x = round(_cc[0]);
				var min_y = round(_cc[1]);
				var max_x = round(_cc[2]);
				var max_y = round(_cc[3]);
				
				var _sw = max_x - min_x + 1;
				var _sh = max_y - min_y + 1;
				
				if(_sw <= 1 || _sh <= 1) continue;
				
				_outPiece[_ind] = surface_verify(_outPiece[_ind], _sw, _sh);
				
				surface_set_shader(_outPiece[_ind], sh_seperate_shape_sep);
					shader_set_s( "original",  _surf   );
					shader_set_f( "color",     _cc     );
					shader_set_i( "override",  0       );
					shader_set_c( "overColor", c_white );
					
					draw_surface_safe(temp_surface[res_index], -min_x, -min_y);
				surface_reset_shader();
				
				_outAtlas[_ind] = new SurfaceAtlas(_outPiece[_ind], min_x, min_y).setOriginalSurface(_surf);
				_ind++;
			}
			
			array_resize(_outPiece, _ind);
			array_resize(_outAtlas, _ind);
			
			ds_map_destroy(reg);
		#endregion
		
		_outData[1] = _outPiece;
		_outData[2] = _outAtlas;
		
		return _outData; 
	}
}