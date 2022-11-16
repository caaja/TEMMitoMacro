# TEMMitoMacro - an ImageJ/Fiji Macro #


**TEMMitoMacro** is a pair of open-source ImageJ and Fiji macros that, together, allow for the semi-automated batch analysis of mitchondrial morphology in TEM images.

Parameters analysed are based on previously implemented measures in the literature: area, area^2, form factor, aspect ratio, perimeter, circularity, Feret’s diameter and roundness (ie as per [Merrill, Flippo & Strack, 2017](https://link.springer.com/protocol/10.1007/978-1-4939-6890-9_2)).

TEMMitoMacro consistes of 2 Macro files: (1) ROIBatchGen, which allows for the selection of ROIs to be used by the second macro, (2)EM-MitoMorphMacro, which automatically analyses mitochondrial morphology in the generated ROI files and generates population statistics.
This macro pair was developed in collaboration with Erin Buchanan from the [O'Ryan Lab](https://geneticskidslab.wixsite.com/oryanlab) at the University of Cape Town.



**TEMMitoMacro** is available for download The .ijm files can be opened and run directly in Fiji/ImageJ.
