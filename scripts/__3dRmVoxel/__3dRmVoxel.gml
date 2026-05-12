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

function __3dRmCubeMarch() : __3dObject() constructor {
	VF = global.VF_POS_NORM_TEX_COL;
	render_type   = pr_trianglelist;
	object_counts = 1;
	
	voxelRes  = 1;
	voxelSize = 1;
	voxelCube = 1;
	voxelData = undefined;
	w = c_white;

	dataArray = [];
	edges     = array_create_ext( 12, function(i) /*=>*/ {return [0,0,0]});
	triTables = array_create_ext(256, function(i) /*=>*/ {return [0,8,4]});
	
	static initModel = function() {
		if(voxelData == undefined || !buffer_exists(voxelData)) return;
		if(!array_empty(VB)) vertex_delete_buffer(VB[0]);
		
		var rs = voxelRes;
		var r2 = rs * rs;

		voxelSize = 1 / voxelRes;
		voxelCube = voxelSize / 2;
		
		VB[0] = vertex_create_buffer();
		var vb = VB[0];
		var ss = voxelCube;
		var cx, cy, cz;
		
		dataArray = array_verify(dataArray, rs * rs * rs);
		var ind = 0;

		buffer_to_start(voxelData);
		for( var i = 0; i < rs; i++ ) 
		for( var j = 0; j < rs; j++ ) 
		for( var k = 0; k < rs; k++ )
			dataArray[ind++] = bool(buffer_read(voxelData, buffer_u8));

		vertex_begin(VB[0], VF);
		for( var i = 0; i < rs-1; i++ ) 
		for( var j = 0; j < rs-1; j++ ) 
		for( var k = 0; k < rs-1; k++ ) {
			var cubeIndex = 0;
			var d000 = dataArray[(i+0) * r2 + (j+0) * rs + (k+0)];
			var d001 = dataArray[(i+0) * r2 + (j+0) * rs + (k+1)];
			var d010 = dataArray[(i+0) * r2 + (j+1) * rs + (k+0)];
			var d011 = dataArray[(i+0) * r2 + (j+1) * rs + (k+1)];
			var d100 = dataArray[(i+1) * r2 + (j+0) * rs + (k+0)];
			var d101 = dataArray[(i+1) * r2 + (j+0) * rs + (k+1)];
			var d110 = dataArray[(i+1) * r2 + (j+1) * rs + (k+0)];
			var d111 = dataArray[(i+1) * r2 + (j+1) * rs + (k+1)];

			var marchIndex = d000 << 0 | d001 << 1 | d010 << 2 | d011 << 3 | d100 << 4 | d101 << 5 | d110 << 6 | d111 << 7;
			if(marchIndex == 0 || marchIndex == 255) continue;

			var p0x = -(k - rs / 2) * voxelSize;
			var p0y =  (i - rs / 2) * voxelSize;
			var p0z = -(j - rs / 2) * voxelSize;

			var p1x = -(k+1 - rs / 2) * voxelSize;
			var p1y =  (i+1 - rs / 2) * voxelSize;
			var p1z = -(j+1 - rs / 2) * voxelSize;
			
			edges[ 0][0] = p0x; edges[ 0][1] = p0y; edges[ 0][2] = (p0z + p1z) / 2;
			edges[ 1][0] = p0x; edges[ 1][1] = p1y; edges[ 1][2] = (p0z + p1z) / 2;
			edges[ 2][0] = p1x; edges[ 2][1] = p1y; edges[ 2][2] = (p0z + p1z) / 2;
			edges[ 3][0] = p1x; edges[ 3][1] = p0y; edges[ 3][2] = (p0z + p1z) / 2;

			edges[ 4][0] = (p0x + p1x) / 2; edges[ 4][1] = p0y; edges[ 4][2] = p0z;
			edges[ 5][0] = (p0x + p1x) / 2; edges[ 5][1] = p1y; edges[ 5][2] = p0z;
			edges[ 6][0] = (p0x + p1x) / 2; edges[ 6][1] = p1y; edges[ 6][2] = p1z;
			edges[ 7][0] = (p0x + p1x) / 2; edges[ 7][1] = p0y; edges[ 7][2] = p1z;

			edges[ 8][0] = p0x; edges[ 8][1] = (p0y + p1y) / 2; edges[ 8][2] = p0z;
			edges[ 9][0] = p0x; edges[ 9][1] = (p0y + p1y) / 2; edges[ 9][2] = p1z;
			edges[10][0] = p1x; edges[10][1] = (p0y + p1y) / 2; edges[10][2] = p0z;
			edges[11][0] = p1x; edges[11][1] = (p0y + p1y) / 2; edges[11][2] = p1z;
			
			var tris = triTables[marchIndex];
			for( var t = 0, m = array_length(tris); t < m; t += 3 ) {
				var e0 = tris[t+0];
				var e1 = tris[t+1];
				var e2 = tris[t+2];

				vertex_position_3d(vb, edges[e0][0], edges[e0][1], edges[e0][2]); vertex_normal(vb,0,1,0); vertex_texcoord(vb,0,0); vertex_color(vb,w,1); vertex_float3(vb,255,0,0);
				vertex_position_3d(vb, edges[e1][0], edges[e1][1], edges[e1][2]); vertex_normal(vb,0,1,0); vertex_texcoord(vb,1,0); vertex_color(vb,w,1); vertex_float3(vb,0,255,0);
				vertex_position_3d(vb, edges[e2][0], edges[e2][1], edges[e2][2]); vertex_normal(vb,0,1,0); vertex_texcoord(vb,0,1); vertex_color(vb,w,1); vertex_float3(vb,0,0,255);
			}
		}
		vertex_end(VB[0]);
		
		object_counts = 1;
	} initModel();
}