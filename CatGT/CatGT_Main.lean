/-
  CatGT_Main.lean
  Catalytic Generative Theory (CatGT) — Core Lean 4 Formalization
  Central theorem: Helical Selectivity Principle (HSP)
  Part I of the GOMC Opus

  Author  : Pablo Nogueira Grossi
  ORCID   : 0009-0000-6496-2186
  Affil   : G6 LLC, Newark, NJ, USA
  Date    : July 2026 (kernel-check revision)
  Zenodo  : 10.5281/zenodo.19117399
  AXLE    : github.com/TOTOGT/AXLE

  ── Revision note (2026-07) ──────────────────────────────────
  This revision makes the file actually elaborate:
    * `λ`/`hλ` renamed `lam`/`hlam` everywhere (λ is reserved
      syntax in Lean 4; the previous file could not parse).
    * `criticalRadius_antitone` restated with properly bound
      hypotheses (previous statement referenced unbound names).
    * `ipr_between_zero_and_one` positivity proof repaired: the
      previous proof needed every ψ n ≠ 0, which does not follow
      from ∑‖ψ n‖² ≠ 0. Now uses Finset.sum_pos' with a witness.
    * Vacuous placeholder "theorems" (`True`, `∃ _, True`,
      `∃ s, s = e`) removed or replaced per the 2026-07-10 site
      correction. Open claims live in comments, not fake theorems.

  Sorry audit:
    ✓ criticalRadius_pos          — closed
    ✓ criticalRadius_antitone     — closed
    ✓ helical_selectivity         — closed  ← HSP formal core
    ✓ selectivityFactor_eq        — closed
    ✓ ipr_le_one                  — closed
    ✓ ipr_pos                     — closed
    ✓ catgt_dm3_transport         — closed (narrowed scope, see note)
    ✓ ensemble_scaling_forms_diverge — closed (see note)
  Open (stated in prose, NOT as theorems):
    ⚠ DNLS norm conservation (needs ODE theory)
    ⚠ Corollary 2 disk optimality (needs isoperimetric lemma)
    ⚠ which Pt–Sn scaling form is physical (needs XAS data)

  Total: 8 closed · 0 sorries · 0 vacuous statements.
-/

import Mathlib.Analysis.SpecialFunctions.Pow.NNRpow
import Mathlib.Analysis.SpecialFunctions.Sqrt
import Mathlib.Data.Complex.Basic
import Mathlib.Algebra.Order.BigOperators.Ring.Finset
import Mathlib.Tactic

open Finset

namespace CatGT

/-!
## §1  Basic types and parameters
-/

/-- A DNLS chain of `N` catalytic sites.
    `lam` is the on-site nonlinearity (λ in the paper; Lean 4
    reserves the λ character for anonymous functions). -/
structure DNLSChain (N : ℕ) where
  /-- Wavefunction amplitudes ψ_n at each site -/
  ψ : Fin N → ℂ
  /-- Inter-site coupling J (tunnelling / diffusivity analog) -/
  J : ℝ
  /-- On-site nonlinearity λ (binding energy analog) -/
  lam : ℝ
  hJ : 0 < J
  hlam : 0 < lam

/-- Inverse Participation Ratio — measures wavefunction localisation. -/
noncomputable def IPR {N : ℕ} (c : DNLSChain N) : ℝ :=
  (∑ n : Fin N, ‖c.ψ n‖ ^ 4) / (∑ n : Fin N, ‖c.ψ n‖ ^ 2) ^ 2

/-- Critical attractor radius r*(λ) = √(J/λ).
    The central invariant of CatGT and the HSP. -/
noncomputable def criticalRadius (J lam : ℝ) : ℝ :=
  Real.sqrt (J / lam)

/-!
## §2  Attractor geometry — criticalRadius lemmas
-/

/-- r*(λ) is strictly positive: there is always a nonzero tube of
    accessible pathways. -/
theorem criticalRadius_pos (J lam : ℝ) (hJ : 0 < J) (hlam : 0 < lam) :
    0 < criticalRadius J lam := by
  unfold criticalRadius
  exact Real.sqrt_pos.mpr (div_pos hJ hlam)

/-- r*(λ) decreases as λ increases: stronger binding → tighter
    selectivity. Monotonicity backbone of the HSP. -/
