:- consult('pijani.pl').
:- consult('query.pl').

/* lubi(P, A)
 * capuje(K, A, C)
 * navstivil(Id, P, K, Od)
 * vypil(Id, A, M) 


 * Pijan je lojálny ku krcme K, ak v nej pil aspon raz a ziaden z alkoholov, ktorý kedykolvek pil
v K, uz POTOM nikde inde nepil. Nájdite vsetky dvojice [P, K] také, ze pijan P je lojálny ku                                
krcme K.
*
*/

answer_a(P, K) :- navstivil(I, P, K, _), vypil(I, _, _), \+ pa(P, K).
pa(P, K) :- navstivil(I, P, K, D), vypil(I, A, _), navstivil(I1, P, K1, D1), vypil(I1, A, _), D1 > D, \+ K = K1. 


/*
 * Pijan je silne závislý na alkohole A vtedy, ak alkohol A pil aspon raz a konzumuje ho pri
kazdej návsteve krcmy, ktorá A capuje; a zároven platí, ze mnozstvá A, ktoré pije pri takých
návstevách, tvoria s rastúcim casom neklesajúcu postupnost. Nájdite vsetky dvojice [P, A]
také, ze pijan P je silne závislý na alkohole A.
*/
answer_b(P, A) :- navstivil(I, P, _, _), vypil(I, A, _), \+ navstivilCapujeNepil(P, A), \+ menej(P, A).
navstivilCapujeNepil(P, A) :- capuje(K, A, _), navstivil(I, P, K, _), \+ vypil(I, A, _).
menej(P, A) :- navstivil(I, P, _, Od), vypil(I, A, M), navstivil(I1, P, _, Od1), vypil(I1, A, M1), Od < Od1, M > M1. 


/*
 * Pijan je jediným rekordérom v pití alkoholu A na jedno posedenie v krcme K, ak vypil pocas
niektorej svojej návstevy krcmy K viac alkoholu A ako ktorýkolvek iný pijan pocas ktorejkolvek 
svojej návstevy v K (a aspon raz v krcme K pil). 
Nájdite dvojice [P, A] také, ze pijan P lúbi alkohol A a v kazdej krcme, ktorá capuje alkohol A, 
je P jediným rekordérom v pití A na jedno posedenie.
*/
answer_c(P, A) :- lubi(P, A), \+ capujeAleNenavstivil(P, A), \+ niektoVypilViac(P, A).
capujeAleNenavstivil(P, A) :- capuje(K, A, _), \+ navstivil(_, P, K, _).
niektoVypilViac(P, A) :- capuje(K, A, _), navstivil(I, P, K, _), vypil(I, A, M), najviac(K, P, A, M), navstivil(I1, P1, K, _), vypil(I1, A, M1), \+ P = P1, M1 >= M.

najviac(K, P, A, M) :- navstivil(I, P, K, _), vypil(I, A, M), \+ nieNajviac(K, P, A, M).
nieNajviac(K, P, A, M) :- navstivil(I, P, K, _), vypil(I, A, M), navstivil(I1, P, K, _), vypil(I1, A, M1), \+ I = I1, M < M1.

/*
 * Drzgros je pijan, ktorý pri lubovolnej návsteve krcmy je ochotný vypit len najlacnejsí alkohol
z tých, ktoré tá krcma capuje a ktoré on zároven lúbi (ak je takých viac, môze pit lubovolný),
a aj to len vtedy, ak zatial nepozná (t.j. predtým nenavstívil) krcmu, ktorá ten alkohol capuje
lacnejsie (pit vsak nemusí vôbec). Nájdite vsetkých drsgrosov.

vipil takze nebol niekde kde ho maju lacnejsie a zaroven 
nieje pravda ze existuje lacnejsi kt capuju a lubi ho 
vypil(I, A, _), capuje(K, A, C),
*/

answer_d(P) :- navstivil(_, P, _, _), \+ majuLacnejsi(P), \+ navstivilLacnejciu(P), \+ nelubi(P).
majuLacnejsi(P) :- navstivil(I, P, K, _), vypil(I, A, _), capuje(K, A, C), capuje(K, A1, C1), \+ A = A1, lubi(P, A1), C1 < C.
navstivilLacnejciu(P) :- navstivil(I, P, K, D), vypil(I, A, _), capuje(K, A, C), navstivil(_, P, K1, D1), capuje(K1, A, C1), C1 < C, \+ K1 = K, D1 < D.
nelubi(P) :- navstivil(I, P, _, _), vypil(I, A, _), \+ lubi(P, A).

 