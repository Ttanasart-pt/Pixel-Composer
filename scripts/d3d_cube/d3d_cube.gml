function __3dCube() : __3dObject() constructor {
	VF = global.VF_POS_NORM_TEX_COL;
	render_type   = pr_trianglelist;
	object_counts = 1;
	
	separate_faces = false;
	taper_amount = 0;
	taper_axis   = 0;
	
	static __default_cube = function() {
		var p = [[ -1, -1, -1 ],
	             [  1, -1, -1 ],
	             [ -1,  1, -1 ],
	             [  1,  1, -1 ],
	         
	             [ -1, -1,  1 ],
	             [  1, -1,  1 ],
	             [ -1,  1,  1 ],
	             [  1,  1,  1 ]];
		
		if(taper_amount != 0) {
			for( var i = 0, n = array_length(p); i < n; i++ ) {
				var _p = p[i];
				var _t = _p[taper_axis] * taper_amount;
				
				_p[(taper_axis + 1) % 3] += sign(_p[(taper_axis + 1) % 3]) * _t;
				_p[(taper_axis + 2) % 3] += sign(_p[(taper_axis + 2) % 3]) * _t;
			}
		}
		
		for( var i = 0, n = array_length(p); i < n; i++ ) { p[i][0] /= 2; p[i][1] /= 2; p[i][2] /= 2; }
		
		return [
			[
				new __vertex(p[4]).setNormal(0, 0, 1).setUV(1, 1), 
				new __vertex(p[7]).setNormal(0, 0, 1).setUV(0, 0), 
				new __vertex(p[5]).setNormal(0, 0, 1).setUV(0, 1),
		    																  
				new __vertex(p[4]).setNormal(0, 0, 1).setUV(1, 1), 
				new __vertex(p[6]).setNormal(0, 0, 1).setUV(1, 0), 
				new __vertex(p[7]).setNormal(0, 0, 1).setUV(0, 0),
			],	
			[  
				new __vertex(p[0]).setNormal(0, 0, -1).setUV(1, 1), 
				new __vertex(p[1]).setNormal(0, 0, -1).setUV(0, 1), 
				new __vertex(p[3]).setNormal(0, 0, -1).setUV(0, 0),
		    																   
				new __vertex(p[0]).setNormal(0, 0, -1).setUV(1, 1), 
				new __vertex(p[3]).setNormal(0, 0, -1).setUV(0, 0), 
				new __vertex(p[2]).setNormal(0, 0, -1).setUV(1, 0),
			],	
			[  
				new __vertex(p[4]).setNormal(-1, 0, 0).setUV(1, 0), 
				new __vertex(p[2]).setNormal(-1, 0, 0).setUV(0, 1), 
				new __vertex(p[6]).setNormal(-1, 0, 0).setUV(0, 0),
		    																   
				new __vertex(p[4]).setNormal(-1, 0, 0).setUV(1, 0), 
				new __vertex(p[0]).setNormal(-1, 0, 0).setUV(1, 1), 
				new __vertex(p[2]).setNormal(-1, 0, 0).setUV(0, 1),
			],	
			[  
				new __vertex(p[5]).setNormal(1, 0, 0).setUV(0, 0), 
				new __vertex(p[7]).setNormal(1, 0, 0).setUV(1, 0), 
				new __vertex(p[3]).setNormal(1, 0, 0).setUV(1, 1),
		    																  
				new __vertex(p[5]).setNormal(1, 0, 0).setUV(0, 0), 
				new __vertex(p[3]).setNormal(1, 0, 0).setUV(1, 1), 
				new __vertex(p[1]).setNormal(1, 0, 0).setUV(0, 1),
			],	
			[  
				new __vertex(p[6]).setNormal(0, 1, 0).setUV(1, 0), 
				new __vertex(p[3]).setNormal(0, 1, 0).setUV(0, 1), 
				new __vertex(p[7]).setNormal(0, 1, 0).setUV(0, 0),
		    																  
				new __vertex(p[6]).setNormal(0, 1, 0).setUV(1, 0), 
				new __vertex(p[2]).setNormal(0, 1, 0).setUV(1, 1), 
				new __vertex(p[3]).setNormal(0, 1, 0).setUV(0, 1),
			],	
			[  
				new __vertex(p[4]).setNormal(0, -1, 0).setUV(0, 0), 
				new __vertex(p[5]).setNormal(0, -1, 0).setUV(1, 0), 
				new __vertex(p[1]).setNormal(0, -1, 0).setUV(1, 1),
		    															   	   
				new __vertex(p[4]).setNormal(0, -1, 0).setUV(0, 0), 
				new __vertex(p[1]).setNormal(0, -1, 0).setUV(1, 1), 
				new __vertex(p[0]).setNormal(0, -1, 0).setUV(0, 1), 
			]
		];
	}
	
	static initModel = function() {
		
		vertex = __default_cube();
		if(!separate_faces) vertex = [ array_merge_array(vertex) ];
		object_counts = separate_faces? 6 : 1;
		
		VB = build();
		
	} initModel();
	
	static onParameterUpdate = initModel;
}