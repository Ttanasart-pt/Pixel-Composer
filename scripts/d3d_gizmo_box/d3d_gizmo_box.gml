function __3dGizmoBox(span = 0.5, color = c_white, alpha = 1) : __3dGizmo() constructor {
	vertex = [[
		new __vertex( -span, -span, -span, color, alpha ),
		new __vertex(  span, -span, -span, color, alpha ),
		
		new __vertex( -span,  span, -span, color, alpha ),
		new __vertex(  span,  span, -span, color, alpha ),
		
		new __vertex( -span, -span, -span, color, alpha ),
		new __vertex( -span,  span, -span, color, alpha ),
		
		new __vertex(  span, -span, -span, color, alpha ),
		new __vertex(  span,  span, -span, color, alpha ),
		
		new __vertex( -span, -span,  span, color, alpha ),
		new __vertex(  span, -span,  span, color, alpha ),
		
		new __vertex( -span,  span,  span, color, alpha ),
		new __vertex(  span,  span,  span, color, alpha ),
		
		new __vertex( -span, -span,  span, color, alpha ),
		new __vertex( -span,  span,  span, color, alpha ),
		
		new __vertex(  span, -span,  span, color, alpha ),
		new __vertex(  span,  span,  span, color, alpha ),
		
		new __vertex( -span, -span, -span, color, alpha ),
		new __vertex( -span, -span,  span, color, alpha ),
		
		new __vertex( -span,  span, -span, color, alpha ),
		new __vertex( -span,  span,  span, color, alpha ),
		
		new __vertex(  span, -span, -span, color, alpha ),
		new __vertex(  span, -span,  span, color, alpha ),
		
		new __vertex(  span,  span, -span, color, alpha ),
		new __vertex(  span,  span,  span, color, alpha ),
	]];
	
	VB = build();
}