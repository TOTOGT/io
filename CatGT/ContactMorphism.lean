/-
  ContactMorphism.lean — formal core of Theorem 5(i) (v4)

  Claim being formalized: the coordinate dilation
      Φ_k(r, z, p) = (k·r, z, p/k)
  is a contactomorphism of α = dz − p·dr, for every nonzero k.

  This is stated and proved elementarily, the same way
  ZeoliteCommutation.lean handles Theorem 1: no Mathlib manifold/
  contact-geometry typeclasses are invoked, because the claim reduces
  to a single algebraic identity once α is written out as a linear
  functional on tangent vectors. Concretely:

    (Φ_k^*α)_{(r,z,p)}(v) = α_{Φ_k(r,z,p)}(DΦ_k · v)
                           = v.z − (p/k)·(k · v.r)
                           = v.z − p·v.r
                           = α_{(r,z,p)}(v)

  which is exactly the one-line computation given in paper.tex's proof
  of Theorem 5. `dilateTangent k` below is DΦ_k applied to a tangent
  vector — trivial here since Φ_k is linear, so its own derivative is
  itself.

  NOT covered by this file (still [DERIVED], not [VERIFIED], pending
  further formalization): part (ii), the WKB-induced momentum relation
  connecting this coordinate map to the wavefunction rescaling
  ψ_MCM22(r) = (1/√k)·ψ_ZSM5(r/k); and part (iii), L² norm preservation
  under that rescaling. Both involve differentiation of composed phase
  functions and a change-of-variables integral respectively — heavier
  machinery, deliberately left out of this first pass rather than risk
  an untested, possibly-wrong formalization of them.

  Status: NOT yet run against a Lean kernel. Written without a local
  Lean/Mathlib toolchain or network access to fetch one, so this is a
  candidate file, not a verified result. Please compile it (`lake build`
  in a Mathlib-enabled project, or paste into live.lean-lang.org with
  Mathlib selected) and report back the outcome — including the exact
  error if it doesn't compile as-is, so it can be fixed rather than
  guessed at twice.
-/
import Mathlib.Tactic

/-- The coordinate dilation Φ_k(r, z, p) = (k·r, z, p/k) on ℝ³,
    representing (pore radius, reaction coordinate, momentum). -/
noncomputable def dilate (k : ℝ) (rzp : ℝ × ℝ × ℝ) : ℝ × ℝ × ℝ :=
  (k * rzp.1, rzp.2.1, rzp.2.2 / k)

/-- The pushforward of a tangent vector under Φ_k. Φ_k is linear, so its
    derivative (as a map on tangent vectors) is the same linear map. -/
noncomputable def dilateTangent (k : ℝ) (v : ℝ × ℝ × ℝ) : ℝ × ℝ × ℝ :=
  (k * v.1, v.2.1, v.2.2 / k)

/-- The contact 1-form α = dz − p·dr, evaluated at basepoint (r,z,p) on
    a tangent vector (vr,vz,vp): α_{(r,z,p)}(vr,vz,vp) = vz − p·vr. -/
def alpha (rzp : ℝ × ℝ × ℝ) (v : ℝ × ℝ × ℝ) : ℝ :=
  v.2.1 - rzp.2.2 * v.1

/-- **Theorem 5(i), formal core.** For every nonzero k, the dilation
    Φ_k pulls α back to itself: evaluating α at the image point, on the
    pushed-forward tangent vector, recovers α at the original point and
    vector — for every basepoint and every tangent vector, not just a
    special case. This is exactly the pullback computation
        Φ_k^*(dz − p·dr) = dz − (p/k)·d(k·r) = dz − p·dr = α
    from the v4 proof of Theorem 5, made precise as an equation between
    real numbers. -/
theorem dilate_preserves_alpha (k : ℝ) (hk : k ≠ 0)
    (rzp : ℝ × ℝ × ℝ) (v : ℝ × ℝ × ℝ) :
    alpha (dilate k rzp) (dilateTangent k v) = alpha rzp v := by
  unfold alpha dilate dilateTangent
  field_simp

/-! ## The axiom report

    `index.html` tags Theorem 5(i) `[VERIFIED]` and cites this file by name.
    Until 2026-09-19 the file was not in this repository at all, so the tag
    pointed at something no reader could open -- a certificate for a file
    nobody can inspect, which is worse than no certificate.

    Run 2026-09-19 under Lean 4.33.0-rc1 / Mathlib v4.33.0-rc1:
      'dilate_preserves_alpha' depends on axioms: [propext, Classical.choice, Quot.sound]

    Note that this file is NOT a `lean_lib` target in `lakefile.toml`, so CI
    does not build it. A hand run proves a file on the day it is run and
    nothing afterwards. Declaring the target is what would make a later
    regression fail the job; that is left as a decision rather than made
    silently here, because adding a target changes what CI must build. -/

#print axioms dilate_preserves_alpha
