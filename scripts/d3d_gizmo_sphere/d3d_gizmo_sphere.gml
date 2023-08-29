function __3dGizmoSphere(radius = 0.5, color = c_white, alpha = 1) : __3dGizmo() constructor {
	vertex = [ array_create(33 * 3) ];
	
	var _i = 0;
	for( var i = 0; i <= 32; i++ ) {
		var a0 = (i + 0) / 32 * 360;
		var a1 = (i + 1) / 32 * 360;
		var x0 = lengthdir_x(radius, a0);
		var y0 = lengthdir_y(radius, a0);
		var x1 = lengthdir_x(radius, a1);
		var y1 = lengthdir_y(radius, a1);
		
		vertex[0][_i++] = new __vertex( 0, x0, y0, color, alpha );
		vertex[0][_i++] = new __vertex( 0, x1, y1, color, alpha );
		vertex[0][_i++] = new __vertex( x0, 0, y0, color, alpha );
		vertex[0][_i++] = new __vertex( x1, 0, y1, color, alpha );
		vertex[0][_i++] = new __vertex( x0, y0, 0, color, alpha );
		vertex[0][_i++] = new __vertex( x1, y1, 0, color, alpha );
	}
	
	VB = build();
}