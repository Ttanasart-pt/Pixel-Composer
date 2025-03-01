function Node_Pixel_Builder(_x, _y, _group = noone) : Node_Collection(_x, _y, _group) constructor {
	name  = "Pixel Builder";
	color = COLORS.node_blend_feedback;
	icon  = THEME.pixel_builder;
	
	reset_all_child = true;
	attributes.pure_function = false;
	
	newInput(0, nodeValue_Dimension(self));
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	group_input_display_list  = [ 0 ];
	group_output_display_list = [ 0 ];
	
	custom_input_index  = array_length(inputs);
	custom_output_index = array_length(outputs);
	
	dimension = [ 1, 1 ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		if(!draw_input_overlay) return;
		
		for(var i = custom_input_index; i < array_length(inputs); i++) {
			var _in = inputs[i];
			var _hv = _in.from.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
			if(_hv != undefined) active &= !_hv;
		}
		
		inputs[0].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static checkComplete = function() {
		for( var i = 0, n = array_length(nodes); i < n; i++ ) {
			var _n = nodes[i];
			if(!is(_n, Node_PB_Output)) continue;
			if(!_n.rendered) continue;
		}
		
		buildPixel();
	}
	
	static buildPixel = function() {
		var _outSurf = outputs[0].getValue();
		_outSurf = surface_verify(_outSurf, dimension[0], dimension[1]);
		
		var pr = ds_priority_create();
		for( var i = 0, n = array_length(nodes); i < n; i++ ) {
			var _n = nodes[i];
			if(!is(_n, Node_PB_Output)) continue;
			if(!_n.drawA) continue;
			
			ds_priority_add(pr, _n, _n.layr);
		}
		
		surface_set_shader(_outSurf, noone);
			while(!ds_priority_empty(pr)) {
				var _n = ds_priority_delete_min(pr);
				var _surf = _n.data;
				var _blnd = _n.blend;
				
				switch(_blnd) {
					case 0 : BLEND_NORMAL;   break;
					case 1 : BLEND_SUBTRACT; break;
				}
				
				draw_surface_safe(_surf);
				
				BLEND_NORMAL
			}
		surface_reset_shader();
		
		ds_priority_destroy(pr);
		
		outputs[0].setValue(_outSurf);
	}

	static update = function() {
		dimension = inputs[0].getValue();
	}
	
	static checkPureFunction = function() {
		isPure = false;
	}
	
	static getGraphPreviewSurface = function() /*=>*/ {return outputs[0].getValue()};
}