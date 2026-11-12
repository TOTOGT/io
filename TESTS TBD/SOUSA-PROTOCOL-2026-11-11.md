# CATGT Sousa test: what the existing data can show, and a frozen protocol for new data (2026-11-11)

Status: hand-derived and computed in Python; no Lean involved. Not reviewed by Zila or her advisor. Thresholds below are the author's proposals, to be fixed BEFORE any new run.

## 1. The law, and what it can test
Paper form (V6, fixed-norm): sigma = 1 - (r*/r_pore)^2, one r* shared by all materials. So (1 - sigma_m) r_m^2 = r*^2 for every material m, i.e. ln(1 - sigma_m) = 2 ln r* - 2 ln r_m: slope exactly -2 against ln r_m, one free parameter (r*).
- Two materials: one free parameter, two data points = ONE degree of freedom (R = 1 within error). Three or more distinct r_m give a real slope test.
- Absolute r* is NOT testable: no independent estimate of J, lambda, P, a exists. Only cross-material consistency is.
- The law has no time-on-stream and no contact-time variable. Anything that changes sigma_m with TOS or WHSV at fixed material is outside it.

## 2. Descriptor-free inversion of the existing data (POST HOC, exploratory, not a test)
Required effective radius ratio r_MCM22 / r_ZSM5 = sqrt((1 - sigma_Z)/(1 - sigma_M)), sigma = ethene molar fraction. No pore descriptor is chosen in this computation.
- 2014 images (assignment HMCM-22 / HZSM-5 NOT CONFIRMED; no WHSV printed): 10, 72, 137, 200, 265 min -> 1.67, 1.98, 2.32, 2.56, 2.53.
- Thesis Table 4.2.3 (WHSV 6.5, 500 C, 0.12 atm, 100% conv.): 10 min -> 3.15, 270 min -> 4.41. With sigma = C2=/(C2= + C3=): 3.62 and 5.51.
- Crystallographic ratios MWW/MFI: IZA included sphere 9.69/6.36 = 1.52; IZA diffusing sphere 4.92/4.7 = 1.05; supercage 7.1 vs ZSM-5 channel 5.5 = 1.29.
- Sensitivity (the data carry no uncertainties; +/-2 pp on both ethene values is an ASSUMPTION): 2014 10 min 1.59-1.76; thesis 10 min 2.55-4.36.

Readings, all conditional on sigma = ethene fraction:
(a) every descriptor gives a ratio <= 1.52, the data need 1.7 to 5.5; only the 2014 10-min point comes near the included-sphere ratio.
(b) The required ratio rises with TOS, as coke builds, which the law has no variable for.
(c) For the SAME two materials the required ratio is about 1.7 (2014 images, if those are WHSV 0.65) against 3.2 (thesis, WHSV 6.5) at 10 min, so a single r* does not even carry across contact time.
(d) Direction (larger cavity, more ethene) agrees with the paper; magnitude does not.

Not covered: sigma from coke, other sigma definitions, uncertainties.

## 3. Why the existing data cannot be a pre-registered test
The numbers were seen before sigma and the pore descriptor were fixed. A descriptor chosen now would be chosen with the inversion table in view. So the existing sets stay exploratory. A genuine test needs NEW data (the planned follow-up study), with everything below frozen first.

## 4. Frozen protocol for new data (proposed; freeze and date-stamp before the first run)
1. Materials: at least 4 distinct framework types, pore descriptor spanning at least 1.5x, framework SAR within +/-15%, comparable crystal size, same Na/H form and activation. Same conditions for all: 500 C, p(EtOH) 0.12 atm, WHSV fixed, conversion >= 99% (report any lower).
2. Primary sigma: molar fraction of ethene in the product distribution at the FIRST sampling (10 min). Later TOS is secondary. Coke-based sigma, if wanted, must be defined and dated before data, not after.
3. Primary pore descriptor: largest included sphere DIAMETER from the IZA database, radius = D/2, the same geometric object for every framework. Sensitivity set (reported, never used to pick the result): diffusing sphere, supercage/cavity size where one exists. State openly that this choice was made after the section-2 table was seen.
4. Replicates: 3 independent runs on fresh catalyst per material; report mean and SD. Without SD there is no test.
5. Statistics: regress ln(1 - sigma_m) on ln r_m across materials. Prediction: slope = -2 with the intercept free (r*). Report the slope and its 95% interval. Also T = largest pairwise |ln((1 - sigma_m) r_m^2) - ln((1 - sigma_n) r_n^2)|.
6. Outcomes fixed in advance: SUPPORT only if the 95% interval of the slope contains -2 AND every material lies within 2 replicate SD of the one-parameter fit. REFUTED (for this sigma and descriptor) if the interval excludes -2 or the sign is wrong. Anything between is reported as inconclusive, not as support. Materials with sigma > 0.95 are treated as censored.
7. Controls: (a) permutation control: shuffle the descriptor among the materials and report the rank of the true assignment among all k! permutations (k >= 5 for a smallest p of 1/120; k = 4 gives 1/24); (b) a null model with no pore dependence (slope 0); (c) rival one-parameter models with acid-site density (and strong-site fraction) as the covariate. The law must not do worse than the rivals in leave-one-material-out prediction error. Site density differs between the two zeolites (acidity 1628 vs 938 umol NH3/g), so this rival is real.
8. Cavity alternative: if cavity materials fall off the smooth law, the alternative, stated before data, is a threshold form: sigma is a step in r_pore around r*. A fitted step location is an extra parameter and must be counted as one.

## 5. Open items
Confirm which image is which catalyst, WHSV and basis; the two non-summing rows (98.22 and 98.01 at 72 and 137 min); replicate SDs; whether the follow-up study has at least 4 frameworks.

## 6. Not claimed
That the law is refuted in general: only that, with sigma = ethene fraction, no tested descriptor reproduces the two available datasets. That ethene fraction is the right observable. Any value of a.
