function __3dCylinder(radius = 0.5, height = 1, sides = 8, smooth = false) : __3dObject() constructor {
	VF = global.VF_POS_NORM_TEX_COL;
	render_type = pr_trianglelist;
	
	self.radius = radius;
	self.height = height;
	self.sides  = sides;
	self.smooth = smooth;
		
	static initModel = function() {
		var v0 = array_create(3 * sides);
		var v1 = array_create(3 * sides);
		var n0 = array_create(3 * sides);
		var n1 = array_create(3 * sides);
		var u0 = array_create(3 * sides);
		var u1 = array_create(3 * sides);
		
		var _h = height / 2;
		
		for( var i = 0; i < sides; i++ ) {
			var a0 = (i + 0) / sides * 360;
			var a1 = (i + 1) / sides * 360;
			
			var x0 = lengthdir_x(radius, a0);
			var y0 = lengthdir_y(radius, a0);
			var x1 = lengthdir_x(radius, a1);
			var y1 = lengthdir_y(radius, a1);
			
			v0[i * 3 + 0] = [ 0,  0,  _h];
			v0[i * 3 + 1] = [x0, y0,  _h];
			v0[i * 3 + 2] = [x1, y1,  _h];
			
			v1[i * 3 + 0] = [ 0,  0, -_h];
			v1[i * 3 + 1] = [x0, y0, -_h];
			v1[i * 3 + 2] = [x1, y1, -_h];
			
			n0[i * 3 + 0] = [ 0,  0,   1];
			n0[i * 3 + 1] = [ 0,  0,   1];
			n0[i * 3 + 2] = [ 0,  0,   1];
			
			n1[i * 3 + 0] = [ 0,  0,  -1];
			n1[i * 3 + 1] = [ 0,  0,  -1];
			n1[i * 3 + 2] = [ 0,  0,  -1];
			
			var _u0 = 0.5 + lengthdir_x(0.5, a0);
			var _v0 = 0.5 + lengthdir_y(0.5, a0);
			var _u1 = 0.5 + lengthdir_x(0.5, a1);
			var _v1 = 0.5 + lengthdir_y(0.5, a1);
			
			u0[i * 3 + 0] = [ 0.5,  0.5];
			u0[i * 3 + 1] = [ _u0,  _v0];
			u0[i * 3 + 2] = [ _u1,  _v1];
			
			u1[i * 3 + 0] = [ 0.5,  0.5];
			u1[i * 3 + 1] = [ _u0,  _v0];
			u1[i * 3 + 2] = [ _u1,  _v1];
		}
		
		var vs = array_create(3 * sides * 2);
		var ns = array_create(3 * sides * 2);
		var us = array_create(3 * sides * 2);
		
		for( var i = 0; i < sides; i++ ) {
			var a0 = (i + 0) / sides * 360;
			var a1 = (i + 1) / sides * 360;
			
			var x0 = lengthdir_x(radius, a0);
			var y0 = lengthdir_y(radius, a0);
			var x1 = lengthdir_x(radius, a1);
			var y1 = lengthdir_y(radius, a1);
			
			vs[i * 3 * 2 + 0] = [x0, y0,  _h];
			vs[i * 3 * 2 + 1] = [x1, y1,  _h];
			vs[i * 3 * 2 + 2] = [x0, y0, -_h];
			
			vs[i * 3 * 2 + 3] = [x0, y0, -_h];
			vs[i * 3 * 2 + 4] = [x1, y1,  _h];
			vs[i * 3 * 2 + 5] = [x1, y1, -_h];
			
			var nx0 = smooth? lengthdir_x(1, a0) : lengthdir_x(1, (a0 + a1) / 2);
			var ny0 = smooth? lengthdir_y(1, a0) : lengthdir_y(1, (a0 + a1) / 2);
			var nx1 = smooth? lengthdir_x(1, a1) : lengthdir_x(1, (a0 + a1) / 2);
			var ny1 = smooth? lengthdir_y(1, a1) : lengthdir_y(1, (a0 + a1) / 2);
			
			ns[i * 3 * 2 + 0] = [nx0, ny0, 0];
			ns[i * 3 * 2 + 1] = [nx1, ny1, 0];
			ns[i * 3 * 2 + 2] = [nx0, ny0, 0];
			
			ns[i * 3 * 2 + 3] = [nx0, ny0, 0];
			ns[i * 3 * 2 + 4] = [nx1, ny1, 0];
			ns[i * 3 * 2 + 5] = [nx1, ny1, 0];
			
			var ux0 = (i + 0) / sides;
			var ux1 = (i + 1) / sides;
			
			us[i * 3 * 2 + 0] = [ux0, 0];
			us[i * 3 * 2 + 1] = [ux1, 0];
			us[i * 3 * 2 + 2] = [ux0, 1];
			
			us[i * 3 * 2 + 3] = [ux0, 1];
			us[i * 3 * 2 + 4] = [ux1, 0];
			us[i * 3 * 2 + 5] = [ux1, 1];		
		}
		
		vertex	= [ v0, v1, vs ];
		normals = [ n0, n1, ns ];
		uv		= [ u0, u1, us ];
	
		VB = build();
	} initModel();
	
	static onParameterUpdate = initModel;
}