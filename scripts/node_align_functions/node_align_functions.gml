function node_halign(nodeList, alignment = fa_center) {
	var amo = array_length(nodeList);
	
	switch(alignment) {
		case fa_left: 
			var x0 = 999999;
			for( var i = 0; i < amo; i++ )
				x0 = min(x0, nodeList[i].x);
				
			for( var i = 0; i < amo; i++ )
				nodeList[i].x = x0;
			break;
		case fa_center: 
			var xc = 0;
			for( var i = 0; i < amo; i++ )
				xc += nodeList[i].x + nodeList[i].w / 2;
			xc /= amo;
			
			for( var i = 0; i < amo; i++ )
				nodeList[i].x = xc - nodeList[i].w / 2;
			break;
		case fa_right: 
			var x0 = -999999;
			for( var i = 0; i < amo; i++ )
				x0 = max(x0, nodeList[i].x + nodeList[i].w);
				
			for( var i = 0; i < amo; i++ )
				nodeList[i].x = x0 - nodeList[i].w;
			break;
	}
}

function node_valign(nodeList, alignment = fa_middle) {
	var amo = array_length(nodeList);
	
	switch(alignment) {
		case fa_top: 
			var y0 = 999999;
			for( var i = 0; i < amo; i++ )
				y0 = min(y0, nodeList[i].y);
				
			for( var i = 0; i < amo; i++ )
				nodeList[i].y = y0;
			break;
		case fa_middle: 
			var yc = 0;
			for( var i = 0; i < amo; i++ )
				yc += nodeList[i].y + nodeList[i].h / 2;
			yc /= amo;
			
			for( var i = 0; i < amo; i++ )
				nodeList[i].y = yc - nodeList[i].h / 2;
			break;
		case fa_bottom: 
			var y0 = -999999;
			for( var i = 0; i < amo; i++ )
				y0 = max(y0, nodeList[i].y + nodeList[i].h);
				
			for( var i = 0; i < amo; i++ )
				nodeList[i].y = y0 - nodeList[i].h;
			break;
	}
}

function node_hdistribute(nodeList) {
	var amo   = array_length(nodeList);
	var nodes = ds_priority_create();
	
	var x0 =  999999;
	var x1 = -999999;
	for( var i = 0; i < amo; i++ ) {
		var _x = nodeList[i].x + nodeList[i].w / 2;
		x0 = min(x0, _x);
		x1 = max(x1, _x);
		
		ds_priority_add(nodes, nodeList[i], _x);
	}
	
	var sp = (x1 - x0) / (amo - 1);
	
	for( var i = 0; i < amo; i++ ) {
		var _node = ds_priority_delete_min(nodes);
		_node.x = x0 + sp * i - _node.w / 2;
	}
	
	ds_priority_destroy(nodes);
}

function node_vdistribute(nodeList) {
	var amo   = array_length(nodeList);
	var nodes = ds_priority_create();
	
	var y0 =  999999;
	var y1 = -999999;
	for( var i = 0; i < amo; i++ ) {
		var _y = nodeList[i].y + nodeList[i].h / 2;
		y0 = min(y0, _y);
		y1 = max(y1, _y);
		
		ds_priority_add(nodes, nodeList[i], _y);
	}
	
	var sp = (y1 - y0) / (amo - 1);
	
	for( var i = 0; i < amo; i++ ) {
		var _node = ds_priority_delete_min(nodes);
		_node.y = y0 + sp * i - _node.h / 2;
	}
	
	ds_priority_destroy(nodes);
}

function node_hdistribute_dist(nodeList, anchor = noone, distance = 0) {
	var amo   = array_length(nodeList);
	var nodes = ds_priority_create();
	
	var x0 =  999999;
	var x1 = -999999;
	for( var i = 0; i < amo; i++ ) {
		var _x = nodeList[i].x + nodeList[i].w / 2;
		x0 = min(x0, _x);
		x1 = max(x1, _x);
		
		ds_priority_add(nodes, nodeList[i], _x);
	}
	
	var ar = array_create(ds_priority_size(nodes));
	
	for( var i = 0; i < amo; i++ ) 
		ar[i] = ds_priority_delete_min(nodes);
	ds_priority_destroy(nodes);
	
	if(anchor == noone) anchor = ar[0];
	var an_ind   = array_find(ar, anchor);
	var an_ind_x = anchor.x + anchor.w + distance;
	
	for (var i = an_ind + 1, n = array_length(ar); i < n; i++) {
		ar[i].x   = an_ind_x;
		an_ind_x += ar[i].w + distance;
	}
	
	var an_ind_x = anchor.x - distance;
	for (var i = an_ind - 1; i >= 0; i--) {
		ar[i].x   = an_ind_x - ar[i].w;
		an_ind_x -= ar[i].w + distance;
	}
}

function node_vdistribute_dist(nodeList, anchor = noone, distance = 0) {
	var amo   = array_length(nodeList);
	var nodes = ds_priority_create();
	
	var y0 =  999999;
	var y1 = -999999;
	for( var i = 0; i < amo; i++ ) {
		var _y = nodeList[i].y + nodeList[i].h / 2;
		y0 = min(y0, _y);
		y1 = max(y1, _y);
		
		ds_priority_add(nodes, nodeList[i], _y);
	}
	
	var ar = array_create(ds_priority_size(nodes));
	
	for( var i = 0; i < amo; i++ ) 
		ar[i] = ds_priority_delete_min(nodes);
	ds_priority_destroy(nodes);
	
	if(anchor == noone) anchor = ar[0];
	var an_ind   = array_find(ar, anchor);
	var an_ind_y = anchor.y + anchor.h + distance;
	
	for (var i = an_ind + 1, n = array_length(ar); i < n; i++) {
		ar[i].y   = an_ind_y;
		an_ind_y += ar[i].h + distance;
	}
	
	var an_ind_y = anchor.y - distance;
	for (var i = an_ind - 1; i >= 0; i--) {
		ar[i].y   = an_ind_y - ar[i].h;
		an_ind_y -= ar[i].h + distance;
	}
}

function node_auto_align(nodeList) {
	var h_avg = 0, h_var = 0;
	var v_avg = 0, v_var = 0;
	
	var amo = array_length(nodeList);
	
	for( var i = 0; i < amo; i++ ) {
		var _n = nodeList[i];
		var _x = _n.x;
		var _y = _n.y;
		
		h_avg += _x;
		v_avg += _y;
	}
	
	h_avg /= amo;
	v_avg /= amo;
	
	for( var i = 0; i < amo; i++ ) {
		var _n = nodeList[i];
		
		h_var += sqr(_n.x - h_avg);
		v_var += sqr(_n.y - v_avg);
	}
	
	     if(h_var < v_var) { node_halign(nodeList); node_vdistribute(nodeList); }
	else if(v_var < h_var) { node_valign(nodeList); node_hdistribute(nodeList); }
}