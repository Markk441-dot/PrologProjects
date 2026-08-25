train(swansea, cardiff, [3,5,8,15,17,18,19,20,23],1,[4,5,6,7,10,14,18,22,23]).
train(cardiff, manchester, [7,11,16],4,[8,14,19]).
train(cardiff, bristol, [3,5,7,11,15,18,19,20],2,[5,6,7,10,14,16,18,22]).
train(manchester, bristol, [5,6,7,8,11,15,18,19,20],4,[5,6,7,10,14,16,18,22]).
train(manchester, swansea, [7,11,16],5,[8,14,19]).
train(manchester, london, [6,7,11,16],4,[7,8,14,19]).
train(cardiff, london, [5,6,7,11,18,19,20],3,[8,9,17,18,19,20,21]).
train(london, brussels, [6,7,8,11,13,17,18,20],5,[9,11,13,16,17,18,19,23]).
train(london, paris, [7,11,13,17,18,20],5,[9,11,13,16,18,20]).
train(paris, brussels, [7,11,17],4,[9,13,19]).
train(paris, munich, [7,11,13,17,22],8,[5,9,13,19,23]).
train(munich, vienna, [8,9,11,13,17,19],6,[9,10,12,16,18,23]).
train(vienna, venice, [5,7,8,10,13,16,12,23],8,[2,4,7,9,12,20,21,23]).
train(venice, paris, [4,11,20],11,[9,12,21]).

/*################################################################### 
Direct connections 
this block of proglog for directs will check for existing direct connections between two cities.
it handels both forward and reverse directions.
The first one will check if a train line exists where X Y equal the input 
say swansea, cardiff 
it has a overflow method incase it is cardiff, swansea is inputted 
if that is inputted it will reverse the out.

###################################################################*/
%forward
direct(X, Y, XDep, XDur) :-
    train(X, Y, XDep, XDur, _).
%reverse
% for the reverse wie will pick the argument as the depa times from Y back to X
direct(X, Y, XDep, XDur) :-
    train(Y, X, _, XDur, XDep).
/*
*/
/*
forward
102 ?- direct(swansea, cardiff, Deps, Dur).
Deps = [3, 5, 8, 15, 17, 18, 19, 20, 23],
Dur = 1 ;
false.
*/
/*
reverse 
102 ?- direct(cardiff, swansea, Deps, Dur).
Deps = [4, 5, 6, 7, 10, 14, 18, 22, 23],
Dur = 1.
*/


/*###################################################################
Restricted Journey 
this one will find the based of the X and Y args as before
but it will only do cities in Cs []
so say we have [cardiff, london] it will only do citites there 
this program will also enforce waiting times for 1-3 hrs between the connections 
###################################################################*/
calc_wait(ArrTime, DepTime, Wait) :-
    RawDiff is DepTime - ArrTime,
    (RawDiff < 0 -> Wait is RawDiff + 24 ; Wait is RawDiff).
/* we have a helper function her for calculating the wait time 
this will account for midnight and wrap the times aroudn to next day 
the diff is the NextDeparture time - the arrival time 
*/
% Base Case
/*Y must be in the allowed list of city (Cs) for this to work or it won't work*/
journeyrestr(X, Dep, [], Arr, Y, Cs) :-
    member(Y, Cs), % this will check if the destination is allowed (in Cs)
    direct(X, Y, Deps, Dur), % this will use direct to find the direction route, forward or reverse
    member(Dep, Deps), % this will select the specific dep times for our journy 
    Arr is (Dep + Dur) mod 24. % this will calculate the arrival time we do mod 24 for the time format

% Recursive call for travling from X to city Z, then to Y
journeyrestr(X, Dep, [inter(ArrZ, Z, DepZ) | RestL], Arr, Y, Cs) :-
    select(Z, Cs, RemainingCs), % this will pick z from the allowed cities and remove it to prevent cycles in the recursion
    direct(X, Z, Deps, Dur), %this will check X have connection, but not to the target (Y) 
    member(Dep, Deps), % for dep time again
    ArrZ is (Dep + Dur) mod 24, % calculating arrival to Z
   
    journeyrestr(Z, DepZ, RestL, Arr, Y, RemainingCs),  % Recursive call for the rest of the journey 
    % we do this call as we dont know depZ so this will find a valid one 
   
    calc_wait(ArrZ, DepZ, Wait), % this will valid the waiting time for Z 1-3 hours 
    Wait >= 1, 
    Wait =< 3.
