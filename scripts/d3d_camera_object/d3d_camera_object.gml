function __3dCamera_object() : __3dObject() constructor {
	width  = .35;
	height = .4;
	proj   = CAMERA_PROJECTION.perspective;
	fov    = 45;
	asp    = 1;
	
	VF = global.VF_POS_COL;
	render_type = pr_linelist;
	
	static setMesh = function() {
		if(proj == CAMERA_PROJECTION.perspective) {
			var ofs = clamp(fov / 90, 0, 1) * height / 2;
			var ivw = width * asp - ofs;
			var ivh = width       - ofs;
			var ovw = width * asp + ofs;
			var ovh = width       + ofs;
			
		} else {
			var ivw = width * asp;
			var ivh = width;
			var ovw = width * asp;
			var ovh = width;
			
		}
		
		vertex = [[
			new __vertex( -height, -ivw,  ivh ), new __vertex( -height,  ivw,  ivh ),
			new __vertex( -height,  ivw,  ivh ), new __vertex( -height,  ivw, -ivh ),
			new __vertex( -height,  ivw, -ivh ), new __vertex( -height, -ivw, -ivh ),
			new __vertex( -height, -ivw, -ivh ), new __vertex( -height, -ivw,  ivh ),
										 
			new __vertex(  height, -ovw,  ovh ), new __vertex(  height,  ovw,  ovh ),
			new __vertex(  height,  ovw,  ovh ), new __vertex(  height,  ovw, -ovh ),
			new __vertex(  height,  ovw, -ovh ), new __vertex(  height, -ovw, -ovh ),
			new __vertex(  height, -ovw, -ovh ), new __vertex(  height, -ovw,  ovh ),
									 	 
			new __vertex( -height, -ivw,  ivh ), new __vertex(  height, -ovw,  ovh ),  
			new __vertex( -height,  ivw,  ivh ), new __vertex(  height,  ovw,  ovh ),  
			new __vertex( -height,  ivw, -ivh ), new __vertex(  height,  ovw, -ovh ),  
			new __vertex( -height, -ivw, -ivh ), new __vertex(  height, -ovw, -ovh ),  
			
			new __vertex(  height, -ovw * .5, ovh + .2 ), new __vertex( height,  ovw * .5, ovh + .2 ),  
			new __vertex(  height,         0, ovh + .6 ), new __vertex( height,  ovw * .5, ovh + .2 ),  
			new __vertex(  height, -ovw * .5, ovh + .2 ), new __vertex( height,         0, ovh + .6 ),  
		]];
		
		VB = build();
	}
	
	setMesh();
	
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