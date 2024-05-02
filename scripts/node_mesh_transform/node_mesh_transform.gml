function Node_Mesh_Transform(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Mesh Transform";
	setDimension(96, 48);;
	
	inputs[| 0] = nodeValue("Mesh", self, JUNCTION_CONNECT.input, VALUE_TYPE.mesh, noone)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 2] = nodeValue("Rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.rotation);
	
	inputs[| 3] = nodeValue("Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 4] = nodeValue("Anchor", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	outputs[| 0] = nodeValue("Mesh", self, JUNCTION_CONNECT.output, VALUE_TYPE.mesh, noone);
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var imesh = getInputData(0);
		var omesh = outputs[| 0].getValue();
		if(imesh == noone) return;
		
		var _cm = imesh.center;
		var pos = getInputData(1);
		
		var ax = _x + _cm[0] * _s;
		var ay = _y + _cm[1] * _s;
		
		var px = ax + pos[0] * _s;
		var py = ay + pos[1] * _s;
		
		active &= !inputs[| 1].drawOverlay(hover, active, ax, ay, _s, _mx, _my, _snx, _sny);
		active &= !inputs[| 2].drawOverlay(hover, active, px, py, _s, _mx, _my, _snx, _sny);
		
		draw_set_color(COLORS._main_accent);
		omesh.draw(_x, _y, _s);
	}
	
	function pointTransform(p, _pos, _rot, _sca, _anc) {
		p.x = _anc[0] + (p.x - _anc[0]) * _sca[0];
		p.y = _anc[1] + (p.y - _anc[1]) * _sca[1];
			
		var _pp = point_rotate(p.x, p.y, _anc[0], _anc[1], _rot);
			
		p.x = _pp[0] + _pos[0];
		p.y = _pp[1] + _pos[1];
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
		
		for( var i = 0, n = array_length(mesh.triangles); i < n; i++ ) {
			var t = mesh.triangles[i];
			
			pointTransform(t[0], _pos, _rot, _sca, _anc);
			pointTransform(t[1], _pos, _rot, _sca, _anc);
			pointTransform(t[2], _pos, _rot, _sca, _anc);
		}
		
		mesh.calcCoM();
		
		outputs[| 0].setValue(mesh);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_mesh_path, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}