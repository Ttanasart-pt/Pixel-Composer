function __3dCone(radius = 0.5, height = 1, sides = 8, smooth = false) : __3dObject() constructor {
	VF = global.VF_POS_NORM_TEX_COL;
	render_type = pr_trianglelist;
	object_counts = 2;
	
	self.radius = radius;
	self.height = height;
	self.sides  = sides;
	self.smooth = smooth;
		
	static initModel = function() {
		var v0 = array_create(3 * sides);
		var vs = array_create(3 * sides);
		
		var _h = height / 2;
		
		for( var i = 0; i < sides; i++ ) {
			var a0 = (i + 0) / sides * 360;
			var a1 = (i + 1) / sides * 360;
			
			var x0 = lengthdir_x(radius, a0);
			var y0 = lengthdir_y(radius, a0);
			var x1 = lengthdir_x(radius, a1);
			var y1 = lengthdir_y(radius, a1);
			
			var _u0 = 0.5 + lengthdir_x(0.5, a0);
			var _v0 = 0.5 + lengthdir_y(0.5, a0);
			var _u1 = 0.5 + lengthdir_x(0.5, a1);
			var _v1 = 0.5 + lengthdir_y(0.5, a1);
			
			v0[i * 3 + 0] = V3( 0,  0, -_h).setNormal(0, 0, -1).setUV(0.5,  0.5);
			v0[i * 3 + 1] = V3(x1, y1, -_h).setNormal(0, 0, -1).setUV(_u1,  _v1);
			v0[i * 3 + 2] = V3(x0, y0, -_h).setNormal(0, 0, -1).setUV(_u0,  _v0);
		}
		
		for( var i = 0; i < sides; i++ ) {
			var a0 = (i + 0) / sides * 360;
			var a1 = (i + 1) / sides * 360;
			
			var x0 = lengthdir_x(radius, a0);
			var y0 = lengthdir_y(radius, a0);
			var x1 = lengthdir_x(radius, a1);
			var y1 = lengthdir_y(radius, a1);
			
			var nx0 = smooth? lengthdir_x(1, a0) : lengthdir_x(1, (a0 + a1) / 2);
			var ny0 = smooth? lengthdir_y(1, a0) : lengthdir_y(1, (a0 + a1) / 2);
			var nx1 = smooth? lengthdir_x(1, a1) : lengthdir_x(1, (a0 + a1) / 2);
			var ny1 = smooth? lengthdir_y(1, a1) : lengthdir_y(1, (a0 + a1) / 2);
			var nxc = lengthdir_x(1, (a0 + a1) / 2);
			var nyc = lengthdir_y(1, (a0 + a1) / 2);
			var r2  = radius * radius;
			var h2  = height * height;
			var nz  = r2 / (r2 + h2);
			
			var ux0 = (i + 0) / sides;
			var ux1 = (i + 1) / sides;
			
			vs[i * 3 + 0] = V3( 0,  0,  _h).setNormal(nxc, nyc, nz).setUV(ux0, 0);
			vs[i * 3 + 1] = V3(x0, y0, -_h).setNormal(nx0, ny0, nz).setUV(ux0, 1);
			vs[i * 3 + 2] = V3(x1, y1, -_h).setNormal(nx1, ny1, nz).setUV(ux1, 0);
		}
		
		vertex	= [ v0, vs ];
		
		VB = build();
		generateNormal();
	} initModel();
	
	static onParameterUpdate = initModel;
}