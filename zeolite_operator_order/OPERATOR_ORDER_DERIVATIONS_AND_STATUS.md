# Operator Firing Order in Zeolite Selectivity
## What is proved, what is modelled, what is open

Pablo Nogueira Grossi — G6 LLC, Newark NJ
Original draft: June 5, 2026 · **Corrected: July 18, 2026**

---

## 0. Status of this document

This document previously carried the title "ALGEBRAIC PROOFS: ALL 7 THEOREMS",
marked each section with `∎`, and closed by awarding itself a "MATHEMATICAL RIGOR
SCORE: 10/10 ✓ (proven)". That framing was wrong, and one of the seven theorems was
mathematically false. A document cannot score its own rigor; only a checker can.
This version states only what can be defended.

Four tags are used throughout, and nothing is permitted to drift between them:

| Tag | Meaning |
|---|---|
| **[VERIFIED]** | Checked by the Lean 4 kernel. Reproducible; see §1 and §6. |
| **[MODEL]** | A consequence of the stated model, argued but not machine-checked. |
| **[SIMULATION]** | A number produced by the DNLS simulation. Not derived. |
| **[OPEN]** | Not established. |

**Correction notice.** The previous Theorem 1 claimed `[K, F] ≠ 0` for `K` = the
aperture gate (multiplication by a 0/1 step) and `F` = the pointwise fold
`ψ + λ|ψ|²ψ`. That claim is **false**, and the previous "proof" contradicted itself:
its own computation reached `λθ|ψ|²[1 − θ]ψ`, then observed that
`θ·[1 − θ] = 0 everywhere`, and then asserted a boundary term `∝ δ(r − r_aperture)`
that does not follow from anything above it. Those two operators commute exactly
(§1.1). Because Theorems 2–4 obtained their result by *swapping K and F*, the error
propagated into the central mechanism. §1 and §2 replace it.

---

## 1. The commutation facts

Both facts below are kernel-checked on a 3-site ring with real amplitudes (so
`|v|²v = v³`). The finite setting is deliberate: it makes the claims decidable and
independently reproducible rather than rhetorical.

```lean
def coupling (v : Fin 3 → ℝ) : Fin 3 → ℝ := ![v 1 + v 2, v 0 + v 2, v 0 + v 1]
def onsite   (v : Fin 3 → ℝ) : Fin 3 → ℝ := fun i => (v i) ^ 3
def gate     (v : Fin 3 → ℝ) : Fin 3 → ℝ := ![v 0, 0, v 2]
def psi      : Fin 3 → ℝ := ![1, 1, 0]
```

### 1.1 The aperture gate commutes with the pointwise fold — [VERIFIED]

```lean
theorem gate_commutes (v : Fin 3 → ℝ) : gate (onsite v) = onsite (gate v)
```

For a 0/1 gate `g` and a pointwise map, `(g·v)³ = g³v³ = g·v³`, since `g³ = g` when
`g ∈ {0,1}`. Gate and fold act on each site independently, so their order is
immaterial — **for every state**, not merely for the one tested.

**Consequence, and it is the load-bearing one:** in a model where the aperture is
multiplication by an indicator and the fold is pointwise, gating-then-folding and
folding-then-gating give *identical* results. Such a model **cannot** produce the
ZSM-5 / MCM-22 divergence. Any derivation that obtains different selectivities by
swapping those two operators contains an error.

### 1.2 A linear coupling does *not* commute with the fold — [VERIFIED]

```lean
theorem coupling_not_commute : coupling (onsite psi) ≠ onsite (coupling psi)
```

With `ψ = (1, 1, 0)`, evaluate at site 2, whose two neighbours hold 1 and 1:

- `coupling ∘ onsite` — cube first, then sum: `1³ + 1³ = 2`
- `onsite ∘ coupling` — sum first, then cube: `(1 + 1)³ = 8`

The commutator at site 2 is `2 − 8 = −6 ≠ 0`.

The mechanism is exact and elementary: **a nonlinear map does not distribute over a
sum.** Sum-of-cubes ≠ cube-of-sum. That is the entire source of order-dependence
here. No distributional or boundary argument is required, and none is used.

### 1.3 Where order-dependence actually comes from

Combining §1.1 and §1.2: order-dependence is **not** carried by the aperture. It is
carried by whichever operator moves amplitude *between* sites. Physically that is
the right answer — folding (oligomerisation, ring closure) is not a site-local
recolouring; it redistributes amplitude in space. In the DNLS model,

