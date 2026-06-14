function __3dVoxel_builder() : __3dObject() constructor {
	VF = global.VF_POS_NORM_TEX_COL;
	render_type = pr_trianglelist;
	
	voxelSize   = [0,0,0];
	voxelBuffer = undefined;
	
	static initModel = function() {
		if(!buffer_exists(voxelBuffer)) return;
		
		var vxSize = voxelSize[0] * voxelSize[1] * voxelSize[2];
		
		edges  = [  ];
		vertex = [  ];
		object_counts = array_length(vertex);
		VB = build();
		
	} initModel();
	
	static onParameterUpdate = initModel;
}