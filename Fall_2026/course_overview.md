# CPBP 8306 — Coding for Research (2026 Redesign)

**Instructors:** Joshua Borycz & Daniel Genkins
**TA:** Peyton Coleman
**Time:** Thursdays 10:00–10:55am, Light Hall 439
**Repo:** https://github.com/HeardLibrary/cpbp8306-dataanalysis
**Guide:** https://researchguides.library.vanderbilt.edu/cpbp8306

---

## Course philosophy

Students will use AI (ChatGPT, Copilot, Claude) to write code — that is now the reality of research computing. This course does **not** try to prevent that. Instead, it teaches the underlying *logic of coding* so that students can:

1. **Direct AI effectively** — write prompts that reflect a correct mental model of the problem.
2. **Read and evaluate AI-generated code** — catch subtle errors an LLM will produce (wrong data type, off-by-one indexing, silent NaN propagation, statistical misuse).
3. **Recognize AI's limitations** — know when the model is bluffing, hallucinating a package, or applying the wrong test.
4. **Own their analysis** — a research paper is the student's responsibility, not the model's.

The success criterion for this course is not "can you write code from scratch" but **"can you look at a block of AI-generated code and tell me what it does, whether it's correct, and how you'd fix it if it isn't."**

---

## Weekly format

Each 55-minute session:

| Time       | Activity                                                                 |
|------------|--------------------------------------------------------------------------|
| 0–5 min    | Recap + framing question                                                 |
| 5–35 min   | Concept lecture (~30 min) — see `lectures/NN_*.md`                       |
| 35–55 min  | Guided activity with a Socratic ChatGPT tutor — see `assistants_per_lecture/NN_*.md` |

**About the ChatGPT tutors:** These are custom GPTs (or Claude Projects, or any assistant with a system prompt) designed as **peer-level tutors, not answer bots**. They present problems, ask guiding questions, point students back at lecture concepts, and refuse to hand over solution code. Students should leave each activity having *earned* the answer.

There is also a parallel folder `assistants_by_unit/` with four broader unit-level tutors that span multiple lectures — useful for study, for the project, and for the final quiz.

---

## Structure — concept-first, not language-first

The 2025 syllabus alternated Python and R weekly. The 2026 version reorganizes **by concept**, teaching a topic in one language first, then showing the equivalent in the other. This lets students build one mental model and then translate it, instead of context-switching between two languages every week.

Language convention this course uses:
- **Python** is the default for early concept teaching (weeks 1–6) because errors are more explicit and syntax is simpler for beginners.
- **R** is the default for statistics and publication graphics (weeks 9–13) because that's where R's ecosystem is strongest.
- Data wrangling weeks (7–8) show both side-by-side (pandas + tidyverse) — this is the single most important skill for research.

---

## Session plan

| #  | Date       | Session title                             | Core concept                              | Unit |
|----|------------|-------------------------------------------|-------------------------------------------|------|
| 1  | 08/20/2026 | Course intro, setup, thinking like a coder | Decomposition, tools, AI's role           | 1 |
| 2  | 08/27/2026 | Variables, types, and expressions          | Everything is a typed value               | 1 |
| 3  | 09/03/2026 | Collections: lists, vectors, dictionaries  | Grouping and indexing data                | 1 |
| 4  | 09/10/2026 | Control flow: conditionals and loops       | Repetition and decisions                  | 1 |
| 5  | 09/17/2026 | Functions and modular code                 | Naming behavior, reproducibility          | 1 |
| 6  | 09/24/2026 | Projects, files, and version control       | Reproducible workflows, Git/GitHub        | 1 |
| 7  | 10/01/2026 | Dataframes and tidy data                   | The rectangle: rows = observations        | 2 |
| 8  | 10/08/2026 | *(FALL BREAK — no class)*                  | —                                         | — |
| 8  | 10/15/2026 | Data wrangling: clean, join, reshape       | Splitting-applying-combining              | 2 |
| 9  | 10/22/2026 | Exploratory data analysis                  | Look before you test                      | 2 |
| 10 | 10/29/2026 | Data visualization                         | Grammar of graphics                       | 3 |
| 11 | 11/05/2026 | Univariate statistics                      | Picking the right test                    | 3 |
| 12 | 11/12/2026 | Multivariate & introductory ML             | Dimensionality, clustering, regularization | 3 |
| —  | 11/19/2026 | Buffer / project office hours              | —                                         | — |
| —  | 11/26/2026 | *(THANKSGIVING — no class)*                | —                                         | — |
| 13 | 12/03/2026 | Presentation + advanced viz + post-test    | Communicating findings                    | 4 |

