# Working together here

Who owns what, how a repository changes hands, what a pull request has to carry,
and how to coach an agent working in these repositories.

Normative for every `tcat-*` repository. Where a repository's own
`CONTRIBUTING.md` says something more specific, that wins.

---

## 1. Who owns what

**The `stewards` block in `.tcat-spoke.json` is the single source of truth**, and
`.github/CODEOWNERS` is *generated* from it by `tcat-spoke codeowners`. Never edit
CODEOWNERS by hand; CI fails if you do.

The reason is not tidiness. Ownership recorded in two places diverges, and the
copy that is wrong is always the one nobody is looking at.

| Role | What it means in practice |
|---|---|
| `data_steward` | Answers for the records. Merges. |
| `instrument_owner` | **Must** review anything touching a calibration or a sensor model. |
| `analysis_owner` | Answers for the code in an analysis spoke. |
| `pi` | Escalation. Not a day-to-day reviewer. |

`instrument_owner` is the one that carries weight: the MS sensor model is the
Rioux lab's to approve and the XAS model is Frenkel's — *"reviewed by whoever
owns the instrument, not by whoever is available"* (`PROMOTION.md`). The
generated CODEOWNERS gives that person the `calibrations/` directory, which is
what turns the sentence into a review GitHub will require.

`credit_roles` is a **separate** question from `role`, and uses CRediT
(ANSI/NISO Z39.104-2022). Conflating *who do I email when the calibration is
wrong* with *who goes on the paper* gets both wrong.

## 2. Handing a spoke to somebody else

The graduating-student problem, which is the actual failure mode in an academic
group. Do this while the person leaving still cares:

1. **They** open the PR adding the successor to `stewards`.
2. Regenerate CODEOWNERS in the same PR (`tcat-spoke codeowners`). CI enforces it.
3. Write `.tcat/HANDOVER.md`: what runs, what is broken, what is uncommitted,
   which store paths matter, and **which results are cited anywhere** — a paper,
   a slide, the meeting doc.
4. **The successor runs the spoke's gate from a clean checkout on their own
   machine.** This is the only real test of a handover and it is the step that
   fails. Handover is not done until it passes.
5. Update the hub declaration's `implementations[].notes`, or downgrade its
   `status` to `sandbox` or `abandoned` per `PROMOTION.md`. **Never delete or edit
   the artifacts it produced** — their ids are how published results are traced.
6. Set `until` on the departing steward rather than removing them. A name that has
   gone stale while still looking answered is worse than an absent one.

## 3. Pull requests, and agent-driven work

Every PR states its **autonomy level**. Do not invent a scale: `autonomy_level`
already exists as a required field on datasets and provenance records, pinned to
TRACE-AI v2.2.0. Read for a pull request:

| | |
|---|---|
| **A0** | A human wrote every line. |
| **A1** | Agent suggested; a human edited and understands each hunk. |
| **A2** | Agent wrote it; a human read all of it **and ran it**. |
| **A3** | Agent wrote it; a human read the diff summary only. |
| **A4–A5** | **Not mergeable here** without a named reviewer who has run it. |

**The rule that makes this more than a label:** the autonomy level a PR declares
and the `autonomy_level` stamped into any provenance record it produces must
agree. A PR claiming A1 that mints A3 artifacts is a defect.

Review depth follows: A0–A1 normal; A2 the reviewer runs it; A3 and above the
reviewer runs it *and* a second steward reads the diff.

A PR also carries:

- **"I ran this."** The command and its output. Not "tests pass".
- **The hashing question, first.** *Does this change what any tool outputs? Which
  parameters, and are they hashed?* This is the field a reviewer should look at
  before anything else.
- **Provenance hygiene.** Any artifact id quoted in the body: which store, and was
  `git_sha` `dirty`? A dirty sha disqualifies from promotion.
- **Blast radius.** Which spokes have to do something. "None" is the preferred
  answer.

## 4. Branch protection, and the rights you do not have

Both setup guides used to say "make it a required status check" and neither said
how — and the person creating a spoke is exactly the person without org-admin
rights.

**You should not have to arrange it.** The org applies a ruleset to `tcat-*`
repositories requiring the gate job. If `main` in your repository is unprotected,
**open an issue on the `.github` repository** rather than hunting through settings.

Two consequences worth knowing:

- The ruleset names the **job**, so the gate job is called `validate` in data
  spokes and `conform` in analysis spokes, in every repository. **Renaming that
  job silently ungates the repository**, with no error anywhere.
- CODEOWNERS is advisory unless "Require review from Code Owners" is on. That is
  part of the ruleset, not something a script can enforce.

### The hub token

`tcat-analysis` is private, and a workflow's automatic `GITHUB_TOKEN` is scoped to
the repository it runs in — it cannot read another private repo in the same org,
on any plan, however many people are members. Spoke CI therefore needs an
**organisation-level** secret, `TCAT_HUB_TOKEN`, with read access to the org's
repositories.

Organisation-level, deliberately: a new spoke inherits it with no setup. Every
analysis-side workflow already reads it and fails with an actionable message when
it is absent. When the hub goes public the secret can be deleted and nothing else
changes.

## 5. Coaching an agent in these repositories

Most work here now involves an agent, so this is a section rather than a footnote.

**First instruction, in any of these repositories: read `./CLAUDE.md` and the
normative document it names.** Otherwise the agent will break a local invariant
that no test covers until CI — and some of them are not covered at all.

**An agent does not do these without a human saying so, in writing, in the PR:**

- push to `main`
- edit `stewards` or `.github/CODEOWNERS`
- add a capability name (it is hashed into artifact ids, and two spokes minting
  one name for different procedures collide on a single id with **no error
  anywhere**)
