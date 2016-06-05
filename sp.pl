:- use_module(library(clpfd)).

:- multifile clpfd:run_propagator/2.

%generacja ciągu liczb na bazie wartości minimalnej, maksymalnej oraz podanego kroku
%wynikiem jest dziedzina reprezentująca ciąg
%dostęp do kolejnych elementów można uzyskać poprzez użycie predykatu label/2
%	przykladowo
%	min = 2
%	max = 99
%	step = 4
%	uzyskany ciąg: 2 , 6, 10, 14, ..., 94, 98
get_series_step(Min, Max, Step, Out) :-
	Out in (Min .. Max),
	K in (0 .. sup),
	Out #= K * Step + Min.

%wyznaczenie nieunikatowych A i B
%lub
%sprawdzenie czy A i B są nieunikatowe
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
	A2*B2 #= Product.

%sprawdzenie czy podana suma jest dozwolona
%	suma jest dozwolona gdy iloczyn skladnikow sumy mozna rozlozyc na wiecej niz 1 pare czynnikow
eligible_sum_check(Min, Max, Step, Sum) :-
	A #= Sum - Min,
	eligible_sum_check(Min, Max, Step, A, Min).
eligible_sum_check(_, _, _, A, B) :- A #< B.
eligible_sum_check(Min, Max, Step, A1, A2) :-
	non_unique_AB(Min, Max, Step, A2, A1),
	NA1 #= A1 - Step,
	NA2 #= A2 + Step,
	eligible_sum_check(Min, Max, Step, NA1, NA2).
	
%zdefiniowanie wlasnego propagatora CLP, który reaguje na zmiany termu Sum
eligible_sum(Min, Max, Step, Sum) :-
	clpfd:make_propagator(eligible_sum(Min, Max, Step, Sum), Prop),
	clpfd:init_propagator(Sum, Prop),
	clpfd:trigger_once(Prop).
	
clpfd:run_propagator(eligible_sum(Min, Max, Step, Sum), _) :-
	(
		integer(Sum) -> eligible_sum_check(Min, Max, Step, Sum);
		true
	).
	
eligible_product_check_next(Min, Max, _, Product, A1, A2, NA1, NA2) :-
	[NA1, NA2] ins (Min .. Max),
	Product #= NA1 * NA2,
	NA1 #> A1,
	NA2 #< A2,
	NA1 #< NA2,
	label([NA1, NA2]).
	
%produkt jest dozwolony gdy suma pary czynnikow daje dozwolona sume tylko raz
eligible_product_check(Min, Max, Step, Product) :-
	[A1, A2] ins (Min .. Max),
	Product #= A1 * A2,
	label([A1, A2]),
	!,
	eligible_product_check(Min, Max, Step, Product, A1, A2, 0).
eligible_product_check(_, _, _, _, _, _, Acc) :- Acc > 1, !, fail.
eligible_product_check(Min, Max, Step, Product, A1, A2, Acc) :-
	integer(A1),
	integer(A2),
	EligibleSum #= A1 + A2,
	eligible_sum(Min, Max, Step, EligibleSum),
	NAcc #= Acc + 1,
	eligible_product_check_next(Min, Max, Step, Product, A1, A2, NA1, NA2),
	!,
	eligible_product_check(Min, Max, Step, Product, NA1, NA2, NAcc).
eligible_product_check(Min, Max, Step, Product, A1, A2, Acc) :-
	integer(A1),
	integer(A2),
	EligibleSum #= A1 + A2,
	eligible_sum(Min, Max, Step, EligibleSum),
	NAcc #= Acc + 1,
	!,
	eligible_product_check(Min, Max, Step, Product, _, _, NAcc).
eligible_product_check(Min, Max, Step, Product, A1, A2, Acc) :-
integer(A1),
	integer(A2),
	eligible_product_check_next(Min, Max, Step, Product, A1, A2, NA1, NA2),
	!,
	eligible_product_check(Min, Max, Step, Product, NA1, NA2, Acc).
eligible_product_check(_, _, _, _, _, _, 1).
	
%zdefiniowanie wlasnego propagatora CLP, który reaguje na zmiany termu Product
eligible_product(Min, Max, Step, Product) :-
	clpfd:make_propagator(eligible_product(Min, Max, Step, Product), Prop),
	clpfd:init_propagator(Product, Prop),
	clpfd:trigger_once(Prop).
	
clpfd:run_propagator(eligible_product(Min, Max, Step, Product), _) :-
	(
		integer(Product) -> eligible_product_check(Min, Max, Step, Product);
		true
	).

%zliczanie elementów będącymi rozwiązaniami z listy elementów
count(List, Element, Occurences) :-
	count(List, Element, Occurences, 0).
count([], _, Occurences, Occurences).
count([[_, _, _, S]|T], [A, B, I, S], Occ, Acc) :-
	NAcc #= Acc + 1,
	!,
	count(T, [A, B, I, S], Occ, NAcc).
count([_|T], Element, Occ, Acc) :-
	!,
	count(T, Element, Occ, Acc).

%wyznaczenie unikatowego rozwiązania z listy
find_unique_solution(List, Solution) :-
	find_unique_solution(List, List, Solution).
find_unique_solution(List, [[A, B, I, S]|_], [A, B, I, S]) :-
	count(List, [_, _, _, S], 1).
find_unique_solution(List, [_|T], Solution) :-
	find_unique_solution(List, T, Solution).

sp_list(Min, Max, Step, A, B, Product, Sum) :- 
	get_series_step(2, 99, Step, A),
	get_series_step(2, 99, Step, B),
	A #< B,
	Sum #= A + B,
	Product #= A * B,
	eligible_sum(Min, Max, Step, Sum),
	label([Sum]),
	eligible_product(Min, Max, Step, Product),
	label([Product]),
	label([A, B]).

sp(Min, Max, Step, A, B, Product, Sum) :-
	bagof([A, B, I, S], sp_list(Min, Max, Step, A, B, I, S), List),
	find_unique_solution(List, [A, B, Product, Sum]).