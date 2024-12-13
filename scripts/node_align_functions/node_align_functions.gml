function node_halign(nodeList, alignment = fa_center) {
	var amo = array_length(nodeList);
	
	for( var i = 0; i < amo; i++ ) {
		recordAction(ACTION_TYPE.var_modify, nodeList[i], [ nodeList[i].x, "x", "node x position" ]);
        recordAction(ACTION_TYPE.var_modify, nodeList[i], [ nodeList[i].y, "y", "node y position" ]);
	}
	
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
	
	for( var i = 0; i < amo; i++ ) {
		recordAction(ACTION_TYPE.var_modify, nodeList[i], [ nodeList[i].x, "x", "node x position" ]);
        recordAction(ACTION_TYPE.var_modify, nodeList[i], [ nodeList[i].y, "y", "node y position" ]);
	}
	
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
	
	for( var i = 0; i < amo; i++ ) {
		recordAction(ACTION_TYPE.var_modify, nodeList[i], [ nodeList[i].x, "x", "node x position" ]);
        recordAction(ACTION_TYPE.var_modify, nodeList[i], [ nodeList[i].y, "y", "node y position" ]);
	}
	
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
	
	for( var i = 0; i < amo; i++ ) {
		recordAction(ACTION_TYPE.var_modify, nodeList[i], [ nodeList[i].x, "x", "node x position" ]);
        recordAction(ACTION_TYPE.var_modify, nodeList[i], [ nodeList[i].y, "y", "node y position" ]);
	}
	
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
	
	for( var i = 0; i < amo; i++ ) {
		recordAction(ACTION_TYPE.var_modify, nodeList[i], [ nodeList[i].x, "x", "node x position" ]);
        recordAction(ACTION_TYPE.var_modify, nodeList[i], [ nodeList[i].y, "y", "node y position" ]);
	}
	
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
	
	for( var i = 0; i < amo; i++ ) {
		recordAction(ACTION_TYPE.var_modify, nodeList[i], [ nodeList[i].x, "x", "node x position" ]);
        recordAction(ACTION_TYPE.var_modify, nodeList[i], [ nodeList[i].y, "y", "node y position" ]);
	}
	
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
		recordAction(ACTION_TYPE.var_modify, nodeList[i], [ nodeList[i].x, "x", "node x position" ]);
        recordAction(ACTION_TYPE.var_modify, nodeList[i], [ nodeList[i].y, "y", "node y position" ]);
	}
	
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

function node_snap_grid(nodeList, spacing = 16) {
	
	var amo = array_length(nodeList);
	
	for( var i = 0; i < amo; i++ ) {
		recordAction(ACTION_TYPE.var_modify, nodeList[i], [ nodeList[i].x, "x", "node x position" ]);
        recordAction(ACTION_TYPE.var_modify, nodeList[i], [ nodeList[i].y, "y", "node y position" ]);
	}
	
	for (var i = 0, n = array_length(nodeList); i < n; i++) {
		var _node = nodeList[i];
		
		_node.x = value_snap(_node.x, spacing);
		_node.y = value_snap(_node.y, spacing);
	}
}

	////- Auto organize

function node_auto_organize_parameter() constructor {
	padd_w = 32;
	padd_h = 16;
	
	snap      = true;
	snap_size = 16;
	
	gridmap   = [];
}

function __node_auto_organize_graph(node) {
	var children = [];
	var froms    = node.getNodeFrom();
	node.__organize_sorted = false;
	
	for( var i = 0, n = array_length(froms); i < n; i++ )
		children[i] = __node_auto_organize_graph(froms[i]);
	
	return { node, children, w: 0, h: 0, depth: 0 };
}

function __node_auto_organize_size(node, param) {
	if(array_empty(node.children)) {
		if(node.node == noone) return node;
		
		node.w = node.node.w;
		node.h = node.node.h;
		return node;
	}
	
	var tw = 0;
	var th = 0;
	
	for( var i = 0, n = array_length(node.children); i < n; i++ ) {
		var _s = __node_auto_organize_size(node.children[i], param);
		tw = max(tw, _s.node.w);
		th += _s.h + param.padd_h * bool(i);
	}
	
	node.w  = tw;
	node.h  = th;
	
	return node;
}

