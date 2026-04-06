Interpret Number convert array of numbers into surface by map the value into a range. 

This node can be useful 
for creating animation by animating the number array instead of the surface itself.


<img interpret_number/>



## Properties


### <junc number/>


The array of number to interpret.


### <junc mode/>


Select intepretation modes:


<ul>
    <li><span class="inline-code">Greyscale</span>: Interpret value into greyscale color by mapping to the 
<junc range/> scale.</li>
    <li><span class="inline-code">Gradient</span>: Takes the value from the range mapping and use it to sample 
color from the <junc gradient/>.</li>
</ul>


### <junc range/>


The range to map the value in. <span class="inline-code">Min</span> value will correspond to 0 and <span
class="inline-code">Max</span> value will correspond to 1.


### <junc gradient/>


The gradient to map to if use the <span class="inline-code">Gradient</span> mode.


