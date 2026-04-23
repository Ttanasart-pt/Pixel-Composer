function Node_Strand_Force_Apply(_x, _y, _group = noone) : _Node_Strand_Affector(_x, _y, _group) constructor {
	name  = "Strand Force";
	color = COLORS.node_blend_strand;
	icon  = THEME.strandSim;
	setDimension(96, 48);
	setDrawIcon(s_node_strand_force_apply);
	
	manual_ungroupable	 = false;
	var i = input_fix_len;
	
	////- =Force
	newInput(i+0, nodeValue_Slider( "Strength", 1, [ 0, 5, 0.01 ] ));
	newInput(i+2, nodeValueSeed());
	newInput(i+1, nodeValue_Float( "Turbulence",            0 ));
	newInput(i+3, nodeValue_Float( "Turbulence frequency", .5 ));
	newInput(i+4, nodeValue_Int(   "Turbulence detail",     2 ));
	// i+5
	
	array_push(input_display_list, 
		[ "Force", false ], i+0, i+2, i+1, i+3, i+4, 
	);
	
	static update = function(frame = CURRENT_FRAME) {
		#region data
			var i = input_fix_len;
			
			var _pos = getInputData(2);
			var _dir = getInputData(4);
		
			var _stn = getInputData(i+0);
			var _tur = getInputData(i+1);
			var _sed = getInputData(i+2);
			var _tfr = getInputData(i+3);
			var _toc = getInputData(i+4);
			
			inputs[4].setVisible(true);
		#endregion
		
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
	
}