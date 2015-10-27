type linearstvenant
	phs::Phs
	
	
	function linearstvenant(N)
		this = new()
		this.phs = moulla(N,-1,1);
		return this
	end
end

type spectral_element_phs
	phs::Phs
	
	
	function spectral_element_phs(Nel,Npol,a,b)
	# creates a "spectral element" phs model for
	# first order derivative PHS
	# Npol: is the polynomial approximation order
	# Nel: is the number of elements
	# (a,b): is the domain interval
	
	# to do: 
	# * matrices B and D
	# * create a Hamiltonian/grad method or something like that
		this = new();
		dx = (b-a)/Nel;
		xpoints = linspace(a,b,Nel+1);
		ph = moulla(Npol,0.,dx);
		zvec = zeros(length(ph.zi)*Nel)
		wvec = zeros(length(ph.wi)*Nel)
		J = zeros(2*length(ph.wi)*Nel, 2*length(ph.wi)*Nel)
		alpha1_index = Array(Int, length(ph.wi)*Nel,1)
		alpha2_index = Array(Int, length(ph.wi)*Nel,1)
		for e = 1:Nel
			ze = ph.zi + xpoints[e]
			zvec[1+length(ph.zi)*(e-1):length(ph.zi)*e] = ze;
			wvec[1+length(ph.zi)*(e-1):length(ph.zi)*e] = ph.wi;
			J[1+2*length(ph.zi)*(e-1):2*length(ph.zi)*e,1+2*length(ph.zi)*(e-1):2*length(ph.zi)*e] = ph.J;
			for ei = (e+1):Nel
				J[1+2*length(ph.zi)*(e-1):2*length(ph.zi)*e,1+2*length(ph.zi)*(ei-1):2*length(ph.zi)*(ei)] = -(-ph.D[2,1])^(ei-e+1)*ph.B[:,1]*ph.B[:,2]';
			end
			for ei = 1:(e-1)
				J[1+2*length(ph.zi)*(e-1):2*length(ph.zi)*e,1+2*length(ph.zi)*(ei-1):2*length(ph.zi)*(ei)] = (ph.D[1,2])^(ei-e+1)*ph.B[:,2]*ph.B[:,1]';
			end
			alpha1_index[1+length(ph.zi)*(e-1):length(ph.zi)*e] = [(1:length(ph.zi))+length(ph.zi)*2*(e-1)];
			alpha2_index[1+length(ph.zi)*(e-1):length(ph.zi)*e] = (1:length(ph.zi))+length(ph.zi)*(2*e-1);
		end
		a = alpha1_index;
		b = alpha2_index;
		Jn = J[[a[:];b[:]],[a[:];b[:]]]
		Qn = sparse(diagm(wvec[:],0));
		Qn = blkdiag(Qn,Qn);
		return Jn,Qn,a,b,ph.D
	end
end