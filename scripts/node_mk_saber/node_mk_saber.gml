function Node_MK_Saber(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK Saber";
	
	inputs[| 0] = nodeValue_Dimension(self);
	
	inputs[| 1] = nodeValue("Point 1", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 2] = nodeValue("Point 2", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 16, 16 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 3] = nodeValue("Thickness", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 2)
	
	inputs[| 4] = nodeValue("Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.gradient, new gradientObject(cola(c_white)))
	
	inputs[| 5] = nodeValue("Trace", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0);
	
	inputs[| 6] = nodeValue("Fix length", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 7] = nodeValue("Gradient step", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1);
	
	inputs[| 8] = nodeValue("Glow intensity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 9] = nodeValue("Glow radius", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0);
	
	inputs[| 10] = nodeValue_Surface("Trace texture", self)
		.setVisible(true, true);
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 0, 
		["Saber",		false], 1, 2, 3, 6, 
		["Render",		false], 4, 7, 5, 8, 9, 10,
	];
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	prev_points  = noone;
	fixed_length = 0;
	
	temp_surface = [ surface_create(1, 1), surface_create(1, 1), surface_create(1, 1) ];
	surface_blur_init();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		var _p1 = getSingleValue(1);
		var _p2 = getSingleValue(2);
		
		var _p1x = _x + _p1[0] * _s;
		var _p1y = _y + _p1[1] * _s;
		var _p2x = _x + _p2[0] * _s;
		var _p2y = _y + _p2[1] * _s;
		
		draw_set_color(COLORS._main_accent);
		draw_line(_p1x, _p1y, _p2x, _p2y);
		var _hov = false;
		var  hv  = inputs[| 1].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); active &= !hv; _hov |= hv;
		var  hv  = inputs[| 2].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); active &= !hv; _hov |= hv;
		
		return _hov;
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _dim  = _data[0];
		var _pnt1 = _data[1];
		var _pnt2 = _data[2];
		var _thck = _data[3];
		var _colr = _data[4];
		var _trac = _data[5];
		var _fixl = _data[6];
		var _grds = max(1, _data[7]);
		var _gint = _data[8];
		var _grad = _data[9];
		var _trcTex = _data[10];
		
		draw_set_circle_precision(32);
		
		var _p1x = round(_pnt1[0] - 1);
		var _p1y = round(_pnt1[1] - 1);
		var _p2x = round(_pnt2[0] - 1);
		var _p2y = round(_pnt2[1] - 1);
		var _dir = point_direction(_p1x, _p1y, _p2x, _p2y);
		var _cur;
		
		if(prev_points == noone || IS_FIRST_FRAME) prev_points = [];
		if(!is_array(array_safe_get_fast(prev_points, _array_index)))
			prev_points[_array_index] = [];
		
		if(_fixl) { #region
			var _prevArr = prev_points[_array_index];
			
			if(IS_FIRST_FRAME)
				fixed_length = point_distance(_pnt1[0], _pnt1[1], _pnt2[0], _pnt2[1]);
			else if(!array_empty(_prevArr)){
				var _prev = _prevArr[array_length(_prevArr) - 1];
				
				var _pr1x = _prev[2][0];
				var _pr1y = _prev[2][1];
				var _pr2x = _prev[3][0];
				var _pr2y = _prev[3][1];
				
				var _dsp = point_distance(_pr1x, _pr1y, _pr2x, _pr2y);
				var _dsc = point_distance(_p1x, _p1y, _p2x, _p2y);
				var _ds1 = point_distance(_p1x, _p1y, _pr1x, _pr1y);
				var _ds2 = point_distance(_p2x, _p2y, _pr2x, _pr2y);
				
				var _ds_off = _dsp - _dsc;
				var _ds_of1 = _ds_off * (_ds1 / (_ds1 + _ds2));
				var _ds_of2 = _ds_off * (_ds2 / (_ds1 + _ds2));
				
				var __p2x = _p2x + lengthdir_x(_ds_of2, _dir);
				var __p2y = _p2y + lengthdir_y(_ds_of2, _dir);
				var __p1x = _p1x - lengthdir_x(_ds_of1, _dir);
				var __p1y = _p1y - lengthdir_y(_ds_of1, _dir);
				
				_p1x = __p1x;
				_p1y = __p1y;
				_p2x = __p2x;
				_p2y = __p2y;
			}
		} #endregion
		
		_cur = [[ _p1x, _p1y ], [ _p2x, _p2y ], [ _p1x, _p1y ], [ _p2x, _p2y ]];
		if(_thck) {
			_cur = [
				[ _p1x - lengthdir_x(_thck / 2, _dir), _p1y - lengthdir_y(_thck / 2, _dir) ], 
				[ _p2x + lengthdir_x(_thck / 2, _dir), _p2y + lengthdir_y(_thck / 2, _dir) ],
				[ _p1x, _p1y ], [ _p2x, _p2y ]
			];
		}
		
		for( var i = 0; i < array_length(temp_surface); i++ )
			temp_surface[i] = surface_verify(temp_surface[i], _dim[0], _dim[1]);
		
		surface_set_target(temp_surface[0]);
			DRAW_CLEAR
			
			draw_set_color(_colr.eval(1));
			if(_trac > 0 && CURRENT_FRAME > 0 && prev_points != noone) { #region Trace
				var _prevArr = prev_points[_array_index];
				var _inds    = max(0, array_length(_prevArr) - _trac);
				var useTex   = is_surface(_trcTex);
				
				if(useTex) draw_primitive_begin_texture(pr_trianglelist, surface_get_texture(_trcTex));
				else       draw_primitive_begin(pr_trianglelist);
				
				for( var i = _inds, n = array_length(_prevArr); i < n; i++ ) {
					var _prev = _prevArr[i];
					var _curr = i + 1 == n? _cur : _prevArr[i + 1];
					
					var _pr1x = ceil(_prev[0][0]);
					var _pr1y = ceil(_prev[0][1]);
					var _pr2x = ceil(_prev[1][0]);
					var _pr2y = ceil(_prev[1][1]);
					
					var _pp1x = ceil(_curr[0][0]);
					var _pp1y = ceil(_curr[0][1]);
					var _pp2x = ceil(_curr[1][0]);
					var _pp2y = ceil(_curr[1][1]);
					
					var _inx = false;// line_intersect(_pr1x, _pr1y, _pr2x, _pr2y, _pp1x, _pp1y, _pp2x, _pp2y);
					
					if(_inx == false) {
						if(useTex) {
							var _v0 = (i - _inds + 0) / (n - _inds);
							var _v1 = (i - _inds + 1) / (n - _inds);
						
							draw_vertex_texture(_pr1x, _pr1y, 0, _v0);
							draw_vertex_texture(_pr2x, _pr2y, 1, _v0);
							draw_vertex_texture(_pp1x, _pp1y, 0, _v1);
											
							draw_vertex_texture(_pr2x, _pr2y, 1, _v0);
							draw_vertex_texture(_pp1x, _pp1y, 0, _v1);
							draw_vertex_texture(_pp2x, _pp2y, 1, _v1);
						} else {
							draw_vertex(_pr1x, _pr1y);
							draw_vertex(_pr2x, _pr2y);
							draw_vertex(_pp1x, _pp1y);
										
							draw_vertex(_pr2x, _pr2y);
							draw_vertex(_pp1x, _pp1y);
							draw_vertex(_pp2x, _pp2y);
						}
					} else { #region circular // disabled
						var _side = point_distance(_inx[0], _inx[1], _pr1x, _pr1y) < point_distance(_inx[0], _inx[1], _pr2x, _pr2y);
						var _stp  = 8;
						
						if(_side == 1) {
							var _d0 = point_distance( _pr1x, _pr1y, _pr2x, _pr2y);
							var _d1 = point_distance( _pp1x, _pp1y, _pp2x, _pp2y);
							var _a0 = point_direction(_pr1x, _pr1y, _pr2x, _pr2y);
							var _a1 = point_direction(_pp1x, _pp1y, _pp2x, _pp2y);
							var _i0 = point_distance(_inx[0], _inx[1], _pr1x, _pr1y);
							var _i1 = point_distance(_inx[0], _inx[1], _pp1x, _pp1y);
							
						} else {
							var _d0 = point_distance( _pr2x, _pr2y, _pr1x, _pr1y);
							var _d1 = point_distance( _pp2x, _pp2y, _pp1x, _pp1y);
							var _a0 = point_direction(_pr2x, _pr2y, _pr1x, _pr1y);
							var _a1 = point_direction(_pp2x, _pp2y, _pp1x, _pp1y);
							var _i0 = point_distance(_inx[0], _inx[1], _pr2x, _pr2y);
							var _i1 = point_distance(_inx[0], _inx[1], _pp2x, _pp2y);
						}
						
						var _od, _oa, _oi;
						var _nd, _na, _ni;
						var __r1x, __r1y, __r2x, __r2y;
						var __p1x, __p1y, __p2x, __p2y;
						
						for( var j = 0; j <= _stp; j++ ) {
							_nd = lerp(_d0, _d1, j / _stp);
							_na = lerp_float_angle(_a0, _a1, j / _stp);
							_ni = lerp(_i0, _i1, j / _stp);
							
							if(j) {
								__r1x = _inx[0] + lengthdir_x(_oi, _oa);
								__r1y = _inx[1] + lengthdir_y(_oi, _oa);
								__r2x = _inx[0] + lengthdir_x(_oi + _od, _oa);
								__r2y = _inx[1] + lengthdir_y(_oi + _od, _oa);
								
								__p1x = _inx[0] + lengthdir_x(_ni, _na);
								__p1y = _inx[1] + lengthdir_y(_ni, _na);
								__p2x = _inx[0] + lengthdir_x(_ni + _nd, _na);
								__p2y = _inx[1] + lengthdir_y(_ni + _nd, _na);
								
								draw_vertex(ceil(__r1x), ceil(__r1y));
								draw_vertex(ceil(__r2x), ceil(__r2y));
								draw_vertex(ceil(__p1x), ceil(__p1y));
						
								draw_vertex(ceil(__r2x), ceil(__r2y));
								draw_vertex(ceil(__p1x), ceil(__p1y));
								draw_vertex(ceil(__p2x), ceil(__p2y));
							}
							
							_od = _nd;
							_oa = _na;
							_oi = _ni;
						}
					} #endregion
				}
				
				draw_primitive_end();
			} #endregion
			
			if(_thck == 1) {
				draw_set_color(_colr.eval(1));
				draw_line(_p1x, _p1y, _p2x, _p2y);
			} else {
				for( var i = _thck; i > 0; i -= _grds ) {
					draw_set_color(_colr.eval((i - 1) / (_thck - 1)));
					draw_line_round(_p1x, _p1y, _p2x, _p2y, i);
				}
			}
		surface_reset_target();
		
		if(_gint > 0) { #region
			surface_set_target(temp_surface[1]);
				draw_clear(c_black);
				draw_surface_safe(temp_surface[0]);
			surface_reset_target();	
		
			temp_surface[2] = surface_apply_gaussian(temp_surface[1], _grad, false, 0, 1);
		} #endregion
		
		surface_set_target(_outSurf); #region
			DRAW_CLEAR
			
			if(_gint > 0) {
				BLEND_OVERRIDE
				shader_set(sh_mk_saber_glow);
					shader_set_color("color", _colr.eval(1));
					shader_set_f("intensity", _gint);
					draw_surface_safe(temp_surface[2]);
				shader_reset();
			}
			
			BLEND_ALPHA_MULP
			draw_surface_safe(temp_surface[0]);
			
			BLEND_NORMAL
		surface_reset_target(); #endregion
		
		array_push(prev_points[_array_index], _cur);
		
		return _outSurf;
	}
}