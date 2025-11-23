function Node_FLIP_Domain(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Domain";
	color = COLORS.node_blend_fluid;
	icon  = THEME.fluid_sim;
	setDrawIcon(s_node_flip_domain);
	
	manual_ungroupable = false;
	update_on_frame    = true;
	
	newInput(0, nodeValue_Dimension());
	
	newInput(1, nodeValue_Int("Particle Size", 1));
	
	newInput(2, nodeValue_Int("Particle Density", 10));
	
	newInput(3, nodeValue_Slider("FLIP Ratio", 0.8));
	
	newInput(4, nodeValue_Float("Resolve accelerator", 1.5));
	
	newInput(5, nodeValue_Int("Iteration", 8));
	
	newInput(6, nodeValue_Slider("Damping", 0.8));
	
	newInput(7, nodeValue_Float("Gravity", 5));
	
	newInput(8, nodeValue_Float("Time Step", 0.05));
	
	newInput(9, nodeValue_Toggle("Wall", 0b1111, { data:  [ "T", "B", "L", "R" ] }));
	
	newInput(10, nodeValue_Slider("Viscosity", 0., [ -1, 1, 0.01 ] ));
	
	newInput(11, nodeValue_Slider("Friction", 0.));
		
	newInput(12, nodeValue_Slider("Wall Elasticity", 0., [ 0, 2, 0.01 ] ));
	
	newInput(13, nodeValue_Rotation("Gravity Direction", -90));
	
	input_display_list = [
		["Domain",	false], 0, 1, 9, 12, 
		["Solver",   true], 3, 8, 
		["Physics", false], 7, 13, 10, 11, 
	]
	
	newOutput(0, nodeValue_Output("Domain", VALUE_TYPE.fdomain, noone));
	
	#region attributes
		attributes.max_particles       = 10000;
		attributes.iteration           = 8;
		attributes.iteration_pressure  = 2;
		attributes.iteration_particle  = 2;
		attributes.overrelax           = 1.5;
		attributes.skip_incompressible = false;

		array_push(attributeEditors, "FLIP Solver");
		array_push(attributeEditors, ["Maximum particles",   function() /*=>*/ {return attributes.max_particles},      textBox_Number(function(v) /*=>*/ {return setAttribute("max_particles", v)})            ]);
		array_push(attributeEditors, ["Global iteration",    function() /*=>*/ {return attributes.iteration},          textBox_Number(function(v) /*=>*/ {return setAttribute("iteration", v, true)})          ]);
		array_push(attributeEditors, ["Pressure iteration",  function() /*=>*/ {return attributes.iteration_pressure}, textBox_Number(function(v) /*=>*/ {return setAttribute("iteration_pressure", v, true)}) ]);
		array_push(attributeEditors, ["Particle iteration",  function() /*=>*/ {return attributes.iteration_particle}, textBox_Number(function(v) /*=>*/ {return setAttribute("iteration_particle", v, true)}) ]);
		array_push(attributeEditors, ["Overrelaxation",      function() /*=>*/ {return attributes.overrelax},          textBox_Number(function(v) /*=>*/ {return setAttribute("overrelax", v, true)})          ]);
		array_push(attributeEditors, ["Skip incompressible", function() /*=>*/ {return attributes.skip_incompressible}, new checkBox(function() /*=>*/ {return toggleAttribute("skip_incompressible", true)})  ]);
	#endregion
	
	domain  = instance_create(0, 0, FLIP_Domain);
	toReset = true;
	
	static step = function() {
		var _col = getInputData(9);
		
		inputs[12].setVisible(_col);
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
		
		outputs[0].setValue(domain);
	}
	
	static getPreviewValues = function() { return domain.domain_preview; }
	
}