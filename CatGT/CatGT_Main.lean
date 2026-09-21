/-
  CatGT_Main.lean
  Lean 4 formalization supporting "The Self-Trapping Selectivity
  Principle: Zeolite Shape-Selectivity and Pt-Sn Ensemble Effects"
  Central theorem: Self-Trapping Selectivity Principle (Theorem 1)

  Author  : Pablo Nogueira Grossi
  ORCID   : 0009-0000-6496-2186
  Affil   : G6 LLC, Newark, NJ, USA
  Date    : May 2026 · corrected July 2026 · corrected September 2026
            · renamed September 2026 (header/comments only, no
            re-verification needed -- comments do not affect
            compilation or any theorem's content)
  Zenodo  : 10.5281/zenodo.22851704 (V5; until 2026-09-21 this line cited 19117399, a different work)
  AXLE    : github.com/TOTOGT/AXLE

  Renamed September 2026: this file previously called itself
  "Catalytic Generative Theory (CatGT)," named its central theorem
  the "Helical Selectivity Principle (HSP)," and described itself as
  "Part I of the GOMC Opus" with a "Relation to GTCT" (an overarching
  "Generative Temporal Contact Theory"). The paper this file supports
  dropped all of that framing on 2026-09-19, retitled around its two
  actual catalytic test cases -- this header is updated to match.
  Nothing below this point changed as a result: no theorem, no proof,
  no definition -- only what the file calls itself and its theorem.

  Sorry audit (kernel-checked, Lean v4.33 / Mathlib, live.lean-lang.org):
    ✓ ipr_between_zero_and_one     — closed  (IPR ∈ (0,1], Cauchy-Schwarz)
    ✓ criticalRadius_pos           — closed
    ✓ criticalRadius_antitone      — closed
    ✓ helical_selectivity          — closed  ← Theorem 1(i) core inequality
    ✓ selectivityFactor_eq         — closed
    ✓ reeb_alpha_eq_one            — closed  (α(R)=1, the actual pairing — NEW Sep 2026)
    ✓ reeb_orbit_advances          — closed  (corrected content, same name — Sep 2026)
    ✓ dnlsNorm_nonneg              — closed  (discrete norm ≥ 0)
    ✓ catgt_dm3_disk               — closed  (disk membership facts)
    ✓ ensemble_scaling_forms_diverge — closed  ((1-x)² ≠ 1-x² at x=1/2)
    ✓ relaxStep_fixed              — closed  (r_star is a fixed point — NEW Sep 2026)
    ✓ relaxStep_contracts          — closed  (Lyapunov decay, one step — NEW Sep 2026)
    ✓ relax_iterate_dist           — closed  (Lyapunov decay, iterated — NEW Sep 2026)

  Total: 13 closed · 0 admits · 0 sorries · 0 vacuous.

  Corrections (July 2026), each verified in a real Lean kernel:
   - `λ`/`hλ` identifiers → `lam`/`hlam` (Lean 4 reserves `λ`).
   - `Complex.abs _` → `‖·‖` (Complex.abs removed in current Mathlib).
   - criticalRadius_antitone: unbound `hλ₁` in the signature → proper binders.
   - THREE previously VACUOUS theorems replaced by real, non-vacuous ones:
       dnls_norm_conservation_ideal (: True)          → dnlsNorm_nonneg
       reeb_orbit_is_integral       (: 1 = 1)         → reeb_orbit_advances
       catgt_dm3_transport          (: ∃ shape, True) → catgt_dm3_disk
       ensemble_scaling             (: ∃ s, s=(1-x)²) → ensemble_scaling_forms_diverge

  Corrections (September 2026). Kernel-verified 2026-09-20: this file
  compiles with exit 0 and zero errors under Lean 4.33.0-rc1 against
  Mathlib v4.33.0-rc1, nineteen minor versions above the v4.14.0 the
  repository pins; the only diagnostics are four unused-binder linter
  warnings (hJ, hlam, hN, hr). Axiom report appended below and written
  to CatGT_Main.axioms.txt. The corrections themselves:
   - dnlsStep: removed two erroneous leading minus signs on `coupling`
     and `onsite`. The stepper had been evolving iψ̇=+J(...)+λ|ψ|²ψ,
     the opposite sign convention from this project's own stated PDE
     iψ̇=-J(ψ_{n+1}+ψ_{n-1})-λ|ψ_n|²ψ_n. Not load-bearing for any of the
     nine theorems above (none use dnlsStep/dnlsIterate, only the
     static dnlsNorm) — but if this stepper generated any cited
     simulation numbers, they came from the wrong dynamics.
   - reeb_orbit_advances: the pre-Sep-2026 version proved a fact about
     an unrelated scalar potential F(r,θ,z)=z-r²θ, not the actual
     contact-form pairing α(R)=1 the theorem's name and comment claimed.
     dF = dz-r²dθ-2rθ·dr ≠ α_cat = dz-r²dθ (extra -2rθ·dr term), and the
     r²θ choice never entered the old proof's computation at all — any
     F(r,θ,z)=z+g(r,θ) for any g would have "proved" the identical
     result. Replaced with alphaCat (the real 1-form as a pairing on
     tangent vectors, not a potential) and reebR = (0,0,1); the new
     reeb_alpha_eq_one is the actual defining fact, and reeb_orbit_
     advances now derives its z-advance claim FROM that pairing, kept
     under the same name since index.html and paper.tex both cite it.
  Length-scale change (2026-09-20) — kernel-checked on Lean 4.32.0 /
  Mathlib v4.32.0 by the file's owner (`lake env lean`, run from the
  geometry checkout): no errors, all 13 `#print axioms` on [propext,
  Classical.choice, Quot.sound], warnings only for unused binders (ha, hJ,
  hlam, hN, hr). NOT yet checked under the v4.14.0 pin that this repo's CI
  uses -- that run is the arbiter for this repo. The paragraphs above
  describe the file as it was compiled earlier on 2026-09-20 (dimensionless
  criticalRadius := √(J/λ), Claude-side check on 4.33.0-rc1). This edit adds the
  explicit length scale `a > 0` to match Theorem 1's 2026-09-19 correction
  on the paper's page, r*(λ) = a·√(J/λ): `criticalRadius`, `withinAttractor`,
  `criticalRadius_pos`, `criticalRadius_antitone`, `helical_selectivity`,
  `selectivityFactor` and `selectivityFactor_eq` all gain `a` and `ha`;
  helical_selectivity's hypothesis becomes r² ≤ a²·(J/λ); and
  selectivityFactor_eq now states σ = 1 - (J/λ)(a/r_pore)², the form the
  paper's fit uses. No theorem was renamed. The statements checked are
  exactly the ones printed by the #check block at the bottom of this file.
  What is and is not established: this fixes the Lean file to carry the
  length scale the paper's Theorem 1 states; it does not show r* = a√(J/λ)
  is the right physical scaling (see the open item below).
  Still OPEN (honest prose, NOT theorems): Corollary 2 disk optimality
  (κ_stab maximiser); which Pt–Sn law ((1-x)² vs 1-(r*/r_pore)²) is
  physical; whether r* = a√(J/λ) is the right DNLS self-trapping scaling at
  all — the continuum DNLS ground state has width ≈ 4Ja/(λP) at fixed norm
  P = Σ|ψ|² (linear in J/λ, not √), and ≈ a√(2J/λ)/A only at fixed peak
  amplitude A; the √ form therefore encodes an unstated normalisation
  choice (2026-09-20, hand-derived and checked numerically on a 400-site
  chain, not yet in the paper). Full continuous DNLS norm conservation
  (ODE) — open, awaits Mathlib ODE.

  Addition (September 2026), §9, NOT yet re-verified in a kernel: a
  genuinely dissipative relaxation map (relaxStep) with a real Lyapunov
  decay argument (relaxStep_contracts, relax_iterate_dist), explicitly
  separate from and not required to preserve the contact structure R
  respects. This is the actual attracting mechanism the Reeb flow
  cannot supply — added, not substituted for R, which remains correct
  as a structural (non-attracting) fact about α_cat.
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