/*
Valid restricted path

104 ?- journeyrestr(swansea, Dep, L, Arr, london, [cardiff, london]).
Dep = 3,
L = [inter(4, cardiff, 5)],
Arr = 8 ;
Dep = 3,
L = [inter(4, cardiff, 6)],
Arr = 9 ;
Dep = 3,
L = [inter(4, cardiff, 7)],
Arr = 10 ;
Dep = 5,
L = [inter(6, cardiff, 7)],
Arr = 10 ;
Dep = 8,
L = [inter(9, cardiff, 11)],
Arr = 14 ;
Dep = 15,
L = [inter(16, cardiff, 18)],
Arr = 21 ;
Dep = 15,
L = [inter(16, cardiff, 19)],
Arr = 22 ;
Dep = 17,
L = [inter(18, cardiff, 19)],
Arr = 22 ;
Dep = 17,
L = [inter(18, cardiff, 20)],
Arr = 23 ;
Dep = 18,
L = [inter(19, cardiff, 20)],
Arr = 23 ;
false.
*/
/*
impossible path
105 ?-  journeyrestr(swansea, Dep, L, Arr, london, [bristol, london]).
false.
*/



/*###################################################################
Main Journey Predicate
###################################################################*/
get_all_cities(Cities) :-
    setof(City, 
          A^B^C^D^E^(train(City, A, B, C, D); train(E, City, A, B, C)), 
          Cities).

journey(X, Dep, L, Arr, Y) :-
    get_all_cities(AllCities),
    select(X, AllCities, Cs),
    journeyrestr(X, Dep, L, Arr, Y, Cs).
/*
full journey 

106 ?- journey(swansea, Dep, L, Arr, munich).
Dep = 3,
L = [inter(4, cardiff, 5), inter(8, london, 11), inter(16, paris, 17)],
Arr = 1 ;
Dep = 3,
L = [inter(4, cardiff, 6), inter(9, london, 11), inter(16, paris, 17)],
Arr = 1 ;
Dep = 3,
L = [inter(4, cardiff, 7), inter(10, london, 11), inter(16, paris, 17)],
Arr = 1 ;
Dep = 3,
L = [inter(4, cardiff, 7), inter(10, london, 13), inter(18, paris, 21), inter(8, venice, 9), inter(17, vienna, 18)],
Arr = 0 ;
Dep = 5,
L = [inter(6, cardiff, 7), inter(10, london, 11), inter(16, paris, 17)],
Arr = 1 ;
Dep = 5,
L = [inter(6, cardiff, 7), inter(10, london, 13), inter(18, paris, 21), inter(8, venice, 9), inter(17, vienna, 18)],
Arr = 0 ;
false.
*/
/*
109 ?- journey(manchester, Dep, L, Arr, venice).
Dep = 6,
L = [inter(10, london, 13), inter(18, paris, 21)],
Arr = 8 ;
Dep = 7,
L = [inter(11, london, 13), inter(18, paris, 21)],
Arr = 8 ;
false.
*/

/*###################################################################
Quickest Journey 
###################################################################*/
total_duration(Dep, [], Arr, Duration) :- 
    (Arr >= Dep -> Duration is Arr - Dep ; Duration is (24 - Dep) + Arr).

total_duration(Dep, [inter(ArrZ, _, DepNext)|Rest], Arr, Duration) :-
    (ArrZ >= Dep -> LegDur is ArrZ - Dep ; LegDur is (24 - Dep) + ArrZ),
    calc_wait(ArrZ, DepNext, Wait),
    total_duration(DepNext, Rest, Arr, RemainderDur),
    Duration is LegDur + Wait + RemainderDur.

quickest_journey(X, Dep, L, Arr, Y) :-
    findall(
        (Duration, Dep, L, Arr), 
        (journey(X, Dep, L, Arr, Y), total_duration(Dep, L, Arr, Duration)),
        AllJourneys
    ),
    sort(AllJourneys, [(_, Dep, L, Arr) | _]).
/*
107 ?- quickest_journey(swansea, Dep, L, Arr, munich).Dep = 5,
L = [inter(6, cardiff, 7), inter(10, london, 11), inter(16, paris, 17)],
Arr = 1.
*/
/*
108 ?- quickest_journey(london, Dep, L, Arr, vienna).
Dep = 13,
L = [inter(18, paris, 21), inter(8, venice, 9)],
Arr = 17.
*/
