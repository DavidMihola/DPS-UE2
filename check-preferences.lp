#hide preferenceNumber/1.
preferenceNumber(1).
preferenceNumber(2).
preferenceNumber(3).

% (p1)
:- preference(T, S, P1), preference(T, S, P2), teacher(T), course(S), P1 != P2.
% Seems OK!

% (p2)
:- preference(C, T, P1), preference(C, T, P2), class(C, _), teacher(T), P1 != P2.
% Should be OK, too.

% (p3)
preference(T, S, 2) :- teacher(T), course(S), 0 #count {preference(T, S, P) : preferenceNumber(P) : P != 2} 0.

% (p4)
courseCount(N) :- N := #count {course(C)}.

negativePreferences(T, N) :- teacher(T), N := #count {preference(T, S, 1) : course(S)}.
:- teacher(T), negativePreferences(T, N), courseCount(M), N > M / 2.

negativePreferences(C, N) :- class(C, _), N := #count {preference(C, T, 1) : teacher(T)}.
positivePreferences(C, P) :- class(C, _), P := #count {preference(C, T, 3) : teacher(T)}.
:- class(C, _), negativePreferences(C, N), positivePreferences(C, P), N > P.

weightedSum(T, C, N) :- teacher(T), class(C, G), N := #sum [preference(T, S, P) : assigned(T, C, S, L) = P * L]. 

rating(T, C, R) :- teacher(T), class(C, G), N := #sum [preference(T, S, P1) : assigned(T, C, S, L) = P1 * L], preference(C, T, P2), R = N * P2. 
