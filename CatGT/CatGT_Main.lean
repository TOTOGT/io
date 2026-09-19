/-
  CatGT_Main.lean
  Catalytic Generative Theory (CatGT) — Core Lean 4 Formalization
  Central theorem: Helical Selectivity Principle (HSP)
  Part I of the GOMC Opus

  Author  : Pablo Nogueira Grossi
  ORCID   : 0009-0000-6496-2186
  Affil   : G6 LLC, Newark, NJ, USA
  Date    : May 2026 · corrected July 2026
  Zenodo  : 10.5281/zenodo.19117399
  AXLE    : github.com/TOTOGT/AXLE

  Relation to GTCT:
    CatGT is the catalysis instantiation of the overarching
    Generative Temporal Contact Theory (GTCT). The operator
    pipeline G = U∘F∘K∘C and the contact manifold X_cat are
    GTCT primitives applied to heterogeneous catalysis.

  Sorry audit (kernel-checked, Lean v4.33 / Mathlib, live.lean-lang.org):
    ✓ ipr_between_zero_and_one     — closed  (IPR ∈ (0,1], Cauchy-Schwarz)
    ✓ criticalRadius_pos           — closed
    ✓ criticalRadius_antitone      — closed
    ✓ helical_selectivity          — closed  ← HSP formal core
    ✓ selectivityFactor_eq         — closed
    ✓ reeb_orbit_advances          — closed  (α(R)=1 along the Reeb orbit)
    ✓ dnlsNorm_nonneg              — closed  (discrete norm ≥ 0)
    ✓ catgt_dm3_disk               — closed  (disk membership facts)
    ✓ ensemble_scaling_forms_diverge — closed  ((1-x)² ≠ 1-x² at x=1/2)

  Total: 9 closed · 0 admits · 0 sorries · 0 vacuous.

  Corrections (July 2026), each verified in a real Lean kernel:
   - `λ`/`hλ` identifiers → `lam`/`hlam` (Lean 4 reserves `λ`).
   - `Complex.abs _` → `‖·‖` (Complex.abs removed in current Mathlib).
   - criticalRadius_antitone: unbound `hλ₁` in the signature → proper binders.
   - THREE previously VACUOUS theorems replaced by real, non-vacuous ones:
       dnls_norm_conservation_ideal (: True)          → dnlsNorm_nonneg
       reeb_orbit_is_integral       (: 1 = 1)         → reeb_orbit_advances
       catgt_dm3_transport          (: ∃ shape, True) → catgt_dm3_disk
       ensemble_scaling             (: ∃ s, s=(1-x)²) → ensemble_scaling_forms_diverge
  Still OPEN (honest prose, NOT theorems): Corollary 2 disk optimality
  (κ_stab maximiser); which Pt–Sn law ((1-x)² vs 1-(r*/r_pore)²) is physical.
  Full continuous DNLS norm conservation (ODE) — open, awaits Mathlib ODE.
-/

import Mathlib

open BigOperators Real Complex

/-! ## §1  Basic types and parameters -/

/-- A DNLS chain of N catalytic sites. -/
structure DNLSChain (N : ℕ) where
  ψ : Fin N → ℂ
  J : ℝ
  lam : ℝ
  hJ : 0 < J
  hlam : 0 < lam

/-- Inverse Participation Ratio — measures wavefunction localisation. -/
noncomputable def IPR {N : ℕ} (c : DNLSChain N) : ℝ :=
  (∑ n : Fin N, ‖c.ψ n‖ ^ 4) /
  (∑ n : Fin N, ‖c.ψ n‖ ^ 2) ^ 2

/-- Critical attractor radius r*(λ) = √(J/λ). -/
noncomputable def criticalRadius (J lam : ℝ) (hJ : 0 < J) (hlam : 0 < lam) : ℝ :=
  Real.sqrt (J / lam)

/-! ## §2  IPR bounds -/

