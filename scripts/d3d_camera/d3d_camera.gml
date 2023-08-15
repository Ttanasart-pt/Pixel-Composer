function __3dCamera() constructor {
	position = new __vec3();
	focus    = new __vec3();
	up       = new __vec3(0, 0, -1);
	
	focus_angle_x = 0;
	focus_angle_y = 0;
	focus_dist    = 1;
	
	fov = 60;
	view_near = 1;
	view_far  = 32000;
	
	view_w = 1;
	view_h = 1;
	view_aspect = 1;
	
	viewMat = new __mat4();
	projMat = new __mat4();
	
	static getUp = function() {
		var upVector = new __vec3(0, 0, 0);
    
	    var hRad = degtorad(focus_angle_x);
	    var vRad = degtorad(focus_angle_y);
		
	    upVector.x = -sin(hRad) *  sin(vRad);
	    upVector.y =  cos(hRad) * -sin(vRad);
	    upVector.z =  cos(vRad);
		
	    return upVector._normalize();
	}
	
	static applyCamera = function(cam) {
		camera_set_proj_mat(cam, projMat.raw);
		camera_set_view_mat(cam, viewMat.raw);
		
		camera_apply(cam);
	}
	
	static setMatrix = function() {
		projMat.setRaw(matrix_build_projection_perspective_fov(fov, view_aspect, view_near, view_far));
		viewMat.setRaw(matrix_build_lookat(position.x, position.y, position.z, focus.x, focus.y, focus.z, up.x, up.y, up.z));
		
		return self;
	}
	
	static setFocusAngle = function(ax, ay, dist) {
		focus_angle_x = ax;
		focus_angle_y = ay;
		focus_dist    = dist;
		
		return self;
	}
	
	static setViewFov = function(fov, near = view_near, far = view_far) {
		self.fov = fov;
		self.view_near = near;
		self.view_far  = far;
		
		return self;
	}
	
	static setViewSize = function(w, h) {
		view_w = w;
		view_h = h;
		view_aspect = w / h;
		
		return self;
	}
	
	static worldPointToViewPoint = function(vec3) {
		var _vec4 = new __vec4().set(vec3, 1);
		var _view = viewMat.transpose().multiplyVector(_vec4);
		var _proj = projMat.transpose().multiplyVector(_view);
		
		_proj._divide(_proj.w);
		_proj.x = view_w / 2 + _proj.x * view_w / 2;
		_proj.y = view_h / 2 + _proj.y * view_h / 2;
		
		return _proj;
	}
	
	static viewPointToWorldRay = function(_x, _y) {
		var rayOrigin = position;
		
	    var normalizedX = (2 * _x / view_w) - 1;
	    var normalizedY = 1 - (2 * _y / view_h);
		
	    var tanFOV  = tan(degtorad(fov) * 0.5);
		var _up     = getUp();
		var forward = focus.subtract(position)._normalize();
		var right   = forward.cross(_up)._normalize();
		
	    var rayDirection = forward.add(right.multiply(normalizedX * tanFOV * view_aspect))
								  .add(_up.multiply(normalizedY * tanFOV))
								  ._normalize();
    
	    return new __ray(rayOrigin, rayDirection);
	}
}