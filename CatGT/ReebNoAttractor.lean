/-
  ReebNoAttractor.lean  (2026-09-21)  --  REVISED 2026-09-21 after the author's first run. First run: Part A compiled except one line
  (`IsClopen.eq_univ` via an anonymous-constructor ascription); Part B did not parse (`∞` needs
  `open scoped ENNReal`), and `reebFlow_measurePreserving` failed instance search for
  `volume.IsAddRightInvariant`. This revision fixes those three points and is UNTESTED again.

  QUESTION. The V5 paper says of the Reeb flow of alpha_cat: "it is volume-preserving, hence has no
  attracting set". Prove it or disprove it.

  ANSWER (hand-derived; this file is the formalisation).

  1. AS WRITTEN, THE STATEMENT IS FALSE. The whole space attracts itself: A = U = X satisfies every
     reasonable definition of "attracting set" for ANY flow, volume-preserving or not
     (`univ_attracts` below). On a closed contact manifold M the set A = M is a compact attracting
     set of the Reeb flow. So "cannot have an attracting set, for any contact form on any contact
     manifold" overstates.

  2. THE TRUE STATEMENT (Part B). Let mu be preserved by the maps phi_n. If a closed set A, with
     mu(thickening R A) finite for some R > 0, attracts every point of a set U, then
         mu(U) <= mu(A).
     So a volume-preserving flow has no attracting set of SMALLER volume than its basin. In
     particular there is no attracting fixed point, periodic orbit, or lower-dimensional attractor
     (for those mu(A) = 0 < mu(U) whenever U is a nonempty open set of positive volume).
     Proof (no dominated convergence needed): fix eps > 0. Put
         E_N = { x in U : phi_n x in thickening eps A for all n >= N }.
     E_N increases with N and its union contains U. Each E_N lies in phi_N^{-1}(thickening eps A),
     whose measure equals mu(thickening eps A) because phi_N preserves mu. So
         mu(U) <= mu(union E_N) = sup_N mu(E_N) <= mu(thickening eps A).
     Let eps -> 0: for a closed A with a finite-measure thickening, mu(thickening eps A) -> mu(A).

  3. FOR THE ACTUAL FLOW (Part A, purely metric, no measure). The Reeb flow of alpha_cat is
     translation p |-> p + t*(0,0,1). It is an isometry, so for any invariant set A
     dist(phi_t x, A) = dist(x, A) for all t. "Attracted" then forces dist(x, A) = 0, i.e. x in
     closure A. Hence: a nonempty closed invariant A with an attracted open neighbourhood U is
     open and closed, so A = whole space (`no_proper_attractor`). And there is no nonempty compact
     invariant set at all (`no_compact_invariant`), since z-translation is unbounded.

  MODEL / CAVEATS.
    * Part A and B use the chart R x R x R exactly as ReebFlow.lean does (`reebFlow` is copied
      verbatim from there). In the Cartesian chart (u,v,z) of the real R^3 the contact volume is
      alpha ^ d alpha = -2 du ^ dv ^ dz, a constant multiple of Lebesgue measure; that identification
      is [DERIVED] by hand and is not proved here.
    * Attraction in Part B is stated at integer times n : N. For a continuous-time flow this is
      implied by convergence as t -> infinity restricted to integers.
    * Part B needs no invariance of A, only that A is closed with a finite-measure thickening (true
      for compact A in R^3). Part A's stronger conclusion uses invariance.
-/

import Mathlib

open MeasureTheory Filter Topology
open scoped ENNReal

namespace ReebNoAttractor

/-! ## Copy of the definitions from ReebFlow.lean -/

def reebR : ℝ × ℝ × ℝ := (0, 0, 1)

def reebFlow (t : ℝ) (p : ℝ × ℝ × ℝ) : ℝ × ℝ × ℝ := p + t • reebR

/-! ## Part A: metric argument for the actual Reeb flow -/

theorem reebFlow_isometry (t : ℝ) : Isometry (reebFlow t) := by
  refine Isometry.of_dist_eq fun x y => ?_
  simp [reebFlow, dist_add_right]

/-- A is invariant under the Reeb flow for all times. -/
def ReebInvariant (A : Set (ℝ × ℝ × ℝ)) : Prop := ∀ t : ℝ, reebFlow t '' A = A

