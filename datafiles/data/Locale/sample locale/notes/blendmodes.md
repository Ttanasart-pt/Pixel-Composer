This is a list of equation associated to each blend mode.

## Symbols

{g}
<x20> [B]     <x80> Background color
<x20> [F]     <x80> Foreground color
<x20> [R]     <x80> Result color

<x20> [Brgba] <x80> Background red, green, blue, alpha components
<x20> [Bhsl]  <x80> Background hue, saturation, luminosity components
{g}

## Equations
### Normal
{g}
<x20> [Normal*]      <x128> `R = F * Fa + B * (1 - Fa)`
<x20> [Replace]      <x128> `R = F * Fa + B * (1 - Fa)`
{g}

### Darken
{g}
<x20> [Multiply]     <x128> `R = F * B`
<x20> [Color Burn]   <x128> `R = 1 - (1 - B) / F`
<x20> [Linear Burn]  <x128> `R = B + F - 1`
<x20> [Minimum]      <x128> `R = min(F, B)`
{g}

### Lighten
{g}
<x20> [Add]          <x128> `R = F + B`
<x20> [Screen]       <x128> `R = 1 - (1 - F) * (1 - B)`
<x20> [Color Dodge]  <x128> `R = F / (1 - B)`
<x20> [Maximum]      <x128> `R = max(F, B)`
{g}

### Contrast
{g}
<x20> [Overlay]      <x128> `R =` <x152> `Fl < 0.5: 2 * F * B`
                                  <x152> `Fl > 0.5: 1 - 2 * (1 - F) * (1 - B)`
<x20> [Soft Light]   <x128> `R =` <x152> `Fl < 0.5: B * (F + 0.5)`
                                  <x152> `Fl > 0.5: 1 - (1 - B) * (1 - (F - 0.5))`
<x20> [Hard Light]   <x128> `R =` <x152> `Fl < 0.5: 2 * F * B`
                                  <x152> `Fl > 0.5: 1 - 2 * (1 - F) * (1 - B)`
<x20> [Vivid Light]  <x128> `R =` <x152> `Fl < 0.5: B / (1 - 2 * F)`
                                  <x152> `Fl > 0.5: 1 - (1 - B) / (2 * F - 1)`
<x20> [Linear Light] <x128> `R =` <x152> `B + 2 * F - 1`
<x20> [Pin Light]    <x128> `R =` <x152> `Fl < 0.5: min(B, 2 * F)`
                                  <x152> `Fl > 0.5: max(B, 2 * F - 1)`
{g}

### Inversion
{g}
<x20> [Difference]   <x128> `R = |F - B|`
<x20> [Exclusion]    <x128> `R = F + B - 2 * F * B`
<x20> [Subtract]     <x128> `R = F - B`
<x20> [Divide]       <x128> `R = F / B`
{g}

### HSL
{g}
<x20> [Hue]          <x128> `Rh = Fh`
<x20> [Saturation]   <x128> `Rs = Fs`
<x20> [Luminosity]   <x128> `Rl = Fl`
{g}

## Alpha Compensation
Blend modes with asterick [*] means they use alpha compensation to avoid premultiplied alpha (e.g. 50% transparent white turns to 50% grey.)

This process will apply after the blend equation.

{g}
<x20> `Ra = Fa * Fb + Ba * (1 - Fa) * (1 - Fb)`
<x20> `Rrgb = Rrgb / Ra`
{g}