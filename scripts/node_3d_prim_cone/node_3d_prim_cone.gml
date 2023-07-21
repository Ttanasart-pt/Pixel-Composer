function Node_3D_Cone(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "3D Cone";
	
	inputs[| 0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF)
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue("Render position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0.5, 0.5 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); }, VALUE_UNIT.reference);
	
	inputs[| 2] = nodeValue("Render rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 3] = nodeValue("Render scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 4] = nodeValue("Object scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1, 1 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 5] = nodeValue("Light direction", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.rotation);
		
	inputs[| 6] = nodeValue("Light height", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider, [-1, 1, 0.01]);
		
	inputs[| 7] = nodeValue("Light intensity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	inputs[| 8] = nodeValue("Light color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	inputs[| 9] = nodeValue("Ambient color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_grey);
	
	inputs[| 10] = nodeValue("Object rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
		
	inputs[| 11] = nodeValue("Object position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 12] = nodeValue("Projection", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Orthographic", "Perspective" ])
		.rejectArray();
		
	inputs[| 13] = nodeValue("Field of view", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 60)
		.setDisplay(VALUE_DISPLAY.slider, [ 1, 90, 1 ]);
	
	inputs[| 14] = nodeValue("Sides", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 16);
	
	inputs[| 15] = nodeValue("Textures base",	self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 16] = nodeValue("Textures side", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 17] = nodeValue("Scale view with dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true)
	
	input_display_list = [
		["Output", 				false], 0, 17, 
		["Geometry",			false], 14, 
		["Object transform",	false], 11, 10, 4,
		["Camera",				false], 12, 13, 1, 3, 
		["Texture",				 true], 15, 16, 
		["Light",				false], 5, 6, 7, 8, 9,
	];
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	outputs[| 1] = nodeValue("3D scene", self, JUNCTION_CONNECT.output, VALUE_TYPE.d3object, function() { return submit_vertex(); });
	
	outputs[| 2] = nodeValue("Normal pass", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	outputs[| 3] = nodeValue("3D vertex", self, JUNCTION_CONNECT.output, VALUE_TYPE.d3vertex, []);
	
	output_display_list = [
		0, 2, 1, 3
	]
	
	_3d_node_init(0, /*Transform*/ 1, 3, 11, 10, 4);
	
	sides = 16;
	vertexObjects = [];
	
	static generate_vb = function() {
		var _ox, _oy, _nx, _ny, _ou, _nu;
		
		for( var i = 0; i < array_length(vertexObjects); i++ ) 
			vertexObjects[i].destroy();
		vertexObjects = [];
		
		var top = new VertexObject();
		for(var i = 0; i <= sides; i++)  {
			_nx = lengthdir_x(0.5, i * 360 / sides);
			_ny = lengthdir_y(0.5, i * 360 / sides);
			
			if(i) {
				top.addFace( [  0, 0.5,   0], [0, 1, 0], [  0 + 0.5,   0 + 0.5], 
				             [_ox, 0.5, _oy], [0, 1, 0], [_ox + 0.5, _oy + 0.5], 
				             [_nx, 0.5, _ny], [0, 1, 0], [_nx + 0.5, _ny + 0.5], );
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
			
			if(i) {
				sid.addFace( [  0, -0.5,   0], [_nx, -0.5, _ny], [_nu, 1], 
				             [_nx,  0.5, _ny], [_nx, -0.5, _ny], [_nu, 0], 
				             [_ox,  0.5, _oy], [_nx, -0.5, _ny], [_ou, 0], );
			}
			
			_ox = _nx;
			_oy = _ny;
			_ou = _nu;
		}
		
		sid.createBuffer();
		vertexObjects[1] = sid;
		
	}
	generate_vb();
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		_3d_gizmo(active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static submit_vertex = function(index = 0) {
		var _lpos = getSingleValue(11, index);
		var _lrot = getSingleValue(10, index);
		var _lsca = getSingleValue( 4, index);
		
		var face_bas	= getSingleValue(15, index);
		var face_sid	= getSingleValue(16, index);
		
		_3d_local_transform(_lpos, _lrot, _lsca);
		
		matrix_set(matrix_world, matrix_stack_top());
		vertexObjects[0].submit(face_bas);
		vertexObjects[1].submit(face_sid);
		
		_3d_clear_local_transform();
	}
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		if(_output_index == 3) return vertexObjects;
		
		var _sides = _data[14];
		
		if(_sides != sides) {
			sides = _sides;
			generate_vb();	
		}
		
		var _dim		= _data[0];
		var _pos		= _data[1];
		var _sca		= _data[3];
		
		var face_bas	= _data[15];
		var face_sid	= _data[16];
		
		var _lpos = _data[11];
		var _lrot = _data[10];
		var _lsca = _data[ 4];
		
		var _ldir = _data[5];
		var _lhgt = _data[6];
		var _lint = _data[7];
		var _lclr = _data[8];
		var _aclr = _data[9];
		
		var _proj = _data[12];
		var _fov  = _data[13];
		var _dimS = _data[17];
		
		inputs[| 13].setVisible(_proj);
		
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
		vertexObjects[0].submit(face_bas);
		vertexObjects[1].submit(face_sid);
		
		_3d_post_setup();
		
		return _outSurf;
	}
}