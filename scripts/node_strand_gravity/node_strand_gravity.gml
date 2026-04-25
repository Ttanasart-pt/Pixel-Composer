function Node_Strand_Gravity(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Strand Gravity";
	color = COLORS.node_blend_strand;
	icon  = THEME.strandSim;
	setDimension(96, 48);
	setDrawIcon(s_node_strand_gravity);
	
	manual_ungroupable	 = false;
	
	newInput( 0, nodeValue_Strand());
	
	////- =Gravity
	newInput( 1, nodeValue_Float(    "Gravity",    1  ));
	newInput( 2, nodeValue_Rotation( "Direction", -90 ));
	
	newOutput(0, nodeValue_Output("Strand", VALUE_TYPE.strands, noone));
	
	input_display_list = [ 0, 
		[ "Gravity", false ], 1, 2, 
	];
	
	////- Node
	
	static update = function(frame = CURRENT_FRAME) {
		#region data
			var _str = getInputData(0);
			var _gra = getInputData(1);
			var _dir = getInputData(2);
		#endregion
		
		if(_str == noone) return;
		var __str = _str;
		if(!is_array(_str)) __str = [ _str ];
		
		var gx = lengthdir_x(_gra, _dir);
		var gy = lengthdir_y(_gra, _dir);
		
		for( var k = 0; k < array_length(__str); k++ )
		for( var i = 0, n = array_length(__str[k].hairs); i < n; i++ ) {
			var h = __str[k].hairs[i];
			
			for( var j = h.free? 0 : 1, m = array_length(h.points); j < m; j++ ) {
				var p = h.points[j];
				p.x += p.dx;
				p.y += p.dy;
				
				p.x += gx;
				p.y += gy;
			}
		}
		
		outputs[0].setValue(_str);
	}
	
}