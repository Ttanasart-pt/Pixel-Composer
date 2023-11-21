enum CAMERA_PROJECTION {
	perspective,
	orthograph
}

function __3dCamera() constructor {
	position = new __vec3();
	rotation = new BBMOD_Quaternion();
	focus    = new __vec3();
	up       = new __vec3(0, 0, -1);
	
	raw = camera_create();
	
	useFocus = true;
	focus_angle_x = 0;
	focus_angle_y = 0;
	focus_dist    = 1;
	
	projection = CAMERA_PROJECTION.perspective;
	
	fov = 60;
	view_near = .01;
	view_far  =  50;
	
	view_w = 1;
	view_h = 1;
	view_aspect = 1;
	
	viewMat = new __mat4();
	projMat = new __mat4();
	
	static getUp = function(_x = 1, _y = 1, _z = 1) { #region
		var upVector = new __vec3(0, 0, -1);
    
	    var hRad = degtorad(focus_angle_x);
	    var vRad = degtorad(focus_angle_y);
		
	    upVector.x = -sin(hRad) *  sin(vRad) * _x;
	    upVector.y =  cos(hRad) * -sin(vRad) * _y;
	    upVector.z =  cos(vRad) * _z;
		
	    return upVector._normalize();
	} #endregion
	
	static getCombinedMatrix = function() { return matrix_multiply(viewMat.raw, projMat.raw); }
	
	static applyCamera = function() { #region
		camera_set_view_mat(raw, viewMat.raw);
		camera_set_proj_mat(raw, projMat.raw);
		
		camera_apply(raw);
	} #endregion
	
	static resetCamera = function() { #region
		camera_apply(0);
		gpu_set_cullmode(cull_noculling); 
	} #endregion
	
	static setMatrix = function() { #region
		if(projection == CAMERA_PROJECTION.perspective)
			projMat.setRaw(matrix_build_projection_perspective_fov(fov, view_aspect, view_near, view_far));
		else
			projMat.setRaw(matrix_build_projection_ortho(view_w, view_h, view_near, view_far));
		
		if(useFocus)
			viewMat.setRaw(matrix_build_lookat(position.x, position.y, position.z, focus.x, focus.y, focus.z, up.x, up.y, up.z));
		else {
			var _for = rotation.Rotate(new BBMOD_Vec3( 1.0,  0.0,  0.0));
			var _up  = rotation.Rotate(new BBMOD_Vec3( 0.0,  0.0, -1.0));
			
			viewMat.setRaw(matrix_build_lookat(position.x, position.y, position.z, 
											   position.x + _for.X, position.y + _for.Y, position.z + _for.Z, 
											   _up.X, _up.Y, _up.Z));
		}
		
		return self;
	} #endregion
	
	static setFocusAngle = function(ax, ay, dist) { #region
		if(ay % 90 == 0) ay += 0.01;
		
		focus_angle_x = ax;
		focus_angle_y = ay;
		focus_dist    = dist;
		
		return self;
	} #endregion
	
	static setViewFov = function(fov, near, far) { #region
		self.fov = fov;
		self.view_near = near;
		self.view_far  = far;
		
		return self;
	} #endregion
	
	static setViewSize = function(w, h) { #region
		view_w = w;
		view_h = h;
		view_aspect = w / h;
		
		return self;
	} #endregion
	
	static setCameraLookRotate = function() { #region
		var _fPos = d3d_PolarToCart(focus.x, focus.y, focus.z, focus_angle_x, focus_angle_y, focus_dist);
		position.set(_fPos);
	} #endregion
	
	static worldPointToViewPoint = function(vec3) { #region
		var _vec4 = new __vec4().set(vec3, 1);
		var _view = viewMat.transpose().multiplyVector(_vec4);
		var _proj = projMat.transpose().multiplyVector(_view);
		
		_proj._divide(_proj.w);
		_proj.x = view_w / 2 + _proj.x * view_w / 2;
		_proj.y = view_h / 2 + _proj.y * view_h / 2;
		
		return _proj;
	} #endregion
	
	static viewPointToWorldRay = function(_x, _y) { #region
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
	} #endregion
}