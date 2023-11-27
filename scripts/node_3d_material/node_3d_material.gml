function Node_3D_Material(_x, _y, _group = noone) : Node_3D(_x, _y, _group) constructor {
	name = "3D Material";
	solid_surf = noone;
	
	inputs[| 0] = nodeValue("Texture", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone )
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Diffuse", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1 )
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 2] = nodeValue("Specular", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0 )
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 3] = nodeValue("Shininess", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1 );
	
	inputs[| 4] = nodeValue("Metalic", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false );
	
	inputs[| 5] = nodeValue("Normal Map", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone );
	
	inputs[| 6] = nodeValue("Normal Strength", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1 )
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 2, 0.01 ] });
		
	inputs[| 7] = nodeValue("Roughness", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1 )
		.setDisplay(VALUE_DISPLAY.slider);
	
	outputs[| 0] = nodeValue("Material", self, JUNCTION_CONNECT.output, VALUE_TYPE.d3Material, noone);
	
	input_display_list = [ 0, 
		["Properties",	false], 1, 2, 3, 4, 7, 
		["Normal",		false], 5, 6, 
	];
	
	static processData = function(_output, _data, _output_index, _array_index = 0) {
		var _surf = _data[0];
		var _diff = _data[1];
		var _spec = _data[2];
		var _shin = _data[3];
		var _metl = _data[4];
		var _nor  = _data[5];
		var _norS = _data[6];
		var _roug = _data[7];
		
		if(!is_surface(_surf)) {
			solid_surf = surface_verify(solid_surf, 1, 1);
			_surf = solid_surf;
		}
		
		var _mat = new __d3dMaterial(_surf);
		_mat.diffuse   = _diff;
		_mat.specular  = _spec;
		_mat.shine     = _shin;
		_mat.metalic   = _metl;
		
		_mat.normal    = _nor;
		_mat.normalStr = _norS;
		_mat.reflective = clamp(1 - _roug, 0, 1);
		
		return _mat;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		if(!previewable) return;
		
		var bbox  = drawGetBbox(xx, yy, _s);
		var _mat  = outputs[| 0].getValue();
		
		if(_mat == noone) return;
		
		if(is_array(_mat)) {
			if(array_empty(_mat)) return;
			_mat = _mat[0];
		}
		
		if(is_instanceof(_mat, __d3dMaterial) && is_surface(_mat.surface)) {
			var aa   = 0.5 + 0.5 * renderActive;
			if(!isHighlightingInGraph()) aa *= 0.25;
		
			draw_surface_bbox(_mat.surface, bbox,, aa);
		}
	}
}