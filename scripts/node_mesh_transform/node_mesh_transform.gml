function Node_Mesh_Transform(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "Mesh Transform";
	previewable = false;
	
	w = 96;
	
	inputs[| 0] = nodeValue("Mesh", self, JUNCTION_CONNECT.input, VALUE_TYPE.mesh, noone)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 2] = nodeValue("Rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.rotation);
	
	inputs[| 3] = nodeValue("Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 4] = nodeValue("Anchor", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	outputs[| 0] = nodeValue("Mesh", self, JUNCTION_CONNECT.output, VALUE_TYPE.mesh, noone);
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var pos = inputs[| 1].getValue();
		
		var px = _x + pos[0] * _s;
		var py = _y + pos[1] * _s;
		
		active &= !inputs[| 1].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
		active &= !inputs[| 2].drawOverlay(active, px, py, _s, _mx, _my, _snx, _sny);
		active &= !inputs[| 4].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny, THEME.anchor );
		
		var mesh = outputs[| 0].getValue();
		if(mesh == noone) return;
		
		draw_set_color(COLORS._main_accent);
		mesh.draw(_x, _y, _s);
	}
	
	function pointTransform(p, _pos, _rot, _sca, _anc) {
		p.x = _anc[0] + (p.x - _anc[0]) * _sca[0];
		p.y = _anc[1] + (p.y - _anc[1]) * _sca[1];
			
		var _pp = point_rotate(p.x, p.y, _anc[0], _anc[1], _rot);
			
		p.x = _pp[0] + _pos[0];
		p.y = _pp[1] + _pos[1];
	}
	
	function update() {  
		var _msh = inputs[| 0].getValue();
		var _pos = inputs[| 1].getValue();
		var _rot = inputs[| 2].getValue();
		var _sca = inputs[| 3].getValue();
		var _anc = inputs[| 4].getValue();
		
		if(_msh == noone) return;
		var mesh = _msh.clone();
		
		for( var i = 0; i < array_length(mesh.triangles); i++ ) {
			var t = mesh.triangles[i];
			
			pointTransform(t[0], _pos, _rot, _sca, _anc);
			pointTransform(t[1], _pos, _rot, _sca, _anc);
			pointTransform(t[2], _pos, _rot, _sca, _anc);
		}
		
		outputs[| 0].setValue(mesh);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_mesh_path, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}