1 {assigned(T, C, S, L2) : teacher(T) : lessonNumber(L2) : 2 <= L2 : L2 <= L} :- class(C, G), course(S), curriculum(G,S,L).

#hide lessonNumber/1.
lessonNumber(0).
lessonNumber(N + 1) :- lessonNumber(N), N < M, maxLessons(M).

%maxLessons(M) :- M := #max [curriculum(G, S, L) = L].

maxLessons(50).

% (g5):
% If there are two assignments of
:- assigned(T1, C, S, L1), assigned(T2, C, S, L2), T1 == T2, L1 != L2.

% (g6):
% For each class and each course: Compute the total number of lessons for which
% teachers are assigned to teach this class in this course. This total number
% must be equal to (neither bigger nor smaller than) the number of lessons prescribed
% by the curriculum.
:- class(C, G), course(S), curriculum(G, S, L), not L #sum[assigned(T, C, S, L2) : teacher(T) = L2] L.

% if the curriculum prescribes that a class of grade G should have lessons
% of course S, then some teacher must be assigned to that class
% TODO: check whether we really still need the following rule:
:- curriculum(G, S, L), L > 0, class(C, G), not someTeacherAssigned(C, S).
someTeacherAssigned(C, S) :- assigned(T, C, S, _).

% for each combination of teacher and class: either the teacher is the form teacher
% of the class or he is not
1 {formteacherOf(T, C), -formteacherOf(T, C)} 1 :- teacher(T), class(C, _).

% each class must have a (i. e. at least one) form theacher
% (the "at most one"-part is checked elsewhere)
hasFormteacher(C) :- formteacherOf(_, C).
:- class(C, _), not hasFormteacher(C).