function __node_auto_organize(node, param, _x = 0, _y = 0, _cap = false) {
	var ch = [];
	var tw = node.w;
	
	var _sx = _x - tw - param.padd_w;
	var _sy = _y;
	
	if(param.snap) {
		_sx = value_snap(_sx, param.snap_size);
		_sy = value_snap(_sy, param.snap_size);
	}
	
	var miny = 0; 
	var maxy = 0; 
	
	for( var i = 0, n = array_length(node.children); i < n; i++ ) {
		var _n = node.children[i];
		__node_auto_organize(_n, param, _sx, _sy, _cap);
		
		if(!_n.node.__organize_sorted) {
			_n.node.x = _sx;
			_n.node.y = _sy;
		} else {
			_n.node.x = min(_n.node.x, _sx);
			_n.node.y = min(_n.node.y, _sy);
		}
		
		miny = i == 0? _n.node.y             : min(miny, _n.node.y);
		maxy = i == 0? _n.node.y + _n.node.h : max(maxy, _n.node.y + _n.node.h);
		
		_n.node.__organize_sorted = true;
		_sy += _n.h + param.padd_h;
		
		if(param.snap) _sy = value_snap(_sy, param.snap_size);
	}
	
	if(_cap && node.node) miny = max(miny, node.node.y);
	if(n) node.h = maxy - miny;
	if(node.node) node.h = max(node.h, node.node.h);
}

function __node_bbox_recal(node, param) {
	node.bbox = [ 0, 0, 0, 0 ];
	node.h    = 0;
	if(node.node) node.node.__organize_sorted = false;
	
	if(array_empty(node.children)) {
		if(node.node == noone) return node;
		
		node.bbox[0] = node.node.x;
		node.bbox[1] = node.node.y;
		node.bbox[2] = node.node.x + node.node.w;
		node.bbox[3] = node.node.y + node.node.h;
		
		node.h = node.bbox[3] - node.bbox[1];
		return node;
	}
	
	for( var i = 0, n = array_length(node.children); i < n; i++ ) {
		var _n = node.children[i];
		__node_bbox_recal(_n, param);
		
		node.bbox[0] = min(node.bbox[0], _n.bbox[0]);
		node.bbox[1] = min(node.bbox[1], _n.bbox[1]);
		node.bbox[2] = max(node.bbox[2], _n.bbox[2]);
		node.bbox[3] = max(node.bbox[3], _n.bbox[3]);
	}
	
	if(node.node) node.bbox[1] = max(node.bbox[1], node.node.y);
	node.h = node.bbox[3] - node.bbox[1];
	return node;
}

function node_auto_organize(nodeList, param = new node_auto_organize_parameter()) {
	if(array_empty(nodeList)) return;
	
	var cx = 0, cy = 0;
	for( var i = 0, n = array_length(nodeList); i < n; i++ ) {
		var _n = nodeList[i];
		cx += _n.x + _n.w / 2;
		cy += _n.y + _n.h / 2;
	}
	cx /= n; cy /= n;
	
	var root = { node: noone, children: [], w: 0, h: 0, depth: 0 };
	
	for( var i = 0, n = array_length(nodeList); i < n; i++ ) {
		var _n   = nodeList[i];
		var _nto = _n.getNodeTo();
		
		var _isRoot = array_empty(_nto) || array_empty(array_union(_nto, nodeList));
		if(_isRoot) array_push(root.children, __node_auto_organize_graph(_n));
	}
	
	array_sort(root.children, function(a, b) /*=>*/ {return a.node.y - b.node.y});
	
	__node_auto_organize_size(root, param);
	__node_auto_organize(root, param, 0, 0);
	
	repeat(1) {
		__node_bbox_recal(root, param);
		__node_auto_organize(root, param, 0, 0, true);
	}
	
	var ncx = 0, ncy = 0;
	for( var i = 0, n = array_length(nodeList); i < n; i++ ) {
		var _n = nodeList[i];
		ncx += _n.x + _n.w / 2;
		ncy += _n.y + _n.h / 2;
	}
	ncx /= n; ncy /= n;
	
	var dx = ncx - cx;
	var dy = ncy - cy;
	
	if(param.snap) {
		dx = value_snap(dx, param.snap_size);
		dy = value_snap(dy, param.snap_size);
	}
	
	for( var i = 0, n = array_length(nodeList); i < n; i++ ) {
		var _n   = nodeList[i];
		_n.x = _n.x - dx;
		_n.y = _n.y - dy;
	}
	
	PANEL_GRAPH.draw_refresh = true;
}