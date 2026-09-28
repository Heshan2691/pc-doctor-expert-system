/* ==========================================================================
   PC-Doctor : Windows Troubleshooting Expert System
   FILE      : tests.pl  (AUTOMATED TEST CASES)
   --------------------------------------------------------------------------
   Run all tests from a terminal in this folder:
       swipl -g run_all_tests -t halt tests.pl

   test(TestID, Category, YesFacts, ExpectedRule)
     YesFacts     = the facts the "user" answers YES to (all others = NO)
     ExpectedRule = the rule that should fire, or none
   ========================================================================== */

:- ensure_loaded(engine).
:- dynamic passed/1.

% --- One test per rule: the rule's own conditions must make it fire -------
test(t01, sound,          [no_sound, wrong_output_device],                 r01).
test(t02, sound,          [no_sound, audio_hardware_muted_or_unplugged],   r02).
test(t03, sound,          [no_sound, after_update],                        r03).
test(t04, sound,          [no_sound, audio_driver_problem],                r04).
test(t05, wifi,           [no_wifi, airplane_mode_on],                     r05).
test(t06, wifi,           [no_wifi, saved_network_fails],                  r06).
test(t07, wifi,           [no_internet, other_devices_fail],               r07).
test(t08, wifi,           [no_internet, other_devices_ok],                 r08).
test(t09, wifi,           [no_wifi, after_update],                         r09).
test(t10, printer,        [printer_not_working],                           r10).
test(t11, printer,        [printer_not_working, printer_connection_problem], r11).
test(t12, printer,        [printer_not_working, jobs_stuck_in_queue],      r12).
test(t13, printer,        [printer_not_working, printer_offline],          r13).
test(t14, blue_screen,    [blue_screen, new_hardware_added],               r14).
test(t15, blue_screen,    [blue_screen, cannot_restart],                   r15).
test(t16, blue_screen,    [blue_screen, device_manager_warning],           r16).
test(t17, blue_screen,    [blue_screen, low_disk_space],                   r17).
test(t18, blue_screen,    [blue_screen, steps_failed],                     r18).
test(t19, blank_screen,   [blank_screen, external_display],                r19).
test(t20, blank_screen,   [blank_screen, cursor_visible],                  r20).
test(t21, blank_screen,   [blank_screen, after_update],                    r21).
test(t22, blank_screen,   [blank_screen, began_recently],                  r22).
test(t23, bluetooth,      [bluetooth_problem, bluetooth_off],              r23).
test(t24, bluetooth,      [bluetooth_problem, bt_device_not_ready],        r24).
test(t25, bluetooth,      [bluetooth_problem, after_update],               r25).
test(t26, bluetooth,      [bluetooth_problem, bt_missing_but_in_device_manager], r26).
test(t27, slow_pc,        [slow_pc, low_disk_space],                       r27).
test(t28, slow_pc,        [slow_pc, slow_startup],                         r28).
test(t29, slow_pc,        [slow_pc, many_apps_open],                       r29).
test(t30, slow_pc,        [slow_pc, suspicious_activity],                  r30).
test(t31, windows_update, [update_fails, no_stable_internet],              r31).
test(t32, windows_update, [update_fails, low_disk_space],                  r32).
test(t33, windows_update, [update_fails, wrong_date_time],                 r33).
test(t34, windows_update, [update_fails, update_error_persists],           r34).

% --- Special cases ----------------------------------------------------------
% Main symptom answered "no" -> no diagnosis
test(t35, printer,        [],                                              none).
% Symptom detail yes, but main symptom no -> no diagnosis
test(t36, sound,          [wrong_output_device],                           none).
% Main symptom yes, but no detail matches (sound has no general rule) -> none
test(t37, sound,          [no_sound],                                      none).
% Several details yes -> the more specific rule placed first wins (conflict resolution)
test(t38, printer,        [printer_not_working, printer_offline, jobs_stuck_in_queue], r13).
test(t39, slow_pc,        [slow_pc, suspicious_activity, low_disk_space],  r30).
test(t40, wifi,           [no_wifi, airplane_mode_on, after_update],       r05).


% --- Test runner -------------------------------------------------------------
run_all_tests :-
    retractall(passed(_)),
    findall(T, test(T, _, _, _), Ts),
    length(Ts, N),
    format("Running ~w test cases...~n~n", [N]),
    format("Test Category~t~22|Expected~t~32|Got~t~40|Result~n"),
    format("---------------------------------------------~n"),
    forall(test(T, C, Yes, Exp), run_one(T, C, Yes, Exp)),
    aggregate_all(count, passed(_), P),
    format("---------------------------------------------~n"),
    format("Passed ~w of ~w tests~n", [P, N]).

run_one(T, Category, YesFacts, Expected) :-
    run_test(Category, YesFacts, Got),
    (   Got == Expected
    ->  Result = 'PASS', assertz(passed(T))
    ;   Result = 'FAIL'
    ),
    format("~w  ~w~t~22|~w~t~32|~w~t~40|~w~n", [T, Category, Expected, Got, Result]).
