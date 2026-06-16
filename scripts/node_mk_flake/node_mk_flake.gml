function Node_MK_Flake(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK Flake";
	
	newInput( 2, nodeValueSeed());
	
	////- =Output
	newInput( 0, nodeValue_Dimension());
	newInput( 1, nodeValue_Surface( "Background" ));
	
	////- =Transform
	newInput(14, nodeValue_Rotation( "Rotation", 0 ));
	
	////- =Flakes
	newInput( 3, nodeValue_Slider(   "Size",            .7      ));
	newInput(22, nodeValue_SliRange( "Range",           [0,1]   ));
	newInput( 4, nodeValue_Range(    "Branches",        [3,5]   ));
	newInput(11, nodeValue_SliRange( "Branch Position", [0,1]   ));
	newInput( 5, nodeValue_RotRange( "Branch Angle",    [0,75]  ));
	newInput( 6, nodeValue_Range(    "Branch Length",   [.2,1]  ));
	
	////- =Caps
	newInput(16, nodeValue_EScroll(  "Cap Shape",  0, [ "None", 
		new scrollItem( "Diamond",   s_node_shape_diamond, 0 ), 
		new scrollItem( "Rectangle", s_node_shape_rectangle, 0 ), 
		new scrollItem( "Circle",    s_node_shape_circle, 0 ),
		"Surface", 
	] ));
	newInput(18, nodeValue_Surface(  "Cap Texture"       ));
	newInput(17, nodeValue_Vec2(     "Cap Size",   [4,4] ));
	newInput(20, nodeValue_Slider(   "Branch Cap",  0    ));
	
	////- =Spokes
	newInput(23, nodeValue_Vec2(     "Offset",   [0,0] ));
	newInput(13, nodeValue_Rotation( "Rotation",  0    ));
	newInput(12, nodeValue_Int(      "Spokes",    6    ));
	
	////- =Render
	newInput(15, nodeValue_EScroll(  "Blend Mode",    0, [ "Normal", "Additive", "Maximum" ]   ));
	newInput( 7, nodeValue_Range(    "Thickness",    [2,2], true )).setCurvable(10, CURVE_DEF_11);
	newInput( 8, nodeValue_Gradient( "Colors",       gra_white   ));
	newInput(21, nodeValue_Gradient( "Width Color",  gra_white   ));
	newInput(19, nodeValue_Color(    "Mirror Shade", ca_white    ));
	
		////- =/Trim
	newInput( 9, nodeValue_Slider(   "Trim",     0 ));
	// 24
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ s_MKFX, 2, 
		[ "Output",    false ],  0,  1, 
		[ "Transform", false ], 14, 
		[ "Flakes",    false ],  3, 22,  4, 11,  5,  6,  
		[ "Caps",      false ], 16, 18, 17, 20, 
		[ "Spokes",    false ], 23, 13, 12, 
		[ "Render",    false ], 15,  7, 10,  8, 21, 19, 
			[ "/Trim", false ],  9, 
	];
	
	////- Nodes
	
	temp_surface = [ 0 ]
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { }
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
			var _seed   = _data[ 2];
			
			var _dim    = _data[ 0];
			var _bgSurf = _data[ 1];
			
			var _rotat  = _data[14];
			
			var _size   = _data[ 3];
			var _range  = _data[22];
			var _brAmo  = _data[ 4];
			var _brPos  = _data[11];
			var _brAng  = _data[ 5];
			var _brLen  = _data[ 6];
			
			var _capT   = _data[16];
			var _capTx  = _data[18];
			var _capS   = _data[17];
			var _capB   = _data[20];
			
			var _offs   = _data[23];
			var _rota   = _data[13];
			var _spks   = _data[12];
			
			var _blnd   = _data[15];
			var _thcks  = _data[ 7];
			var _colrs  = _data[ 8];
			var _colrw  = _data[21];
			var _mirrC  = _data[19];
			
			var _trim   = _data[ 9];
			
			inputs[18].setVisible(_capT == 4, _capT == 4);
		#endregion
		
		var cx  = _dim[0] / 2;
		var cy  = _dim[1] / 2;
		var trm = 1 - _trim;
		
		var tw = surface_get_width_safe(_capTx);
		var th = surface_get_height_safe(_capTx);
		
		random_set_seed(_seed);
		
		temp_surface[0] = surface_verify(temp_surface[0], _dim[0], _dim[1]);
		surface_set_shader(temp_surface[0]);
		
			shader_set(sh_mk_flake_line);
			shader_set_curve( "thick", _data[10], inputs[7] );
			shader_set_gradient( _colrw );
			shader_reset();
			
			switch(_blnd) {
				case 0 : BLEND_NORMAL; break;
				case 1 : BLEND_ADD;    break;
				case 2 : BLEND_MAX;    break;
			}
			
			var maxPrg = 1 + max(_brLen[0], _brLen[1]) * .5;
			var trmPrg = maxPrg * trm;
			
			var _len = _dim[1] * .5 * _size;
			var  thk = random_range(_thcks[0], _thcks[1]);
			var  cc  = _colrs.eval(0);
			draw_set_color(cc);
			
			var cx0 = cx;
			var cy0 = cy - _len * _range[0];
			
			var cx1 = cx;
			var cy1 = cy - _len * min(1, trmPrg) * _range[1];
			
			shader_set(sh_mk_flake_line);
			draw_line_width2(cx0 + _offs[0], cy0 + _offs[1], cx1 + _offs[0], cy1 + _offs[1], thk, thk);
			shader_reset();
			
			var ew = _capS[0] * min(1, trmPrg);
			var eh = _capS[1] * min(1, trmPrg);
			switch(_capT) {
				case 1 : draw_triangle(cx1, cy1 - eh, cx1, cy1 + eh, cx1 + ew, cy1, false);
					     draw_triangle(cx1, cy1 - eh, cx1, cy1 + eh, cx1 - ew, cy1, false); break;
				
				case 2 : draw_rectangle(cx1 - ew, cy1 - eh, cx1 + ew, cy1 + eh, false);     break;
					
				case 3 : draw_set_circle_precision(32);
					     draw_ellipse(cx1 - ew, cy1 - eh, cx1 + ew, cy1 + eh, false);       break;
					
				case 4 : draw_surface_stretched_safe(_capTx, cx1 - ew, cy1 - eh, ew * 2, eh * 2, cc); break;
			}
			
			var brn = irandom_range(_brAmo[0], _brAmo[1]);
			
			repeat(brn) {
				var ofs  = random_range(_brPos[0], _brPos[1]);
				var dir  = random_range(_brAng[0], _brAng[1]);
				var len  = random_range(_brLen[0], _brLen[1]) * _dim[1] * .25;
				    len *= clamp((trmPrg - ofs) / (maxPrg - ofs), 0., 1.);
				
				var bx  = cx;
				var by  = cy - ofs * _len;
				
				var bx1 = bx + lengthdir_x(len, dir);
				var by1 = by + lengthdir_y(len, dir);
				
				var thk = random_range(_thcks[0], _thcks[1]);
				var clr = _colrs.eval(random(1));
				
				shader_set(sh_mk_flake_line);
				draw_set_color(clr);
				draw_line_width2(bx + _offs[0], by + _offs[1], bx1 + _offs[0], by1 + _offs[1], thk, thk);
				shader_reset();
				
				if(random(1) < _capB) {
					switch(_capT) {
						case 1 : draw_triangle(bx1, by1 - eh, bx1, by1 + eh, bx1 + ew, by1, false);
							     draw_triangle(bx1, by1 - eh, bx1, by1 + eh, bx1 - ew, by1, false); break;
						
						case 2 : draw_rectangle(bx1 - ew, by1 - eh, bx1 + ew, by1 + eh, false);     break;
							
						case 3 : draw_set_circle_precision(32);
							     draw_ellipse(bx1 - ew, by1 - eh, bx1 + ew, by1 + eh, false);       break;
							
						case 4 : 
							var p = point_rotate(bx1-ew, by1-eh, bx1, by1, dir);
							draw_surface_ext_safe(_capTx, p[0], p[1], ew*2 / tw, eh*2 / th, dir, clr);
							break;
					}
				}
			}
			
		surface_reset_shader();
		
		surface_set_shader(_outSurf);
			draw_surface_safe(_bgSurf);
			
			shader_set(sh_mk_flake);
			shader_set_2( "sampleDimension", _dim   );
			shader_set_i( "blendMode",       _blnd  );
			
			shader_set_f( "globalRotation",  _rotat );
			shader_set_f( "rotation",        _rota  );
			shader_set_f( "spokes",          _spks  );
			
			shader_set_c( "mirrorColor",     _mirrC );
			
			draw_surface(temp_surface[0], 0, 0);
		surface_reset_shader();
		
		return _outSurf; 
	}
}