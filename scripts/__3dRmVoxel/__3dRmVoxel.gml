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
	static triTables = [ // haha am I gonna finish this
	
		/* 000 : 0000_0000 */ [],
		/* 001 : 0000_0001 */ [ 0, 4, 5],
		/* 002 : 0000_0010 */ [ 1, 6, 4],
		/* 003 : 0000_0011 */ [ 0, 1, 5, 1, 6, 5],
		
		/* 004 : 0000_0100 */ [ 2, 5, 7],
		/* 005 : 0000_0101 */ [ 0, 7, 2, 0, 4, 7],
		/* 006 : 0000_0110 */ [ 2, 5, 7, 1, 6, 4],
		/* 007 : 0000_0111 */ [ 0, 7, 2, 0, 6, 7, 0, 1, 6],
		
		/* 008 : 0000_1000 */ [ 3, 7, 6],
		/* 009 : 0000_1001 */ [ 3, 7, 6, 0, 4, 5],
		/* 010 : 0000_1010 */ [ 1, 3, 4, 3, 7, 4],
		/* 011 : 0000_1011 */ [ 1, 5, 0, 1, 7, 5, 1, 3, 7],
		
		/* 012 : 0000_1100 */ [ 2, 5, 3, 3, 5, 6],
		/* 013 : 0000_1101 */ [ 2, 0, 4, 2, 4, 6, 2, 6, 3],
		/* 014 : 0000_1110 */ [ 3, 2, 5, 3, 5, 4, 3, 4, 1],
		/* 015 : 0000_1111 */ [ 0, 3, 2, 0, 1, 3],
		
		////////////////////////////////////
		
		/* 016 : 0001_0000 */ [ 0, 9, 8],
		/* 017 : 0001_0001 */ [ 8, 5, 9, 8, 4, 5],
		/* 018 : 0001_0010 */ [ 0, 9, 8, 1, 6, 4],
		/* 019 : 0001_0011 */ [ 5, 9, 8, 5, 8, 1, 5, 1, 6],
		
		/* 020 : 0001_0100 */ [ 0, 9, 8, 2, 5, 7],
		/* 021 : 0001_0101 */ [ 4, 7, 2, 4, 2, 9, 8, 4, 9],
		/* 022 : 0001_0110 */ [ 0, 9, 8, 2, 5, 7, 1, 6, 4],
		/* 023 : 0001_0111 */ [ 2, 9, 7, 7, 9, 6, 9, 8, 6, 6, 8, 1],
		
		/* 024 : 0001_1000 */ [ 0, 9, 8, 3, 7, 6],
		/* 025 : 0001_1001 */ [ 9, 8, 5, 5, 8, 4, 3, 7, 6],
		/* 026 : 0001_1010 */ [ 0, 9, 8, 1, 3, 4, 4, 3, 7],
		/* 027 : 0001_1011 */ [ 1, 3, 8, 8, 3, 9, 9, 3, 7, 9, 7, 5],
		
		/* 028 : 0001_1100 */ [ 0, 9, 8, 2, 5, 3, 3, 5, 6],
		/* 029 : 0001_1101 */ [ 2, 9, 3, 3, 9, 8, 3, 8, 6, 8, 4, 6],
		/* 030 : 0001_1110 */ [ 0, 9, 8, 1, 3, 4, 3, 2, 4, 4, 2, 5],
		/* 031 : 0001_1111 */ [ 9, 3, 2, 3, 9, 8, 3, 8, 1],
		
		////////////////////////////////////
		
		/* 032 : 0010_0000 */ [ 1, 8, 10],
		/* 033 : 0010_0001 */ [ 1, 8, 10, 0, 4, 5],
		/* 034 : 0010_0010 */ [ 8, 10, 4, 10, 6, 4],
		/* 035 : 0010_0011 */ [ 8, 10, 0, 0, 10, 5, 10, 6, 5],
		
		/* 036 : 0010_0100 */ [ 2, 5, 7, 1, 8, 10],
		/* 037 : 0010_0101 */ [ 1, 8, 10, 0, 7, 2, 7, 0, 4],
		/* 038 : 0010_0110 */ [ 2, 5, 7, 4, 8, 6, 8, 10, 6],
		/* 039 : 0010_0111 */ [ 0, 8, 2, 8, 10, 2, 2, 10, 7, 10, 6, 7],
		
		/* 040 : 0010_1000 */ [ 1, 8, 10, 3, 7, 6],
		/* 041 : 0010_1001 */ [ 1, 8, 10, 3, 7, 6, 0, 4, 5],
		/* 042 : 0010_1010 */ [ 4, 8, 10, 4, 10, 7, 10, 3, 7],
		/* 043 : 0010_1011 */ [ 0, 8, 5, 8, 10, 5, 5, 10, 7, 10, 3, 7],
		
		/* 044 : 0010_1100 */ [ 1, 8, 10, 2, 5, 3, 3, 5, 6],
		/* 045 : 0010_1101 */ [ 1, 8, 10, 2, 6, 3, 6, 2, 4, 2, 0, 4],
		/* 046 : 0010_1110 */ [ 3, 2, 10, 10, 2, 8, 2, 5, 8, 8, 5, 4],
		/* 047 : 0010_1111 */ [ 0, 8, 2, 2, 8, 10, 10, 3, 2],
		
		////////////////////////////////////
		
		/* 048 : 0011_0000 */ [ 0, 9, 1, 1, 9, 10],
		/* 049 : 0011_0001 */ [ 1, 4, 10, 10, 4, 9, 4, 5, 9],
		/* 050 : 0011_0010 */ [ 4, 0, 10, 10, 0, 9, 4, 10, 6],
		/* 051 : 0011_0011 */ [ 5, 9, 6, 6, 9, 10],
		
		/* 052 : 0011_0100 */ [ 2, 5, 7, 0, 9, 1, 1, 9, 10],
		/* 053 : 0011_0101 */ [ 10, 2, 9, 1, 4, 7, 2, 10, 7, 10, 1, 7],
		/* 054 : 0011_0110 */ [ 2, 5, 7, 0, 10, 4, 9, 10, 0, 10, 6, 4],
		/* 055 : 0011_0111 */ [ 2, 9, 6, 2, 6, 7, 6, 9, 10],
		
		/* 056 : 0011_1000 */ [ 3, 7, 6, 0, 9, 1, 1, 9, 10],
		/* 057 : 0011_1001 */ [ 3, 7, 6, 1, 4, 9, 9, 4, 5, 1, 9, 10],
		/* 058 : 0011_1010 */ [ 0, 9, 7, 0, 7, 4, 7, 9, 3, 3, 9, 10],
		/* 059 : 0011_1011 */ [ 5, 9, 7, 7, 9, 3, 3, 9, 10],
		
		/* 060 : 0011_1100 */ [ 2, 5, 3, 5, 6, 3, 1, 0, 9, 1, 9, 10],
		/* 061 : 0011_1101 */ [ 1, 4, 6, 2, 9, 3, 3, 9, 10],
		/* 062 : 0011_1110 */ [ 0, 5, 4, 2, 9, 3, 3, 9, 10],
		/* 063 : 0011_1111 */ [ 3, 2, 9, 3, 9, 10],
		
		////////////////////////////////////
		
		/* 064 : 0100_0000 */ [ 9, 2, 11],
		/* 065 : 0100_0001 */ [ 9, 2, 11, 0, 4, 5],
		/* 066 : 0100_0010 */ [ 9, 2, 11, 1, 6, 4],
		/* 067 : 0100_0011 */ [ 9, 2, 11, 0, 1, 5, 1, 6, 5],

		/* 068 : 0100_0100 */ [ 5, 7, 9, 9, 7, 11],
		/* 069 : 0100_0101 */ [ 0, 4, 9, 9, 4, 11, 7, 11, 4],
		/* 070 : 0100_0110 */ [ 1, 6, 4, 5, 7, 9, 9, 7, 11],
		/* 071 : 0100_0111 */ [ 1, 9, 0, 9, 1, 11, 6, 11, 1, 11, 6, 7],

		/* 072 : 0100_1000 */ [ 3, 7, 6, 9, 2, 11],
		/* 073 : 0100_1001 */ [ 3, 7, 6, 9, 2, 11, 0, 4, 5],
		/* 074 : 0100_1010 */ [ 9, 2, 11, 1, 3, 4, 4, 3, 7],
		/* 075 : 0100_1011 */ [ 9, 2, 11, 0, 1, 5, 1, 7, 5, 7, 1, 3],
		
		/* 076 : 0100_1100 */ [ 3, 11, 6, 11, 5, 6, 5, 11, 9],
		/* 077 : 0100_1101 */ [ 3, 11, 6, 6, 11, 9, 9, 4, 6, 9, 0, 4],
		/* 078 : 0100_1110 */ [ 1, 3, 11, 11, 9, 1, 1, 9, 4, 9, 5, 4],
		/* 079 : 0100_1111 */ [ 0, 1, 9, 9, 1, 11, 11, 1, 3],

		////////////////////////////////////

		/* 080 : 0101_0000 */ [ 0, 2, 8, 8, 2, 11],
		/* 081 : 0101_0001 */ [ 5, 2, 11, 5, 11, 4, 11, 8, 4],
		/* 082 : 0101_0010 */ [ 0, 2, 11, 11, 8, 0, 1, 6, 4],
		/* 083 : 0101_0011 */ [ 8, 1, 11, 11, 1, 6, 2, 11, 6, 2, 6, 5],

		/* 084 : 0101_0100 */ [ 0, 5, 11, 7, 11, 5, 11, 8, 0],
		/* 085 : 0101_0101 */ [ 4, 7, 8, 8, 7, 11],
		/* 086 : 0101_0110 */ [ 1, 6, 4, 0, 5, 11, 5, 7, 11, 11, 8, 0],
		/* 087 : 0101_0111 */ [ 8, 1, 11, 11, 1, 6, 7, 11, 6],

		/* 088 : 0101_1000 */ [ 3, 7, 6, 0, 2, 8, 8, 2, 11],
		/* 089 : 0101_1001 */ [ 3, 7, 6, 2, 8, 5, 8, 2, 11, 5, 8, 4],
		/* 090 : 0101_1010 */ [ 1, 3, 4, 4, 3, 7, 0, 2, 8, 8, 2, 11],
		/* 091 : 0101_1011 */ [ 2, 7, 5, 1, 3, 8, 8, 3, 11],

		/* 092 : 0101_1100 */ [ 5, 8, 0, 3, 11, 6, 11, 8, 6, 6, 8, 5],
		/* 093 : 0101_1101 */ [ 6, 11, 4, 11, 8, 4, 3, 11, 6],
		/* 094 : 0101_1110 */ [ 0, 5, 4, 1, 3, 8, 8, 3, 11],
		/* 095 : 0101_1111 */ [ 1, 3, 8, 8, 3, 11],

		////////////////////////////////////

		/* 096 : 0110_0000 */ [ 1, 8, 10, 9, 2, 11],
		/* 097 : 0110_0001 */ [ 1, 8, 10, 9, 2, 11, 0, 4, 5],
		/* 098 : 0110_0010 */ [ 9, 2, 11, 4, 8, 6, 6, 8, 10],
		/* 099 : 0110_0011 */ [ 9, 2, 11, 5, 8, 6, 0, 8, 5, 6, 8, 10],

		/* 100 : 0110_0100 */ [ 1, 8, 10, 5, 7, 9, 9, 7, 11],
		/* 101 : 0110_0101 */ [ 1, 8, 10, 0, 4, 9, 9, 4, 11, 7, 11, 4],
		/* 102 : 0110_0110 */ [ 6, 4, 8, 6, 8, 10, 5, 7, 9, 9, 7, 11],
		/* 103 : 0110_0111 */ [ 0, 8, 9, 6, 7, 10, 7, 11, 10],

		/* 104 : 0110_1000 */ [ 1, 8, 10, 9, 2, 11, 3, 7, 6],
		/* 105 : 0110_1001 */ [ 0, 4, 5, 1, 8, 10, 9, 2, 11, 3, 7, 6],
		/* 106 : 0110_1010 */ [ 9, 2, 11, 8, 10, 7, 8, 7, 4, 10, 3, 7],
		/* 107 : 0110_1011 */ [ 9, 2, 11, 0, 8, 5, 5, 8, 7, 7, 8, 10, 7, 10, 3],

		/* 108 : 0110_1100 */ [ 1, 8, 10, 11, 9, 3, 3, 9, 6, 9, 5, 6],
		/* 109 : 0110_1101 */ [ 1, 8, 10, 0, 4, 6, 6, 3, 11, 11, 9, 0, 0, 6, 11],
		/* 110 : 0110_1110 */ [ 3, 11, 10, 5, 4, 8, 5, 8, 9],
		/* 111 : 0110_1111 */ [ 3, 11, 10, 0, 8, 9],
		
		////////////////////////////////////

		/* 112 : 0111_0000 */ [ 0, 2, 11, 0, 11, 10, 0, 10, 1],
		/* 113 : 0111_0001 */ [ 1, 4, 10, 5, 2, 4, 11, 10, 2, 4, 2, 10],
		/* 114 : 0111_0010 */ [ 0, 2, 4, 4, 2, 6, 6, 2, 11, 6, 11, 10],
		/* 115 : 0111_0011 */ [ 2, 6, 5, 6, 2, 11, 10, 6, 11],	

		/* 116 : 0111_0100 */ [ 0, 5, 1, 1, 5, 7, 1, 7, 10, 10, 7, 11],
		/* 117 : 0111_0101 */ [ 1, 4, 7, 1, 7, 10, 10, 7, 11],
		/* 118 : 0111_0110 */ [ 0, 5, 4, 6, 7, 10, 7, 11, 10],
		/* 119 : 0111_0111 */ [ 6, 7, 10, 7, 11, 10],

		/* 120 : 0111_1000 */ [ 3, 7, 6, 0, 2, 11, 10, 0, 11, 0, 10, 1],
		/* 121 : 0111_1001 */ [ 3, 7, 6, 5, 2, 11, 5, 11, 10, 10, 4, 5, 4, 10, 1],
		/* 122 : 0111_1010 */ [ 0, 2, 7, 4, 0, 7, 3, 11, 10],
		/* 123 : 0111_1011 */ [ 2, 7, 5, 3, 11, 10],

		/* 124 : 0111_1100 */ [ 3, 11, 10, 0, 5, 1, 1, 5, 6],
		/* 125 : 0111_1101 */ [ 3, 11, 10, 1, 4, 6],
		/* 126 : 0111_1110 */ [ 3, 11, 10, 0, 5, 4],
		/* 127 : 0111_1111 */ [ 3, 11, 10],
	];
	
	VF = global.VF_POS_NORM_TEX_COL;
	render_type   = pr_trianglelist;
	object_counts = 1;
	
	voxelRes  = 1;
	voxelSize = 1;
	voxelData = undefined;
	w = c_white;

	dataArray = [];
	edges     = array_create_ext( 12, function(i) /*=>*/ {return [0,0,0]});
	
	static initModel = function() {
		if(voxelData == undefined || !buffer_exists(voxelData)) return;
		if(!array_empty(VB)) vertex_delete_buffer(VB[0]);
		
		var rs = voxelRes;
		var r2 = rs * rs;
		var cs = rs / 2;
		
		VB[0] = vertex_create_buffer();
		var vb = VB[0];
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

			var p0x = (k   - cs) / rs;
			var p0y = (j   - cs) / rs;
			var p0z = (i   - cs) / rs;

			var p1x = (k+1 - cs) / rs;
			var p1y = (j+1 - cs) / rs;
			var p1z = (i+1 - cs) / rs;
			
			edges[ 0][0] = p0x;             edges[ 0][1] = p0y;             edges[ 0][2] = (p0z + p1z) / 2;
			edges[ 1][0] = p1x;             edges[ 1][1] = p0y;             edges[ 1][2] = (p0z + p1z) / 2;
			edges[ 2][0] = p0x;             edges[ 2][1] = p1y;             edges[ 2][2] = (p0z + p1z) / 2;
			edges[ 3][0] = p1x;             edges[ 3][1] = p1y;             edges[ 3][2] = (p0z + p1z) / 2;
			
			edges[ 4][0] = (p0x + p1x) / 2; edges[ 4][1] = p0y;             edges[ 4][2] = p0z;
			edges[ 5][0] =  p0x;            edges[ 5][1] = (p0y + p1y) / 2; edges[ 5][2] = p0z;
			edges[ 6][0] =  p1x;            edges[ 6][1] = (p0y + p1y) / 2; edges[ 6][2] = p0z;
			edges[ 7][0] = (p0x + p1x) / 2; edges[ 7][1] = p1y;             edges[ 7][2] = p0z;
			
			edges[ 8][0] = (p0x + p1x) / 2; edges[ 8][1] =  p0y;            edges[ 8][2] = p1z;
			edges[ 9][0] =  p0x;            edges[ 9][1] = (p0y + p1y) / 2; edges[ 9][2] = p1z;
			edges[10][0] =  p1x;            edges[10][1] = (p0y + p1y) / 2; edges[10][2] = p1z;
			edges[11][0] = (p0x + p1x) / 2; edges[11][1] =  p1y;            edges[11][2] = p1z;
			
			var inv = marchIndex >= 128;
			if(inv) marchIndex = 127 - (marchIndex - 128);
			var tris = triTables[marchIndex];
			
			for( var t = 0, m = array_length(tris); t < m; t += 3 ) {
				if(inv) {
					var e0 = tris[t+0];
					var e1 = tris[t+1];
					var e2 = tris[t+2];
					
				} else {
					var e0 = tris[m-1-(t+0)];
					var e1 = tris[m-1-(t+1)];
					var e2 = tris[m-1-(t+2)];
				} 
				
				var e0x = edges[e0][0];
				var e0y = edges[e0][1];
				var e0z = edges[e0][2];
				
				var e1x = edges[e1][0];
				var e1y = edges[e1][1];
				var e1z = edges[e1][2];
				
				var e2x = edges[e2][0];
				var e2y = edges[e2][1];
				var e2z = edges[e2][2];
				
				var nx = (e1y - e0y) * (e2z - e0z) - (e1z - e0z) * (e2y - e0y);
				var ny = (e1z - e0z) * (e2x - e0x) - (e1x - e0x) * (e2z - e0z);
				var nz = (e1x - e0x) * (e2y - e0y) - (e1y - e0y) * (e2x - e0x);
				
				vertex_position_3d(vb, e0x, e0y, e0z); vertex_normal(vb,nx,ny,nz); vertex_texcoord(vb,0,0); vertex_color(vb,w,1); vertex_float3(vb,255,0,0);
				vertex_position_3d(vb, e1x, e1y, e1z); vertex_normal(vb,nx,ny,nz); vertex_texcoord(vb,1,0); vertex_color(vb,w,1); vertex_float3(vb,0,255,0);
				vertex_position_3d(vb, e2x, e2y, e2z); vertex_normal(vb,nx,ny,nz); vertex_texcoord(vb,0,1); vertex_color(vb,w,1); vertex_float3(vb,0,0,255);
			}
		}
		vertex_end(VB[0]);
		
		object_counts = 1;
	} initModel();
}