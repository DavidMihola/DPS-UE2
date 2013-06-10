% Only courses from the given set (course/1) are used to classify
% assignments, curricula, and teachers’ knowledge of courses.
:- assigned(_, _, S, _), not course(S).
:- curriculum(_, S, _), not course(S).
:- qualified(_, S), not course(S).

% "Classes can only be in grade 1 – 4-"
:- class(_, G), G < 1.
:- class(_, G), G > 4.
% OK.

% "and cannot be classified to be in more than one grade."
:- class(C, G1), class(C, G2), G1!=G2.
% OK.

% "If for some grade and course the curriculum is not given,
%  assume that no lessons (i.e. 0) are required."
courseInGrade(G, S) :- curriculum(G, S, L), L!=0.
curriculum(G,S,0) :- not courseInGrade(G, S), class(_, G), course(S).

% "No teacher should be assigned to teach a course in a class
%  where no lessons are required."
:- assigned(T,C,S,_), class(C,G), curriculum(G,S,0).

% "Only teachers who are qualified for a course may teach it."
:- assigned(T,_,S,_), not qualified(T,S).

% "Each class should only be taught each course by at most one teacher."
% Removed for exersize 3

% "No teacher has to be without any teaching assignment, i.e., unemployed."
:- teacher(T), not assignedToAClass(T).
assignedToAClass(T) :- assigned(T, _, _, _).

% "No teacher should teach more than 4 different classes."
% Let's try to first just look at teachers and classes (without specific courses):

% To iterate over classes, we first need an ordering of the classes:

% C1 is a (direct or indirect) precursor of C2, if they are both
% classes, and C1 < C2
precClass(C1, C2) :- class(C1,_), class(C2,_), C1 < C2.

% C2 is not the direct successor of C1 if there is a third class C3
% between them
-succClass(C1, C2) :- precClass(C1, C3), precClass(C3, C2).

% C2 is the direct successor of C1 if C1 is any precursor of C2 and
% we do not know that C2 is not the direct successor of C1
succClass(C1, C2) :- precClass(C1, C2), not -succClass(C1, C2).

% C2 cannot be the first class if it is the (direct) successor of
% another class
-firstClass(C2) :- succClass(_, C2).

% C is the first class if it is a class and we do not know that it
% is not the first class
firstClass(C) :- class(C,_), not -firstClass(C).

% C1 cannot be the last class if it has a (direct) successor
-lastClass(C1) :- succClass(C1,_).

% C is the last class if it is a class and we do not knoe that it
% is not the last class
lastClass(C) :- class(C,_), not -lastClass(C).

% We can then calculate the number of classes taught by each teacher:

% First we collapse all the courses that a teacher has in a class to one
% simpler prediacte, namely whether the teacher teaches the class at all
% or not
teaches(T, C, 1) :- assigned(T, C, _, _).
teaches(T, C, 0) :- not teaches(T, C, 1), teacher(T), class(C,_).

% Then, we follow the iteration pattern to calculate the sum
partialTeacherClassesSum(T, C, S) :- firstClass(C), teaches(T, C, S).
partialTeacherClassesSum(T, C2, S) :- succClass(C1, C2), partialTeacherClassesSum(T, C1, S1), teaches(T, C2, S2), S = S1 + S2.
teacherClassesSum(T, S) :- lastClass(C), partialTeacherClassesSum(T, C, S).

:- teacherClassesSum(T, S), S>4.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% "A teacher may not teach a class he has a relative in, except
%  when there is a relative in every class, to which he or she
%  could teach at least one course. In that case, he or she may
%  teach a single class with a relative in it (and any number of
%  courses in that class)."

% OK, let's put this another way: Under no circumstances is a teacher
% allowed to teach more than one class in which he has relatives. If
% he teaches two classes and has relatives in both, they must be the
% same class:
:- hasRelativeIn(T,C1), assigned(T, C1, _, _), hasRelativeIn(T, C2), assigned(T, C2, _, _), C1 != C2.

% Also, no teacher schould teach a class in which he has a relative,
% except if he has relatives in all classes. To put it yet another way:
% No teacher should teach a class in which he has a relative if he is also
% assigned to classes in which he has no relatives:
:- hasRelativeIn(T, C), assigned(T, C, _, _), couldTeachClassWithoutRelatives(T).

assignedToClassWithoutRelatives(T) :- assigned(T, C, _, _), not hasRelativeIn(T, C).
couldTeachClassWithoutRelatives(T) :- qualified(T, S), class(C, G), curriculum(G, S, _), not hasRelativeIn(T, C).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% "No teacher should be required to spend more than 24 hours
%  preparing lessons every week, whereas each lesson for grades
%  1 and 2 accounts for 1 hour of preparation and each lesson for
%  grades 3 and 4 accounts for 2 hours of preparation.

% Removed for exersize 3

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% "No class has more than one form teacher."
:- formteacherOf(T1,C), formteacherOf(T2,C), T1!=T2.

% "A class’s form teacher must be teaching that class."
:- formteacherOf(T,C), teaches(T, C, 0).

% "No teacher should be form teacher at more than one class."
:- formteacherOf(T,C1), formteacherOf(T,C2), C1!=C2.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% New Constraints

% (a8) Each teacher is assigned to teach at most 20 lessons a week.

teachingAmount(T, X) :- X := #sum [assigned(T, C, S, L) = L], teacher(T).
