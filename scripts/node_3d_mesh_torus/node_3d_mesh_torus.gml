function Node_3D_Mesh_Torus(_x, _y, _group = noone) : Node_3D_Mesh(_x, _y, _group) constructor {
	name = "3D torus";
	object_class = __3dTorus;
	
	var i = in_mesh;
	newInput(i+0, nodeValue_Int(      "Toroidal Slices",  16 )).setValidator(VV_min(3));
	newInput(i+1, nodeValue_Int(      "Poloidal Slices",  8  )).setValidator(VV_min(3));
	newInput(i+2, nodeValue_Float(    "Toroidal Radius",  1  ));
	newInput(i+3, nodeValue_Slider(   "Poloidal Radius", .2  ));
	newInput(i+6, nodeValue_Rotation( "Toroidal Angle",   0  ));
	newInput(i+7, nodeValue_Rotation( "Poloidal Angle",   0  ));
	newInput(i+8, nodeValue_Float(    "Twist",            0  ));
	
	newInput(i+5, nodeValue_Bool(       "Smooth Normal", false ));
	newInput(i+4, nodeValue_D3Material( "Material", new __d3dMaterial() )).setVisible(true, true);
	// i+9
	
	input_display_list = [
		__d3d_input_list_mesh, i+0, i+1, i+2, i+3, i+6, i+7, i+8, 
		__d3d_input_list_transform,
		["Material",	false], i+5, i+4, 
	]
	
	static processData = function(_output, _data, _array_index = 0) {
		var _sideT = _data[in_mesh + 0];
		var _sideP = _data[in_mesh + 1];
		var _radT  = _data[in_mesh + 2];
		var _radP  = _data[in_mesh + 3];
		var _angT  = _data[in_mesh + 6];
		var _angP  = _data[in_mesh + 7];
		var _twst  = _data[in_mesh + 8];
		
		var _smt   = _data[in_mesh + 5];
		var _mat   = _data[in_mesh + 4];
		
		var object = getObject(_array_index);
		object.checkParameter({ 
			sideT  : _sideT,
			sideP  : _sideP,
			radT   : _radT,
			radP   : _radP,
			angT   : _angT,
			angP   : _angP,
			twist  : _twst, 
			
			smooth : _smt,
		});
		object.materials = [ _mat ];
		
		setTransform(object, _data);
		
		return object;
	}
	
	static getPreviewValues = function() { return getSingleValue(in_mesh + 4); }
}