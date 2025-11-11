function Node_Strand_Force_Apply(_x, _y, _group = noone) : _Node_Strand_Affector(_x, _y, _group) constructor {
	name  = "Strand Force";
	color = COLORS.node_blend_strand;
	icon  = THEME.strandSim;
	setDimension(96, 48);
	
	manual_ungroupable	 = false;
	
	newInput(input_fix_len + 0, nodeValue_Slider("Strength", 1, [ 0, 5, 0.01 ] ));
	
	newInput(input_fix_len + 1, nodeValue_Float("Turbulence", 0));
		
	newInput(input_fix_len + 2, nodeValueSeed());
	
	newInput(input_fix_len + 3, nodeValue_Float("Turbulence frequency", 0.5));
	
	newInput(input_fix_len + 4, nodeValue_Int("Turbulence detail", 2));
	
	array_push(input_display_list, 
		["Force",	false], input_fix_len + 0, input_fix_len + 2, input_fix_len + 1, input_fix_len + 3, input_fix_len + 4
	);
	
	static update = function(frame = CURRENT_FRAME) {
		var _pos = getInputData(2);
		var _dir = getInputData(4);
	
		var _stn = getInputData(input_fix_len + 0);
		var _tur = getInputData(input_fix_len + 1);
		var _sed = getInputData(input_fix_len + 2);
		var _tfr = getInputData(input_fix_len + 3);
		var _toc = getInputData(input_fix_len + 4);
		
		inputs[4].setVisible(true);
		
		var _strTur = _tur == 0? _stn : perlin1D(CURRENT_FRAME, _sed, _tfr, _toc, _stn - _tur, _stn + _tur);
		var gx = lengthdir_x(_strTur, _dir);
		var gy = lengthdir_y(_strTur, _dir);
		
		var _pos1 = [
			_pos[0] + lengthdir_x(16, _dir),
			_pos[1] + lengthdir_y(16, _dir),
		];
		
		STRAND_EFFECTOR_PRE
			pnt.x += gx * mulp;
			pnt.y += gy * mulp;
		STRAND_EFFECTOR_POST
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		draw_sprite_fit(s_node_strand_force_apply, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}