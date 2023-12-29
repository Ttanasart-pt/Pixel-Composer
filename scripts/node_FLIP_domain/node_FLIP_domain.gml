function Node_FLIP_Domain(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Domain";
	color = COLORS.node_blend_fluid;
	icon  = THEME.fluid_sim;
	w     = 96;
	min_h = 96;
	
	manual_ungroupable = false;
	update_on_frame = true;
	
	inputs[| 0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF)
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue("Particle Size", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 2);
	
	inputs[| 2] = nodeValue("Particle Density", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 10);
	
	inputs[| 3] = nodeValue("FLIP Ratio", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.8)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 4] = nodeValue("Resolve accelerator", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1.5);
	
	inputs[| 5] = nodeValue("Iteration", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 8);
	
	inputs[| 6] = nodeValue("Damping", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.8)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 7] = nodeValue("Gravity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 5);
	
	inputs[| 8] = nodeValue("Time Step", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.05);
	
	input_display_list = [
		["Domain",	false], 0, 1, 2, 
		["Solver",  false], 3, 4, 5, 
		["Physics", false], 8, 6, 7, 
	]
	
	outputs[| 0] = nodeValue("Domain", self, JUNCTION_CONNECT.output, VALUE_TYPE.fdomain, noone);
	
	attributes.max_particles = 10000;
	
	domain = instance_create(0, 0, FLIP_Domain);
	
	static update = function(frame = CURRENT_FRAME) {
		var _dim = getInputData(0);
		var _siz = getInputData(1);
		var _den = getInputData(2);
		
		var _flp = getInputData(3);
		var _ovr = getInputData(4);
		var _itr = getInputData(5);
		 
		var _dmp = getInputData(6);
		var _grv = getInputData(7);
		var _dt  = getInputData(8);
		
		if(frame == 0 || domain == noone) {
			var width        = _dim[0] + _siz * 2;
			var height       = _dim[1] + _siz * 2;
			var particleSize = _siz;
			var density      = _den;
			var maxParticles = attributes.max_particles;
			
			domain.init(width, height, particleSize, density, maxParticles);
		}
		
		domain.velocityDamping  = _dmp;
		domain.dt               = _dt;
		domain.iteration        = _itr;
			
		domain.g                = _grv;
		domain.flipRatio        = _flp;
		domain.numPressureIters = 3;
		domain.numParticleIters = 3;
		domain.overRelaxation   = _ovr;
		
		domain.update();
		
		outputs[| 0].setValue(domain);
	}
}