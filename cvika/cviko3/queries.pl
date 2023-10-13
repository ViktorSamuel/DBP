:- consult('query.pl').

/*

Consider the following database scheme:

reader(Ir, Name, RegistrationDate)      // Ir is a unique reader id
book(Ib, Title, Author)                 // Ib is a unique book id
borrowing(Ir, Ib, BorrowingDate, ReturnDate)

Represent dates by integers describing number of days that have passed since a fixed date (e. g. 2018/01/01).
If a reader has not returned a book, ReturnDate is represented by the constant null.

*/

/* 0. Create the file "library.pl" containing at least 2 records for each table (predicate). 

Required: Do not use spaces in string constants and start every string constant with a lower-case letter.

Advisable: Use artificial names for both people and books, e.g. 'r01' and 'r02' for readers and 'b01' for a book. It would be easier to extend the dataset later.
*/

:- consult('lib.pl').

//*  1. Print names and registration dates of all readers. */
nameAndRegDate(N, D) :- reader(_, N, D).

/*  2. Print titles of all books that have been borrowed at least once. */
borrowed(T) :- borrowing(_, IB, _, _), book(IB, T, _).

/*  3. Print titles of all books that have never been borrowed. */
notBorrowed(T) :- book(_, T, _), \+ borrowed(T).

/*  4. Find names of all registered readers that have never borrowed a book. */
readerWithBook(N) :- reader(IR, N, _),  borrowing(IR, _, _, _).
readerNoBook(N) :- reader(_, N, _), \+ readerWithBook(N).

/*  5. Print all triples [R, B, BorrowingDate], where B is the title of a book that was borrowed by a reader R, but has not been returned yet. */
notReturnedBook(R, B, D) :- reader(IR, R, _), borrowing(IR, IB, D, RD), RD = 'null', book(IB, B, _).

/*  6. Find names of all readers that returned all the books they borrowed. */
hasNotReturn(R) :- reader(IR, R, _), borrowing(IR, IB, _, RD), RD = 'null', book(IB, _, _).
returnAll(R) :- reader(IR, R, _), book(IB, _, _), borrowing(IR, IB, _, _), \+ hasNotReturn(R).

/*  7. Print all pairs [R, B] such that B is the title of a book that the reader R borrowed at least twice. */
atLeastTwice(R, B) :- reader(IR, R, _), book(IB, B, _), borrowing(IR, IB, D1, _), borrowing(IR, IB, D2, _), \+ D1 = D2.

/*  8. Print all pairs [R, B] such that B is the title of a book that the reader R borrowed exactly twice. */
moreThanTwice(R, B) :- reader(IR, R, _), book(IB, B, _), borrowing(IR, IB, D1, _), borrowing(IR, IB, D2, _), borrowing(IR, IB, D3, _), \+ D1 = D2, \+ D1 = D3, \+ D2 = D3.
exactlyTwice(R, B) :- atLeastTwice(R, B), \+ moreThanTwice(R, B).

/*  9. Find names of all readers that borrowed at least two different books and such that all the books they borrowed were written by the same author. */
allFromSameAuthor(R) :- reader(IR, R, _), borrowing(IR, IB1, _, _), borrowing(IR, IB2, _, _), \+ IB1 = IB2, \+ differentAuthors(R).
differentAuthors(R) :- reader(IR, R, _), borrowing(IR, IB1, _, _), borrowing(IR, IB2, _, _), \+ IB1 = IB2, book(IB1, _, A1), book(IB2, _, A2), \+ A1 = A2.

/* 10. For each registered reader list the name of the first book he borrowed (or null if he has never borrowed anything). */
notFirst(IR, IB, D) :- borrowing(IR, IB2, D2, _), \+ IB = IB2, D2 < D.
firstBook(R, B) :- reader(IR, R, _), borrowing(IR, IB, D, _), book(IB, B, _), \+ notFirst(IR, IB, D).
firstBook(R, B) :- readerNoBook(R), B = 'null'.

/* 11. Find names of all authors such that every reader borrowed at least one of their books. 
 * authors such that not exist reader such that not borroved his book*/
borrow(A, IR) :- borrowing(IR, IB, _, _), book(IB, _, A).
exist(A) :- reader(IR, _, _), \+ borrow(A, IR).                                                
authors(A) :- book(_, _, A), \+ exist(A).

