#region setup
	globalvar PRIMITIVES, FORMAT_PT, FORMAT_PNT;
	PRIMITIVES = ds_map_create();

	vertex_format_begin();
	vertex_format_add_position_3d();
	vertex_format_add_texcoord();
	FORMAT_PT = vertex_format_end();

	vertex_format_begin();
	vertex_format_add_position_3d();
	vertex_format_add_normal();
	vertex_format_add_texcoord();
	FORMAT_PNT = vertex_format_end();
#endregion

#region plane
	var _0 = -.5;
	var _1 =  .5;
	
	var VB = vertex_create_buffer();
	vertex_begin(VB, FORMAT_PT);
		
	vertex_add_pt(VB, [_1, _0, 0], [1, 0]);
	vertex_add_pt(VB, [_0, _0, 0], [0, 0]);
	vertex_add_pt(VB, [_1, _1, 0], [1, 1]);
						    		
	vertex_add_pt(VB, [_1, _1, 0], [1, 1]);
	vertex_add_pt(VB, [_0, _0, 0], [0, 0]);
	vertex_add_pt(VB, [_0, _1, 0], [0, 1]);
		
	vertex_end(VB);
	vertex_freeze(VB);
	PRIMITIVES[? "plane"] = VB;
	
	var VB = vertex_create_buffer();
	vertex_begin(VB, FORMAT_PNT);
		
	vertex_add_pnt(VB, [_1, _0, 0], [0, 0, 1], [1, 0]);
	vertex_add_pnt(VB, [_0, _0, 0], [0, 0, 1], [0, 0]);
	vertex_add_pnt(VB, [_1, _1, 0], [0, 0, 1], [1, 1]);
						    		
	vertex_add_pnt(VB, [_1, _1, 0], [0, 0, 1], [1, 1]);
	vertex_add_pnt(VB, [_0, _0, 0], [0, 0, 1], [0, 0]);
	vertex_add_pnt(VB, [_0, _1, 0], [0, 0, 1], [0, 1]);
		
	vertex_end(VB);
	vertex_freeze(VB);
	PRIMITIVES[? "plane_normal"] = VB;
#endregion

#region cube
	var VB = vertex_create_buffer();
	vertex_begin(VB, FORMAT_PNT);
		
	vertex_add_pnt(VB, [_1, _0, _0], [0, 0, -1], [1, 0]);
	vertex_add_pnt(VB, [_0, _0, _0], [0, 0, -1], [0, 0]);
	vertex_add_pnt(VB, [_1, _1, _0], [0, 0, -1], [1, 1]);
						    		
	vertex_add_pnt(VB, [_1, _1, _0], [0, 0, -1], [1, 1]);
	vertex_add_pnt(VB, [_0, _0, _0], [0, 0, -1], [0, 0]);
	vertex_add_pnt(VB, [_0, _1, _0], [0, 0, -1], [0, 1]);
	
	vertex_add_pnt(VB, [_1, _0, _1], [0, 0, 1], [1, 0]);
	vertex_add_pnt(VB, [_0, _0, _1], [0, 0, 1], [0, 0]);
	vertex_add_pnt(VB, [_1, _1, _1], [0, 0, 1], [1, 1]);
						    		
	vertex_add_pnt(VB, [_1, _1, _1], [0, 0, 1], [1, 1]);
	vertex_add_pnt(VB, [_0, _0, _1], [0, 0, 1], [0, 0]);
	vertex_add_pnt(VB, [_0, _1, _1], [0, 0, 1], [0, 1]);
	
	
	vertex_add_pnt(VB, [_1, _0, _0], [0, 1, 0], [1, 0]);
	vertex_add_pnt(VB, [_0, _0, _0], [0, 1, 0], [0, 0]);
	vertex_add_pnt(VB, [_1, _0, _1], [0, 1, 0], [1, 1]);
						   	   			 
	vertex_add_pnt(VB, [_1, _0, _1], [0, 1, 0], [1, 1]);
	vertex_add_pnt(VB, [_0, _0, _0], [0, 1, 0], [0, 0]);
	vertex_add_pnt(VB, [_0, _0, _1], [0, 1, 0], [0, 1]);
							  
	vertex_add_pnt(VB, [_1, _1, _0], [0, -1, 0], [1, 0]);
	vertex_add_pnt(VB, [_0, _1, _0], [0, -1, 0], [0, 0]);
	vertex_add_pnt(VB, [_1, _1, _1], [0, -1, 0], [1, 1]);
						   	 
	vertex_add_pnt(VB, [_1, _1, _1], [0, -1, 0], [1, 1]);
	vertex_add_pnt(VB, [_0, _1, _0], [0, -1, 0], [0, 0]);
	vertex_add_pnt(VB, [_0, _1, _1], [0, -1, 0], [0, 1]);
	
	
	vertex_add_pnt(VB, [_0, _1, _0], [1, 0, 0], [1, 0]);
	vertex_add_pnt(VB, [_0, _0, _0], [1, 0, 0], [0, 0]);
	vertex_add_pnt(VB, [_0, _1, _1], [1, 0, 0], [1, 1]);
							      	  
	vertex_add_pnt(VB, [_0, _1, _1], [1, 0, 0], [1, 1]);
	vertex_add_pnt(VB, [_0, _0, _0], [1, 0, 0], [0, 0]);
	vertex_add_pnt(VB, [_0, _0, _1], [1, 0, 0], [0, 1]);
						   			  
	vertex_add_pnt(VB, [_1, _1, _0], [-1, 0, 0], [1, 0]);
	vertex_add_pnt(VB, [_1, _0, _0], [-1, 0, 0], [0, 0]);
	vertex_add_pnt(VB, [_1, _1, _1], [-1, 0, 0], [1, 1]);
							    	  		 
	vertex_add_pnt(VB, [_1, _1, _1], [-1, 0, 0], [1, 1]);
	vertex_add_pnt(VB, [_1, _0, _0], [-1, 0, 0], [0, 0]);
	vertex_add_pnt(VB, [_1, _0, _1], [-1, 0, 0], [0, 1]);
	
	vertex_end(VB);
	vertex_freeze(VB);
	PRIMITIVES[? "cube"] = VB;
#endregion