/-- Every point of U has distance to A tending to 0 as t -> infinity. -/
def AttractedTo (A U : Set (ℝ × ℝ × ℝ)) : Prop :=
  ∀ x ∈ U, Tendsto (fun t : ℝ => Metric.infDist (reebFlow t x) A) atTop (𝓝 0)

theorem infDist_reebFlow (t : ℝ) (A : Set (ℝ × ℝ × ℝ)) (hA : ReebInvariant A) (x : ℝ × ℝ × ℝ) :
    Metric.infDist (reebFlow t x) A = Metric.infDist x A := by
  have h : Metric.infDist (reebFlow t x) (reebFlow t '' A) = Metric.infDist x A :=
    Metric.infDist_image (reebFlow_isometry t)
  rw [hA t] at h
  exact h

theorem attracted_subset_closure (A U : Set (ℝ × ℝ × ℝ)) (hA : ReebInvariant A) (hne : A.Nonempty)
    (hatt : AttractedTo A U) : U ⊆ closure A := by
  intro x hx
  have hlim := hatt x hx
  have hconst : (fun t : ℝ => Metric.infDist (reebFlow t x) A)
      = fun _ => Metric.infDist x A := by
    funext t
    exact infDist_reebFlow t A hA x
  rw [hconst] at hlim
  have h0 : Metric.infDist x A = 0 := tendsto_nhds_unique tendsto_const_nhds hlim
  exact (Metric.mem_closure_iff_infDist_zero hne).2 h0

/-- **No proper attracting set for the Reeb flow.** A nonempty closed invariant set A that attracts
    every point of some open neighbourhood U of itself is the whole space. -/
theorem no_proper_attractor (A U : Set (ℝ × ℝ × ℝ)) (hAc : IsClosed A) (hne : A.Nonempty)
    (hinv : ReebInvariant A) (hU : IsOpen U) (hAU : A ⊆ U) (hatt : AttractedTo A U) :
    A = Set.univ := by
  have hsub : U ⊆ A := by
    have h := attracted_subset_closure A U hinv hne hatt
    rwa [hAc.closure_eq] at h
  have hAopen : IsOpen A := by
    have hEq : A = U := Set.Subset.antisymm hAU hsub
    rw [hEq]
    exact hU
  have hcl : IsClopen A := ⟨hAc, hAopen⟩
  exact hcl.eq_univ hne

/-- There is no nonempty compact set invariant under the Reeb flow. -/
theorem no_compact_invariant (A : Set (ℝ × ℝ × ℝ)) (hc : IsCompact A) (hne : A.Nonempty)
    (hinv : ReebInvariant A) : False := by
  obtain ⟨m, hm, hmax⟩ :=
    hc.exists_isMaxOn hne ((continuous_snd.comp continuous_snd).continuousOn)
  have hmem : reebFlow 1 m ∈ A := by
    rw [← hinv 1]
    exact ⟨m, hm, rfl⟩
  have h := isMaxOn_iff.1 hmax _ hmem
  simp [reebFlow, reebR] at h
  linarith

/-! ## The unqualified statement is false: the whole space attracts itself -/

/-- For ANY maps phi_n, A = U = univ satisfies the attraction condition of Part B. So
    "a volume-preserving flow has no attracting set" cannot be true without a size condition. -/
theorem univ_attracts {X : Type*} [PseudoMetricSpace X] (φ : ℕ → X → X) :
    ∀ x ∈ (Set.univ : Set X), ∀ ε > 0, ∃ N : ℕ, ∀ n ≥ N,
      φ n x ∈ Metric.thickening ε (Set.univ : Set X) :=
  fun _ _ _ hε => ⟨0, fun _ _ => Metric.self_subset_thickening hε _ (Set.mem_univ _)⟩

/-! ## Part B: the measure-theoretic theorem -/

/-- **A measure-preserving family cannot have an attracting closed set smaller than its basin.**
    If every phi_n preserves mu, A is closed with mu(thickening R A) < infinity for some R > 0, and A
    attracts every point of U (in the sense: eventually inside every eps-thickening of A), then
    mu(U) <= mu(A). -/
