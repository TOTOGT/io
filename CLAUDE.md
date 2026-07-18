# CLAUDE.md — TOTOGT/io (CatGT / zeolite selectivity)

Primes any future session (Claude or otherwise) working in this repo. Read
this before touching `README.md`, `.github/workflows/verify-proofs.yml`, or
any `.lean` file here.

## Standing rule: keep README.md in sync, every time

`README.md`'s "Key results" tables and "Source" section are a claim about
what the Lean kernel has actually checked. Whenever a theorem statement,
`sorry` count, or file layout changes in `CatGT/`, `PrincipiaOrthogona1/`,
or `zeolite_operator_order/`, update `README.md` in the SAME commit (or
immediately after) — do not let it describe a prior state of the code.
Concretely:

- If a theorem's statement changes (restated, weakened, params dropped),
  update its row in the Key Results table to match what's actually proved.
- If a `sorry` is added or removed, update the "open · N sorries" /
  "closed · 0 sorry" status for that row.
- If a new `.lean` file is wired into `lakefile.toml`, add it to the
  Source section and its own Key Results table if it has citable theorems.
- If `.github/workflows/verify-proofs.yml` changes what it gates or
  prints, make sure the "Build" section's prose still describes it
  accurately (see the `#print axioms` note below — this claim was false
  in README for a while because the workflow step it referred to had been
  silently dropped).

