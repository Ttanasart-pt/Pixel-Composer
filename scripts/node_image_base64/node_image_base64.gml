function Node_Image_Base64(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Image Base64";
	
	newInput( 0, nodeValue_Text( "Base64 text", "" )).setDisplay(VALUE_DISPLAY._default, { collapsible : true, collapsed : true });
	// 1
	
	newOutput( 0, nodeValue_Output( "Surface",   VALUE_TYPE.surface, noone));
	newOutput( 1, nodeValue_Output( "Dimension", VALUE_TYPE.integer, [1,1] )).setDisplay(VALUE_DISPLAY.vector);
	
	////- Node
	
	spr    = undefined;
	sprStr = "";
	
	static update = function() {
		var _str = getInputData( 0);
		
		if(_str != sprStr) {
			sprStr = _str;
			if(spr != undefined && sprite_exists(spr))
				sprite_delete(spr);
				
			spr = sprite_add(sprStr, 1, 0, 0, 0, 0);
		}
		
		if(spr == undefined || !sprite_exists(spr))
			return;
		
		var sw = sprite_get_width(spr);
		var sh = sprite_get_height(spr);
		
		var _surf = outputs[0].getValue();
		_surf = surface_verify(_surf, sw, sh);
		
		surface_set_shader(_surf, noone);
			draw_sprite(spr, 0, 0, 0);
		surface_reset_shader();
		
		outputs[0].setValue(_surf);
		outputs[1].setValue([sw,sh]);
	}
}
