function Node_Flood_Fill(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Flood Fill";
	
	newActiveInput(3);
	
	////- =Surfaces
	newInput(0, nodeValue_Surface( "Surface In" ));
	newInput(1, nodeValue_Surface( "Mask"       ));
	newInput(2, nodeValue_Slider(  "Mix",     1 ));
	__init_mask_modifier(1, 8); // inputs 8, 9
	
	////- =Fill
	newInput(17, nodeValue_Toggle(  "Channel",     0b1111, { data: array_create(4, THEME.inspector_channel) }));
	newInput(18, nodeValue_EScroll( "Fill Mode",   0, [ "Point", "Path", "Mask" ] ));
	newInput( 4, nodeValue_Vec2(    "Position",   [.5,.5]   )).setHotkey("G").setUnitSimple();
	newInput(20, nodeValue_Path(    "Path",                 ));
	newInput(23, nodeValue_Int(     "Resolution",  16       ));
	newInput(21, nodeValue_Surface( "Fill Mask",            ));
	newInput(22, nodeValue_Color(   "Ref. Color",  ca_white ))
	newInput( 6, nodeValue_Slider(  "Threshold",   .1       ));
	
	////- =Algorithm
	newInput(12, nodeValue_EScroll( "Algorithm",   0, [ "Linear Sweep", "Diffusion" ]    ));
	newInput( 7, nodeValue_Bool(    "Diagonal",    false   ));
	newInput(11, nodeValue_Int(     "Iteration",   8       ));
	
	////- =Rendering
	newInput( 5, nodeValue_Color(   "Color",      ca_black )).setHotkeyAuto("C");
	newInput(10, nodeValue_EScroll( "Blend Mode",   0, [ "Override", "Multiply" ] ));
	newInput(19, nodeValue_Bool(    "Invert",     false    ));
	
		////- =/Background
	newInput(15, nodeValue_Bool(    "Fill Background",  false            ));
	newInput(16, nodeValue_Color(   "Background Color", cola(c_black, 0) ));
	
		////- =/Gradient
	newInput(13, nodeValue_Bool(    "Fill Gradient",    false            ));
	newInput(14, nodeValue_Gradient("Gradient",         gra_black_white  ));
	// 24
	
	newOutput( 0, nodeValue_Output( "Surface Out", VALUE_TYPE.surface, noone ));
	newOutput( 1, nodeValue_Output( "Fill Mask",   VALUE_TYPE.surface, noone ));
	
	input_display_list = [  3,
		[ "Surfaces",   true ],  0,  1,  2,  8,  9, 
		[ "Fill",      false ], 17, 18,  4, 20, 23, 21, 22,  6, 
		[ "Algorithm", false ], 12,  7, 11, 
		
		[ "Rendering", false ],  5, 10, 19, 
			[ "/Background", false, 15 ], 16, 
			[ "/Gradient",   false, 13 ], 14, 
	];
	
	////- Node
	
	temp_surface = [ noone, noone ];
	
	attribute_surface_depth();
	
	attributes.fill_iteration = -1;
	array_push(attributeEditors, "Algorithm");
	array_push(attributeEditors, Node_Attribute("Fill iteration", function() /*=>*/ {return attributes.fill_iteration}, function() /*=>*/ {return textBox_Number(function(v) /*=>*/ {return setAttribute("fill_iteration", v, true)} )}));
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		drawOverlayInput(inputs[4].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
		return w_hovering;
	}
	
	static processData = function(_outData, _data, _array_index) {
		#region data
			var inSurf = _data[0];
			if(!is_surface(inSurf)) return _outData;
			
			var _chan  = _data[17];
			var _mode  = _data[18];
			var _pos   = _data[ 4];
			var _path  = _data[20];
			var _reso  = _data[23];
			var _mask  = _data[21];
			var _cref  = _data[22];
			var _thr   = _data[ 6];
			
			var _algo  = _data[12];
			var _dia   = _data[ 7];
			var _itr   = _data[11];
			
			var _col   = _data[ 5];
			var _bnd   = _data[10];
			var _invt  = _data[19];
			
			var _bgFil = _data[15];
			var _bgCol = _data[16];
			
			var _ugrad = _data[13];
			var _grad  = _data[14];
			
			inputs[ 4].setVisible(_mode == 0);
			
			inputs[20].setVisible(_mode == 1, _mode == 1);
			inputs[23].setVisible(_mode == 1);
			
			inputs[21].setVisible(_mode == 2, _mode == 2);
			inputs[22].setVisible(_mode != 0);
		#endregion
		
		var  sw   = surface_get_width_safe(inSurf);
		var  sh   = surface_get_height_safe(inSurf);
		
		for( var i = 0, n = array_length(temp_surface); i < n; i++ )
			temp_surface[i] = surface_verify(temp_surface[i], sw, sh, attrDepth());
		
		surface_set_target(temp_surface[0]);
			DRAW_CLEAR
			
			shader_set(sh_flood_fill_thres);
			shader_set_2( "dimension", [sw,sh]  );
			shader_set_i( "mode",       _mode   );
			shader_set_2( "position",   _pos    );
			shader_set_c( "refColor",   _cref   );
			
			shader_set_i( "channel",    _chan   );
			shader_set_f( "thres",      _thr    );
			
			BLEND_OVERRIDE
			draw_surface_safe(inSurf);
			BLEND_NORMAL
			shader_reset();
			
			switch(_mode) {
				case 0 : 
					draw_set_color(#FF0000);
					draw_point(_pos[0] - 1, _pos[1] - 1); 
					break;
				
				case 1 : 
					draw_set_color(#FF0000);
					if(is_path(_path)) {
						var __p   = new __vec2P();
						var _reso = 32;
						
						var ox, oy, nx, ny;
						
						for( var i = 0; i <= _reso; i++ ) {
							var _t = i / _reso;
							__p = _path.getPointRatio(_t, 0, __p);
							
							nx = __p.x;
							ny = __p.y;
							
							if(i) draw_line(ox, oy, nx, ny);
							
							ox = nx;
							oy = ny;
						}
					}
					break;
					
				case 2 : 
					shader_set(sh_flood_fill_mask_thres);
						draw_surface_safe(_mask);
					shader_reset();
					break;
			}
			
		surface_reset_target();
		
		var ind   = 0;
		var itr   = 0;
		var itrSt = 1 / max(1, _itr - 1); 
		
		repeat(_itr) {
			ind = !ind;
			surface_set_shader(temp_surface[ind], _algo? sh_flood_fill_diff : sh_flood_fill_it);
				shader_set_f( "dimension", [sw,sh] );
				shader_set_i( "diagonal",   _dia   );
				shader_set_f( "iteration",  itr * itrSt);
				
				draw_surface_safe(temp_surface[!ind]);
			surface_reset_shader();
			itr++;
		}
		
		var _outSurf = surface_verify(_outData[0], sw, sh);
		var _outMask = surface_verify(_outData[1], sw, sh);
		
		surface_set_shader(_outSurf, sh_flood_fill_replace);
			shader_set_c( "color",  _col  );
			shader_set_s( "mask",   temp_surface[ind]);
			shader_set_i( "blend",  _bnd  );
			shader_set_i( "invert", _invt );
			
			shader_set_i( "useGrad", _ugrad );
			shader_set_gradient(     _grad  );
			
			shader_set_i( "fillBG",  _bgFil );
			shader_set_c( "bgColor", _bgCol );
			
			draw_surface(inSurf, 0, 0);
		surface_reset_shader();
		
		surface_set_shader(_outMask, sh_flood_fill_render_mask);
			shader_set_i( "invert", _invt );
			
			draw_surface(temp_surface[ind], 0, 0);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply_input(_data[0], _outSurf, _data[1], _data[2], inputs[1]);
		
		return _outData;
	}
}
