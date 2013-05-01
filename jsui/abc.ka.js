jsonCallback({
    model: "\
####### TEMPLATE MODEL AS DESCRIBED IN THE MANUAL#############\n\
#### Signatures \n\
%agent: A(x,c) # Declaration of agent A \n\
%agent: B(x) # Declaration of B \n\
%agent: C(x1~u~p,x2~u~p) # Declaration of C with 2 modifiable sites\n\
\n\
#### Rules \n\
'a.b' A(x),B(x) <-> A(x!1),B(x!1) @ 'on_rate','off_rate' #A binds B \n\
#'a..b' A(x!1),B(x!1) -> A(x),B(x) @ 'off_rate' #AB dissociation\n\
'ab.c' A(x!_,c),C(x1~u) ->A(x!_,c!2),C(x1~u!2) @ 'on_rate' #AB binds C \n\
'mod x1' C(x1~u!1),A(c!1) ->C(x1~p),A(c) @ 'mod_rate' #AB modifies x1\n\
'a.c' A(x,c),C(x1~p,x2~u) -> A(x,c!1),C(x1~p,x2~u!1) @ 'on_rate' #A binds C on x2 \n\
'mod x2' A(x,c!1),C(x1~p,x2~u!1) -> A(x,c),C(x1~p,x2~p) @ 'mod_rate' #A modifies x2 \n\
\n\
#### Variables \n\
%var: 'on_rate' 1.0E-4 # per molecule per second\n\
%var: 'off_rate' 0.1 # per second \n\
%var: 'mod_rate' 1 # per second \n\
%obs: 'AB' A(x!x.B)\n\
%obs: 'Cuu' C(x1~u?,x2~u?)\n\
%obs: 'Cpu' C(x1~p?,x2~u?) \n\
%obs: 'Cpp' C(x1~p?,x2~p?) \n\
\n\
%var: 'n_a' 1000\n\
%obs: 'n_b' 'n_a'\n\
%var: 'n_c' 10000\n\
\n\
#### Initial conditions \n\
%init: 'n_a' A()\n\
%init: 'n_b' B()\n\
%init: 'n_c' C()"
});