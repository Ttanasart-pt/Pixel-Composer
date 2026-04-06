<v 1.18.0/>
A function generator that generate easing functions, a function that smoothly transition from zero to one.

A function generator nodes precalculate the value for the entire animation and plot it as a curve. This allow for easy data visualization and manipulation.

## Properties

### <junc range>
Range of the animation (as a fraction of the total duration). If set to [0, 1] then the easing function will be evaluated from the first frame to the last frame.

### <junc amount>
The length of the easing function. The larger the value the slower the transition.

### <junc smooth>
The equation used to generate the easing function. The following equations are available:

- Cubic polynomial
- Quadratic polynomial
- Cubic rational
- Cosine