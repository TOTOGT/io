# The degree of freedom that can bifurcate

Design note for the successor to `dm3_dnls_zeolite_simulation.py`.
Written 2026-09-20, after the three-breadth-measure split. Nothing here is
built yet; this is the spec, and the point of writing it down before building
is that the observable has to be fixed in advance.

## What went wrong, stated precisely

The hypothesis is about **operator firing order**: ZSM-5 fires C→K→F→U,
constraint before folding, giving linear products; MCM-22 fires C→F→K→U,
folding before constraint, giving branched and aromatic ones.

The model is one complex field on one coordinate, ψ(r). Its state space is
L²(ℝ). "Branched" and "linear" are not two points in that space — there is no
coordinate whose values mean those words. So every breadth measure available
is a spread in position or momentum, and on 2026-09-20 three reasonable ones
split 1–2 on the direction:

| measure | ZSM-5 | MCM-22 | MCM-22/ZSM-5 | |
|---|---:|---:|---:|---|
| spatial variance | 3.999 | 3.043 | 0.76× | contradicts |
| delocalisation 1/IPR | 3.908 | 5.084 | 1.30× | agrees |
| effective mode count | 8.38 | 4.27 | 0.51× | contradicts |

They disagree because they are all partly measuring the same irrelevant thing.
The ZSM-5 packet reaches max ⟨r⟩ = 4.454 Å against a barrier at 4.5, with 45%
of its density past it; MCM-22 reaches 4.671 Å and puts 19% past 6.0. A packet
scattering off a nearby wall gets broader and fills modes. That is a
reflection, not a branching, and no better observable on ψ(r) separates them.

Two further facts the model cannot currently express. Both materials have V
and λ switched on from t = 0, so no operator fires *before* another in either
run — the only difference is where the parabola starts. And γ is a constant,
so dissipation removes norm everywhere equally and encodes no chemistry at
all, when escape from the pore is the chemistry.

## The minimal addition

Give ψ a channel index. Two components is enough to start:
ψ_L (linear) and ψ_B (branched), each a function of r.

    i ∂ψ_L/∂t = -∂²ψ_L + V(r)ψ_L - λ(|ψ_L|² + σ|ψ_B|²)ψ_L - κ(r)ψ_B - iγ(r)ψ_L
    i ∂ψ_B/∂t = -∂²ψ_B + V(r)ψ_B + Δψ_B - λ(|ψ_B|² + σ|ψ_L|²)ψ_B - κ(r)ψ_L - iγ(r)ψ_B

New objects, and what each one is for:

- **κ(r) — the folding operator F, finally an operator.** The rate at which
  amplitude transfers between channels. It must depend on free volume, because
  branching needs room: κ(r) = κ₀·exp(−V(r)/V₀), or κ₀ where V(r) < ε and 0
  beyond. This is the whole mechanism. F can only fire where the cage is open.
- **Δ — the energetic penalty on the branched channel.** Without it the two
  channels are symmetric and the split is trivial.
- **σ — cross-phase coupling.** σ = 1 is the symmetric case; σ ≠ 1 is where
  the self-trapping asymmetry between channels lives.
- **γ(r) — escape, not decay.** Nonzero only *beyond* the aperture. Then
  "gets out" versus "stays in" is a measurement rather than a parameter, and
  the uniform-γ problem goes away.

## The observable, fixed in advance

    S = ∫|ψ_B|² dr / ( ∫|ψ_L|² dr + ∫|ψ_B|² dr )

the branched fraction. Dimensionless, bounded in [0,1], and a distribution
over **products** rather than over position. Breadth of the product
distribution is participation over the channel index — which is exactly the
`IPR` of `CatGT/CatGT_Main.lean` with N = number of channels, so
`ipr_between_zero_and_one` applies to it verbatim. The formalisation already
fits this model better than it fits the one in the repo.

**Pre-registered prediction: S(MCM-22) > S(ZSM-5).** Recorded here, before the
code exists, so it cannot be chosen after the fact. If the run comes out equal
or reversed, the operator-order account is wrong, and that is the finding.

## Why this version can fail, and the old one could not

The mechanism is now the ordering itself. κ(r) is large in the open cage and
small past the barrier, so the packet's residence time in the open region
decides how much amplitude reaches ψ_B before the constraint clamps it.
ZSM-5's wall at 4.5 Å cuts that window short; MCM-22's at 6.0 Å leaves it open
longer. Firing order stops being a label on the two runs and becomes a
consequence of where the wall is.

Which buys a second prediction the current model cannot even state:

> Move the ZSM-5 barrier out to 6.0 Å, changing nothing else, and S should
> rise to MCM-22's value. If it does not, the selectivity is not coming from
> aperture position and the geometric story is wrong.

That is a knob, a predicted response, and a way to be wrong. The present
model has none of the three.

## Not in scope

A second spatial coordinate (transverse cage width) is the physically fuller
answer and is much more expensive; the channel index is the cheap version of
the same idea and should be tried first. A chemical master equation over real
product species is the honest version and is a different project.
