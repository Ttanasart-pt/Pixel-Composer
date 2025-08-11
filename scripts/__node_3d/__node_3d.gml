function Node_3D(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "3D";
	is_3D = NODE_3D.polygon;
	dimension_index = -1;
	
	mesh_prev_surface = noone;
	
	static drawOverlay3D = function(active, params, _mx, _my, _snx, _sny, _panel) {}
	
	static processData = function(_outSurf, _data, _array_index) {}
	static onDrawNode  = function(xx, yy, _mx, _my, _s, _hover, _focus) {}
	
	static getPreviewObject = function() {
		if(array_empty(outputs)) return noone;
		
		switch(outputs[preview_channel].type) {
			case VALUE_TYPE.d3Mesh		: 
			case VALUE_TYPE.d3Light		: 
			case VALUE_TYPE.d3Camera	: 
			case VALUE_TYPE.d3Scene		: break;
			
			default : return noone;
		}
		
		var _obj = outputs[0].getValue();
		if(is_array(_obj)) _obj = array_safe_get_fast(_obj, preview_index, noone);
		
		return _obj;
	}
	
	static getPreviewObjects = function() { return [ getPreviewObject() ]; }
	
	static getPreviewObjectOutline = function() { return getPreviewObjects() }
	
	static refreshPreview = function() {
		var _prev_obj = getPreviewObjects();
		
		surface_depth_disable(false);
		mesh_prev_surface = surface_verify(mesh_prev_surface, PREFERENCES.node_3d_preview_size, PREFERENCES.node_3d_preview_size);
		
		surface_set_target(mesh_prev_surface);
			DRAW_CLEAR
			
			gpu_set_zwriteenable(true);
			gpu_set_ztestenable(true);
			gpu_set_cullmode(cull_noculling); 
			
			D3D_GLOBAL_PREVIEW.camera.applyCamera();
			D3D_GLOBAL_PREVIEW.apply();
			
			for( var i = 0, n = array_length(_prev_obj); i < n; i++ ) {
				var _prev = _prev_obj[i];
				if(!has(_prev, "getBBOX")) continue;
				
				var _b = _prev.getBBOX();
				var _c = _prev.getCenter();
				if(_b == noone || _c == noone) continue;
				
				D3D_GLOBAL_PREVIEW.custom_transform.position.set(_c._multiply(-1));
				
				var _sca = 2 / _b.getScale();
				
				D3D_GLOBAL_PREVIEW.custom_transform.scale.set(_sca);
				D3D_GLOBAL_PREVIEW.submit(_prev);
			}
		surface_reset_target();
		surface_depth_disable(true);
		
		D3D_GLOBAL_PREVIEW.camera.resetCamera();
	}
	
	static postProcess = function() /*=>*/ { if(!IS_PLAYING) refreshPreview(); }
	
	static getGraphPreviewSurface = function() { return mesh_prev_surface; }
	
	static onDrawNodeOver = function(xx, yy, _mx, _my, _s, _hover = false, _focus = false) { }
}