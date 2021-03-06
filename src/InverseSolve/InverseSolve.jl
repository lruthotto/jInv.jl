module InverseSolve
	
	using KrylovMethods
	
	using jInv.Utils
	using jInv.Mesh
	using jInv.ForwardShare
	using jInv.LinearSolvers
	
	import jInv.ForwardShare.ForwardProbType
	
	export getName,AbstractModel, AbstractMisfit

	abstract AbstractModel
	abstract AbstractMisfit
	
	include("HessianPreconditioners.jl")
	
	include("misfitParam.jl")

	"""
	type jInv.InverseSolve.InverseParam
	
	Type storing parameters for Inversion. 
	
	Fields:
		Minv::AbstractMesh
		modelfun::Function    - model function (evaluated by main worker), see models.jl
		regularizer::Function - regularizer, see regularizer.jl
		alpha::Real           - regularization parameter
		mref::Array           - reference model
		boundsLow::Vector     - lower bounds for model
		boundsHigh::Vector    - upper bounds for model
		maxStep::Real         - maximum step in optimization
    	pcgMaxIter::Int       - maximum number of PCG iterations
		pcgTol::Real          - tolerance for PCG
		minUpdate::Real       - stopping criteria
    	maxIter::Int          - maximum number of iterations
		HesPrec				  - A preconditioner for the Hessian.
	Constructor:
		getInverseParam
	
	Example: 
	    Minv = getRegularMesh(domain,n)
	    modelfun = expMod
	    regularizer(m,mref,Minv) = wdiffusionReg(m,mref,Minv)
	    alpha   = 1e-3
		mref    = zeros(Minv.nc)
		pInv = getInverseParam(Minv,modelfun,regularizer,alpha,mref)
	"""
	type InverseParam
		MInv::AbstractMesh
		modelfun::Function  # function that goes from model to conductivity
		regularizer::Union{Function,Array{Function}}  # function to calculate WTW
		alpha::Union{Float64,Array{Float64}}  # tradeoff parameter
		mref::Array  # reference model
		boundsLow::Vector
		boundsHigh::Vector
		maxStep::Real  # maximum step size for delta m
		pcgMaxIter::Int
		pcgTol::Real
		minUpdate::Real  #  Step norm stopping tol.
		maxIter::Int
		HesPrec
	end  # type InverseParam
	
	"""
	function jInv.InverseSolve.getInverseParam(...)
	
	Constructs an InverseParam
	
	Required Input:
	
		Minv::AbstractMesh    - mesh of model
		modFun::Function      - model
		regularizer::Function - regularizer, see regularizer.jl
		alpha::Real           - regularization parameter
		mref                  - reference model
		boundsLow::Vector     - lower bounds for model
		boundsHigh::Vector    - upper bounds for model
		
	Optional Inputs:
	
		maxStep::Real=1.0     - maximum step in optimization
	    pcgMaxIter::Int=10    - maximum number of PCG iterations
	    pcgTol::Real          - tolerance for PCG
		minUpdate::Real=1e-4  - stopping criteria
	    maxIter::Int=10       - maximum number of iterations
	"""
	function getInverseParam(MInv,modFun,
							 regularizer,alpha,mref,
							 boundsLow::Vector,boundsHigh::Vector; maxStep=1.0,pcgMaxIter=10,pcgTol=1e-1,
							 minUpdate=1e-4,maxIter=10,HesPrec=getSSORRegularizationPreconditioner(1.0,1e-15,10))
							 
		return 	InverseParam(MInv,modFun,
							 regularizer,alpha,mref,
		                     boundsLow,boundsHigh,
							 maxStep,pcgMaxIter,pcgTol,minUpdate,maxIter,HesPrec)
	end



	export InverseParam, getInverseParam

	include("globalToLocal.jl")
	include("models.jl")
	include("misfit.jl")
	include("regularizers.jl")
	include("projGNCG.jl")
	include("projPCG.jl")
	include("barrierGNCG.jl")
	include("computeMisfit.jl")
	include("computeGradMisfit.jl")
	include("HessMatVec.jl")
	include("iteratedTikhonov.jl")
	
end
