# CatGT — Catalytic Generative Theory

_repo: `io` — imaginary origin_

Lean 4 / Mathlib4 formalization of the operator-chain framework applied to
heterogeneous catalysis, with zeolite selectivity as the worked instance.
Part of the [Principia Orthogona](https://github.com/TOTOGT/AXLE) series.

CatGT applies a general operator pipeline (compression, curvature, fold,
unfold) to a contact-manifold model of catalytic reaction pathways. The
central applied result is the **Helical Selectivity Principle**: a
confinement bound explaining why pore geometry constrains product
selectivity in zeolite catalysis (e.g. HZSM-5 vs. HMCM-22 divergent product
distributions). A companion result, Theorem 5.3, establishes that the
operator chain is order-dependent in general — firing order affects
outcome — while also proving this is not universal: some configurations
provably commute.

All results below are checked by the Lean 4 kernel, not hand-verified.

## Key results

| Theorem | Status | Description |
|---|---|---|
| `helical_selectivity` | closed · 0 sorry | Confinement bound `r ≤ r*(J, λ)` on the helical radius of a confined trajectory, given positive curvature and coupling parameters. Formal core of the Helical Selectivity Principle. |
| `thm_5_3_is_exactly_existential` | closed · 0 sorry | Precise statement of Theorem 5.3: an existential claim, not universal. Some valid operator instances are order-dependent; others provably commute. Both exhibited on the same manifold. |

## Source

- [`CatGT/CatGT_Main.lean`](CatGT/CatGT_Main.lean) — core formalization, Helical Selectivity Principle
- [`PrincipiaOrthogona1/Theorem53NonCommutativity.lean`](PrincipiaOrthogona1/Theorem53NonCommutativity.lean) — Theorem 5.3
- [`PrincipiaOrthogona_7Proofs_Template.docx`](PrincipiaOrthogona_7Proofs_Template.docx) — proof template, reference

## Build

```
lake build CatGT Theorem53
```

CI (GitHub Actions, [`.github/workflows/verify-proofs.yml`](.github/workflows/verify-proofs.yml))
runs the real Lean kernel on every push and prints the axiom dependencies of
each theorem.

## Author

Pablo Nogueira Grossi · G6 LLC
[github.com/TOTOGT](https://github.com/TOTOGT) ·
ORCID [0009-0000-6496-2186](https://orcid.org/0009-0000-6496-2186) ·
Zenodo DOI [10.5281/zenodo.19117399](https://doi.org/10.5281/zenodo.19117399)