This was violated at least once already (2026-07-11): README claimed CI
"prints the axiom dependencies of each theorem" after that step had been
removed from the workflow (likely during the "stray Lean source"
incident — see the workflow file's own header comment), and it never
mentioned the zeolite-selectivity theorems at all despite them being the
repo's stated worked instance. Don't let README drift from the code again.

## Standing rule: don't trust "0 sorry" by eye

A theorem with no literal `sorry` in its own tactic block can still be
open — it can call something else that has a `sorry`, or worse, its
whole build can be hiding a real located Lean error behind a non-gating
CI step (this happened twice with `ZeoliteProofs`: once for a false
theorem statement, once for a missing `MeasurableSpace` instance that sat
in "green" CI runs for a full day because the step was non-gating). Two
concrete checks, not just a grep for the word `sorry`:

1. Is the CI step for this target actually gating (no
   `continue-on-error: true`, or an explicit error-grep like
   `ZeoliteProofs`'s)? If not, a "passing" run proves nothing.
2. Does `#print axioms <theorem>` show only Mathlib's standard axioms
   (`propext`, `Classical.choice`, `Quot.sound`), or does it also show
   `sorryAx`? The latter means the theorem is open even with zero
   `sorry` text in its own body. `verify-proofs.yml` runs this for every
   theorem in `CatGT`, `Theorem53`, and `ZeoliteProofs` on every push —
   read the CI log, don't re-derive this by eye.

## Repo layout gotcha: no duplicate files at root

`CatGT_PROOFS_COMPLETE.lean` and `CatGT_v2.lean` used to exist BOTH at the
repo root AND under `zeolite_operator_order/` (identical content, stale
duplicates — removed 2026-07-11, commits `c384443` / `7e79e77`). Only the
copies under `zeolite_operator_order/` are wired into `lakefile.toml` and
actually built by CI. If a root-level copy of either file ever reappears
(e.g. from a careless drag-and-drop upload), it's dead weight that will
silently diverge from the real, built version — delete it, don't edit it.

## `io/` folder: sensitive, not repo-related content

`io/NOTES.md` and `io/NJIT.md` are drafts of an unrelated DOE SBIR grant
application (G6 LLC, Phase I), not part of the CatGT/Lean project. As of
2026-07-11 they also contradict each other on a material fact (one
describes an NJIT subaward/collaboration, the other says the work is
"entirely solo" with a separate Brazilian-collaborator angle) and one
carries an internal note saying "delete before submission." Do not edit,
reference, or build on these files as part of any CatGT/Lean task — they
are out of scope for this repo's stated purpose and their public
presence here is the owner's call, not something to change unprompted.

## CI structure (verify-proofs.yml)

- `Theorem53`: **fully isolated** — its own `leanprover/lean-action@v1`
  invocation (`build-args: "Theorem53"` only), own `id`, own
  `continue-on-error: true` + explicit "Fail workflow if Theorem53 did
  not build" gate, own `#print axioms` step gated on its own success.
  Nothing about its pass/fail status can be affected by CatGT,
  ZeoliteProofs, or anything else in this job. This is deliberate: this
  repo exists to give Theorem 5.3 (Non-Commutativity) a clean citation
  target isolated from AXLE/PrincipiaVol1's legacy breakage (see the
  file's own header), and the whole point is lost if its CI badge is
  entangled with some other target's health.
- `CatGT`: same independent pattern (own `lean-action@v1` invocation,
  own id, own gate, own axiom-print) — separated from `Theorem53` on
  2026-07-12. Before that they were built together in one combined
  `lean-action@v1` step, which meant a CatGT break would silently
  prevent Theorem53's own axiom-print from ever running even though
  Theorem53 itself was fine.
- `ZeoliteProofs`: gating on real, located Lean errors only (grep for
  `error: path:line:col:` in the build log) — a plain nonzero exit from
  `lake build` because of `sorry`s is expected and NOT a failure. Also
  followed by an informational `#print axioms` step, gated on that
  build step's own success.
- `ZeoliteV2Stub`: fully non-gating, expected to fail outright (explicit
  stub, every body is `sorry`). No axiom-printing — there's nothing to
  check.

As of 2026-07-12, `#print axioms` on all 7 `Theorem53` theorems and all
9 `CatGT` theorems shows only `[propext, Classical.choice, Quot.sound]`
— zero `sorryAx`. Both are genuinely closed; nothing there currently
needs proof work. If that ever regresses, fix the proof in the specific
file, not the CI wiring — don't loosen a gate to paper over a real break.

If you add a new gating `.lean` target, give it this same fully-isolated
pattern (own build step + own `continue-on-error` + explicit fail-check
+ axiom-print step) rather than bundling it into another target's build
command or relying on a bare `continue-on-error: true` with no explicit
gate — either of those is what let entanglement and a full day of a
hidden real error happen previously.

---

## Hard rules (added 2026-07-18, after a session that broke things)

### Before touching anything
1. **Read this file first.** It exists because these mistakes already happened.
2. **Work only in a real clone.** `git rev-parse --show-toplevel` must print this
   repo's root. `~/Documents/Claude/Projects/io` is **NOT a clone** — it is a stale
   copy sitting inside the home-directory repo (`~` is a git repo with remote
   `TOTOGT/3M`). Editing there does not reach this repository, and it is usually
   behind. Commits made there land in 3M by accident.
3. **`git pull` before editing.** Assume the remote is ahead of any local copy.

### Editing
4. **Never wholesale-replace a working file.** Read it, then make the minimal edit.
   If you believe a full rewrite is warranted, `git diff` it against HEAD first and
   justify every deletion. A file that is already correct must not be "fixed".
5. **Renaming a theorem is a four-file change**: the `.lean`, the CI `#print axioms`
   list, `README.md`, and `index.html`. All four, or none.

### Proof claims
6. **No "closed" / "0 sorry" / "proved" / "verified" without a kernel check.** Either
   CI is green, or the code was pasted into a real Lean kernel and shown clean.
   Fluent prose and confidence are not evidence.
7. **Vacuous statements are banned as theorems**: `True`, `∃ x, True`, `∃ x, x = e`,
   `1 = 1`. They compile and establish nothing. If it cannot be proved, write an
   explicit `sorry` with a comment, or state it as prose — never as a green check.
8. **`#print axioms` must show only** `[propext, Classical.choice, Quot.sound]`.
   Any `sorryAx` means not closed, including inherited transitively.
9. **Documents do not score their own rigor.** No "10/10", no `∎` on a sketch. Tag
   every claim `[VERIFIED]` / `[MODEL]` / `[SIMULATION]` / `[OPEN]` and never let a
   claim drift between tags.

### CI and build
10. **Toolchain is pinned** in `lean-toolchain` (v4.14.0) and `lakefile.toml`. Do not
    bump it in the middle of another task.
11. **There is no committed `lake-manifest.json`.** The workflow MUST run
    `lake update` before any `lean-action` step or mathlib resolution fails with
    `configuration file not found: .lake/packages/mathlib/lakefile.toml`.
12. **Do not rewrite `verify-proofs.yml` wholesale.** Its per-target isolation
    (separate build + axiom-print + gate for each library) is deliberate: Theorem53's
    status must never depend on CatGT.
13. **Pushing workflow changes needs a PAT with `workflow` scope.** Without it, edit
    the file in the GitHub web UI instead.
14. **`CatGT_Main.lean` declares at root level — no namespace.** Do not `open CatGT`
    in the axiom-check file.

### Mathlib gotchas
15. **`Complex.abs` no longer exists** in current Mathlib. Use the norm `‖·‖` — it
    works on both v4.14 and v4.33.
16. **`λ` is reserved syntax** in Lean 4 and can never be an identifier. Use `lam` /
    `hlam`.

---

## The false commutator lemma is NOT confined to this repo (found 2026-07-18)

The Theorem 1 error corrected here — asserting `[K,F] ≠ 0` for a 0/1 gate and a
**pointwise** fold `ψ + λ|ψ|²ψ`, escaping via a δ boundary term that does not
exist — originated elsewhere and propagated. Confirmed carriers outside this repo,
in `~/geometry`:

- `book4/chIV-orthogonality.html`, Lemma 5.3 "Distributional Commutator" —
  the **injection point**
- `ALGEBRAIC_PROOFS_D1_RIBOSWITCH.md` (D1)
- `ch18-zeolite-noncommutativity.html` (D2) — presents it as Book 3's central commutator
- `ALGEBRAIC_PROOFS_CH7_CRYSTALLINE_RETURN.md`, Ch7-T1 Step 5 (Saturn hexagon)

**The 5.3 number collides.** Vol I §5.3 ("the operators C, K, F, U do not
commute; the sequence is order-dependent") is TRUE and is what this repo's
`Theorem53NonCommutativity.lean` verifies. `book4`'s *Lemma* 5.3 is a different,
false claim wearing the same number. Downstream files cite "5.3" meaning either
one — always check which before touching anything.

Full ledger, detection greps, and repair guidance: `~/geometry/CLAUDE.md`,
section "KNOWN DEFECT: the false commutator lemma." Keep that ledger current —
this repo holds the machine-checked refutation the other records need to cite:
`zeolite_operator_order/ZeoliteCommutation.lean` (`gate_commutes`,
`coupling_not_commute`, `gate_fold_not_commute`; axioms clean, no `sorryAx`).

Do **not** let anyone "fix" `PrincipiaOrthogona1/Theorem53NonCommutativity.lean`
on account of this. It is a different, existential, chain-level claim, it is
kernel-verified, and it is fine. Similar number, unrelated statement.
