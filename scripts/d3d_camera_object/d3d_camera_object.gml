function __3dCamera_object() : __3dObject() constructor {
	ivw = 0.2; //innerViewWidth
	ivh = 0.2; //innerViewHeight
	ovw = 0.5; //outerViewWidth
	ovh = 0.5; //outerViewHeight
	len = 0.5; //cameraLength
	
	vertex = [
		[  len, -ivw,  ivh ], [  len,  ivw,  ivh ],
		[  len,  ivw,  ivh ], [  len,  ivw, -ivh ],
		[  len,  ivw, -ivh ], [  len, -ivw, -ivh ],
		[  len, -ivw, -ivh ], [  len, -ivw,  ivh ],
									 
		[ -len, -ovw,  ovh ], [ -len,  ovw,  ovh ],
		[ -len,  ovw,  ovh ], [ -len,  ovw, -ovh ],
		[ -len,  ovw, -ovh ], [ -len, -ovw, -ovh ],
		[ -len, -ovw, -ovh ], [ -len, -ovw,  ovh ],
									 
		[  len, -ivw,  ivh ], [ -len, -ovw,  ovh ],  
		[  len,  ivw,  ivh ], [ -len,  ovw,  ovh ],  
		[  len,  ivw, -ivh ], [ -len,  ovw, -ovh ],  
		[  len, -ivw, -ivh ], [ -len, -ovw, -ovh ],  
		
		[ -len, -ovw * 0.5, ovh + 0.2 ], [ -len,  ovw * 0.5, ovh + 0.2 ],  
		[ -len, 0, ovh + 0.6 ],			 [ -len,  ovw * 0.5, ovh + 0.2 ],  
		[ -len, -ovw * 0.5, ovh + 0.2 ], [ -len,  0, ovh + 0.6 ],  
	];
	
	VF = global.VF_POS_COL;
	render_type = pr_linelist;
	VB = build();
	
	position.set(-5, -5, 5);
	rotation.set(0, 30, 135);
	scale.set(1, room_width / room_height, 1);
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