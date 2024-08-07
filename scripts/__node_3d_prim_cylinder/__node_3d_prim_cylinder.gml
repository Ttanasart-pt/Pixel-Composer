function __Node_3D_Cylinder(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "3D Cylinder";
	batch_output = false;
	dimension_index = 2;
	
	inputs[| 0] = nodeValue_Int("Sides", self, 16);
	
	inputs[| 1] = nodeValue_Float("Thickness", self, 0.2);
		
	inputs[| 2] = nodeValue_Dimension(self);
	
	inputs[| 3] = nodeValue_Vector("Render position", self, [ 0.5, 0.5 ])
		.setUnitRef(function(index) { return getDimension(index); }, VALUE_UNIT.reference);
	
	inputs[| 4] = nodeValue_Vector("Render rotation", self, [ 0, 0, 0 ]);
	
	inputs[| 5] = nodeValue_Vector("Render scale", self, [ 1, 1 ]);
	
	inputs[| 6] = nodeValue_Surface("Textures top",	self);
	inputs[| 7] = nodeValue_Surface("Textures bottom", self);
	inputs[| 8] = nodeValue_Surface("Textures side",	self);
	
	inputs[| 9] = nodeValue_Vector("Object scale", self, [ 1, 1, 1 ]);
	
	inputs[| 10] = nodeValue_Rotation("Light direction", self, 0);
		
	inputs[| 11] = nodeValue_Float("Light height", self, 0.5)
		.setDisplay(VALUE_DISPLAY.slider, { range: [-1, 1, 0.01] });
		
	inputs[| 12] = nodeValue_Float("Light intensity", self, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 13] = nodeValue_Color("Light color", self, c_white);
	inputs[| 14] = nodeValue_Color("Ambient color", self, c_grey);
	
	inputs[| 15] = nodeValue_Vector("Object rotation", self, [ 0, 0, 0 ]);
		
	inputs[| 16] = nodeValue_Vector("Object position", self, [ 0, 0, 0 ]);
	
	inputs[| 17] = nodeValue_Enum_Button("Projection", self,  0, [ "Orthographic", "Perspective" ])
		.rejectArray();
		
	inputs[| 18] = nodeValue_Float("Field of view", self, 60)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 1, 90, 0.1 ] });
		
	inputs[| 19] = nodeValue_Float("Taper", self, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 20] = nodeValue_Bool("Scale view with dimension", self, true)
	
	input_display_list = [
		["Output",				false], 2, 20, 
		["Geometry",			false], 0, 1, 19,
		["Object transform",	false], 16, 15, 9,
		["Camera",				false], 17, 18, 3, 5, 
		["Texture",				 true], 6, 7, 8,
		["Light",				false], 10, 11, 12, 13, 14,
	];
	
	outputs[| 0] = nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone);
	
	outputs[| 1] = nodeValue_Output("3D scene", self, VALUE_TYPE.d3object, function() { return submit_vertex(); });
	
	outputs[| 2] = nodeValue_Output("Normal pass", self, VALUE_TYPE.surface, noone);
	
	outputs[| 3] = nodeValue_Output("3D vertex", self, VALUE_TYPE.d3vertex, []);
	
	output_display_list = [
		0, 2, 1, 3
	]
	
	_3d_node_init(2, /*Transform*/ 3, 5, 16, 15, 9);
	
	sides = 16;
	taper = 1;
	thick =  0.5;
	vertexObjects = [];
	
	static generate_vb = function() {
		var _ox, _oy, _nx, _ny, _ou, _nu;
		
		for( var i = 0, n = array_length(vertexObjects); i < n; i++ ) 
			vertexObjects[i].destroy();
		vertexObjects = [];
		
		var top = new VertexObject();
		for(var i = 0; i <= sides; i++)  {
			_nx = lengthdir_x(0.5, i * 360 / sides);
			_ny = lengthdir_y(0.5, i * 360 / sides);
			
			if(i) {
				top.addFace( [  0, thick / 2,   0], [0, 1, 0], [  0 + 0.5,   0 + 0.5], 
				             [_ox, thick / 2, _oy], [0, 1, 0], [_ox + 0.5, _oy + 0.5], 
				             [_nx, thick / 2, _ny], [0, 1, 0], [_nx + 0.5, _ny + 0.5], );
			}
			
			_ox = _nx;
			_oy = _ny;
		}
		
		top.createBuffer();
		vertexObjects[0] = top;
		
		var sid = new VertexObject();
		for(var i = 0; i <= sides; i++)  {
			_nx = lengthdir_x(0.5, i * 360 / sides);
			_ny = lengthdir_y(0.5, i * 360 / sides);
			_nu = i / sides;
			
			var nrm_y = 1 - taper;
			
			if(i) {
				sid.addFace( [_ox * taper, -thick / 2, _oy * taper], [_nx, nrm_y, _ny], [_ou, 0], 
				             [_ox,          thick / 2, _oy        ], [_nx, nrm_y, _ny], [_ou, 1], 
				             [_nx,          thick / 2, _ny        ], [_nx, nrm_y, _ny], [_nu, 1], );
																	        
				sid.addFace( [_nx,          thick / 2, _ny        ], [_nx, nrm_y, _ny], [_nu, 1], 
				             [_nx * taper, -thick / 2, _ny * taper], [_nx, nrm_y, _ny], [_nu, 0], 
				             [_ox * taper, -thick / 2, _oy * taper], [_nx, nrm_y, _ny], [_ou, 0], );
			}
			
			_ox = _nx;
			_oy = _ny;
			_ou = _nu;
		}
		
		sid.createBuffer();
		vertexObjects[1] = sid;
	}
	generate_vb();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		PROCESSOR_OVERLAY_CHECK
		
		_3d_gizmo(active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static submit_vertex = function(index = 0) {
		var _lpos = getSingleValue(16, index);
		var _lrot = getSingleValue(15, index);
		var _lsca = getSingleValue( 9, index);
		
		var face_top	= getSingleValue(6, index);
		var face_bot	= getSingleValue(7, index);
		var face_sid	= getSingleValue(8, index);
		
		_3d_local_transform(_lpos, _lrot, _lsca);
		
		matrix_set(matrix_world, matrix_stack_top());
		vertexObjects[0].submit(face_top);
				
		matrix_stack_push(matrix_build(0, -thick, 0, 0, 0, 0, taper, 1, taper));
		matrix_set(matrix_world, matrix_stack_top());
		vertexObjects[0].submit(face_bot);
		matrix_stack_pop();
				
		matrix_set(matrix_world, matrix_stack_top());
		vertexObjects[1].submit(face_sid);
		
		_3d_clear_local_transform();
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		if(_output_index == 3) return vertexObjects;
		
		var _sides = _data[0];
		var _thick = _data[1];
		var _taper = _data[19];
		
		if(_sides != sides || _thick != thick || _taper != taper) {
			sides = _sides;
			thick = _thick;
			taper = _taper;
			generate_vb();	
		}
		
		var _dim		= _data[2];
		var _pos		= _data[3];
		//var _rot		= _data[4];
		var _sca		= _data[5];
		var face_top	= _data[6];
		var face_bot	= _data[7];
		var face_sid	= _data[8];
		
		var _lpos = _data[16];
		var _lrot = _data[15];
		var _lsca = _data[ 9];
		
		var _ldir = _data[10];
		var _lhgt = _data[11];
		var _lint = _data[12];
		var _lclr = _data[13];
		var _aclr = _data[14];
		
		var _proj = _data[17];
		var _fov  = _data[18];
		var _dimS = _data[20];
		
		inputs[| 18].setVisible(_proj);
		
		var pass = "diff";
		switch(_output_index) {
			case 0 : pass = "diff" break;
			case 2 : pass = "norm" break;
		}
		
		var _transform = new __3d_transform(_pos,, _sca, _lpos, _lrot, _lsca, true, _dimS );
		var _light     = new __3d_light(_ldir, _lhgt, _lint, _lclr, _aclr);
		var _cam	   = new __3d_camera(_proj, _fov);
			
		_outSurf = _3d_pre_setup(_outSurf, _dim, _transform, _light, _cam, pass);
		
		matrix_set(matrix_world, matrix_stack_top());
		vertexObjects[0].submit(face_top);
				
		matrix_stack_push(matrix_build(0, -thick, 0, 0, 0, 0, taper, 1, taper));
		matrix_set(matrix_world, matrix_stack_top());
		vertexObjects[0].submit(face_bot);
		matrix_stack_pop();
				
		matrix_set(matrix_world, matrix_stack_top());
		vertexObjects[1].submit(face_sid);
		
		_3d_post_setup();
		
		return _outSurf;
	}
}