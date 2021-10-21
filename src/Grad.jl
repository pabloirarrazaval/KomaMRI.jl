"Rotates vector counter-clockwise with respecto to the x-axis."
rotx(θ::Real) = [1		0		0
				 0	cos(θ)	-sin(θ);
				 0	sin(θ)	cos(θ)]
"Rotates vector counter-clockwise with respecto to the y-axis."
roty(θ::Real) = [cos(θ) 0	sin(θ);
				 0		1		0;
				-sin(θ)	0 	cos(θ)]
"Rotates vector counter-clockwise with respecto to the z-axis."
rotz(θ::Real) = [cos(θ) -sin(θ)	0;
				 sin(θ) cos(θ)	0;
				 0 		0 		1]
#####################
## Gradient OBJECT ##
#####################
# @everywhere begin
"""
    Grad(A,T)

Square gradient object.

# Arguments
- `A::Real` := Gradient amplitude [T].
- `T::Real` := Gradient duration [s].

# Examples
```julia-repl
julia> Grad(1,1)
Grad(1, 1)
```
"""
mutable struct Grad
	A::Real #Amplitud [T]
	T::Real #Duration of sequence [s]
    function Grad(A,T)
		T < 0 ? error("Gradient duration must be positive.") : new(A, T)
    end 
end
#Gradient operations
*(x::Grad,α::Real) = Grad(α*x.A,x.T)
*(α::Real,x::Grad) = Grad(α*x.A,x.T)
*(A::Matrix{Float64},GR::Matrix{Grad}) = begin
	N, M = size(GR)
	[sum(A[i,1:N] .* GR[:,j]) for i=1:N, j=1:M]
end
import Base.zero
zero(::Grad) = Grad(0,0)
/(x::Grad,α::Real) = Grad(x.A/α,x.T)
+(x::Grad,y::Grad) = Grad(x.A+y.A,max(x.T,y.T))
+(x::Array{Grad,1}, y::Array{Grad,1}) = [x[i]+y[i] for i=1:length(x)]
-(x::Grad) = -1*x
-(x::Grad,y::Grad) = Grad(x.A-y.A,max(x.T,y.T))
#Gradient functions
vcat(x::Array{Grad,1},y::Array{Grad,1}) = [i==1 ? x[j] : y[j] for i=1:2,j=1:length(x)]
vcat(x::Array{Grad,1},y::Array{Grad,1},z::Array{Grad,1}) = [i==1 ? x[j] : i==2 ? y[j] : z[j] for i=1:3,j=1:length(x)]
getproperty(x::Vector{Grad}, f::Symbol) = getproperty.(x,f)
getproperty(x::Matrix{Grad}, f::Symbol) = begin
	if f == :x
		x[1,:].A
	elseif f == :y
		x[2,:].A
	elseif f == :z && size(x,1) == 3
		x[3,:].A
	elseif f == :T
		x[1,:].T
	elseif f == :A
		getproperty.(x,:A)
	end
end

"""
	delay(T)

Auxiliary function, creates Grad object of duration `T` [s] and strength 0 [T].
"""
delay(T::Real) = Grad(0,T)
"""
	Grad_fun(f,T,N)

Generates **arbitrary gradient waveform** defined by function `f` in the interval t∈[0,`T`].
It uses `N` square gradients uniformly spaced in the interval.

# Arguments
 - `f::Function` := Gradient waveform.
 - `T::Real`     := Gradient duration.
 - `N::Integer=1`:= Number of sample points.

# Examples
```julia-repl
julia> Grad_fun(x-> sin(π*x),1,4)
1×4 Array{Grad,2}:
 Grad(0.0, 0.333333)  Grad(0.866025, 0.333333)  Grad(0.866025, 0.333333)  Grad(1.22465e-16, 0.333333)
```
"""
Grad(f::Function,T::Real,N::Int64=300) = begin
	Grads = [Grad(f(t),T/N) for t = range(0,stop=T,length=N)]
	reshape(Grads,(1,N))
end

Grad(A::Vector, T::Real) = begin
	N = length(A)
	Δt = T/N
	Grads = [Grad(A[i],Δt) for i = 1:N]
	reshape(Grads,(1,N))
end