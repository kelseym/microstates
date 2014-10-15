function test_ft_plot_lay

% MEM 1gb
% WALLTIME 0:03:00

% TEST test_ft_plot_lay
% TEST ft_plot_lay

% the following layout is CTF151.lay after being passed through printstruct
lay.pos = [
  -0.0343694 0.17318 
  -0.0951155 0.155795 
  -0.176643 0.137073 
  -0.2246 0.0782318 
  -0.266163 0.00869242 
  -0.0647425 0.0996285 
  -0.128686 0.0969539 
  -0.171847 0.0434621 
  -0.210213 -0.0100297 
  -0.10071 0.0327637 
  -0.141474 -0.0207281 
  -0.103108 -0.0849183 
  -0.0343694 0.0327637 
  -0.0647425 -0.0314264 
  -0.0311723 -0.0956166 
  -0.0927176 0.439302 
  -0.17984 0.409881 
  -0.0383659 0.40052 
  -0.122291 0.377786 
  -0.20222 0.340342 
  -0.0791297 0.340342 
  -0.155062 0.309584 
  -0.221403 0.26679 
  -0.274156 0.203938 
  -0.0351687 0.293536 
  -0.109503 0.27214 
  -0.181439 0.230684 
  -0.228597 0.165156 
  -0.278952 0.104978 
  -0.0671403 0.229346 
  -0.13508 0.201263 
  -0.0367673 -0.320282 
  -0.131083 -0.284175 
  -0.0959147 -0.352377 
  -0.187034 -0.305572 
  -0.0471581 -0.41523 
  -0.152664 -0.377786 
  -0.24778 -0.317608 
  -0.111101 -0.436627 
  -0.219005 -0.389822 
  -0.311723 -0.310921 
  -0.066341 -0.146434 
  -0.135879 -0.137073 
  -0.178242 -0.0768945 
  -0.0343694 -0.214636 
  -0.096714 -0.195914 
  -0.0767318 -0.257429 
  -0.151066 -0.211961 
  -0.196625 -0.146434 
  -0.238188 -0.0742199 
  -0.272558 0.290862 
  -0.326909 0.146434 
  -0.322114 0.0354383 
  -0.301332 -0.0635215 
  -0.255773 -0.15312 
  -0.204618 -0.229346 
  -0.264565 0.367088 
  -0.339698 0.23737 
  -0.376465 0.0782318 
  -0.36048 -0.0394502 
  -0.322114 -0.141085 
  -0.261368 -0.236033 
  -0.346092 0.320282 
  -0.402043 0.166493 
  -0.414831 0.011367 
  -0.384458 -0.113001 
  -0.32611 -0.228009 
  -0.415631 0.246731 
  -0.45 0.0902675 
  -0.43881 -0.0581724 
  -0.391652 -0.190565 
  0.0335702 0.17318 
  0.0943162 0.155795 
  0.176643 0.137073 
  0.2246 0.0782318 
  0.266163 0.00869242 
  0.0647425 0.0982912 
  0.128686 0.0969539 
  0.171847 0.0434621 
  0.210213 -0.0100297 
  0.10151 0.0327637 
  0.141474 -0.0207281 
  0.103108 -0.0849183 
  0.0343694 0.0327637 
  0.0655417 -0.0327637 
  0.0311723 -0.0956166 
  0.091119 0.439302 
  0.17984 0.409881 
  0.0375666 0.401857 
  0.121492 0.377786 
  0.20222 0.341679 
  0.0783304 0.341679 
  0.154263 0.309584 
  0.221403 0.26679 
  0.274156 0.203938 
  0.0343694 0.293536 
  0.109503 0.27214 
  0.181439 0.230684 
  0.227798 0.166493 
  0.278952 0.104978 
  0.066341 0.229346 
  0.134281 0.201263 
  0.0383659 -0.320282 
  0.131883 -0.284175 
  0.096714 -0.352377 
  0.188632 -0.305572 
  0.0471581 -0.413893 
  0.153464 -0.376449 
  0.249378 -0.317608 
  0.111101 -0.437964 
  0.220604 -0.391159 
  0.312522 -0.309584 
  0.066341 -0.145097 
  0.136679 -0.137073 
  0.178242 -0.0768945 
  0.0343694 -0.214636 
  0.096714 -0.194577 
  0.0775311 -0.257429 
  0.151066 -0.210624 
  0.198224 -0.146434 
  0.239787 -0.0742199 
  0.271758 0.290862 
  0.32611 0.147771 
  0.322114 0.0354383 
  0.301332 -0.0635215 
  0.256572 -0.151783 
  0.206217 -0.229346 
  0.264565 0.368425 
  0.338899 0.238707 
  0.376465 0.0782318 
  0.36048 -0.0394502 
  0.322114 -0.142422 
  0.261368 -0.236033 
  0.345293 0.320282 
  0.402043 0.166493 
  0.414831 0.011367 
  0.384458 -0.113001 
  0.326909 -0.228009 
  0.41643 0.246731 
  0.45 0.0916048 
  0.43881 -0.0581724 
  0.392451 -0.189227 
  0.00079929 0.104978 
  0.00079929 -0.034101 
  0.00079929 0.45 
  0.00079929 0.352377 
  0.00079929 0.238707 
  0.00079929 -0.368425 
  0.00079929 -0.45 
  0.00079929 -0.157132 
  0.00079929 -0.26679 
  0.400444 0.440639 
  -0.43881 0.507504 
];
lay.width = [
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
  0.0489432 
];
lay.height = [
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
  0.0521694 
];
lay.label = {
 'MLC11'
 'MLC12'
 'MLC13'
 'MLC14'
 'MLC15'
 'MLC21'
 'MLC22'
 'MLC23'
 'MLC24'
 'MLC31'
 'MLC32'
 'MLC33'
 'MLC41'
 'MLC42'
 'MLC43'
 'MLF11'
 'MLF12'
 'MLF21'
 'MLF22'
 'MLF23'
 'MLF31'
 'MLF32'
 'MLF33'
 'MLF34'
 'MLF41'
 'MLF42'
 'MLF43'
 'MLF44'
 'MLF45'
 'MLF51'
 'MLF52'
 'MLO11'
 'MLO12'
 'MLO21'
 'MLO22'
 'MLO31'
 'MLO32'
 'MLO33'
 'MLO41'
 'MLO42'
 'MLO43'
 'MLP11'
 'MLP12'
 'MLP13'
 'MLP21'
 'MLP22'
 'MLP31'
 'MLP32'
 'MLP33'
 'MLP34'
 'MLT11'
 'MLT12'
 'MLT13'
 'MLT14'
 'MLT15'
 'MLT16'
 'MLT21'
 'MLT22'
 'MLT23'
 'MLT24'
 'MLT25'
 'MLT26'
 'MLT31'
 'MLT32'
 'MLT33'
 'MLT34'
 'MLT35'
 'MLT41'
 'MLT42'
 'MLT43'
 'MLT44'
 'MRC11'
 'MRC12'
 'MRC13'
 'MRC14'
 'MRC15'
 'MRC21'
 'MRC22'
 'MRC23'
 'MRC24'
 'MRC31'
 'MRC32'
 'MRC33'
 'MRC41'
 'MRC42'
 'MRC43'
 'MRF11'
 'MRF12'
 'MRF21'
 'MRF22'
 'MRF23'
 'MRF31'
 'MRF32'
 'MRF33'
 'MRF34'
 'MRF41'
 'MRF42'
 'MRF43'
 'MRF44'
 'MRF45'
 'MRF51'
 'MRF52'
 'MRO11'
 'MRO12'
 'MRO21'
 'MRO22'
 'MRO31'
 'MRO32'
 'MRO33'
 'MRO41'
 'MRO42'
 'MRO43'
 'MRP11'
 'MRP12'
 'MRP13'
 'MRP21'
 'MRP22'
 'MRP31'
 'MRP32'
 'MRP33'
 'MRP34'
 'MRT11'
 'MRT12'
 'MRT13'
 'MRT14'
 'MRT15'
 'MRT16'
 'MRT21'
 'MRT22'
 'MRT23'
 'MRT24'
 'MRT25'
 'MRT26'
 'MRT31'
 'MRT32'
 'MRT33'
 'MRT34'
 'MRT35'
 'MRT41'
 'MRT42'
 'MRT43'
 'MRT44'
 'MZC01'
 'MZC02'
 'MZF01'
 'MZF02'
 'MZF03'
 'MZO01'
 'MZO02'
 'MZP01'
 'MZP02'
 'SCALE'
 'COMNT'
};
lay.outline = { [ 0.5 0 ; 0.499013 0.0313953 ; 0.496057 0.0626666 ; 0.491144 0.0936907 ; 0.484292 0.124345 ; 0.475528 0.154508 ; 0.464888 0.184062 ; 0.452414 0.21289 ; 0.438153 0.240877 ; 0.422164 0.267913 ; 0.404508 0.293893 ; 0.385257 0.318712 ; 0.364484 0.342274 ; 0.342274 0.364484 ; 0.318712 0.385257 ; 0.293893 0.404508 ; 0.267913 0.422164 ; 0.240877 0.438153 ; 0.21289 0.452414 ; 0.184062 0.464888 ; 0.154508 0.475528 ; 0.124345 0.484292 ; 0.0936907 0.491144 ; 0.0626666 0.496057 ; 0.0313953 0.499013 ; -8.04061e-17 0.5 ; -0.0313953 0.499013 ; -0.0626666 0.496057 ; -0.0936907 0.491144 ; -0.124345 0.484292 ; -0.154508 0.475528 ; -0.184062 0.464888 ; -0.21289 0.452414 ; -0.240877 0.438153 ; -0.267913 0.422164 ; -0.293893 0.404508 ; -0.318712 0.385257 ; -0.342274 0.364484 ; -0.364484 0.342274 ; -0.385257 0.318712 ; -0.404508 0.293893 ; -0.422164 0.267913 ; -0.438153 0.240877 ; -0.452414 0.21289 ; -0.464888 0.184062 ; -0.475528 0.154508 ; -0.484292 0.124345 ; -0.491144 0.0936907 ; -0.496057 0.0626666 ; -0.499013 0.0313953 ; -0.5 6.12323e-17 ; -0.499013 -0.0313953 ; -0.496057 -0.0626666 ; -0.491144 -0.0936907 ; -0.484292 -0.124345 ; -0.475528 -0.154508 ; -0.464888 -0.184062 ; -0.452414 -0.21289 ; -0.438153 -0.240877 ; -0.422164 -0.267913 ; -0.404508 -0.293893 ; -0.385257 -0.318712 ; -0.364484 -0.342274 ; -0.342274 -0.364484 ; -0.318712 -0.385257 ; -0.293893 -0.404508 ; -0.267913 -0.422164 ; -0.240877 -0.438153 ; -0.21289 -0.452414 ; -0.184062 -0.464888 ; -0.154508 -0.475528 ; -0.124345 -0.484292 ; -0.0936907 -0.491144 ; -0.0626666 -0.496057 ; -0.0313953 -0.499013 ; -9.18485e-17 -0.5 ; 0.0313953 -0.499013 ; 0.0626666 -0.496057 ; 0.0936907 -0.491144 ; 0.124345 -0.484292 ; 0.154508 -0.475528 ; 0.184062 -0.464888 ; 0.21289 -0.452414 ; 0.240877 -0.438153 ; 0.267913 -0.422164 ; 0.293893 -0.404508 ; 0.318712 -0.385257 ; 0.342274 -0.364484 ; 0.364484 -0.342274 ; 0.385257 -0.318712 ; 0.404508 -0.293893 ; 0.422164 -0.267913 ; 0.438153 -0.240877 ; 0.452414 -0.21289 ; 0.464888 -0.184062 ; 0.475528 -0.154508 ; 0.484292 -0.124345 ; 0.491144 -0.0936907 ; 0.496057 -0.0626666 ; 0.499013 -0.0313953 ; 0.5 -1.22465e-16 ], [ 0.09 0.496 ; 0 0.575 ; -0.09 0.496 ], [ 0.497 0.0555 ; 0.51 0.0775 ; 0.518 0.0783 ; 0.5299 0.0746 ; 0.5419 0.0555 ; 0.54 -0.0055 ; 0.547 -0.0932 ; 0.532 -0.1313 ; 0.51 -0.1384 ; 0.489 -0.1199 ], [ -0.497 0.0555 ; -0.51 0.0775 ; -0.518 0.0783 ; -0.5299 0.0746 ; -0.5419 0.0555 ; -0.54 -0.0055 ; -0.547 -0.0932 ; -0.532 -0.1313 ; -0.51 -0.1384 ; -0.489 -0.1199 ]};
lay.mask = { [ 0.5 0 ; 0.499013 0.0313953 ; 0.496057 0.0626666 ; 0.491144 0.0936907 ; 0.484292 0.124345 ; 0.475528 0.154508 ; 0.464888 0.184062 ; 0.452414 0.21289 ; 0.438153 0.240877 ; 0.422164 0.267913 ; 0.404508 0.293893 ; 0.385257 0.318712 ; 0.364484 0.342274 ; 0.342274 0.364484 ; 0.318712 0.385257 ; 0.293893 0.404508 ; 0.267913 0.422164 ; 0.240877 0.438153 ; 0.21289 0.452414 ; 0.184062 0.464888 ; 0.154508 0.475528 ; 0.124345 0.484292 ; 0.0936907 0.491144 ; 0.0626666 0.496057 ; 0.0313953 0.499013 ; -8.04061e-17 0.5 ; -0.0313953 0.499013 ; -0.0626666 0.496057 ; -0.0936907 0.491144 ; -0.124345 0.484292 ; -0.154508 0.475528 ; -0.184062 0.464888 ; -0.21289 0.452414 ; -0.240877 0.438153 ; -0.267913 0.422164 ; -0.293893 0.404508 ; -0.318712 0.385257 ; -0.342274 0.364484 ; -0.364484 0.342274 ; -0.385257 0.318712 ; -0.404508 0.293893 ; -0.422164 0.267913 ; -0.438153 0.240877 ; -0.452414 0.21289 ; -0.464888 0.184062 ; -0.475528 0.154508 ; -0.484292 0.124345 ; -0.491144 0.0936907 ; -0.496057 0.0626666 ; -0.499013 0.0313953 ; -0.5 6.12323e-17 ; -0.499013 -0.0313953 ; -0.496057 -0.0626666 ; -0.491144 -0.0936907 ; -0.484292 -0.124345 ; -0.475528 -0.154508 ; -0.464888 -0.184062 ; -0.452414 -0.21289 ; -0.438153 -0.240877 ; -0.422164 -0.267913 ; -0.404508 -0.293893 ; -0.385257 -0.318712 ; -0.364484 -0.342274 ; -0.342274 -0.364484 ; -0.318712 -0.385257 ; -0.293893 -0.404508 ; -0.267913 -0.422164 ; -0.240877 -0.438153 ; -0.21289 -0.452414 ; -0.184062 -0.464888 ; -0.154508 -0.475528 ; -0.124345 -0.484292 ; -0.0936907 -0.491144 ; -0.0626666 -0.496057 ; -0.0313953 -0.499013 ; -9.18485e-17 -0.5 ; 0.0313953 -0.499013 ; 0.0626666 -0.496057 ; 0.0936907 -0.491144 ; 0.124345 -0.484292 ; 0.154508 -0.475528 ; 0.184062 -0.464888 ; 0.21289 -0.452414 ; 0.240877 -0.438153 ; 0.267913 -0.422164 ; 0.293893 -0.404508 ; 0.318712 -0.385257 ; 0.342274 -0.364484 ; 0.364484 -0.342274 ; 0.385257 -0.318712 ; 0.404508 -0.293893 ; 0.422164 -0.267913 ; 0.438153 -0.240877 ; 0.452414 -0.21289 ; 0.464888 -0.184062 ; 0.475528 -0.154508 ; 0.484292 -0.124345 ; 0.491144 -0.0936907 ; 0.496057 -0.0626666 ; 0.499013 -0.0313953 ; 0.5 -1.22465e-16 ] };


figure
ft_plot_lay(lay);


