function Node_3D_Mesh_Vertex_Points(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "Mesh Vertices";
	color = COLORS.node_blend_number;
	is_3D = NODE_3D.polygon;
	setDimension(96, 48);
	
	newInput(0, nodeValue_D3Mesh( "Mesh", noone )).setVisible(true, true);
	newInput(1, nodeValue_Bool(   "Apply Transform", false ));
	
	newOutput(0, nodeValue_Output( "Positions", VALUE_TYPE.float, [ 0, 0, 0 ])).setDisplay(VALUE_DISPLAY.vector).setArrayDepth(1);
	newOutput(1, nodeValue_Output( "Normals",   VALUE_TYPE.float, [ 0, 0, 0 ])).setDisplay(VALUE_DISPLAY.vector).setArrayDepth(1);
	
	input_display_list = [ 0, 1 ];
	
	////- Draw
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { }
	
	static drawOverlay3D = function(active, _mx, _my, _snx, _sny, _params) {
		var ansize = array_length(inputs) - input_fix_len;
		var edited = false;
		var _qinv  = new BBMOD_Quaternion().FromAxisAngle(new BBMOD_Vec3(1, 0, 0), 90);
	
		var _camera = _params.scene.camera;
		var _qview  = new BBMOD_Quaternion().FromEuler(_camera.focus_angle_y, -_camera.focus_angle_x, 0);
		
		////////////////////////////////////////////////// DRAW POINTS //////////////////////////////////////////////////
		
		var _center = getSingleValue(1);
		var _hsize  = getSingleValue(2);
		var _points = getSingleValue(0, preview_index, true);
		
		var _v3 = new __vec3();
		draw_set_circle_precision(32);
		
		for( var i = 0, n = array_length(_points); i < n; i++ ) {
			var _p = _points[i];
			if(!is_array(_p)) continue;
			
			_v3.x = array_safe_get_fast(_p, 0);
			_v3.y = array_safe_get_fast(_p, 1);
			_v3.z = array_safe_get_fast(_p, 2);
			
			var _posView = _camera.worldPointToViewPoint(_v3);
			var _x = _posView.x;
			var _y = _posView.y;
				
			draw_set_color(COLORS._main_accent);
			draw_circle(_x, _y, 4, false);
		}
	}
	
	////- Nodes
	
	static processData = function(_outData, _data, _array_index) {
		var _mesh = _data[0];
		var _appy = _data[1];
		
		var pos = _outData[0];
		var nor = _outData[1];
		
		if(!is(_mesh, __3dObject)) return _outData;
		
		__mat = _mesh.transform.matrix;
		
		var _ind = 0;
		
		if(!array_empty(_mesh.vertex)) {
			for( var i = 0, n = array_length(_mesh.vertex); i < n; i++ ) {
				var _vs = _mesh.vertex[i];
				var for( var j = 0, m = array_length(_vs); j < m; j++ ) {
					var _v = _vs[j];
					
					pos[_ind] = [ _v.x,  _v.y,  _v.z  ];
					nor[_ind] = [ _v.nx, _v.ny, _v.nz ];
					_ind++;
				}
			}
			
		} else {
			var vbs = _mesh.VB;
			var vf  = _mesh.VF;
			
			for( var i = 0, n = array_length(vbs); i < n; i++ ) {
				var _vb = vbs[i];
				var  vb = buffer_create_from_vertex_buffer(_vb, buffer_fixed, 1);
				
				var siz = buffer_get_size(vb);
				var vsz = 0;
				
				switch(vf) {
					case global.VF_POS_COL :          vsz = global.VF_POS_COL_size;          break;
					case global.VF_POS_NORM_TEX_COL : vsz = global.VF_POS_NORM_TEX_COL_size; break;
				}
				
				var vamo = floor(siz / vsz);
				
				buffer_to_start(vb);
				switch(vf) {
					case global.VF_POS_COL :          
						repeat(vamo) {
							var _px = buffer_read(vb, buffer_f32);
							var _py = buffer_read(vb, buffer_f32);
							var _pz = buffer_read(vb, buffer_f32);
							
							var _r  = buffer_read(vb, buffer_s8);
							var _g  = buffer_read(vb, buffer_s8);
							var _b  = buffer_read(vb, buffer_s8);
							var _a  = buffer_read(vb, buffer_s8);
							
							pos[_ind] = [_px, _py, _pz];
							_ind++;
						}
						break;
						
					case global.VF_POS_NORM_TEX_COL : 
						repeat(vamo) {
							var _px = buffer_read(vb, buffer_f32);
							var _py = buffer_read(vb, buffer_f32);
							var _pz = buffer_read(vb, buffer_f32);
							
							var _nx = buffer_read(vb, buffer_f32);
							var _ny = buffer_read(vb, buffer_f32);
							var _nz = buffer_read(vb, buffer_f32);
							
							var _u  = buffer_read(vb, buffer_f32);
							var _v  = buffer_read(vb, buffer_f32);
							
							var _r  = buffer_read(vb, buffer_s8);
							var _g  = buffer_read(vb, buffer_s8);
							var _b  = buffer_read(vb, buffer_s8);
							var _a  = buffer_read(vb, buffer_s8);
							
							var _bx = buffer_read(vb, buffer_f32);
							var _by = buffer_read(vb, buffer_f32);
							var _bz = buffer_read(vb, buffer_f32);
							
							pos[_ind] = [_px, _py, _pz];
							_ind++;
						}
						break;
				}
			}
			
		}
		
		array_resize(pos, _ind);
		array_resize(nor, _ind);
		
		if(_appy) {
			array_map_ext(pos, function(v,i) /*=>*/ {return __mat.MulArray(v, 1)});
			array_map_ext(nor, function(v,i) /*=>*/ {return __mat.MulArray(v, 0)});
		}
		
		return _outData;
	}
	
	////- Preview
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		draw_sprite_bbox_uniform(s_node_3d_mesh_vertex_points, 0, bbox);
	}
	
	static getPreviewObject 		= function() /*=>*/ {return noone};
	static getPreviewObjects		= function() /*=>*/ {return []};
	static getPreviewObjectOutline  = function() /*=>*/ {return []};
	
}