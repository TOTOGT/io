**Target: v2, DOI 10.5281/zenodo.21296707 (supersedes v1, zenodo.org/records/20563363)**

# Corrected reference list — "Operator Firing Order..." (Grossi 2026)

All 10 references in the current PDF were checked against CrossRef/PubMed. Six had fabricated titles, pages, and in two cases fabricated author lists, despite correct DOIs. One (Zhou et al., ref [9]) is dropped per your instruction — source no longer available on the web. Csicsery [4] was already correct, no change.

No `.tex`/`.docx` source file for this paper was found in your folders — only PDFs. Paste the block below over the current References section in whatever file you're compiling from (or send me that source file and I'll apply it directly).

## Corrected References (renumbered 1–9, Zhou dropped)

1. Sousa, Z. S. B.; Cesar, D. V.; Henriques, C. A.; Teixeira da Silva, V. "Bioethanol conversion into hydrocarbons on HZSM-5 and HMCM-22 zeolites: Use of in situ DRIFTS to elucidate the role of the acidity and of the pore structure over the coke formation and product distribution." *Catalysis Today*, 2014, 234, 182–191. doi:10.1016/j.cattod.2014.03.023

2. Sousa, Z.; Henriques, C.; da Silva, V. "Ethanol Conversion Catalyzed by MCM-22 and Its Dealuminated and Delaminated Forms." *Journal of the Brazilian Chemical Society*, 2023, 34. doi:10.21577/0103-5053.20230028

3. Weisz, P. B.; Frilette, V. J. "Intracrystalline and Molecular-Shape-Selective Catalysis by Zeolite Salts." *J. Phys. Chem.*, 1960, 64, 382. doi:10.1021/j100832a513

4. Csicsery, S. M. "Shape-Selective Catalysis in Zeolites." *Zeolites*, 1984, 4, 202–213. doi:10.1016/0144-2449(84)90024-1 — *(unchanged, was already correct)*

5. Sastre, G.; Catlow, C. R. A.; Corma, A. "Diffusion of Benzene and Propylene in MCM-22 Zeolite. A Molecular Dynamics Study." *J. Phys. Chem. B*, 1999, 103, 5187–5196. doi:10.1021/jp984776m

6. Sastre, G.; Catlow, C. R. A.; Corma, A. "Influence of the Intermolecular Interactions on the Mobility of Heptane in the Supercages of MCM-22 Zeolite. A Molecular Dynamics Study." *J. Phys. Chem. B*, 2002, 106, 956–962. doi:10.1021/jp013589c

7. Lawton, S. L.; Leonowicz, M. E.; Partridge, R. D.; Chu, P.; Rubin, M. K. "Twelve-ring pockets on the external surface of MCM-22 crystals." *Microporous and Mesoporous Materials*, 1998, 23, 109–117. doi:10.1016/S1387-1811(98)00057-2

8. Kadam, S. A.; Shamzhy, M. V. "IR Operando Study of Ethanol Dehydration over MFI Zeolite." *Catalysis Today*, 2018, 304, 51–57. doi:10.1016/j.cattod.2017.09.020

9. Parmar, D.; Cha, S. H.; Salavati-Fard, T.; Agarwal, A.; Chiang, H.; Washburn, S. M.; Palmer, J. C.; Grabow, L. C.; Rimer, J. D. "Spatiotemporal Coke Coupling Enhances para-Xylene Selectivity in Highly Stable MCM-22 Catalysts." *J. Am. Chem. Soc.*, 2022, 144, 7861–7870. doi:10.1021/jacs.2c01975

## What changed (old → new)

| Old # | Issue | Fix |
|---|---|---|
| [1] | Fabricated author list (Mertens, Roldán, Jiménez-Sanchidrián, Ruiz-Morales, Ramírez, Cunha, Chadwick — none are real authors), wrong volume/pages (215, 213–223) | Real authors: Sousa, Cesar, Henriques, Teixeira da Silva. Vol. 234, pp. 182–191 |
| [2] | Wrong journal ("Catalysts, 12(7), 742" doesn't exist) | Real journal: *J. Braz. Chem. Soc.*, 2023 |
| [3] | Wrong title ("Molecular-Sieve Catalysis" vs. real "Molecular-Shape-Selective Catalysis by Zeolite Salts") | Corrected title |
| [4] | — | No change, already correct |
| [5] | Wrong title/pages, pointed at a different Sastre paper under the same DOI | Corrected to the paper the DOI actually resolves to |
| [6] | Wrong title ("Quantum Mechanical Study of the Adsorption of n-Heptane"), wrong pages (701–711) | Real title and pages 956–962 |
| [7] | Wrong title/journal name ("MWW: A Layered Aluminosilicate...", "Microporous Materials" 207–219) | Real title/journal: "Twelve-ring pockets...", *Microporous and Mesoporous Materials*, 109–117 |
| [8] | Wrong author (Kadam, N.), wrong title, wrong pages | Kadam, S. A.; Shamzhy, M. V., "IR Operando Study...", pp. 51–57 |
| [9] Zhou et al. 2019 | Unverifiable — could not confirm this Nature Communications entry exists as cited, and per your note the source is no longer available online | **Dropped.** In-text citations to old [9] need to be removed or replaced with a different source if that claim still needs support |
| old [10] → new [9] | Fabricated authors (Parmar, K.P.S.; Semelsberger; Pagar), wrong title, wrong pages | Real paper: Parmar et al., "Spatiotemporal Coke Coupling...", pp. 7861–7870 |

## Action needed on your end

Any in-text `\cite{}` call keyed to the old [9] (Zhou) or old [10] (Parmar) needs updating — [10] is now [9], and any claim that specifically leaned on the Zhou et al. mechanistic-insights point (ethoxide/olefin pathway on H-ZSM-5) has lost its citation and either needs a replacement source or should be rephrased as unsupported/hypothesis.

Refs [3], [4], [7] were flagged in the original review as unverified — all three are now confirmed above ([4] was fine, [3] and [7] needed title/journal fixes).
