/* ==========================================================================
   PC-Doctor : Windows Troubleshooting Expert System
   FILE      : knowledge_base.pl  (KNOWLEDGE BASE)
   --------------------------------------------------------------------------
   This file contains ONLY knowledge - no reasoning code.
   It has four kinds of facts:

     1. source(ID, Title, URL)
          - the Microsoft Support pages every rule comes from.

     2. category(ID, MenuLabel)
          - the problem areas shown to the user in the menu.

     3. question(Fact, Text)
          - the yes/no question the system asks to find out whether
            Fact is true for the user's computer.

     4. rule(RuleID, Category, Conditions, Diagnosis, Action, SourceID)
          - IF all Conditions are true
            THEN the problem is Diagnosis and the fix is Action.
          - Conditions is a list of facts, e.g. [no_sound, after_update].
          - Rules inside a category are ordered from MOST SPECIFIC to
            LEAST SPECIFIC, because the inference engine tries them
            from top to bottom and stops at the first rule that fires.

   All sources accessed on 28 September 2026.
   ========================================================================== */

:- discontiguous rule/6.


/* --------------------------------------------------------------------------
   1. SOURCES
   -------------------------------------------------------------------------- */

source(s1, 'Fix sound or audio problems in Windows',
       'https://support.microsoft.com/en-us/windows/fix-sound-or-audio-problems-in-windows-73025246-b61c-40fb-671a-2535c7cd56c8').
source(s2, 'Fix Wi-Fi connection issues in Windows',
       'https://support.microsoft.com/en-us/windows/fix-wi-fi-connection-issues-in-windows-9424a1f7-6a3b-65a6-4d78-7f07eee84d2c').
source(s3, 'Fix printer connection and printing problems in Windows',
       'https://support.microsoft.com/en-us/windows/fix-printer-connection-and-printing-problems-in-windows-fb830bff-7702-6349-33cd-9443fe987f73').
source(s4, 'Resolving Blue Screen errors in Windows',
       'https://support.microsoft.com/en-us/topic/60b01860-58f2-be66-7516-5c45a66ae3c6').
source(s5, 'Troubleshooting blank screens in Windows',
       'https://support.microsoft.com/en-us/windows/hardware/display-graphics/troubleshooting-blank-screens-in-windows').
source(s6, 'Fix Bluetooth problems in Windows',
       'https://support.microsoft.com/en-us/windows/fix-bluetooth-problems-in-windows-723e092f-03fa-858b-5c80-131ec3fba75c').
source(s7, 'Tips to improve PC performance in Windows',
       'https://support.microsoft.com/en-us/windows/experience/performance-optimization/tips-to-improve-pc-performance-in-windows').
source(s8, 'Troubleshoot problems updating Windows',
       'https://support.microsoft.com/en-us/windows/troubleshoot-problems-updating-windows-188c2b0f-10a7-d72f-65b8-32d177eb136c').
source(s9, 'Free up drive space in Windows',
       'https://support.microsoft.com/en-us/windows/experience/storage-filemanagement/free-up-drive-space-in-windows').


/* --------------------------------------------------------------------------
   2. CATEGORIES (problem areas for the menu)
   -------------------------------------------------------------------------- */

category(sound,          'Sound / audio problems').
category(wifi,           'Wi-Fi / internet problems').
category(printer,        'Printer problems').
category(blue_screen,    'Blue screen (stop code) errors').
category(blank_screen,   'Blank or black screen').
category(bluetooth,      'Bluetooth problems').
category(slow_pc,        'Slow PC performance').
category(windows_update, 'Windows Update problems').


/* --------------------------------------------------------------------------
   3. QUESTIONS (one per fact used in the rules)
   -------------------------------------------------------------------------- */

% Sound
question(no_sound,                  'Is there no sound coming from your PC?').
question(wrong_output_device,       'Is the wrong (or no) output device selected in Sound settings?').
question(audio_hardware_muted_or_unplugged,
                                    'Are your speakers/headphones unplugged, powered off or muted?').
question(audio_driver_problem,      'Does your audio device show a warning in Device Manager?').

% Shared by several categories
question(after_update,              'Did the problem start after a Windows update?').
question(low_disk_space,            'Is your hard drive almost full?').

