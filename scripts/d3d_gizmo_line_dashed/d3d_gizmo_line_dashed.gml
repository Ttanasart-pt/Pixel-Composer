function __3dGizmoLineDashed(from, to, dash = 0.1, color = c_white, alpha = 1) : __3dGizmo() constructor {
	var _dist = from.distance(to);
	var _dash = max(2, ceil(_dist / dash));
	
	vertex = [ array_create(_dash) ];
	for( var i = 0; i < _dash; i++ ) {
		var prog = i / (_dash - 1);
		vertex[0][i] = V3( lerp(from.x, to.x, prog),
				   		   lerp(from.y, to.y, prog),
						   lerp(from.z, to.z, prog),
						   color, alpha );
	}
	VB = build();
}