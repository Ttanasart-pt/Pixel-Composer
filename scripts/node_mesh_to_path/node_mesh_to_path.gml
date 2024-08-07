function Node_Mesh_To_Path(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "Mesh to Path";
	
	setDimension(96, 48);
	
	inputs[| 0] = nodeValue("Mesh", self, JUNCTION_CONNECT.input, VALUE_TYPE.mesh, noone)
		.setVisible(true, true);
	
	outputs[| 0] = nodeValue_Output("Path", self, VALUE_TYPE.pathnode, noone);
	
	segments = [];
	length   = 0;
	lengths  = [];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var mesh = getInputData(0);
		if(mesh == noone) return;
		
		draw_set_color(c_grey);
		mesh.draw(_x, _y, _s);
		
		draw_set_color(COLORS._main_accent);
		var op, np;
		
		for( var i = 0, n = array_length(segments); i < n; i += 1 ) {
			np = segments[i];
			if(i) draw_line_round(_x + op.x * _s, _y + op.y * _s, _x + np.x * _s, _y + np.y * _s, 2);
			op = np;
		}
	}
	
	static getLineCount = function() { return 1; }
	
	static getPointRatio = function(_rat) {
		_rat = frac(_rat);
		var l = _rat * length;
		
		for( var i = 1; i < array_length(lengths); i += 1 ) {
			if(l <= lengths[i]) {
				var rat = l / lengths[i];
				return segments[i - 1].lerpTo(segments[i], rat);
			}
			
			l -= lengths[i];
		}
		
		return new __vec2();
	}
	
	static update = function() {  
		var _mesh = getInputData(0);	
		outputs[| 0].setValue(self);
		if(_mesh == noone) return;
		
		segments = _mesh.mergePath();
		length   = 0;
		lengths  = [];
		
		var op, np;
		for( var i = 0, n = array_length(segments); i < n; i += 1 ) {
			np = segments[i];
			if(i) {
				lengths[i] = point_distance(op.x, op.y, np.x, np.y);
				length += lengths[i];
			}
			op = np;
		}
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_mesh_path, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}