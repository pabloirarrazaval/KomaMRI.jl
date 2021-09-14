# MRIsim.jl

<p align="center">
<img width="250px" src="./docs/src/assets/logo.png"/>
</p>

![Build status](https://github.com/cncastillo/MRIsim.jl/actions/workflows/ci.yml/badge.svg)
[![Docs](https://img.shields.io/badge/docs-dev-blue.svg)](https://cncastillo.github.io/MRIsim.jl/)

MRIsim.jl is a Julia package to simulate Magnetic Resonance Imaging (MRI) acquisitions. The main focus of this package is to simulate general scenarios that could arise in pulse sequence development. 

**TO-DO**:
 - [x] Phantom and Sequence data-types,
 - [x] Spin preccesion in gradient-only blocks,
 - [x] GPU accelaration using CUDA.jl,
 - [x] RF excitation,
 - [ ] GPU accelaration of RF excitation (under development),
 - [ ] [Pulseq](https://github.com/imr-framework/pypulseq) IO and auxiliary functions,
 - [ ] Signal "Raw Output" dictionary ([ISMRMRD](https://ismrmrd.github.io/)),
 - [ ] [MRIReco.jl](https://magneticresonanceimaging.github.io/MRIReco.jl/latest/) for the reconstruciton,
 - [ ] Scanner data-type: <img src="https://latex.codecogs.com/gif.latex?B_0,\,B_1,\,G_{\max},\,S_{\max}">, etc.,
 - [ ] Diffusion models with Laplacian Eigen Functions,
 - [ ] Magnetic susceptibility,
 - [ ] Coil sensitivities,
 - [ ] Documentation.


**ISMRM 2020 Presentation**: [MRIsim - Carlos Castillo.pdf](others/MRIsim-CarlosCastillo.pdf)

## Installation
To install just do the following:

```julia
] add MRIsim
```
## First run
MRIsim.jl comes with a handy GUI that contains a brain phantom with an EPI sequence. To open it use:

```julia
SpinLab()
```
Then, press the button that says "Run simulation!" to do your first simulatation :).

---

## SpinLab GUI

![SpinLab](others/GUI.png)

---

## Example 1: Brain phantom for different TEs

![Brain phantom with different TEs](others/TEs.png)

## Example 2: dMRI with multiple diffusion directions  

<img src="others/propagator.gif" width="80%">

## Example 3: Moment-compensated diffusion

<img src="others/MomentCompensation.gif" width="80%">