theorem criticalRadius_antitone (J lam₁ lam₂ : ℝ)
    (hJ : 0 < J) (hlam₁ : 0 < lam₁) (hle : lam₁ ≤ lam₂) :
    criticalRadius J lam₂ ≤ criticalRadius J lam₁ := by
  unfold criticalRadius
  apply Real.sqrt_le_sqrt
  exact div_le_div_of_nonneg_left hJ.le hlam₁ hle

/-!
## §3  Helical Selectivity Principle (HSP) — Theorem 1
-/

/-- **Helical Selectivity Principle (HSP)** — formal core of Theorem 1.
    A state with radial coordinate r satisfying r² ≤ J/λ is confined
    within the attractor tube of radius r*(λ) = √(J/λ). -/
theorem helical_selectivity (J lam : ℝ) (r_state : ℝ)
    (hr : 0 ≤ r_state) (h_confined : r_state ^ 2 ≤ J / lam) :
    r_state ≤ criticalRadius J lam := by
  unfold criticalRadius
  calc r_state = Real.sqrt (r_state ^ 2) := (Real.sqrt_sq hr).symm
    _ ≤ Real.sqrt (J / lam) := Real.sqrt_le_sqrt h_confined

/-- Selectivity factor σ = 1 - (r*/r_pore)². -/
noncomputable def selectivityFactor (J lam r_pore : ℝ) : ℝ :=
  1 - (criticalRadius J lam / r_pore) ^ 2

/-- σ = 1 - J/(λ·r_pore²), recovering the classical zeolite
    shape-selectivity factor (Weisz & Frilette 1960; Csicsery 1984). -/
theorem selectivityFactor_eq (J lam r_pore : ℝ)
    (hJ : 0 ≤ J) (hlam : 0 ≤ lam) :
    selectivityFactor J lam r_pore = 1 - J / (lam * r_pore ^ 2) := by
  unfold selectivityFactor criticalRadius
  rw [div_pow, Real.sq_sqrt (div_nonneg hJ hlam), div_div]

/-!
## §4  IPR bounds
-/

/-- IPR ≤ 1: no state is more localised than full self-trapping.
    Proof: ∑‖ψ‖⁴ ≤ (∑‖ψ‖²)² term-by-term via single_le_sum. -/
theorem ipr_le_one {N : ℕ} (c : DNLSChain N)
    (hnonzero : (∑ n : Fin N, ‖c.ψ n‖ ^ 2) ≠ 0) :
    IPR c ≤ 1 := by
  unfold IPR
  have hden_nonneg : (0:ℝ) ≤ ∑ n : Fin N, ‖c.ψ n‖ ^ 2 :=
    Finset.sum_nonneg fun n _ => pow_nonneg (norm_nonneg _) 2
  have hden_pos : (0:ℝ) < ∑ n : Fin N, ‖c.ψ n‖ ^ 2 :=
    lt_of_le_of_ne hden_nonneg (Ne.symm hnonzero)
  rw [div_le_one (by positivity)]
  calc ∑ n : Fin N, ‖c.ψ n‖ ^ 4
      ≤ ∑ n : Fin N, ‖c.ψ n‖ ^ 2 * ∑ m : Fin N, ‖c.ψ m‖ ^ 2 := by
        apply Finset.sum_le_sum
        intro n _
        have h4 : ‖c.ψ n‖ ^ 4 = ‖c.ψ n‖ ^ 2 * ‖c.ψ n‖ ^ 2 := by ring
        rw [h4]
        apply mul_le_mul_of_nonneg_left _ (pow_nonneg (norm_nonneg _) 2)
        exact Finset.single_le_sum
          (fun m _ => pow_nonneg (norm_nonneg _) 2) (Finset.mem_univ n)
    _ = (∑ n : Fin N, ‖c.ψ n‖ ^ 2) ^ 2 := by
        rw [← Finset.sum_mul, sq]

