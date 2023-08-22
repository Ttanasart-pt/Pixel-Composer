function __3dCamera_object() : __3dObject() constructor {
	ivw = 0.2; //innerViewWidth
	ivh = 0.2; //innerViewHeight
	ovw = 0.5; //outerViewWidth
	ovh = 0.5; //outerViewHeight
	len = 0.5; //cameraLength
	
	vertex = [
		V3( -len, -ivw,  ivh ), V3( -len,  ivw,  ivh ),
		V3( -len,  ivw,  ivh ), V3( -len,  ivw, -ivh ),
		V3( -len,  ivw, -ivh ), V3( -len, -ivw, -ivh ),
		V3( -len, -ivw, -ivh ), V3( -len, -ivw,  ivh ),
									 
		V3(  len, -ovw,  ovh ), V3(  len,  ovw,  ovh ),
		V3(  len,  ovw,  ovh ), V3(  len,  ovw, -ovh ),
		V3(  len,  ovw, -ovh ), V3(  len, -ovw, -ovh ),
		V3(  len, -ovw, -ovh ), V3(  len, -ovw,  ovh ),
								 	 
		V3( -len, -ivw,  ivh ), V3(  len, -ovw,  ovh ),  
		V3( -len,  ivw,  ivh ), V3(  len,  ovw,  ovh ),  
		V3( -len,  ivw, -ivh ), V3(  len,  ovw, -ovh ),  
		V3( -len, -ivw, -ivh ), V3(  len, -ovw, -ovh ),  
		
		V3(  len, -ovw * 0.5, ovh + 0.2 ), V3(  len,  ovw * 0.5, ovh + 0.2 ),  
		V3(  len, 0, ovh + 0.6 ),	  	   V3(  len,  ovw * 0.5, ovh + 0.2 ),  
		V3(  len, -ovw * 0.5, ovh + 0.2 ), V3(  len,  0, ovh + 0.6 ),  
	];
	
	VF = global.VF_POS_COL;
	render_type = pr_linelist;
	VB = build();
	
	position.set(-5, -5, 5);
	rotation.set(0, 30, 135);
	scale.set(1, room_width / room_height, 1);
	
	static submitSel = function(params = {}) { 
		shader_set(sh_d3d_wireframe);
		submitVertex(params); 
		shader_reset();
	}
}

function calculate_3d_position(camFx, camFy, camFz, camAx, camAy, camDist) {
    var pos = new __vec3();
    
    var radAx = degtorad(camAx);
    var radAy = degtorad(camAy);
    
    pos.x = camFx + (cos(radAy) * sin(radAx)) * camDist;
    pos.y = camFy + (cos(radAy) * cos(radAx)) * camDist;
	pos.z = camFz + (sin(radAy)) * camDist;
    
    return pos;
}