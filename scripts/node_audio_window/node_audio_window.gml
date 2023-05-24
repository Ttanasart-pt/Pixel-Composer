function Node_Audio_Window(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "Audio Window";
	previewable = false;
	
	w = 96;
	h = 32 + 24;
	min_h = h;
	
	inputs[| 0] = nodeValue("Audio Array", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [])
		.setArrayDepth(1)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Sample", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 44100);
	
	inputs[| 2] = nodeValue("Size", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 64);
	
	outputs[| 0] = nodeValue("Windowed Array", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, [])
		.setArrayDepth(1);
	
	static update = function(frame = ANIMATOR.current_frame) {
		var _arr = inputs[| 0].getValue();
		
		if(!is_array(_arr) || array_length(_arr) < 1) return;
		if(!is_array(_arr[0])) return;
		
		var sam = inputs[| 1].getValue();
		var siz = inputs[| 2].getValue();
		var res = [];
		var off = frame / ANIMATOR.framerate * sam;
		
		for( var i = 0; i < array_length(_arr); i++ ) {
			var _dat = _arr[i];
			res[i] = [];
			array_copy(res[i], 0, _dat, off, siz);
		}
		
		outputs[| 0].setValue(res);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_audio_trim, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}