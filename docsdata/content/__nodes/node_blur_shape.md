Blur shape node blur image using shape map. For each pixel, it place the shape map in the middle and calculate 
weighted convolution of the shape map and the pixel. The result is then used as the final pixel color.


<img blur_shape>



## Properties


### <junc mode/>


Blur mode, there're 2 modes available: blur and maximum.


<ul>
    <li><span class="bold">Blur</span> calculate weighted average of the convolution.</li>
    <li><span class="bold">Maximum</span> find brightness pixel in the convolution.</li>
</ul>


### <junc blur shape/>


Shape map to be used for blurring.


### <junc blur mask/>


Extra surface use for scaling blur effect.