/-- Critical (self-trapping) radius r*(λ) = a·√(J/λ), where `a > 0` is the
    lattice-spacing length scale. J and λ are both energies, so J/λ is
    dimensionless and `a` is what gives r* the dimension of a length
    (Theorem 1's 2026-09-19 correction on the paper's page). NOTE: this is
    the *definition* the theorems below are stated against; that r* is the
    physically correct DNLS self-trapping width is a separate claim, and
    depends on what is held fixed (see the 2026-09-20 note in the header). -/
noncomputable def criticalRadius (a J lam : ℝ) (ha : 0 < a) (hJ : 0 < J)
    (hlam : 0 < lam) : ℝ :=
  a * Real.sqrt (J / lam)

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

def withinAttractor (N : ℕ) (γ : ReactionPathway N) (a J lam : ℝ)
    (ha : 0 < a) (hJ : 0 < J) (hlam : 0 < lam) : Prop :=
  ∀ t : ℝ, γ.r t ≤ criticalRadius a J lam ha hJ hlam

/-! ## §4  Self-Trapping Selectivity Principle — Theorem 1 -/

/-- The critical radius r*(λ) is strictly positive. -/
theorem criticalRadius_pos (a J lam : ℝ) (ha : 0 < a) (hJ : 0 < J)
    (hlam : 0 < lam) :
    0 < criticalRadius a J lam ha hJ hlam := by
  unfold criticalRadius
  exact mul_pos ha (Real.sqrt_pos_of_pos (div_pos hJ hlam))

