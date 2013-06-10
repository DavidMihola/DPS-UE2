averageTeachingAmount(Y) :- S := #sum [teachingAmount(T, X) : teacher(T) = X], N := #count {teachingAmount(T, X) : teacher(T)}, Y = S / N.

teachingDeviation(T, D) :- teachingAmount(T, X), averageTeachingAmount(Y), D = X - Y.
absoluteTeachingDeviation(T, D) :- teachingDeviation(T, D1), D1 < 0, D = D1 * - 1.
absoluteTeachingDeviation(T, D) :- teachingDeviation(T, D1), D1 >= 0, D = D1.

#minimize [absoluteTeachingDeviation(T, D) : teacher(T) = D @ 1].

#maximize [rating(T, C, V) : teacher(T) : class(C, _) = V @ 2].

mainClass(T, C) :- formteacherOf(T, C).

maxGrade(T, H) :- teacher(T), H := #max [class(C, G) : assigned(T, C, _, _) = G].
%mainClass(T, C) :- not formTeacherOf(T, C), maxGrade(T, H), class(C, G), G = H.
isFormteacher(T) :- formteacherOf(T, C).
isNotFormteacher(T) :- teacher(T), not isFormteacher(T).
maxGradeMinNameClass(T, C) :- teacher(T), class(C, G), maxGrade(T, G), 0 #count{class(C1, G) : assigned(T, C1, S, L) : teacher(T) : C1 < C} 0.
mainClass(T, C) :- isNotFormteacher(T), maxGradeMinNameClass(T, C).
