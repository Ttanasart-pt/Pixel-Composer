function __3dLight() : __3dObject() constructor {
	UI_vertex = array_create(33);
	for( var i = 0; i <= 32; i++ ) UI_vertex[i] = V3(0, lengthdir_x(0.5, i / 32 * 360), lengthdir_y(0.5, i / 32 * 360), c_yellow, 0.8);
	VB_UI = build(noone, UI_vertex);
	
	color = c_white;
	intensity = 1;
	
	shadow_mapper = sh_d3d_shadow_depth;
	shadow_active = false;
	shadow_map    = noone;
	shadow_map_size   = 1024;
	shadow_map_scale  = 256;
	shadow_map_camera = camera_create();
	shadow_map_view   = array_create(16, 0);
	shadow_map_proj   = array_create(16, 0);
	
	static getCenter = function() { return noone; }
	static getBBOX   = function() { return noone; }
	
	static submit    = function(params = {}, shader = noone) {}
	
	static setShadow = function(active, shadowMapSize, shadowMapScale = shadow_map_scale) { #region
		shadow_active    = active;
		shadow_map_size  = shadowMapSize;
		shadow_map_scale = shadowMapScale;
		
		return self;
	} #endregion
	
	static shadowProjectBegin = function() {}
	
	static shadowProjectEnd = function() {} 
	
	static shadowProjectVertex = function(scene, objects) { #region
		if(!shadow_active) return;
		
		shadowProjectBegin();
		for( var i = 0, n = array_length(objects); i < n; i++ ) {
			var _prev = objects[i];
			if(_prev == noone) continue;
			_prev.submit(scene, shadow_mapper);
		}
		shadowProjectEnd();
	} #endregion
}