function Node_ASE_Tag(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "ASE Tag";
	
	newInput(0, nodeValue("ASE data", self, CONNECT_TYPE.input, VALUE_TYPE.object, noone))
		.setIcon(s_junc_aseprite, c_white)
		.setVisible(false, true)
		.rejectArray();
	
	newInput(1, nodeValue_Text("Tag", self, ""));
	
	newOutput(0, nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone));
	
	temp_surface = [ 0, 0, 0 ];
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _ase = _data[0];
		var _tag = _data[1];
		
		if(_ase == noone || _ase.content == noone) return;
		
		var _cnt = _ase.content;
		var ww   = _cnt[$ "Width"];
		var hh   = _cnt[$ "Height"];
		_outSurf = surface_verify(_outSurf, ww, hh);
		
		var tag = noone;
		for( var i = 0, n = array_length(_ase.tags); i < n; i++ ) {
			if(_ase.tags[i][$ "Name"] == _tag) {
				tag = _ase.tags[i];
				break;
			}
		}
		
		if(tag == noone) return;
		
		for (var i = 0, n = array_length(temp_surface); i < n; i++) {
			temp_surface[i] = surface_verify(temp_surface[i], ww, hh);
			surface_clear(temp_surface[i]);
		}
		
		blend_temp_surface = temp_surface[2];
		
		var st = tag[$ "Frame start"];
		var ed = tag[$ "Frame end"];
		var fr = st + CURRENT_FRAME % (ed - st);
		var bg = 0;
		
		for( var i = 0, n = array_length(_ase.layers); i < n; i++ ) {
			var cel = _ase.layers[i].getCel(fr);
			if(!cel) continue;
			
			var _inSurf = cel.getSurface();
			if(!is_surface(_inSurf)) continue;
			
			var xx = cel.data[$ "X"];
			var yy = cel.data[$ "Y"];
			
			surface_set_shader(temp_surface[bg], sh_sample, true, BLEND.over);
				draw_surface_blend_ext(temp_surface[!bg], _inSurf, xx, yy);
			surface_reset_shader();
			
			bg = !bg;
		}
		
		surface_set_shader(_outSurf);
			DRAW_CLEAR
			draw_surface_safe(temp_surface[!bg]);
		surface_reset_shader();
		
		return _outSurf;
	}
}