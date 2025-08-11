function __3dCamera_object() : __3dObject() constructor {
	ivw = 0.2; //innerViewWidth
	ivh = 0.2; //innerViewHeight
	ovw = 0.5; //outerViewWidth
	ovh = 0.5; //outerViewHeight
	len = 0.5; //cameraLength
	
	vertex = [[
		new __vertex( -len, -ivw,  ivh ), new __vertex( -len,  ivw,  ivh ),
		new __vertex( -len,  ivw,  ivh ), new __vertex( -len,  ivw, -ivh ),
		new __vertex( -len,  ivw, -ivh ), new __vertex( -len, -ivw, -ivh ),
		new __vertex( -len, -ivw, -ivh ), new __vertex( -len, -ivw,  ivh ),
									 
		new __vertex(  len, -ovw,  ovh ), new __vertex(  len,  ovw,  ovh ),
		new __vertex(  len,  ovw,  ovh ), new __vertex(  len,  ovw, -ovh ),
		new __vertex(  len,  ovw, -ovh ), new __vertex(  len, -ovw, -ovh ),
		new __vertex(  len, -ovw, -ovh ), new __vertex(  len, -ovw,  ovh ),
								 	 
		new __vertex( -len, -ivw,  ivh ), new __vertex(  len, -ovw,  ovh ),  
		new __vertex( -len,  ivw,  ivh ), new __vertex(  len,  ovw,  ovh ),  
		new __vertex( -len,  ivw, -ivh ), new __vertex(  len,  ovw, -ovh ),  
		new __vertex( -len, -ivw, -ivh ), new __vertex(  len, -ovw, -ovh ),  
		
		new __vertex(  len, -ovw * 0.5, ovh + 0.2 ), new __vertex(  len,  ovw * 0.5, ovh + 0.2 ),  
		new __vertex(  len, 0, ovh + 0.6 ),	  	   new __vertex(  len,  ovw * 0.5, ovh + 0.2 ),  
		new __vertex(  len, -ovw * 0.5, ovh + 0.2 ), new __vertex(  len,  0, ovh + 0.6 ),  
	]];
	
	VF = global.VF_POS_COL;
	render_type = pr_linelist;
	VB = build();
	
	transform.position.set(-5, -5, 5);
	transform.rotation.FromEuler(0, 30, 135);
	transform.scale.set(1, room_width / room_height, 1);
	transform.applyMatrix();
	
	static submitSel = function(params = {}) { 
		shader_set(sh_d3d_wireframe);
		shader_set_color("blend", c_white);
		submitVertex(params); 
		shader_reset();
	}
}

function d3d_PolarToCart(camFx, camFy, camFz, camAx, camAy, camDist) {
    var pos = new __vec3();
    
	if(camAy % 90 == 0) camAy += 0.1;
	if(camAx % 90 == 0) camAx += 0.1;
	
    var radAx = degtorad(camAx);
    var radAy = degtorad(camAy);
    
    pos.x = camFx + (cos(radAy) * sin(radAx)) * camDist;
    pos.y = camFy + (cos(radAy) * cos(radAx)) * camDist;
	pos.z = camFz + (sin(radAy)) * camDist;
    
    return pos;
}