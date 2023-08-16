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
		
		inputs[| input_d3d_index + 8].setVisible(_proj == 1);
	}
	
	static update = function(frame = PROJECT.animator.current_frame) {
		setTransform();
		
		var _pos = inputs[| 0].getValue();
		var _rot = inputs[| 1].getValue();
		
		var _fov  = inputs[| input_d3d_index + 0].getValue();
		var _clip = inputs[| input_d3d_index + 1].getValue();
		var _dim  = inputs[| input_d3d_index + 2].getValue();
		var _proj = inputs[| input_d3d_index + 3].getValue();
		var _scne = inputs[| input_d3d_index + 4].getValue();
		var _ambt = inputs[| input_d3d_index + 5].getValue();
		var _dbg  = inputs[| input_d3d_index + 6].getValue();
		var _back = inputs[| input_d3d_index + 7].getValue();
		var _orts = inputs[| input_d3d_index + 8].getValue();
		
		if(_scne == noone) return;
		
		camera.position.set(_pos[0], _pos[1], _pos[2]);
		camera.rotation.set(_rot[0], _rot[1], _rot[2], _rot[3]);
		camera.projection = _proj;
		
		camera.setViewFov(_fov, _clip[0], _clip[1]);
		if(_proj == 0)		camera.setViewSize(_dim[0], _dim[1]);
		else if(_proj == 1) camera.setViewSize(_dim[0] / _orts, _dim[1] / _orts);
		
		scene.lightAmbient = _ambt;
		
		var _outSurf = outputs[| 0].getValue();
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		outputs[| 0].setValue(_outSurf);
		
		camera.setMatrix();
		
		surface_set_target(_outSurf);
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
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		
	}
	
	static submitShader = function(params = {}, shader = noone) { 
		object.submitShader(params, shader);
		
		var _scne = inputs[| input_d3d_index + 4].getValue(); 
		if(_scne == noone) return; 
		_scne.submitShader(params, shader); 
	}
	
	static submitUI  = function(params = {}, shader = noone) {
		object.submitUI(params, shader);
		
		var _scne = inputs[| input_d3d_index + 4].getValue(); 
		if(_scne == noone) return; 
		_scne.submitUI(params, shader);
	}
		
	static submit    = function(params = {}, shader = noone) {
		object.submit(params, shader);
		
		var _scne = inputs[| input_d3d_index + 4].getValue(); 
		if(_scne == noone) return; 
		_scne.submit(params, shader); 
	}
		
	static submitSel = function(params = {}, shader = noone) { 
		object.submitSel(params, shader); 
	}
		
}