/* ==========================================================================
   PC-Doctor : Windows Troubleshooting Expert System
   FILE      : engine.pl  (INFERENCE ENGINE + EXPLANATION FACILITY)
   --------------------------------------------------------------------------
   How it works (BACKWARD CHAINING):

     1. The user picks a problem category (e.g. printer).
     2. The engine takes the rules of that category from top to bottom.
     3. For each rule it tries to prove every condition in its IF list:
          - if the answer is already in WORKING MEMORY (known/2) it is reused,
          - otherwise the user is ASKED the question and the answer is stored.
     4. The FIRST rule whose conditions are all "yes" FIRES and gives the
        diagnosis. If no rule fires, the system says it cannot diagnose.

   Explanation facility:
     - WHY : while a question is shown the user can type "why" to see which
             rule the engine is currently testing.
     - HOW : after a diagnosis, how/0 shows which rule fired, the facts that
             made it true, and the Microsoft source of the rule.
   ========================================================================== */

:- ensure_loaded(knowledge_base).

:- dynamic known/2.       % known(Fact, yes/no)  - working memory
:- dynamic fired/1.       % fired(RuleID)        - rule that gave the result
:- dynamic batch_mode/0.  % when set, questions are not asked (used for tests)


/* --------------------------------------------------------------------------
   1. WORKING MEMORY
   -------------------------------------------------------------------------- */

reset :-
    retractall(known(_, _)),
    retractall(fired(_)).


/* --------------------------------------------------------------------------
   2. INFERENCE - backward chaining
   -------------------------------------------------------------------------- */

% diagnose(+Category, -RuleID)
%   Find the first rule of Category whose conditions are all true.
diagnose(Category, RuleID) :-
    rule(RuleID, Category, Conditions, _, _, _),
    all_true(Conditions, RuleID),
    !,
    assertz(fired(RuleID)).

% all_true(+Conditions, +RuleID) - every condition in the list is true
all_true([], _).
all_true([Fact | Rest], RuleID) :-
    is_true(Fact, RuleID),
    all_true(Rest, RuleID).

% is_true(+Fact, +RuleID)
is_true(Fact, _) :-                 % already known to be true
    known(Fact, yes), !.
is_true(Fact, _) :-                 % already known to be false
    known(Fact, no), !, fail.
is_true(Fact, RuleID) :-            % unknown -> ask the user and remember
    ask(Fact, RuleID, Answer),
    assertz(known(Fact, Answer)),
    Answer == yes.


/* --------------------------------------------------------------------------
   3. ASKING QUESTIONS (user dialogue)
   -------------------------------------------------------------------------- */

% In batch (test) mode every unknown fact is taken as "no".
ask(_, _, no) :-
    batch_mode, !.
ask(Fact, RuleID, Answer) :-
    question(Fact, Text),
    format("~n  ~w (yes/no/why): ", [Text]),
    read_answer(Reply),
    (   Reply == why
    ->  explain_why(RuleID),
        ask(Fact, RuleID, Answer)
    ;   Answer = Reply
    ).

% read_answer(-Reply) : Reply is yes, no or why
read_answer(Reply) :-
    read_line_to_string(user_input, Line),
    (   Line == end_of_file
    ->  Reply = no
    ;   normalize_space(atom(A), Line),
        downcase_atom(A, Word),
        (   answer_word(Word, Reply)
        ->  true
        ;   format("  Please type yes, no or why: "),
            read_answer(Reply)
        )
    ).

answer_word(yes, yes).  answer_word(y, yes).
answer_word(no,  no).   answer_word(n, no).
answer_word(why, why).  answer_word(w, why).  answer_word('?', why).


/* --------------------------------------------------------------------------
   4. EXPLANATION FACILITY
   -------------------------------------------------------------------------- */

% WHY - shown during questioning
explain_why(RuleID) :-
    rule(RuleID, _, Conditions, Diagnosis, _, Source),
    source(Source, Title, _),
    upcase_atom(RuleID, R),
    format("~n  [WHY] I am testing rule ~w:~n", [R]),
    format("        IF~n"),
    forall(member(C, Conditions), print_condition(C)),
    format("        THEN ~w~n", [Diagnosis]),
    format("        (Source: ~w)~n", [Title]).

print_condition(C) :-
    question(C, Text),
    (   known(C, V) -> Status = V ; Status = 'not asked yet' ),
    format("          - ~w  [~w]~n", [Text, Status]).

% HOW - shown after a diagnosis
how :-
    fired(RuleID), !,
    rule(RuleID, _, Conditions, Diagnosis, _, Source),
    source(Source, Title, URL),
    upcase_atom(RuleID, R),
    upcase_atom(Source, S),
    format("~n  [HOW] The conclusion was reached by rule ~w:~n", [R]),
    format("        IF~n"),
    forall(member(C, Conditions), print_condition(C)),
    format("        THEN ~w~n", [Diagnosis]),
    format("~n        Source ~w: ~w~n        ~w~n", [S, Title, URL]),
    rejected_rules.
how :-
    format("~n  No diagnosis has been made yet.~n").

% rejected_rules - rules that were ruled out by a "no" answer
rejected_rules :-
    fired(Fired),
    rule(Fired, Category, _, _, _, _),
    findall(R, ( rule(R, Category, Conds, _, _, _),
                 R \== Fired,
                 member(C, Conds), known(C, no) ),
            Rs0),
    sort(Rs0, Rs),
    (   Rs == []
    ->  true
    ;   maplist(upcase_atom, Rs, Up),
        atomic_list_concat(Up, ', ', List),
        format("~n        Rules ruled out by your 'no' answers: ~w~n", [List])
    ).


/* --------------------------------------------------------------------------
   5. RUNNING A CONSULTATION
   -------------------------------------------------------------------------- */

% consultation(+Category) - full interactive session for one category
consultation(Category) :-
    reset,
    category(Category, Label),
    format("~n=== ~w ===~n", [Label]),
    format("  (Answer yes or no. Type why to see why a question is asked.)~n"),
    (   diagnose(Category, RuleID)
    ->  show_result(RuleID)
    ;   no_result
    ).

show_result(RuleID) :-
    rule(RuleID, _, _, Diagnosis, Action, Source),
    source(Source, Title, _),
    upcase_atom(RuleID, R),
    format("~n  ------------------------------------------------------------~n"),
    format("  DIAGNOSIS      : ~w~n", [Diagnosis]),
    format("  RECOMMENDATION : ~w~n", [Action]),
    format("  RULE / SOURCE  : ~w - Microsoft Support: ~w~n", [R, Title]),
    format("  ------------------------------------------------------------~n").

no_result :-
    format("~n  ------------------------------------------------------------~n"),
    format("  No rule matched your answers, so no diagnosis can be made.~n"),
    format("  Please contact a technician or Microsoft Support.~n"),
    format("  ------------------------------------------------------------~n").


/* --------------------------------------------------------------------------
   6. NON-INTERACTIVE MODE (for test cases)
      run_test(+Category, +YesFacts, -Result)
        YesFacts = facts the "user" answers yes to; all others are no.
        Result   = the RuleID that fired, or none.
      Example:  ?- run_test(printer, [printer_not_working, printer_offline], R).
                R = r13.
   -------------------------------------------------------------------------- */

run_test(Category, YesFacts, Result) :-
    reset,
    assertz(batch_mode),
    forall(member(F, YesFacts), assertz(known(F, yes))),
    (   diagnose(Category, R) -> Result = R ; Result = none ),
    retractall(batch_mode).
