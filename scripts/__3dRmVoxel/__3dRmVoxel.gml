function __3dRmVoxel() : __3dObject() constructor {
	VF = global.VF_POS_NORM_TEX_COL;
	render_type   = pr_trianglelist;
	object_counts = 1;
	
	voxelRes  = 1;
	voxelSize = 1;
	voxelCube = 1;
	voxelData = undefined;
	w = c_white;
	
	static initModel = function() {
		if(voxelData == undefined || !buffer_exists(voxelData)) return;
		if(!array_empty(VB)) vertex_delete_buffer(VB[0]);
		
		voxelSize = 1 / voxelRes;
		voxelCube = voxelSize / 2;
		
		buffer_to_start(voxelData);
		VB[0] = vertex_create_buffer();
		vertex_begin(VB[0], VF);
		
		var vb = VB[0];
		var ss = voxelCube;
		var cx, cy, cz;
		
		for( var i = 0; i < voxelRes; i++ ) 
		for( var j = 0; j < voxelRes; j++ ) 
		for( var k = 0; k < voxelRes; k++ ) {
			var d = buffer_read(voxelData, buffer_u8);
			if(!d) continue;
			
			cx = -(k - voxelRes / 2) * voxelSize;
			cy =  (i - voxelRes / 2) * voxelSize;
			cz = -(j - voxelRes / 2) * voxelSize;
			
			vertex_position_3d(vb,cx-ss,cy-ss,cz+ss); vertex_normal(vb,0,0,1); vertex_texcoord(vb,0,0); vertex_color(vb,w,1); vertex_float3(vb,255,0,0);
			vertex_position_3d(vb,cx+ss,cy+ss,cz+ss); vertex_normal(vb,0,0,1); vertex_texcoord(vb,1,1); vertex_color(vb,w,1); vertex_float3(vb,0,255,0);
			vertex_position_3d(vb,cx+ss,cy-ss,cz+ss); vertex_normal(vb,0,0,1); vertex_texcoord(vb,1,0); vertex_color(vb,w,1); vertex_float3(vb,0,0,255);
			//											  					  
			vertex_position_3d(vb,cx+ss,cy+ss,cz+ss); vertex_normal(vb,0,0,1); vertex_texcoord(vb,1,1); vertex_color(vb,w,1); vertex_float3(vb,255,0,0);
			vertex_position_3d(vb,cx-ss,cy-ss,cz+ss); vertex_normal(vb,0,0,1); vertex_texcoord(vb,0,0); vertex_color(vb,w,1); vertex_float3(vb,0,255,0);
			vertex_position_3d(vb,cx-ss,cy+ss,cz+ss); vertex_normal(vb,0,0,1); vertex_texcoord(vb,0,1); vertex_color(vb,w,1); vertex_float3(vb,0,0,255);
			
			vertex_position_3d(vb,cx+ss,cy+ss,cz-ss); vertex_normal(vb,0,0,-1); vertex_texcoord(vb,1,1); vertex_color(vb,w,1); vertex_float3(vb,255,0,0);
			vertex_position_3d(vb,cx-ss,cy-ss,cz-ss); vertex_normal(vb,0,0,-1); vertex_texcoord(vb,0,0); vertex_color(vb,w,1); vertex_float3(vb,0,255,0);
			vertex_position_3d(vb,cx+ss,cy-ss,cz-ss); vertex_normal(vb,0,0,-1); vertex_texcoord(vb,1,0); vertex_color(vb,w,1); vertex_float3(vb,0,0,255);
			//											  					  
			vertex_position_3d(vb,cx-ss,cy-ss,cz-ss); vertex_normal(vb,0,0,-1); vertex_texcoord(vb,0,0); vertex_color(vb,w,1); vertex_float3(vb,255,0,0);
			vertex_position_3d(vb,cx+ss,cy+ss,cz-ss); vertex_normal(vb,0,0,-1); vertex_texcoord(vb,1,1); vertex_color(vb,w,1); vertex_float3(vb,0,255,0);
			vertex_position_3d(vb,cx-ss,cy+ss,cz-ss); vertex_normal(vb,0,0,-1); vertex_texcoord(vb,0,1); vertex_color(vb,w,1); vertex_float3(vb,0,0,255);
			
			
			vertex_position_3d(vb,cx+ss,cy+ss,cz+ss); vertex_normal(vb,0,1,0); vertex_texcoord(vb,1,1); vertex_color(vb,w,1); vertex_float3(vb,255,0,0);
			vertex_position_3d(vb,cx-ss,cy+ss,cz-ss); vertex_normal(vb,0,1,0); vertex_texcoord(vb,0,0); vertex_color(vb,w,1); vertex_float3(vb,0,255,0);
			vertex_position_3d(vb,cx+ss,cy+ss,cz-ss); vertex_normal(vb,0,1,0); vertex_texcoord(vb,1,0); vertex_color(vb,w,1); vertex_float3(vb,0,0,255);
			//											  					  
			vertex_position_3d(vb,cx-ss,cy+ss,cz-ss); vertex_normal(vb,0,1,0); vertex_texcoord(vb,0,0); vertex_color(vb,w,1); vertex_float3(vb,255,0,0);
			vertex_position_3d(vb,cx+ss,cy+ss,cz+ss); vertex_normal(vb,0,1,0); vertex_texcoord(vb,1,1); vertex_color(vb,w,1); vertex_float3(vb,0,255,0);
			vertex_position_3d(vb,cx-ss,cy+ss,cz+ss); vertex_normal(vb,0,1,0); vertex_texcoord(vb,0,1); vertex_color(vb,w,1); vertex_float3(vb,0,0,255);
			
			vertex_position_3d(vb,cx-ss,cy-ss,cz-ss); vertex_normal(vb,0,-1,0); vertex_texcoord(vb,0,0); vertex_color(vb,w,1); vertex_float3(vb,255,0,0);
			vertex_position_3d(vb,cx+ss,cy-ss,cz+ss); vertex_normal(vb,0,-1,0); vertex_texcoord(vb,1,1); vertex_color(vb,w,1); vertex_float3(vb,0,255,0);
			vertex_position_3d(vb,cx+ss,cy-ss,cz-ss); vertex_normal(vb,0,-1,0); vertex_texcoord(vb,1,0); vertex_color(vb,w,1); vertex_float3(vb,0,0,255);
			//											  					  
			vertex_position_3d(vb,cx+ss,cy-ss,cz+ss); vertex_normal(vb,0,-1,0); vertex_texcoord(vb,1,1); vertex_color(vb,w,1); vertex_float3(vb,255,0,0);
			vertex_position_3d(vb,cx-ss,cy-ss,cz-ss); vertex_normal(vb,0,-1,0); vertex_texcoord(vb,0,0); vertex_color(vb,w,1); vertex_float3(vb,0,255,0);
			vertex_position_3d(vb,cx-ss,cy-ss,cz+ss); vertex_normal(vb,0,-1,0); vertex_texcoord(vb,0,1); vertex_color(vb,w,1); vertex_float3(vb,0,0,255);
			
			
			vertex_position_3d(vb,cx+ss,cy-ss,cz-ss); vertex_normal(vb,1,0,0); vertex_texcoord(vb,0,0); vertex_color(vb,w,1); vertex_float3(vb,255,0,0);
			vertex_position_3d(vb,cx+ss,cy+ss,cz+ss); vertex_normal(vb,1,0,0); vertex_texcoord(vb,1,1); vertex_color(vb,w,1); vertex_float3(vb,0,255,0);
			vertex_position_3d(vb,cx+ss,cy+ss,cz-ss); vertex_normal(vb,1,0,0); vertex_texcoord(vb,1,0); vertex_color(vb,w,1); vertex_float3(vb,0,0,255);
			//											  					  
			vertex_position_3d(vb,cx+ss,cy+ss,cz+ss); vertex_normal(vb,1,0,0); vertex_texcoord(vb,1,1); vertex_color(vb,w,1); vertex_float3(vb,255,0,0);
			vertex_position_3d(vb,cx+ss,cy-ss,cz-ss); vertex_normal(vb,1,0,0); vertex_texcoord(vb,0,0); vertex_color(vb,w,1); vertex_float3(vb,0,255,0);
			vertex_position_3d(vb,cx+ss,cy-ss,cz+ss); vertex_normal(vb,1,0,0); vertex_texcoord(vb,0,1); vertex_color(vb,w,1); vertex_float3(vb,0,0,255);
			
			vertex_position_3d(vb,cx-ss,cy+ss,cz+ss); vertex_normal(vb,-1,0,0); vertex_texcoord(vb,1,1); vertex_color(vb,w,1); vertex_float3(vb,255,0,0);
			vertex_position_3d(vb,cx-ss,cy-ss,cz-ss); vertex_normal(vb,-1,0,0); vertex_texcoord(vb,0,0); vertex_color(vb,w,1); vertex_float3(vb,0,255,0);
			vertex_position_3d(vb,cx-ss,cy+ss,cz-ss); vertex_normal(vb,-1,0,0); vertex_texcoord(vb,1,0); vertex_color(vb,w,1); vertex_float3(vb,0,0,255);
			//											  					  
			vertex_position_3d(vb,cx-ss,cy-ss,cz-ss); vertex_normal(vb,-1,0,0); vertex_texcoord(vb,0,0); vertex_color(vb,w,1); vertex_float3(vb,255,0,0);
			vertex_position_3d(vb,cx-ss,cy+ss,cz+ss); vertex_normal(vb,-1,0,0); vertex_texcoord(vb,1,1); vertex_color(vb,w,1); vertex_float3(vb,0,255,0);
			vertex_position_3d(vb,cx-ss,cy-ss,cz+ss); vertex_normal(vb,-1,0,0); vertex_texcoord(vb,0,1); vertex_color(vb,w,1); vertex_float3(vb,0,0,255);
		}
		
		vertex_end(VB[0]);
		
		object_counts = 1;
	} initModel();
}