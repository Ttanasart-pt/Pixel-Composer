function Node_VFX_Override(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "VFX Override";
	color = COLORS.node_blend_vfx;
	icon  = THEME.vfx;
	previewable = false;
	node_draw_icon = s_node_vfx_override;
	
	w = 96;
	h = 80;
	min_h = h;
	
	inputs[| 0] = nodeValue("Particles", self, JUNCTION_CONNECT.input, VALUE_TYPE.particle, -1 )
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Positions", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [] )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 2] = nodeValue("Rotations", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [] )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 3] = nodeValue("Scales", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0 );
	
	inputs[| 4] = nodeValue("Blend", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white );
	
	inputs[| 5] = nodeValue("Alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0 );
	
	inputs[| 6] = nodeValue("Surface", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone )
		.setVisible(true, false);
	
	outputs[| 0] = nodeValue("Particles", self, JUNCTION_CONNECT.output, VALUE_TYPE.particle, -1 );
	
	static update = function(frame = CURRENT_FRAME) {
		var parts = getInputData(0);
		if(!is_array(parts)) return;
		
		var _pos = getInputData(1);
		var _sca = getInputData(2);
		var _rot = getInputData(3);
		var _col = getInputData(4);
		var _alp = getInputData(5);
		var _srf = getInputData(6);
		
		var nParts = array_create(array_length(parts));
		
		var _a_pos = is_array(_pos);
		var _a_sca = is_array(_sca);
		var _a_rot = is_array(_rot);
		var _a_col = is_array(_col);
		var _a_alp = is_array(_alp);
		var _a_srf = is_array(_srf);
		
		var _l_pos = array_length(_pos);
		var _l_sca = array_length(_sca);
		var _l_rot = array_length(_rot);
		var _l_col = array_length(_col);
		var _l_alp = array_length(_alp);
		var _l_srf = array_length(_srf);
		
		for( var i = 0, n = array_length(parts); i < n; i++ ) {
			var nPart = parts[i].clone();
			
			if(_a_pos && _l_pos > i && is_array(_pos[i])) {
				nPart.x = _pos[i][0];
				nPart.y = _pos[i][1];
			}
			
			if(_a_sca && _l_sca > i && is_array(_sca[i])) {
				nPart.scx = _sca[i][0];
				nPart.scy = _sca[i][1];
			}
			
			if(_a_rot && _l_rot > i) nPart.rot   = array_safe_get(_rot, i);
			if(_a_col && _l_col > i) nPart.blend = array_safe_get(_col, i);
			if(_a_alp && _l_alp > i) nPart.alp   = array_safe_get(_alp, i);
			if(_a_srf && _l_srf > i) nPart.surf  = array_safe_get(_srf, i);
			
			nParts[i] = nPart;
		}
		
		outputs[| 0].setValue(nParts);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(node_draw_icon, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
		
	getPreviewingNode = VFX_PREVIEW_NODE;
}