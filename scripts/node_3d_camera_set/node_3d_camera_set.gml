function Node_3D_Camera_Set(_x, _y, _group = noone) : Node_3D_Camera(_x, _y, _group) constructor {
	name = "3D Camera Set";
	
	dimension_index = in_d3d + 2;
	light_key  = new __3dLightDirectional();
	light_fill = new __3dLightDirectional();
	
	newInput(in_cam + 0, nodeValue_Rotation("L1 H angle", 30))
		.setName("Horizontal angle");
	
	newInput(in_cam + 1, nodeValue_Float("L1 V angle", 45 ))
		.setName("Vertical angle")
		.setDisplay(VALUE_DISPLAY.slider, { range: [0, 90, 0.1] });
	
	newInput(in_cam + 2, nodeValue_Color("L1 Color", ca_white ))
		.setName("Color")
	
	newInput(in_cam + 3, nodeValue_Float("L1 Intensity", 1 ))
		.setName("Intensity")
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(in_cam + 4, nodeValue_Rotation("L2 H angle", -45))
		.setName("Horizontal angle");
	
	newInput(in_cam + 5, nodeValue_Float("L2 V angle", 45 ))
		.setName("Vertical angle")
		.setDisplay(VALUE_DISPLAY.slider, { range: [0, 90, 0.1] });
	
	newInput(in_cam + 6, nodeValue_Color("L2 Color", ca_white ))
		.setName("Color")
	
	newInput(in_cam + 7, nodeValue_Float("L2 Intensity", 0.25 ))
		.setName("Intensity")
		.setDisplay(VALUE_DISPLAY.slider);
	
	array_append(input_display_list, [
		["Key light",  false], in_cam + 0, in_cam + 1, in_cam + 2, in_cam + 3, 
		["Fill light", false], in_cam + 4, in_cam + 5, in_cam + 6, in_cam + 7, 
	]);
	
	static submitShadow = function() {
		light_key.submitShadow(scene, light_key);
		light_fill.submitShadow(scene, light_fill);
	}
	
	static submitShader = function() {
		scene.submitShader(light_key);
		scene.submitShader(light_fill);
	}
	
	static preProcessData = function(_data) {
		var _han = _data[in_cam + 0];
		var _van = _data[in_cam + 1];
		var _col = _data[in_cam + 2];
		var _int = _data[in_cam + 3];
		
		var pos = d3d_PolarToCart(0, 0, 0, _han, _van, 4)
		light_key.transform.position.set(pos.x, pos.y, pos.z);
		var _rot = new __rot3().lookAt(light_key.transform.position, new __vec3());
		light_key.transform.rotation.FromEuler(_rot.x, _rot.y, _rot.z);
		
		light_key.color	    = _col;
		light_key.intensity = _int;
		
		var _han = _data[in_cam + 4];
		var _van = _data[in_cam + 5];
		var _col = _data[in_cam + 6];
		var _int = _data[in_cam + 7];
		
		var pos = d3d_PolarToCart(0, 0, 0, _han, _van, 4)
		light_fill.transform.position.set(pos.x, pos.y, pos.z);
		var _rot = new __rot3().lookAt(light_fill.transform.position, new __vec3());
		light_fill.transform.rotation.FromEuler(_rot.x, _rot.y, _rot.z);
		
		light_fill.color	 = _col;
		light_fill.intensity = _int;
	}
	
	static getPreviewObjects = function() { 
		var _scene = getSingleValue(in_d3d + 4);
		return [ object, lookat, lookLine, lookRad, _scene, light_key, light_fill ];
	}
	
}