% Wi-Fi
question(no_wifi,                   'Are you unable to connect to Wi-Fi?').
question(airplane_mode_on,          'Is Airplane mode turned on?').
question(saved_network_fails,       'Does a previously saved Wi-Fi network fail to connect?').
question(no_internet,               'Are you connected to Wi-Fi but have no internet access?').
question(other_devices_fail,        'Do other devices on the same network also have no internet?').
question(other_devices_ok,          'Do other devices on the same network work normally?').

% Printer
question(printer_not_working,       'Is your printer not printing or not responding?').
question(printer_connection_problem,'Is the printer cable loose or its wireless connection down?').
question(jobs_stuck_in_queue,       'Are print jobs stuck in the print queue?').
question(printer_offline,           'Does the printer show an "Offline" status?').

% Blue screen
question(blue_screen,               'Are you getting a blue screen (stop code) error?').
question(new_hardware_added,        'Did you add new hardware before the error started?').
question(cannot_restart,            'Does the PC have trouble restarting?').
question(device_manager_warning,    'Does any device show a warning (!) in Device Manager?').
question(steps_failed,              'Does the problem continue after trying the previous steps?').

% Blank screen
question(blank_screen,              'Is your screen blank (black)?').
question(external_display,          'Are you using an external monitor or display cable?').
question(cursor_visible,            'Can you see the mouse cursor on the blank screen?').
question(began_recently,            'Did the problem begin recently (not after an update)?').

% Bluetooth
question(bluetooth_problem,         'Is a Bluetooth device not connecting / Bluetooth not working?').
question(bluetooth_off,             'Is Bluetooth turned off on your PC?').
question(bt_device_not_ready,       'Is the Bluetooth device off, uncharged or out of range?').
question(bt_missing_but_in_device_manager,
                                    'Is Bluetooth missing from Settings but shown in Device Manager?').

% Slow PC
question(slow_pc,                   'Is your PC running slowly?').
question(slow_startup,              'Does your PC take a long time to start up?').
question(many_apps_open,            'Do you have many apps or browser tabs open?').
question(suspicious_activity,       'Do you see pop-ups or unknown programs running?').

% Windows Update
question(update_fails,              'Is Windows Update failing?').
question(no_stable_internet,        'Is your internet unstable, or is the PC not plugged into power?').
question(wrong_date_time,           'Is the date or time on your PC wrong?').
question(update_error_persists,     'Does the update still fail although internet, space and date/time are fine?').


/* --------------------------------------------------------------------------
   4. RULES
      rule(ID, Category, [Conditions], Diagnosis, Action, Source)
   -------------------------------------------------------------------------- */

% ---------------- SOUND  (Source S1) ----------------

% R01 - S1: "Check your speaker output in Windows settings" / "Set default audio device"
rule(r01, sound, [no_sound, wrong_output_device],
     'Audio output device is misconfigured',
     'Open Settings > System > Sound and select the correct default output device.',
     s1).

% R02 - S1: "Check your audio hardware and volume controls"
rule(r02, sound, [no_sound, audio_hardware_muted_or_unplugged],
     'Audio hardware connection or volume issue',
     'Check the cables, speaker power and volume/mute controls.',
     s1).

% R03 - S1: "If you have audio issues after installing updates, try rolling back your audio driver"
rule(r03, sound, [no_sound, after_update],
     'Audio driver is incompatible after a Windows update',
     'Roll back the audio driver in Device Manager.',
     s1).

% R04 - S1: "Update or reinstall audio drivers"
rule(r04, sound, [no_sound, audio_driver_problem],
     'Outdated or corrupt audio driver',
     'Update, or uninstall and reinstall, the audio driver in Device Manager.',
     s1).

% ---------------- WI-FI  (Source S2) ----------------

% R05 - S2: "Step 2. Check Airplane Mode"
rule(r05, wifi, [no_wifi, airplane_mode_on],
     'Wireless radios are disabled by Airplane mode',
     'Turn Airplane mode off and make sure Wi-Fi is turned on.',
     s2).

% R09 - S2: "Step 8. Uninstall the network adapter driver and restart"
%       (placed before R06 because it is more specific)
rule(r09, wifi, [no_wifi, after_update],
     'Network adapter driver problem after a recent update',
     'Uninstall the network adapter driver in Device Manager and restart the PC.',
     s2).

