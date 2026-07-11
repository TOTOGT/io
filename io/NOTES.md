# FACILITIES, EQUIPMENT, & OTHER RESOURCES
DOE SBIR Phase I — G6 LLC, Newark, NJ — FY2027 Release 1 (Summer 2026)

<!-- INTERNAL NOTES — delete before submission ------------------------------
1. Strategy rationale (100% in-house Phase I, no foreign work, computational
   scope) belongs in the Work Plan / Commercialization Plan, NOT here. FEOR
   is descriptive only.
2. NYFA fiscal sponsorship: do NOT mention anywhere in this application.
   SBIR awards go directly to the small business; PI must be >50% employed
   by G6 LLC at award; G6 must be majority US-citizen/PR owned and listed
   in SAM.gov + SBA company registry (sbir.gov). Start registrations early.
3. Brazilian relationships: disclose in the required foreign-affiliation
   disclosure forms, not in FEOR. All SBIR R&D must be performed in the US;
   foreign subawards are rarely waived — do not build Phase II around one.
4. Get letters of support/commitment from VentureLink, the NJIT
   collaborating faculty member, and NJIT core facilities BEFORE
   submission. Attach as Letters of Support.
5. Outsourcing math: SBIR Phase I allows up to 1/3 of the budget via
   subaward/consultants — the NJIT subaward below must stay under that.
   If NJIT's share should be larger (30-60%), switch to STTR, which
   REQUIRES a research-institution partner. Decide before the LOI.
6. Mandatory LOI ~3 weeks after FOA release (~Aug 2026). Watch
   science.osti.gov/sbir/Funding-Opportunities for the topics document.
--------------------------------------------------------------------------->

## 1. FACILITIES

### A. Computational & Operational Base (G6 LLC — Newark, NJ)

The applicant, G6 LLC, is a small business headquartered in Newark, NJ.
Phase I research is led by the Principal Investigator, Pablo Grossi, from
the company's computational facility in Newark, NJ, with experimental
support provided through the collaboration described in Section 1.B.

The facility is equipped with high-speed internet, dedicated server
capacity, and redundant local backup systems sufficient to develop, execute,
and archive the project's mathematical models, formal verification
codebases, and kinetic simulations.

### B. Collaborative Laboratory Access (NJIT — Newark, NJ)

Formal verification is only as strong as the empirical data that anchors
its models. To ground the machine-checked kinetic models in measured
reality, G6 LLC will collaborate with faculty at the New Jersey Institute
of Technology (NJIT), located in Newark, NJ, adjacent to the company's
operational base. Under a Phase I subaward [letter of commitment from the
collaborating faculty member attached], NJIT will provide:

* **Benchmark experimental data:** targeted ethanol-to-hydrocarbon
  conversion runs and catalyst characterization measurements used to
  calibrate and validate the kinetic model parameters that the formal
  verification layer certifies.
* **Laboratory facilities:** access to NJIT chemical engineering
  laboratories and core user facilities (GC-MS, FTIR, TGA, XRD) on a
  subaward and fee-for-service basis for the validation measurements.

This collaboration keeps the majority of Phase I effort with the small
business, consistent with SBIR program requirements, while ensuring the
verified models are anchored to laboratory measurements from the outset
rather than deferred to Phase II.

## 2. EQUIPMENT

The core Phase I scope — formalizing, machine-checking, and mathematically
verifying kinetic and catalytic upgrading pathways — is computational; the
supporting validation measurements use NJIT instrumentation described in
Section 1.B, so no equipment purchases are requested. G6 LLC possesses all
computational hardware needed to execute the project tasks:

* **High-performance workstations:** multi-core systems configured for
  sustained computational workloads, symbolic execution, and proof
  compilation.
* **Storage and version control:** encrypted, redundant solid-state storage
  with private Git-based version control tracking all formal proof
  development, with continuous-integration verification on every commit.