> Dates above are placeholders; adjust for the Fall 2026 Vanderbilt academic calendar. The **13 numbered sessions** are the substantive lecture weeks.

### Unit map (matches `assistants_by_unit/`)

- **Unit 1 — Foundations** (Sessions 1–6): setup, variables, structures, control flow, functions, Git.
- **Unit 2 — Data Wrangling** (Sessions 7–9): tidy data, cleaning, joining, EDA.
- **Unit 3 — Analysis** (Sessions 10–12): visualization, univariate stats, multivariate/ML.
- **Unit 4 — Synthesis** (Session 13 + project): communicating findings, publication figures, image analysis intro.

---

## Grading (from 2025 syllabus)

| Assignment                        | Points |
|-----------------------------------|--------|
| Pre-test assessment               | 10     |
| Project write-up + presentation   | 30     |
| Post-test assessment              | 10     |
| Participation (weekly activities) | 50     |
| **Total**                         | **100** |

**Participation = the weekly tutor activity.** Each week the student pastes a transcript of their ChatGPT tutor session to Brightspace. Full credit for engaging with the problems (not for reaching the "right answer"). The whole point is that the tutor makes the student wrestle with the concept.

**Project:** Same as 2025 — pick a dataset, clean it, run analyses, produce plots, write ~2 pages, present in the final session. See `lectures/13_synthesis_project_postquiz.md`.

**Final concept quiz:** See `final_quiz.md`. Short (~20 min), tests understanding of concepts and AI-collaboration judgment. Given during the final session before presentations.

---

## Dataset options

Same list carried over from 2025. Students should choose a dataset by **Session 4** and register it on Brightspace by **Session 6**.

- Policy Map — https://researchguides.library.vanderbilt.edu/az/databases/?q=policy%20map
- Our World in Data — https://ourworldindata.org/
- Statista — https://researchguides.library.vanderbilt.edu/az/databases/?q=statista
- IARC — https://gco.iarc.fr/en
- Social Explorer — https://researchguides.library.vanderbilt.edu/az/databases/?q=social%20explorer
- ICPSR — https://www.icpsr.umich.edu/web/pages/
- Google dataset search — https://datasetsearch.research.google.com/
- SEER — https://seer.cancer.gov/
- NIH-NCI GDC — https://portal.gdc.cancer.gov
- WHO GHO — https://www.who.int/data/gho/
- ATSDR — https://www.atsdr.cdc.gov/placeandhealth/index.html
- SAGE Data — https://researchguides.library.vanderbilt.edu/az/databases/?q=data%20planet

---

## File layout

```
CPBP_2026/
├── course_overview.md              ← this file
├── lectures/
│   ├── 01_intro_setup_thinking.md
│   ├── 02_variables_types.md
│   ├── 03_collections_indexing.md
│   ├── 04_control_flow.md
│   ├── 05_functions_modular.md
│   ├── 06_projects_git.md
│   ├── 07_dataframes_tidy.md
│   ├── 08_wrangling_join_reshape.md
│   ├── 09_eda.md
│   ├── 10_visualization.md
│   ├── 11_univariate_stats.md
│   ├── 12_multivariate_ml.md
│   └── 13_synthesis_project_postquiz.md
├── assistants_per_lecture/
│   └── 01–13_*_gpt.md              ← one Socratic tutor per lecture
├── assistants_by_unit/
│   ├── unit1_foundations_gpt.md
│   ├── unit2_data_wrangling_gpt.md
│   ├── unit3_analysis_gpt.md
│   └── unit4_synthesis_gpt.md
└── final_quiz.md
```
