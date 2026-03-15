function Node_Atlas_Affector(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Atlas Affector";
	
	newInput( 0, nodeValue_Atlas("Atlas In")).setArrayDepth(1).setVisible(true, true);
	
	////- =Output
	newInput(25, nodeValue_Bool(    "Use Base Dimension", true     )).rejectArray();
	newInput(26, nodeValue_Dimension());
	
	////- =Influence
	newInput( 1, nodeValue_EScroll(  "Influence Shape", 0, [ "Area", "Linear Wipe", "Map", "Order", "Uniform" ]));
	newInput( 2, nodeValue_Area(     "Area", DEF_AREA_REF   )).setUnitSimple();
	newInput( 3, nodeValue_Vec2(     "Wipe Origin", [.5,.5] )).setUnitSimple();
	newInput( 4, nodeValue_Rotation( "Wipe Angle",   0      ));
	newInput(27, nodeValue_Float(    "Order Index",  0      ));
	newInput( 6, nodeValue_Surface(  "Influence Map"        ));
	newInput(32, nodeValue_Slider(   "Uniform Influence", 0 ));
	
	newInput( 5, nodeValue_Float(    "Falloff",      0      )).setCurvable(24, CURVE_DEF_01);
	
	////- =Position
	newInput( 7, nodeValue_Bool( "Effect Position", false ));
	newInput( 8, nodeValue_EButton( "Mode",         0, [ "Absolute", "Relative" ])).setInternalName("Position mode");
	newInput( 9, nodeValue_Vec2(    "Position",    [0,0]  ));
	newInput(28, nodeValue_Toggle(  "Axis",        0b11, [ "X", "Y" ] )).setInternalName("Position axis");
	
	////- =Rotation
	newInput(10, nodeValue_Bool(     "Set Rotation", false ));
	newInput(11, nodeValue_EButton(  "Mode",         0, [ "Absolute", "Relative" ])).setInternalName("Rotation mode");
	newInput(12, nodeValue_Rotation( "Rotation",     0 ));
	newInput(13, nodeValue_Bool(     "Recalculate Position", true ));
	
	////- =Scale
	newInput(14, nodeValue_Bool(     "Set Scale",  false ));
	newInput(15, nodeValue_EButton(  "Mode",       0, [ "Absolute", "Additive", "Multiplicative" ])).setInternalName("Scale mode");
	newInput(16, nodeValue_Vec2(     "Scale",     [1,1]  ));
	newInput(17, nodeValue_Anchor(   "Anchor"            ));
	newInput(29, nodeValue_Toggle(   "Axis",       0b11, [ "X", "Y" ] )).setInternalName("Scale axis");
	
	////- =Blend
	newInput(18, nodeValue_Bool(     "Set Blending", false ));
	newInput(19, nodeValue_EButton(  "Mode",         0, [ "Absolute", "Multiplicative" ])).setInternalName("Blend mode");
	newInput(20, nodeValue_Color(    "Blend",        ca_white ));
	
	////- =Alpha
	newInput(21, nodeValue_Bool(     "Set Alpha", false ));
	newInput(22, nodeValue_EButton(  "Mode",      0, [ "Absolute", "Additive", "Multiplicative" ])).setInternalName("Alpha mode");
	newInput(23, nodeValue_Float(    "Alpha",     1     ));
		
	////- =Interpolate
	newInput(30, nodeValue_Bool(     "Interpolate", false ));
	newInput(31, nodeValue_Atlas(    "Target Atlas"       )).setArrayDepth(1).setVisible(true, true);
	// input 33
	
	newOutput( 0, nodeValue_Output( "Atlas Out", VALUE_TYPE.atlas,   noone ));
	newOutput( 1, nodeValue_Output( "Rendered",  VALUE_TYPE.surface, noone ));
	
	input_display_list = [ 0, 
		[ "Output",      false,    ], 25, 26, 
		[ "Influence",   false     ],  1,  2,  3,  4, 27,  6, 32,  5, 24, 
		[ "Position",    false,  7 ],  8,  9, 28, 
		[ "Rotation",    false, 10 ], 11, 12, 13, 
		[ "Scale",       false, 14 ], 15, 16, 17, 29, 
		[ "Blend",       false, 18 ], 19, 20, 
		[ "Alpha",       false, 21 ], 22, 23, 
		[ "Interpolate", false, 30 ], 31, 
	];
	
	////- Nodes
	
	__p0 = [ 0, 0 ];
	__p1 = [ 0, 0 ];
	
	static getDimension = function(arr = 0) { 
		var _use_dim = getInputSingle(25, arr);
		if(!_use_dim) return getInputSingle(26, arr);
		
		var _atlas = getInputSingle( 0, arr);
		    _atlas = array_safe_get_fast(_atlas, 0);
		
		if(!is(_atlas, Atlas)) return [1,1];
		return surface_get_dimension(_atlas.oriSurf);
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _atlas = inputs[0].getValue();
		
		for( var i = 0, n = array_length(_atlas); i < n; i++ ) {
			var _a = _atlas[i];
			if(!is(_a, Atlas)) continue;
			
			var _ax = _x + _a.x * _s;
			var _ay = _y + _a.y * _s;
			var _aw = _a.w * _a.sx * _s;
			var _ah = _a.h * _a.sy * _s;
			var _xc = _ax + _aw / 2;
			var _yc = _ay + _ah / 2;
			
			draw_set_color(COLORS._main_icon);
			draw_rectangle(_ax, _ay, _ax + _aw, _ay + _ah, true);
			
			draw_set_color(COLORS._main_accent);
			draw_line(_xc - 8, _yc, _xc + 8, _yc);
			draw_line(_xc, _yc - 8, _xc, _yc + 8);
		}
		
		var _inf_shp  = getInputSingle(1);
		var _inf_fall = getInputSingle(5) * _s;
		
		switch(_inf_shp) {
			case 0 :
				InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
				var _inf_are  = getInputSingle(2);
				
				var cx = _x + _inf_are[0] * _s;
				var cy = _y + _inf_are[1] * _s;
				var cw = _inf_are[2] * _s;
				var ch = _inf_are[3] * _s;
				var cs = _inf_are[4];
				
				var x0 = cx - cw + _inf_fall;
				var x1 = cx + cw - _inf_fall;
				var y0 = cy - ch + _inf_fall;
				var y1 = cy + ch - _inf_fall;
				
				draw_set_color(COLORS._main_accent);
				draw_set_alpha(0.5);
				switch(cs) {
					case AREA_SHAPE.elipse :	draw_ellipse_dash(cx, cy, cw - _inf_fall, ch - _inf_fall); break;	
					case AREA_SHAPE.rectangle :	draw_rectangle_dashed(x0, y0, x1, y1);                     break;	
				}
				
				var x0 = cx - cw - _inf_fall;
				var x1 = cx + cw + _inf_fall;
				var y0 = cy - ch - _inf_fall;
				var y1 = cy + ch + _inf_fall;
				
				switch(cs) {
					case AREA_SHAPE.elipse :	draw_ellipse_dash(cx, cy, cw + _inf_fall, ch + _inf_fall); break;	
					case AREA_SHAPE.rectangle :	draw_rectangle_dashed(x0, y0, x1, y1);                     break;
				}
				draw_set_alpha(1);
				break;
				
			case 1 :
				var _inf_wori = getInputSingle(3);
				var _inf_wrot = getInputSingle(4);
				
				var _ox = _x + _inf_wori[0] * _s;
				var _oy = _y + _inf_wori[1] * _s;
				
				InputDrawOverlay(inputs[3].drawOverlay(w_hoverable, active,  _x,  _y, _s, _mx, _my));
				InputDrawOverlay(inputs[4].drawOverlay(w_hoverable, active, _ox, _oy, _s, _mx, _my));
				
				var _dx = lengthdir_x(9999, _inf_wrot);
				var _dy = lengthdir_y(9999, _inf_wrot);
				
				draw_set_color(COLORS._main_accent);
				draw_line(_ox - _dx, _oy - _dy, _ox + _dx, _oy + _dy);
				
				var _odx = lengthdir_x(_inf_fall, _inf_wrot + 90);
				var _ody = lengthdir_y(_inf_fall, _inf_wrot + 90);
				
				draw_set_alpha(.5);
				draw_line_dashed(_ox - _odx - _dx, _oy - _ody - _dy, _ox - _odx + _dx, _oy - _ody + _dy);
				draw_line_dashed(_ox + _odx - _dx, _oy + _ody - _dy, _ox + _odx + _dx, _oy + _ody + _dy);
				draw_set_alpha(1);
				break;
				
		}
		
	}
	
	static processData = function(_outData, _data, _array_index = 0) { 
		#region data
			var _atlas    = _data[ 0];
			
			var _inf_shp  = _data[ 1];
			var _inf_are  = _data[ 2];
			var _inf_wori = _data[ 3];
			var _inf_wrot = _data[ 4];
			var _inf_ind  = _data[27];
			var _inf_map  = _data[ 6];
			var _inf_lin  = _data[32];
			
			var _fall_dis = _data[ 5] * 2;
			var _fall_cur = _data[24];
			
			var _use_dim  = _data[25];
			var _cus_dim  = _data[26];
			
			inputs[26].setVisible(!_use_dim);
			
			inputs[ 2].setVisible(_inf_shp == 0);
			inputs[ 3].setVisible(_inf_shp == 1);
			inputs[ 4].setVisible(_inf_shp == 1);
			inputs[27].setVisible(_inf_shp == 3);
			inputs[ 5].setVisible(_inf_shp != 2 && _inf_shp != 4);
			inputs[ 6].setVisible(_inf_shp == 2, _inf_shp == 2);
			inputs[32].setVisible(_inf_shp == 4);
		#endregion
		
		#region data
			var pos_use = _data[ 7];
			var pos_mod = _data[ 8];
			var pos     = _data[ 9];
			var pos_axs = _data[28];
			
			var rot_use = _data[10];
			var rot_mod = _data[11];
			var rot_amo = _data[12];
			var rot_cal = _data[13];
			
			var sca_use = _data[14];
			var sca_mod = _data[15];
			var sca     = _data[16];
			var sca_anc = _data[17];
			var sca_axs = _data[29];
				
			var bln_use = _data[18];
			var bln_mod = _data[19];
			var bln     = _data[20];
			
			var alp_use = _data[21];
			var alp_mod = _data[22];
			var alp     = _data[23];
				
			var inp_use = _data[30];
			var inp_tar = _data[31];
		#endregion
		
		if(!is_array(inp_tar) || array_empty(inp_tar)) inp_use = false;
		if(_inf_shp == 2 && !is_surface(_inf_map)) return _outData;
		
		#region process
			var _atlas_len     = array_length(_atlas);
			var _atlas_tar_len = array_safe_length(inp_tar);
			
			var _atlas_res = array_create(_atlas_len);
			var _fall_samp = new Surface_sampler(_inf_map);
			
			var area_x = _inf_are[0];
			var area_y = _inf_are[1];
			var area_w = _inf_are[2];
			var area_h = _inf_are[3];
			var area_t = _inf_are[4];
			
			var area_x0 = area_x - area_w;
			var area_x1 = area_x + area_w;
			var area_y0 = area_y - area_h;
			var area_y1 = area_y + area_h;
			
			for( var i = 0, n = _atlas_len; i < n; i++ ) {
				var _a = _atlas[i];
				if(!is(_a, Atlas)) continue;
					
				_a = _a.clone();
				_atlas_res[i] = _a;
					
				////- =Influence
				
				var _inf = 0;
				var _w = _a.w;
				var _h = _a.h;
				var _x = _a.x + _w / 2;
				var _y = _a.y + _h / 2;
				
				switch(_inf_shp) {
					case 0 :
						var _in  = false;
						var _dst = 0;
						
						if(area_t == AREA_SHAPE.rectangle) {
							_in  =    point_in_rectangle(_x, _y, area_x0, area_y0, area_x1, area_y1)
							_dst = min(	distance_to_line(_x, _y, area_x0, area_y0, area_x1, area_y0), 
										distance_to_line(_x, _y, area_x0, area_y1, area_x1, area_y1), 
										distance_to_line(_x, _y, area_x0, area_y0, area_x0, area_y1), 
										distance_to_line(_x, _y, area_x1, area_y0, area_x1, area_y1));
										
						} else if(area_t == AREA_SHAPE.elipse) {
							var _dirr = point_direction(area_x, area_y, _x, _y);
							var _epx = area_x + lengthdir_x(area_w, _dirr);
							var _epy = area_y + lengthdir_y(area_h, _dirr);
							
							_in  = point_distance(area_x, area_y, _x, _y) < point_distance(area_x, area_y, _epx, _epy);
							_dst = point_distance(_x, _y, _epx, _epy);
						}
							
						var str = bool(_in);
						var inf = _in? 0.5 + _dst / _fall_dis : 0.5 - _dst / _fall_dis;
						str = eval_curve_x(_fall_cur, clamp(inf, 0., 1.));
						
						_inf = str;
						break;
					
					case 1 :
						var _dir = point_direction(_inf_wori[0], _inf_wori[1], _x, _y);
						var _dis = point_distance(_inf_wori[0], _inf_wori[1], _x, _y);
						var _ang = angle_difference(_dir, _inf_wrot);
						
						var _in  = _ang < 0;
						var _dst = abs(_dis * dsin(_ang));
						
						var str = bool(_in);
						var inf = _in? 0.5 + _dst / _fall_dis : 0.5 - _dst / _fall_dis;
						str = eval_curve_x(_fall_cur, clamp(inf, 0., 1.));
						
						_inf = str;
						break;
					
					case 2 :
						var _p = _fall_samp.getPixel(_x, _y);
						_inf = colorBrightness(_p);
						break;
						
					case 3 :
						var inf = abs(i - _inf_ind) / _fall_dis;
						str = eval_curve_x(_fall_cur, clamp(inf, 0., 1.));
						_inf = str;
						break;
						
					case 4 : 
						_inf = _inf_lin;
						break;
				}
				
				////- =Position
				
				if(pos_use) {
					switch(pos_mod) {
						case 0 : 
							if(pos_axs & 0b01) _a.x  = lerp(_a.x, pos[0], _inf); 
						    if(pos_axs & 0b10) _a.y  = lerp(_a.y, pos[1], _inf); 
						    break;
						         
						case 1 : 
							if(pos_axs & 0b01) _a.x += pos[0] * _inf; 
						    if(pos_axs & 0b10) _a.y += pos[1] * _inf;
						    break;
					}
				}
				
				////- =Rotation
				
				if(rot_use) {
					var _or = _a.rotation;
					var _nr = rot_mod? _or + rot_amo : rot_amo;
					    _nr = lerp_angle_direct(_or, _nr, _inf);
					_a.rotation = _nr;
					
					if(rot_cal) {
						var _sw = _w * _a.sx;
						var _sh = _h * _a.sy;
						
						var p0 = point_rotate(0, 0, _sw / 2, _sh / 2, -_or, __p0);
						var p1 = point_rotate(0, 0, _sw / 2, _sh / 2,  _nr, __p1);
						
						_a.x = _a.x - p0[1] + p1[0];
						_a.y = _a.y - p0[0] + p1[1];
					}
				}
				
				////- =Scale
				
				if(sca_use) {
					var _ox = _a.sx;
					var _oy = _a.sy;
					
					var _nx = _ox;
					var _ny = _oy;
					
					switch(sca_mod) {
						case 0 : _nx  = sca[0]; _ny  = sca[1]; break;
						case 1 : _nx += sca[0]; _ny += sca[1]; break;
						case 2 : _nx *= sca[0]; _ny *= sca[1]; break;
					}
					
					if(sca_axs & 0b01) {
						_a.sx = lerp(_ox, _nx, _inf);
						_a.x -= (_a.sx - _ox) * _w * sca_anc[0];
					}
					
					if(sca_axs & 0b10) {
						_a.sy = lerp(_oy, _ny, _inf);
						_a.y -= (_a.sy - _oy) * _h * sca_anc[1];
					}
				}
				
				////- =Blend
				
				if(bln_use) {
					var _oc = _a.blend;
					var _nc = _oc;
					
					switch(bln_mod) {
						case 0 : _nc = bln; break;
						case 1 : _nc = colorMultiply(_a.blend, bln); break;
					}
					
					_a.blend = merge_color(_oc, _nc, _inf);
				}
				
				////- =Alpha
				
				if(alp_use) {
					var _oa = _a.alpha;
					var _na = _oa;
					
					switch(alp_mod) {
						case 0 : _na  = alp; break;
						case 1 : _na += alp; break;
						case 2 : _na *= alp; break;
					}
					
					_a.alpha = lerp(_oa, _na, _inf);
				}
				
				////- =Interpolate
				
				if(inp_use) {
					var _atlas_target = inp_tar[i % _atlas_tar_len];
					
					_a.x = lerp(_a.x, _atlas_target.x, _inf);
					_a.y = lerp(_a.y, _atlas_target.y, _inf);
					
					_a.rotation = lerp(_a.rotation, _atlas_target.rotation, _inf);
					
					var _ox = _a.sx;
					var _oy = _a.sy;
					
					_a.sx = lerp(_a.sx, _atlas_target.sx, _inf);
					_a.sy = lerp(_a.sy, _atlas_target.sy, _inf);
					
					// if(_ox != _a.sx) _a.x -= (_a.sx - _ox) * _w * sca_anc[0];
					// if(_oy != _a.sy) _a.y -= (_a.sy - _oy) * _h * sca_anc[1];
				}
				
			}
			
			_outData[0] = _atlas_res;
		#endregion
		
		#region render
			var _outSurf = _outData[1];
			var _dim     = _cus_dim; 
			
			if(_use_dim) {
				var _a = array_safe_get_fast(_atlas, 0);
				if(is(_a, Atlas)) 
					_dim = surface_get_dimension(_a.oriSurf);
			} 
			
			_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
			surface_set_shader(_outSurf);
				for( var i = 0, n = array_length(_atlas_res); i < n; i++ ) {
					var _a = _atlas_res[i];
					if(!is(_a, Atlas)) continue;
					_a.draw(0, 0, 1);
				}
			surface_reset_shader();
			
			_outData[1] = _outSurf;
		#endregion
		
		return _outData; 
	}
	
	static getPreviewValues       = function() /*=>*/ {return outputs[1].getValue()};
	static getGraphPreviewSurface = function() /*=>*/ {return outputs[1].getValue()};
}