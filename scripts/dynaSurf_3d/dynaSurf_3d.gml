function dynaSurf_3d() : dynaSurf() constructor {
	object = noone;
	
	camera    = new __3dCamera();
	camTarget = new __vec3();
	camera_ay = 45;
	
	scene  = new __3dScene(camera, "Dynamic surf scene");
	
	w = 1;
	h = 1;
	
	surfaces  = array_create(4);
	deferData = noone;
	
	static getWidth  = function() { return w; }
	static getHeight = function() { return h; }
	
	static draw = function(_x = 0, _y = 0, _xs = 1, _ys = 1, _rot = 0, _col = c_white, _alp = 1) {
		var _sw = w * _xs;
		var _sh = h * _xs;
		
		#region view
			var _pos, _blend = 1;
			
			_pos = d3d_PolarToCart(camTarget.x, camTarget.y, camTarget.z, _rot, camera_ay, camera.focus_dist);
			
			camera.position.set(_pos);
			camera.focus.set(camTarget);
			
			camera.setViewSize(_sw, _sh);
			camera.setMatrix();
		#endregion
		
		#region background
			//surface_free_safe(surfaces[0]);
			//surfaces[0] = scene.renderBackground(_sw, _sh, surfaces[0]);
		#endregion
		
		#region surfaces
			surfaces[1] = surface_verify(surfaces[1], _sw, _sh);
			surfaces[2] = surface_verify(surfaces[2], _sw, _sh);
			surfaces[3] = surface_verify(surfaces[3], _sw, _sh);
			deferData   = scene.deferPass(object, _sw, _sh, deferData);
		#endregion
		
		#region submit
			var _px = point_rotate(0, 0, _sw / 2, _sh / 2, _rot);
			var _xx = _x - _px[0];
			var _yy = _y - _px[1];
			
			surface_set_target_ext(0, surfaces[1]);
			surface_set_target_ext(1, surfaces[2]);
			surface_set_target_ext(2, surfaces[3]);
			
			DRAW_CLEAR
			
			camera.setMatrix();
			scene.reset();
			gpu_set_cullmode(cull_counterclockwise); 
				
			object.submitShader(scene);
			object.submitShadow(scene, object);
			scene.apply(deferData);
			
			gpu_set_cullmode(cull_noculling); 
			surface_reset_target();
		#endregion
		
		#region draw
			//if(scene.draw_background)
			//	draw_surface_safe(surfaces[0], _xx, _yy);
			draw_surface_safe(surfaces[1], _xx, _yy);
			
			BLEND_MULTIPLY
			draw_surface_safe(deferData.ssao, _xx, _yy);
			BLEND_NORMAL
		#endregion
	}
	
	static drawTile = function(_x = 0, _y = 0, _xs = 1, _ys = 1, _col = c_white, _alp = 1) {}
	
	static drawPart = function(_l, _t, _w, _h, _x, _y, _xs = 1, _ys = 1, _rot = 0, _col = c_white, _alp = 1) {}
}