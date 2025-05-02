function __Node_3D_Cone(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "3D Cone";
	batch_output = false;
	
	newInput(0, nodeValue_Dimension(self));
	
	newInput(1, nodeValue_Vec2("Render position", self, [ 0.5, 0.5 ]))
		.setUnitRef(function(index) { return getDimension(index); }, VALUE_UNIT.reference);
	
	newInput(2, nodeValue_Vec3("Render rotation", self, [ 0, 0, 0 ]));
	
	newInput(3, nodeValue_Vec2("Render scale", self, [ 1, 1 ]));
	
	newInput(4, nodeValue_Vec3("Object scale", self, [ 1, 1, 1 ]));
	
	newInput(5, nodeValue_Rotation("Light direction", self, 0));
		
	newInput(6, nodeValue_Float("Light height", self, 0.5))
		.setDisplay(VALUE_DISPLAY.slider, { range: [-1, 1, 0.01] });
		
	newInput(7, nodeValue_Float("Light intensity", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(8, nodeValue_Color("Light color", self, ca_white));
	newInput(9, nodeValue_Color("Ambient color", self, cola(c_grey)));
	
	newInput(10, nodeValue_Vec3("Object rotation", self, [ 0, 0, 0 ]));
		
	newInput(11, nodeValue_Vec3("Object position", self, [ 0, 0, 0 ]));
	
	newInput(12, nodeValue_Enum_Button("Projection", self,  0, [ "Orthographic", "Perspective" ]))
		.rejectArray();
		
	newInput(13, nodeValue_Float("Field of view", self, 60))
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 1, 90, 0.1 ] });
	
	newInput(14, nodeValue_Int("Sides", self, 16));
	
	newInput(15, nodeValue_Surface("Textures base",	self));
	
	newInput(16, nodeValue_Surface("Textures side", self));
	
	newInput(17, nodeValue_Bool("Scale view with dimension", self, true))
	
	input_display_list = [
		["Output", 				false], 0, 17, 
		["Geometry",			false], 14, 
		["Object transform",	false], 11, 10, 4,
		["Camera",				false], 12, 13, 1, 3, 
		["Texture",				 true], 15, 16, 
		["Light",				false], 5, 6, 7, 8, 9,
	];
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	newOutput(1, nodeValue_Output("3D scene", self, VALUE_TYPE.d3object, function() { return submit_vertex(); }));
	
	newOutput(2, nodeValue_Output("Normal pass", self, VALUE_TYPE.surface, noone));
	
	newOutput(3, nodeValue_Output("3D vertex", self, VALUE_TYPE.d3vertex, []));
	
	output_display_list = [
		0, 2, 1, 3
	]
	
	_3d_node_init(0, /*Transform*/ 1, 3, 11, 10, 4);
	
	sides = 16;
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
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		PROCESSOR_OVERLAY_CHECK
		
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
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
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
		
		inputs[13].setVisible(_proj);
		
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