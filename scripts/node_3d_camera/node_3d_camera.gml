function Node_3D_Camera(_x, _y, _group = noone) : Node_3D_Object(_x, _y, _group) constructor {
	name = "3D Camera";
	object = new __3dCamera_object();
	camera = new __3dCamera();
	camera.useFocus = false;
	
	scene = new __3dScene(camera);
	scene.name = "Camera";
	
	inputs[| input_d3d_index + 0] = nodeValue("FOV", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 60)
		.setDisplay(VALUE_DISPLAY.slider, [ 10, 90, 1 ]);
	
	inputs[| input_d3d_index + 1] = nodeValue("Clipping Distance", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 1, 32000 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| input_d3d_index + 2] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| input_d3d_index + 3] = nodeValue("Projection", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Perspective", "Orthographic" ]);
	
	inputs[| input_d3d_index + 4] = nodeValue("Scene", self, JUNCTION_CONNECT.input, VALUE_TYPE.d3Scene, noone )
		.setVisible(true, true);
	
	inputs[| input_d3d_index + 5] = nodeValue("Ambient Light", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_black );
	
	inputs[| input_d3d_index + 6] = nodeValue("Show Background", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false );
	
	inputs[| input_d3d_index + 7] = nodeValue("Backface Culling", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "None", "CW", "CCW" ]);
	
	inputs[| input_d3d_index + 8] = nodeValue("Orthographic Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [ 0.01, 4, 0.01 ]);
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ input_d3d_index + 4,
		["Output",		false], input_d3d_index + 2,
		["Transform",	false], 0, 1,
		["Camera",		false], input_d3d_index + 3, input_d3d_index + 0, input_d3d_index + 1, input_d3d_index + 8, 
		["Render",		false], input_d3d_index + 5, input_d3d_index + 6, input_d3d_index + 7, 
	];
	
	static step = function() {
		var _proj = inputs[| input_d3d_index + 3].getValue();
		
		inputs[| input_d3d_index + 0].setVisible(_proj == 0);
		inputs[| input_d3d_index + 8].setVisible(_proj == 1);
	}
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { #region
		var _pos = _data[0];
		var _rot = _data[1];
		
		var _fov  = _data[input_d3d_index + 0];
		var _clip = _data[input_d3d_index + 1];
		var _dim  = _data[input_d3d_index + 2];
		var _proj = _data[input_d3d_index + 3];
		var _scne = _data[input_d3d_index + 4];
		var _ambt = _data[input_d3d_index + 5];
		var _dbg  = _data[input_d3d_index + 6];
		var _back = _data[input_d3d_index + 7];
		var _orts = _data[input_d3d_index + 8];
		
		setTransform(object, _data);
		if(_scne == noone) return;
		
		camera.position.set(_pos[0], _pos[1], _pos[2]);
		camera.rotation.set(_rot[0], _rot[1], _rot[2], _rot[3]);
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
	
	static getPreviewObject = function() { 
		var _scene = array_safe_get(all_inputs, input_d3d_index + 4, []);
		    _scene = array_safe_get(_scene, preview_index);
		
		return [ object, _scene ]; 
	}
	
	static getPreviewObjectOutline = function() { return [ object ]; }
}