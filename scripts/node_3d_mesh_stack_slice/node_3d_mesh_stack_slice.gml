function Node_3D_Mesh_Stack_Slice(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Slice Stack";
	
	inputs[0] = nodeValue_D3Mesh("Mesh", self, noone)
		.setVisible(true, true);
	
	inputs[1] = nodeValue_Vec2("Output Dimension", self, [ 16, 16 ]);
	
	inputs[2] = nodeValue_Float("Scale", self, 1);
	
	inputs[3] = nodeValue_Int("Slices", self, 4);
	
	inputs[4] = nodeValue_Vec3("BBOX Padding", self, [ 0, 0, 0 ]);
		
	outputs[0] = nodeValue_Output("Outputs", self, VALUE_TYPE.surface, [])
		.setArrayDepth(1);
	
	mesh_data = new Inspector_Label("", f_code);
	
	input_display_list = [ 
		["Model",  false], 0, 4, mesh_data, 
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
	
	bbox_padding = [ 0, 0, 0 ];
	
	faces_minx = 99999; faces_maxx = -99999;
	faces_miny = 99999; faces_maxy = -99999;
	faces_minz = 99999; faces_maxz = -99999;
	
	faces_data = [];
	faces_amo  = 1;
	faces_cull = 0;
	
	point_size = 15;
	
	dimensions = [ 1, 1 ];
	slicesAmo  = 1;
	surfaces   = [];
	
	start_time = 0;
	end_time   = 0;
	
	insp1UpdateTooltip   = "Splice";
	insp1UpdateIcon      = [ THEME.sequence_control, 1, COLORS._main_value_positive ];
	
	static onInspector1Update = function(_fromValue = false) { 
		meshInit();
		spliceInit(true); 
	}
	
	static meshInit = function() {
		start_time = get_timer();
		
		var _mesh = getInputData(0);
		if(_mesh == params.mesh) return;
		
		params.mesh = _mesh;
		if(_mesh == noone) return;
		
		faces_minx = 99999; faces_maxx = -99999;
		faces_miny = 99999; faces_maxy = -99999;
		faces_minz = 99999; faces_maxz = -99999;
		
		var _vbs = _mesh.VB;
		var _fac = [];
		var _ind = 0;
		
		faces_cull = 0;
		
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
				
				// print($"{_matSurf} : {_surfBuff} [{buffer_get_size(_surfBuff)}]");
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
							if(_pnt[2] != _pnt[5] || _pnt[5] != _pnt[8]) {
								_pnt[9]  = c_white;
								
								if(_useSurf) {
									_uu = frac(_uu) < 0? 1 + frac(_uu) : frac(_uu);
									_vv = frac(_vv) < 0? 1 + frac(_vv) : frac(_vv);
									var _uvPx = round(_vv * (_surfH - 1)) * _surfW + round(_uu * (_surfW - 1));
									_pnt[9] = buffer_read_at(_surfBuff, _uvPx * 4, buffer_u32);
								}
								
								_pnt[10] = max(_pnt[0], _pnt[3], _pnt[6]);
								_pnt[11] = min(_pnt[0], _pnt[3], _pnt[6]);
								
								_pnt[12] = (_pnt[0] + _pnt[3] + _pnt[6]) / 3;
								_pnt[13] = (_pnt[1] + _pnt[4] + _pnt[7]) / 3;
								_pnt[14] = (_pnt[2] + _pnt[5] + _pnt[8]) / 3;
								
								// _pnt[15] = _pnt[3] - _pnt[0];
							 //   _pnt[16] = _pnt[4] - _pnt[1];
							 //   _pnt[17] = _pnt[5] - _pnt[2];
							    
							 //   _pnt[18] = _pnt[6] - _pnt[0];
							 //   _pnt[19] = _pnt[7] - _pnt[1];
							 //   _pnt[20] = _pnt[8] - _pnt[2];
								
								_fac[_ind++] = _pnt;
								
							} else 
								faces_cull++;
							
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
		
		var _surfs = outputs[0].getValue();
		    _surfs = array_verify(_surfs, slicesAmo);
		    
		for(var i = 0; i < slicesAmo; i++) {
		    _surfs[i] = surface_verify(_surfs[i], dimensions[0], dimensions[1]);
		    surface_clear(_surfs[i]);
		}
		
		surfaces = _surfs;
		outputs[0].setValue(_surfs);
		    
		splicing        = force || dimensions != params.dim || slicesAmo != params.slic;
		splice_progress = 0;
		splice_prog_tot = slicesAmo;
		
		params.dim  = dimensions;
		params.slic = slicesAmo;
	}
	
	static splice = function() {
		if(!splicing) return;
		
		preview_index = splice_progress;
		
		var _faces = faces_amo;
		var _ranx  = faces_maxx - faces_minx + bbox_padding[0] * 2;
		var _rany  = faces_maxy - faces_miny + bbox_padding[1] * 2;
		var _ranz  = faces_maxz - faces_minz + bbox_padding[2] * 2;
		
		var _stpx = _ranx / dimensions[0];
		var _stpy = _rany / dimensions[1];
		var _stpz = _ranz / slicesAmo;
		
		var _strx = faces_minx - bbox_padding[0] + _stpx / 2;
		var _stry = faces_miny - bbox_padding[1] + _stpy / 2 + _stpy * 0.1;
		var _strz = faces_minz - bbox_padding[2] + _stpz / 2;
		
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
				
				var _vx = 1;//_px;
				var _vy = 0;//_py;
				var _vz = 0;//_pz;
				
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
				    
				    // var rc2e_vecx = _vy * edge2z - _vz * edge2y;
				    // var rc2e_vecy = _vz * edge2x - _vx * edge2z;
				    // var rc2e_vecz = _vx * edge2y - _vy * edge2x;
				    // var det = edge1x * rc2e_vecx + edge1y * rc2e_vecy + edge1z * rc2e_vecz;
				    
				    var det = edge1z * edge2y - edge1y * edge2z;
				    
				    if (abs(det) < 0.0001) continue;
				    var inv_det = 1.0 / det;
				    
				    var s_vecx = _px - _f1x;
				    var s_vecy = _py - _f1y;
				    var s_vecz = _pz - _f1z;
				    
				    // var u = (s_vecx * rc2e_vecx + s_vecy * rc2e_vecy + s_vecz * rc2e_vecz) * inv_det;
				    
				    var u = (s_vecz * edge2y - s_vecy * edge2z) * inv_det;
				    if (u < 0.0 || u > 1.0) continue;
				    
				    var sc1e_vecx = s_vecy * edge1z - s_vecz * edge1y;
				    
				    // var v = (_vx * sc1e_vecx + _vy * sc1e_vecy + _vz * sc1e_vecz) * inv_det;
				    var v = sc1e_vecx * inv_det;
				    if (v < 0.0 || u + v > 1.0) continue;
				    
				    var sc1e_vecy = s_vecz * edge1x - s_vecx * edge1z;
				    var sc1e_vecz = s_vecx * edge1y - s_vecy * edge1x;
				    
				    var t = (edge2x * sc1e_vecx + edge2y * sc1e_vecy + edge2z * sc1e_vecz) * inv_det;
				    if(t <= 0) continue;
					
					_inSide = !_inSide;
					
					var _d = sqr(_px - faces_data[_f + 12]) + sqr(_py - faces_data[_f + 13]) + sqr(_pz - faces_data[_f + 14]);
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
				
				end_time   = get_timer();
				logNode($"Slice completed in {(end_time - start_time) / 1000}ms");
			}
		}
	}
	
	static step = function() {
		if(splicing) splice();
	}
	
	static update = function() {
		meshInit();
		
		bbox_padding = getInputData(4);
		var _ranx  = faces_maxx - faces_minx + bbox_padding[0] * 2;
		var _rany  = faces_maxy - faces_miny + bbox_padding[1] * 2;
		var _ranz  = faces_maxz - faces_minz + bbox_padding[2] * 2;
		
		mesh_data.text = $"Faces: {faces_amo} (culled {faces_cull})\nSize: [{_ranx}, {_rany}, {_ranz}]";
		
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		if(!splicing) return;
		
		var bbox = drawGetBbox(xx, yy, _s);
		var rr   = min(bbox.w - 16, bbox.h - 16) / 2;
		var ast  = current_time / 5;
		var prg  = (splice_progress + splice_pixel / (dimensions[0] * dimensions[1])) / splice_prog_tot;
		
		draw_set_color(COLORS._main_icon);
		draw_arc(bbox.xc, bbox.yc, rr, ast, ast + prg * 360, 4 * _s, 90);
	}
	
	static getPreviewBoundingBox = function() { return BBOX().fromWH(0, 0, dimensions[0], dimensions[1]); }
}