/* ==========================================================================
   PC-Doctor : Windows Troubleshooting Expert System
   FILE      : main.pl  (USER INTERFACE - menu driven CLI)
   --------------------------------------------------------------------------
   Start the system from a terminal in this folder:
       swipl main.pl
   ========================================================================== */

:- ensure_loaded(engine).
:- initialization(main, main).   % run main/0 when started with "swipl main.pl"


main :-
    banner,
    menu_loop.


/* --------------------------------------------------------------------------
   Banner and menu
   -------------------------------------------------------------------------- */

banner :-
    aggregate_all(count, rule(_,_,_,_,_,_), N),
    format("~n==============================================================~n"),
    format("   PC-DOCTOR : Windows Troubleshooting Expert System~n"),
    format("   Knowledge source: Microsoft Support (~w rules)~n", [N]),
    format("==============================================================~n").

menu_loop :-
    findall(Cat-Label, category(Cat, Label), Cats),
    show_menu(Cats),
    read_choice(Choice),
    (   Choice == exit
    ->  format("~n  Thank you for using PC-Doctor. Goodbye!~n~n")
    ;   handle(Choice, Cats),
        pause,
        menu_loop
    ).

show_menu(Cats) :-
    length(Cats, L),
    H is L + 1, R is L + 2, S is L + 3,
    format("~n  What problem does your Windows PC have?~n~n"),
    forall(nth1(I, Cats, _-Label),
           format("    ~t~w~6|. ~w~n", [I, Label])),
    format("~n    ~t~w~6|. Explain last diagnosis (HOW)~n", [H]),
    format("    ~t~w~6|. Show all rules~n", [R]),
    format("    ~t~w~6|. Show knowledge sources~n", [S]),
    format("    ~t~w~6|. Exit~n", [0]).


/* --------------------------------------------------------------------------
   Reading and handling the user's choice
   -------------------------------------------------------------------------- */

read_choice(Choice) :-
    format("~n  Enter your choice: "),
    read_line_to_string(user_input, Line),
    (   Line == end_of_file
    ->  Choice = exit
    ;   normalize_space(atom(A), Line),
        (   atom_number(A, N), integer(N)
        ->  ( N =:= 0 -> Choice = exit ; Choice = N )
        ;   Choice = invalid
        )
    ).

handle(N, Cats) :-
    integer(N),
    length(Cats, L),
    (   N >= 1, N =< L  -> nth1(N, Cats, Cat-_), consultation(Cat)
    ;   N =:= L + 1     -> how
    ;   N =:= L + 2     -> show_rules
    ;   N =:= L + 3     -> show_sources
    ),
    !.
handle(_, _) :-
    format("~n  Invalid choice. Please enter a number from the menu.~n").

pause :-
    format("~n  Press Enter to return to the menu..."),
    read_line_to_string(user_input, _).


/* --------------------------------------------------------------------------
   Listing the knowledge base
   -------------------------------------------------------------------------- */

show_rules :-
    forall(category(Cat, Label),
           ( format("~n  --- ~w ---~n", [Label]),
             forall(rule(Id, Cat, Conds, Diag, _, Src),
                    ( upcase_atom(Id, UId),
                      upcase_atom(Src, USrc),
                      atomic_list_concat(Conds, ' AND ', If),
                      format("  ~w: IF ~w~n       THEN ~w  [~w]~n",
                             [UId, If, Diag, USrc]) )) )).

show_sources :-
    format("~n  All rules are taken from these Microsoft Support pages:~n"),
    forall(source(Id, Title, URL),
           ( upcase_atom(Id, UId),
             format("~n  ~w: ~w~n      ~w~n", [UId, Title, URL]) )).