/-- IPR > 0 for any not-identically-zero wavefunction.
    (Repaired: previous proof required every ψ n ≠ 0, which does not
    follow from the sum being nonzero. Uses sum_pos' with a witness.) -/
theorem ipr_pos {N : ℕ} (c : DNLSChain N)
    (hnonzero : (∑ n : Fin N, ‖c.ψ n‖ ^ 2) ≠ 0) :
    0 < IPR c := by
  unfold IPR
  -- extract a witness site with ψ n ≠ 0
  have hex : ∃ n : Fin N, c.ψ n ≠ 0 := by
    by_contra h
    push_neg at h
    apply hnonzero
    exact Finset.sum_eq_zero fun n _ => by rw [h n]; simp
  obtain ⟨n₀, hn₀⟩ := hex
  have hden_nonneg : (0:ℝ) ≤ ∑ n : Fin N, ‖c.ψ n‖ ^ 2 :=
    Finset.sum_nonneg fun n _ => pow_nonneg (norm_nonneg _) 2
  have hden_pos : (0:ℝ) < ∑ n : Fin N, ‖c.ψ n‖ ^ 2 :=
    lt_of_le_of_ne hden_nonneg (Ne.symm hnonzero)
  apply div_pos
  · apply Finset.sum_pos'
    · intro n _; exact pow_nonneg (norm_nonneg _) 4
    · exact ⟨n₀, Finset.mem_univ n₀,
        pow_pos (norm_pos_iff.mpr hn₀) 4⟩
  · positivity

/-- IPR ∈ (0, 1] — combined statement matching the paper. -/
theorem ipr_between_zero_and_one {N : ℕ} (c : DNLSChain N)
    (hnonzero : (∑ n : Fin N, ‖c.ψ n‖ ^ 2) ≠ 0) :
    0 < IPR c ∧ IPR c ≤ 1 :=
  ⟨ipr_pos c hnonzero, ipr_le_one c hnonzero⟩

/-!
## §5  Corrected theorems (2026-07-10 revision)

The two theorems below replace earlier vacuous versions
(`∃ shape, True` and `∃ s, s = (1-x)²`) which established nothing.
See the paper's revision note.
-/

/-- dm³ transport (Corollary 2, narrowed scope): pins the candidate
    shape to the disk of radius r* and proves two real membership
    facts about it. The optimality claim (this disk maximises κ_stab
    over convex cross-sections of equal area) is NOT proved here —
    open obligation, target Part II. -/
theorem catgt_dm3_transport (r_star : ℝ) (hr : 0 < r_star) :
    ∃ shape : Set (ℝ × ℝ),
      shape = {p : ℝ × ℝ | p.1 ^ 2 + p.2 ^ 2 ≤ r_star ^ 2} ∧
      (0, 0) ∈ shape ∧
      (2 * r_star, 0) ∉ shape := by
  refine ⟨{p | p.1 ^ 2 + p.2 ^ 2 ≤ r_star ^ 2}, rfl, ?_, ?_⟩
  · simp only [Set.mem_setOf_eq]
    nlinarith [sq_nonneg r_star]
  · simp only [Set.mem_setOf_eq]
    push_neg
    nlinarith [sq_nonneg r_star, hr]

/-- Ensemble scaling (Corollary 1, honest form): the two proposed
    scaling laws (1-x)² and 1-x² agree at the endpoints but are NOT
    the same function — they differ at x = 1/2. Which is physically
    correct awaits XAS validation (Part III). -/
theorem ensemble_scaling_forms_diverge :
    (1 - (0:ℝ)) ^ 2 = 1 - (0:ℝ) ^ 2 ∧
    (1 - (1:ℝ)) ^ 2 = 1 - (1:ℝ) ^ 2 ∧
    ∃ x : ℝ, 0 < x ∧ x < 1 ∧ (1 - x) ^ 2 ≠ 1 - x ^ 2 := by
  refine ⟨by ring, by ring, 1/2, by norm_num, by norm_num, by norm_num⟩

/-!
## §6  Open obligations — stated as prose, not theorems

* **DNLS norm conservation.** The continuous DNLS flow conserves ‖ψ‖²
  (coupling cancels by summation-by-parts on a periodic chain; the
  onsite term is purely imaginary). A Lean proof needs ODE machinery.
  NOTE: the explicit-Euler stepper does NOT conserve the norm exactly
  — only the exact flow does. Any formal statement must be about the
  continuous flow, not the iterator.

* **Corollary 2 optimality.** Needs κ_stab defined + a 2D
  isoperimetric argument. Check current Mathlib for Brunn–Minkowski /
  isoperimetric support before attempting.

* **Pt–Sn scaling form.** Empirical question; not a theorem until the
  physical model is fixed.
-/

end CatGT
