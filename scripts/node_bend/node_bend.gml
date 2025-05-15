#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Bend", "Type > Toggle", "T", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[2].setValue((_n.inputs[2].getValue() + 1) % 2); });
		addHotkey("Node_Bend", "Axis > Toggle", "A", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[3].setValue((_n.inputs[3].getValue() + 1) % 2); });
	});
#endregion

function Node_Bend(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Bend";
	
	newInput(0, nodeValue_Surface("Surface In", self));
	
	newInput(1, nodeValue_Bool("Active", self, true));
		active_index = 1;
	
	newInput(2, nodeValue_Enum_Scroll("Type", self, 0, [ new scrollItem("Arc",  s_node_bend_type, 0),
		                                        		 new scrollItem("Wave", s_node_bend_type, 1) ]));
	
	newInput(3, nodeValue_Enum_Button("Axis", self,  0, [ "x", "y" ]));
	
	newInput(4, nodeValue_Float("Amount", self, 0.25))
		.setDisplay(VALUE_DISPLAY.slider, { range: [-1, 1, 0.01] });
	
	newInput(5, nodeValue_Float("Scale", self, 1));
	
	newInput(6, nodeValue_Float("Shift", self, 0.));
		
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 1, 
		["Surfaces", false], 0, 
		["Bend",     false], 2, 3, 4, 5, 6, 
	]
	
	mesh = [];
	
	attribute_surface_depth();
	attribute_interpolation();
	
	static step = function() {
		var _typ = getInputData(2);
		
		inputs[5].setVisible(_typ == 1);
		inputs[6].setVisible(_typ == 1);
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _surf = _data[0];
		var _typ  = _data[2];
		var _axs  = _data[3];
		var _amo  = _data[4];
		var _sca  = _data[5];
		var _shf  = _data[6];
		
		var _sw = surface_get_width_safe(_surf);
		var _sh = surface_get_height_safe(_surf);
		
		var _gw = min(32, floor(_sw / 2));
		var _gh = min(32, floor(_sh / 2));
		
		switch(_typ) { #region
			case 0 :
				if(_axs == 0) {
					_gw = min(64, floor(_sw / 2));
					_gh = min(16, floor(_sh / 2));
				} else {
					_gw = min(16, floor(_sw / 2));
					_gh = min(64, floor(_sh / 2));
				}
				break;
				
			case 1 :
				if(_axs == 0) {
					_gw = min(64, floor(_sw / 2));
					_gh = min(16, floor(_sh / 2));
				} else {
					_gw = min(16, floor(_sw / 2));
					_gh = min(64, floor(_sh / 2));
				}
				break;
				
		} #endregion
		
		var _dw  = _sw / _gw;
		var _dh  = _sh / _gh;
		
		mesh   = array_create(_gw * _gh * 2);
		var _i = 0;
		
		var _minx = undefined, _miny = undefined;
		var _maxx = undefined, _maxy = undefined;
		
		switch(_typ) {
			case 0 : #region
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
			
				for( var i = 0; i < _gw; i++ ) 
				for( var j = 0; j < _gh; j++ ) {
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
					
					_minx = _minx == undefined? min(x0, x1, x2, x3) : min(_minx, x0, x1, x2, x3);
					_miny = _miny == undefined? min(y0, y1, y2, y3) : min(_miny, y0, y1, y2, y3);
					_maxx = _maxx == undefined? max(x0, x1, x2, x3) : max(_maxx, x0, x1, x2, x3);
					_maxy = _maxy == undefined? max(y0, y1, y2, y3) : max(_maxy, y0, y1, y2, y3);
					
					mesh[_i] = [ [x0, y0, u0, v0], [x1, y1, u1, v1], [x2, y2, u2, v2] ]; _i++;
					mesh[_i] = [ [x1, y1, u1, v1], [x2, y2, u2, v2], [x3, y3, u3, v3] ]; _i++;
				} 
				#endregion
				break;
				
			case 1 : #region
				for( var i = 0; i < _gw; i++ ) 
				for( var j = 0; j < _gh; j++ ) {
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
					
					_minx = _minx == undefined? min(x0, x1, x2, x3) : min(_minx, x0, x1, x2, x3);
					_miny = _miny == undefined? min(y0, y1, y2, y3) : min(_miny, y0, y1, y2, y3);
					_maxx = _maxx == undefined? max(x0, x1, x2, x3) : max(_maxx, x0, x1, x2, x3);
					_maxy = _maxy == undefined? max(y0, y1, y2, y3) : max(_maxy, y0, y1, y2, y3);
					
					mesh[_i] = [ [x0, y0, u0, v0], [x1, y1, u1, v1], [x2, y2, u2, v2] ]; _i++;
					mesh[_i] = [ [x1, y1, u1, v1], [x2, y2, u2, v2], [x3, y3, u3, v3] ]; _i++;
				} 
				#endregion
				break;
		}
		
		if(_maxx == undefined) return _outSurf; 
		
		#region render
			for( var i = 0; i < array_length(mesh); i++ ) {
				var _t = mesh[i];
				
				for( var j = 0; j < 3; j++ ) {
					_t[j][0] -= _minx;
					_t[j][1] -= _miny;
				}
			}
		
			var _ww = _maxx - _minx;
			var _hh = _maxy - _miny;
		
			_outSurf = surface_verify(_outSurf, _ww, _hh);
			surface_set_shader(_outSurf, noone);
			
				draw_set_color(c_white);
				draw_set_alpha(1);
			
				var  n = array_length(mesh);
			
				gpu_set_texfilter(getAttribute("interpolate") > 1);
				for( var k = 0; k < n; k += 100 ) {
					draw_primitive_begin_texture(pr_trianglelist, surface_get_texture(_surf));
				
					var m = min(n, k + 100);
					for( var i = k; i < m; i++ ) {
						var _t = mesh[i];
				
						for( var j = 0; j < 3; j++ )
							draw_vertex_texture(_t[j][0], _t[j][1], _t[j][2], _t[j][3]);
					}
			
					draw_primitive_end();
				}
				gpu_set_texfilter(false);
			surface_reset_shader();
		#endregion
		
		return _outSurf;
	}
}