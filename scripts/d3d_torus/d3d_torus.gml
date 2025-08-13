function __3dTorus(_radT = 1, _radP = .2, _sideT = 16, _sideP = 8, _smooth = false) : __3dObject() constructor {
	VF = global.VF_POS_NORM_TEX_COL;
	render_type   = pr_trianglelist;
	object_counts = 1;
	
	radT   = _radT;
	radP   = _radP;
	sideT  = _sideT;
	sideP  = _sideP;
	smooth = _smooth;
	twist  = 0;
	angT   = 0;
	angP   = 0;
		
	static initModel = function() {
		edges   = [];
		var eid = 0;
		var vs  = [];
		var ix  = 0;
		
		for( var i = 0; i < sideT; i++ ) {
			var aT0 = (i + 0) / sideT * 360 + angT;
			var aT1 = (i + 1) / sideT * 360 + angT;
			
			var _lt0_x = lengthdir_x(1, aT0);
			var _lt0_y = lengthdir_y(1, aT0);
			var _lt1_x = lengthdir_x(1, aT1);
			var _lt1_y = lengthdir_y(1, aT1);
			
			var xT0 = _lt0_x * radT;
			var yT0 = _lt0_y * radT;
			var xT1 = _lt1_x * radT;
			var yT1 = _lt1_y * radT;
			var tws = twist;
			
			for( var j = 0; j < sideP; j++ ) {
				var aP00 = (j + 0) / sideP * 360 + angP;
				var aP01 = (j + 1) / sideP * 360 + angP;
				
				var aP10 = (j + 0 + tws) / sideP * 360 + angP;
				var aP11 = (j + 1 + tws) / sideP * 360 + angP;
				
				var xP0 = lengthdir_x(radP, aP00);
				var x0  = _lt0_x * (radT + xP0);
				var y0  = _lt0_y * (radT + xP0);
				var z0  = lengthdir_y(radP, aP00);
				
				var xP0 = lengthdir_x(radP, aP10);
				var x1  = _lt1_x * (radT + xP0);
				var y1  = _lt1_y * (radT + xP0);
				var z1  = lengthdir_y(radP, aP10);
				
				var xP1 = lengthdir_x(radP, aP11);
				var x2  = _lt1_x * (radT + xP1);
				var y2  = _lt1_y * (radT + xP1);
				var z2  = lengthdir_y(radP, aP11);
				
				var xP1 = lengthdir_x(radP, aP01);
				var x3  = _lt0_x * (radT + xP1);
				var y3  = _lt0_y * (radT + xP1);
				var z3  = lengthdir_y(radP, aP01);
				
				var ux0 = 1 - (i + 0) / sideT;
				var ux1 = 1 - (i + 1) / sideT;
				var uy0 = 1 - (j + 0) / sideP;
				var uy1 = 1 - (j + 1) / sideP;
				
				if(smooth) {
					var nx0 = x0 - xT0;
					var ny0 = y0 - yT0;
					var nz0 = z0;
					
					var nx1 = x1 - xT1;
					var ny1 = y1 - yT1;
					var nz1 = z1;
					
					var nx2 = x2 - xT1;
					var ny2 = y2 - yT1;
					var nz2 = z2;
					
					var nx3 = x3 - xT0;
					var ny3 = y3 - yT0;
					var nz3 = z3;
					
				} else {
					var nx0 = (x0 + x1 + x2 + x3) / 4 - (xT0 + xT1) / 2;
					var ny0 = (y0 + y1 + y2 + y3) / 4 - (yT0 + yT1) / 2;
					var nz0 = (z0 + z1 + z2 + z3) / 4;
					
					var nx1 = nx0;
					var ny1 = ny0;
					var nz1 = nz0;
					
					var nx2 = nx0;
					var ny2 = ny0;
					var nz2 = nz0;
					
					var nx3 = nx0;
					var ny3 = ny0;
					var nz3 = nz0;
					
				}
				
				vs[ix++] = new __vertex(x0, y0, z0).setNormal(nx0, ny0, nz0).setUV(ux0, uy0);
				vs[ix++] = new __vertex(x2, y2, z2).setNormal(nx2, ny2, nz2).setUV(ux1, uy1);
				vs[ix++] = new __vertex(x1, y1, z1).setNormal(nx1, ny1, nz1).setUV(ux1, uy0);
				
				vs[ix++] = new __vertex(x0, y0, z0).setNormal(nx0, ny0, nz0).setUV(ux0, uy0);	
				vs[ix++] = new __vertex(x3, y3, z3).setNormal(nx3, ny3, nz3).setUV(ux0, uy1);
				vs[ix++] = new __vertex(x2, y2, z2).setNormal(nx2, ny2, nz2).setUV(ux1, uy1);
				
				edges[eid++] = new __3dObject_Edge([x0, y0, z0], [x1, y1, z1]);
				edges[eid++] = new __3dObject_Edge([x1, y1, z1], [x2, y2, z2]);
				edges[eid++] = new __3dObject_Edge([x2, y2, z2], [x3, y3, z3]);
				edges[eid++] = new __3dObject_Edge([x3, y3, z3], [x0, y0, z0]);
			}
		}
		
		edges  = [ edges ];
		vertex = [ vs ];
		VB = build();
	} 
	
	initModel();
	
	static onParameterUpdate = initModel;
}