function Node_GrainSim_Domain(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Domain";
	color = COLORS.node_blend_grain;
	icon  = THEME.grain_sim;
	setDrawIcon();
	setDimension(96, 48);
	
	manual_ungroupable = false;
	update_on_frame    = true;
	
	////- =Domain
	newInput( 0, nodeValue_Int(    "Size",     1  )).setUnitSimple();
	newInput( 2, nodeValue_Float(  "Gravity",  10 ));
	newInput( 9, nodeValue_Toggle( "Wall",  0b1111, [ "T", "B", "L", "R" ] ));
	
	////- =Grain
	newInput( 3, nodeValue_Float(  "Mass",         1, [1,2,.01] ));
	newInput( 4, nodeValue_Slider( "Volume",       1, [1,2,.01] ));
	newInput( 5, nodeValue_Float(  "Hardening",   10 ));
	newInput( 6, nodeValue_Float(  "Granular",     1 ));
	
	////- =Simulation
	newInput( 1, nodeValue_Float(  "Timestep",         1     ));
	newInput( 7, nodeValue_Bool(   "Sleepable",        false ));
	newInput( 8, nodeValue_Float(  "Sleep Threshold", .01    ));
	
	newInput(10, nodeValue_Float(  "Stiffness (K)",    10   ));
	newInput(11, nodeValue_Slider( "Poisson",         .20   ));
	// 12
	
	newOutput( 0, nodeValue_Output("Domain", VALUE_TYPE.struct, {} )).setCustomData(global.GRAINSIM_JUNC);
	
	input_display_list = [
		[ "Domain",     false ],  0,  2,  9, 
		[ "Grain",      false ],  3,  4,  5,  6,  
		[ "Simulation", false ],  1,  7,  8, -2, 10, 11, 
	];
	
	////- Node
	
	dIndex = undefined;
	domain = new GrainSim_Domain();
	
	static update = function(frame = CURRENT_FRAME) {
		#region data
			var _size = inputs[ 0].getValue();
			var _grav = inputs[ 2].getValue();
			var _wall = inputs[ 9].getValue();
			
			var _mass = inputs[ 3].getValue();
			var _volu = inputs[ 4].getValue();
			var _hard = inputs[ 5].getValue();
			var _gran = inputs[ 6].getValue();
			
			var _time = inputs[ 1].getValue();
			var _slep = inputs[ 7].getValue();
			var _slth = inputs[ 8].getValue();
			
			var _stff = inputs[10].getValue();
			var _pois = inputs[11].getValue();
		#endregion
		
		if(IS_FIRST_FRAME || dIndex == undefined) {
			if(dIndex != undefined)
				grainSim_destroy(dIndex);
				
			dIndex = grainSim_init(_size);
		}
		
		grainSim_refresh(dIndex);
		
		domain.index = dIndex;
		domain.size  = _size;
		
		var res = grainSim_setGravity(   dIndex, _grav * -100 );
		var res = grainSim_setWall(      dIndex, _wall        );
		var res = grainSim_setStiffness( dIndex, _stff * 1000, _pois );
		
		var res = grainSim_setPartMass(  dIndex, _mass        );
		var res = grainSim_setVol(       dIndex, _volu        );
		var res = grainSim_setHardening( dIndex, _hard        );
		var res = grainSim_setGranular(  dIndex, _gran        );
		
		var res = grainSim_setTimestep(  dIndex, _time        );
		var res = grainSim_setSleep(     dIndex, _slep, _slth );
		
		outputs[0].setValue(domain);
	}

}