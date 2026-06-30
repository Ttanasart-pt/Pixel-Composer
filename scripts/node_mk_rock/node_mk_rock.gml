function Node_MK_Rock(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK Rock";
	
	newInput( 1, nodeValueSeed());
	
	////- =Output
	newInput( 0, nodeValue_Dimension());
	
	////- =Pile
	newInput( 2, nodeValue_Int(      "Amount",       3          ));
	newInput( 5, nodeValue_Vec2(     "Scatter",     [3,2]       ));
	newInput( 8, nodeValue_Vec2(     "Origin",      [.5,.5]     )).setUnitSimple();
	newInput(27, nodeValue_Slider(   "Pile Scale",   .8         )).setCurvable(30, CURVE_DEF_11);
	newInput(41, nodeValue_Rotation( "Rotation",      0         ));
	
	////- =Rock
	newInput(37, nodeValue_EScroll(  "Shape",        0, [ "Ellipse", "Quadrilateral", "Diamond", "Polygon", "Surface" ] ));
	newInput(40, nodeValue_Range(    "Sides",       [4,6]       ));
	newInput(43, nodeValue_Surface(  "Surface"                  ));
	newInput( 3, nodeValue_Range(    "Size",        [4,8]       ));
	newInput( 4, nodeValue_Slider(   "Ratio",       .5          ));
	newInput( 7, nodeValue_Range(    "Depth",       [4,6]       ));
	newInput( 6, nodeValue_RotRange( "Rock Angle",  [0,0]       ));
	newInput(16, nodeValue_Range(    "Shape Scale", [1,1], true )).setCurvable(28, CURVE_DEF_11);
	
		////- =Shape Modifier
	newInput(34, nodeValue_Range(    "Shear",       [0,0]       )).setCurvable(35, CURVE_DEF_11);
	newInput(38, nodeValue_Slider(   "Cut Chance",   0          )).setCurvable(42, CURVE_DEF_11);
	newInput(39, nodeValue_Range(    "Cut Scale",   [0,1]       ));
	
	////- =Nugget
	newInput(20, nodeValue_Bool(     "Nugget",      false       ));
	newInput(24, nodeValue_Slider(   "Chance",       .5         ));
	newInput(21, nodeValue_Range(    "Width",       [2,2]       ));
	newInput(22, nodeValue_Range(    "Height",      [1,2]       ));
	newInput(23, nodeValue_Range(    "Depth",       [1,1]       ));
	
		////- =/Rendering
	newInput(19, nodeValue_Gradient( "Nugget Color",   gra_white ));
	newInput(25, nodeValue_Gradient( "Nugget Outline", gra_white ));
	
	////- =Rendering
	newInput(36, nodeValue_EButton(  "Blend Mode", 0, [ "Normal", "Additive", "Maximum" ] ));
	newInput(18, nodeValue_Gradient( "Base Color", new gradientObject(cola(c_grey)) ));
	
		////- =/Shading
	newInput( 9, nodeValue_Gradient( "Shading",    new gradientObject(cola(c_grey)) )).setCurvable(26, CURVE_DEF_11);
	newInput(33, nodeValue_Color(    "Shine Color", ca_white      ));
	newInput(29, nodeValue_Range(    "Shine",      [.5,.5],  true ))
	newInput(17, nodeValue_RotRand(  "Direction",  [-15,-15]      ));
	
		////- =/Highlight
	newInput(31, nodeValue_Bool(     "Highlight",  true  ));
	newInput(32, nodeValue_Slider(   "Intensity",  1     ));
	
		////- =/Outline
	newInput(12, nodeValue_EButton(  "Inner Outline Blend", 1, [ "Normal", "Multiply", "Screen" ] ));
	newInput(10, nodeValue_Gradient( "Inner Outline", new gradientObject(cola(c_grey)) ));
	
	newInput(13, nodeValue_EButton(  "Outer Outline Blend", 1, [ "Normal", "Multiply", "Screen" ] ));
	newInput(11, nodeValue_Gradient( "Outer Outline", gra_white ));
	
		////- =/Posterize
	newInput(14, nodeValue_Bool(    "Colorize",  true        ));
	newInput(15, nodeValue_Palette( "Colors",    DEF_PALETTE ));
	// 44
	
	newOutput( 0, nodeValue_Output( "Surface Out", VALUE_TYPE.surface, noone ));
	newOutput( 1, nodeValue_Output( "Depth",       VALUE_TYPE.surface, noone ));
	
	input_display_list = [ s_MKFX, 1, 
		[ "Output",         false     ],  0, 
		[ "Pile",           false     ],  2,  5,  8, 27, 30, 
		[ "Rock",           false     ], 37, 40, 43,  3,  4,  7,  6, 16, 28, 
			[ "/Shape Modifier", false], 34, 35, 38, 42, 39, 
		
		[ "Nugget",          true, 20 ], 24, 21, 22, 23, 
			[ "/Rendering", false     ], 19, 25, 
		
		[ "Rendering",      false     ], 36, 18, 
			[ "/Shading",   false     ],  9, 26, 33, 29, 17, 
			[ "/Highlight", false, 31 ], 32, 
			[ "/Outline",   false     ], 12, 10, 13, 11, 
			[ "/Posterize", false, 14 ], 15, 
	];
	
	////- Nodes
	
	temp_surface = array_create(8, noone);
	
	output_index = 6;
	depth_index  = 7;
	
	rotation     = 0;
	
	seed         = 0;
	shape        = 0;
	shape_surf   = noone;
	
	dirr_range   = [0,0];
	scal_range   = [1,1];
	shin_range   = [1,1];
	shine_col    = ca_white;
	
	gra_base     = undefined;
	gra_nugg     = undefined;
	gra_shad     = undefined;
	gra_outi     = undefined;
	gra_outo     = undefined;
	
	scal_curve   = undefined;
	shade_curve  = undefined;

	highlight    = false;
	high_alpha   = 0;
	
	bld_outi     = 0;
	bld_outo     = 0;
	
	shear        = [0,0];
	shear_curve  = undefined;
	
	cut_chance   = 0;
	cut_curve    = undefined;
	cut_scale    = [0,0];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		drawOverlayInput(inputs[ 8].drawOverlay(hover, active, _x, _y, _s, _mx, _my));
	}
	
	static pebble = function(index, pebx, peby, pebw, pebh, pebs, rot, baseC, outline, nugg) {
		pebx = round(pebx);
		peby = round(peby);
		pebw = round(pebw);
		pebh = round(pebh);
		pebs = round(pebs);
		
		temp_surface[0] = surface_verify(temp_surface[0], pebw, pebh);
		surface_set_shader(temp_surface[0], noone);
			draw_set_color(baseC);
			
			switch(shape) {
				case 0 :
					draw_ellipse(-1, -1, pebw-1, pebh-1, false); 
					break;
					
				case 1 :
					draw_rectangle_points(
						random_range(-1,     pebw/2), random_range(-1,     pebh/2), 
						random_range(pebw/2, pebw),   random_range(-1,     pebh/2), 
						random_range(-1,     pebw/2), random_range(pebh/2, pebh), 
						random_range(pebw/2, pebw),   random_range(pebh/2, pebh), 
						false);
					break;
					
				case 2 :
					draw_rectangle_points(
						pebw/2-1, 0-1,
						pebw-1,   pebh/2-1,
						0-1,      pebh/2-1,
						pebw/2-1, pebh-1,
						false);
					break;
					
				case 3 : 
					var _polySide = irandom_range(sides[0], sides[1]);
					var _ang = random(360);
					var _ast = 360 / _polySide;
					
					var cx = pebw / 2;
					var cy = pebh / 2;
					
					for( var i = 0; i < _polySide; i++ ) {
						var a0 = _ang + i * _ast;
						var a1 = a0 + _ast;
						
						var x0 = cx + lengthdir_x(cx, a0);
						var y0 = cy + lengthdir_y(cy, a0);
						
						var x1 = cx + lengthdir_x(cx, a1);
						var y1 = cy + lengthdir_y(cy, a1);
						
						draw_triangle(cx-1, cy-1, x0-1, y0-1, x1-1, y1-1, false);
					}
					break;
					
				case 4 : 
					if(!is_just_surface(shape_surf)) break;
					draw_surface_stretched_ext(shape_surf, 0, 0, pebw, pebh, baseC, 1);
					break;
			}
			
			if(!nugg) {
				var shineSca = random_range(shin_range[0], shin_range[1]);
				
				BLEND_ADD
				gpu_set_colorwriteenable(1,1,1,0);
				draw_set_color_alpha(shine_col, _color_get_a(shine_col));
				draw_ellipse(-1+1, -1, pebw * shineSca, pebh * shineSca, false);
				draw_set_alpha(1);
				gpu_set_colorwriteenable(1,1,1,1);
				BLEND_NORMAL
			}
		surface_reset_shader();
		
		var extx = random_range(shear[0], shear[1]);
		extx *= shear_curve.get(index);
		
		var exty = -1;
		
		var pd  = 1 + ceil(abs(extx) * pebs);
		var pw2 = pebw + pd * 2;
		var ph2 = pebh + pd * 2;
		
		temp_surface[1] = surface_verify(temp_surface[1], pw2, ph2);
		surface_set_shader(temp_surface[1], sh_mk_rock_pabble_face);
			shader_set_2( "dimension", [pw2, ph2] );
			shader_set_f( "angle",     random_range(dirr_range[0], dirr_range[1]) );
			draw_surface(temp_surface[0], pd, pd);
		surface_reset_shader();
		
		temp_surface[2] = surface_verify(temp_surface[2], pw2, ph2);
		surface_set_shader(temp_surface[2]);
			var __p = point_rotate(0, 0, pw2/2, ph2/2, rot);
			draw_surface_ext(temp_surface[1], __p[0], __p[1], 1, 1, rot, c_white, 1);
		surface_reset_shader();
		
		temp_surface[3] = surface_verify(temp_surface[3], pw2, ph2+pebs); surface_clear(temp_surface[3]);
		temp_surface[5] = surface_verify(temp_surface[5], pw2, ph2+pebs); surface_clear(temp_surface[5]);
		
		var shade = gra_shad.eval(random(1));
		var scal  = 1;
		var scalO = nugg? .5 : random_range(scal_range[0], scal_range[1]);
		
		var ox = .5;
		var oy = .5;
		if(nugg) ox = random_range(.3, .7);
		
		var px = 0    + pw2 * ox;
		var py = pebs + ph2 * oy;
		
		pebx = pebx - pebw / 2 - pd;
		peby = peby - ph2  / 2 - pebs;
		
		for( var i = 0; i < pebs - 1; i++) {
			var prg = (i + 1) / pebs;
			
			surface_set_shader([temp_surface[3], temp_surface[5]], sh_mk_rock_pebble_draw, false, BLEND.normal);
			shader_set_f("depth", prg)
			surface_reset_shader();
			
			var dpx = px - pw2 * .5 * scal;
			var dpy = py - ph2 * .5 * scal;
			
			var curChn = cut_chance * cut_curve.get(prg);
			if(random(1) < curChn) {
				surface_set_shader([temp_surface[3], temp_surface[5]], sh_mk_rock_pebble_draw, false, BLEND.normal);
				draw_surface_ext(temp_surface[2], dpx, dpy, scal, scal, 0, c_white, 1);
				surface_reset_shader();
				
				var cutw = random_range(cut_scale[0], cut_scale[1]) * pw2;
				var cuth = random_range(cut_scale[0], cut_scale[1]) * ph2;
				
				var cutr = random(360);
				
				var curx = pw2/2 + lengthdir_x((pw2 - pd)/2, cutr);
				var cury = ph2/2 + lengthdir_y((ph2 - pd)/2, cutr);
				
				surface_set_target(temp_surface[2]);
					BLEND_SUBTRACT
					draw_ellipse(curx - cutw/2, cury - cuth/2, curx + cutw/2, cury + cuth/2, false);
					BLEND_NORMAL
				surface_reset_target();
			}
			
			surface_set_shader([temp_surface[3], temp_surface[5]], sh_mk_rock_pebble_draw, false, BLEND.normal);
			var shc = merge_color_rgba(c_white, shade, shade_curve.get(prg));
			draw_surface_ext(temp_surface[2], dpx, dpy, scal, scal, 0, shc, 1);
			BLEND_NORMAL
			
			if(i == pebs - 2 && highlight) {
				BLEND_ADD
				draw_surface_ext(temp_surface[2], dpx, dpy, scal, scal, 0, c_white, high_alpha);
				BLEND_NORMAL
			}
			surface_reset_shader();
			
			px += extx;
			py += exty;
			scal = lerp(scal, scal * scalO, scal_curve.get(prg));
			
		}
	
		surface_set_shader([temp_surface[3], temp_surface[5]], sh_mk_rock_pebble_draw, false, BLEND.normal);
		shader_set_f("depth", 1)
			var dpx   = px - pw2 * .5 * scal;
			var dpy   = py - ph2 * .5 * scal;
			var pebdy = dpy + ph2 * .5 * scal;
			
			draw_surface_ext(temp_surface[2], dpx, dpy, scal, scal, 0, c_white, 1);
		surface_reset_shader();
		
		temp_surface[4] = surface_verify(temp_surface[4], pw2, ph2+pebs);
		surface_set_shader(temp_surface[4], sh_mk_rock_pabble_outline);
			shader_set_2( "dimension", [pw2, ph2+pebs] );
			shader_set_c( "color",     nugg? gra_nugg_o.eval(random(1)) : gra_outi.eval(random(1)) );
			shader_set_i( "blend",     bld_outi );
			shader_set_i( "nugget",    nugg     );
			
			draw_surface(temp_surface[3], 0, 0);
		surface_reset_shader();
		
		surface_set_target(temp_surface[output_index]);
			switch(blend_mode) {
				case 0 : BLEND_NORMAL; break;
				case 1 : BLEND_ADD;    break;
				case 2 : BLEND_MAX;    break;
			}
			
			draw_surface(temp_surface[4], pebx, peby);
			BLEND_NORMAL
		surface_reset_target();
		
		surface_set_target(temp_surface[depth_index]);
			draw_surface(temp_surface[5], pebx, peby);
		surface_reset_target();
		
		return peby + pebdy;
	}
	
	static processData = function(_outData, _data, _array_index = 0) { 
		#region data
			seed        = _data[ 1];
			
			var _dim    = _data[ 0];
			
			var _amou   = _data[ 2];
			var _scatt  = _data[ 5];
			var _orig   = _data[ 8];
			var _pscal  = _data[27];
			pscal_curve = new curveMap(_data[30]);
			rotation    = _data[41];
			
			shape       = _data[37];
			sides       = _data[40];
			shape_surf  = _data[43];
			var _size   = _data[ 3];
			var _ratio  = _data[ 4];
			var _dept   = _data[ 7];
			var _rota   = _data[ 6];
			scal_range  = _data[16];
			scal_curve  = new curveMap(_data[28]);
			
			shear       = _data[34];
			shear_curve = new curveMap(_data[35]);
			cut_chance  = _data[38];
			cut_curve   = new curveMap(_data[42]);
			cut_scale   = _data[39];
			
			var _nugg   = _data[20];
			var _nchn   = _data[24];
			var _nwid   = _data[21];
			var _nhei   = _data[22];
			var _nsiz   = _data[23];
			
			gra_nugg    = _data[19];
			gra_nugg_o  = _data[25];
			
			blend_mode  = _data[36];
			gra_base    = _data[18];
			gra_shad    = _data[ 9];
			shin_range  = _data[29];
			shine_col   = _data[33];
			shade_curve = new curveMap(_data[26]);
			dirr_range  = _data[17];
			
			highlight   = _data[31];
			high_alpha  = _data[32];
			
			bld_outi    = _data[12];
			gra_outi    = _data[10];
			
			bld_outo    = _data[13];
			gra_outo    = _data[11];
			
			var _post   = _data[14];
			var _ppal   = _data[15];
			
			inputs[40].setVisible(shape == 3);
			inputs[43].setVisible(shape == 4, shape == 4);
		#endregion
		
		random_set_seed(seed); seed += 100;
		draw_set_circle_precision(32);
			
		var ww   = _dim[0];
		var hh   = _dim[1];
		
		var cx   = _orig[0];
		var cy   = _orig[1];
			
		var pebx = cx;
		var peby = cy;
		var _dir = choose(-1, 1);
			
		temp_surface[output_index] = surface_verify(temp_surface[output_index], ww, hh);
		temp_surface[depth_index]  = surface_verify(temp_surface[depth_index],  ww, hh);
		
		surface_clear(temp_surface[output_index]);
		surface_clear(temp_surface[depth_index], c_black, 1);
		
		var rockS = random(1);
		var deptS = random(1);
		
		var pebw = lerp(_size[0], _size[1], rockS);
		var pebh = ceil(pebw * _ratio);
		
		var pebs = lerp(_dept[0], _dept[1], deptS);
		
		var scx  = _scatt[0];
		var scy  = _scatt[1];
		
		for( var i = 0; i < _amou; i++ ) {
			var prg = _amou > 1? i / (_amou - 1) : 1;
			
			random_set_seed(seed); seed += 100;
			
			var rot   = irandom_range(_rota[0], _rota[1]);
			var baseC = gra_base.eval(random(1));
			
			var pebdy = pebble(prg, pebx, peby, pebw, pebh, pebs, rot, baseC, true, false);
			
			if(_nugg && random(1) < _nchn) {
				var nugw  = random_range(_nwid[0], _nwid[1]);
				var nugh  = random_range(_nhei[0], _nhei[1]);
				var nugs  = random_range(_nsiz[0], _nsiz[1]);
				
				var nugx  = pebx + random_range(-pebw/3, pebw/3);
				var nugy  = pebdy - irandom(pebh/2);
				
				var baseC = gra_nugg.eval(random(1));
				
				pebble(prg, nugx, nugy, nugw, nugh, nugs, rot, baseC, true, true);
			}
			
			pebx  = cx + scx * _dir;
			peby += scy;
			
			var cScale = _pscal * pscal_curve.get(prg);
			
			pebw *= cScale;
			pebh *= cScale;
			pebs *= cScale;
			
			scx  *= cScale;
			scy  *= cScale;
			_dir  = -_dir;
		}
	
		_outData[0] = surface_verify(_outData[0], ww, hh);
		_outData[1] = surface_verify(_outData[1], ww, hh);
		
		var _outSurf  = _outData[0];
		var _outDepth = _outData[1];
		
		surface_set_shader(_outSurf, sh_mk_rock_pabble_outline_inner);
			shader_set_2("dimension", [ww, hh]);
			shader_set_c("color",     gra_outo.eval(random(1)));
			shader_set_i("blend",     bld_outo);
			
			draw_surface(temp_surface[output_index], 0, 0);
		surface_reset_shader();
		
		surface_set_shader(_outDepth);
			draw_surface(temp_surface[depth_index], 0, 0);
		surface_reset_shader();
		
		if(_post) {
			surface_set_shader(temp_surface[output_index], sh_mk_rock_pabble_posterize);
				shader_set_palette(_ppal);
				draw_surface(_outSurf, 0, 0);
			surface_reset_shader();
			
			surface_set_shader(_outSurf);
				draw_surface(temp_surface[output_index], 0, 0);
			surface_reset_shader();
		}
		
		return _outData;
	}
}