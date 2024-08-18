function Node_VFX_Override(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "VFX Override";
	color = COLORS.node_blend_vfx;
	icon  = THEME.vfx;
	node_draw_icon = s_node_vfx_override;
	
	manual_ungroupable = false;
	setDimension(96, 48);
	
	inputs[0] = nodeValue_Particle("Particles", self, -1 )
		.setVisible(true, true);
	
	newInput(1, nodeValue_Float("Positions", self, noone ));
	
	newInput(2, nodeValue_Float("Rotations", self, noone ));
	
	newInput(3, nodeValue_Float("Scales", self, noone ));
	
	newInput(4, nodeValue_Color("Blend", self, noone ));
	
	newInput(5, nodeValue_Float("Alpha", self, noone ));
	
	inputs[6] = nodeValue_Surface("Surface", self)
		.setVisible(true, false);
	
	outputs[0] = nodeValue_Output("Particles", self, VALUE_TYPE.particle, -1 );
	
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
		
		var _a_pos = inputs[1].value_from != noone;
		var _a_rot = inputs[2].value_from != noone;
		var _a_sca = inputs[3].value_from != noone;
		var _a_col = inputs[4].value_from != noone;
		var _a_alp = inputs[5].value_from != noone;
		var _a_srf = inputs[6].value_from != noone;
		
		if(array_get_depth(_pos) < 2) _pos = [ _pos ];
		if(array_get_depth(_sca) < 2) _sca = [ _sca ];
		if(!is_array(_rot))			  _rot = [ _rot ];
		if(!is_array(_col))			  _col = [ _col ];
		if(!is_array(_alp))			  _alp = [ _alp ];
		if(!is_array(_srf))			  _srf = [ _srf ];
		
		var _l_pos = array_length(_pos);
		var _l_sca = array_length(_sca);
		var _l_rot = array_length(_rot);
		var _l_col = array_length(_col);
		var _l_alp = array_length(_alp);
		var _l_srf = array_length(_srf);
		
		for( var i = 0, n = array_length(parts); i < n; i++ ) {
			var nPart = parts[i].clone();
			
			if(_a_pos) {
				nPart.x = _pos[i % _l_pos][0];
				nPart.y = _pos[i % _l_pos][1];
			}
			
			if(_a_sca) {
				nPart.scx = _sca[i % _l_sca][0];
				nPart.scy = _sca[i % _l_sca][1];
			}
			
			if(_a_rot) nPart.rot   = array_safe_get_fast(_rot, i % _l_rot);
			if(_a_col) nPart.blend = array_safe_get_fast(_col, i % _l_col);
			if(_a_alp) nPart.alp   = array_safe_get_fast(_alp, i % _l_alp);
			if(_a_srf) nPart.surf  = array_safe_get_fast(_srf, i % _l_srf);
			
			nParts[i] = nPart;
		}
	
		outputs[0].setValue(nParts);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(node_draw_icon, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
		
	getPreviewingNode = VFX_PREVIEW_NODE;
}