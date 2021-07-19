This is a simple but working matlab code for vibrational EELS data processing. It works only on Matlab R2019b or later versions.

Please cite: ???

## Features

- 3D-EELS
  - Processing: ZLP alignment, normalization, block-matching and 3D filtering (BM3D) denoising, background subtraction, Lucy-Richardson deconvolution.
  - Visualization: Energy-filtered EELS maps and line profiles.
  - Supports user-defined custom functions
- 4D-EELS
  - Processing: Pre-processing, ZLP alignment, BM3D denoising.
  - Visualization: Dynamical plot of 4D datasets.
  - Supports user-defined custom functions

## File organization

- `EELS3D_TOOLBOX.mlapp`: Matlab app for 3D-EELS data processing
- `EELS4D_TOOLBOX.mlapp`: Matlab app for 4D-EELS data processing
- `3DEELS`: Functions used for 3D-EELS data processing
- `4DEELS`: Functions used for 4D-EELS data processing

## Contact

- Ruishi Qi: `rs-qi(at)pku.edu.cn`
- Prof. Peng Gao: `p-gao(at)pku.edu.cn`

