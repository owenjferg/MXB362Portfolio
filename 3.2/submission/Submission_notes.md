# PST2 submission notes

The PDF covers every prescribed portfolio task in the week 8–11 slide decks. No required saved visual output is missing. Existing MATLAB and week 8–10 outputs were used; those scripts were not rerun. Week 11 was run successfully with local R 4.6.1, paletteer and ggplot2.

## Submission copies

- `code/week8_volume.R` preserves the original renderer but replaces the obsolete absolute input path with a relative filename. Run it from `3.2/week8`.
- `code/week11_corrected.R` replaces the faulty LDA angle indexing (`cos(angles[1])`), normalises W, fixes the loop bound, uses uppercase Y for the histogram, and exports the figures and numerical results. Run it from `3.2/week11`. The original `week11/pract1.R` is preserved.
- Week 11 provides both columns 1/3 (worked slides) and columns 1/2 (final task slide), because the deck is inconsistent. The PDF uses the corrected plots and calculated values.
- Full source listings are in the PDF. Its LaTeX source and derived images are retained here for editing/rebuilding. From this folder, run `xelatex portfolio.tex`.

## Files and animation checks

- No files under `3.2` were Git LFS pointer stubs.
- The beetle raw data is present at the expected 683,917,312 bytes.
- `week8/stag_beetle_rotation.mp4` is readable H.264: 720 frames, 18 seconds. The PDF includes its complete source and the existing isosurface still.
- `week9/LarvalDispersal.gif` is readable: 3,998 frames. Four representative frames are included in the PDF.
- The original TIFF is present and included as a lossless PNG display conversion.
- The exploratory head/aneurism volume-renderer exercises do not have saved scripts/plots in week8, but they are not prescribed portfolio deliverables on the final task slide.

No ZIP was created. When you prepare it, include the corrected submission code and its matching figures alongside the original work and animations. The current Git status reflects your folder move from root-level week directories into 3.1/3.2; this task did not stage, commit or change Git/LFS settings. The raw-data ignore entry and some LFS patterns still reference the old week8 location, so review those before your next Git add/push.
