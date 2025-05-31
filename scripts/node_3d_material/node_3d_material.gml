function Node_3D_Material(_x, _y, _group = noone) : Node_3D(_x, _y, _group) constructor {
	name  = "3D Material";
	is_3D = NODE_3D.none;
	solid_surf = noone;
	
	newInput(0, nodeValue_Surface("Texture"))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Slider("Diffuse", 1 ));
	
	newInput(2, nodeValue_Slider("Specular", 0 ));
	
	newInput(3, nodeValue_Float("Shininess", 1 ));
	
	newInput(4, nodeValue_Bool("Metalic", false ));
	
	newInput(5, nodeValue_Surface("Normal Map"));
	
	newInput(6, nodeValue_Slider("Normal Strength", 1, [ 0, 2, 0.01 ] ));
		
	newInput(7, nodeValue_Slider("Roughness", 1 ));
	
	newInput(8, nodeValue_Bool("Anti aliasing", false ));
	
	newInput(9, nodeValue_Vec2("Scale", [ 1, 1 ] ));
	
	newInput(10, nodeValue_Vec2("Shift", [ 0, 0 ] ));
	
	newOutput(0, nodeValue_Output("Material", VALUE_TYPE.d3Material, noone));
	
	input_display_list = [ 
		["Texture",		false], 0, 8, 9, 10, 
		["Properties",	false], 1, 2, 3, 4, 7,
		["Normal",		false], 5, 6,
	];
	
	static processData = function(_output, _data, _array_index = 0) {
		var _surf = _data[0];
		var _diff = _data[1];
		var _spec = _data[2];
		var _shin = _data[3];
		var _metl = _data[4];
		var _nor  = _data[5];
		var _norS = _data[6];
		var _roug = _data[7];
		var _aa   = _data[8];
		var _scal = _data[9];
		var _shft = _data[10];
		
		if(!is_surface(_surf)) {
			solid_surf = surface_verify(solid_surf, 1, 1);
			_surf = solid_surf;
		}
		
		var _mat = new __d3dMaterial(_surf);
		_mat.diffuse   = _diff;
		_mat.specular  = _spec;
		_mat.shine     = _shin;
		_mat.metalic   = _metl;
		_mat.texFilter = _aa;
		_mat.texScale  = _scal;
		_mat.texShift  = _shft;
		
		_mat.normal    = _nor;
		_mat.normalStr = _norS;
		_mat.reflective = clamp(1 - _roug, 0, 1);
		
		return _mat;
	}
	
	static getPreviewValues       = function() /*=>*/ {return inputs[0].getValue()};
	static getGraphPreviewSurface = function() /*=>*/ {return getSingleValue(0)};
}