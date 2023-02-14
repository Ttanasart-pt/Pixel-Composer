/// fd_rectangle_set_pressure_iteration_type(instance id, iteration type)
function fd_rectangle_set_pressure_iteration_type(domain, iteration) {
	// Sets the type of iteration to use for solving the pressure in the fluid dynamics simulation. This is the most intensive part of the fluid dynamics
	// simulation and should therefore be the first thing to address whenever you want to optimize or enhance detail.
	// instance id: The instance id of the fluid dynamics rectangle.
	// iteration type: The recommended type of iteration is SRJ iteration. This can selected by setting the iteration type to a negative value.
	//     There are 4 types of SRJ iteration. The higher the iteration count, the higher the detail, but it's much more intensive:
	//     -1 for 16 iterations. -2 for 31 iterations. -3 for 64 iterations. -4 for 131 iterations.
	//     If you instead of a negative value use a positive one, traditional jacobi iteration will be used, where the number you input equals the number
	//     of jacboi iterations that will be performed. So a value of 100 will use 100 jacobi iterations, while a value of 50 will use 50 jacobi iterations.
	//     SRJ iteration is recommended as it's much more efficient, but in case you want to use traditional jacobi iteration, you usually want a value above 30.

	with (domain) {
	    pressure_iteration_type = iteration;
	    if (iteration < 0) {
	        pressure_relaxation_parameter = 0;
	        var i = 0, j = 0;
	        switch (iteration) {
	            case -1:
	                for (j = 0; j < 1; ++j) {if (j == 0) pressure_relaxation_parameter[i] = 32.6; else pressure_relaxation_parameter[i] = -1; ++i;}
	                for (j = 0; j < 15; ++j) {if (j == 0) pressure_relaxation_parameter[i] = 0.8630; else pressure_relaxation_parameter[i] = -1; ++i;}
	                break;
                
	            case -2:
	                for (j = 0; j < 1; ++j) {if (j == 0) pressure_relaxation_parameter[i] = 81.22; else pressure_relaxation_parameter[i] = -1; ++i;}
	                for (j = 0; j < 30; ++j) {if (j == 0) pressure_relaxation_parameter[i] = 0.9178; else pressure_relaxation_parameter[i] = -1; ++i;}
	                break;
                
	            case -3:
	                for (j = 0; j < 1; ++j) {if (j == 0) pressure_relaxation_parameter[i] = 190.2; else pressure_relaxation_parameter[i] = -1; ++i;}
	                for (j = 0; j < 63; ++j) {if (j == 0) pressure_relaxation_parameter[i] = 0.9532; else pressure_relaxation_parameter[i] = -1; ++i;}
	                break;
                
	            case -4:
	                for (j = 0; j < 1; ++j) {if (j == 0) pressure_relaxation_parameter[i] = 425.8; else pressure_relaxation_parameter[i] = -1; ++i;}
	                for (j = 0; j < 130; ++j) {if (j == 0) pressure_relaxation_parameter[i] = 0.9742; else pressure_relaxation_parameter[i] = -1; ++i;}
	                break;
	        }
	    }
	}



}
