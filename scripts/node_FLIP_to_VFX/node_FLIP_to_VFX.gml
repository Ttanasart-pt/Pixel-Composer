function Node_FLIP_to_VFX(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "FLIP to VFX";
	color = COLORS.node_blend_fluid;
	icon  = THEME.fluid_sim;
	setDimension(96, 96);
	
	manual_ungroupable = false;
	
	inputs[| 0] = nodeValue_Fdomain("Domain", self, noone)
		.setVisible(true, true);
		
	outputs[| 0] = nodeValue_Output("Particles",	self, VALUE_TYPE.particle, [] );
	
	attributes.part_amount = 512;
	array_push(attributeEditors, ["Maximum particles", function() { return attributes.part_amount; },
		new textBox(TEXTBOX_INPUT.number, function(val) { attributes.part_amount = val; }) ]);
		
	for( var i = 0; i < attributes.part_amount; i++ )
		parts[i] = new __particleObject();
		
	static update = function(frame = CURRENT_FRAME) {
		var domain = getInputData(0);
		if(!instance_exists(domain)) return;
		if(domain.domain == noone)   return;
		
		var _x, _y, _p, _px, _py, _r, _l, _a, _v, _sx, _sy;
		var _mx  = min(array_length(domain.particlePos) / 2 - 1, domain.numParticles);
		var _pa  = outputs[| 0].getValue();
		var _ind = 0;
		
		for( var i = 0; i < _mx; i++ ) {
			_x  = domain.particlePos[i * 2 + 0];
			_y  = domain.particlePos[i * 2 + 1];
			
			if(_x == 0 && _y == 0) continue;
			
			_p = parts[_ind];
			_pa[_ind] = _p;
			_ind++;
			
			_p.active = true;
			_p.x = _x;
			_p.y = _y;
			
			if(_ind >= attributes.part_amount) break;
		}
		
		array_resize(_pa, _ind);
		outputs[| 0].setValue(_pa);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_fluidSim_to_VFX, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
	
}