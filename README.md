# PC-Doctor: Windows Troubleshooting Expert System

A rule-based expert system written in **SWI-Prolog** that diagnoses common Windows PC problems.
It asks the user yes/no questions, uses **backward chaining** to find the matching rule, and gives a
diagnosis and a recommended fix. It can also explain its reasoning (**WHY** and **HOW**).

All **34 rules** come from official **Microsoft Support** troubleshooting articles (see [Knowledge sources](#knowledge-sources)).

> Module: Logic Programming and Artificial Cognitive Systems
> Student: T. M. H. M. Yatigammana | Student ID: 224222K

---

## Features

- 8 problem areas: sound, Wi-Fi/internet, printer, blue screen, blank screen, Bluetooth, slow PC, Windows Update
- 34 IF-THEN rules, each linked to its Microsoft Support source
- Asks only the questions it needs and never asks the same question twice (working memory)
- **WHY**: type `why` at any question to see which rule is being tested
- **HOW**: after a diagnosis, shows which rule fired, your answers and the source URL
- Menu options to list all rules and all knowledge sources
- 40 automated test cases

---

## 1. Requirements

| Software   | Version                         | Download                                   |
| ---------- | ------------------------------- | ------------------------------------------ |
| SWI-Prolog | 9.x or later (tested on 10.0.2) | https://www.swi-prolog.org/download/stable |

Works on Windows, macOS and Linux. No other software is needed.

---

## 2. Installation

1. **Install SWI-Prolog**
   - Download the installer for your operating system from the link above.
   - Windows: run the installer and tick **"Add swipl to the system PATH"** when asked.
   - Check it works by opening a terminal and typing:
     ```
     swipl --version
     ```

2. **Download this project**
   - On this GitHub page click **Code → Download ZIP**, then extract the ZIP file,
   - or, if you use Git:
     ```
     git clone <this-repository-URL>
     ```

---

## 3. How to run

1. Open a terminal **inside the project folder** (the folder that contains `main.pl`).
   - Windows tip: open the folder in File Explorer, click the address bar, type `cmd` and press Enter.
2. Start the system:
   ```
   swipl main.pl
   ```
3. The main menu appears:

   ```
   ==============================================================
      PC-DOCTOR : Windows Troubleshooting Expert System
      Knowledge source: Microsoft Support (34 rules)
   ==============================================================

     What problem does your Windows PC have?

        1. Sound / audio problems
        2. Wi-Fi / internet problems
        3. Printer problems
        4. Blue screen (stop code) errors
        5. Blank or black screen
        6. Bluetooth problems
        7. Slow PC performance
        8. Windows Update problems

        9. Explain last diagnosis (HOW)
       10. Show all rules
       11. Show knowledge sources
        0. Exit

     Enter your choice:
   ```

4. Type a number and press **Enter**.
5. Answer each question with **`yes`** (or `y`), **`no`** (or `n`), or **`why`** (or `w`) to see why the question is asked.
6. After the result, press **Enter** to return to the menu. Choose **0** to exit.

### Example session

```
  Enter your choice: 3

=== Printer problems ===
  Is your printer not printing or not responding? (yes/no/why): yes
  Does the printer show an "Offline" status? (yes/no/why): no
  Are print jobs stuck in the print queue? (yes/no/why): yes

  ------------------------------------------------------------
  DIAGNOSIS      : Print spooler problem
  RECOMMENDATION : Clear and reset the print spooler service.
  RULE / SOURCE  : R12 - Microsoft Support: Fix printer connection and printing problems in Windows
  ------------------------------------------------------------

  Enter your choice: 9

  [HOW] The conclusion was reached by rule R12:
        IF
          - Is your printer not printing or not responding?  [yes]
          - Are print jobs stuck in the print queue?  [yes]
        THEN Print spooler problem

        Source S3: Fix printer connection and printing problems in Windows
        https://support.microsoft.com/en-us/windows/fix-printer-connection-and-printing-problems-in-windows-fb830bff-7702-6349-33cd-9443fe987f73

        Rules ruled out by your 'no' answers: R13
```

### Other scenarios to try

| Menu             | Answers      | Expected diagnosis                                  |
| ---------------- | ------------ | --------------------------------------------------- |
| 7 (Slow PC)      | yes, yes     | Possible malware infection (R30)                    |
| 4 (Blue screen)  | yes, no, yes | Windows cannot start normally (R15)                 |
| 2 (Wi-Fi)        | yes, yes     | Wireless radios are disabled by Airplane mode (R05) |
| 5 (Blank screen) | yes, yes     | Windows Explorer has stalled (R20)                  |

---

## 4. Running the automated tests

```
swipl -g run_all_tests -t halt tests.pl
```

This runs 40 test cases (one for each rule plus special cases) and should end with:

```
Passed 40 of 40 tests
```

### Test results

**Automated tests: 40 of 40 passed** (T01–T34 one per rule, T35–T37 no-diagnosis cases, T38–T40 conflict resolution).

**Interactive tests (run through `main.pl`): 11 of 11 as expected**

| ID     | What is tested                                | Input                   | Result                                      |
| ------ | --------------------------------------------- | ----------------------- | ------------------------------------------- |
| TC-I01 | Diagnosis + WHY (printer)                     | 3 → yes, why, no, yes   | R12 Print spooler problem ✔                 |
| TC-I02 | HOW explanation                               | 9                       | Shows R12, answers, source, R13 ruled out ✔ |
| TC-I03 | Diagnosis (slow PC)                           | 7 → yes, yes            | R30 Possible malware infection ✔            |
| TC-I04 | Rule skipped by a "no" (blue screen)          | 4 → yes, no, yes        | R15 Windows cannot start normally ✔         |
| TC-I05 | No rule matches (sound)                       | 1 → yes, no, no, no, no | "No rule matched your answers" ✔            |
| TC-I06 | Working memory: no repeated questions (Wi-Fi) | 2 → no, no              | Only 2 questions asked, then no diagnosis ✔ |
| TC-I07 | Invalid answer                                | 3 → maybe               | "Please type yes, no or why:" ✔             |
| TC-I08 | Invalid menu choice                           | abc                     | "Invalid choice…" ✔                         |
| TC-I09 | List all rules                                | 10                      | 34 rules listed ✔                           |
| TC-I10 | List sources                                  | 11                      | 9 Microsoft Support URLs ✔                  |
| TC-I11 | Exit                                          | 0                       | "Goodbye!" ✔                                |

Full test tables: [`docs/Test_Cases.xlsx`](docs/Test_Cases.xlsx).

---

## 5. Project structure

| File                                      | Role                                                                                            |
| ----------------------------------------- | ----------------------------------------------------------------------------------------------- |
| `main.pl`                                 | **User interface**: menu, reading choices, listing rules and sources. Start here.               |
| `engine.pl`                               | **Inference engine**: backward chaining, asking questions, working memory, WHY/HOW explanations |
| `knowledge_base.pl`                       | **Knowledge base**: 34 rules, 37 questions, 8 categories, 9 sources                             |
| `tests.pl`                                | 40 automated test cases                                                                         |
| `docs/Windows_Troubleshooting_Rules.xlsx` | Rule table with the source section for every rule                                               |
| `docs/Test_Cases.xlsx`                    | Test case tables                                                                                |
| `docs/diagrams/`                          | Architecture, inference flowchart and decision-path diagrams                                    |

### How a rule is written

```prolog
% R14 - S4: "Remove any new hardware"
rule(r14, blue_screen, [blue_screen, new_hardware_added],
     'Newly added hardware is causing the stop error',
     'Remove the new hardware and restart the PC.',
     s4).
```

Read as: **IF** `blue_screen` **AND** `new_hardware_added` **THEN** the diagnosis is _"Newly added hardware is
causing the stop error"_; source **S4**. Rules in each category are ordered from most specific to most general,
and the first rule whose conditions are all true fires.

---

## 6. Knowledge sources

All rules were taken from these Microsoft Support articles (accessed 28 September 2026):

| ID  | Article                                                                                                                                                                                             |
| --- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| S1  | [Fix sound or audio problems in Windows](https://support.microsoft.com/en-us/windows/fix-sound-or-audio-problems-in-windows-73025246-b61c-40fb-671a-2535c7cd56c8)                                   |
| S2  | [Fix Wi-Fi connection issues in Windows](https://support.microsoft.com/en-us/windows/fix-wi-fi-connection-issues-in-windows-9424a1f7-6a3b-65a6-4d78-7f07eee84d2c)                                   |
| S3  | [Fix printer connection and printing problems in Windows](https://support.microsoft.com/en-us/windows/fix-printer-connection-and-printing-problems-in-windows-fb830bff-7702-6349-33cd-9443fe987f73) |
| S4  | [Resolving Blue Screen errors in Windows](https://support.microsoft.com/en-us/topic/60b01860-58f2-be66-7516-5c45a66ae3c6)                                                                           |
| S5  | [Troubleshooting blank screens in Windows](https://support.microsoft.com/en-us/windows/hardware/display-graphics/troubleshooting-blank-screens-in-windows)                                          |
| S6  | [Fix Bluetooth problems in Windows](https://support.microsoft.com/en-us/windows/fix-bluetooth-problems-in-windows-723e092f-03fa-858b-5c80-131ec3fba75c)                                             |
| S7  | [Tips to improve PC performance in Windows](https://support.microsoft.com/en-us/windows/experience/performance-optimization/tips-to-improve-pc-performance-in-windows)                              |
| S8  | [Troubleshoot problems updating Windows](https://support.microsoft.com/en-us/windows/troubleshoot-problems-updating-windows-188c2b0f-10a7-d72f-65b8-32d177eb136c)                                   |
| S9  | [Free up drive space in Windows](https://support.microsoft.com/en-us/windows/experience/storage-filemanagement/free-up-drive-space-in-windows)                                                      |

---

## 7. Troubleshooting

| Problem                                     | Solution                                                                                                                                             |
| ------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| `'swipl' is not recognized`                 | SWI-Prolog is not on the PATH. Reinstall and tick "Add to PATH", or run it with the full path, e.g. `"C:\Program Files\swipl\bin\swipl.exe" main.pl` |
| `source_sink 'main.pl' does not exist`      | The terminal is not in the project folder. Use `cd` to go to the folder that contains `main.pl`.                                                     |
| Nothing happens after typing a Prolog query | Prolog queries must end with a full stop (`.`). Menu choices and yes/no answers do **not** need one.                                                 |
