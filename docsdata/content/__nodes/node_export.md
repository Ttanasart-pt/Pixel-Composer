Export node is one of the most important node in Pixel Composer. It allows you to export surface to different 
formats, it also allows Pixel Composer project to be run in headless mode.



## Output Format


There're 3 types of output:


<table class="ccc205030">
    <tr>
        <th><junc type/></th>
        <th>Description</th>
        <th><junc format/></th>
    </tr>
    <tr>
        <td>Single Image</td>
        <td>Export still surface to image file</td>
        <td>.png, .jpg, .webp</td>
    </tr>
    <tr>
        <td>Image Sequence</td>
        <td>Export the entire animation into series of still images</td>
        <td>.png, .jpg, .webp</td>
    </tr>
    <tr>
        <td>Animation</td>
        <td>Export the animation into a animation file</td>
        <td>.gif, .apng, .mp4, .webm</td>
    </tr>
</table>



## Export Path


The exported file location is control by <junc paths/>. However, you can add extra formatting using <junc template/>.


### Export Template


<junc template/> is used with a defined <junc paths/>. Template will replace special token with the actual value in 
the <junc paths/>.

The available tokens are:


<table class="cc4060">
    <tr>
        <th>Token</th>
        <th>Description</th>
    </tr>
    <tr>
        <td><span style="color: #88ffe9">%d</span></td>
        <td>Path directory, the folder where the path is located</td>
    </tr>
    <tr>
        <td><span style="color: #88ffe9">%{number}d</span></td>
        <td>Getting the parent folder, the {number} control how many parent to go up</td>
    </tr>
    <tr>
        <td><span style="color: #8fde5d">%n</span></td>
        <td>File name</td>
    </tr>
    <tr>
        <td><span style="color: #eb00b7">%f</span></td>
        <td>Frame number, use with image sequence export</td>
    </tr>
    <tr>
        <td><span style="color: #eb00b7">%{number}f</span></td>
        <td>Frame number, with zero padding to 2 digits</td>
    </tr>
    <tr>
        <td><span style="color: #ffe478">%i</span></td>
        <td>Array index, use when exporting surface array</td>
    </tr>
</table>


For example, if the <junc paths/> is set to <span class="inline-code">foo/bar/file.png</span> then these templates will returns:


<table class="cc4060">
    <tr>
        <th>Template</th>
        <th>Result</th>
    </tr>
    <tr>
        <td><span style="color: #88ffe9">%d</span><span style="color: #8fde5d">%n</span></td>
        <td>foo/bar/file</td>
    </tr>
    <tr>
        <td><span style="color: #88ffe9">%1d</span>name</td>
        <td>foo/name</td>
    </tr>
</table>


Note that the extension will be remove and re-added automatically based on the selecting <junc format/>.



## Format Properties


### .png


.png format comes with extra <junc subformat/> for file optimization.


<table class="ccc205030">
    <tr>
        <th><junc subformat/></th>
        <th>Description</th>
    </tr>
    <tr>
        <td>PNG32</td>
        <td>Default 32 bit PNG format</td>
    </tr>
    <tr>
        <td>INDEX4</td>
        <td>4 bit indexed PNG format</td>
    </tr>
    <tr>
        <td>INDEX8</td>
        <td>8 bit indexed PNG format</td>
    </tr>
</table>


### .jpg


.jpg format comes with <junc quality/>, the lower the quality, the smaller the file size.


### .gif


.gif comes with <junc Frame optimization/> for reducing file size and <junc Color merge/> that combine similiar into one for even smaller 
file.


### .mp4


.mp4 file has <junc quality/> (crf value) slider for controlling quality of the output. The higher the CRF value, the lower the quality.



## Animation Properties


For animation type, there're extra properties for controlling the animation.


<table class="cc4060">
    <tr>
        <th>Property</th>
        <th>Description</th>
    </tr>
    <tr>
        <td><junc framerate/></td>
        <td>The speed of the animation</td>
    </tr>
    <tr>
        <td><junc frame step/></td>
        <td>Export one frame every n frames step</td>
    </tr>
    <tr>
        <td><junc frame range/></td>
        <td>Range of the animation to export</td>
    </tr>
    <tr>
        <td><junc loop/></td>
        <td>Loop the animation</td>
    </tr>
</table>