function Node_3D_Sphere(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "3D Sphere";
	dimension_index = 1;
	
	inputs[| 0] = nodeValue("Subdivisions", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [8, 4], "Amount of polygon in X and Y axis.")
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF)
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 2] = nodeValue("Render position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0.5, 0.5 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); }, VALUE_UNIT.reference);
	
	inputs[| 3] = nodeValue("Render rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 4] = nodeValue("Render scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 5] = nodeValue("Textures",	self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 6] = nodeValue("Object scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1, 1 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 7] = nodeValue("Light direction", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.rotation);
		
	inputs[| 8] = nodeValue("Light height", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider, [-1, 1, 0.01]);
		
	inputs[| 9] = nodeValue("Light intensity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	inputs[| 10] = nodeValue("Light color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	inputs[| 11] = nodeValue("Ambient color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_grey);
	
	inputs[| 12] = nodeValue("Object rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
		
	inputs[| 13] = nodeValue("Object position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 14] = nodeValue("Projection", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Orthographic", "Perspective" ])
		.rejectArray();
		
	inputs[| 15] = nodeValue("Field of view", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 60)
		.setDisplay(VALUE_DISPLAY.slider, [ 1, 90, 1 ]);
	
	inputs[| 16] = nodeValue("Scale view with dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true)
	
	input_display_list = [
		["Output",				false], 1, 16, 
		["Geometry",			false], 0,
		["Object transform",	false], 13, 12, 6,
		["Camera",				false], 14, 15, 2, 4, 
		["Texture",				 true], 5,
		["Light",				false], 7, 8, 9, 10, 11,
	];
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	outputs[| 1] = nodeValue("3D scene", self, JUNCTION_CONNECT.output, VALUE_TYPE.d3object, function() { return submit_vertex(); });
	
	outputs[| 2] = nodeValue("Normal pass", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	outputs[| 3] = nodeValue("3D vertex", self, JUNCTION_CONNECT.output, VALUE_TYPE.d3vertex, []);
	output_display_list = [
		0, 2, 1, 3
	]
	
	_3d_node_init(1, /*Transform*/ 2, 4, 13, 12, 6);
	
	subd = [8, 4];
	vertexObjects = [];
	
	static generate_vb = function() {
		var _ox, _oy, _nx, _ny, _ou, _nu;
		
		for( var i = 0, n = array_length(vertexObjects); i < n; i++ ) 
			vertexObjects[i].destroy();
		vertexObjects = [];
		
		var v = new VertexObject();
		
		for( var i = 0; i < subd[0]; i++ )
		for( var j = 0; j < subd[1]; j++ ) {
			var ha0 = (i + 0) / subd[0] * 360;
			var ha1 = (i + 1) / subd[0] * 360;
			var va0 = 90 - (j + 0) / subd[1] * 180;
			var va1 = 90 - (j + 1) / subd[1] * 180;
			
			var h0 = dsin(va0) * 0.5;
			var h1 = dsin(va1) * 0.5;
			var r0 = dcos(va0) * 0.5;
			var r1 = dcos(va1) * 0.5;
			
			var hx0 = dcos(ha0) * r0;
			var hy0 = dsin(ha0) * r0;
			var hz0 = h0;
			
			var hx1 = dcos(ha1) * r0;
			var hy1 = dsin(ha1) * r0;
			var hz1 = h0;
			
			var hx2 = dcos(ha0) * r1;
			var hy2 = dsin(ha0) * r1;
			var hz2 = h1;
			
			var hx3 = dcos(ha1) * r1;
			var hy3 = dsin(ha1) * r1;
			var hz3 = h1;
			
			var u0 = ha0 / 360;
			var v0 = 0.5 + 0.5 * dsin(va0);
			
			var u1 = ha1 / 360;
			var v1 = 0.5 + 0.5 * dsin(va0);
			
			var u2 = ha0 / 360;
			var v2 = 0.5 + 0.5 * dsin(va1);
			
			var u3 = ha1 / 360;
			var v3 = 0.5 + 0.5 * dsin(va1);
			
			v.addFace( [hx0, hz0, hy0], d3_normalize([hx0, hz0, hy0]), [u0, v0], 
			           [hx1, hz1, hy1], d3_normalize([hx1, hz1, hy1]), [u1, v1], 
			           [hx2, hz2, hy2], d3_normalize([hx2, hz2, hy2]), [u2, v2], );
			
			v.addFace( [hx1, hz1, hy1], d3_normalize([hx1, hz1, hy1]), [u1, v1], 
			           [hx2, hz2, hy2], d3_normalize([hx2, hz2, hy2]), [u2, v2], 
			           [hx3, hz3, hy3], d3_normalize([hx3, hz3, hy3]), [u3, v3], );
		}
		
		v.createBuffer();
		vertexObjects[0] = v;
		
	}
	generate_vb();
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		_3d_gizmo(active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static submit_vertex = function(index = 0) {
		var _lpos = getSingleValue(13, index);
		var _lrot = getSingleValue(12, index);
		var _lsca = getSingleValue( 6, index);
		
		var texture	= getSingleValue(5, index);
		_3d_local_transform(_lpos, _lrot, _lsca);
		
		matrix_set(matrix_world, matrix_stack_top());
		vertexObjects[0].submit(texture);
		
		_3d_clear_local_transform();
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		if(_output_index == 3) return vertexObjects;
		
		var _subd = _data[0];
		
		if(_subd[0] != subd[0] || _subd[1] != subd[1]) {
			subd[0] = _subd[0];
			subd[1] = _subd[1];
			generate_vb();	
		}
		
		var _dim	= _data[1];
		var _pos	= _data[2];
		//var _rot	= _data[3];
		var _sca	= _data[4];
		var texture	= _data[5];
		
		var _lpos = _data[13];
		var _lrot = _data[12];
		var _lsca = _data[ 6];
		
		var _ldir = _data[ 7];
		var _lhgt = _data[ 8];
		var _lint = _data[ 9];
		var _lclr = _data[10];
		var _aclr = _data[11];
		
		var _proj = _data[14];
		var _fov  = _data[15];
		var _dimS = _data[16];
		
		inputs[| 15].setVisible(_proj);
		
		var pass = "diff";
		switch(_output_index) {
			case 0 : pass = "diff" break;
			case 2 : pass = "norm" break;
		}
		
		var _transform = new __3d_transform(_pos,, _sca, _lpos, _lrot, _lsca, true, _dimS );
		var _light     = new __3d_light(_ldir, _lhgt, _lint, _lclr, _aclr);
		var _cam	   = new __3d_camera(_proj, _fov);
			
		_outSurf = _3d_pre_setup(_outSurf, _dim, _transform, _light, _cam, pass);
			vertexObjects[0].submit(texture);
		_3d_post_setup();
		
		return _outSurf;
	}
}