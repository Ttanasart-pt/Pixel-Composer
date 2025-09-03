function Node_pSystem_3D_Mask(_x, _y, _group = noone) : Node_3D_Object(_x, _y, _group) constructor {
	name  = "Mask";
	icon  = THEME.vfx;
	color = COLORS.node_blend_vfx;
	node_draw_icon = s_node_psystem_3d_mask;
	
	setDimension(96, 0);
	update_on_frame = true;
	
	gizmo_sphere = [ new __3dGizmoSphere(,, 0.75), new __3dGizmoSphere(,, 0.5) ];
	gizmo_plane  = [ new __3dGizmoPlaneFalloff(,, 0.75) ];
	gizmo_object = noone;
	
	var i = in_d3d;
	
	newInput(i+2, nodeValueSeed());
	
	////- =Particles
	newInput(i+0, nodeValue_Particle( "Particles" ));
	newInput(i+1, nodeValue_Buffer(   "Mask"      ));
	
	////- =Mask
	newInput(i+3, nodeValue_Enum_Scroll( "Type",   0, [ "Shape", /*"Mesh"*/ ] )); 
	newInput(i+4, nodeValue_Enum_Scroll( "Shape",  0 )).setChoices([ new scrollItem("Sphere", s_node_3d_affector_shape, 0), 
	                                                                 new scrollItem("Plane",  s_node_3d_affector_shape, 1), ]);
	newInput(i+5, nodeValue_D3Mesh( "Mesh" ));
	
	////- =Falloff
	newInput(i+6, nodeValue_Float( "Falloff Distance", 1 )).setCurvable(i+7, CURVE_DEF_11, "Curve"); 
	// i+8
	
	newOutput(0, nodeValue_Output( "Particles", VALUE_TYPE.particle, noone ));
	newOutput(1, nodeValue_Output( "Mask",      VALUE_TYPE.buffer,   noone ));
	
	input_display_list = [ i+2, 
		[ "Particles", false ], i+0, 
		[ "Affectors", false ], i+3, i+4, 0, 1, 2, i+5, 
		[ "Falloff",   false ], i+6, i+7, 
	];
	
	////- Nodes
	
	shape_type   = 0;
	mask_buffer  = undefined;
	mask_sampler = undefined;
	plane_normal = [ 0, 0, 1 ];
	
	static update = function(_frame = CURRENT_FRAME) { 
		var _data = inputs_data;
		
		#region data
			var i = in_d3d;
			var _seed  = _data[i+2];
			
			var _parts = _data[i+0];
			var _masks = _data[i+1];
			
			var _type  = _data[i+3];
			var _shap  = _data[i+4];
			var _pos   = _data[  0];
			var _rot   = _data[  1];
			var _sca   = _data[  2];
			var _mesh  = _data[i+5];
			
			var _fald  = _data[i+6], _fall_curved = inputs[i+6].attributes.curved;
			var _fcrv  = _data[i+7];
			
			var _maxs  = max(_sca[0], _sca[1], _sca[2]);
			
			inputs[i+4].setVisible(_type == 0);
			inputs[  0].setVisible(_type == 0);
			inputs[  1].setVisible(_type == 0);
			inputs[  2].setVisible(_type == 0);
			inputs[i+5].setVisible(_type == 1);
			inputs[i+6].setVisible(_type == 0);
			
			shape_type = _type;
		#endregion
		
		if(_type == 0) {
			if(_shap == 0) {
				gizmo_object = gizmo_sphere;
				
				setTransform(gizmo_sphere[0], _data);
				setTransform(gizmo_sphere[1], _data);
				
				gizmo_sphere[0].transform.scale.set(_maxs + _fald, _maxs + _fald, _maxs + _fald);
				gizmo_sphere[1].transform.scale.set(_maxs - _fald, _maxs - _fald, _maxs - _fald);
				
				gizmo_sphere[0].transform.applyMatrix();
				gizmo_sphere[1].transform.applyMatrix();
			
			} else if(_shap == 1) {
				gizmo_object = gizmo_plane;
				
				setTransform(gizmo_plane[0], _data);
				gizmo_plane[0].transform.scale.set(1, 1, 1);
				gizmo_plane[0].transform.applyMatrix();
				
				gizmo_plane[0].checkParameter({ distance: _fald });
				
				var _prot    = new BBMOD_Quaternion(_rot[0], _rot[1], _rot[2], _rot[3]);
				plane_normal = _prot.Rotate(new BBMOD_Vec3(0, 0, 1)).ToArray();
			}
			
		}
		
		if(!is(_parts, pSystem_Particles)) return;
		
		var _pools  = _parts.poolSize;
		mask_buffer = buffer_verify(mask_buffer, _pools * 4);
		
		var _partAmo  = _parts.maxCursor;
		var _partBuff = _parts.buffer;
		var _off = 0;
		buffer_to_start(mask_buffer);
		
		var _dis = 0;
		var _inR = 0;
		var _ouR = 1;
		
		repeat(_partAmo) {
			var _start = _off;
			buffer_seek(_partBuff, buffer_seek_start, _start);
			_off += global.pSystem_data_length;
			
			var _act    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.active, buffer_bool );
			var _spwnId = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.sindex, buffer_u32  );
			if(!_act) { buffer_write(mask_buffer, buffer_f32, 0); continue; }
			
			var _px  = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.posx, buffer_f64  );
			var _py  = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.posy, buffer_f64  );
			var _pz  = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.posz, buffer_f64  );
			
			var _inf = 0;
			
			switch(_type) {
				case 0 : 
					switch(_shap) {
						case 0 : 
							_dis = point_distance_3d(_pos[0], _pos[1], _pos[2], _px, _py, _pz);
							_inR = (_maxs - _fald) / 2;
							_ouR = (_maxs + _fald) / 2;
							break;
						
						case 1 : 
							_dis = d3d_point_to_plane(_pos, plane_normal, [_px, _py, _pz]);
							_inR = -_fald / 2;
							_ouR =  _fald / 2;
							break;
					}
					
					
					     if(_dis >= _ouR) _inf = 0;
					else if(_dis <= _inR) _inf = 1;
					else _inf = 1 - (_dis - _inR) / _fald;
					break;
			}
			
			if(_fall_curved) _inf = eval_curve_x(_fcrv, clamp(_inf, 0., 1.));
			
			buffer_write(mask_buffer, buffer_f32, _inf);
		}
		
		outputs[0].setValue(_parts);
		outputs[1].setValue(mask_buffer);
	}
	
	static getPreviewObjects		= function() /*=>*/ {return shape_type == 0? array_append([getPreviewObject()], gizmo_object) : []};
	static getPreviewObjectOutline  = function() /*=>*/ {return shape_type == 0? gizmo_object : noone};
}