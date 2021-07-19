This is a simple but working matlab code for vibrational EELS data processing. It works only on Matlab R2019b or later versions.

Suggested publications:

- R. Qi#, R. Shi#, ...,  Peng Gao*. Measuring phonon dispersion at an interface. *in press* (2021).
- R. Qi#, N. Li#, ...,  Peng Gao*. Four-dimensional vibrational spectroscopy for nanoscale mapping of phonon dispersion in BN nanotubes. *Nature Communications* **12**, 1179 (2021).

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

Used 3rd-party packages:

- BM3D ([Image and video denoising by sparse 3D transform-domain collaborative filtering | Block-matching and 3D filtering (BM3D) algorithm and its extensions (tuni.fi)](https://webpages.tuni.fi/foi/GCF-BM3D/))
- npy-matlab ([kwikteam/npy-matlab: Experimental code to read/write NumPy .NPY files in MATLAB (github.com)](https://github.com/kwikteam/npy-matlab))

## Contact

- Ruishi Qi: `rs-qi(at)pku.edu.cn`
- Prof. Peng Gao: `p-gao(at)pku.edu.cn`

