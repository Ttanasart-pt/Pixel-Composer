function __3dGizmoLine(from, to, color = c_white, alpha = 1) : __3dGizmo() constructor {
	vertex = [[
		V3( from.x, from.y, from.z, color, alpha ),
		V3(   to.x,   to.y,   to.z, color, alpha ),
	]];
	VB = build();
}