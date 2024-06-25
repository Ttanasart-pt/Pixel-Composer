function Node_3D_Mesh_Stack_Slice(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Slice Stack";
	
	inputs[| 0] = nodeValue("Mesh", self, JUNCTION_CONNECT.input, VALUE_TYPE.d3Mesh, noone)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Output Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 16, 16 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 2] = nodeValue("Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1);
	
	inputs[| 3] = nodeValue("Slices", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 4);
	
	outputs[| 0] = nodeValue("Outputs", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, [])
		.setArrayDepth(1);
	
	mesh_data = new Inspector_Label("", f_code);
	
	input_display_list = [ 
		["Model",  false], 0, mesh_data, 
		["Slices", false], 1, 3, 
	];
	
	insp1UpdateTooltip   = "Export";
	insp1UpdateIcon      = [ THEME.sequence_control, 1, COLORS._main_value_positive ];
	
	params = {
		mesh : noone,
		dim  : noone,
		sca  : noone,
		slic : noone,
	}
	
	splicing        = false;
	splice_progress = 0;
	splice_prog_tot = 0;
	splice_pixel    = 0;
	
	faces_minx = 99999; faces_maxx = -99999;
	faces_miny = 99999; faces_maxy = -99999;
	faces_minz = 99999; faces_maxz = -99999;
	
	faces_data = [];
	faces_amo  = 1;
	
	point_size = 14;
	
	dimensions = [ 1, 1 ];
	slicesAmo  = 1;
	surfaces   = [];
	
	insp1UpdateTooltip   = "Splice";
	insp1UpdateIcon      = [ THEME.sequence_control, 1, COLORS._main_value_positive ];
	
	static onInspector1Update = function(_fromValue = false) { 
		meshInit();
		spliceInit(true); 
	}
	
	static meshInit = function() {
		var _mesh = getInputData(0);
		if(_mesh == params.mesh) return;
		
		faces_minx = 99999; faces_maxx = -99999;
		faces_miny = 99999; faces_maxy = -99999;
		faces_minz = 99999; faces_maxz = -99999;
		
		var _vbs = _mesh.VB;
		var _fac = [];
		var _ind = 0;
		
		for (var i = 0, n = array_length(_vbs); i < n; i++) {
			var _vb = _vbs[i];
			
			var _buffer   = buffer_create_from_vertex_buffer(_vb, buffer_fixed, 1);
			var _buffer_s = buffer_get_size(_buffer);
			
			var _matInd   = array_safe_get_fast(_mesh.material_index, i, i);
			var _material = array_safe_get_fast(_mesh.materials, _matInd, noone);
			var _matSurf  = _material == noone? noone : _material.surface;
			var _useSurf  = surface_exists(_matSurf);
			if(_useSurf) {
				var _surfBuff = buffer_from_surface(_matSurf, false);
				var _surfW    = surface_get_width(_matSurf);
				var _surfH    = surface_get_height(_matSurf);
			}
				
			switch(_mesh.VF) {
				case global.VF_POS_NORM_TEX_COL : 
					var _format_s = global.VF_POS_NORM_TEX_COL_size;
					var _vertex_s = floor(_buffer_s / _format_s);
					buffer_to_start(_buffer);
					
					var _pnt = [];
					var _pid = 0;
					var _uu  = 0;
					var _vv  = 0;
					
					repeat(_vertex_s) {
						var _px = buffer_read(_buffer, buffer_f32);
						var _py = buffer_read(_buffer, buffer_f32);
						var _pz = buffer_read(_buffer, buffer_f32);
						
						var _nx = buffer_read(_buffer, buffer_f32);
						var _ny = buffer_read(_buffer, buffer_f32);
						var _nz = buffer_read(_buffer, buffer_f32);
						
						var _u  = buffer_read(_buffer, buffer_f32);
						var _v  = buffer_read(_buffer, buffer_f32);
						
						var _r  = buffer_read(_buffer, buffer_s8);
						var _g  = buffer_read(_buffer, buffer_s8);
						var _b  = buffer_read(_buffer, buffer_s8);
						var _a  = buffer_read(_buffer, buffer_s8);
						
						_pnt[_pid++] = _px;
						_pnt[_pid++] = _py;
						_pnt[_pid++] = _pz;
						
						_uu += _u / 3;
						_vv += _v / 3;
						
						faces_minx = min(faces_minx, _px);
						faces_maxx = max(faces_maxx, _px);
						faces_miny = min(faces_miny, _py);
						faces_maxy = max(faces_maxy, _py);
						faces_minz = min(faces_minz, _pz);
						faces_maxz = max(faces_maxz, _pz);
						
						if(_pid == 9) {
							_pnt[9]  = _useSurf? buffer_read_at(_surfBuff, (round(_vv * _surfH) * _surfW + round(_uu * _surfW)) * 4, buffer_u32) : c_white;
							_pnt[10] = max(_pnt[0], _pnt[3], _pnt[6]);
							
							_pnt[11] = (_pnt[0] + _pnt[3] + _pnt[6]) / 3;
							_pnt[12] = (_pnt[1] + _pnt[4] + _pnt[7]) / 3;
							_pnt[13] = (_pnt[2] + _pnt[5] + _pnt[8]) / 3;
							
							_fac[_ind++] = _pnt;
							_pnt = [];
							_pid = 0;
							
							_uu  = 0;
							_vv  = 0;
						}
					}
					break;
			}
			
			if(_useSurf) buffer_delete(_surfBuff);
		}
		
		array_sort(_fac, function(a1, a2) { return sign(a2[10] - a1[10]); });
		
		faces_amo  = _ind;
		for (var i = 0, n = _ind; i < n; i++) {
			for(var j = 0; j < point_size; j++) 
				faces_data[i * point_size + j] = _fac[i][j];
		}
		
		params.mesh = _mesh;
	}
	
	static spliceInit = function(force = false) {
		if(splicing) return;
		
		var _mesh  = getInputData(0);
		dimensions = getInputData(1);
		slicesAmo  = getInputData(3);
		
		if(_mesh == noone) return;
		if(!is_instanceof(_mesh, __3dObject)) return;
		
		var _surfs = outputs[| 0].getValue();
		    _surfs = array_verify(_surfs, slicesAmo);
		    
		for(var i = 0; i < slicesAmo; i++) {
		    _surfs[i] = surface_verify(_surfs[i], dimensions[0], dimensions[1]);
		    surface_clear(_surfs[i]);
		}
		
		surfaces = _surfs;
		outputs[| 0].setValue(_surfs);
		    
		splicing        = force || dimensions != params.dim || slicesAmo != params.slic;
		splice_progress = 0;
		splice_prog_tot = slicesAmo;
		
		params.dim  = dimensions;
		params.slic = slicesAmo;
	}
	
	static splice = function() {
		if(!splicing) return;
		
		var _faces = faces_amo;
		var _ranx  = faces_maxx - faces_minx;
		var _rany  = faces_maxy - faces_miny;
		var _ranz  = faces_maxz - faces_minz;
		
		mesh_data.text = $"Faces: {_faces}\nSize: [{_ranx}, {_rany}, {_ranz}]";
		
		var _stpx = _ranx / dimensions[0];
		var _stpy = _rany / dimensions[1];
		var _stpz = _ranz / slicesAmo;
		
		var _strx = faces_minx + _stpx / 2;
		var _stry = faces_miny + _stpy / 2;
		var _strz = faces_minz + _stpz / 2;
		
		var _f1x, _f1y, _f1z, _f2x, _f2y, _f2z, _f3x, _f3y, _f3z;
		var w = dimensions[0];
		var _pxAmo = dimensions[0] * dimensions[1];
		
		var _z    = splice_progress;
		var _surf = surfaces[_z];
		var _pz   = _strz + _z * _stpz;
		
		var _left = _pxAmo - splice_pixel;
		var _time = get_timer();
		
		surface_set_target(_surf);
			
			repeat(_left) {
				_x = splice_pixel % w;
				_y = floor(splice_pixel / w);
				splice_pixel++;
				
				var _px = _strx + _x * _stpx;
				var _py = _stry + _y * _stpy;
				
				var _inSide = false;
				var _fc     = c_white;
				var _dist   = 99999;
				
				var _f = 0, _fi = 0;
				repeat(_faces) {
					_f   = _fi;
					_fi += point_size;
					
					if(faces_data[_f + 10] < _px - 0.1) break;
					
					_f1x = faces_data[_f + 0]; _f2x = faces_data[_f + 3]; _f3x = faces_data[_f + 6];
					_f1y = faces_data[_f + 1]; _f2y = faces_data[_f + 4]; _f3y = faces_data[_f + 7];
					_f1z = faces_data[_f + 2]; _f2z = faces_data[_f + 5]; _f3z = faces_data[_f + 8];
					
					var edge1x = _f2x - _f1x;
				    var edge1y = _f2y - _f1y;
				    var edge1z = _f2z - _f1z;
				    
				    var edge2x = _f3x - _f1x;
				    var edge2y = _f3y - _f1y;
				    var edge2z = _f3z - _f1z;
				    
				    var pvecx = _py * edge2z - _pz * edge2y;
				    var pvecy = _pz * edge2x - _px * edge2z;
				    var pvecz = _px * edge2y - _py * edge2x;
				    
				    var det = edge1x * pvecx + edge1y * pvecy + edge1z * pvecz;
				    
				    if (abs(det) < 0.0001) continue;
				    
				    var inv_det = 1.0 / det;
				    
				    var tvecx = _px - _f1x;
				    var tvecy = _py - _f1y;
				    var tvecz = _pz - _f1z;
				    
				    var u = (tvecx * pvecx + tvecy * pvecy + tvecz * pvecz) * inv_det;
				    if (u < 0.0 || u > 1.0) continue;
				    
				    var qvecx = tvecy * edge1z - tvecz * edge1y;
				    var qvecy = tvecz * edge1x - tvecx * edge1z;
				    var qvecz = tvecx * edge1y - tvecy * edge1x;
				    
				    var v = (_px * qvecx + _py * qvecy + _pz * qvecz) * inv_det;
				    if (v < 0.0 || u + v > 1.0) continue;
				    
				    var t = (edge2x * qvecx + edge2y * qvecy + edge2z * qvecz) * inv_det;
				    if(t <= 0) continue;
					
					_inSide = !_inSide;
					
					var _d = sqr(_px - faces_data[_f + 11]) + sqr(_py - faces_data[_f + 12]) + sqr(_pz - faces_data[_f + 13]);
					if(_d < _dist) {
						_dist = _d;
						_fc   = faces_data[_f + 9];
					}
				}
				
				if(!_inSide) continue;
				draw_point_color(_x, _y, _fc);
				
				if(get_timer() - _time > 1_000_000 / 60)
					break;
			}
		surface_reset_target();
		
		if(splice_pixel >= _pxAmo) {
			splice_pixel = 0;
			splice_progress++;
			
			if(splice_progress >= splice_prog_tot) {
				splicing = false;
				triggerRender();
			}
		}
	}
	
	static step = function() {
		if(splicing) splice();
	}
	
	static update = function() {
		
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		if(splicing) {
			var cx = xx + w * _s / 2;
			var cy = yy + h * _s / 2;
			var rr = min(w - 32, h - 32) * _s / 2;
			
			draw_set_color(COLORS._main_icon);
			draw_arc(cx, cy, rr, current_time / 5, current_time / 5 + 90, 4 * _s, 90);
			return;
		}
	}
	
}