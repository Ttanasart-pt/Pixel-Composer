function __3dLight() : __3dObject() constructor {
	UI_vertex = [ array_create(33) ];
	for( var i = 0; i <= 32; i++ ) 
		UI_vertex[0][i] = new __vertex(0, lengthdir_x(0.5, i / 32 * 360), lengthdir_y(0.5, i / 32 * 360), c_white);
	VB_UI = build(noone, UI_vertex);
	
	color = c_white;
	intensity = 1;
	
	shadow_mapper = sh_d3d_shadow_depth;
	shadow_active = false;
	shadow_map    = noone;
	shadow_map_size   = 1024;
	shadow_map_scale  = 4;
	shadow_map_camera = camera_create();
	shadow_map_view   = array_create(16, 0);
	shadow_map_proj   = array_create(16, 0);
	shadow_bias	  = 0.001;
	
	static getCenter = function() /*=>*/ {return new __vec3(transform.position.x, transform.position.y, transform.position.z)};
	static getBBOX   = function() /*=>*/ {return new __bbox3D(new __vec3(-1,-1,-1), new __vec3(1,1,1))};
	
	static submit    = function(scene = {}, shader = noone) {}
	
	static setShadow = function(active, shadowMapSize, shadowMapScale = shadow_map_scale) {
		shadow_active    = active;
		shadow_map_size  = shadowMapSize;
		shadow_map_scale = shadowMapScale;
		
		return self;
	}
	
	static shadowProjectBegin = function() {}
	
	static shadowProjectEnd = function() {} 
	
	static submitShadow = function(scene, objects) {
		if(!shadow_active) return;
		
		shadowProjectBegin();
		objects.submit(scene, shadow_mapper);
		shadowProjectEnd();
	}
}