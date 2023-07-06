function Node_Animation_Control(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "Animation Control";
	
	w = 96;
	h = 96;
	min_h = h;
	
	inputs[| 0] = nodeValue("Toggle Play / Pause", self, JUNCTION_CONNECT.input, VALUE_TYPE.trigger, 0);
	
	inputs[| 1] = nodeValue("Pause", self, JUNCTION_CONNECT.input, VALUE_TYPE.trigger, 0);
	
	inputs[| 2] = nodeValue("Resume", self, JUNCTION_CONNECT.input, VALUE_TYPE.trigger, 0);
	
	inputs[| 3] = nodeValue("Play From Beginning", self, JUNCTION_CONNECT.input, VALUE_TYPE.trigger, 0);
	
	inputs[| 4] = nodeValue("Play once", self, JUNCTION_CONNECT.input, VALUE_TYPE.trigger, 0);
	
	inputs[| 5] = nodeValue("Skip Frames", self, JUNCTION_CONNECT.input, VALUE_TYPE.trigger, 0);
	
	inputs[| 6] = nodeValue("Skip Frames Count", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1);
	
	static step = function() { 
		if(inputs[| 0].getValue())
			PROJECT.animator.toggle();
		
		if(inputs[| 1].getValue())
			PROJECT.animator.pause();
		
		if(inputs[| 2].getValue())
			PROJECT.animator.resume();
		
		if(inputs[| 3].getValue()) {
			PROJECT.animator.stop();
			PROJECT.animator.play();
		} 
		
		if(inputs[| 4].getValue())
			PROJECT.animator.render();
		
		if(inputs[| 5].getValue()) { 
			var fr = inputs[| 6].getValue();
			PROJECT.animator.setFrame(PROJECT.animator.current_frame + fr);
		}
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		var ind  = 0;
		
		if(PROJECT.animator.is_playing) ind = 1;
		
		draw_sprite_fit(THEME.sequence_control, ind, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}