/-- r*(λ) decreases as λ increases: stronger binding → tighter selectivity. -/
theorem criticalRadius_antitone (a : ℝ) (ha : 0 < a) (J : ℝ) (hJ : 0 < J)
    (lam1 lam2 : ℝ) (h1 : 0 < lam1) (h2 : 0 < lam2) (hle : lam1 ≤ lam2) :
    criticalRadius a J lam2 ha hJ h2 ≤ criticalRadius a J lam1 ha hJ h1 := by
  unfold criticalRadius
  have h : J / lam2 ≤ J / lam1 := by gcongr
  exact mul_le_mul_of_nonneg_left (Real.sqrt_le_sqrt h) ha.le

/-- **Self-Trapping Selectivity Principle** — formal core of Theorem 1.
    r² ≤ a²·(J/λ) ⟹ r ≤ r*(λ) = a·√(J/λ).
    NOTE (what this does and does not say): the hypothesis is the squared
    form of the conclusion, so this is the equivalence "r ≤ r* ⟸ r² ≤ r*²"
    for r ≥ 0, i.e. sqrt-monotonicity. It does NOT derive confinement from
    any DNLS dynamics; that is Theorem 1(ii)'s open content. -/
theorem helical_selectivity (a J lam : ℝ) (ha : 0 < a) (hJ : 0 < J)
    (hlam : 0 < lam) (r_state : ℝ) (hr : 0 ≤ r_state)
    (h_confined : r_state ^ 2 ≤ a ^ 2 * (J / lam)) :
    r_state ≤ criticalRadius a J lam ha hJ hlam := by
  unfold criticalRadius
  have h1 : r_state ≤ Real.sqrt (a ^ 2 * (J / lam)) := by
    rw [← Real.sqrt_sq hr]; exact Real.sqrt_le_sqrt h_confined
  have h2 : Real.sqrt (a ^ 2 * (J / lam)) = a * Real.sqrt (J / lam) := by
    rw [Real.sqrt_mul (sq_nonneg a), Real.sqrt_sq ha.le]
  rw [h2] at h1
  exact h1

/-- Selectivity factor σ = 1 - (r*/r_pore)² = 1 - (J/λ)(a/r_pore)². -/
noncomputable def selectivityFactor (a J lam r_pore : ℝ)
    (ha : 0 < a) (hJ : 0 < J) (hlam : 0 < lam) (hr : 0 < r_pore) : ℝ :=
  1 - (criticalRadius a J lam ha hJ hlam / r_pore) ^ 2

theorem selectivityFactor_eq (a J lam r_pore : ℝ)
    (ha : 0 < a) (hJ : 0 < J) (hlam : 0 < lam) (hr : 0 < r_pore) :
    selectivityFactor a J lam r_pore ha hJ hlam hr
      = 1 - (J / lam) * (a / r_pore) ^ 2 := by
  unfold selectivityFactor criticalRadius
  have hs : Real.sqrt (J / lam) ^ 2 = J / lam :=
    Real.sq_sqrt (div_nonneg hJ.le hlam.le)
  have hkey : (a * Real.sqrt (J / lam) / r_pore) ^ 2
      = (J / lam) * (a / r_pore) ^ 2 := by
    calc (a * Real.sqrt (J / lam) / r_pore) ^ 2
        = Real.sqrt (J / lam) ^ 2 * (a / r_pore) ^ 2 := by ring
      _ = (J / lam) * (a / r_pore) ^ 2 := by rw [hs]
  rw [hkey]

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

