# Phase I — Facilities, Equipment & Other Resources (REVISED)
### Draft replacing the "entirely solo" language · 2026-07-18

> **Read the compliance notes at the bottom before submitting.** Two items require
> your confirmation and one requires action from Felipe and Zila.

---

## 1. FACILITIES

### A. Computational & Operational Base (G6 LLC — Newark, NJ)

The applicant, G6 LLC, is a Newark, New Jersey small business. All research and
development effort funded under this Phase I award will be performed by the
Principal Investigator, Pablo Grossi, at G6 LLC's facility in Newark, New Jersey.
No portion of the funded R&D will be performed outside the United States.

The operational base is a secure computational facility equipped with high-speed
network access, dedicated server capacity, and redundant local backup sufficient
to develop, execute, and archive kinetic models, formal verification developments,
and simulation codebases. Because the Phase I scope is entirely computational, no
external laboratory space or university infrastructure is required.

---

## 2. EQUIPMENT

The Phase I scope is limited to formalizing, machine-checking, and mathematically
verifying kinetic and catalytic upgrading pathways. No laboratory hardware or
analytical instrumentation is required or requested. G6 LLC already possesses all
infrastructure needed to execute the proposed tasks:

* **Computation** — multi-core workstations provisioned for sustained symbolic
  execution and proof-checking workloads.
* **Storage & version control** — encrypted redundant solid-state storage with
  private Git-based version control, providing a complete auditable history of
  every proof development.
* **Toolchain** — integrated environments for formal methods and interactive
  theorem proving (Lean 4 / Mathlib), with continuous-integration kernel
  verification on every commit.

---

## 3. OTHER RESOURCES

### A. Open-source formal verification framework

The project builds on the Principal Investigator's existing machine-checked
formalization work, publicly available at `totogt.github.io/io` and
`github.com/TOTOGT/io`. Every theorem in the shipped libraries is verified by the
Lean kernel in continuous integration on each push, with per-theorem axiom audits
(`#print axioms`) confirming the absence of `sorryAx` — that is, confirming no
result depends on an unproved placeholder.

The value of this infrastructure to the proposed work is demonstrated rather than
asserted. In July 2026 the framework surfaced a **false theorem in the Principal
Investigator's own prior published derivation**: an operator-commutation result
asserted for a pore-aperture gate acting on a pointwise reaction term, which
machine-checking showed to be exactly the opposite of the truth. The result was
corrected, the correction was itself kernel-verified, and the affected preprint
was revised. Conventional peer review had not caught it. This is precisely the
class of silent modeling error that formal verification is intended to eliminate
before it propagates into experimental design or scale-up, and it is the
methodological case for the present proposal.

### B. Technical advisory relationships

The Principal Investigator performs all funded R&D under this award. G6 LLC has
additionally secured the informal technical mentorship of two senior
subject-matter experts, who advise the Principal Investigator on experimental
realism and commercial context in an unpaid advisory capacity:

* **Prof. Zila S. B. Sousa** — zeolite catalysis; operando DRIFTS
  characterization of ethanol-to-hydrocarbon conversion over HZSM-5 and HMCM-22,
  the specific catalytic systems modeled in this proposal.
* **Prof. Felipe de Aquino** — [affiliation]; [specialization], with direct
  commercial experience in the specification and supply of the analytical
  instrumentation used to characterize these reaction systems.

This advisory relationship is material to the proposal in two respects. First, it
grounds the computational models against the judgment of researchers who have
measured these systems experimentally — the models are checked for realism by
people who know what the instruments actually report. Second, Prof. de Aquino's
commercial experience supplying analytical instrumentation into this market
provides G6 LLC with direct insight into the equipment base, cost structure, and
purchasing behavior of the laboratories that would validate and adopt this
technology, informing the Phase II commercialization pathway.

