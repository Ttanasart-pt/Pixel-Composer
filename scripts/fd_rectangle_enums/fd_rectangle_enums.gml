function fd_rectangle_enums() {
	// This script is not meant to be called.

	enum FD_TARGET_TYPE {
	    REPLACE_MATERIAL,
	    REPLACE_MATERIAL_ADVANCED,
	    ADD_MATERIAL,
	    REPLACE_VELOCITY,
	    ADD_VELOCITY
	}

	enum FD_MATERIAL_TYPE {
	    RGBA_16,
	    RGBA_8,
	    A_16,
	    A_8
	}

	enum FD_VISUALIZATION_SHADER {
	    NO_SHADER = -1,
	    DEBUG_VELOCITY = -2,
	    DEBUG_VELOCITY_DIVERGENCE = -3,
	    DEBUG_PRESSURE = -4,
	    PIXEL_ART_FIRE = -5,
	    COLORIZE = -6,
	    PIXEL_ART_FIERY_SMOKE = -7,
	    THICK_SMOKE = -8
	}


}
