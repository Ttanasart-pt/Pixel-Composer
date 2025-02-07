function Node_3D_Camera(_x, _y, _group = noone) : Node_3D_Object(_x, _y, _group) constructor {
	name = "3D Camera";
	batch_output = true;
	
	dimension_index = in_d3d + 2;
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
	var i = in_d3d;
	
	newInput(i+0, nodeValue_Int("FOV", self, 60 ))
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 10, 90, 0.1 ] });
	
	newInput(i+1, nodeValue_Vec2("Clipping Distance", self, [ 1, 10 ] ));
	 
	newInput(i+2, nodeValue_Dimension(self));
	
	newInput(i+3, nodeValue_Enum_Button("Projection", self,  1 , [ "Perspective", "Orthographic" ]));
	
	newInput(i+4, nodeValue_D3Scene("Scene", self, noone ))
		.setVisible(true, true);
	
	newInput(i+5, nodeValue_Color("Ambient Light", self, c_dkgrey ));
	
	newInput(i+6, nodeValue_Bool("Show Background", self, false ));
	
	newInput(i+7, nodeValue_Enum_Button("Backface Culling", self,  2 , [ "None", "CW", "CCW" ]));
	
	newInput(i+8, nodeValue_Float("Orthographic Scale", self, 0.5 ))
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0.01, 4, 0.01 ] });
	
	newInput(i+9, nodeValue_Enum_Scroll("Postioning Mode", self, 2, [ "Position + Rotation", "Position + Lookat", "Lookat + Rotation" ] ));
	
	newInput(i+10, nodeValue_Vec3("Lookat Position", self, [ 0, 0, 0 ] ));
	
	newInput(i+11, nodeValue_Rotation("Roll", self, 0));
	
	newInput(i+12, nodeValue_Rotation("Horizontal Angle", self, 45 ));
	
	newInput(i+13, nodeValue_Float("Vertical Angle", self, 30 ))
		.setDisplay(VALUE_DISPLAY.slider, { range: [0, 90, 0.1] });
	
	newInput(i+14, nodeValue_Float("Distance", self, 4 ));
	
	newInput(i+15, nodeValue_Bool("Gamma Adjust", self, false ));
	
	newInput(i+16, nodeValue_Surface("Environment Texture", self));
	
	newInput(i+17, nodeValue_Bool("Ambient Occlusion", self, false ));
	
	newInput(i+18, nodeValue_Float("AO Radius", self, 0.25 ));
	
	newInput(i+19, nodeValue_Float("AO Bias", self, 0.05 ));
	
	newInput(i+20, nodeValue_Float("AO Strength", self, 1. ))
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0.01, 4, 0.01 ] });
	
	newInput(i+21, nodeValue_Int("Round Normal", self, 0 ))
		.setWindows();
	
	newInput(i+22, nodeValue_Enum_Button("Blend mode", self,  0 , [ "Normal", "Additive" ]));
	
	newInput(i+23, nodeValue_Bool("Wireframe", self, false));
	
	newInput(i+24, nodeValue_Float("Wireframe Thickness", self, 1));
	
	newInput(i+25, nodeValue_Color("Wireframe Color", self, cola(c_black)));
	
	newInput(i+26, nodeValue_Bool("Wireframe antialias", self, false));
	
	newInput(i+27, nodeValue_Bool("Wireframe shading", self, false));
	
	newInput(i+28, nodeValue_Bool("Wireframe only", self, false));
	
	in_cam = array_length(inputs);
	
	newOutput(0, nodeValue_Output("Rendered", self, VALUE_TYPE.surface, noone ));
	newOutput(1, nodeValue_Output("Normal",   self, VALUE_TYPE.surface, noone )).setVisible(false);
	newOutput(2, nodeValue_Output("Depth",    self, VALUE_TYPE.surface, noone )).setVisible(false);
	newOutput(3, nodeValue_Output("Shadow",   self, VALUE_TYPE.surface, noone )).setVisible(false);
	newOutput(4, nodeValue_Output("Ambient Occlusion", self, VALUE_TYPE.surface, noone )).setVisible(false);
	newOutput(5, nodeValue_Output("Diffuse",  self, VALUE_TYPE.surface, noone )).setVisible(false);
	
	input_display_list = [ i+4,
		["Output",		     false],       i+ 2,
		["Transform",	     false],       i+ 9, 0, 1, i+10, i+11, i+12, i+13, i+14, 
		["Camera",		      true],       i+ 3, i+ 0, i+ 1, i+ 8, 
		["Render",		      true],       i+ 5, i+16, i+ 6, i+ 7, i+15, i+22, 
		["Wireframe",         true, i+23], i+24, i+25, i+26, i+27, i+28, 
		["Ambient Occlusion", true, i+17], i+20, i+18, i+19, 
		["Effects",			  true],       i+21,
	];
	
	output_display_list = [ 0, 5, 1, 2, 3, 4 ];
	
	temp_surface = [ 0 ];
	tool_lookat  = new NodeTool( "Move Target", THEME.tools_3d_transform_object );
	
	////- Preview
	
	static getToolSettings = function() {
		var _posm = getInputData(in_d3d + 9);
		if(_posm == 0) return tool_settings;
		
		return [];
	}
	
	static drawOverlay3D = function(active, params, _mx, _my, _snx, _sny, _panel) {
		var preObj = getPreviewObjects();
		if(array_empty(preObj)) return;
		preObj = preObj[0];
		
		var _pos  = inputs[0].getValue(,,, true);
		var _vpos = new __vec3( _pos[0], _pos[1], _pos[2] );
		
		if(isUsingTool("Transform"))	drawGizmoPosition(0, preObj, _vpos, active, params, _mx, _my, _snx, _sny, _panel);
		else if(isUsingTool("Rotate"))	drawGizmoRotation(1, preObj, _vpos, active, params, _mx, _my, _snx, _sny, _panel);
		else if(isUsingTool("Move Target")) {
			var _lkpos  = inputs[in_d3d + 10].getValue(,,, true);
			var _lkvpos = new __vec3( _lkpos[0], _lkpos[1], _lkpos[2] );
			
			drawGizmoPosition(in_d3d + 10, noone, _lkvpos, active, params, _mx, _my, _snx, _sny, _panel);
		}
		
		if(drag_axis != noone && mouse_release(mb_left)) {
			drag_axis = noone;
			UNDO_HOLDING = false;
		}
		
		#region draw result
			var _outSurf = outputs[0].getValue();
			if(is_array(_outSurf)) _outSurf = array_safe_get_fast(_outSurf, 0);
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
	}
	
	////- Update
	
	static onValueUpdate = function(index) {
		if(index == in_d3d + 9) PANEL_PREVIEW.tool_current = noone;
	}
		
	static step = function() {
		var _proj = getInputData(in_d3d +  3);
		var _posm = getInputData(in_d3d +  9);
		var _ao   = getInputData(in_d3d + 17);
		
		inputs[in_d3d + 0].setVisible(_proj == 0);
		inputs[in_d3d + 8].setVisible(_proj == 1);
		
		inputs[0].setVisible(_posm == 0 || _posm == 1);
		inputs[1].setVisible(_posm == 0);
		inputs[in_d3d + 10].setVisible(_posm == 1 || _posm == 2);
		inputs[in_d3d + 11].setVisible(_posm == 1);
		inputs[in_d3d + 12].setVisible(_posm == 2);
		inputs[in_d3d + 13].setVisible(_posm == 2);
		inputs[in_d3d + 14].setVisible(_posm == 2);
		
		inputs[in_d3d + 18].setVisible(_ao);
		inputs[in_d3d + 19].setVisible(_ao);
		inputs[in_d3d + 20].setVisible(_ao);
		
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
	}
	
	static preProcessData = function(_data) {}
	
	static submitShadow = function() {}
	static submitShader = function() {}
	
	static processData = function(_outData, _data, _output_index, _array_index = 0) {
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
			
			var _wire   = _data[in_d3d + 23];
			var _wiret  = _data[in_d3d + 24];
			var _wirec  = _data[in_d3d + 25];
			var _wirea  = _data[in_d3d + 26];
			var _wires  = _data[in_d3d + 27];
			var _wireo  = _data[in_d3d + 28];
		
			var _qi1  = new BBMOD_Quaternion().FromAxisAngle(new BBMOD_Vec3(0, 1, 0),  90);
			var _qi2  = new BBMOD_Quaternion().FromAxisAngle(new BBMOD_Vec3(1, 0, 0), -90);
			var _qi3  = new BBMOD_Quaternion().FromAxisAngle(new BBMOD_Vec3(1, 0, 0),  90);
		#endregion
		
		surface_depth_disable(false);
		
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
			scene.camera		      = camera;
			scene.lightAmbient        = _ambt;
			scene.gammaCorrection     = _gamm;
			scene.enviroment_map      = _env;
			scene.cull_mode		      = _back;
			scene.ssao_enabled	      = _aoEn;
			scene.ssao_radius	      = _aoRa;
			scene.ssao_bias  	      = _aoBi;
			scene.ssao_strength       = _aoSr;
			scene.defer_normal_radius = _nrmSmt;
			scene.draw_background     = _dbg;
			
			scene.show_wireframe      = _wire;
			scene.wireframe_width     = _wiret;
			scene.wireframe_color     = _wirec;
			scene.wireframe_aa        = _wirea;
			scene.wireframe_shade     = _wires;
			scene.wireframe_only      = _wireo;
		#endregion
		
		#region submit
			for( var i = 0, n = array_length(_outData); i < n; i++ ) {
				if(is_surface(_outData[i]) && !surface_has_depth(_outData[i]))
					surface_free(_outData[i]);
				_outData[i] = surface_verify(_outData[i], _dim[0], _dim[1]);
			}
			
			temp_surface[0] = surface_verify(temp_surface[0], _dim[0], _dim[1]);
			var _render = temp_surface[0];
			var _bgSurf = _dbg? scene.renderBackground(_dim[0], _dim[1]) : noone;
			
			if(_sobj) {
				_sobj.submitShadow(scene, _sobj);
				submitShadow();
				
				deferData = scene.deferPass(_sobj, _dim[0], _dim[1], deferData);
				
				surface_set_target_ext(0, _render);
				surface_set_target_ext(1, _outData[1]);
				surface_set_target_ext(2, _outData[2]);
				surface_set_target_ext(3, _outData[3]);
				DRAW_CLEAR
				
				gpu_set_zwriteenable(true);
				gpu_set_cullmode(_back); 
				gpu_set_ztestenable(_blend == 0);
				if(_blend == 1) BLEND_ADD
				
				camera.applyCamera();
				scene.reset();
				scene.submitShader(_sobj);
				submitShader();
				
				scene.apply(deferData);
				scene.submit(_sobj);
				
				BLEND_NORMAL
				surface_reset_target();
				
				camera.resetCamera();
				
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
				
				surface_set_target_ext(0, _outData[5]);
				DRAW_CLEAR
				
				gpu_set_zwriteenable(true);
				gpu_set_cullmode(_back); 
				gpu_set_ztestenable(_blend == 0);
				if(_blend == 1) BLEND_ADD
				
				camera.applyCamera();
				scene.submitShader(_sobj, sh_d3d_unlit);
				
				BLEND_NORMAL
				surface_reset_target();
				
				camera.resetCamera();
				
			}
		#endregion
		
		#region render
			surface_set_target(_outData[0]);
				DRAW_CLEAR
				BLEND_ALPHA
				
				if(_dbg) { 
					draw_surface_safe(_bgSurf);
					surface_free(_bgSurf);
				}
				draw_surface_safe(_render);
				
				if(deferData) {
					BLEND_MULTIPLY
					draw_surface_safe(deferData.ssao);
					BLEND_NORMAL
					
					_outData[4] = deferData.ssao;
				}
			surface_reset_target();
			surface_free(_render);
			
		#endregion
		
		surface_depth_disable(true);
		
		return _outData;
	}
	
	////- Draw
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {}
	
	static getPreviewObject = function() {  return getSingleValue(in_d3d + 4); }
	
	static getPreviewObjects = function() { 
		var _posm  = getInputData(in_d3d + 9);
		var _scene = getSingleValue(in_d3d + 4);
		
		switch(_posm) {
			case 0 : return [ object, _scene ];
			case 1 : return [ object, lookat, lookLine, _scene ];
			case 2 : return [ object, lookat, lookLine, lookRad, _scene ];
		}
		
		return [ object, _scene ]; 
	}
	
	static getPreviewObjectOutline = function() { return isUsingTool("Move Target")? [ lookat ] : [ object ]; }
	
	////- Serialize
	
	static doSerialize = function(_map) {
		_map.camera_base_length = in_cam;
	}
	
	static postDeserialize = function() {
		var _tlen = struct_try_get(load_map, "camera_base_length", in_d3d + 22);
		
		for( var i = _tlen; i < in_cam; i++ )
			array_insert(load_map.inputs, i, noone);
	}
}