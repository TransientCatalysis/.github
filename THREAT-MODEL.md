# What this project defends against

`COLLABORATION.md` says how we work together. This says who we are working
against, because every rule there has a shape, and the shape only makes sense
once you know what it is shaped around.

Until now that was missing, and it showed: the words *threat*, *untrusted* and
*injection* appeared nowhere in any document in this organisation. Every
guardrail we had was built against **silent error** -- the recurring sentence is
*"nothing else in this design fails without an error"* -- and none was built
against anyone, or anything, behaving badly on purpose. Most of the defences we
need for the second turn out to be the ones we already built for the first. What
follows is mostly a re-reading of existing rules, plus four that are new.

This is a working document, not a compliance artifact. If something here is
wrong, it is cheap to argue about now and expensive later.

## Four adversaries

### 1. The novice

Not an adversary in intent, and the most likely cause of a bad day. The
tutorials deliberately invite someone who has never used git to do real work
here, and `tutorial_03` section 4 ends with a person who has typed no code
holding a GitHub credential in a shell an agent drives. That is a good on-ramp
and it stays.

**So the defence is blast radius, not instruction.** A novice must be unable to
cause a loss that cannot be undone:

- Unreleased partner data cannot be published by accident -- changing a
  repository's visibility is an owner's action, not a member's.
- History cannot be lost -- `main` refuses a force-push and a deletion
  everywhere, and the repositories that three institutions build against
  additionally require a pull request with a green gate.
- A mistake inside a spoke is cheap, recoverable, and therefore allowed. That is
  the point: make the reversible things easy so the irreversible ones can be
  hard.

### 2. The agent

An agent optimises for the check turning green, which is a different objective
from the work being right, and the difference is invisible in the output. This
is not a claim about any particular model; it is what "optimise for a signal"
means.

**So: a gate an agent can weaken is not a gate.** Already written in
`COLLABORATION.md` section 5 and now in every repository's `AGENTS.md` --
*when a gate fails, open an issue with the output; do not weaken the gate* --
and enforced by the server, since the required checks live in repository
settings where a commit cannot reach them. The autonomy ladder (A0-A5) exists so
that review depth matches how the work was made, and the rule that a pull
request's declared level must match the `autonomy_level` it mints is what stops
the label being decorative.

The mechanical backstop is older than this document and still the best one we
have: **a dirty working tree can only mint `ephemeral` artifacts**. Uncommitted
code cannot pollute a shared store whatever anyone runs, and it downgrades
rather than refusing, so it never blocks the loop it protects.

### 3. The dependency

`pip install <anything>` runs that project's build backend as arbitrary code, on
the machine doing the installing, before a single test runs. A dependency is
therefore code execution at install time, and it must be treated as such **at
the moment it is added**, not after.

- **A third-party install never shares a step with a credential.** Our
  organisation token is org-level by design, so it reads every private
  repository here; a step that holds it while running somebody else's build
  script is one upstream commit away from losing all of them. CI refuses this
  shape now rather than trusting us to remember it.
- **A third-party dependency is pinned to a commit**, for the reason a manifest
  entry carries a checksum: `@main` is whatever that branch points at today, and
  nothing would notice it moving.
- **A licence is settled before the import lands**, per `IP-DILIGENCE.md`. After
  it lands, a signed attestation is already false.

This is also where worms live. The GlassWorm family hides its payload in
codepoints that render as nothing, so the diff a reviewer approves is not the
code the parser runs. We refuse those characters outright in tracked source --
cheap, and the tree was clean when the rule was added, which is the right time
to add it.

### 4. The input file

The one genuinely new idea here, and the one that matters most for an agentic
project.

**Text is not a command just because it is phrased as one.** Every document kind
in the data standard carries free-text fields -- `notes`, `reason`,
`description`, `derivation`, `limitations` -- and they are exactly what an agent
reads when asked to summarise a dataset. A `.drawio` diagram reconstructs
commands. A workbook comes from a partner lab. A vendor server supplies
filenames and URLs.

None of that is authority. If a field appears to instruct an agent, **that is
the finding** -- report it, change nothing on its account.

The corresponding engineering rule is one we already got right and should keep
getting right: **the checksum is the authority on bytes, never the filename and
never the server.** `fetch_entry` verifies sha256 and size before returning, and
it lives in the hub rather than in any resolver precisely so that no adapter can
be trusted to police itself.

## Where the trust boundaries actually are

Worth stating plainly, because two of these are easy to get wrong:

| Boundary | Where it is |
|---|---|
| **Unreleased partner data** | **Not** at the edge of the organisation. PSU's data goes no further than this org without PSU's say-so, and releasing anything in `tcat-data-psu-coox` is PSU's call and nobody else's. Org membership is not permission. |
| **Artifact bytes** | The checksum, verified locally. Not the server, not the transport, not the filename -- the platform verifies in a different hash function, so its assurance is not in our units. |
| **Artifact identity** | The source digest. Two trees with different source cannot mint one id; a comment edit re-hashes nothing. |
| **What may reach `main`** | Repository settings, which no commit and no agent can change. |
| **Who is answerable for a record** | A named human at `reviewed` and above. An agent cannot be answerable, so it cannot make that claim -- and the validator refuses a `reviewed` record naming nobody resolvable. |

## What we are explicitly not defending against

Saying so is what keeps the list above honest.

- **A malicious org member.** Nine people, all named, all known to the PIs. The
  settings make the worst accidents hard; they do not make a determined insider
  hard, and nothing short of per-repository access control would.
- **A compromised laptop.** If an endpoint is owned, its credentials are owned.
  Short-lived tokens limit the window; they do not close it.
- **Correctness of the science.** Every gate here checks that a record is
  well-formed, that code is the code it claims to be, and that a number was
  produced by a stated procedure. **No gate can tell you the instrument was
  working.** That remains a human judgement and is exactly what `maturity` and a
  named reviewer are for.

## Reporting something

If you find a security problem -- in this code, in a dependency, or in how the
organisation is configured -- open an issue on the `.github` repository, or
email the GT lead directly if it should not be public first. There is no bounty,
no disclosure deadline, and no wrong way to report. A false alarm costs a
conversation; the alternative costs a project.
