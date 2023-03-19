function Node_Strand_Force_Apply(_x, _y, _group = noone) : _Node_Strand_Affector(_x, _y, _group) constructor {
	name = "Strand Force";
	color = COLORS.node_blend_strand;
	icon  = THEME.strandSim;
	w = 96;
	
	inputs[| input_fix_len + 0] = nodeValue("Strength", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 5, 0.01 ]);
	
	inputs[| input_fix_len + 1] = nodeValue("Turbulence", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0);
		
	inputs[| input_fix_len + 2] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, irandom_range(10000, 99999));
	
	inputs[| input_fix_len + 3] = nodeValue("Turbulence frequency", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5);
	
	inputs[| input_fix_len + 4] = nodeValue("Turbulence detail", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 2);
	
	array_push(input_display_list, 
		["Force",	false], input_fix_len + 0, input_fix_len + 2, input_fix_len + 1, input_fix_len + 3, input_fix_len + 4
	);
	
	static update = function(frame = ANIMATOR.current_frame) {
		var _pos = inputs[|  2].getValue();
		var _dir = inputs[|  4].getValue();
	
		var _stn = inputs[| input_fix_len + 0].getValue();
		var _tur = inputs[| input_fix_len + 1].getValue();
		var _sed = inputs[| input_fix_len + 2].getValue();
		var _tfr = inputs[| input_fix_len + 3].getValue();
		var _toc = inputs[| input_fix_len + 4].getValue();
		
		inputs[| 4].setVisible(true);
		
		var _strTur = _tur == 0? _stn : perlin1D(_sed + ANIMATOR.current_frame, _tfr, _toc, _stn - _tur, _stn + _tur);
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
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_strandSim_force, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}