theorem measure_le_of_attractor {X : Type*} [PseudoMetricSpace X] [MeasurableSpace X]
    [OpensMeasurableSpace X] (μ : Measure X) (φ : ℕ → X → X)
    (hφ : ∀ n, MeasurePreserving (φ n) μ μ)
    (A U : Set X) (hAc : IsClosed A) (hfin : ∃ R > 0, μ (Metric.thickening R A) ≠ ∞)
    (hatt : ∀ x ∈ U, ∀ ε > 0, ∃ N : ℕ, ∀ n ≥ N, φ n x ∈ Metric.thickening ε A) :
    μ U ≤ μ A := by
  have hε : ∀ ε > 0, μ U ≤ μ (Metric.thickening ε A) := by
    intro ε hε0
    let E : ℕ → Set X := fun N => {x | x ∈ U ∧ ∀ n ≥ N, φ n x ∈ Metric.thickening ε A}
    have hmono : Monotone E := by
      intro N M hNM x hx
      exact ⟨hx.1, fun n hn => hx.2 n (le_trans hNM hn)⟩
    have hcov : U ⊆ ⋃ N, E N := by
      intro x hx
      obtain ⟨N, hN⟩ := hatt x hx ε hε0
      exact Set.mem_iUnion.2 ⟨N, hx, hN⟩
    have hbound : ∀ N, μ (E N) ≤ μ (Metric.thickening ε A) := by
      intro N
      have hsub : E N ⊆ φ N ⁻¹' Metric.thickening ε A := fun x hx => hx.2 N le_rfl
      calc μ (E N) ≤ μ (φ N ⁻¹' Metric.thickening ε A) := measure_mono hsub
        _ = μ (Metric.thickening ε A) :=
          (hφ N).measure_preimage Metric.isOpen_thickening.measurableSet.nullMeasurableSet
    calc μ U ≤ μ (⋃ N, E N) := measure_mono hcov
      _ = ⨆ N, μ (E N) := hmono.measure_iUnion
      _ ≤ μ (Metric.thickening ε A) := iSup_le hbound
  have ht := tendsto_measure_thickening_of_isClosed hfin hAc
  exact ge_of_tendsto ht (eventually_nhdsWithin_of_forall fun ε hε' => hε ε hε')

/-- Corollary: no attracting closed set of strictly smaller measure than its basin. -/
theorem no_smaller_attractor {X : Type*} [PseudoMetricSpace X] [MeasurableSpace X]
    [OpensMeasurableSpace X] (μ : Measure X) (φ : ℕ → X → X)
    (hφ : ∀ n, MeasurePreserving (φ n) μ μ)
    (A U : Set X) (hAc : IsClosed A) (hfin : ∃ R > 0, μ (Metric.thickening R A) ≠ ∞)
    (hatt : ∀ x ∈ U, ∀ ε > 0, ∃ N : ℕ, ∀ n ≥ N, φ n x ∈ Metric.thickening ε A) :
    ¬ (μ A < μ U) :=
  not_lt.2 (measure_le_of_attractor μ φ hφ A U hAc hfin hatt)

/-- The Reeb flow (translation) preserves Lebesgue measure on R x R x R, which in the Cartesian
    chart (u,v,z) is, up to the constant factor 2, the contact volume. -/
theorem reebFlow_measurePreserving (t : ℝ) :
    MeasurePreserving (reebFlow t) (volume : Measure (ℝ × ℝ × ℝ)) volume := by
  -- `volume` on a product is `volume.prod volume` only up to unfolding, so instance search does not
  -- see it; the two instances below make that explicit (same trick as Mathlib's PolarCoord.lean).
  haveI hRR : (volume : Measure (ℝ × ℝ)).IsAddHaarMeasure :=
    Measure.prod.instIsAddHaarMeasure _ _
  haveI hRRR : (volume : Measure (ℝ × ℝ × ℝ)).IsAddHaarMeasure :=
    Measure.prod.instIsAddHaarMeasure _ _
  exact measurePreserving_add_right volume (t • reebR)

/-! ## Axiom report: each line should read [propext, Classical.choice, Quot.sound] or a subset. -/

#print axioms reebFlow_isometry
#print axioms infDist_reebFlow
#print axioms attracted_subset_closure
#print axioms no_proper_attractor
#print axioms no_compact_invariant
#print axioms univ_attracts
#print axioms measure_le_of_attractor
#print axioms no_smaller_attractor
#print axioms reebFlow_measurePreserving

end ReebNoAttractor
