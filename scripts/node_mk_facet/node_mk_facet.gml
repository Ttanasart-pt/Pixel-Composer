function Node_MK_Facet(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK Facet";
	
	////- =Output
	newInput( 0, nodeValue_Dimension());
	newInput( 2, nodeValue_Surface( "Background" ));
	
	////- =Shape
	newInput(11, nodeValue_EScroll( "Shape", 0, [ new scrollItem("Rectangle", s_node_shape_type, 0), 
	                                              new scrollItem("Ellipse",   s_node_shape_type, 5),
	                                              "Path" ] ));
	newInput( 1, nodeValue_Area(     "Area", AREA_DEF_REF, false )).setUnitSimple();
	newInput(12, nodeValue_PathNode( "Path"           ));
	newInput(13, nodeValue_Int(      "Sample",  32    ));
	newInput(14, nodeValue_Bool(     "Reverse", false ));
	newInput( 5, nodeValue_Slider(   "Trim",    0     ));
	
	////- =Render
	newInput( 4, nodeValue_Palette(  "Base Color",   [ca_white] ));
	newInput( 8, nodeValue_Color(    "Ambient Color", ca_black  ));
	newInput( 6, nodeValue_Slider(   "Depth Blend",   1         ));
	newInput(15, nodeValue_Slider(   "Reflective",    0         ));
	
		////- =/Light
	newInput( 9, nodeValue_Color(    "Light Color",   ca_white ));
	newInput( 3, nodeValue_Rotation( "Direction",     135      ));
	newInput( 7, nodeValue_Float(    "Intensity",     1        ));
	newInput(10, nodeValue_Float(    "Contrast",      1        ));
	// 16
	
	newOutput( 0, nodeValue_Output( "Shaded",    VALUE_TYPE.surface, noone ));
	newOutput( 1, nodeValue_Output( "Depth",     VALUE_TYPE.surface, noone ));
	newOutput( 2, nodeValue_Output( "Cut Order", VALUE_TYPE.surface, noone ));
	
	static draw_ui_frame = function(_x, _y, _w, _h, _m, _hover) {  
		var _hv = point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h) && _hover;
		draw_sprite_stretched_ext(THEME.ui_panel, 0, _x, _y, _w, _h, COLORS._main_icon_dark,  1);
		draw_sprite_stretched_ext(THEME.ui_panel, 1, _x, _y, _w, _h, _hv? COLORS._main_icon : CDEF.main_dkgrey, 1);
		return _hv;
	}
	
	// repeat, angle, width, depth
	facet_builder = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		var _amo   = getInputAmount();
		var _hg    = ui(32);
		var _h     = 0;
		
		var _fx = _x;
		var _fy = _y;
		var _ffh = _hg - ui(8);
		
		for( var i = 0; i < _amo; i++ ) {
			var _ind = input_fix_len + i;
			var  jun = inputs[_ind];
			var _fc  = getInputData(_ind);
			var _hv  = _hover && point_in_rectangle(_m[0], _m[1], _fx, _fy, _fx + _w, _fy + _hg);
			
			var bx = _fx + ui(16);
			var by = _fy + _ffh / 2;
			
			var index = jun.is_anim;
			var cc    = index? COLORS._main_value_positive : c_white;
			var _hov  = _hover && point_in_circle(_m[0], _m[1], bx, by, _ffh / 2);
			draw_sprite_ui_uniform(THEME.animate_clock, index, bx, by, .75, cc, .8 + .2 * _hov);
			
			if(_hov && mouse_lpress(_focus))
				jun.setAnim(!jun.is_anim, true);
			
			var _ffx = _fx + ui(32);
			var _ffy = _fy;
			var _ffw = _w - ui(4)  - ui(32);
			var _fxs = _ffx;
			
			var _edt = jun.getEditWidget();
			_edt.setFocusHover(_focus, _hover);
			_edt.drawParam(new widgetParam(_ffx, _ffy, _ffw, _ffh, _fc, undefined, _m, facet_builder.rx, facet_builder.ry).setFont(f_p3));
			
			var _fww = _ffw / 4;
			var _hov = _hover && point_in_rectangle(_m[0], _m[1], _ffx, _ffy, _ffx + _fww, _ffy + _ffh);
			if(_hov) TOOLTIP = __txt("Pattern");
			draw_sprite_ui(THEME.prop_segment, 0, _ffx + _ffh / 2, _ffy + _ffh / 2, .75, .75, 0, COLORS._main_icon);
			_ffx += _fww;
			
			var _hov = _hover && point_in_rectangle(_m[0], _m[1], _ffx, _ffy, _ffx + _fww, _ffy + _ffh);
			if(_hov) TOOLTIP = __txt("Angle");
			
			shader_set(sh_widget_rotator);
				shader_set_c("color", COLORS._main_icon );
				shader_set_f("side",  _ffh              );
				shader_set_f("angle", degtorad(_fc[1])  );
			
				draw_sprite_stretched(s_fx_pixel, 0, _ffx, _ffy, _ffh, _ffh);
			shader_reset();
			_ffx += _fww;
			
			var _hov = _hover && point_in_rectangle(_m[0], _m[1], _ffx, _ffy, _ffx + _fww, _ffy + _ffh);
			if(_hov) TOOLTIP = __txt("Width");
			_ffx += _fww;
			
			var _hov = _hover && point_in_rectangle(_m[0], _m[1], _ffx, _ffy, _ffx + _fww, _ffy + _ffh);
			if(_hov) TOOLTIP = __txt("Depth");
			_ffx += _fww;
			
			_fy += _hg;
			_h  += _hg;
		}
		
		var bx = _fx;
		var by = _fy;
		var bs = ui(24);
		
		if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, _m, _hover, _focus, "", THEME.add_16, 0, COLORS._main_value_positive) == 2)
			createNewInput();
		
		bx += bs;
		_h += bs;
		
		if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, _m, _hover, _focus, "", THEME.minus_16, 0, COLORS._main_value_negative) == 2)
			deleteDynamicInput(_amo - 1);
		
		return _h;
	});
	
	input_display_list = [ s_MKFX, 
		[ "Output",        false ],  0,  2, 
		[ "Shape",         false ], 11,  1, 12, 13, 14,  5, 
		[ "Facet",         false ],  facet_builder, 
		[ "Render",        false ],  4,  8,  6, 15, 
			[ "/Lighting", false ],  9,  3,  7, 10, 
	];
	
	function createNewInput(index = array_length(inputs)) {
		newInput(index, nodeValue_Vec4( "Facet", [ 4,  0,  8, .5 ], { linkable: false, label: array_create(4,"") } ));
		return inputs[index];
	} 
	
	setDynamicInput(1, false);
	
	if(NODE_NEW_MANUAL) {
		newInput(input_fix_len+0, nodeValue_Vec4( "Facet", [ 4,  0,  8, .5 ], { linkable: false, label: array_create(4,"") } ));
		newInput(input_fix_len+1, nodeValue_Vec4( "Facet", [ 4, 45, 18,  1 ], { linkable: false, label: array_create(4,"") } ));
	}
	
	////- Nodes
	
	temp_surface = [ noone, noone, noone ];
	__bg_index   = 0;
	path_points  = [];
	__p = new __vec2P();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		InputDrawOverlay(inputs[ 1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
	}
	
	static cutFacet = function(i, cx, cy, ang, span, dep) {
		var dx = lengthdir_x(span + 2, ang);
		var dy = lengthdir_y(span + 2, ang);
		
		var ax = lengthdir_x(9999, ang - 90);
		var ay = lengthdir_y(9999, ang - 90);
		var cc = make_color_grey(1 - dep);
		
		var p0x = cx + ax;
		var p0y = cy + ay;
		
		var p1x = cx - ax;
		var p1y = cy - ay;
		
		var p2x = p0x + dx;
		var p2y = p0y + dy;
		
		var p3x = p1x + dx;
		var p3y = p1y + dy;
		
		surface_set_target(temp_surface[2]);
			DRAW_CLEAR
			draw_triangle_color(p0x, p0y, p1x, p1y, p2x, p2y, c_white, c_white, cc, false);
			draw_triangle_color(p1x, p1y, p2x, p2y, p3x, p3y, c_white, cc,      cc, false);
		surface_reset_target();
		
		surface_set_shader(temp_surface[__bg_index], sh_mk_facet_cut);
			shader_set_s("depthSurf", temp_surface[!__bg_index]);
			shader_set_s("cutSurf",   temp_surface[2]);
			shader_set_f("order",     i);
			shader_set_f("angle",     (ang + 360) % 360);
			
			draw_empty();
		surface_reset_shader();
		__bg_index = !__bg_index;
	}
	
	static processData = function(_outData, _data, _array_index = 0) { 
		#region data
			var _dim  = _data[ 0];
			var _bg   = _data[ 2];
			
			var _shap = _data[11];
			var _area = _data[ 1];
			var _path = _data[12];
			var _reso = _data[13];
			var _prev = _data[14];
			
			var _trim = _data[ 5];
			
			var _colr = _data[ 4];
			var _aCol = _data[ 8];
			var _dbln = _data[ 6];
			var _refl = _data[15];
			
			var _lCol = _data[ 9];
			var _lRot = _data[ 3];
			var _lInt = _data[ 7];
			var _cont = _data[10];
			
			inputs[ 1].setVisible(_shap != 2);
			inputs[12].setVisible(_shap == 2);
			inputs[13].setVisible(_shap == 2);
			inputs[14].setVisible(_shap == 2);
		#endregion
		
		var cx = _area[0];
		var cy = _area[1];
		var ww = _area[2];
		var hh = _area[3];
		
		var x0 = cx - ww;
		var y0 = cy - hh;
		var x1 = cx + ww;
		var y1 = cy + hh;
		
		for( var i = 0, n = array_length(_outData); i < n; i++ )
			_outData[i] = surface_verify(_outData[i], _dim[0], _dim[1]);
		
		for( var i = 0, n = array_length(temp_surface); i < n; i++ ) 
			temp_surface[i] = surface_verify(temp_surface[i], _dim[0], _dim[1], surface_rgba16float);
		
		if(_shap == 2) {
			if(!is_path(_path)) return _outData;
			
		    __tpath  = _path;
			__step   = 1 / _reso;
			path_points = array_verify_ext(path_points, _reso, function() /*=>*/ {return new __vec2P()});
			
			array_map_ext(path_points, function(p, i) /*=>*/ {return __tpath.getPointRatio(i * __step, 0, p)});
			var _triangles = polygon_triangulate(path_points, 0)[0];
		}
		
		surface_set_target(temp_surface[0]);
			DRAW_CLEAR
			BLEND_OVERRIDE
			
			draw_set_color(c_white);
			draw_set_circle_precision(32);
			switch(_shap) {
				case 0 : draw_rectangle(x0, y0, x1, y1, false); break;
				case 1 : draw_ellipse(x0, y0, x1, y1, false);   break;
				case 2 : 
					draw_primitive_begin(pr_trianglelist);
					for( var i = 0, n = array_length(_triangles); i < n; i++ ) {
						var _t = _triangles[i];
						var p0 = _t[0];
						var p1 = _t[1];
						var p2 = _t[2];
						
						draw_vertex(p0.x, p0.y);
						draw_vertex(p1.x, p1.y);
						draw_vertex(p2.x, p2.y);
					}
					draw_primitive_end();
					break;
			}
			
			BLEND_NORMAL
			draw_surface_safe(_bg);
			
		surface_reset_target();
		
		__bg_index = 1;
		
		var _amo = getInputAmount();
		
		for( var i = 0; i < _amo; i++ ) {
			var _ind = input_fix_len + i;
			var f    = _data[_ind];
			
			var ordr = i / _amo;
			var patt = f[0];
			var angg = f[1];
			var widd = f[2];
			var dept = f[3];
			
			for( var j = 0; j < patt; j++ ) {
				var _ang = (angg + j / patt * 360 + 360) % 360;
				
				switch(_shap) {
					case 0 :
						var dx = lengthdir_x(ww, _ang) * 1000;
						var dy = lengthdir_y(hh, _ang) * 1000;
						
						           var p = segment_intersect(cx, cy, cx + dx, cy + dy, x0, y0, x1, y0);
						if(p == false) p = segment_intersect(cx, cy, cx + dx, cy + dy, x0, y1, x1, y1);
						if(p == false) p = segment_intersect(cx, cy, cx + dx, cy + dy, x0, y0, x0, y1);
						if(p == false) p = segment_intersect(cx, cy, cx + dx, cy + dy, x1, y0, x1, y1);
						break;
						
					case 1 :
						p[0] = cx + lengthdir_x(ww, _ang);
						p[1] = cy + lengthdir_y(hh, _ang);
						break;
						
					case 2 : 
						var _rat = j / patt;
						var _prt = frac(_rat + angg / 360 / 2);
						var _pos = _path.getPointRatio(_prt, 0, __p);
						p[0] = _pos.x;
						p[1] = _pos.y;
						
						var _pos = _path.getPointRatio(frac(_prt - .01), 0, __p);
						var dx0 = _pos.x;
						var dy0 = _pos.y;
						
						var _pos = _path.getPointRatio(frac(_prt + .01), 0, __p);
						var dx1 = _pos.x;
						var dy1 = _pos.y;
						
						_ang = point_direction(dx0, dy0, dx1, dy1) + (_prev? -90 : 90);
						break;
				}
				
				if(p == false) continue;
				var px = p[0] + lengthdir_x(widd, _ang + 180);
				var py = p[1] + lengthdir_y(widd, _ang + 180);
				cutFacet(ordr, px, py, _ang, widd, dept);
			}
		}
		
		surface_set_shader(_outData, sh_mk_facet_render);
			shader_set_f( "depthBlend",   _dbln );
			shader_set_f( "reflective",   _refl );
			
			shader_set_c( "ambientColor", _aCol );
			shader_set_f( "lightAngle",   _lRot );
			shader_set_c( "lightColor",   _lCol );
			
			shader_set_f( "intensity",    _lInt );
			shader_set_f( "contrast",     _cont );
			shader_set_f( "trim",         _trim );
			shader_set_f( "maxDepth",     _amo  );
			
			shader_set_palette( _colr );
			
			draw_surface(temp_surface[!__bg_index], 0, 0);
		surface_reset_shader();
		
		return _outData; 
	}
}