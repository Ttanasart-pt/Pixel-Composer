function Node_3D_Camera(_x, _y, _group = noone) : Node_3D_Object(_x, _y, _group) constructor {
	name = "3D Camera";
	batch_output = true;
	
	object   = new __3dCamera_object();
	camera   = new __3dCamera();
	lookat   = new __3dGizmoSphere(0.5, c_ltgray, 1);
	lookLine = noone;
	lookRad  = new __3dGizmoCircleZ(0.5, c_yellow, 0.5);
	
	w = 128;
	
	scene = new __3dScene(camera);
	scene.name = "Camera";
	
	deferData = noone;
	
	global.SKY_SPHERE = new __3dUVSphere(0.5, 16, 8, true);
	
	inputs[| in_d3d + 0] = nodeValue("FOV", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 60 )
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 10, 90, 0.1 ] });
	
	inputs[| in_d3d + 1] = nodeValue("Clipping Distance", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 10 ] )
		.setDisplay(VALUE_DISPLAY.vector);
	 
	inputs[| in_d3d + 2] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| in_d3d + 3] = nodeValue("Projection", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Perspective", "Orthographic" ]);
	
	inputs[| in_d3d + 4] = nodeValue("Scene", self, JUNCTION_CONNECT.input, VALUE_TYPE.d3Scene, noone )
		.setVisible(true, true);
	
	inputs[| in_d3d + 5] = nodeValue("Ambient Light", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_grey );
	
	inputs[| in_d3d + 6] = nodeValue("Show Background", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false );
	
	inputs[| in_d3d + 7] = nodeValue("Backface Culling", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 2 )
		.setDisplay(VALUE_DISPLAY.enum_button, [ "None", "CW", "CCW" ]);
	
	inputs[| in_d3d + 8] = nodeValue("Orthographic Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1 )
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0.01, 4, 0.01 ] });
	
	inputs[| in_d3d + 9] = nodeValue("Postioning Mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Position + Rotation", "Position + Lookat", "Lookat + Rotation" ] );
	
	inputs[| in_d3d + 10] = nodeValue("Lookat Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| in_d3d + 11] = nodeValue("Roll", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0 )
		.setDisplay(VALUE_DISPLAY.rotation);
	
	inputs[| in_d3d + 12] = nodeValue("Horizontal Angle", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0 )
		.setDisplay(VALUE_DISPLAY.rotation);
	
	inputs[| in_d3d + 13] = nodeValue("Vertical Angle", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 45 )
		.setDisplay(VALUE_DISPLAY.slider, { range: [0, 90, 0.1] });
	
	inputs[| in_d3d + 14] = nodeValue("Distance", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 4 );
	
	inputs[| in_d3d + 15] = nodeValue("Gamma Adjust", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false );
	
	inputs[| in_d3d + 16] = nodeValue("Environment Texture", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone );
	
	inputs[| in_d3d + 17] = nodeValue("Ambient Occlusion", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false );
	
	inputs[| in_d3d + 18] = nodeValue("AO Radius", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.25 );
	
	inputs[| in_d3d + 19] = nodeValue("AO Bias", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.05 );
	
	inputs[| in_d3d + 20] = nodeValue("AO Strength", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1. )
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0.01, 4, 0.01 ] });
	
	inputs[| in_d3d + 21] = nodeValue("Round Normal", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.setWindows();
	
	inputs[| in_d3d + 22] = nodeValue("Blend mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Normal", "Additive" ]);
		
	in_cam = ds_list_size(inputs);
	
	outputs[| 0] = nodeValue("Rendered", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone );
	
	outputs[| 1] = nodeValue("Normal", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone )
		.setVisible(false);
	
	outputs[| 2] = nodeValue("Depth", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone )
		.setVisible(false);
	
	input_display_list = [ in_d3d + 4,
		["Output",		false], in_d3d + 2,
		["Transform",	false], in_d3d + 9, 0, 1, in_d3d + 10, in_d3d + 11, in_d3d + 12, in_d3d + 13, in_d3d + 14, 
		["Camera",		 true], in_d3d + 3, in_d3d + 0, in_d3d + 1, in_d3d + 8, 
		["Render",		 true], in_d3d + 5, in_d3d + 16, in_d3d + 6, in_d3d + 7, in_d3d + 15, in_d3d + 22, 
		["Ambient Occlusion",	true], in_d3d + 17, in_d3d + 20, in_d3d + 18, in_d3d + 19, 
		["Effects",		 true], in_d3d + 21,
	];
	
	tool_lookat = new NodeTool( "Move Target", THEME.tools_3d_transform_object );
	
	static getToolSettings = function() { #region
		var _posm = getInputData(in_d3d + 9);
		
		switch(_posm) {
			case 0 : return tool_settings;
			case 1 : 
			case 2 : return [];
		}
		
		return [];
	} #endregion
	
	static drawOverlay3D = function(active, params, _mx, _my, _snx, _sny, _panel) { #region
		var object = getPreviewObjects();
		if(array_empty(object)) return;
		object = object[0];
		
		var _pos  = inputs[| 0].getValue(,,, true);
		var _vpos = new __vec3( _pos[0], _pos[1], _pos[2] );
		
		if(isUsingTool("Transform"))	drawGizmoPosition(0, object, _vpos, active, params, _mx, _my, _snx, _sny, _panel);
		else if(isUsingTool("Rotate"))	drawGizmoRotation(1, object, _vpos, active, params, _mx, _my, _snx, _sny, _panel);
		else if(isUsingTool("Move Target")) {
			var _lkpos  = inputs[| in_d3d + 10].getValue(,,, true);
			var _lkvpos = new __vec3( _lkpos[0], _lkpos[1], _lkpos[2] );
			
			drawGizmoPosition(in_d3d + 10, noone, _lkvpos, active, params, _mx, _my, _snx, _sny, _panel);
		}
		
		if(drag_axis != noone && mouse_release(mb_left)) {
			drag_axis = noone;
			UNDO_HOLDING = false;
		}
		
		#region draw result
			var _outSurf = outputs[| 0].getValue();
			if(is_array(_outSurf)) _outSurf = array_safe_get(_outSurf, 0);
			if(!is_surface(_outSurf)) return;
		
			var _w = _panel.w;
			var _h = _panel.h - _panel.toolbar_height;
			var _pw = surface_get_width_safe(_outSurf);
			var _ph = surface_get_height_safe(_outSurf);
			var _ps = min(128 / _ph, 160 / _pw);
		
			var _pws = _pw * _ps;
			var _phs = _ph * _ps;
		
			var _px = _w - 16 - _pws;
			var _py = _h - 16 - _phs;
		
			draw_surface_ext_safe(_outSurf, _px, _py, _ps, _ps);
			draw_set_color(COLORS._main_icon);
			draw_rectangle(_px, _py, _px + _pws, _py + _phs, true);
		#endregion
	} #endregion
	
	static onValueUpdate = function(index) { #region
		if(index == in_d3d + 9) PANEL_PREVIEW.tool_current = noone;
	} #endregion
		
	static step = function() { #region
		var _proj = getInputData(in_d3d +  3);
		var _posm = getInputData(in_d3d +  9);
		var _ao   = getInputData(in_d3d + 17);
		
		inputs[| in_d3d + 0].setVisible(_proj == 0);
		inputs[| in_d3d + 8].setVisible(_proj == 1);
		
		inputs[| 0].setVisible(_posm == 0 || _posm == 1);
		inputs[| 1].setVisible(_posm == 0);
		inputs[| in_d3d + 10].setVisible(_posm == 1 || _posm == 2);
		inputs[| in_d3d + 11].setVisible(_posm == 1);
		inputs[| in_d3d + 12].setVisible(_posm == 2);
		inputs[| in_d3d + 13].setVisible(_posm == 2);
		inputs[| in_d3d + 14].setVisible(_posm == 2);
		
		inputs[| in_d3d + 18].setVisible(_ao);
		inputs[| in_d3d + 19].setVisible(_ao);
		inputs[| in_d3d + 20].setVisible(_ao);
		
		switch(_posm) {
			case 0 : 
				tools = [ tool_pos, tool_rot ]; 
				break;
			case 1 : 
				tools = [ tool_pos, tool_lookat ]; 
				tool_attribute.context = 1;
				break;
			case 2 : 
				tools = [ tool_lookat ]; 
				tool_attribute.context = 1;
				break;
		}	
	} #endregion
	
	static preProcessData = function(_data) {}
	
	static submitShadow = function() {}
	static submitShader = function() {}
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { #region
		#region data
			var _pos = _data[0];
			var _rot = _data[1];
			
			var _fov  = _data[in_d3d + 0];
			var _clip = _data[in_d3d + 1];
			var _dim  = _data[in_d3d + 2];
			var _proj = _data[in_d3d + 3];
			var _sobj = _data[in_d3d + 4];
			var _ambt = _data[in_d3d + 5];
			var _dbg  = _data[in_d3d + 6];
			var _back = _data[in_d3d + 7];
			var _orts = _data[in_d3d + 8];
		
			var _posm = _data[in_d3d + 9];
			var _look = _data[in_d3d + 10];
			var _roll = _data[in_d3d + 11];
			var _hAng = _data[in_d3d + 12];
			var _vAng = _data[in_d3d + 13];
			var _dist = _data[in_d3d + 14];
			var _gamm = _data[in_d3d + 15];
			var _env  = _data[in_d3d + 16];
		
			var _aoEn = _data[in_d3d + 17];
			var _aoRa = _data[in_d3d + 18];
			var _aoBi = _data[in_d3d + 19];
			var _aoSr = _data[in_d3d + 20];
		
			var _nrmSmt = _data[in_d3d + 21];
			var _blend  = _data[in_d3d + 22];
		
			var _qi1  = new BBMOD_Quaternion().FromAxisAngle(new BBMOD_Vec3(0, 1, 0),  90);
			var _qi2  = new BBMOD_Quaternion().FromAxisAngle(new BBMOD_Vec3(1, 0, 0), -90);
			var _qi3  = new BBMOD_Quaternion().FromAxisAngle(new BBMOD_Vec3(1, 0, 0),  90);
		#endregion
		
		if(_sobj == noone || !struct_has(_sobj, "submit")) return [ noone, noone, noone ];
		
		switch(_posm) { #region ++++ camera positioning ++++
			case 0 :
				camera.useFocus = false;
				camera.position.set(_pos);
				camera.rotation.set(_rot[0], _rot[1], _rot[2], _rot[3]);
				break;
			case 1 :
				camera.useFocus = true;
				camera.position.set(_pos);
				camera.focus.set(_look);
				camera.up.set(0, 0, -1);
				
				var _for = camera.focus.subtract(camera.position);
				if(!_for.isZero())
					camera.rotation = new BBMOD_Quaternion().FromLookRotation(_for, camera.up).Mul(_qi1).Mul(_qi2);
					
				lookat.transform.position.set(_look);
				lookLine = new __3dGizmoLineDashed(camera.position, camera.focus, 0.25, c_gray, 1);
				break;
			case 2 :
				camera.useFocus = true;
				camera.focus.set(_look);
				camera.setFocusAngle(_hAng, _vAng, _dist);
				camera.setCameraLookRotate();
				camera.up = camera.getUp()._multiply(-1);
				
				var _for = camera.focus.subtract(camera.position);
				if(!_for.isZero()) camera.rotation = new BBMOD_Quaternion().FromLookRotation(_for, camera.up.multiply(-1)).Mul(_qi1).Mul(_qi3);
				
				lookat.transform.position.set(_look);
				lookLine = new __3dGizmoLineDashed(camera.position, camera.focus, 0.25, c_gray, 1);
				
				var _camRad = camera.position.subtract(camera.focus);
				var _rad = point_distance(0, 0, _camRad.x, _camRad.y) * 2;
				lookRad.transform.scale.set(_rad, _rad, 1);
				lookRad.transform.position.set(new __vec3(camera.focus.x, camera.focus.y, camera.position.z));
				break;
		} #endregion
		
		object.transform.position.set(camera.position);
		object.transform.rotation = camera.rotation.Clone();
		object.transform.scale.set(1, _dim[0] / _dim[1], 1);
		
		preProcessData(_data);
		
		#region camera view project
			camera.projection = _proj;
			camera.setViewFov(_fov, _clip[0], _clip[1]);
			if(_proj == 0)		camera.setViewSize(_dim[0], _dim[1]);
			else if(_proj == 1) camera.setViewSize(1 / _orts, _dim[0] / _dim[1] / _orts);
			camera.setMatrix();
		#endregion
		
		#region scene setting
			scene.camera		  = camera;
			scene.lightAmbient    = _ambt;
			scene.gammaCorrection = _gamm;
			scene.enviroment_map  = _env;
			scene.cull_mode		  = _back;
			scene.ssao_enabled	  = _aoEn;
			scene.ssao_radius	  = _aoRa;
			scene.ssao_bias  	  = _aoBi;
			scene.ssao_strength   = _aoSr;
			scene.defer_normal_radius   = _nrmSmt;
			scene.draw_background   = _dbg;
		#endregion
		
		#region submit
			var _bgSurf = _dbg? scene.renderBackground(_dim[0], _dim[1]) : noone;
			_sobj.submitShadow(scene, _sobj);
			submitShadow();
			
			deferData   = scene.deferPass(_sobj, _dim[0], _dim[1], deferData);
			
			var _render = outputs[| 0].getValue();
			var _normal = outputs[| 1].getValue();
			var _depth  = outputs[| 2].getValue();
		
			_render = surface_verify(_render, _dim[0], _dim[1]);
			_normal = surface_verify(_normal, _dim[0], _dim[1]);
			_depth  = surface_verify(_depth , _dim[0], _dim[1]);
		
			surface_set_target_ext(0, _render);
			surface_set_target_ext(1, _normal);
			surface_set_target_ext(2, _depth );
		
			DRAW_CLEAR
			
			gpu_set_zwriteenable(true);
			gpu_set_cullmode(_back); 
			
			if(_blend == 0) {
				gpu_set_ztestenable(true);
			} else {
				BLEND_ADD 
				gpu_set_ztestenable(false);
			}
			
			camera.applyCamera();
			scene.reset();
			scene.submitShader(_sobj);
			submitShader();
			
			scene.apply(deferData);
			scene.submit(_sobj);
			
			BLEND_NORMAL
			surface_reset_target();
			
			camera.resetCamera();
		#endregion
		
		#region render
			var _finalRender = surface_create(_dim[0], _dim[1]);
			surface_set_target(_finalRender);
				DRAW_CLEAR
				BLEND_ALPHA
				
				if(_dbg) { 
					draw_surface_safe(_bgSurf, 0, 0);
					surface_free(_bgSurf);
				}
				draw_surface_safe(_render, 0, 0);
			
				BLEND_MULTIPLY
				draw_surface_safe(deferData.ssao);
				BLEND_NORMAL
			surface_reset_target();
			surface_free(_render);
		#endregion
		
		return [ _finalRender, _normal, _depth ];
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {}
	
	static getPreviewObject = function() { #region 
		var _scene = array_safe_get(all_inputs, in_d3d + 4, noone);
		if(is_array(_scene))
			_scene = array_safe_get(_scene, preview_index, noone);
		return _scene;
	} #endregion
	
	static getPreviewObjects = function() { #region 
		var _posm = getInputData(in_d3d + 9);
		
		var _scene = array_safe_get(all_inputs, in_d3d + 4, noone);
		if(is_array(_scene))
			_scene = array_safe_get(_scene, preview_index, noone);
		
		switch(_posm) {
			case 0 : return [ object, _scene ];
			case 1 : return [ object, lookat, lookLine, _scene ];
			case 2 : return [ object, lookat, lookLine, lookRad, _scene ];
		}
		
		return [ object, _scene ]; 
	} #endregion
	
	static getPreviewObjectOutline = function() { return isUsingTool("Move Target")? [ lookat ] : [ object ]; }
	
	static doSerialize = function(_map) { #region
		_map.camera_base_length = in_cam;
	} #endregion
	
	static postDeserialize = function() { #region
		var _tlen = struct_try_get(load_map, "camera_base_length", in_d3d + 22);
		
		for( var i = _tlen; i < in_cam; i++ )
			array_insert(load_map.inputs, i, noone);
	} #endregion
}