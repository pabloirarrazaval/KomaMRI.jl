# Simulation Examples

These examples are designed so you can go along by copying and pasting the code blocks 😃. Before starting, don't forget to include the `KomaMRI` package:
```julia
using KomaMRI # Copy me by clicking the icon at the right! ------>
```

## Free Induction Decay

```@setup 1
using KomaMRI # Copy me by clicking the icon at the right! ------>
```

The free induction decay is the simplest observable NMR signal. This signal is the one that follows a single tipping RF pulse. To recreate this experiment, we will need to define a `Sequence` with 2 blocks. 

The first block containing an RF pulse with a flip-angle of 90 deg, 
```@example 1
ampRF = 2e-6                        # 2 uT RF amplitude
durRF = π / 2 / (2π * γ * ampRF)    # required duration for a 90 deg RF pulse
exc = RF(ampRF,durRF)
nothing # hide
```
and the second block containing the ADC.
```@example 1
nADC = 8192         # number of acquisition samples
durADC = 250e-3     # duration of the acquisition
delay =  1e-3       # small delay
acq = ADC(nADC, durADC, delay)
nothing # hide
```

Finally, we concatenate the sequence blocks to create the final sequence (for more info. refer to [Sequence Structure](useful-information.md#Sequence-Structure)).
```@example 1
seq = Sequence()  # empty sequence
seq += exc        # adding RF-only block
seq += acq        # adding ADC-only block
p = plot_seq(seq; slider=false, height=300)
savefig(p, "assets/1-seq.html") # hide
nothing # hide
```
```@raw html
<object type="text/html" data="../assets/1-seq.html" style="width:100%; height:320px;"></object>
```

Now, we will define a `Phantom` with a single spin at $x=0$ with $T_1=1000\,\mathrm{ms}$ and $T_2=100\,\mathrm{ms}$.
```@example 1
obj = Phantom{Float64}(x=[0.], T1=[1000e-3], T2=[100e-3])
nothing # hide
```

Finally, to simulate we will need to use the function [simulate](@ref).
```@example 1
sys = Scanner() # default hardware definition
raw = simulate(obj, seq, sys)
```

To plot the results we will need to use the [plot_signal](@ref) function 
```@example 1
p = plot_signal(raw; slider=false, height=300)
savefig(p, "assets/1-signal.html"); nothing # hide
```
```@raw html
<object type="text/html" data="../assets/1-signal.html" style="width:100%; height:320px;"></object>
```
Nice!, we can see that $S(t)$ follows an exponential decay $\exp(-t/T_2)$ as expected.

For a little bit of spiciness, let's add **off-resonance** to our example. We will use $\Delta f=-100\,\mathrm{Hz}$. For this, we will need to add a definition for `Δw` in our `Phantom`
```@example 1
obj = Phantom{Float64}(x=[0.], T1=[1000e-3], T2=[100e-3], Δw=[-2π*100])
nothing # hide
```

and simulate again.
```@setup 1
raw = simulate(obj, seq, sys)
p = plot_signal(raw; slider=false, height=300)
savefig(p, "assets/1-signal2.html"); nothing # hide
```
```julia
raw = simulate(obj, seq, sys)
p = plot_signal(raw; slider=false, height=300)
```
```@raw html
<object type="text/html" data="../assets/1-signal2.html" style="width:100%; height:320px;"></object>
```
The signal now follows an exponential of the form $\exp(-t/T_2)\cdot\exp(-i\Delta\omega t)$. The addition of $\exp(-i\Delta\omega t)$ to the signal will generate a shift in the image space (Fourier shifting property). This effect will be better visualized and explained in later examples.


## Chemical Shift in an EPI sequence

```@setup 2
using KomaMRI
sys = Scanner()
```

For a more realistic example, we will use a brain phantom. 
```@example 2
obj = brain_phantom2D() # a slice of a brain
p1 = plot_phantom_map(obj, :T2 ; height=400)
p2 = plot_phantom_map(obj, :Δw ; height=400)
savefig(p1, "assets/2-phantom1.html"); nothing # hide
savefig(p2, "assets/2-phantom2.html"); nothing # hide
```

At the left, you can see the $T_2$ map of the phantom, and at the right, the off-resonance $\Delta\omega$. In this example, the fat is the only source of off-resonance (with $\Delta f =  -220\,\mathrm{Hz}$) and you can see it in black in the off-resonance map.
```@raw html
<object type="text/html" data="../assets/2-phantom1.html" style="width:50%; height:420px;"></object><object type="text/html" data="../assets/2-phantom2.html" style="width:50%; height:420px;"></object>
```

Then, we will load an EPI sequence, that is well known for being affected by off-resonance. With this sequence, we will be able visualize the effect of the chemical shift.
```@setup 2
seq = read_seq("../../examples/3.koma_paper/comparison_jemris/sequences/EPI/epi_100x100_TE100_FOV230.seq")
p = plot_seq(seq; range=[0 40], slider=true, height=300)
savefig(p, "assets/2-seq.html");
```
```julia
seq = read_seq("examples/3.koma_paper/comparison/sequences/EPI/epi_100x100_TE100_FOV230.seq")
p = plot_seq(seq; range=[0 40], slider=true, height=300)
```

Feel free to explore the sequence's plot 🔍 below!
```@raw html
<object type="text/html" data="../assets/2-seq.html" style="width:100%; height:320px;"></object>
```

If we simulate this sequence we will end up with the following signal.
```@example 2
raw = simulate(obj, seq, sys)
p = plot_signal(raw; range=[98.4 103.4] , height=300)
savefig(p, "assets/2-signal.html"); #nothing
```
```@raw html
<object type="text/html" data="../assets/2-signal.html" style="width:100%; height:320px;"></object>
```

Now, we need to inspect what effect the off-resonance had in the reconstructed image. As you can see, the fat layer is now shifted to a different position 🤯, this is why the effect is called chemical shift!
```@example 2
# Get the acquisition data
acq = AcquisitionData(raw)
acq.traj[1].circular = false #This is to remove a circular mask

# Setting up the reconstruction parameters
Nx, Ny = raw.params["reconSize"][1:2]
reconParams = Dict{Symbol,Any}(:reco=>"direct", :reconSize=>(Nx, Ny))
image = reconstruction(acq, reconParams)

# Plotting the recon
slice_abs = abs.(image[:, :, 1])
p = plot_image(slice_abs; height=400)
savefig(p, "assets/2-recon.html");  nothing # hide
```
```@raw html
<center>
<object type="text/html" data="../assets/2-recon.html" style="width:65%; height:420px;"></object>
</center>
```


## Slice Selective Acquisition of 3D Phantom

```@setup 3
using KomaMRI
sys = Scanner()
```

While in the previous examples we simulated using hard RF pulses, in this demonstration we will illustrate the principles of slice selection. First, let's import a 3D phantom, in this case a brain slab (thickness of $2\,\mathrm{cm}$), by calling the function [brain_phantom3D](@ref). 
```@example 3
obj = brain_phantom3D()
obj.Δw .= 0 # Removes the off-resonance
p = plot_phantom_map(obj, :T2 ; height=400)
savefig(p, "assets/3-phantom.html"); nothing # hide
```
```@raw html
<center>
<object type="text/html" data="../assets/3-phantom.html" style="width:50%; height:420px;"></object>
</center>
```

Now, we are going to import a sequence which acquires 3 slices in the longitudinal axis. Note that the sequence contains three EPIs to acquire 3 slices of the phantom.
```@setup 3
seq = read_seq("../../examples/1.sequences/epi_multislice.seq")
p = plot_seq(seq; range=[0,10], height=400)
savefig(p, "assets/3-seq.html"); 
```
```@raw html
<object type="text/html" data="../assets/3-seq.html" style="width:100%; height:420px;"></object>
```
We can take a look to the slice profiles by using the function [simulate_slice_profile](@ref):
```@example 3
z = range(-2., 2., 200) * 1e-2; # -2 to 2 cm
rf1, rf2, rf3 = findall(KomaMRI.is_RF_on.(seq))
M1 = simulate_slice_profile(seq[rf1]; z)
M2 = simulate_slice_profile(seq[rf2]; z)
M3 = simulate_slice_profile(seq[rf3]; z)
```
```@setup 3
using PlotlyJS
p1 = scatter(x=z*1e2, y=abs.(M1.xy), name="Slice 1") # hide
p2 = scatter(x=z*1e2, y=abs.(M2.xy), name="Slice 2")
p3 = scatter(x=z*1e2, y=abs.(M3.xy), name="Slice 3")
p = plot([p1,p2,p3], Layout(xaxis=attr(title="z [cm]"), height=300,margin=attr(t=40,l=0,r=0), title="Slice profiles for the slice-selective sequence"))
savefig(p, "assets/3-profile.html"); nothing # hide
```
```@raw html
<object type="text/html" data="../assets/3-profile.html" style="width:100%; height:320px;"></object>
```

Now let's simulate the acquisition. Notice the three echoes, one for every slice excitation.
```@setup 3
raw = simulate(obj, seq, sys; simParams=Dict{String,Any}("Nblocks"=>20))
p = plot_signal(raw; slider=false, height=300)
savefig(p, "assets/3-signal.html"); nothing # hide
```
```julia
raw = simulate(obj, seq, sys)
p = plot_signal(raw; slider=false, height=300)
```
```@raw html
<object type="text/html" data="../assets/3-signal.html" style="width:100%; height:320px;"></object>
```

Finally, we reconstruct the acquiered images.
```@example 3
# Get the acquisition data
acq = AcquisitionData(raw)

# Setting up the reconstruction parameters and perform reconstruction
Nx, Ny = raw.params["reconSize"][1:2]
reconParams = Dict{Symbol,Any}(:reco=>"direct", :reconSize=>(Nx, Ny))
image = reconstruction(acq, reconParams)

# Plotting the slices
p1 = plot_image(abs.(image[:, :, 1]); height=360, title="slice 1")
p2 = plot_image(abs.(image[:, :, 2]); height=360, title="slice 2")
p3 = plot_image(abs.(image[:, :, 3]); height=360, title="slice 3")
savefig(p1, "assets/3-recon1.html");  nothing # hide
savefig(p2, "assets/3-recon2.html");  nothing # hide
savefig(p3, "assets/3-recon3.html");  nothing # hide
```
```@raw html
<object type="text/html" data="../assets/3-recon1.html" style="width:50%; height:380px;"></object><object type="text/html" data="../assets/3-recon2.html" style="width:50%; height:380px;"></object>
```
```@raw html
<center>
<object type="text/html" data="../assets/3-recon3.html" style="width:50%; height:380px;"></object>
</center>
```