function Node_3D_Mesh_Export(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Mesh Export";
	
	newInput(0, nodeValue_D3Mesh("Mesh", self, noone))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Path("Paths",   self, ""))
		.setDisplay(VALUE_DISPLAY.path_save, { filter: "Obj (.obj)|*.obj" })
		.setVisible(true);
	
	newInput(2, nodeValue_Bool("Export Texture", self, true));
	
	newInput(3, nodeValue_Bool("Invert UV", self, false));
	
	input_display_list = [ 0, 
		["Export", false], 1, 2, 3, 
	];
	
	setTrigger(1, "Export", [ THEME.sequence_control, 1, COLORS._main_value_positive ], function() /*=>*/ {return export()});
	
	static export = function() {
		var _mesh = getInputData(0);
		var _path = getInputData(1);
		var _mat  = getInputData(2);
		var _invv = getInputData(3);
		
		if(_mesh == noone) return;
		if(!is_instanceof(_mesh, __3dObject)) return;
		
		var _vbs = _mesh.VB;
		
		var _mtlPath = filename_dir(_path) + "/" + filename_name_only(_path) + ".mtl";
		var _mtlName = filename_name(_mtlPath);
		var _mtl     =  "# Pixel Composer\n";
		var _obj     =  "# Pixel Composer\n";
		if(_mat) _obj += $"mtllib {_mtlName}\n";
		    
		for (var i = 0, n = array_length(_vbs); i < n; i++) {
			var _vb = _vbs[i];
			
			var _buffer   = buffer_create_from_vertex_buffer(_vb, buffer_fixed, 1);
			var _buffer_s = buffer_get_size(_buffer);
			
			_obj += $"o shape{i}\n";
			
			if(_mat) {
				var _matName  = $"mat.{i}";
				var _material = array_safe_get_fast(_mesh.materials, i, 0);
				
				if(_material) {
					_mtl += $"newmtl {_matName}\n";
					_obj += $"usemtl {_matName}\n";
					
					if(is_surface(_material.surface)) {
						var _surfPath = $"{filename_dir(_path)}/{filename_name_only(_path)}_texture{i}.png";
						surface_save(_material.surface, _surfPath);
						_mtl += $"map_Kd {_surfPath}\n";
					}
				}
			}
			
			var _obj_v  = "";
			var _obj_vn = "";
			var _obj_vt = "";
			var _obj_f  = "";
			
			var _map_v  = ds_map_create();
			var _map_vn = ds_map_create();
			var _map_vt = ds_map_create();
			var _map_f  = ds_map_create();
			
			switch(_mesh.VF) {
				case global.VF_POS_NORM_TEX_COL :
					var _format_s = global.VF_POS_NORM_TEX_COL_size;
					var _vertex_s = floor(_buffer_s / _format_s);
					var _ind = 0;
					buffer_to_start(_buffer);
					
					var _idx_v  = [ 0, 0, 0 ];
					var _idx_vn = [ 0, 0, 0 ];
					var _idx_vt = [ 0, 0, 0 ];
					
					ds_map_clear(_map_v);
					ds_map_clear(_map_vn);
					ds_map_clear(_map_vt);
					ds_map_clear(_map_f);
					
					repeat(_vertex_s) {
						var _px = buffer_read(_buffer, buffer_f32);
						var _py = buffer_read(_buffer, buffer_f32);
						var _pz = buffer_read(_buffer, buffer_f32);
						
						var _nx = buffer_read(_buffer, buffer_f32);
						var _ny = buffer_read(_buffer, buffer_f32);
						var _nz = buffer_read(_buffer, buffer_f32);
						
						var _u  = buffer_read(_buffer, buffer_f32);
						var _v  = buffer_read(_buffer, buffer_f32);
						if(_invv) _v = 1. - _v;
						
						var _r  = buffer_read(_buffer, buffer_s8);
						var _g  = buffer_read(_buffer, buffer_s8);
						var _b  = buffer_read(_buffer, buffer_s8);
						var _a  = buffer_read(_buffer, buffer_s8);
						
						var _bx = buffer_read(_buffer, buffer_f32);
						var _by = buffer_read(_buffer, buffer_f32);
						var _bz = buffer_read(_buffer, buffer_f32);
						
						var __v  = $"v {string_format(_px, -1, 5)} {string_format(_py, -1, 5)} {string_format(_pz, -1, 5)}";
						var __vn = $"vn {string_format(_nx, -1, 5)} {string_format(_ny, -1, 5)} {string_format(_nz, -1, 5)}";
						var __vt = $"vt {string_format(_u, -1, 5)} {string_format(_v, -1, 5)}";
						
						var _id_v, _id_vn, _id_vt;
						
						if(ds_map_exists(_map_v, __v)) {
							_id_v = _map_v[? __v];
						} else {
							_id_v = ds_map_size(_map_v) + 1;
							_map_v[? __v] = _id_v;
							_obj_v  += $"{__v} \n";
						}
						
						if(ds_map_exists(_map_vn, __vn)) {
							_id_vn = _map_vn[? __vn];
						} else {
							_id_vn = ds_map_size(_map_vn) + 1;
							_map_vn[? __vn] = _id_vn;
							_obj_vn  += $"{__vn} \n";
						}
						
						if(ds_map_exists(_map_vt, __vt)) {
							_id_vt = _map_vt[? __vt];
						} else {
							_id_vt = ds_map_size(_map_vt) + 1;
							_map_vt[? __vt] = _id_vt;
							_obj_vt  += $"{__vt} \n";
						}
						
						_idx_v[_ind % 3]  = _id_v;
						_idx_vn[_ind % 3] = _id_vn;
						_idx_vt[_ind % 3] = _id_vt;
						
						if(_ind % 3 == 2) _obj_f += $"f {_idx_v[0]}/{_idx_vt[0]}/{_idx_vn[0]} {_idx_v[1]}/{_idx_vt[1]}/{_idx_vn[1]} {_idx_v[2]}/{_idx_vt[2]}/{_idx_vn[2]}\n";
						_ind++;
					}
					break;
			}
			
			ds_map_destroy(_map_v);
			ds_map_destroy(_map_vn);
			ds_map_destroy(_map_vt);
			ds_map_destroy(_map_f);
			
			_obj += _obj_v  + "\n";
			_obj += _obj_vn + "\n";
			_obj += _obj_vt + "\n";
			_obj += _obj_f  + "\n";
			
			buffer_delete(_buffer);
		}
		
		file_text_write_all(   _path, _obj);
		if(_mat) file_text_write_all(_mtlPath, _mtl);
		
		var _txt = $"Export model complete.";
		logNode(_txt);
		
		var noti = log_message("EXPORT", _txt, THEME.noti_icon_tick, COLORS._main_value_positive, false);
		noti.path = filename_dir(_path);
		noti.setOnClick(function() { shellOpenExplorer(self.path); }, "Open in explorer", THEME.explorer);
	}
	
	static update = function() {}
	
}