/-- IPR lies in (0, 1] for any nonzero wavefunction. -/
theorem ipr_between_zero_and_one {N : ℕ} (c : DNLSChain N) (hN : 0 < N)
    (hnz : ∑ n : Fin N, ‖c.ψ n‖ ^ 2 ≠ 0) :
    0 < IPR c ∧ IPR c ≤ 1 := by
  haveI : Nonempty (Fin N) := Fin.pos_iff_nonempty.mp hN
  set a : Fin N → ℝ := fun n => ‖c.ψ n‖ ^ 2 with ha
  have ha0 : ∀ n, 0 ≤ a n := fun n => by positivity
  have hsum_nonneg : 0 ≤ ∑ n, a n := Finset.sum_nonneg (fun n _ => ha0 n)
  have hsum_pos : 0 < ∑ n, a n := lt_of_le_of_ne hsum_nonneg (Ne.symm hnz)
  have hnum_eq : ∑ n : Fin N, ‖c.ψ n‖ ^ 4 = ∑ n, (a n) ^ 2 := by
    apply Finset.sum_congr rfl; intro n _; rw [ha]; ring
  obtain ⟨n, -, hn⟩ : ∃ n ∈ Finset.univ, (0:ℝ) < a n := by
    apply Finset.exists_lt_of_sum_lt; simpa using hsum_pos
  constructor
  · rw [IPR, hnum_eq]
    apply div_pos
    · exact Finset.sum_pos' (fun m _ => by positivity) ⟨n, Finset.mem_univ n, pow_pos hn 2⟩
    · exact pow_pos hsum_pos 2
  · rw [IPR, hnum_eq, div_le_one (pow_pos hsum_pos 2)]
    have key : ∀ n ∈ Finset.univ, (a n) ^ 2 ≤ a n * ∑ m, a m := by
      intro n _
      have h1 : a n ≤ ∑ m, a m := Finset.single_le_sum (fun m _ => ha0 m) (Finset.mem_univ n)
      nlinarith [ha0 n, h1]
    calc ∑ n, (a n) ^ 2 ≤ ∑ n, a n * ∑ m, a m := Finset.sum_le_sum key
      _ = (∑ n, a n) * (∑ m, a m) := by rw [← Finset.sum_mul]
      _ = (∑ n, a n) ^ 2 := by ring

/-! ## §3  Attractor geometry -/

def isDelocalised {N : ℕ} (c : DNLSChain N) : Prop := IPR c < 1 / 2

structure ReactionPathway (N : ℕ) where
  r : ℝ → ℝ
  θ : ℝ → ℝ
  z : ℝ → ℝ

def withinAttractor (N : ℕ) (γ : ReactionPathway N) (J lam : ℝ)
    (hJ : 0 < J) (hlam : 0 < lam) : Prop :=
  ∀ t : ℝ, γ.r t ≤ criticalRadius J lam hJ hlam

/-! ## §4  Helical Selectivity Principle (HSP) — Theorem 1 of CatGT -/

/-- The critical radius r*(λ) is strictly positive. -/
theorem criticalRadius_pos (J lam : ℝ) (hJ : 0 < J) (hlam : 0 < lam) :
    0 < criticalRadius J lam hJ hlam := by
  unfold criticalRadius; exact Real.sqrt_pos_of_pos (div_pos hJ hlam)

/-- r*(λ) decreases as λ increases: stronger binding → tighter selectivity. -/
theorem criticalRadius_antitone (J : ℝ) (hJ : 0 < J) (lam1 lam2 : ℝ)
    (h1 : 0 < lam1) (h2 : 0 < lam2) (hle : lam1 ≤ lam2) :
    criticalRadius J lam2 hJ h2 ≤ criticalRadius J lam1 hJ h1 := by
  unfold criticalRadius; apply Real.sqrt_le_sqrt; gcongr

/-- **Helical Selectivity Principle (HSP)** — formal core of Theorem 1.
    r² ≤ J/λ ⟹ r ≤ r*(λ) = √(J/λ). -/
theorem helical_selectivity (J lam : ℝ) (hJ : 0 < J) (hlam : 0 < lam)
    (r_state : ℝ) (hr : 0 ≤ r_state) (h_confined : r_state ^ 2 ≤ J / lam) :
    r_state ≤ criticalRadius J lam hJ hlam := by
  unfold criticalRadius; rw [← Real.sqrt_sq hr]; exact Real.sqrt_le_sqrt h_confined

/-- Selectivity factor σ = 1 - J/(λ·r_pore²). -/
noncomputable def selectivityFactor (J lam r_pore : ℝ)
    (hJ : 0 < J) (hlam : 0 < lam) (hr : 0 < r_pore) : ℝ :=
  1 - (criticalRadius J lam hJ hlam / r_pore) ^ 2

theorem selectivityFactor_eq (J lam r_pore : ℝ)
    (hJ : 0 < J) (hlam : 0 < lam) (hr : 0 < r_pore) :
    selectivityFactor J lam r_pore hJ hlam hr = 1 - J / (lam * r_pore ^ 2) := by
  unfold selectivityFactor criticalRadius
  rw [div_pow, Real.sq_sqrt (div_nonneg hJ.le hlam.le)]; ring

