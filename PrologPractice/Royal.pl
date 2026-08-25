parent(mary,georgeVI).
parent(georgeV,georgeVI).
parent(elizabeth,elizabethII).
parent(georgeVI,elizabethII).
parent(elizabethII,charlesIII).
parent(elizabethII,andrew).
parent(elizabethII,anne).
parent(elizabethII,edward).
parent(philip,charlesIII).
parent(philip,andrew).
parent(philip,anne).
parent(philip,edward).
parent(diana,william).
parent(diana,harry).
parent(charlesIII,william).
parent(charlesIII,harry).
parent(sarah,beatrice).
parent(sarah,eugenie).
parent(andrew,beatrice).
parent(andrew,eugenie).
parent(anne,peter).
parent(anne,zara).
parent(mark,peter).
parent(mark,zara).
parent(kate,georgejun).
parent(kate,charlotte).
parent(kate,louis).
parent(william,georgejun).
parent(william,charlotte).
parent(william,louis).
parent(meghan,archie).
parent(meghan,lilibet).
parent(harry,archie).
parent(harry,lilibet).

royal_female(X):-member(X,[mary,elizabeth,elizabethII,anne,diana,
sarah,beatrice,eugenie,zara,charlotte,kate,meghan,lilibet]).
royal_male(X):-member(X,[georgeV,georgeVI,philip,charlesIII,
andrew,edward,william,harry,mark,peter,georgejun,louis,archie]).


mother(M,C) :- parent(M,C), royal_female(M).
%if M has a child and is a female it will return true 
% for this case if M is a mother of beatrice and a female we will return sarah
/*
###################################################################
Example)
14 ?-  mother(M,beatrice).
M = sarah ;
false.
*/
ancestor(A,D) :- parent(A,D).          
ancestor(A,D) :- parent(A,X), ancestor(X,D).
% this code will recusive call ancestor with parent X as A in ancestor until it finds a parent that satisfies the first condition 
/*
###################################################################
Example)
70 ?- ancestor(A,louis).
A = kate ;
A = william ;
A = mary ;
A = georgeV ;
A = elizabeth ;
A = georgeVI ;
A = elizabethII ;
A = philip ;
A = diana ;
A = charlesIII ;
false.
*/
grandparent(GP,GC) :- parent(GP,P), parent(P,GC).
% this is checking is the grandparent gp is a parent, and if the P the child to the grandparent is a parent 
% if both = true then this must me that gp is a grandparent 
% we are also returning the child of P which will be GC the grand child.

/*
####################################################################
Example)
13 ?- grandparent(elizabeth,GC).
GC = charlesIII ;
GC = andrew ;
GC = anne ;
GC = edward.
*/

has_child(X) :- parent(X,_).
% self explanitiory jsut checking if there is anyone that is a child to X


/*
######################################################################
Example)
15 ?- parent(X,_).
X = mary ;
X = georgeV ;
X = elizabeth ;
X = georgeVI ;
X = elizabethII ;
X = philip ;
X = diana ;
X = charlesIII ;
X = sarah ;
X = andrew ;
X = anne ;
X = mark ;
X = kate ;
X = william ;
X = meghan ;
X = harry.
*/

sibling(X,Y) :- parent(P,X), parent(P,Y), X \= Y.
% if x and y are sibling this would implie that they have the same parent 
% this checks that

brother(B,S) :- sibling(B,S), royal_male(B).
% this checks if the sibling is a male

cousin(X,Y) :- parent(PX,X), parent(PY,Y), sibling(PX,PY), X \= Y.
% X and Y are cousins if PX and PY are sibilings


has_brother(X) :- brother(_,X).
% checking if X has a brother if there exists anyone who is a brother to X

has_cousin(X)  :- cousin(_,X).
% checking if X has a cousin if there exists anyone who is a cousin to X

has_brother_and_cousin(X) :- has_brother(X), has_cousin(X).
% if both has_brother and has_cousin conditions are true it will return the person
/*
#####################################################################
Example)
22 ?- has_brother_and_cousin(X).
X = harry ;
X = william ;
X = zara ;
X = charlotte ;
X = louis ;
X = georgejun ;
X = lilibet ;
false.
*/

has_brother_who_is_granddad(X) :- brother(B,X), granddad(B).
% checking if is a grandad and a brother pretty self explanitiory 

granddad(GD) :- grandparent(GD,_), royal_male(GD).
% checking basically if granddad is male and is a grandad to anyone
%  re-using the code to check if is a grandparent grandparent(GP,GC) :- parent(GP,P), parent(P,GC).

/*
######################################################################
Example)
24 ?- has_brother_who_is_granddad(X).
X = andrew ;
X = anne ;
X = edward ;
false.
*/


