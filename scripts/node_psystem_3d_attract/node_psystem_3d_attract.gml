#region
	FN_NODE_TOOL_INVOKE {
		hotkeyTool("Node_pSystem_3D_Attract", "Move Target", "G");
	});
	
#endregion

function Node_pSystem_3D_Attract(_x, _y, _group = noone) : Node_3D(_x, _y, _group) constructor {
	name  = "Attract";
	icon  = THEME.vfx;
	color = COLORS.node_blend_vfx;
	node_draw_icon = s_node_psystem_attract;
	
	setDimension(96, 0);
	update_on_frame = true;
	
	target_gizmo = new __3dGizmoAxis(.5, c_white, .75 );
	
	newInput( 2, nodeValueSeed());
	
	////- =Particles
	newInput( 0, nodeValue_Particle( "Particles" ));
	newInput( 1, nodeValue_Buffer(   "Mask"      ));
	
	////- =Attract
	newInput( 3, nodeValue_Range( "Strength", [1,1], true )).setCurvable( 4, CURVE_DEF_11, "Over Lifespan"); 
	newInput( 5, nodeValue_Vec3(  "Target",   [0,0,0]     ));
	
	////- =Vortex
	newInput( 6, nodeValue_Range( "Vortex",       [ 0, 0], true )).setCurvable( 7, CURVE_DEF_11, "Over Lifespan"); 
	newInput( 8, nodeValue_Range( "Vortex Angle", [90,90], true )).setCurvable( 9, CURVE_DEF_11, "Over Lifespan"); 
	// 10
	
	newOutput(0, nodeValue_Output("Particles", VALUE_TYPE.particle, noone ));
	
	input_display_list = [ 2, 
		[ "Particles", false ], 0, 1, 
		[ "Attract",   false ], 3, 4, 5, 
		[ "Vortex",    false ], 6, 7, 8, 9, 
	];
	
	////- Tools
	
	tool_attribute.context = 0;
	tool_ori_obj = new d3d_transform_tool_position(self);
	tool_ori     = new NodeTool( "Move Target", THEME.tools_3d_transform, "Node_pSystem_3D_Attract" ).setToolObject(tool_ori_obj);
	tools = [ tool_ori ];
	
	static drawOverlay3D = function(active, _mx, _my, _snx, _sny, _params) { 
		var _ori = new __vec3(inputs[5].getValue(,,, true));
		
		if(isUsingTool("Move Target")) tool_ori_obj.drawOverlay3D(5, noone, _ori, active, _mx, _my, _snx, _sny, _params);
	} 
	
	////- Nodes
	
	curve_strn = undefined;
	curve_vert = undefined;
	curve_vang = undefined;
	
	static reset = function() {
		curve_strn = new curveMap(getInputData( 4));
		curve_vert = new curveMap(getInputData( 7));
		curve_vang = new curveMap(getInputData( 9));
	}
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {
		var _parts = _data[ 0];
		var _masks = _data[ 1], use_mask = _masks != noone;
		
		if(!is(_parts, pSystem_Particles)) return _parts;
		if(use_mask) buffer_to_start(_masks);
		outputs[0].setValue(_parts);
		
		var _seed = _data[ 2];
		var _strn = _data[ 3], _strn_curved = inputs[3].attributes.curved && curve_strn != undefined;
		var _targ = _data[ 5];
		
		var _vort = _data[ 6], _vort_curved = inputs[6].attributes.curved && curve_strn != undefined;
		var _vang = _data[ 8], _vang_curved = inputs[8].attributes.curved && curve_strn != undefined;
		
		var _partAmo  = _parts.maxCursor;
		var _partBuff = _parts.buffer;
		var _off = 0;
		
		#region preview
			target_gizmo.transform.position.set( _targ );
			target_gizmo.transform.applyMatrix();
		#endregion
		
		repeat(_partAmo) {
			var _start = _off;
			buffer_seek(_partBuff, buffer_seek_start, _start);
			_off += global.pSystem_data_length;
			
			var _mask   = use_mask? buffer_read(_masks, buffer_f32) : 1; if(_mask <= 0) continue;
			var _act    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.active, buffer_bool );
			var _spwnId = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.sindex, buffer_u32  );
			if(!_act) continue;
			
			var _lif    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.life,   buffer_f64  );
			var _lifMax = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.mlife,  buffer_f64  );
			
			var _px     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.posx,   buffer_f64  );
			var _py     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.posy,   buffer_f64  );
			var _pz     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.posz,   buffer_f64  );
			
			var _vx     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.velx,   buffer_f64  );
			var _vy     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.vely,   buffer_f64  );
			var _vz     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.velz,   buffer_f64  );
			
			var rat = _lif / (_lifMax - 1);
			random_set_seed(_seed + _spwnId);
			
			var _strn_mod = _strn_curved? curve_strn.get(rat) : 1;
			var _strn_cur = random_range(_strn[0], _strn[1]) * _strn_mod * _mask;
			
			var _vort_mod = _vort_curved? curve_vort.get(rat) : 1;
			var _vort_cur = random_range(_vort[0], _vort[1]) * _vort_mod * _mask;
			
			var _vang_mod = _vang_curved? curve_vang.get(rat) : 1;
			var _vang_cur = random_range(_vang[0], _vang[1]) * _vang_mod * _mask;
			
			var _dx = _targ[0] - _px;
			var _dy = _targ[1] - _py;
			var _dz = _targ[2] - _pz;
			var _ds = sqrt(_dx*_dx + _dy*_dy + _dz*_dz);
			
			_dx /= _ds;
			_dy /= _ds;
			_dz /= _ds;
			
			var _dis = point_distance_3d( _px, _py, _pz, _targ[0], _targ[1], _targ[2]);
			    _dis = min(_dis, _strn_cur);
			    
			_px += _dx * _dis;
			_py += _dy * _dis;
			_pz += _dz * _dis;
			
			// _px += lengthdir_x(_dis * _vort_cur, _dir + _vang_cur);
			// _py += lengthdir_y(_dis * _vort_cur, _dir + _vang_cur);
			// _pz += lengthdir_y(_dis * _vort_cur, _dir + _vang_cur);
			
			buffer_write_at(_partBuff, _start + PSYSTEM_OFF.posx, buffer_f64, _px );
			buffer_write_at(_partBuff, _start + PSYSTEM_OFF.posy, buffer_f64, _py );
			buffer_write_at(_partBuff, _start + PSYSTEM_OFF.posz, buffer_f64, _pz );
		}
		
		return _parts;
	}

	////- Draw
	
	static getPreviewObject        = function() /*=>*/ {return noone};
	static getPreviewObjects       = function() /*=>*/ {return [ target_gizmo ]};
	static getPreviewObjectOutline = function() /*=>*/ {return [ target_gizmo ]};
		
}