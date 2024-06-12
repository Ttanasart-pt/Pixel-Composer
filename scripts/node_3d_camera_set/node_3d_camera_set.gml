function Node_3D_Camera_Set(_x, _y, _group = noone) : Node_3D_Camera(_x, _y, _group) constructor {
	name = "3D Camera Set";
	
	light_key  = new __3dLightDirectional();
	light_fill = new __3dLightDirectional();
	
	inputs[| in_cam + 0] = nodeValue("L1 H angle", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 30 )
		.setName("Horizontal angle")
		.setDisplay(VALUE_DISPLAY.rotation);
	
	inputs[| in_cam + 1] = nodeValue("L1 V angle", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 45 )
		.setName("Vertical angle")
		.setDisplay(VALUE_DISPLAY.slider, { range: [0, 90, 0.1] });
	
	inputs[| in_cam + 2] = nodeValue("L1 Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white )
		.setName("Color")
	
	inputs[| in_cam + 3] = nodeValue("L1 Intensity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1 )
		.setName("Intensity")
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| in_cam + 4] = nodeValue("L2 H angle", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, -45 )
		.setName("Horizontal angle")
		.setDisplay(VALUE_DISPLAY.rotation);
	
	inputs[| in_cam + 5] = nodeValue("L2 V angle", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 45 )
		.setName("Vertical angle")
		.setDisplay(VALUE_DISPLAY.slider, { range: [0, 90, 0.1] });
	
	inputs[| in_cam + 6] = nodeValue("L2 Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white )
		.setName("Color")
	
	inputs[| in_cam + 7] = nodeValue("L2 Intensity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.25 )
		.setName("Intensity")
		.setDisplay(VALUE_DISPLAY.slider);
	
	array_append(input_display_list, [
		["Key light",  false], in_cam + 0, in_cam + 1, in_cam + 2, in_cam + 3, 
		["Fill light", false], in_cam + 4, in_cam + 5, in_cam + 6, in_cam + 7, 
	]);
	
	static submitShadow = function() { #region
		light_key.submitShadow(scene, light_key);
		light_fill.submitShadow(scene, light_fill);
	} #endregion
	
	static submitShader = function() { #region
		scene.submitShader(light_key);
		scene.submitShader(light_fill);
	} #endregion
	
	static preProcessData = function(_data) { #region
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
	} #endregion
	
	static getPreviewObjects = function() { #region 
		var _scene = array_safe_get_fast(all_inputs, in_d3d + 4, noone);
		if(is_array(_scene)) _scene = array_safe_get_fast(_scene, preview_index, noone);
		
		return [ object, lookat, lookLine, lookRad, _scene, light_key, light_fill ];
	} #endregion
	
}