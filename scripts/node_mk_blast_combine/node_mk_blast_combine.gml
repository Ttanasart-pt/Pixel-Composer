function Node_MK_Blast_Combine(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Combine";
	color = COLORS.node_blend_mkblast;
	icon  = THEME.mkBlast;
	update_on_frame = true;
	setDrawIcon();
	setDimension(96, 48);
	
	////- =Blast
	newInput( 0, nodeValue_Toggle( "Mask", 0b01, [ "Flame", "Smoke" ] ));
	// 1
	
	newOutput( 0, nodeValue_Output( "Blast", VALUE_TYPE.struct, [] )).setCustomData(global.MKBLAST_JUNC);
	
	input_display_list = [ s_MKFX,
		[ "Blast", false ],  0, 
	];
	
	function createNewInput(index = array_length(inputs)) {
		var inAmo = array_length(inputs);
		newInput(index, nodeValue_Struct( "Blast" )).setCustomData(global.MKBLAST_JUNC).setVisible(true, true);
		array_push(input_display_list, inAmo);
		return inputs[index];
	} setDynamicInput(1);
	
	////- Nodes
	
	static getDimension = function() /*=>*/ {return is(inline_context, Node_MK_Blast_Inline)? inline_context.getDimension() : DEF_SURF};
	
	static update = function() {
		if(!is(inline_context, Node_MK_Blast_Inline)) return;
		
		#region data
			var _mask = getInputData( 0);
		#endregion
		
		var _flameLayer = [];
		
		for( var i = input_fix_len, n = array_length(inputs); i < n; i++) {
			var _fl = getInputData(i);
			_flameLayer = array_append(_flameLayer, _fl);
		}
		
		outputs[0].setValue(_flameLayer);
	}
}