% R06 - S2: "Step 3. Forget and reconnect to the Wi-Fi Network"
rule(r06, wifi, [no_wifi, saved_network_fails],
     'Saved Wi-Fi network profile problem',
     'Forget the network, then reconnect and enter the password again.',
     s2).

% R07 - S2: "Step 4. Restart your modem and wireless router"
%       + "Step 6. Try to connect to the same network on a different device"
rule(r07, wifi, [no_internet, other_devices_fail],
     'Router or modem problem (not the PC)',
     'Restart the modem and wireless router (unplug, wait, plug back in).',
     s2).

% R08 - S2: "Step 7. Run network commands"
rule(r08, wifi, [no_internet, other_devices_ok],
     'Network configuration problem on this PC',
     'Run in an admin Command Prompt: netsh winsock reset, netsh int ip reset, ipconfig /release, ipconfig /renew, ipconfig /flushdns.',
     s2).

% ---------------- PRINTER  (Source S3) ----------------

% R13 - S3: "Step 6. Change a printer's status to online"
rule(r13, printer, [printer_not_working, printer_offline],
     'Printer is set to Offline',
     'Change the printer status to "online" in Settings > Bluetooth & devices > Printers & scanners.',
     s3).

% R12 - S3: "Step 5. Clear and reset the print spooler"
rule(r12, printer, [printer_not_working, jobs_stuck_in_queue],
     'Print spooler problem',
     'Clear and reset the print spooler service.',
     s3).

% R11 - S3: "Step 2. Check cables or wireless connection"
rule(r11, printer, [printer_not_working, printer_connection_problem],
     'Printer connection problem',
     'Check the USB cable or the printer wireless connection.',
     s3).

% R10 - S3: "Step 1. Unplug and restart your printer"
%       (general rule - placed LAST in this category)
rule(r10, printer, [printer_not_working],
     'Printer is in a stuck state',
     'Turn off and unplug the printer, wait 30 seconds, then plug it in and turn it on.',
     s3).

% ---------------- BLUE SCREEN  (Source S4, S9) ----------------

% R14 - S4: "Remove any new hardware"
rule(r14, blue_screen, [blue_screen, new_hardware_added],
     'Newly added hardware is causing the stop error',
     'Remove the new hardware and restart the PC.',
     s4).

% R15 - S4: "Start your PC in safe mode"
rule(r15, blue_screen, [blue_screen, cannot_restart],
     'Windows cannot start normally',
     'Start the PC in Safe Mode to continue troubleshooting.',
     s4).

% R16 - S4: "Check the Device Manager"
rule(r16, blue_screen, [blue_screen, device_manager_warning],
     'Faulty device driver',
     'Open Device Manager and update the driver of the device marked with (!).',
     s4).

% R17 - S4: "Check for sufficient free space on the hard drive" (see also S9)
rule(r17, blue_screen, [blue_screen, low_disk_space],
     'Insufficient free disk space',
     'Free up space on the hard drive (Settings > System > Storage).',
     s4).

% R18 - S4: "Restore Windows" - "If none of these steps help"
rule(r18, blue_screen, [blue_screen, steps_failed],
     'Persistent system problem',
     'Restore Windows using System Restore or the recovery options.',
     s4).

% ---------------- BLANK SCREEN  (Source S5) ----------------

% R20 - S5: "4. Restart Windows Explorer" (if the cursor is visible)
rule(r20, blank_screen, [blank_screen, cursor_visible],
     'Windows Explorer has stalled',
     'Press Ctrl+Shift+Esc, find Windows Explorer and select Restart (or run explorer.exe).',
     s5).

% R19 - S5: "1. Check Hardware Connections"
rule(r19, blank_screen, [blank_screen, external_display],
     'Display connection problem',
     'Check the cables, try another monitor or cable; on a laptop disconnect external displays.',
     s5).

% R21 - S5: "3. Update or Roll Back Graphics Drivers" (roll back if after an update)
rule(r21, blank_screen, [blank_screen, after_update],
     'Graphics driver problem after an update',
     'Boot into Safe Mode and roll back the graphics driver in Device Manager.',
     s5).

% R22 - S5: "5. Perform a System Restore" (if the issue began recently)
rule(r22, blank_screen, [blank_screen, began_recently],
     'A recent system change caused the problem',
     'Perform a System Restore to a restore point before the problem started.',
     s5).

% ---------------- BLUETOOTH  (Source S6) ----------------