```
i ψ̇ₙ = −J(ψₙ₊₁ + ψₙ₋₁) − λ|ψₙ|²ψₙ
```

the two terms are exactly `coupling` (the `J` hopping) and `onsite` (the `λ`
nonlinearity), and §1.2 shows they do not commute. **The fold must carry its
coupling term for the mechanism to exist at all.**

---

## 2. The corrected model

Let the fold be `F = F_coupling ∘ F_onsite` — spreading *and* on-site nonlinearity —
not the pointwise map alone. Then:

- `[gate, F] ≠ 0`, because `F` now contains the coupling. — [MODEL, resting on §1.2]
- Folding inside an **open** cavity spreads amplitude across sites that a
  later-applied gate then encloses; folding **after** gating spreads only within the
  already-restricted support. These are different states. — [MODEL]

This is the honest form of the original intuition. The intuition was sound; the
operator definition was not.

### Chain-level order dependence — [VERIFIED, independently]

That the full chain `G = U ∘ F ∘ K ∘ C` is order-dependent *in general*, while some
configurations provably commute, is established separately and kernel-checked in
`PrincipiaOrthogona1/Theorem53NonCommutativity.lean` (7 theorems, 0 `sorry`). That
result is exactly existential: it exhibits an order-dependent instance **and** a
commuting instance on the same manifold. It does not assert that every chain is
order-dependent, and neither does this document.

---

## 3. Selectivity: what is model, what is simulation

The physical claim — ZSM-5 (`C→K→F→U`) suppresses aromatics, MCM-22 (`C→F→K→U`)
permits them — is a **model prediction**, not a theorem.

- Gating first restricts support before the fold can populate the aromatic region;
  folding first populates it and the gate then traps it. — [MODEL]
- `S ≈ 0.35–0.40` for the MCM-22 order, `S ≈ 0` for the ZSM-5 order —
  **[SIMULATION]**, from `dm3_dnls_zeolite_simulation.py`. These are outputs of a
  numerical integration at specific parameters. They are not derived in closed form
  and must never be cited as proved.
- The wavepacket figures in the earlier draft (`σ₁ ≈ 0.2 Å`, `⟨r⟩₁ ≈ 2.5 Å`,
  `σ₂ ≈ 1.5–2.0 Å`) are **[MODEL]** ansätze — neither measurements nor derivations.

---

## 4. Status of the original seven

| # | Original claim | Status now |
|---|---|---|
| 1 | `[K, F] ≠ 0` for gate and pointwise fold | **False.** Replaced by §1.1 (they commute) and §1.2 (coupling/fold do not) — both [VERIFIED] |
| 2 | `C→K→F→U ⟹ S ≈ 0` | [MODEL] + [SIMULATION]; not a theorem |
| 3 | `C→F→K→U ⟹ S > 0` | [MODEL] + [SIMULATION]; not a theorem |
| 4 | `S = S(operator order)` | [MODEL], resting on §1.2 and the corrected fold. Chain-level order-dependence itself is [VERIFIED] via Theorem 5.3 |
| 5 | Contact morphism scaling | [OPEN] — not re-derived in this revision |
| 6 | Predictions P1–P3 (DRIFTS sequence, coke segregation, acid-site relocation) | [MODEL] — falsifiable experimental predictions, correctly labelled; no proof claimed or needed |
| 7 | Selectivity ↔ order bijection | [OPEN] — injectivity was argued from Theorems 2 and 3, which are [MODEL]; the bijection does not follow |

---

## 5. Open items

1. Formalise §2's `[gate, F] ≠ 0` for the corrected fold — the §1.2 lemma is the seed.
2. Re-derive Theorem 5 (contact morphism scaling), or withdraw it.
3. Theorem 7's bijection needs a real argument, or removal.
4. A closed-form selectivity, if obtainable, would upgrade §3 from simulation to derivation.

---

## 6. Reproducing the verification

The two lemmas of §1 are self-contained and compile against Lean 4 / Mathlib with no
`sorry` and no warnings. Paste the four definitions and both theorem statements into
any Lean 4 + Mathlib environment (for example `live.lean-lang.org`) to re-check them
independently. Verified July 18, 2026 against Lean `v4.33`.

Nothing marked [MODEL], [SIMULATION] or [OPEN] may be presented as proved — in this
repository, or in any paper drawing on it.
