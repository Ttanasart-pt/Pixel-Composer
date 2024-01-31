function __3dCylinder_noCaps(radius = 0.5, height = 1, sides = 8, smooth = false) : __3dObject() constructor {
	VF = global.VF_POS_NORM_TEX_COL;
	render_type   = pr_trianglelist;
	object_counts = 1;
	
	self.radius = radius;
	self.height = height;
	self.sides  = sides;
	self.smooth = smooth;
		
	static initModel = function() {
		var vs = array_create(3 * sides * 2);
		var _h = height / 2;
		
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
			
			var ux0 = (i + 0) / sides;
			var ux1 = (i + 1) / sides;
			
			vs[i * 3 * 2 + 0] = new __vertex(x0, y0,  _h).setNormal(nx0, ny0, 0).setUV(ux0, 0);
			vs[i * 3 * 2 + 1] = new __vertex(x0, y0, -_h).setNormal(nx0, ny0, 0).setUV(ux0, 1);
			vs[i * 3 * 2 + 2] = new __vertex(x1, y1,  _h).setNormal(nx1, ny1, 0).setUV(ux1, 0);
														  					  
			vs[i * 3 * 2 + 3] = new __vertex(x0, y0, -_h).setNormal(nx0, ny0, 0).setUV(ux0, 1);
			vs[i * 3 * 2 + 4] = new __vertex(x1, y1, -_h).setNormal(nx1, ny1, 0).setUV(ux1, 1);
			vs[i * 3 * 2 + 5] = new __vertex(x1, y1,  _h).setNormal(nx1, ny1, 0).setUV(ux1, 0);	
		}
		
		vertex	= [ vs ];
	
		VB = build();
	} initModel();
	
	static onParameterUpdate = initModel;
}