% R23 - S6: "Step 2. Make sure Bluetooth is turned on"
rule(r23, bluetooth, [bluetooth_problem, bluetooth_off],
     'Bluetooth is disabled on the PC',
     'Turn Bluetooth on (also check the physical switch on laptops).',
     s6).

% R24 - S6: "Step 3. Check your Bluetooth device"
rule(r24, bluetooth, [bluetooth_problem, bt_device_not_ready],
     'Bluetooth device is not ready',
     'Turn on and charge the device, put it in pairing mode and bring it within range.',
     s6).

% R26 - S6: "Step 8. Uninstall the Bluetooth adapter in Device Manager"
rule(r26, bluetooth, [bluetooth_problem, bt_missing_but_in_device_manager],
     'Bluetooth adapter is not loaded properly',
     'Uninstall the Bluetooth adapter in Device Manager and restart the PC.',
     s6).

% R25 - S6: "Step 7. Make sure you have the latest drivers" (after an upgrade/update)
rule(r25, bluetooth, [bluetooth_problem, after_update],
     'Outdated or incompatible Bluetooth driver',
     'Install the latest Bluetooth drivers (Device Manager or Windows Update).',
     s6).

% ---------------- SLOW PC  (Source S7, S9) ----------------

% R30 - S7: "Run a malware scan to detect and remove threats that slow PC performance"
rule(r30, slow_pc, [slow_pc, suspicious_activity],
     'Possible malware infection',
     'Run a full malware scan (Windows Security) and remove any threats.',
     s7).

% R27 - S7: "Free up disk space to boost PC performance" (see also S9)
rule(r27, slow_pc, [slow_pc, low_disk_space],
     'Low disk space is reducing performance',
     'Free up disk space using Storage Sense or Cleanup recommendations.',
     s7).

% R28 - S7: "Disable startup apps to reduce the background activity"
rule(r28, slow_pc, [slow_pc, slow_startup],
     'Too many startup apps',
     'Disable unnecessary startup apps (Task Manager > Startup apps).',
     s7).

% R29 - S7: "Close unused apps and restart your PC"
rule(r29, slow_pc, [slow_pc, many_apps_open],
     'Too many open apps are using resources',
     'Close unused apps and browser tabs, then restart the PC.',
     s7).

% ---------------- WINDOWS UPDATE  (Source S8, S9) ----------------

% R31 - S8: "Step 2: Verify that your device is properly plugged in and connected to the Internet"
rule(r31, windows_update, [update_fails, no_stable_internet],
     'Update cannot download or install',
     'Plug the device into power and connect to a stable internet connection.',
     s8).

% R32 - S8: "Step 8. Free up some space so you can run updates" (16 GB / 20 GB)
rule(r32, windows_update, [update_fails, low_disk_space],
     'Not enough free space for the update',
     'Free up drive space (at least 20 GB on 64-bit Windows) and run Windows Update again.',
     s8).

% R33 - S8: "Step 6. Verify Date and Time settings"
rule(r33, windows_update, [update_fails, wrong_date_time],
     'Incorrect date and time settings',
     'Correct the date and time in Settings > Time & language.',
     s8).

% R34 - S8: "Step 5. Clear the Windows Update Cache"
rule(r34, windows_update, [update_fails, update_error_persists],
     'Corrupt update files in the Windows Update cache',
     'Clear the Windows Update cache and run Windows Update again.',
     s8).


/* --------------------------------------------------------------------------
   5. KNOWLEDGE BASE CHECK (helper for the developer)
      Run  ?- kb_check.   to make sure every condition has a question,
      every rule has a valid category and source.
   -------------------------------------------------------------------------- */

kb_check :-
    findall(R, rule(R,_,_,_,_,_), Rules),
    length(Rules, N),
    format("Rules loaded: ~w~n", [N]),
    forall(( rule(R,_,Conds,_,_,_), member(C, Conds), \+ question(C,_) ),
           format("  WARNING: ~w uses ~w but it has no question~n", [R, C])),
    forall(( rule(R,Cat,_,_,_,_), \+ category(Cat,_) ),
           format("  WARNING: ~w has unknown category ~w~n", [R, Cat])),
    forall(( rule(R,_,_,_,_,S), \+ source(S,_,_) ),
           format("  WARNING: ~w has unknown source ~w~n", [R, S])),
    format("Check finished.~n").
