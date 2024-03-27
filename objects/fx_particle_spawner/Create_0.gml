/// @description Insert description here
randomize();
parts  = array_create_ext(8, function(i) { return [ x + random_range(-radius, radius), y + random_range(-radius, radius) ]; });
speeds = array_create_ext(8, function(i) { return [ random_range(-8, 8), random_range(-8, 0) ]; });
life   = 20;
size   = 2;

seed   = seed_random();
depth  = -19999;