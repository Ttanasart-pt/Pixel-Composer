function Node_Font_Data(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Font";
	always_pad = true;
	setDimension(96, 48);
	
	newInput( 0, nodeValue_Font( "Font" ));
	
	newOutput(0, nodeValue_Output("Font", VALUE_TYPE.font, noone ));
	
	input_display_list = [ 0 ];
	
	////- Nodes
	
	font     = undefined;
	fontName = "";
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
			var _font = _data[0];
		#endregion
		
		if(_font != fontName) {
			if(font) font_delete(font);
			
			font = font_add(_font, 32, false, false, 0, 0);
			font_enable_sdf(font, true);
		}
		
		return _font; 
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		draw_set_text(font ?? f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, "Abc");
	}
	
}