- flip a `hashed: true` to `false`
- bump `standard_version` or a schema version
- delete or edit an artifact
- touch anything under a `raw/` directory
- change repository settings or branch protection
- add an `xfail` or a skip to a failing gate

**And one an agent must do rather than avoid:** if a change alters what a tool
outputs, bump the spoke's `__version__` and re-run `tcat-spoke fingerprint`. The
version is hashed into every artifact id, so without the bump the store keeps
serving pre-change results under ids that look correct. CI fails when `src/`
changed and the version did not — the message tells you which of the two honest
answers applies.

### One bump per landing, and which digit

The rule above says a bump is needed. It does not say how often, and answering
"once per change" is how one spoke went **0.1.0 to 0.10.2 in five days**, three
of those numbers stamped in a working tree and never committed — so no tree
anybody could check out was ever at two of them.

**Bump in the commit that LANDS the work, once, however many changes it
contains.** A version is not a changelog. What it has to be is a name for a
state of the source somebody else can obtain.

**While you are iterating, change the STORE, not the version.** This is the
substitution that removes most of the pressure. A mid-work bump is almost always
being used to buy isolation from your own earlier results — and a fresh
`--store` gives that for free, immediately, without re-hashing every artifact in
the project or invalidating a colleague's cache. The fingerprint check is what
catches a bump you forgot at landing time, so a bump you make early buys nothing
that a directory does not.

Which digit, given that EVERY bump re-hashes and the mechanism is identical for
all three — so the size of the increment is free to carry meaning:

| | when |
|---|---|
| **patch** | the default. The output changed, the CONTRACT did not: bug fixes, numerical corrections, a field added to a report. Anything written against the previous version still runs and still means what it meant. |
| **minor** | the surface a caller can INVOKE grew: a new hashed parameter, a new tool, a new accepted solver or criterion value, a new artifact kind. Hashed parameters *are* the contract surface, so this is the same boundary drawn twice. |
| **major** | a break: a parameter removed, an artifact kind renamed, or an existing hashed value changing meaning. |

Reserve the changelog for what changed. Spend the version on what it is.

### Two agents, one repository

Two sessions in one working copy is now the normal case, and it has a specific
failure that no amount of care prevents: **the version is a property of the
TREE, and the work is a property of a SESSION.** One session's commit landing
mid-run forked the other's store — 30 artifacts at one version and 1 at another,
inside a single provenance chain, with nothing saying so. On another day, four
notebooks were built against three different source states all stamped with the
same version number.

Four rules, in order of how much they buy:

1. **One session, one worktree, one store.** `git worktree add` per session,
   pinned to a commit, with `TCAT_STORE` named after it. This is the only thing
   here that PREVENTS the fork rather than detecting it, and the session that
   did it was structurally immune. The other three rules exist because a session
   deliberately holding uncommitted work cannot use it.
2. **Never edit the analysis hub from a spoke session.** `git_sha()` reads the
   hub, so a dirty hub refuses every notebook build in every spoke — including
   builds that do not depend on what you changed. Hub edits get their own
   session and land as a commit before spoke work resumes.
3. **Announce before you bump, and before you commit into a shared tree.** A
   social rule, so it fails the first time somebody forgets — which is why it is
   third and not first. Keep a message channel open between concurrent
   long-running sessions by default, not only once something has collided.
4. **Read the other session's tree before you disagree with it.** On the one
   occasion each session went looking at the other's working copy, each found
   the other's latent bug and neither had found its own.

The mechanical backstops, for when the rules above are not available: a
notebook builder records the source fingerprint at the start and refuses to
write its exhibit if the source moved during the run, and refuses to start at
all while the hub's tree is dirty or the spoke's `__version__` does not describe
its own source. None of these prevents anything. They convert a silent
corruption into a loud refusal, which is the difference between finding out now
and quoting it at a meeting.

**Develop disconnected.** Use `sandbox/` or a scratch store (`--store /tmp/...`)
until the numbers are believed. A registry full of results nobody stands behind
is as bad as no registry, and an agent asked to iterate on a fit will otherwise
run it against whatever store it finds. One guarantee is automatic: a **dirty
working tree can only mint `ephemeral` artifacts**, which are never registered
and never synced — so uncommitted code cannot pollute a shared store whatever
you run. `PROMOTION.md` has the four levels.

**When a gate fails, the agent opens an issue with the output. It does not weaken
the gate.** Three temptations this project has already had to defend against, by
name: relaxing `tcat-conform`; relaxing `compile_axial_integrator`'s Courant
refusal (fragile point 17 says in terms *"do not relax that check to 'just try
it'"*); and "simplifying" the stdin-only-on-`--in -` rule, which has a regression
test and an explicit note not to.

**Never hand-write a provenance record.** A record that is sometimes accurate is
worse than none, because it invites trust it has not earned.

**`tcat-tools show <tool> --json` is the agent's interface to the contract.** It
carries `when_to_use`, `when_not_to_use`, and cost. Point at it rather than
inventing a second description of the same thing.

## 6. Who reviews what

| A change touching | Reviewer | Where the name comes from |
|---|---|---|
| a sensor model or calibration | **instrument owner** | `stewards[].role == "instrument_owner"` in the data spoke |
| a hashed parameter, or a capability name | a hub maintainer | `tcat-analysis` CODEOWNERS |
| a schema | data-hub maintainer **plus a steward from a spoke that would have to change** | `tcat-data-standard` CODEOWNERS + that spoke's `stewards` |
| a fitting method inside one spoke | that spoke's maintainer | spoke CODEOWNERS |
| the registry, or `_common.py` | index maintainer | `tcat-index` CODEOWNERS |