* **Development environments:** integrated toolchains for formal methods
  and theorem proving (Lean 4 with Mathlib), kinetic modeling, and
  scientific computing.

## 3. OTHER RESOURCES

### A. Open-Source Formal Verification Framework (AXLE)

The proposed research builds directly on AXLE, the open-source,
machine-checked verification framework developed by the Principal
Investigator (github.com/TOTOGT/AXLE; archived at Zenodo,
DOI 10.5281/zenodo.19117399; documentation at totogt.github.io/io). AXLE
provides Lean 4 formalizations of the underlying catalytic selectivity
theory, verified in continuous integration against the Lean kernel on every
commit, with a public audit trail distinguishing closed theorems from open
obligations. This framework substantially reduces the risk of undetected
mathematical error in the upgrading reaction models and provides a
reproducible, independently checkable foundation for physical validation in
Phase II.

### B. Personnel and Technical Support

Phase I personnel comprise the Principal Investigator (formal methods,
kinetic modeling, project direction), the collaborating NJIT faculty member
and their laboratory personnel (experimental validation, via subaward), and
NJIT's local pipeline of chemical engineering graduate students available
for auxiliary support on a consulting basis. This structure pairs the
verification expertise of the small business with established experimental
capability, while keeping project direction and the majority of effort
within G6 LLC.

### C. Advisory and Industry Network

G6 LLC maintains an active network of industrial and market contacts in the
U.S. renewable fuels sector, enabling the Principal Investigator to align
the computational models with commercially relevant performance metrics
during Phase I.

---

# Phase II — FACILITIES, EQUIPMENT, & OTHER RESOURCES
(forward-looking; included to demonstrate scale-up path)

## 1. FACILITIES

### A. Laboratory Space (VentureLink at NJIT — Newark, NJ)

Physical laboratory tasks in Phase II — wet-lab synthesis, chemical
handling, and analytical characterization — will be performed at
VentureLink, New Jersey's largest technology incubator, located on the
campus of the New Jersey Institute of Technology (NJIT) in Newark, NJ.

G6 LLC will secure a dedicated wet-lab bench membership upon Phase II award.
[Letter of support from VentureLink attached.] The facility provides full
environmental health and safety (EHS) compliance, chemical fume hoods,
hazardous-waste management, climate-controlled storage, and the utilities
required to safely conduct ethanol-to-hydrocarbon catalytic upgrading
experiments.

### B. Computational / Office Space

Administrative, project-management, and kinetic/molecular modeling tasks
will continue at G6 LLC's computational facility in Newark, NJ, described
above.

## 2. EQUIPMENT

Through VentureLink membership and fee-for-service access to NJIT core user
facilities [letter of support attached], G6 LLC will have shared access to
the analytical and synthesis equipment required for Phase II. No major
capital equipment purchases are anticipated in the Phase II budget.

* **Chromatography:** GC-MS and HPLC for quantification of
  ethanol-to-hydrocarbon conversion and product selectivity.
* **Thermal and surface analysis:** FTIR, TGA, and XRD access for
  post-reaction catalyst characterization and coking/deactivation analysis.
* **Synthesis infrastructure:** multi-position stirring hotplates, vacuum
  ovens, calcination furnaces, and analytical microbalances for catalyst
  formulation.
* **Safety and handling:** certified fume hoods, N2/H2 gas lines, PPE, and
  specialized chemical storage.

## 3. OTHER RESOURCES

### A. University Ecosystem and Technical Support

VentureLink's location on the NJIT campus provides access to NJIT library
resources, academic literature databases, and specialized core facilities on
a fee-for-service basis, plus a local pipeline of chemical engineering
talent for auxiliary technician support if needed.

### B. Advisory and Commercialization Support

As a VentureLink member company, G6 LLC receives corporate mentoring,
milestone-tracking support, and access to venture capital and industrial
manufacturing partners, aligned with the commercialization priorities of the
DOE Office of Technology Commercialization.
