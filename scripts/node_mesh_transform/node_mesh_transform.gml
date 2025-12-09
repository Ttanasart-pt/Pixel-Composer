function Node_Mesh_Transform(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Mesh Transform";
	setDimension(96, 48);
	setDrawIcon(s_node_mesh_transform);
	
	newInput(0, nodeValue_Mesh( "Mesh" )).setVisible(true, true);
	
	newInput(1, nodeValue_Vec2(     "Position", [0,0] )).setHotkey("G");
	newInput(2, nodeValue_Rotation( "Rotation",  0    )).setHotkey("R");
	newInput(3, nodeValue_Vec2(     "Scale",    [1,1] ));
	newInput(4, nodeValue_Vec2(     "Anchor",   [0,0] ));
	
	newOutput(0, nodeValue_Output("Mesh", VALUE_TYPE.mesh, noone));
	
	__pp = [ 0, 0 ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var imesh = getInputData(0);
		var omesh = outputs[0].getValue();
		if(imesh == noone) return w_hovering;
		
		var _cm = imesh.center;
		var pos = getInputData(1);
		
		var ax = _x + _cm[0] * _s;
		var ay = _y + _cm[1] * _s;
		
		var px = ax + pos[0] * _s;
		var py = ay + pos[1] * _s;
		
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, ax, ay, _s, _mx, _my, _snx, _sny));
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my, _snx, _sny));
		
		draw_set_color(COLORS._main_icon);
		omesh.draw(_x, _y, _s);
		
		return w_hovering;
	}
	
	function pointTransform(p, _pos, _rot, _sca, _anc) {
		p.x = _anc[0] + (p.x - _anc[0]) * _sca[0];
		p.y = _anc[1] + (p.y - _anc[1]) * _sca[1];
			
		point_rotate(p.x, p.y, _anc[0], _anc[1], _rot, __pp);
		p.x = __pp[0] + _pos[0];
		p.y = __pp[1] + _pos[1];
	}
	
	static update = function() {  
		var _msh = getInputData(0);
		var _pos = getInputData(1);
		var _rot = getInputData(2);
		var _sca = getInputData(3);
		var _anc = getInputData(4);
		
		if(_msh == noone) return;
		var mesh = _msh.clone();
		var _cm  = _msh.center;
		
		_anc = [ _cm[0] + _anc[0], _cm[1] + _anc[1] ];
		
		for( var i = 0, n = array_length(mesh.points); i < n; i++ )
			pointTransform(mesh.points[i], _pos, _rot, _sca, _anc);
		
		mesh.calcCoM();
		
		outputs[0].setValue(mesh);
	}
}