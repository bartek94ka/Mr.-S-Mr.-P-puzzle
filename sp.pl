:- use_module(library(clpfd)).

min(A, B, A) :-
	A =< B.
min(A, B, B) :-
	B < A.

decompose_product(Min, Max, N, A, B) :-
	min(Max, N, M),
	A in (Min .. M),
	B in (Min .. M),
	A #< B,
	N #= A*B #<== 1,
	label([A, B]).

%nieunikatowe A i B
non_unique_AB(Min, Max, A, B) :-
	A in (Min .. Max),
	B in (Min .. Max),
	A #< B,
	Iloczyn #= A*B,
	A2 in (Min .. Max),
	B2 in (Min .. Max),
	A2 #< B2,
	A2 #\= A,
	B2 #\= B,
	A2*B2 #= Iloczyn,
	label([A, B]).

get_series_step(Min, Max, Step, Out) :-
	Out in (Min .. Max),
	Out2 in (Min .. Max),
	get_series_step(Min, Max, Step, Out, Out2, Min, Min).
get_series_step(_, Max, _, Out, Out, Max, Max).
get_series_step(_, Max, _, Out, Out, K, Max) :- Out #\= Max.
get_series_step(Min, Max, Step, Out, Out2, K, K) :-
	NK #= K + Step,
	NAcc #= K + 1,
	get_series_step(Min, Max, Step, Out, Out2, NK, NAcc).
get_series_step(Min, Max, Step, Out, Out2, K, Acc) :-
	Out2 #\= Acc,
	NAcc #= Acc + 1,
	get_series_step(Min, Max, Step, Out, Out2, K, NAcc).

non_unique_AB(Min, Max, Step, A, B) :-
	get_series_step(Min, Max, Step, A),
	get_series_step(Min, Max, Step, B),
	A #< B,
	Product #= A*B,
	get_series_step(Min, Max, Step, A2),
	get_series_step(Min, Max, Step, B2),
	A2 #< B2,
	B2 #\= B,
	A2 #\= A,
	A2*B2 #= Product,
	!,
	label([A, B]).

%suma jest dozwolona gdy iloczyn skladnikow sumy mozna rozlozyc na wiecej niz 1 pare czynnikow
eligible_sum(Min, Max, Sum) :-
	A #= Sum - Min,
	eligible_sum(Min, Max, A, Min).
eligible_sum(_, _, A, B) :- A #< B.
eligible_sum(Min, Max, A1, A2) :-
	non_unique_AB(Min, Max, A2, A1),
	NA1 #= A1 - 1,
	NA2 #= A2 + 1,
	eligible_sum(Min, Max, NA1, NA2).

%produkt jest dozwolony gdy suma pary czynnikow daje dozwolona sume tylko raz
eligible_product(Min, Max, Product) :-
	bagof([A, B], decompose_product(Min, Max, Product, A, B), ProductsList),
	eligible_product(Min, Max, ProductsList, 0).
eligible_product(_, _, [], 1).
eligible_product(Min, Max, [[P1,P2]|T], Acc) :-
	EligibleSum #= P1 + P2,
	eligible_sum(Min, Max, EligibleSum),
	NAcc #= Acc + 1,
	!,
	eligible_product(Min, Max, T, NAcc).
eligible_product(Min, Max, [_|T], Acc) :-
	!,
	eligible_product(Min, Max, T, Acc).

count(List, Element, Occurences) :-
	count(List, Element, Occurences, 0).
count([], _, Occurences, Occurences).
count([[_, _, _, S]|T], [A, B, I, S], Occ, Acc) :-
	NAcc #= Acc + 1,
	!,
	count(T, [A, B, I, S], Occ, NAcc).
count([H|T], Element, Occ, Acc) :-
	!,
	count(T, Element, Occ, Acc).

find_unique_solution(List, Solution) :-
	find_unique_solution(List, List, Solution).
find_unique_solution(List, [[A, B, I, S]|_], [A, B, I, S]) :-
	count(List, [_, _, _, S], 1).
find_unique_solution(List, [H|T], Solution) :-
	find_unique_solution(List, T, Solution).

sp_list(Min, Max, Krok, A, B, Iloczyn, Suma) :- 
	non_unique_AB(Min, Max, Krok, A, B),
	Iloczyn #= A*B,
	Suma #= A+B,
	eligible_sum(Min, Max, Suma),
	eligible_product(Min, Max, Iloczyn),
	label([A, B, Iloczyn, Suma]).

sp(Min, Max, Krok, A, B, Iloczyn, Suma) :-
	bagof([Atmp, Btmp, I, S], sp_list(Min, Max, Krok, Atmp, Btmp, I, S), List),
	find_unique_solution(List, [A, B, Iloczyn, Suma]).