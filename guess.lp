% for every combination of teacher, class and course:
% either the teacher is assigned to that class and that course, or he isn't
1 {assigned(T, C, S), -assigned(T, C, S)} 1 :- teacher(T), class(C, _), course(S).

% if the curriculum prescribes that a class of grade G should have lessons
% of course S, then some teacher must be assigned to that class
:- curriculum(G, S, L), L > 0, class(C, G), not someTeacherAssigned(C, S).
someTeacherAssigned(C, S) :- assigned(T, C, S).

1 {formteacherOf(T, C), -formteacherOf(T, C)} 1 :- teacher(T), class(C, _).

hasFormteacher(C) :- formteacherOf(_, C).
:- class(C, _), not hasFormteacher(C).
