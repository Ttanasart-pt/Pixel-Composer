function Node_3D_Mesh_Wall_Builder(_x, _y, _group = noone) : Node_3D_Mesh(_x, _y, _group) constructor {
	name = "3D Wall";
	object_class = __3dWall_builder;
	
	newInput(in_mesh + 0, nodeValue_PathNode("Path", self, noone))
		.setVisible(true, true);
	
	newInput(in_mesh + 1, nodeValue_Int("Segments", self, 16 ));
	
	newInput(in_mesh + 2, nodeValue_Float("Height", self, 1 ));
	
	newInput(in_mesh + 3, nodeValue_Float("Thickness", self, 0.1 ))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(in_mesh + 4, nodeValue_Bool("Material per side", self, false ));
	
	newInput(in_mesh + 5, nodeValue_D3Material("Side Material", self, new __d3dMaterial()))
		.setVisible(true, true);
	
	newInput(in_mesh + 6, nodeValue_Float("Path Scale", self, .01 ));
	
	newInput(in_mesh + 7, nodeValue_D3Material("Side Material 2", self, new __d3dMaterial()))
		.setVisible(true, true);
	
	newInput(in_mesh + 8, nodeValue_D3Material("Cap Material", self, new __d3dMaterial()))
		.setVisible(true, true);
	
	newInput(in_mesh + 9, nodeValue_Bool("Loop", self, false ));
	
	input_display_list = [
		__d3d_input_list_mesh, in_mesh + 0, in_mesh + 6, in_mesh + 9, in_mesh + 1, in_mesh + 2, in_mesh + 3,  
		__d3d_input_list_transform,
		["Material",	false], in_mesh + 4, in_mesh + 5, in_mesh + 7, in_mesh + 8, 
	]
	
	static processData = function(_output, _data, _output_index, _array_index = 0) {
		var _paths   = _data[in_mesh + 0];
		var _segment = _data[in_mesh + 1];
		var _loop    = _data[in_mesh + 9];
		var _height  = _data[in_mesh + 2];
		var _thick   = _data[in_mesh + 3];
		var _pscale  = _data[in_mesh + 6];
		
		var _side2    = _data[in_mesh + 4];
		var _mat_sid  = _data[in_mesh + 5];
		var _mat_sid2 = _data[in_mesh + 7];
		var _mat_cap  = _data[in_mesh + 8];
		
		inputs[in_mesh + 7].setVisible(_side2, _side2);
		
		if(_paths == noone) return noone;
		
		var points = array_create(_segment + 1);
		var p = new __vec2P();
		
		for( var i = 0; i <= _segment; i++ ) {
			p = _paths.getPointRatio(i / _segment, 0, p);
			points[i] = [ p.x * _pscale, -p.y * _pscale ];
		}
		
		var object = getObject(_array_index);
		object.checkParameter({
			points :  points,
			offset : _thick,
			height : _height,
			loop   : _loop,
		});
		object.materials = _side2? [ _mat_sid, _mat_sid2, _mat_cap, _mat_cap ] : [ _mat_sid, _mat_sid, _mat_cap, _mat_cap ];
		
		setTransform(object, _data);
		
		return object;
	}
	
	static getPreviewValues = function() { return getSingleValue(in_mesh + 5); }
}