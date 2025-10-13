#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Bend", "Type > Toggle", "T", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[2].setValue((_n.inputs[2].getValue() + 1) % 2); });
		addHotkey("Node_Bend", "Axis > Toggle", "A", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[3].setValue((_n.inputs[3].getValue() + 1) % 2); });
	});
#endregion

function Node_Bend(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Bend";
	
	newActiveInput(1);
	
	////- =Surfaces
	newInput(0, nodeValue_Surface( "Surface In" ));
	
	////- =Surfaces
	newInput(2, nodeValue_EScroll( "Type",   0, __enum_array_gen(["Arc", "Wave"], s_node_bend_type) ));
	newInput(3, nodeValue_EButton( "Axis",   0, [ "X", "Y" ]     ));
	newInput(4, nodeValue_Slider(  "Amount", 0.25, [-1, 1, 0.01] ));
	newInput(5, nodeValue_Float(   "Scale",  1 ));
	newInput(6, nodeValue_Float(   "Shift",  0 ));
	// 7
		
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 1, 
		["Surfaces", false], 0, 
		["Bend",     false], 2, 3, 4, 5, 6, 
	];
	
	////- Nodes
	
	attribute_surface_depth();
	attribute_interpolation();
	
	vb       = undefined;
	vb_minx  = 0;
	vb_miny  = 0;
	vb_maxx  = 0;
	vb_maxy  = 0;
	vb_cache = "";
	
	static processData = function(_outSurf, _data, _array_index) {
		var _surf = _data[0];
		var _typ  = _data[2];
		var _axs  = _data[3];
		var _amo  = _data[4];
		var _sca  = _data[5];
		var _shf  = _data[6];
		
		inputs[5].setVisible(_typ == 1);
		inputs[6].setVisible(_typ == 1);
		
		var _sw = surface_get_width_safe(_surf);
		var _sh = surface_get_height_safe(_surf);
		var _gw, _gh;
		
		if(_axs == 0) {
			_gw = min(64, floor(_sw / 2));
			_gh = min(16, floor(_sh / 2));
			
		} else {
			_gw = min(16, floor(_sw / 2));
			_gh = min(64, floor(_sh / 2));
		}
		
		var _dw = _sw / _gw;
		var _dh = _sh / _gh;
		
		var _cach = $"{_sw}_{_sh}_{_typ}_{_axs}_{_amo}_{_sca}_{_shf}";
		
		if(vb == undefined || _cach != vb_cache) {
			var _minx =  infinity, _miny =  infinity;
			var _maxx = -infinity, _maxy = -infinity;
			
			vb_cache = _cach;
			
			if(vb) vertex_delete_buffer(vb);
			vb = vertex_create_buffer();
			vertex_begin(vb, VF_P3CT);
			
			switch(_typ) {
				case 0 : 
					if(_amo != 0) {
						var _t = abs(_amo) * 90;
						
						var _rx, _ry, _rr = 1 / (2 * dtan(_t));
						var _r  = sqrt(_rr * _rr + 1 / 4);
						
						var _as = _t;
						var _ae = _t;
						
						if(_axs == 0) {
							_rx = 0.5;
							if(_amo > 0) {
								_ry = 1 + _rr;
								_as = 90 + _t;
								_ae = 90 - _t;
							} else {
								_ry = -_rr;
								_as = -90 - _t;
								_ae = -90 + _t;
							}
							
						} else if(_axs == 1) {
							_ry = 0.5;
							if(_amo > 0) {
								_rx = -_rr;
								_as = 0 + _t;
								_ae = 0 - _t;
							} else {
								_rx = 1 + _rr;
								_as = 180 - _t;
								_ae = 180 + _t;
							}
							
						}
					}
					
					var i = 0;
					repeat(_gw) {
						var j = 0;
						repeat(_gh) {
							var _x0 = i * _dw;
							var _y0 = j * _dh;
							var _x1 = min((i + 1) * _dw, _sw);
							var _y1 = min((j + 1) * _dh, _sh);
							
							var x0 = _x0,  y0 = _y0;
							var x1 = _x1,  y1 = _y0;
							var x2 = _x0,  y2 = _y1;
							var x3 = _x1,  y3 = _y1;
							
							var u0 = x0 / _sw, v0 = y0 / _sh;
							var u1 = x1 / _sw, v1 = y1 / _sh;
							var u2 = x2 / _sw, v2 = y2 / _sh;
							var u3 = x3 / _sw, v3 = y3 / _sh;
							
							if(_amo != 0) {
								var uu0 = _axs == 0? u0 : v0;
								var uu1 = _axs == 0? u1 : v1;
								var uu2 = _axs == 0? u2 : v2;
								var uu3 = _axs == 0? u3 : v3;
								
								var vv0 = _axs == 0? v0 : (1 - u0);
								var vv1 = _axs == 0? v1 : (1 - u1);
								var vv2 = _axs == 0? v2 : (1 - u2);
								var vv3 = _axs == 0? v3 : (1 - u3);
								
								var _r0 = _amo > 0? _r + (1 - vv0) : _r + vv0;
								var _r1 = _amo > 0? _r + (1 - vv1) : _r + vv1;
								var _r2 = _amo > 0? _r + (1 - vv2) : _r + vv2;
								var _r3 = _amo > 0? _r + (1 - vv3) : _r + vv3;
								
								var _t0 = lerp(_as, _ae, uu0);
								var _t1 = lerp(_as, _ae, uu1);
								var _t2 = lerp(_as, _ae, uu2);
								var _t3 = lerp(_as, _ae, uu3);
								
								x0 = _rx + lengthdir_x(_r0, _t0) * _sw;
								y0 = _ry + lengthdir_y(_r0, _t0) * _sh;
								
								x1 = _rx + lengthdir_x(_r1, _t1) * _sw;
								y1 = _ry + lengthdir_y(_r1, _t1) * _sh;
								
								x2 = _rx + lengthdir_x(_r2, _t2) * _sw;
								y2 = _ry + lengthdir_y(_r2, _t2) * _sh;
								
								x3 = _rx + lengthdir_x(_r3, _t3) * _sw;
								y3 = _ry + lengthdir_y(_r3, _t3) * _sh;
							}
							
							_minx = min(_minx, x0, x1, x2, x3);
							_miny = min(_miny, y0, y1, y2, y3);
							_maxx = max(_maxx, x0, x1, x2, x3);
							_maxy = max(_maxy, y0, y1, y2, y3);
							
							vertex_position_3d(vb, x0, y0, 0); vertex_color(vb, c_white, 1); vertex_texcoord(vb, u0, v0);
							vertex_position_3d(vb, x1, y1, 0); vertex_color(vb, c_white, 1); vertex_texcoord(vb, u1, v1);
							vertex_position_3d(vb, x2, y2, 0); vertex_color(vb, c_white, 1); vertex_texcoord(vb, u2, v2);
							
							vertex_position_3d(vb, x1, y1, 0); vertex_color(vb, c_white, 1); vertex_texcoord(vb, u1, v1);
							vertex_position_3d(vb, x2, y2, 0); vertex_color(vb, c_white, 1); vertex_texcoord(vb, u2, v2);
							vertex_position_3d(vb, x3, y3, 0); vertex_color(vb, c_white, 1); vertex_texcoord(vb, u3, v3);
							j++;
						} 
						i++;
					}
					break;
					
				case 1 : 
					var i = 0;
					repeat(_gw) {
						var j = 0;
						repeat(_gh) {
							var _x0 = i * _dw;
							var _y0 = j * _dh;
							var _x1 = min((i + 1) * _dw, _sw);
							var _y1 = min((j + 1) * _dh, _sh);
							
							var x0 = _x0,  y0 = _y0;
							var x1 = _x1,  y1 = _y0;
							var x2 = _x0,  y2 = _y1;
							var x3 = _x1,  y3 = _y1;
							
							var u0 = x0 / _sw, v0 = y0 / _sh;
							var u1 = x1 / _sw, v1 = y1 / _sh;
							var u2 = x2 / _sw, v2 = y2 / _sh;
							var u3 = x3 / _sw, v3 = y3 / _sh;
							
							if(_axs == 0) {
								x0 += sin(v0 * pi * _sca - _shf * pi * 2) * _amo * _sh / 2;
								x1 += sin(v1 * pi * _sca - _shf * pi * 2) * _amo * _sh / 2;
								x2 += sin(v2 * pi * _sca - _shf * pi * 2) * _amo * _sh / 2;
								x3 += sin(v3 * pi * _sca - _shf * pi * 2) * _amo * _sh / 2;
							} else {
								y0 += sin(u0 * pi * _sca - _shf * pi * 2) * _amo * _sw / 2;
								y1 += sin(u1 * pi * _sca - _shf * pi * 2) * _amo * _sw / 2;
								y2 += sin(u2 * pi * _sca - _shf * pi * 2) * _amo * _sw / 2;
								y3 += sin(u3 * pi * _sca - _shf * pi * 2) * _amo * _sw / 2;
							}
							
							_minx = min(_minx, x0, x1, x2, x3);
							_miny = min(_miny, y0, y1, y2, y3);
							_maxx = max(_maxx, x0, x1, x2, x3);
							_maxy = max(_maxy, y0, y1, y2, y3);
							
							vertex_position_3d(vb, x0, y0, 0); vertex_color(vb, c_white, 1); vertex_texcoord(vb, u0, v0);
							vertex_position_3d(vb, x1, y1, 0); vertex_color(vb, c_white, 1); vertex_texcoord(vb, u1, v1);
							vertex_position_3d(vb, x2, y2, 0); vertex_color(vb, c_white, 1); vertex_texcoord(vb, u2, v2);
							
							vertex_position_3d(vb, x1, y1, 0); vertex_color(vb, c_white, 1); vertex_texcoord(vb, u1, v1);
							vertex_position_3d(vb, x2, y2, 0); vertex_color(vb, c_white, 1); vertex_texcoord(vb, u2, v2);
							vertex_position_3d(vb, x3, y3, 0); vertex_color(vb, c_white, 1); vertex_texcoord(vb, u3, v3);
							j++;
						} 
						i++;
					}
					break;
			}
			
			vertex_end(vb);
			
			vb_minx = _minx;
			vb_miny = _miny;
			vb_maxx = _maxx;
			vb_maxy = _maxy;
		}
		
		#region render
			var _ww = vb_maxx - vb_minx;
			var _hh = vb_maxy - vb_miny;
			_outSurf = surface_verify(_outSurf, _ww, _hh);
		
			surface_set_shader(_outSurf, noone);
			draw_set_color_alpha(c_white, 1);
			gpu_set_texfilter(getAttribute("interpolate") > 1);
			
			matrix_stack_clear();
			matrix_stack_push([
				 1, 0, 0, 0, 
				 0, 1, 0, 0, 
				 0, 0, 1, 0, 
				-vb_minx - _ww/2, -vb_miny - _hh/2, 0, 1, 
			]);
			
			camera_set_view_mat(camera_get_active(), matrix_stack_top());
			camera_apply(camera_get_active());
			vertex_submit(vb, pr_trianglelist, surface_get_texture(_surf));
			
			camera_set_view_mat(camera_get_active(), MATRIX_IDENTITY);
			matrix_stack_clear();
			
			gpu_set_texfilter(false);
			surface_reset_shader();
		#endregion
		
		return _outSurf;
	}
}