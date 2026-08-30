function Node_Revert(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Reverse";
	setCacheManual();
	
	newInput( 0, nodeValue_Surface("Surface In")).setRequired();
	// 1
	
	newOutput( 0, nodeValue_Output("Output", VALUE_TYPE.surface, noone));
	
	cacheLabel = new Inspector_Label("Play the animation first.", f_p3, COLORS._main_value_negative, COLORS._main_value_negative);
	
	input_display_list = [ cacheLabel, 
		[ "Surfaces", true ], 0, 
	];
	
	////- Node
	
	cache_wait = false;
	
	static update = function(_frame = CURRENT_FRAME) {
		if(!inputs[0].value_from) return;
		if(!inputs[0].value_from.node.renderActive) return;
		
		var _surf = getInputData(0);
		cacheCurrentFrame(_surf);
		
		var _frm = TOTAL_FRAMES - _frame - 1;
		
		cache_wait = !cacheExist(_frm);
		cacheLabel.visible = cache_wait;
		if(cache_wait) return;
		
		outputs[0].setValue(getCacheFrame(_frm));
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		if(cache_wait) draw_sprite_ui(THEME.cache, 0, xx + w * _s / 2, yy + h * _s / 2, _s, _s, 0, COLORS._main_icon, 1);
	}
	
}