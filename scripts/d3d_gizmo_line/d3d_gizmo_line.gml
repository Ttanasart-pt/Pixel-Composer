function __3dGizmoLine(from, to, color = c_white, alpha = 1) : __3dGizmo() constructor {
	vertex = [[
		new __vertex( from.x, from.y, from.z, color, alpha ),
		new __vertex(   to.x,   to.y,   to.z, color, alpha ),
	]];
	VB = build();
}