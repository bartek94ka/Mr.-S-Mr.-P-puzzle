:- use_module(library(clpfd)).

decompose_product(Min, Max, N) :-
	Max2 #= Max // 2,
	Min2 #= Min + 1,
	Min3 #= Min + 2,
	A in (Min2 .. Max2),
	B in (Min3 .. Max),
	label([A, B]),
	A #< B,
	A + B #< 100,
	N #= A*B #<== 1.

possible_products(Min, Max, Out) :-
	MinSqr #= (Min + 1) * (Min + 2),
	MaxSqr #= (Max // 2 - 1) * (Max // 2),
	Out in (MinSqr .. MaxSqr),
	possible_products2(Min, Max, Out, Out, MinSqr, MaxSqr).

possible_products2(Min, Max, A, A, MaxSqr, MaxSqr).
possible_products2(Min, Max, Out, A, I, MaxSqr) :-
	decompose_product(Min, Max, I),
	I2 #= I+1,
	possible_products2(Min, Max, Out, A, I2, MaxSqr).
possible_products2(Min, Max, Out, A, I, MaxSqr) :-
	A #\= I,
	I2 #= I+1,
	possible_products2(Min, Max, Out, A, I2, MaxSqr).

sp(Min, Max, A, B, A2, B2, Iloczyn, Suma) :- 
	A in (Min .. Max),
	B in (Min .. Max),
	A #> B,
	Iloczyn #= A*B,
	Suma #= A+B,
% szukanie iloczynow z nieunikatowymi czynnikami
	A2 in (Min .. Max),
	B2 in (Min .. Max),
	A2 #> B2,
	A2 #\= A,
	B2 #\= B,
	A2*B2 #= Iloczyn,
% w tym momencie A i B sa para nieunikatowych czynnikow
	label([A, B, Iloczyn, Suma, A2, B2]).