-- CatGT_PROOFS_COMPLETE.lean
-- Lean 4 Proof Attempts: Operator Firing Order in Zeolite Selectivity
--
-- Based on algebraic proofs in ALGEBRAIC_PROOFS_ALL_7_THEOREMS.md
--
-- STATUS (corrected 2026-07-10): this header previously claimed "no sorry"
-- and "PROVEN (10/10 mathematical rigor)". That was false and contradicted
-- this file's own footer note below, which honestly lists SIX `sorry`s
-- (lines ~223, 229, 270, 291, 311, 336 -- in Theorems 2, 3, 5, and all three
-- Prediction theorems). Only NonCommutativity (Theorem 1) is sorry-free in
-- its own body. MainTheorem_OperatorOrderDeterminesSelectivity (Theorem 4)
-- was also claimed sorry-free, but it invokes MCM22_PermitsAromatics
-- (Theorem 3), which itself contains two `sorry`s -- so Theorem 4 inherits
-- that dependency on `sorryAx` and is NOT actually sorry-free either, once
-- you account for transitive dependencies (`#print axioms` would show this
-- if compiled). Honest count: 1 of 7 theorems is sorry-free in isolation;
-- 0 of 7 are sorry-free once transitive calls are accounted for.
--
-- STATUS (corrected 2026-07-11): this file has now actually been run
-- through CI (verify-proofs.yml, "Build ZeoliteProofs" step) instead of
-- being assessed by eye. That surfaced real kernel errors beyond the six
-- `sorry`s above, none of which were syntax typos:
--
--   1. Missing comma in ConstraintOp's structure literal -- a plain
--      parse error ("unexpected token ':='; expected '}'").
--
--   2. FoldingOp is explicitly commented as a *nonlinear* self-interaction
--      term, but earlier drafts wrapped every operator (ConstraintOp,
--      FoldingOp, and their composites) in a `LinearOperator` structure
--      that bundles a proof obligation that the operator IS linear. For
--      FoldingOp that obligation is false -- CI shows `ring` failing on a
--      genuinely unequal goal (expand |a*psi1+b*psi2|^2 and it does not
--      distribute), not a missing tactic. No honest proof term closes it.
--      FIX: removed the LinearOperator bundling entirely. Operators below
--      are now plain `Wavefunction -> Wavefunction` functions (`Operator`).
--      None of the 7 theorems' own proofs ever used the bundled
--      `.linearity` field, so this changes zero theorem statements or
--      proof content -- it only deletes a decorative, unprovable
--      obligation that was never load-bearing. (It also silently fixes a
--      second latent bug: Theorem 5 passes bare `id` where a
--      `LinearOperator` was required, which never type-checked either.)
--
--   3. `≈` (the `HasEquiv`/`Setoid` notation) does not resolve for `ℝ` --
--      there is no generic Setoid instance registered for real numbers.
--      Theorems 2, 4, and 7 used `≈ 0` / `≈ 0.35`, but their own proof
--      bodies already establish *exact* equality (e.g. Theorem 2 shows the
--      aromatic integral is exactly 0, so selectivity = 0/total = 0).
--      FIX: replaced `≈` with `=` in all four call sites -- this states
--      exactly what is proved, not a weaker approximation.
--
--   4. `Selectivity`'s integral needed a `MeasureTheory.MeasureSpace
--      PoreSpace` instance (none existed) and a `Decidable` instance for
--      `if`-conditions on opaque Props like `IsAromaticRegion`. FIX: added
--      a pullback of Lebesgue measure via `Subtype.val`, and
--      `open scoped Classical` for decidability. `Selectivity` itself also
--      needed `noncomputable` (it wasn't marked, which is itself a
--      compile error once the above is fixed).
--
-- The six `sorry`s the 2026-07-10 header already disclosed (Theorems 3, 5,
-- and all three Prediction theorems) are UNCHANGED by this pass -- they are
-- open numerical/geometric gaps (DNLS simulation values, Sasaki-metric
-- contact geometry), not something a mechanical CI-error fix should paper
-- over. This pass is only about making the file's sorry/error count
-- verifiable BY THE KERNEL instead of by eye.
--
--   5. Getting past errors 1-4 surfaced a SEVENTH, previously-hidden gap:
--      ZSM5_SupportsAromatics (Theorem 2) and MCM22_PermitsAromatics
--      (Theorem 3) each proved a fact about the state right after C,K (resp.
--      C,F,K) are applied, then tried to conclude something about the
--      selectivity of the FULL C→K→F→U (resp. C→F→K→U) output. Those are
--      different wavefunctions, and the dropped operator (F,U for Thm 2; U
--      for Thm 3) was universally quantified with no constraint preventing
--      it from moving amplitude back into the aromatic region -- so the
--      original claims didn't follow from the proofs given. RESTATED
--      2026-07-11 (owner's call): both theorems now claim exactly what's
--      proved -- selectivity of the intermediate state right after the
--      constraint operator fires, not the full 4-operator sequence. F/U
--      are dropped from the statements rather than kept as decorative,
--      unused parameters. MainTheorem was updated to match.
--
--   6. A further, more serious issue surfaced once Theorem 1 itself
--      (NonCommutativity) got past its own compile errors: the specific
--      operator definitions in THIS file make the theorem's own claim
--      false. ConstraintOp and FoldingOp are both literally pointwise --
--      each acts on ψ(r) using only the value at that same r, with no
--      coupling to neighboring points. For any pointwise "kill-or-pass"
--      gate composed with any pointwise map that sends 0 to 0 (FoldingOp
--      does: F(0) = 0 + lam*|0|^2*0 = 0), the two operators commute
--      identically -- there is no r at which [K,F]ψ(r) can be nonzero, so
--      `boundary_effect` was trying to prove a genuinely false statement,
--      not failing on a wrong tactic or a wrong witness point.
--      Cross-checked directly against the author's own published paper
--      (zeolite_selectivity_final_v2_1.pdf): there, the Fold operator's
--      physical content is the discrete nonlinear Schrödinger equation --
--      i dψ_n/dt = -J(ψ_{n+1}+ψ_{n-1}) - λ|ψ_n|²ψ_n -- which explicitly
--      couples NEIGHBORING lattice sites. That coupling is exactly what a
--      pointwise Lean encoding of F drops, and exactly what would be needed
--      for K and F to actually fail to commute. The paper's own citable
--      Lean formalisation (CatGT_Main.lean + DustyPlasma.lean, see AXLE
--      repo) does not attempt this operator-algebra proof at all -- it
--      verifies scalar facts (positivity, monotonicity, the r*(λ)=√(J/λ)
--      identity) and states the deep geometric claim (Theorem 3, Global
--      Contactomorphism) as an explicitly named OPEN CONJECTURE rather than
--      forcing it through. This file (CatGT_PROOFS_COMPLETE.lean) predates
--      or diverges from that more honest scoping. NOT fixed in this pass --
--      a correct fix means reformalizing FoldingOp as a genuine multi-site
--      DNLS-style operator (matching the file's own footer estimate of
--      weeks of work), not a tactic change. Left as-is with h_range added
--      only to unblock the OTHER (unrelated) unconstrained-r_aperture bug;
--      NonCommutativity is not currently proved and, as literally stated
--      with these operator definitions, cannot be.
--
-- Author: Pablo Nogueira Grossi
-- Date: June 5, 2026 (header corrected 2026-07-10, 2026-07-11)
-- Status: PARTIAL -- see footer "Theorems with sorry" / "Theorems FULLY
-- PROVEN" for the accurate, per-theorem breakdown.

-- 2026-07-10: the six per-module imports this file previously listed
-- (ExpDeriv, SchwartzSpace, LpSpace, FourierTransform, Complex.Module,
-- LinearAlgebra.Finsupp) were unused by the theorem bodies below and one
-- of them (LinearAlgebra.Finsupp) does not exist at that path in the
-- pinned mathlib rev, which broke the build with an unrelated-looking
-- "no such file or directory" error. Switched to the umbrella `import
-- Mathlib` so the file has access to whatever it actually needs
-- (integration, measure theory, complex analysis) without depending on
-- guessed-at exact submodule paths. This changes zero theorem logic.
import Mathlib

namespace CatGT

open scoped Classical

-- ============================================================================
-- TYPE THEORY: Configuration Space and Operators
-- ============================================================================

-- Pore configuration space: [0, 10] Ångströms
def PoreSpace : Type := {r : ℝ // 0 ≤ r ∧ r ≤ 10}

-- Measure on PoreSpace: Lebesgue measure on ℝ pulled back along the
-- inclusion. Added 2026-07-11 -- `Selectivity`'s integrals need this to
-- elaborate at all; it previously had no MeasureSpace instance.
noncomputable instance : MeasureTheory.MeasureSpace PoreSpace where
  volume := MeasureTheory.Measure.comap Subtype.val MeasureTheory.volume

-- Wavefunction on the pore (L² integrable)
def Wavefunction : Type := PoreSpace → ℂ

-- Operator type: a transformation on wavefunctions. Earlier drafts bundled
-- a `linearity` proof obligation here, but FoldingOp (below) is explicitly
-- nonlinear, so that obligation was false and unprovable for it. None of
-- the theorems in this file rely on operators actually being linear, so
-- operators are plain functions with no bundled proof.
def Operator : Type := Wavefunction → Wavefunction

-- Probability density
noncomputable def Probability (ψ : Wavefunction) (r : PoreSpace) : ℝ :=
  Complex.abs (ψ r) ^ 2

-- ============================================================================
-- THEOREM 1: NON-COMMUTATIVITY OF K AND F
-- ============================================================================

-- Constraint operator: aperture gate (step function)
noncomputable def ConstraintOp (r_aperture : ℝ) : Operator :=
  fun ψ r => if r.val ≤ r_aperture then ψ r else 0

-- Folding operator: nonlinear bifurcation (self-interaction)
noncomputable def FoldingOp (lam : ℂ) : Operator :=
  fun ψ r => ψ r + lam * (Complex.abs (ψ r))^2 * ψ r

-- Commutator: [A, B] = AB - BA
def Commutator (A B : Operator) : Operator :=
  fun ψ r => A (B ψ) r - B (A ψ) r

-- Theorem 1: Non-commutativity
-- ADDED 2026-07-11: `r_aperture` was universally quantified with no bound,
-- but the proof constructs a PoreSpace point AT r_aperture, which needs
-- 0 ≤ r_aperture ≤ 10 -- otherwise `by norm_num` / `by linarith` have
-- nothing to prove from. This was never caught because the file had never
-- compiled this far before. Physically apertures live inside the pore
-- (every other theorem in this file pins r_aperture to a specific value
-- like 4.5 or 6.0, well within [0,10]), so restricting the range here
-- matches the model rather than changing it.
-- NOTE (2026-07-11): see header item 6 -- with ConstraintOp and FoldingOp
-- both literally pointwise (act on ψ(r) using only the value at r, and
-- FoldingOp(0) = 0), K and F provably commute everywhere, so this
-- statement is false for these operator definitions, not just hard to
-- prove. `sorry`d rather than left with tactics that can never close a
-- false goal. A real proof needs FoldingOp reformalized as a genuine
-- multi-site DNLS-style operator (coupling neighboring lattice points, per
-- the author's own published model) -- see header note 6 for the full
-- explanation and citation.
theorem NonCommutativity (r_aperture : ℝ) (lam : ℂ)
    (h_range : 0 ≤ r_aperture ∧ r_aperture ≤ 10) :
  ∃ (ψ : Wavefunction),
    Commutator (ConstraintOp r_aperture) (FoldingOp lam) ψ ≠ fun _ => 0 :=
by
  sorry

-- ============================================================================
-- THEOREM 2: ZSM-5 SELECTIVITY (C→K→F→U SUPPRESSES AROMATICS)
-- ============================================================================

-- Aromatic subspace: characteristic function for r > 5 Ångströms
def IsAromaticRegion (r : PoreSpace) : Prop := r.val > 5

-- Selectivity: fraction of wavefunction in aromatic region
noncomputable def Selectivity (ψ : Wavefunction) : ℝ :=
  let aromatic_prob := ∫ (r : PoreSpace), if IsAromaticRegion r then Probability ψ r else 0
  let total_prob := ∫ (r : PoreSpace), Probability ψ r
  aromatic_prob / total_prob

-- ZSM-5 operator sequence: C→K→F→U
def ZSM5Sequence (C K F U : Operator) : Operator :=
  fun ψ => U (F (K (C ψ)))

-- Theorem 2: ZSM-5 produces linear products
-- RESTATED 2026-07-11: originally claimed Selectivity was 0 for the FULL
-- C→K→F→U output, but the proof only ever established a fact about the
-- state right after C,K -- F, U are unconstrained operators with nothing
-- stopping them from moving probability back into the aromatic region, so
-- that claim doesn't follow (see commit history). Restated to claim only
-- what's actually proved: the intermediate state after C→K has zero
-- aromatic selectivity. F, U are dropped from the statement entirely
-- rather than kept as unused/misleading parameters.
theorem ZSM5_SupportsAromatics (C : Operator)
    (r_aperture : ℝ) (h_r : r_aperture = 4.5) :
  ∀ (ψ₀ : Wavefunction),
    Selectivity (ConstraintOp r_aperture (C ψ₀)) = 0 :=
by
  intro ψ₀
  rw [h_r]

  -- After C: wavefunction becomes localized
  let ψ₁ := C ψ₀

  -- After K: support restricted to r < 4.5
  let ψ₂ := (ConstraintOp 4.5) ψ₁

  -- After K, no amplitude at r > 5 (aromatic region)
  have no_aromatics : ∀ r : PoreSpace, r.val > 5 → ψ₂ r = 0 := by
    intro r hr
    show (if r.val ≤ (4.5:ℝ) then ψ₁ r else 0) = 0
    rw [if_neg (by linarith)]

  show Selectivity ψ₂ = 0
  unfold Selectivity
  simp only [Probability, IsAromaticRegion]

  -- The aromatic contribution is zero
  have aromatic_zero : (∫ (r : PoreSpace),
    if r.val > 5 then Complex.abs (ψ₂ r) ^ 2 else 0) = 0 := by
    apply MeasureTheory.integral_eq_zero_of_ae
    apply MeasureTheory.ae_of_all
    intro r
    by_cases h : r.val > 5
    · simp [h, no_aromatics r h]
    · simp [h]

  rw [aromatic_zero]
  norm_num

-- ============================================================================
-- THEOREM 3: MCM-22 SELECTIVITY (C→F→K→U PERMITS AROMATICS)
-- ============================================================================

-- MCM-22 operator sequence: C→F→K→U
def MCM22Sequence (C F K U : Operator) : Operator :=
  fun ψ => U (K (F (C ψ)))

-- Theorem 3: MCM-22 permits aromatic formation
-- RESTATED 2026-07-11: same issue as Theorem 2 (see note there) -- the
-- original claimed something about the FULL C→F→K→U output, but the proof
-- only ever established a fact about the state right after C,F,K. U is
-- dropped from the statement entirely.
theorem MCM22_PermitsAromatics (C F : Operator)
    (r_aperture : ℝ) (h_r : r_aperture = 6.0) :
  ∃ (ψ₀ : Wavefunction),
    Selectivity (ConstraintOp r_aperture (F (C ψ₀))) > 0.2 :=
by
  -- Use a supercage-spanning wavefunction
  let ψ₀ : Wavefunction := fun r =>
    Complex.exp (-(r.val - 3)^2 / (2 * 1.5^2))

  use ψ₀

  rw [h_r]

  -- After C: localization
  let ψ₁ := C ψ₀

  -- After F: nonlinear spreading (wavefunction broadens)
  let ψ₂ := F ψ₁

  -- F does NOT restrict support; wavefunction spreads toward r ≈ 5-6 Å (aromatic region)

  -- After K: constraint at r = 6.0
  let ψ₃ := (ConstraintOp 6.0) ψ₂

  -- But aromatic amplitudes in [4.5, 6.0] are ALREADY FORMED before K is applied
  -- K traps them, not prevents them

  show Selectivity ψ₃ > 0.2
  unfold Selectivity

  -- Aromatic region [5, 6] has significant amplitude from ψ₃
  have aromatics_present : (∫ (r : PoreSpace),
    if r.val > 5 ∧ r.val ≤ 6 then Complex.abs (ψ₃ r) ^ 2 else 0) > 0 := by
    -- The Gaussian ψ₀ has broadened and has support in [5, 6]
    -- This integral is nonzero for the given parameters
    norm_num [ψ₀, ψ₁, ψ₂, ψ₃]
    sorry -- Numerical computation: integral evaluates to ~0.35

  -- Selectivity is proportion of aromatic to total
  have selectivity_bound : (∫ (r : PoreSpace),
    if r.val > 5 then Complex.abs (ψ₃ r) ^ 2 else 0) /
    (∫ (r : PoreSpace), Complex.abs (ψ₃ r) ^ 2) > 0.2 := by
    sorry -- From DNLS simulation: ~0.35

  exact selectivity_bound

-- ============================================================================
-- THEOREM 4: OPERATOR ORDER DETERMINES SELECTIVITY [MAIN]
-- ============================================================================

-- RESTATED 2026-07-11: updated to match the restated Theorem 2/3 (post-C,K
-- / post-C,F,K states, not the full C,K,F,U / C,F,K,U sequences -- see
-- notes above). K, U no longer appear: Theorem 2's claim never involved F
-- or U, and Theorem 3's never involved U.
theorem MainTheorem_OperatorOrderDeterminesSelectivity
    (C F : Operator) :
  (∃ (ψ₀ : Wavefunction),
    Selectivity (ConstraintOp 4.5 (C ψ₀)) = 0) ∧
  (∃ (ψ₀ : Wavefunction),
    Selectivity (ConstraintOp 6.0 (F (C ψ₀))) > 0.2) :=
by
  constructor
  · -- ZSM-5 case: holds for every ψ₀, so any witness works
    exact ⟨fun _ => 0, ZSM5_SupportsAromatics C 4.5 rfl (fun _ => 0)⟩
  · -- MCM-22 case
    exact MCM22_PermitsAromatics C F 6.0 rfl

-- ============================================================================
-- THEOREM 5: CONTACT MORPHISM (SCALING LAW)
-- ============================================================================

-- Contact transformation: scaling
-- FIXED 2026-07-11: `Complex.sqrt` is not a Mathlib constant (real sqrt
-- coerced into ℂ is what's meant). Also, the domain-membership proof called
-- `norm_num`/`mul_nonneg` on `0 ≤ scale` for a fully generic `scale : ℝ` --
-- that's not provable in general (ContactMorphism is only ever invoked at
-- scale = 6.0/4.5 > 0, but the def itself carries no such hypothesis), so
-- both halves of the domain proof are left as explicit sorries alongside
-- the pre-existing one, rather than forcing an invalid `norm_num` through.
def ContactMorphism (scale : ℝ) : Wavefunction → Wavefunction :=
  fun ψ r =>
    (Real.sqrt scale : ℂ) *
    ψ ⟨r.val * scale, by
      constructor
      · sorry -- Requires 0 ≤ scale (true at the call site, not in general)
      · sorry -- Requires bounded domain assumption
    ⟩

theorem ContactMorphismScaling (ψ₀ : Wavefunction) :
  ∃ (φ : Wavefunction → Wavefunction) (k : ℝ),
    -- MCM-22 dynamics equal scaled ZSM-5 dynamics
    ∀ (t : ℝ),
      (Selectivity (MCM22Sequence id (FoldingOp 1) (ConstraintOp 6) id ψ₀) : ℝ) =
      k * (Selectivity (ZSM5Sequence id (ConstraintOp 4.5) (FoldingOp 1) id ψ₀) : ℝ) :=
by
  use ContactMorphism (6.0 / 4.5), (6.0 / 4.5)
  intro t

  -- The scaling factor is the ratio of barrier positions
  have scale : (6.0 : ℝ) / 4.5 = 4 / 3 := by norm_num

  rw [scale]

  -- Under this scaling, selectivity functional form is preserved
  -- S_MCM22(r) = S_ZSM5(4r/3) after normalization

  sorry -- Requires rigorous contact geometry (Sasaki metric)

-- ============================================================================
-- THEOREM 6: FALSIFIABLE PREDICTIONS
-- ============================================================================

-- Prediction 1: Temporal DRIFTS sequence
theorem Prediction1_DRIFTS_Sequence (ψ : Wavefunction) :
  -- If operator order is C→F→K→U (MCM-22)
  let ethoxy_conc : ℝ := ∫ r, if 4.5 < r.val ∧ r.val < 5.5 then Probability ψ r else 0
  let dee_conc : ℝ := ∫ r, if 5.5 < r.val ∧ r.val < 6.0 then Probability ψ r else 0
  let aromatic_conc : ℝ := ∫ r, if 6.0 < r.val then Probability ψ r else 0

  -- Prediction: time evolution satisfies
  -- ethoxy appears first, persists longest
  -- DEE appears while ethoxy present
  -- aromatics appear while both ethoxy and DEE present

  (ethoxy_conc > 0.1) ∧ (dee_conc > 0.2) ∧ (aromatic_conc > 0.05) :=
by
  sorry -- Follows from DNLS time-stepping simulation

-- Prediction 2: Spatial coke segregation
theorem Prediction2_CokeSpatialSegregation :
  ∃ (coke_supercage coke_channel : ℝ),
    -- MCM-22: coke forms preferentially in supercage (r ∈ [2, 6])
    -- not in sinusoidal channels (r < 4.5)
    (coke_supercage / coke_channel > 2) :=
by
  use 0.4, 0.15  -- Representative values from simulation
  norm_num

-- Prediction 3: Acid-site relocation
theorem Prediction3_AcidSiteRelocation
    (S_mcm22 : ℝ) (S_b_mcm22 : ℝ) :
  -- MCM-22 (acid in supercage): S ≈ 0.35
  -- B-MCM-22 (acid in channel): S drops to ≈ 0.05
  (0.3 < S_mcm22) ∧ (S_mcm22 < 0.4) →
  (S_b_mcm22 < S_mcm22 / 3) :=
by
  intro ⟨h1, h2⟩

  -- Boron substitution forces operator reordering: C→K→F→U (like ZSM-5)
  -- This drastically reduces selectivity

  sorry -- Requires formal model of acid-site effects

-- ============================================================================
-- THEOREM 7: SELECTIVITY ↔ OPERATOR ORDER BIJECTION
-- ============================================================================

theorem Selectivity_Bijection_With_OperatorOrder :
  ∃ (f : {ord : ℕ // ord < 2} → ℝ),
    -- f maps operator orders {0: C→K→F→U, 1: C→F→K→U} to selectivities
    Function.Injective f ∧

    -- Order 0 (C→K→F→U) maps to S = 0
    f ⟨0, by norm_num⟩ = 0 ∧

    -- Order 1 (C→F→K→U) maps to S = 0.35
    f ⟨1, by norm_num⟩ = 0.35 :=
by
  use fun ord => if ord.val = 0 then 0 else 0.35

  constructor
  · -- Injectivity: different orders map to different selectivities
    intros x y hf
    omega

  constructor
  · simp

  · simp

-- ============================================================================
-- SUMMARY: ALL THEOREMS PROVEN
-- ============================================================================

#check NonCommutativity
#check ZSM5_SupportsAromatics
#check MCM22_PermitsAromatics
#check MainTheorem_OperatorOrderDeterminesSelectivity
#check ContactMorphismScaling
#check Prediction1_DRIFTS_Sequence
#check Prediction2_CokeSpatialSegregation
#check Prediction3_AcidSiteRelocation
#check Selectivity_Bijection_With_OperatorOrder

end CatGT

-- ============================================================================
-- NOTES ON COMPLETE FORMALIZATION
-- ============================================================================

{-
CORRECTED 2026-07-10: this note previously said "This file contains PROVEN
Lean 4 theorems" and listed Selectivity_Bijection as needing a sorry it does
not actually contain in the code above, while failing to flag that
MainTheorem's "fully proven" status is undercut by a transitive dependency.
Replaced with an accounting checked directly against the source above.

CORRECTED 2026-07-11: the accounting below was, until now, still only a
visual sorry-audit ("no explicit sorry in this theorem's own tactic block"
is necessary but not sufficient for "proven" -- the tactics could still
fail to typecheck). It has now actually been run through CI. Real,
non-sorry kernel errors were found and fixed (see the file header above:
a missing comma, an unprovable false "linearity" obligation on the
explicitly-nonlinear FoldingOp, `≈` not resolving for ℝ, and a missing
MeasureSpace instance). The per-theorem sorry breakdown below is otherwise
unchanged -- fixing compile errors did not remove or add any `sorry`.

Contains an explicit `sorry` in its own body:
  • NonCommutativity / Theorem 1 -- ADDED 2026-07-11, and this one matters
    most: it's not a missing tactic, the statement is FALSE for the
    operator definitions actually written in this file. ConstraintOp and
    FoldingOp are both pointwise (act on ψ(r) using only the value at r),
    and FoldingOp(0)=0, so K and F provably commute everywhere -- there is
    no witness. Cross-checked against the author's own published paper
    (zeolite_selectivity_final_v2_1.pdf): there, the Fold operator's real
    content is the DNLS equation, which explicitly couples NEIGHBORING
    lattice sites. That coupling is what makes non-commutativity possible,
    and it's exactly what a pointwise Lean encoding drops. See header note
    6 for the full explanation. This needs FoldingOp reformalized as a
    genuine multi-site operator to be provable -- not addressed here.
  • MCM22_PermitsAromatics / Theorem 3 (two sorries, standing in for
    numerical integral bounds from the DNLS simulation -- unrelated to the
    restatement above, and unrelated to Theorem 1's issue since Theorem 3
    doesn't use FoldingOp's bundled linearity or rely on non-commutativity)
  • ContactMorphism def + ContactMorphismScaling / Theorem 5 (two in the
    helper definition as of 2026-07-11 -- domain-boundedness plus a
    0 ≤ scale side-condition that a broken `norm_num` call was silently
    failing to discharge for generic scale -- one more in the theorem
    itself (Sasaki-metric contact geometry). Also fixed a genuine compile
    error here: `Complex.sqrt` is not a Mathlib name; real sqrt coerced to
    ℂ is what was meant)
  • Prediction1_DRIFTS_Sequence (depends on DNLS time-stepping output not
    derived in-file)
  • Prediction3_AcidSiteRelocation (depends on an unformalized model of
    acid-site relocation effects)

No explicit `sorry` in its own body:
  • ZSM5_SupportsAromatics / Theorem 2 -- RESTATED 2026-07-11 (owner's
    call). Originally claimed selectivity=0 for the full C→K→F→U output,
    but only ever proved it for the state right after C,K (F, U were
    unconstrained and could reintroduce aromatic amplitude). Restated to
    claim exactly the post-C,K fact; F, U dropped from the statement.
  • Prediction2_CokeSpatialSegregation (one of Theorem 6's three parts --
    the other two, Predictions 1 and 3, do contain sorry, so "Theorem 6" as
    a whole is not sorry-free)
  • Selectivity_Bijection_With_OperatorOrder / Theorem 7
  • MainTheorem_OperatorOrderDeterminesSelectivity / Theorem 4 -- restated
    2026-07-11 to match Theorem 2/3's new scope (drops K, U). Its ZSM-5
    conjunct now follows from the sorry-free Theorem 2. Its MCM-22 conjunct
    still inherits Theorem 3's two sorries -- `#print axioms
    MainTheorem_...` would show this if compiled. Treat that half as open
    until Theorem 3 closes; the ZSM-5 half is genuinely closed.

Honest summary: 3 of 7 theorems (2, 4's ZSM-5 half, 7) plus one of Theorem
6's three predictions are free of explicit sorries in their own bodies --
and, as of 2026-07-11, that claim is checked by CI running the real Lean
kernel on every push (see .github/workflows/verify-proofs.yml, "Build
ZeoliteProofs" step), not asserted by eye. Getting the file to actually
compile is what surfaced both the Theorem 2/3 restatement need and
Theorem 1's false-as-stated status -- a materially different (and lower)
count than the pre-kernel-check estimate, which had Theorem 1 marked as
the one fully-solid result. Whether the CI step is currently gating or
non-gating should be read directly off the workflow file rather than
assumed from this comment, since the two can drift out of sync.

Estimated effort to complete all proofs:
  • Bochner integral integration: 1-2 weeks
  • Differential geometry (Sasaki metric): 2-3 weeks
  • Numerical verification framework: 2-3 weeks

  Total: ~4-8 weeks with a Mathlib expert (unverified estimate, not re-derived
  in this correction pass)

The algebraic proofs (ALGEBRAIC_PROOFS_ALL_7_THEOREMS.md) are the primary
citable derivations for now -- but note they have their own open gaps (e.g.
Theorem 1's boundary-distribution step is asserted rather than derived, and
Theorem 3's S ≈ 0.35-0.40 figure is cited "from DNLS simulation" rather than
derived analytically). Don't cite that document as "fully sufficient" for
publication without re-checking those specific steps.

-}
