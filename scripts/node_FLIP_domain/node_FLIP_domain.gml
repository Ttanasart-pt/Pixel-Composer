function Node_FLIP_Domain(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Domain";
	color = COLORS.node_blend_fluid;
	icon  = THEME.fluid_sim;
	setDimension(96, 96);
	
	manual_ungroupable = false;
	update_on_frame    = true;
	
	inputs[| 0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF)
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue("Particle Size", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1);
	
	inputs[| 2] = nodeValue("Particle Density", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 10);
	
	inputs[| 3] = nodeValue("FLIP Ratio", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.8)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 4] = nodeValue("Resolve accelerator", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1.5);
	
	inputs[| 5] = nodeValue("Iteration", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 8);
	
	inputs[| 6] = nodeValue("Damping", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.8)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 7] = nodeValue("Gravity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 5);
	
	inputs[| 8] = nodeValue("Time Step", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.05);
	
	inputs[| 9] = nodeValue("Wall", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0b1111)
		.setDisplay(VALUE_DISPLAY.toggle, { data:  [ "T", "B", "L", "R" ] });
	
	inputs[| 10] = nodeValue("Viscosity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ -1, 1, 0.01 ] });
	
	inputs[| 11] = nodeValue("Friction", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.)
		.setDisplay(VALUE_DISPLAY.slider);
		
	inputs[| 12] = nodeValue("Wall Elasticity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 2, 0.01 ] });
	
	inputs[| 13] = nodeValue("Gravity Direction", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 270)
		.setDisplay(VALUE_DISPLAY.rotation);
	
	input_display_list = [
		["Domain",	false], 0, 1, 9, 12, 
		["Solver",   true], 3, 8, 
		["Physics", false], 7, 13, 10, 11, 
	]
	
	outputs[| 0] = nodeValue("Domain", self, JUNCTION_CONNECT.output, VALUE_TYPE.fdomain, noone);
	
	#region attributes
		array_push(attributeEditors, "FLIP Solver");
	
		attributes.max_particles = 10000;
		array_push(attributeEditors, ["Maximum particles", function() { return attributes.max_particles; }, 
			new textBox(TEXTBOX_INPUT.number, function(val) { 
				attributes.max_particles = val; 
			})]);
	
		attributes.iteration = 8;
		array_push(attributeEditors, ["Global iteration", function() { return attributes.iteration; }, 
			new textBox(TEXTBOX_INPUT.number, function(val) { 
				attributes.iteration = val; 
				triggerRender();
			})]);
	
		attributes.iteration_pressure = 2;
		array_push(attributeEditors, ["Pressure iteration", function() { return attributes.iteration_pressure; }, 
			new textBox(TEXTBOX_INPUT.number, function(val) { 
				attributes.iteration_pressure = val; 
				triggerRender();
			})]);
	
		attributes.iteration_particle = 2;
		array_push(attributeEditors, ["Particle iteration", function() { return attributes.iteration_particle; }, 
			new textBox(TEXTBOX_INPUT.number, function(val) { 
				attributes.iteration_particle = val; 
				triggerRender();
			})]);
	
		attributes.overrelax = 1.5;
		array_push(attributeEditors, ["Overrelaxation", function() { return attributes.overrelax; }, 
			new textBox(TEXTBOX_INPUT.number, function(val) { 
				attributes.overrelax = val; 
				triggerRender();
			})]);
	
		attributes.skip_incompressible = false;
		array_push(attributeEditors, ["Skip incompressible", function() { return attributes.skip_incompressible; }, 
			new checkBox(function() { 
				attributes.skip_incompressible = !attributes.skip_incompressible;
				triggerRender();
			})]);
	#endregion
	
	domain  = instance_create(0, 0, FLIP_Domain);
	toReset = true;
	
	static step = function() {
		var _col = getInputData(9);
		
		inputs[| 12].setVisible(_col);
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var _dim = getInputData(0);
		var _siz = getInputData(1); _siz = max(_siz, 1);
		var _den = getInputData(2);
		
		var _flp = getInputData(3);
		 
		var _dmp = getInputData(6);
		var _grv = getInputData(7);
		var _dt  = getInputData(8);
		var _col = getInputData(9);
		
		var _vis  = getInputData(10);
		var _fric = getInputData(11);
		var _ela  = getInputData(12);
		var _gdir = getInputData(13);
		
		var _ovr  = attributes.overrelax;
		
		var _itr  = attributes.iteration;
		var _itrP = attributes.iteration_pressure;
		var _itrR = attributes.iteration_particle;
		
		var width        = _dim[0] + _siz * 2;
		var height       = _dim[1] + _siz * 2;
			
		if(IS_FIRST_FRAME || toReset) {
			var particleSize = _siz;
			var density      = _den;
			var maxParticles = attributes.max_particles;
			
			domain.init(width, height, particleSize, density, maxParticles);
		}
		
		toReset = false;
		
		domain.velocityDamping  = _dmp;
		domain.dt               = _dt;
		
		domain.iteration        = _itr;
		domain.numPressureIters = _itrP;
		domain.numParticleIters = _itrR;
			
		domain.g                = _grv;
		domain.gDirection       = _gdir;
		domain.flipRatio        = _flp;
		domain.overRelaxation   = _ovr;
		domain.viscosity        = _vis;
		domain.friction         = power(1 - _fric, 0.025);
		
		domain.wallCollide      = _col;
		domain.wallElasticity   = _ela;
		domain.skip_incompressible      = attributes.skip_incompressible;
		
		domain.update();
		
		outputs[| 0].setValue(domain);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_bbox(s_node_fluidSim_domain, 0, bbox);
	} #endregion
		
	static getPreviewValues = function() { return domain.domain_preview; }
	
}