% Only courses from the given set (course/1) are used to classify
% assignments, curricula, and teachers’ knowledge of courses.
:- assigned(_, _, S), not course(S).
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
:- assigned(T,C,S), class(C,G), curriculum(G,S,0).

% "Only teachers who are qualified for a course may teach it."
:- assigned(T,_,S), not qualified(T,S).

% "Each class should only be taught each course by at most one teacher."
:- assigned(T1, C, S), assigned(T2, C, S), T1!=T2.

% "No teacher has to be without any teaching assignment, i.e., unemployed."
:- teacher(T), not assignedToAClass(T).
assignedToAClass(T) :- assigned(T, _, _).

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
teaches(T, C, 1) :- assigned(T, C, _).
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
:- hasRelativeIn(T,C1), assigned(T, C1, _), hasRelativeIn(T, C2), assigned(T, C2, _), C1 != C2.

% Also, no teacher schould teach a class in which he has a relative,
% except if he has relatives in all classes. To put it yet another way:
% No teacher should teach a class in which he has a relative if he is also
% assigned to classes in which he has no relatives:
:- hasRelativeIn(T, C), assigned(T, C, _), couldTeachClassWithoutRelatives(T).

assignedToClassWithoutRelatives(T) :- assigned(T, C, _), not hasRelativeIn(T, C).
couldTeachClassWithoutRelatives(T) :- qualified(T, S), class(C, G), curriculum(G, S, _), not hasRelativeIn(T, C).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% "No teacher should be required to spend more than 24 hours
%  preparing lessons every week, whereas each lesson for grades
%  1 and 2 accounts for 1 hour of preparation and each lesson for
%  grades 3 and 4 accounts for 2 hours of preparation.

% We will calculate the weekly preparation time in two steps:
%  * First, for each teacher, we calculate the number of  lessons the teacher
%    has in each class.
%  * Second, we again iterate over all classes and calculate the sum of
%    preparation needed.

% Like "teaches", we need some predicate to provide values also for
% combinations of teachers, courses and classes that are not assigned.
hasLessonsIn(T, C, S, L) :- assigned(T, C, S), class(C, G), curriculum(G, S, L).
hasSomeLessonsIn(T, C, S) :- hasLessonsIn(T, C, S, L), L!=0.
hasLessonsIn(T, C, S, 0) :- not hasSomeLessonsIn(T, C, S), teacher(T), class(C, _), course(S). 

% Then, iterating over all courses we calculate the sum of lessons a teacher
% has in each class:

partialTeacherLessonsSumPerClass(T, C, S, L) :- firstCourse(S), hasLessonsIn(T, C, S, L).
partialTeacherLessonsSumPerClass(T, C, S2, L) :- succCourse(S1, S2), partialTeacherLessonsSumPerClass(T, C, S1, L1), hasLessonsIn(T, C, S2, L2), L = L1 + L2.
teacherLessonsSumPerClass(T, C, L) :- lastCourse(S), partialTeacherLessonsSumPerClass(T, C, S, L).

% From this sum, we can calculate the number of hours of preparation needed:
teacherPreparationSumPerClass(T, C, P) :- teacherLessonsSumPerClass(T, C, L), class(C, 1), P = L.
teacherPreparationSumPerClass(T, C, P) :- teacherLessonsSumPerClass(T, C, L), class(C, 2), P = L.
teacherPreparationSumPerClass(T, C, P) :- teacherLessonsSumPerClass(T, C, L), class(C, 3), P = L * 2.
teacherPreparationSumPerClass(T, C, P) :- teacherLessonsSumPerClass(T, C, L), class(C, 4), P = L * 2.

% Finally, again iterating over classes, we calculate the hour of preparation for each teacher:
partialTeacherPreparationTotalSum(T, C, P) :- firstClass(C), teacherPreparationSumPerClass(T, C, P).
partialTeacherPreparationTotalSum(T, C2, P) :- succClass(C1, C2), partialTeacherPreparationTotalSum(T, C1, P1), teacherPreparationSumPerClass(T, C2, P2), P = P1 + P2.
teacherPreparationTotalSum(T, P) :- lastClass(C), partialTeacherPreparationTotalSum(T, C, P).

:- teacherPreparationTotalSum(T, P), P > 24.

% Ordering of courses:
% C1 is a (direct or indirect) precursor of C2, if they are both
% classes, and C1 < C2
precCourse(C1, C2) :- course(C1), course(C2), C1 < C2.

% C2 is not the direct successor of C1 if there is a third class C3
% between them
-succCourse(C1, C2) :- precCourse(C1, C3), precCourse(C3, C2).

% C2 is the direct successor of C1 if C1 is any precursor of C2 and
% we do not know that C2 is not the direct successor of C1
succCourse(C1, C2) :- precCourse(C1, C2), not -succCourse(C1, C2).

% C2 cannot be the first class if it is the (direct) successor of
% another class
-firstCourse(C2) :- succCourse(_, C2).

% C is the first class if it is a class and we do not know that it
% is not the first class
firstCourse(C) :- course(C), not -firstCourse(C).

% C1 cannot be the last class if it has a (direct) successor
-lastCourse(C1) :- succCourse(C1,_).

% C is the last class if it is a class and we do not knoe that it
% is not the last class
lastCourse(C) :- course(C), not -lastCourse(C).


% "No class has more than one form teacher."
:- formteacherOf(T1,C), formteacherOf(T2,C), T1!=T2.

% "A class’s form teacher must be teaching that class."
:- formteacherOf(T,C), teaches(T, C, 0).

% "No teacher should be form teacher at more than one class."
:- formteacherOf(T,C1), formteacherOf(T,C2), C1!=C2.