function Node_3D_Mesh_Sphere_UV(_x, _y, _group = noone) : Node_3D_Mesh(_x, _y, _group) constructor {
	name     = "3D UV Sphere";
	
	object_class = __3dUVSphere;
	
	newInput(in_mesh + 0, nodeValue_Int("Horizontal Slices", self, 8 ))
		.setValidator(VV_min(2));
	
	newInput(in_mesh + 1, nodeValue_Int("Vertical Slices", self, 16 ))
		.setValidator(VV_min(3));
	
	newInput(in_mesh + 2, nodeValue_D3Material("Material", self, new __d3dMaterial()))
		.setVisible(true, true);
	
	newInput(in_mesh + 3, nodeValue_Bool("Smooth Normal", self, false ));
	
	newInput(in_mesh + 4, nodeValue_Enum_Scroll("Projection", self, 0, [ "Lambert", "Equirectangular" ] ));
	
	input_display_list = [
		__d3d_input_list_mesh, in_mesh + 0, in_mesh + 1, in_mesh + 4,  
		__d3d_input_list_transform,
		["Material",	false], in_mesh + 3, in_mesh + 2, 
	]
	
	static processData = function(_output, _data, _array_index = 0) {
		var _sideH = _data[in_mesh + 0];
		var _sideV = _data[in_mesh + 1];
		var _mat   = _data[in_mesh + 2];
		var _smt   = _data[in_mesh + 3];
		var _proj  = _data[in_mesh + 4];
		
		var object = getObject(_array_index);
		object.checkParameter({ hori: _sideH, vert: _sideV, smooth: _smt, projection: _proj });
		object.materials = [ _mat ];
		
		setTransform(object, _data);
		
		return object;
	}
	
	static getPreviewValues = function() { return getSingleValue(in_mesh + 1); }
}