Neither advisor receives Phase I award funds, performs funded research, nor
generates Phase I deliverables. All Phase I R&D is performed by the Principal
Investigator within the United States. Their engagement establishes the
experimental and commercial pathway for Phase II, in which G6 LLC intends to
formalize these relationships in compensated roles structured to comply with
SBIR performance-location requirements.

### C. Commercial and market alignment

G6 LLC maintains working contact with industrial and market participants in both
the U.S. and Brazilian ethanol sectors, enabling the computational models to be
calibrated against realistic commercial metrics without requiring institutional
subawards during Phase I.

---
---

# COMPLIANCE NOTES — resolve before submission

### 1. Confirm the advisory characterization is accurate ⚠

The draft above states that Zila and Felipe perform **no funded R&D and produce no
Phase I deliverables**. This must be literally true.

The DRIFTS protocols already drafted for them (`Protocolo_DRIFTS_P1_Zila.docx`,
`Protocolo_P2_P3_Felipe.docx`) describe **experimental work**. If that work is
performed abroad *as part of this award* during Phase I, the language above is
false and the application is misrepresenting the performance location.

The distinction that matters:

| Situation | Status |
|---|---|
| They advise on model realism; PI does all funded work | ✅ Draft above is accurate |
| They run DRIFTS as **their own independent research**, unfunded by the award and not a Phase I deliverable | ✅ Normal scientific collaboration — but do not list results as Phase I output |
| They run DRIFTS **as Phase I work under the award** | ❌ Rewrite required; triggers performance-location problem |

**Recommendation:** hold the experimental protocols for Phase II, or have them run
independently and outside the award's scope of work.

### 2. Get written consent and letters of collaboration ⚠

Naming individuals in a federal application requires their knowledge and consent.
DOE expects a **letter of commitment on institutional letterhead** from named
collaborators, identifying the institution, the role, and (where money is
involved) the dollar amount and certifying official.

For uncompensated advisors a short letter of collaboration confirming their
advisory role and willingness to participate is appropriate — and strengthens the
application, since two named domain experts is substantially more credible than a
solo computational effort.

**Ask both before submitting. Do not name them otherwise.**

### 3. The performance-location rule is stricter than a waiver ⚠

DOE's requirement is that **all R&D under an SBIR award be performed in the United
States**. A foreign subawardee is not simply a waiver formality: the application
must affirmatively explain how the "all R&D in the U.S." requirement is satisfied.
This applies to Phase II planning as well — the current Phase II draft's Brazilian
subcontract for "catalyst characterization and feedstock validation" will need to
address this directly, not merely footnote a waiver.

### 4. How to pay them, eventually

Phase I requires the small business to perform **≥ 2/3 (66.67%) of the effort by
cost**; up to 1/3 may go to consultants and subawardees combined. So compensation
is structurally possible — but for work performed abroad, the location rule above
governs. Practical routes:

* **Phase II subaward** with the performance-location question addressed head-on.
* **Consultant line item** for advisory work performed in the U.S. (including
  remote consultation where permitted — confirm treatment with the program
  manager).
* Verify the specific FOA's terms; DOE Phase I is currently up to **$250,000**,
  and the FY2026 statutory cap is $314,363. Do not budget from a remembered
  figure.

### 5. Fix carried over from the earlier review

* Phase II Equipment section claims "shared, **immediate** access" to NJIT
  facilities while Other Resources says **fee-for-service** — reconcile, and
  obtain a VentureLink letter of support.
* Drop "retain 100% of the budget" framing from any narrative text; SBIR is
  cost-reimbursement with a separate allowable fee.
* NYFA fiscal sponsorship appears incompatible with SBIR's for-profit small
  business eligibility — confirm before relying on it.
* Cite the corrected **v3** of the zeolite paper, never v1–v2.

---

*Prepared 2026-07-18. Not legal or grants-compliance advice — items 1–3 in
particular should be confirmed with the DOE program manager or a qualified grants
professional before submission.*
