#region global
	global.WAVE_JUNC = {
		icon:  function() /*=>*/ {return THEME.node_junction_ripple},
		color: function() /*=>*/ {return COLORS.node_blend_ripple},
		widg:  function() /*=>*/ {return new waveSimBox()},
	}
	
#endregion

function Node_WaveSim_Inline(_x, _y, _group = noone) : Node_Collection_Inline(_x, _y, _group) constructor {
	name  = "WaveSim";
	icon  = THEME.wavesim;
	color = COLORS.node_blend_ripple;
	is_simulation   = true;
	update_on_frame = true;
	
	dimension  = undefined;
	domain     = undefined;
	
	if(NODE_NEW_MANUAL) {
		var _source = nodeBuild("Node_WaveSim_Source", x,     y, self);
		var _render = nodeBuild("Node_WaveSim_Render", x+128, y, self);
		
		_render.inputs[0].setFrom(_source.outputs[0]);
		
		addNode(_source);
		addNode(_render);
	}
	
	////- =Inputs
	newInput( 0, nodeValue_Dimension());
	
	input_display_list = [ s_MKFX, 0 ];
	
	////- Nodes
	
	temp_surface = [noone];
	
	static getDimension = function() /*=>*/ { dimension = dimension ?? inputs[0].getValue(); return dimension; }
	
	static update = function() {
		var _dim  = inputs[0].getValue();
		dimension = _dim;
		domain    = surface_verify(domain, _dim[0], _dim[1], surface_rgba32float);
		
		if(IS_FIRST_FRAME) {
			surface_set_target(domain);
				draw_clear_alpha(0,0);
			surface_reset_target();
		}
		
		temp_surface[0] = surface_verify(temp_surface[0], _dim[0], _dim[1], surface_rgba32float);
		
		surface_set_shader(temp_surface[0], sh_wavesim_init);
			shader_set_s( "domain", domain );
			draw_empty();			
		surface_reset_shader();
		
		surface_set_shader(domain, noone, true, BLEND.over);
			draw_surface(temp_surface[0], 0, 0);
		surface_reset_shader();
		
	}
}