/-! ## §5  Computational scaffold — DNLS iterator -/

/-- One explicit Euler step of the DNLS equation (periodic BC).
    September 2026 correction: solving iψ̇ = -J(ψ_{n+1}+ψ_{n-1}) - λ|ψ|²ψ
    for ψ̇ gives ψ̇ = i·(J(ψ_{n+1}+ψ_{n-1}) + λ|ψ|²ψ) — no leading minus
    signs inside the parenthesis (multiplying by 1/i = -i flips both).
    The pre-2026-09-19 version kept the minus signs before multiplying
    by dt·i, which evolved the equation with the opposite sign
    convention from the one stated in this project's own papers. -/
noncomputable def dnlsStep {N : ℕ} (hN : 0 < N) (c : DNLSChain N) (dt : ℝ) :
    DNLSChain N where
  ψ n :=
    let prev := c.ψ ⟨(n.val + N - 1) % N, Nat.mod_lt _ hN⟩
    let next := c.ψ ⟨(n.val + 1) % N, Nat.mod_lt _ hN⟩
    let curr := c.ψ n
    let coupling : ℂ := (c.J : ℂ) * (next + prev)
    let onsite : ℂ := (c.lam : ℂ) * ((‖curr‖ : ℂ) ^ 2) * curr
    curr + (dt : ℂ) * Complex.I * (coupling + onsite)
  J := c.J
  lam := c.lam
  hJ := c.hJ
  hlam := c.hlam

/-- Iterate the DNLS stepper for n steps. -/
noncomputable def dnlsIterate {N : ℕ} (hN : 0 < N) (c : DNLSChain N)
    (dt : ℝ) : ℕ → DNLSChain N
  | 0 => c
  | n + 1 => dnlsStep hN (dnlsIterate hN c dt n) dt

/-- Wavefunction norm ‖ψ‖². -/
noncomputable def dnlsNorm {N : ℕ} (c : DNLSChain N) : ℝ :=
  ∑ n : Fin N, ‖c.ψ n‖ ^ 2

/-- Discrete norm is nonnegative (sum of squared magnitudes).
    The stronger claim — exact conservation ‖ψ(t)‖² = const under the
    continuous DNLS flow — needs Mathlib ODE theory and is OPEN. -/
theorem dnlsNorm_nonneg {N : ℕ} (c : DNLSChain N) : 0 ≤ dnlsNorm c := by
  unfold dnlsNorm; exact Finset.sum_nonneg (fun n _ => by positivity)

/-! ## §6  Reeb vector field of the CatGT contact structure -/

/-- The contact form α_cat = dz - r²dθ, evaluated at a point (r,θ,z) on a
    tangent vector (dr,dθ,dz): α_(r,θ,z)(dr,dθ,dz) = dz - r²·dθ. This is
    the actual 1-form pairing, not a scalar potential: a potential
    F(r,θ,z) with dF = α_cat would need an extra -2rθ·dr term that
    dz-r²dθ does not have, so the pre-2026-09-19 version of this section
    (which used F(r,θ,z) = z - r²θ as a stand-in) was proving a fact
    about a different, unrelated object. -/
def alphaCat (p : ℝ × ℝ × ℝ) (v : ℝ × ℝ × ℝ) : ℝ :=
  v.2.2 - p.1 ^ 2 * v.2.1

/-- The Reeb vector field R = ∂_z, as the constant tangent vector (0,0,1)
    (a coordinate vector field is constant in its own coordinate chart). -/
def reebR : ℝ × ℝ × ℝ := (0, 0, 1)

/-- **α(R) = 1, everywhere.** The actual defining pairing of the Reeb
    vector field for α_cat = dz - r²dθ, computed directly from the 1-form
    above rather than from an unrelated potential function's derivative. -/
theorem reeb_alpha_eq_one (p : ℝ × ℝ × ℝ) : alphaCat p reebR = 1 := by
  show (1 : ℝ) - p.1 ^ 2 * 0 = 1
  ring

/-- The Reeb orbit through (r₀,θ₀,z₀), flowing for time t: γ(t) =
    (r₀,θ₀,z₀+t). Its integral curves hold r,θ fixed — straight lines in
    z, not helices (see the CatGT page's own 2026-09-19 correction notes,
    which also drop the "attractor" language: a Reeb flow preserves
    α∧dα, hence contact volume, hence cannot have an attracting set). -/
