	#define EPSILON 1e-5
	
	uniform int   MAX_MARCHING_STEPS;

	uniform int   ortho;
	uniform float fov;
	uniform float orthoScale;
	uniform vec2  viewRange;

	uniform vec2  depthRange;
	uniform float depthInt;

	uniform vec4  background;
	uniform float ambientIntns;

	uniform int   useLight;
	uniform vec3  lightPosition;
	uniform float lightInten;
	uniform vec4  lightColor;

	uniform int   useEnv;
	uniform int   envFilter;
	uniform int   drawGrid;
	uniform float gridStep;
	uniform float gridScale;
	uniform float gridOpacity;
	uniform vec4  gridColor;
	uniform float axisBlend;

	////========= Util ==========

		vec4 viewGrid(vec2 pos, float scale) {
			vec2 coord      = pos * scale; // use the scale variable to set the distance between the lines
			vec2 derivative = fwidth(coord);
			vec2 grid       = abs(fract(coord - 0.5) - 0.5) / derivative;
			float line      = min(grid.x, grid.y);
			float minimumy  = min(derivative.y, 1.);
			float minimumx  = min(derivative.x, 1.);
			vec4 color = vec4(gridColor.rgb, 1. - min(line, 1.));
			
			// x axis
			if(pos.y > -1. * minimumy / scale && pos.y < 1. * minimumy / scale)
				color.rgb = vec3(1., 0., 0.);

			// y axis
			if(pos.x > -1. * minimumx / scale && pos.x < 1. * minimumx / scale)
				color.rgb = vec3(0., 1., 0.);
			
			color.a *= gridOpacity;
			return color;
		}
		
	////========= Ray Marching ==========

	float march(vec3 camera, vec3 direction) {
		if(shapeAmount == 0) return viewRange.y;
		float depth = viewRange.x;
		
		for (int i = 0; i < MAX_MARCHING_STEPS; i++) {
			float dist = operateSceneSDF(camera + depth * direction);
			if (dist < EPSILON) 
				return depth;
			
			depth += dist;
			if (depth >= viewRange.y)
				return viewRange.y;
		}
		
		return viewRange.y;  
	}

	float marchLinear(vec3 camera, vec3 direction) {
		float st   = 1. / float(MAX_MARCHING_STEPS);
		
		for (int i = 0; i <= MAX_MARCHING_STEPS; i++) {
			float depth = mix(viewRange.x, viewRange.y, float(i) * st);
			vec3  pos   = camera + depth * direction;
			float hit   = operateSceneSDF(pos);
			
			if (hit <= 0.)
				return depth;
		}
		
		return viewRange.y;
	}

	float marchDensity(vec3 camera, vec3 direction) {
		float maxx    = float(MAX_MARCHING_STEPS);
		float st      = 1. / maxx;
		float density = 0.;
		float dens, stp;
		
		for (float i = 0.; i <= maxx; i++) {
			float depth = mix(viewRange.x, viewRange.y, i * st);
			vec3  pos   = camera + depth * direction;
			float hit   = operateSceneSDF(pos);
			
			if (hit <= 0.) {
				dens = volumeDensity[0];
				stp  = dens == 0. ? 0. : pow(2., 10. * dens - 10.);
				
				density += stp;
			}
		}
		
		return density;
	}

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	vec4 sampleBackground(vec2 tx, vec3 camRotation, float camScale, float camRatio) {	
		if(useEnv == 0) return background;

		vec4 bg = background;
		mat3 rx = rotateX(camRotation.x);
		mat3 ry = rotateY(camRotation.y);
		mat3 rz = rotateZ(camRotation.z);
		mat3 camRotMatrix  = rx * ry * rz;
		mat3 camIrotMatrix = inverse(camRotMatrix);
		
		vec3 dir;
		vec2 cps = (tx - .5) * 2.;
		cps.x *= camRatio;
			
		if(ortho == 0) {
			float dz  = 1. / tan(radians(fov) / 2.);
			dir = vec3(cps, -dz);
			
		} else if(ortho == 1) {
			dir = vec3(0., 0., -1.);
		}
		
		dir  = normalize(camIrotMatrix * dir);
		
		vec2 envUV = equirectangularUv(dir);
		vec4 endC  = sampleTexture(0, envUV, envFilter);
		bg = endC;
		return bg;
	}

	vec4 scene(vec2 tx, vec3 camRotation, float camScale, float camRatio, vec3 objectRotation, float objectScale, out float outDepth) {
		mat3 rx = rotateX(camRotation.x);
		mat3 ry = rotateY(camRotation.y);
		mat3 rz = rotateZ(camRotation.z);

		mat3 camRotMatrix  = rx * ry * rz;
		mat3 camIrotMatrix = inverse(camRotMatrix);
		
		mat3 orx = rotateX(objectRotation.x);
		mat3 ory = rotateY(objectRotation.y);
		mat3 orz = rotateZ(objectRotation.z);

		mat3 objRotMatrix  = orx * ory * orz;
		mat3 objIrotMatrix = inverse(objRotMatrix);

		vec3 dir, eye;
		
		vec2 cps = (tx - .5) * 2.;
			 cps.x *= camRatio;
				
		if(ortho == 0) {
			float dz  = 1. / tan(radians(fov) / 2.);
				
			dir = vec3(cps, -dz);
			eye = vec3(0., 0., 5.);
			
		} else if(ortho == 1) {
				
			dir = vec3(0., 0., -1.);
			eye = vec3(cps * orthoScale, 5.);
		}
		
		dir  = camIrotMatrix * dir;
		dir  = objIrotMatrix * dir;
		dir  = normalize(dir);

		eye  = camIrotMatrix * eye;
		eye  = objIrotMatrix * eye;
		eye /= camScale * objectScale;

		if(volumetric[0] == 1) { 
			float _dens = clamp(marchDensity(eye, dir), 0., 1.);
			return diffuseColor[0] * _dens;
		}
		
		float depth = march(eye, dir);
		outDepth = depth;
		
		vec3 coll  = eye + dir * depth;
		vec3 norm  = normal(coll);
		norm = objRotMatrix * norm;

		vec4 grid  = vec4(0.);
		
		if(drawGrid == 1 && (shapeAmount == 0 || sign(eye.y) != sign(coll.y))) {
			vec3  gp = eye + dir * depth * (abs(eye.y) / (abs(coll.y) + abs(eye.y)));
			grid = viewGrid( gp.xz, gridStep );
			grid.a *= clamp(1. - length(gp.xz) * gridScale, 0., 1.) * 0.75;
		}
		
		if(shapeAmount == 0 || depth > viewRange.y - EPSILON) // Not hitting anything.
			return drawGrid == 1? grid : vec4(0.);
		
		///////////////////////////////////////////////////////////
		
		float totalInfluences = 0.;
		for(int i = 0; i < shapeAmount; i++)
			totalInfluences += influences[i];
		
		vec3  c    = vec3(0.);
		float refl = 0.;
		float spec = 0.;
		
		if(opLength > 1) {
			vec3  _shC[MAX_OP];
			float _shR[MAX_OP];
			float _shS[MAX_OP];
			
			float inf;
			int   top = 0;
			int   opr = 0;
			
			for(int i = 0; i < opLength; i++) {
				opr = operations[i];
				inf = influences[i];
				
				if(opr < 100) {
					_shC[top] = inf * getDiffuseColor(opr, coll, norm);
					_shR[top] = inf * reflective[opr];
					_shS[top] = inf * specular[opr];
					
					c     = _shC[top];
					refl  = _shR[top];
					spec  = _shS[top];
					
					top++;
					
				} else if(top >= 2) {
					top--;
					vec3  c1 = _shC[top];
					float r1 = _shR[top];
					float s1 = _shS[top];
					
					top--;
					vec3  c2 = _shC[top];
					float r2 = _shR[top];
					float s2 = _shS[top];
					
					_shC[top] = inf * (c1 + c2);
					_shR[top] = inf * (r1 + r2);
					_shS[top] = inf * (s1 + s2);
					
					c     = _shC[top];
					refl  = _shR[top];
					spec  = _shS[top];
					
					top++;
					
				} else  //error, not enough values
					break;
			}
			
		} else {
			c    = getDiffuseColor(0, coll, norm);
			refl = reflective[0];
			spec = specular[0];
		}
		
		vec3 ref   = reflect(dir, norm);
		vec3 bgClr = background.rgb;

		///////////////////////////////////////////////////////////
		
		float depthS   = objectScale * camScale;
		float distNorm = 1. - (depth * depthS - depthRange.x) / (depthRange.y - depthRange.x);
		c = mix(c * bgClr, c, mix(1., distNorm, depthInt));
		
		///////////////////////////////////////////////////////////
		
		if(useEnv == 1) {
			vec4 refC = sampleTexture(0, equirectangularUv(ref), envFilter);
			c = mix(c, c * refC.rgb, refl);
		}
		
		///////////////////////////////////////////////////////////
		
		if(useLight == 1) {
			vec3 light = normalize(lightPosition);
			float lamo = min(1., max(0., dot(norm, light)) + ambientIntns) * lightInten;
			c = mix(c * bgClr, c * lightColor.rgb, lamo);
			
			float specInt = pow(max(dot(ref, light), 0.0), 2.) * spec;
			c += vec3(specInt);
		}
		
		///////////////////////////////////////////////////////////
		
		vec4 res = vec4(c, 1.);
		
		if(drawGrid == 1 && sign(eye.y) != sign(coll.y))
			res = blend(res, grid);
		
		return res;
	}