/-! ## §6  Reeb vector field of the contact structure -/

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
    z, not helices (see the paper's own 2026-09-19 correction notes,
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

/-! ## §9  Dissipative relaxation toward r*(λ) — NOT the Reeb flow

    Section 6's R = ∂_z is the genuine Reeb field of α_cat, but a Reeb
    flow preserves α∧dα (hence contact volume) and so cannot have an
    attracting set — no choice of contact form changes this. If Theorem
    1's confinement claim is to be a genuine *dynamical* attraction
    rather than a re-grounding in DNLS self-trapping alone (the route
    taken on the paper's 2026-09-19 correction), it needs an
    explicitly different, explicitly dissipative vector field — one
    that is NOT required to preserve α_cat, and does not claim to be.
    This section builds exactly that, honestly labeled as a separate
    mechanism from R, modeling the physically real case where a nascent
    intermediate relaxes toward the self-trapped width via lattice/
    phonon coupling (an open-system correction to the idealized closed
    DNLS equation) rather than starting there exactly. -/

/-- The discrete radial relaxation map: one Euler step of the ODE
    ṙ = -k(r - r_star), with relaxation rate k. Explicitly dissipative —
    distinct from, and not required to preserve, the contact structure
    that R = ∂_z respects. -/
def relaxStep (k r_star : ℝ) (r : ℝ) : ℝ := r - k * (r - r_star)

/-- r_star is a fixed point of the relaxation map. -/
theorem relaxStep_fixed (k r_star : ℝ) : relaxStep k r_star r_star = r_star := by
  unfold relaxStep; ring

/-- **Lyapunov decay, one step.** For 0 < k < 2, relaxation strictly
    decreases the squared distance to r_star, for any r ≠ r_star — the
    genuine dynamical attraction the Reeb flow structurally cannot
    supply. This is a real contraction, checked directly, not asserted. -/
theorem relaxStep_contracts (k r_star r : ℝ) (hk0 : 0 < k) (hk2 : k < 2)
    (hr : r ≠ r_star) :
    (relaxStep k r_star r - r_star) ^ 2 < (r - r_star) ^ 2 := by
  have heq : relaxStep k r_star r - r_star = (1 - k) * (r - r_star) := by
    unfold relaxStep; ring
  have hsq_pos : 0 < (r - r_star) ^ 2 := by
    have hne : r - r_star ≠ 0 := sub_ne_zero.mpr hr
    positivity
  have hk_sq : (1 - k) ^ 2 < 1 := by nlinarith [mul_pos hk0 (sub_pos.mpr hk2)]
  calc (relaxStep k r_star r - r_star) ^ 2
      = (1 - k) ^ 2 * (r - r_star) ^ 2 := by rw [heq]; ring
    _ < 1 * (r - r_star) ^ 2 := mul_lt_mul_of_pos_right hk_sq hsq_pos
    _ = (r - r_star) ^ 2 := by ring

/-- **Lyapunov decay, iterated.** Distance to r_star after n relaxation
    steps shrinks geometrically as |1-k|ⁿ · |r₀ - r_star| — genuine
    convergence to the fixed point as n→∞ (for 0<k<2, |1-k|<1), proved
    directly by induction rather than asserted. This is the actual
    attractor claim; Theorem 1(ii)'s DNLS self-trapping (energy
    conservation, exact solitons) is a separate, complementary
    mechanism, not this one. -/
theorem relax_iterate_dist (k r_star r : ℝ) (n : ℕ) :
    |(relaxStep k r_star)^[n] r - r_star| = |1 - k| ^ n * |r - r_star| := by
  induction n with
  | zero => simp
  | succ n ih =>
    rw [Function.iterate_succ_apply']
    have heq : relaxStep k r_star ((relaxStep k r_star)^[n] r) - r_star
             = (1 - k) * ((relaxStep k r_star)^[n] r - r_star) := by
      unfold relaxStep; ring
    rw [heq, abs_mul, ih, pow_succ]
    ring

/-! ## §8  Summary of verified claims -/

#check @ipr_between_zero_and_one
#check @helical_selectivity
#check @criticalRadius_pos
#check @criticalRadius_antitone
#check @selectivityFactor_eq
#check @reeb_alpha_eq_one
#check @reeb_orbit_advances
#check @dnlsNorm_nonneg
#check @catgt_dm3_disk
#check @ensemble_scaling_forms_diverge
#check @relaxStep_fixed
#check @relaxStep_contracts
#check @relax_iterate_dist

#print axioms ipr_between_zero_and_one
#print axioms helical_selectivity
#print axioms criticalRadius_pos
#print axioms criticalRadius_antitone
#print axioms selectivityFactor_eq
#print axioms reeb_alpha_eq_one
#print axioms reeb_orbit_advances
#print axioms dnlsNorm_nonneg
#print axioms catgt_dm3_disk
#print axioms ensemble_scaling_forms_diverge
#print axioms relaxStep_fixed
#print axioms relaxStep_contracts
#print axioms relax_iterate_dist
