function __3dGizmoAxis(_size = .5, color = c_white, alpha = 1) : __3dGizmo() constructor {
	vertex = [
		[
			new __vertex( -_size, 0, 0, color, alpha ),
			new __vertex(  _size, 0, 0, color, alpha ),
		],
		[
			new __vertex( 0, -_size, 0, color, alpha ),
			new __vertex( 0,  _size, 0, color, alpha ),
		],
		[
			new __vertex( 0, 0, -_size, color, alpha ),
			new __vertex( 0, 0,  _size, color, alpha ),
		],
	];
	object_counts = 3;
	VB = build();
}