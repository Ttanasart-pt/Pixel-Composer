function __3DVFX() constructor {
	active   = true;
	position = [ 0, 0, 0 ];
	rotation = [ 0, 0, 0 ];
	scale    = [ 0, 0, 0 ];
	
	seed = 0;
	velocity = [ 0, 0, 0 ];
	
	static reset = function(seed) {
		self.seed = seed;
		
		random_set_seed(seed);
		position[0] = random_range(-4, 4);
		position[1] = random_range(-4, 4);
		position[2] = random_range(-4, 4);
	}
	
	static step = function() {
		for( var i = 0; i < 3; i++ ) 
			position[i] += velocity[i];
	}
}