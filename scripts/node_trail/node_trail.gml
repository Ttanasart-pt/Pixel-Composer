#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Trail", "Max Life > Set", KEY_GROUP.numeric, MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS_NUMBER _n.inputs[1].setValue(KEYBOARD_NUMBER); });
		addHotkey("Node_Trail", "Loop > Toggle",                "L", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[2].setValue((_n.inputs[2].getValue() + 1) % 2); });
		addHotkey("Node_Trail", "Match Color > Toggle",         "M", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[4].setValue((_n.inputs[4].getValue() + 1) % 2); });
		addHotkey("Node_Trail", "Blend Color > Toggle",         "B", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[5].setValue((_n.inputs[5].getValue() + 1) % 2); });
	});
#endregion

function Node_Trail(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Trail";
	clearCacheOnChange = false;
	setCacheManual();
	
	////- =Surfaces
	newInput(0, nodeValue_Surface("Surface In")).rejectArray();
	
	////- =Trail
	newInput(1, nodeValue_Int(  "Max Life", 5));
	newInput(2, nodeValue_Bool( "Loop", false));
	
	////- =Tracking
	newInput(3, nodeValue_Int(  "Max Distance", -1, "Maximum distance to search for movement, set to -1 to search the entire image."));
	newInput(4, nodeValue_Bool( "Match Color", true, "Make trail track pixels of the same color, instead of the closet pixels."));
	newInput(5, nodeValue_Bool( "Blend Color", true, "Blend color between two pixel smoothly."));
	
	////- =Rendering
	newInput(6, nodeValue_Curve( "Alpha Over Life", CURVE_DEF_11));
	// inputs 7
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [
		["Surfaces",   true], 0, 
		["Trail",     false], 1, 2, 3, 
		["Rendering", false], 6, 
	];
	
	////- Node
	
	temp_surface = array_create(5);
	
	attribute_surface_depth();
	
	static update = function() {
		var _surf  = getInputData(0);
		var _life  = getInputData(1);
		var _loop  = getInputData(2);
		var _rang  = getInputData(3);
		var _alpha = getInputData(6);
		var cDep   = attrDepth();
		
		if(!is_surface(_surf)) {
			logNode($"Surface array not supported.");
			return;
		}
		
		cacheCurrentFrame(_surf);
		
		var _sw = surface_get_width_safe(_surf);
		var _sh = surface_get_height_safe(_surf);
		
		for( var i = 0, n = array_length(temp_surface); i < n; i++ ) {
			temp_surface[i] = surface_verify(temp_surface[i], _sw, _sh, cDep);
			surface_clear(temp_surface[i]);
		}
		
		var famo = _loop? _life : min(_life, CURRENT_FRAME);
		
		var startF = CURRENT_FRAME - _life;
		if(startF < 0) startF = _loop? TOTAL_FRAMES + startF : 0;
		
		var preF, curF, curR = startF;
		var preS, curS;
		var a0, a1;
		var bg = 0;
		
		for(var i = 0; i < famo; i++) {
			a1 = eval_curve_x(_alpha, (i + 1) / (famo + 1));
			
			preF = curR;
			curF = curR == TOTAL_FRAMES - 1? 0 : curR + 1; 
			preS = getCacheFrame(preF);
			curS = getCacheFrame(curF);
			
			curR = curR == TOTAL_FRAMES - 1? 0 : curR + 1; 
			
			if(!is_surface(preS)) continue;
			
			if(preF >= curF || !is_surface(curS)) {
				surface_set_shader(temp_surface[bg], sh_trail_blend, true, BLEND.over);
					shader_set_surface("bg", temp_surface[!bg]);
					shader_set_surface("fg", preS);
					shader_set_f("alpha", a1);
					
					draw_empty();
				surface_reset_target();
				
				bg = !bg;
				continue;
			}
			
			shader_set(sh_trail_filler_pass1);
			shader_set_surface("prevFrame", preS);
			shader_set_surface("currFrame", curS);
			shader_set_dim("dimension",     _surf);
			shader_set_f("range",           _rang? _rang : _sw / 2);
			shader_set_f("alpha",           a1);
			
			surface_set_target_ext(0, temp_surface[2]);
				draw_empty();
			surface_reset_target();
			shader_reset();
			
			surface_set_shader(temp_surface[bg], sh_trail_blend, true, BLEND.over);
				shader_set_surface("bg", temp_surface[!bg]);
				shader_set_surface("fg", temp_surface[2]);
				shader_set_f("alpha", 1);
				
				draw_empty();
			surface_reset_target();
			
			bg = !bg;
		}
		
		var _outSurf = outputs[0].getValue();
		    _outSurf = surface_verify(_outSurf, _sw, _sh, cDep);
		outputs[0].setValue(_outSurf);
		
		surface_set_shader(_outSurf);
			draw_surface_safe(temp_surface[!bg]);
			draw_surface_safe(_surf);
		surface_reset_shader();
	}
	
}