function Node_MK_Jigsaw(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK Jigsaw";
	
	newInput( 3, nodeValueSeed());
	newInput( 0, nodeValue_Surface( "Surface In" ));
	
	////- =Pattern
	newInput( 1, nodeValue_EScroll( "Pattern",    0, [ "Grid" ] ));
	newInput( 2, nodeValue_IVec2(   "Subdivide", [4,4]          ));
	
	////- =Pieces
	newInput( 4, nodeValue_Float(   "Gap",    2 ));
	
	////- =Connection
	newInput( 5, nodeValue_EScroll( "Shape",  0, [ "Circular", "Rectangle" ] ));
	newInput( 6, nodeValue_Vec2(    "Size",   [.33,.25] ));
	
	////- =Render
	
	// 7
	
	newOutput( 0, nodeValue_Output( "Combined", VALUE_TYPE.surface, noone ));
	newOutput( 1, nodeValue_Output( "Pieces",   VALUE_TYPE.surface, []    ));
	newOutput( 2, nodeValue_Output( "Atlas",    VALUE_TYPE.surface, []    ));
	
	input_display_list = [  3,  0, 
		[ "Pattern",    false ],  1,  2, 
		[ "Pieces",     false ],  4, 
		[ "Connection", false ],  5,  6, 
	];
	
	////- Nodes
	
	temp_surface = [ noone, noone, noone ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		
	}
	
	static processData = function(_outData, _data, _array_index = 0) { 
		#region data
			var _seed = _data[ 3];
			var _surf = _data[ 0];
			
			var _patt = _data[ 1];
			var _subd = _data[ 2];
			
			var _gapp = _data[ 4];
			
			var _conn = _data[ 5];
			var _csiz = _data[ 6];
			
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
		var hgap = _gapp / 2;
		
		temp_surface[0] = surface_verify(temp_surface[0], sw, sh);
		temp_surface[1] = surface_verify(temp_surface[1], sw, sh, surface_rgba32float);
		temp_surface[2] = surface_verify(temp_surface[2], sw, sh, surface_rgba32float);
		
		random_set_seed(_seed);
		
		surface_set_target(temp_surface[0]);
			draw_clear(c_white);
			
			var cw = (sw - (_gapp * (col - 1))) / col;
			var ch = (sh - (_gapp * (row - 1))) / row;
			
			var cnw = _csiz[0] * cw;
			var cnh = _csiz[1] * ch;
			
			draw_set_color(c_white);
			BLEND_SUBTRACT
			for( var i = 1; i < row; i++ ) {
				var ly = (ch + _gapp) * i - _gapp / 2;
				
				for( var j = 0; j < col; j++ ) {
					var lx0 = j * pw - 1;
					var lx1 = lx0 + pw + 2;
					var lxc = (lx0 + lx1) / 2;
					
					var c = choose(-1, 1);
					if(c == 0) { draw_line_width(lx0, ly, lx1, ly, _gapp); continue; }
					
					var lcx0 = lxc - cnw / 2;
					var lcx1 = lxc + cnw / 2;
					var lcy  = ly + cnh * c;
					
					draw_line_width(lx0, ly, lcx0, ly, _gapp);
					draw_line_width(lx1, ly, lcx1, ly, _gapp);
					
					if(_conn == 0) {
						
						
					} else if(_conn == 1) {
						draw_line_width(lcx0, lcy, lcx1, lcy, _gapp);
						draw_line_width(lcx0, ly - hgap * c,  lcx0, lcy + hgap * c, _gapp);
						draw_line_width(lcx1, ly - hgap * c,  lcx1, lcy + hgap * c, _gapp);
					}
					
				}
			}
			
			for( var i = 1; i < col; i++ ) {
				var lx = (cw + _gapp) * i - _gapp / 2;
				
				for( var j = 0; j < col; j++ ) {
					var ly0 = j * ph - 1;
					var ly1 = ly0 + ph + 2;
					var lyc = (ly0 + ly1) / 2;
					
					var c = choose(-1, 1);
					if(c == 0) { draw_line_width(lx, ly0, lx, ly1, _gapp); continue; }
					
					var lcy0 = lyc - cnw / 2;
					var lcy1 = lyc + cnw / 2;
					var lcx  = lx + cnh * c;
					
					draw_line_width(lx, ly0, lx, lcy0, _gapp);
					draw_line_width(lx, ly1, lx, lcy1, _gapp);
					
					if(_conn == 0) {
						
						
					} else if(_conn == 1) {
						draw_line_width(lcx, lcy0, lcx, lcy1, _gapp);
						draw_line_width(lx - hgap * c,  lcy0, lcx + hgap * c, lcy0, _gapp);
						draw_line_width(lx - hgap * c,  lcy1, lcx + hgap * c, lcy1, _gapp);
					}
				}
			}
			BLEND_NORMAL
		surface_reset_target();
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			draw_surface(temp_surface[0], 0, 0);
			BLEND_MULTIPLY
			draw_surface(_surf, 0, 0);
			BLEND_NORMAL
		surface_reset_target();
		
		#region region indexing
			surface_set_shader(temp_surface[2], sh_seperate_shape_index);
				shader_set_i( "mode",      1      );
				shader_set_i( "ignore",    1      );
				shader_set_f( "dimension", sw, sh );
				draw_empty();
			surface_reset_shader();
			
			shader_set(sh_seperate_shape_ite);
				shader_set_i( "mode",      1               );
				shader_set_i( "ignore",    1               );
				shader_set_f( "dimension", sw, sh          );
				shader_set_f( "threshold", 0               );
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
		
		_outData[0] = _outSurf;
		_outData[1] = _outPiece;
		_outData[2] = _outAtlas;
		
		return _outData; 
	}
}