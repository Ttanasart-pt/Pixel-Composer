function Node_3D_Camera(_x, _y, _group = noone) : Node_3D_Object(_x, _y, _group) constructor {
	name = "3D Camera";
	object = new __3dCamera_object();
	camera = new __3dCamera();
	lookat = new __3dGizmoSphere(0.5, c_ltgray, 1);
	
	scene = new __3dScene(camera);
	scene.name = "Camera";
	
	inputs[| in_d3d + 0] = nodeValue("FOV", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 60)
		.setDisplay(VALUE_DISPLAY.slider, [ 10, 90, 1 ]);
	
	inputs[| in_d3d + 1] = nodeValue("Clipping Distance", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 1, 32000 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| in_d3d + 2] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| in_d3d + 3] = nodeValue("Projection", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Perspective", "Orthographic" ]);
	
	inputs[| in_d3d + 4] = nodeValue("Scene", self, JUNCTION_CONNECT.input, VALUE_TYPE.d3Scene, noone )
		.setVisible(true, true);
	
	inputs[| in_d3d + 5] = nodeValue("Ambient Light", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_black );
	
	inputs[| in_d3d + 6] = nodeValue("Show Background", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false );
	
	inputs[| in_d3d + 7] = nodeValue("Backface Culling", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "None", "CW", "CCW" ]);
	
	inputs[| in_d3d + 8] = nodeValue("Orthographic Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [ 0.01, 4, 0.01 ]);
	
	inputs[| in_d3d + 9] = nodeValue("Postioning Mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Position + Rotation", "Position + Lookat", "Lookat + Rotation" ]);
	
	inputs[| in_d3d + 10] = nodeValue("Lookat Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| in_d3d + 11] = nodeValue("Roll", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.rotation);
	
	inputs[| in_d3d + 12] = nodeValue("Horizontal Angle", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.rotation);
	
	inputs[| in_d3d + 13] = nodeValue("Vertical Angle", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 45)
		.setDisplay(VALUE_DISPLAY.slider, [0, 90, 1]);
	
	inputs[| in_d3d + 14] = nodeValue("Distance", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 4);
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ in_d3d + 4,
		["Output",		false], in_d3d + 2,
		["Transform",	false], in_d3d + 9, 0, 1, in_d3d + 10, in_d3d + 11, in_d3d + 12, in_d3d + 13, in_d3d + 14, 
		["Camera",		false], in_d3d + 3, in_d3d + 0, in_d3d + 1, in_d3d + 8, 
		["Render",		false], in_d3d + 5, in_d3d + 6, in_d3d + 7, 
	];
	
	tool_lookat = new NodeTool( "Move Target", THEME.tools_3d_transform_object );
	
	static getToolSettings = function() { #region
		var _posm = inputs[| in_d3d + 9].getValue();
		
		switch(_posm) {
			case 0 : return tool_settings;
			case 1 : 
			case 2 : return [];
		}
		
		return [];
	} #endregion
	
	static drawOverlay3D = function(active, params, _mx, _my, _snx, _sny, _panel) { #region
		var object = getPreviewObject();
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
	} #endregion
	
	static onValueUpdate = function(index) {
		if(index == in_d3d + 9) PANEL_PREVIEW.tool_current = noone;
	}
		
	static step = function() { #region
		var _proj = inputs[| in_d3d + 3].getValue();
		var _posm = inputs[| in_d3d + 9].getValue();
		
		inputs[| in_d3d + 0].setVisible(_proj == 0);
		inputs[| in_d3d + 8].setVisible(_proj == 1);
		
		inputs[| 0].setVisible(_posm == 0 || _posm == 1);
		inputs[| 1].setVisible(_posm == 0);
		inputs[| in_d3d + 10].setVisible(_posm == 1 || _posm == 2);
		inputs[| in_d3d + 11].setVisible(_posm == 1);
		inputs[| in_d3d + 12].setVisible(_posm == 2);
		inputs[| in_d3d + 13].setVisible(_posm == 2);
		inputs[| in_d3d + 14].setVisible(_posm == 2);
		
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
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { #region
		var _pos = _data[0];
		var _rot = _data[1];
		
		var _fov  = _data[in_d3d + 0];
		var _clip = _data[in_d3d + 1];
		var _dim  = _data[in_d3d + 2];
		var _proj = _data[in_d3d + 3];
		var _scne = _data[in_d3d + 4];
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
		
		var _qi1  = new BBMOD_Quaternion().FromAxisAngle(new BBMOD_Vec3(0, 1, 0),  90);
		var _qi2  = new BBMOD_Quaternion().FromAxisAngle(new BBMOD_Vec3(1, 0, 0), -90);
		var _qi3  = new BBMOD_Quaternion().FromAxisAngle(new BBMOD_Vec3(1, 0, 0),  90);
		
		switch(_posm) {
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
					
				lookat.position.set(_look);
				break;
			case 2 :
				camera.useFocus = true;
				camera.focus.set(_look);
				camera.setFocusAngle(_hAng, _vAng, _dist);
				camera.setCameraLookRotate();
				camera.up = camera.getUp();
				
				var _for = camera.focus.subtract(camera.position);
				if(!_for.isZero())
					camera.rotation = new BBMOD_Quaternion().FromLookRotation(_for, camera.up).Mul(_qi1).Mul(_qi3);
				
				lookat.position.set(_look);
				break;
		}
		
		object.position.set(camera.position);
		object.rotation = camera.rotation.Clone();
		
		if(_scne == noone) return;
		
		camera.projection = _proj;
		camera.setViewFov(_fov, _clip[0], _clip[1]);
		if(_proj == 0)		camera.setViewSize(_dim[0], _dim[1]);
		else if(_proj == 1) camera.setViewSize(1 / _orts, _dim[0] / _dim[1] / _orts);
		
		scene.lightAmbient = _ambt;
		
		_output = surface_verify(_output, _dim[0], _dim[1]);
		
		camera.setMatrix();
		
		surface_set_target(_output);
		if(_dbg) draw_clear(_ambt);
		else	 DRAW_CLEAR
		
		gpu_set_zwriteenable(true);
		gpu_set_ztestenable(true);
		gpu_set_cullmode(_back); 
		
		var cam = camera_get_active();
		camera.applyCamera(cam);
			
		scene.reset();
		_scne.submitShader(scene);
		scene.apply();
			
		_scne.submit(scene);						//////////////// SUBMIT ////////////////
			
		surface_reset_target();
		gpu_set_cullmode(cull_noculling); 
		
		return _output;
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		
	}
	
	static getPreviewObject = function() { #region 
		var _posm = inputs[| in_d3d + 9].getValue();
		
		var _scene = array_safe_get(all_inputs, in_d3d + 4, []);
		if(is_array(_scene))
			_scene = array_safe_get(_scene, preview_index, noone);
		
		switch(_posm) {
			case 0 : return [ object, _scene ];
			case 1 : return [ object, lookat, _scene ];
			case 2 : return [ object, lookat, _scene ];
		}
		
		return [ object, _scene ]; 
	} #endregion
	
	static getPreviewObjectOutline = function() { return isUsingTool("Move Target")? [ lookat ] : [ object ]; }
}