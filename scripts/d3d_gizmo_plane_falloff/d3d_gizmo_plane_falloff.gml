function __3dGizmoPlaneFalloff(radius = 0.5, color = c_white, alpha = 1) : __3dGizmo() constructor {
	distance    = 0;
	self.radius = radius;
	self.color  = color;
	self.alpha  = alpha;
	
	static initModel = function() {
		vertex   = [];
		object_counts = 3;
		
		var _d = distance / 2;
		vertex = [
			[
				new __vertex( -radius, -radius, -_d, color, alpha ),
				new __vertex( -radius,  radius, -_d, color, alpha ),
				
				new __vertex( -radius,  radius, -_d, color, alpha ),
				new __vertex(  radius,  radius, -_d, color, alpha ),
				
				new __vertex(  radius,  radius, -_d, color, alpha ),
				new __vertex(  radius, -radius, -_d, color, alpha ),
				
				new __vertex(  radius, -radius, -_d, color, alpha ),
				new __vertex( -radius, -radius, -_d, color, alpha ),
			],
			[
				new __vertex( -radius, -radius,  _d, color, alpha ),
				new __vertex( -radius,  radius,  _d, color, alpha ),
												 
				new __vertex( -radius,  radius,  _d, color, alpha ),
				new __vertex(  radius,  radius,  _d, color, alpha ),
												 
				new __vertex(  radius,  radius,  _d, color, alpha ),
				new __vertex(  radius, -radius,  _d, color, alpha ),
												 
				new __vertex(  radius, -radius,  _d, color, alpha ),
				new __vertex( -radius, -radius,  _d, color, alpha ),
			],
			[
				new __vertex(  0, 0, _d + 0, color, alpha ),
				new __vertex(  0, 0, _d + 1, color, alpha ),
			]
		];
		VB = build();
	} initModel();
	
	onParameterUpdate = initModel;
}