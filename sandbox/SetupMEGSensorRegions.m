%% Setup MEG sensor regions
clear;
LF = [229 212 177 153 125 93  64  124 92  230 213 178 154 126 94  65  40  179 155 127 95  66  41                                                             ];
MF = [123 122 121 152 151 91  90  89  120 119 63  62  61  88  87  39  38  37  60  59  22  21  20  19  36  35  34  7   6   5   4   18  17                     ];
RF = [150 118 86  117 149 176 195 58  85  116 148 175 194 228 248 57  84  115 147 174 193 227 247                                                            ];
LT = [231 196 156 128 96  67  42  232 197 157 129 97  68  43  233 198 158 130 98  69  44  214 180 131 99  70  45  159 181 132 100 71  46  160 101 72  133 102];
MP = [23  8   3   16  33  24  9   2   15  32  25  10  1   14  31  26  11  12  13  30  47  27  28  29  51  73  48  49  50  77  74  75  76                     ];
RT = [56  83  114 146 173 211 246 55  82  113 145 172 210 245 54  81  112 144 171 209 244 53  80  111 143 192 226 52  79  110 142 170 191 78  109 169 141 108];
LO = [215 199 182 161 134 234 216 200 183 162 235 217 201 236 218 237                                                                                        ];
MO = [103 107 135 104 105 106 139 184 163 136 137 138 166 188 202 185 164 165 187 205 219 203 186 204 221 220 238 239                                        ];
RO = [140 168 190 208 225 167 189 207 224 243 206 223 242 222 241 240                                                                                        ];

roi = {};
roi{end+1} = LF;
roi{end+1} = MF;
roi{end+1} = RF;
roi{end+1} = LT;
roi{end+1} = MP;
roi{end+1} = RT;
roi{end+1} = LO;
roi{end+1} = MO;
roi{end+1} = RO;

cfg = [];
cfg.layout = '4D248.mat';
lay = ft_prepare_layout(cfg);

% plot sensor membership
colormap;
labelROI = zeros(length(lay.label),1);
for ri=1:length(roi)
  neighbors = roi{ri};
  for ni=1:length(neighbors)
    lbl = sprintf('A%i', neighbors(ni));
    lbli = strmatch(lbl,lay.label,'exact');
    labelROI(lbli) = ri;
  end
end
  
%lay.label{end-1} = '';
%ft_plot_lay(lay, 'box', 'off', 'label', 'no', 'point', 'no');
ft_plot_lay(lay);
ft_plot_topo(lay.pos(:,1),lay.pos(:,2),labelROI(:)/max(labelROI),'gridscale',150,'outline',lay.outline,'mask',lay.mask,'interpmethod','nearest');
axis off;
abc = caxis;
caxis([-1 1]*abc(2));