/* 12. Find all readers that borrowed at least once any book that has ever been borrowed from this library. 
 * readers such that there not exist book thay did not borrow*/
wasBorrowed(IB) :- borrowing(_, IB, _, _).
notAll(IR) :- wasBorrowed(IB), reader(IR, _, _), \+ borrowing(IR, IB, _, _).
readers(R) :- reader(IR, R, _), \+ notAll(IR).
    
/* 13. Find pairs [R, LB], where LB is the length (in days) of the longest borrowing of the reader R (we are not interested in books that have not been returned yet). */
notLongest(IR, IB) :- borrowing(IR, IB, D11, D12), borrowing(IR, IB2, D21, D22), \+ D22 = 'null', \+ IB = IB2, D12-D11 < D22-D21. 
longest(R, LB) :- reader(IR, R, _), borrowing(IR, IB, D1, D2), \+ D2 = 'null', \+ notLongest(IR, IB), LB is D2-D1.

/* 14. Find readers that did not borrow anything during the day of their registration and never borrow more than one book. */
inDayOfReg(IR) :- reader(IR, _, RD), borrowing(IR, _, RD, _).
inSameTime(IR) :- reader(IR, _, _), borrowing(IR, IB, BD, RD), borrowing(IR, IB1, BD1, RD1),
    			  \+ IB = IB1, BD =< BD1, \+ RD = 'null', \+ RD1 = 'null', RD >= RD1.
inSameTime(IR) :- reader(IR, _, _), borrowing(IR, IB, BD, RD), borrowing(IR, IB1, BD1, _),
    			  \+ IB = IB1, BD =< BD1, RD = 'null'.
readers14(R) :- reader(IR, R, _), \+ inSameTime(IR), \+ inDayOfReg(IR).

/* 15. Find readers that returned every book they borrowed and each time they returned a book, they did so in a time shorter than that of at least one other reader. */
didNotReturn(IR) :- borrowing(IR, _, _, null).
notLongest2(IR, IB) :- borrowing(IR, IB, D11, D12), borrowing(IR2, IB, D21, D22), \+ D22 = 'null', \+ IR = IR2, D12-D11 < D22-D21.
readers15(R) :- reader(IR, R, _), borrowing(IR, IB, _, _), \+ didNotReturn(IR), notLongest2(IR, IB).


/* 16. Find meticulous readers that read books "author by author": if they read a book from an author, then they exclusively read books of that author until they have read all such books available from the library.
(Beware: it is possible that they read books of an author more than once and in between they read books of another author. 
Borrowing of several books is allowed, but they must all be of the same author, i. e. a meticulous reader will not borrow a book from a new author until he has returned all the books of the present author.*/
% not correct
bookSerie(IR, D1, D2, IB1, IB2) :- borrowing(IR, IB1, D1, _), borrowing(IR, IB2, D2, _), \+ IB1 = IB2, book(IB1, _, A), book(IB2, _, A), \+ interuption(IR, D1, D2, A).
interuption(IR, D1, D2, A) :- borrowing(IR, IB, D, _), book(IB, _, A1), \+ A = A1, D1 =< D, D =< D2.
interuption(IR, D1, D2, A) :- borrowing(IR, IB, _, D), book(IB, _, A1), \+ A = A1, \+ D = 'null', D1 =< D, D =< D2.
interuption(IR, D1, D2, A) :- borrowing(IR, IB, D, null), book(IB, _, A1), \+ A = A1, D =< D1, borrowing(_, _, _, D2).
interuption(IR, D1, D2, A) :- borrowing(IR, IB, D, null), book(IB, _, A1), \+ A = A1, D =< D2, borrowing(_, _, D1, _).

completeSerie(IR, IB1, D1) :- book(IB1, _, A), book(IB2, _, A), \+ IB2 = IB1, borrowing(IR, IB1, D1, _), borrowing(IR, IB2, D2, _), \+ bookSerie(IR, D1, D2, IB1, IB2).
notComplete(IR) :- borrowing(IR, IB1, _, _), borrowing(IR, IB2, _, _), \+ IB1 = IB2, \+ completeSerie(IR, IB1, _).
onlyCompleteSeries(R) :- reader(IR, R, _), \+ notComplete(IR).

    
/* Check whether all the rules you have used are safe. */