def reebOrbit (r₀ θ₀ z₀ t : ℝ) : ℝ × ℝ × ℝ := (r₀, θ₀, z₀ + t)

/-- **September 2026 correction.** Kept under the original name for
    citation stability (index.html's Sorry Audit and paper.tex's
    Appendix B both cite `reeb_orbit_advances` by name) — the content is
    now what the name always claimed, rather than an unrelated fact
    about the potential F(r,θ,z)=z-r²θ (the pre-2026-09-19 version,
    which proved F(r,θ,z+t)-F(r,θ,z)=t for ANY choice of the r²θ term,
    since it never entered that computation at all). The z-advance of
    the Reeb orbit over time t equals t · α(R) evaluated at the
    basepoint, and α(R)=1 (reeb_alpha_eq_one above), so the advance is
    exactly t — now derived from the actual pairing, not asserted via a
    disconnected function that happened to give the same answer. -/
theorem reeb_orbit_advances (r₀ θ₀ z₀ t : ℝ) :
    (reebOrbit r₀ θ₀ z₀ t).2.2 - (reebOrbit r₀ θ₀ z₀ 0).2.2
      = t * alphaCat (r₀, θ₀, z₀) reebR := by
  show (z₀ + t) - (z₀ + 0) = t * (1 - r₀ ^ 2 * 0)
  ring

/-! ## §7  dm³ transport and ensemble scaling — real facts, honest open claims -/

/-- The candidate optimal cross-section is the disk of radius r_star:
    its centre is inside, a point at 2·r_star is outside. The full
    Corollary 2 optimality claim (this disk maximises κ_stab over
    equal-area convex sections) is OPEN — not a theorem here. -/
theorem catgt_dm3_disk (r_star : ℝ) (hr : 0 < r_star) :
    ((0,0) : ℝ × ℝ) ∈ {p : ℝ × ℝ | p.1 ^ 2 + p.2 ^ 2 ≤ r_star ^ 2} ∧
    ((2 * r_star, 0) : ℝ × ℝ) ∉ {p : ℝ × ℝ | p.1 ^ 2 + p.2 ^ 2 ≤ r_star ^ 2} := by
  refine ⟨?_, ?_⟩
  · simp only [Set.mem_setOf_eq]; nlinarith [sq_nonneg r_star]
  · simp only [Set.mem_setOf_eq]; intro h; nlinarith [mul_pos hr hr]

/-- The two proposed Pt–Sn scaling forms are NOT the same function:
    (1-x)² and 1-x² agree only at x∈{0,1}; at x=1/2, 1/4 ≠ 3/4.
    Which form is physical is OPEN (awaits XAS, Part III). -/
theorem ensemble_scaling_forms_diverge :
    (1 - (1/2 : ℝ)) ^ 2 ≠ 1 - (1/2 : ℝ) ^ 2 := by norm_num

/-! ## §8  Summary of verified claims -/

#check @ipr_between_zero_and_one
#check @helical_selectivity
#check @criticalRadius_pos
#check @criticalRadius_antitone
#check @selectivityFactor_eq
#check @reeb_orbit_advances
#check @dnlsNorm_nonneg
#check @catgt_dm3_disk
#check @ensemble_scaling_forms_diverge

/-! ## §9  The axiom report

    `#check` prints a type. It says nothing about what a proof rests on, and a
    file that compiles has said nothing either: `sorry` compiles. The gate is
    this block. Every theorem below must report exactly
    `[propext, Classical.choice, Quot.sound]` and no `sorryAx`.

    Run 2026-09-19: ten theorems, all three permitted axioms, no `sorryAx`.
    Checked under Lean 4.33.0-rc1 with Mathlib v4.33.0-rc1, and under the
    v4.32.0 pin the author runs; the two sections corrected on 2026-09-19 use
    no Mathlib lemma at all (`show` and `ring` only), so nothing in this file's
    new material depends on a library version. -/

#print axioms ipr_between_zero_and_one
#print axioms criticalRadius_pos
#print axioms criticalRadius_antitone
#print axioms helical_selectivity
#print axioms selectivityFactor_eq
#print axioms dnlsNorm_nonneg
#print axioms reeb_alpha_eq_one
#print axioms reeb_orbit_advances
#print axioms catgt_dm3_disk
#print axioms ensemble_scaling_forms_diverge
