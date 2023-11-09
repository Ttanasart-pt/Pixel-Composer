function __3dGizmoPlane(radius = 0.5, color = c_white, alpha = 1) : __3dGizmo() constructor {
	object_counts = 2;
	
	vertex = [
		[
			new __vertex( -radius, -radius, 0, color, alpha ),
			new __vertex( -radius,  radius, 0, color, alpha ),
			
			new __vertex( -radius,  radius, 0, color, alpha ),
			new __vertex(  radius,  radius, 0, color, alpha ),
			
			new __vertex(  radius,  radius, 0, color, alpha ),
			new __vertex(  radius, -radius, 0, color, alpha ),
			
			new __vertex(  radius, -radius, 0, color, alpha ),
			new __vertex( -radius, -radius, 0, color, alpha ),
		],
		[
			new __vertex(  0, 0, 0, color, alpha ),
			new __vertex(  0, 0, 1, color, alpha ),
		]
	];
	VB = build();
}