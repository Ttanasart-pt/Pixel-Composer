<script src="https://polyfill.io/v3/polyfill.min.js?features=es6"></script>
<script id="MathJax-script" async src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"></script>
Fourier transformation is a process that convert series of data from time domain to frequency domain.

## Data Domain

The domain describe what the x-axis represent. Array of audio data is by default in the time domain, which means 
each number describe the amplitude of the audio at a specific time.
After the Fourier transformation, the 
data is converted to frequency domain, the value now represent the amplitude of the audio at a specific frequency.

<img fft_data_domain>

## Fourier Transform

Fourier transform is a function that takes series of data in time domain and converting it to frequency domain. 
The formula for Fourier transform is:

$$X(f) = \int_{-\infty}^{\infty} x(t) \cdot e^{-i2\pi ft} dt$$

This may look intimidating, and it's kinda is. If you want an intuitive description please watch 3Blue1Brown 
video on Fourier transform here:

<iframe width="560" height="315" src="https://www.youtube.com/embed/spUNpyF58BY?si=Y_qlMK1d9C6w9kXH" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>

FFT node used an optimized version for discrete fourier Transform calls fast fourier transform. Again 
I'd recommend a video by Reducible on FFT which explains it way better that I could ever have done here:

<iframe width="560" height="315" src="https://www.youtube.com/embed/h7apO7q16V0?si=hFHdyEtwu8exVRT8" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>