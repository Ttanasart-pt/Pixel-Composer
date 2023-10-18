function Node_3D(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "3D";
	is_3D = true;
	
	w = 64;
	h = 64;
	min_h = h;
	
	mesh_prev_surface = surface_create(64, 64);
	
	static drawOverlay3D = function(active, params, _mx, _my, _snx, _sny, _panel) {}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {}
	static onDrawNode  = function(xx, yy, _mx, _my, _s, _hover, _focus) {}
	
	static getPreviewObject = function() { #region
		if(ds_list_empty(outputs)) return noone;
		
		switch(outputs[| preview_channel].type) {
			case VALUE_TYPE.d3Mesh		: 
			case VALUE_TYPE.d3Light		: 
			case VALUE_TYPE.d3Camera	: 
			case VALUE_TYPE.d3Scene		: break;
			
			default : return noone;
		}
		
		var _obj = outputs[| 0].getValue();
		if(is_array(_obj)) _obj = array_safe_get(_obj, preview_index, noone);
		
		return _obj;
	} #endregion
	
	static getPreviewObjects = function() { return [ getPreviewObject() ]; }
	
	static getPreviewObjectOutline = function() { return getPreviewObjects() }
	
	static refreshPreview = function() { #region
		var _prev_obj = getPreviewObjects();
		
		mesh_prev_surface = surface_verify(mesh_prev_surface, 64, 64);
		surface_set_target(mesh_prev_surface);
			DRAW_CLEAR
			
			gpu_set_zwriteenable(true);
			gpu_set_ztestenable(true);
			gpu_set_cullmode(cull_noculling); 
			
			D3D_GLOBAL_PREVIEW.camera.applyCamera();
			D3D_GLOBAL_PREVIEW.apply();
			
			for( var i = 0, n = array_length(_prev_obj); i < n; i++ ) {
				var _prev = _prev_obj[i];
				if(!is_struct(_prev) || !struct_has(_prev, "getBBOX")) continue;
				
				var _b = _prev.getBBOX();
				var _c = _prev.getCenter();
				if(_b == noone || _c == noone) continue;
				
				D3D_GLOBAL_PREVIEW.custom_transform.position.set(_c._multiply(-1));
				
				var _sca = 1 / _b.getMaximumScale();
				D3D_GLOBAL_PREVIEW.custom_transform.scale.set(_sca);
				
				D3D_GLOBAL_PREVIEW.submitUI(_prev);
			}
		surface_reset_target();
		
		D3D_GLOBAL_PREVIEW.camera.resetCamera();
	} #endregion
	
	static postUpdate = function() { refreshPreview(); }
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover = false, _focus = false) { #region
		if(!is_surface(mesh_prev_surface)) return;
		
		var bbox = drawGetBbox(xx, yy, _s);
		draw_surface_bbox(mesh_prev_surface, bbox);
	} #endregion
}