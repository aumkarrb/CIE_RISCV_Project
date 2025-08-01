# Fixed-point inverse-distance weighting

# Target >90% accuracy

.equ NUM_TEST, 10
.equ TRAIN_SIZE, 128
.equ IMAGE_PIXELS, 64
.equ K_NEIGHBORS, 5
.equ NUM_CLASSES, 10
.equ DIST_CLAMP, 65535
.equ INV_SCALE, 1000

.data
train_images: 
.byte 0,0,0,9,0,0,0,0,0,0,0,128,0,0,0,0,0,0,0,144,13,0,0,0,0,0,0,119,38,0,0,0,0,0,0,65,72,0,0,0,0,0,0,4,165,108,0,0,0,0,0,0,103,83,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,1,60,0,0,0,0,0,2,113,114,0,0,0,0,0,114,150,2,0,0,0,0,35,194,10,28,133,107,12,0,65,140,56,158,31,131,83,0,3,132,214,158,141,127,8,0,0,0,31,48,2,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,6,68,8,0,0,0,0,0,50,199,180,28,0,0,0,0,0,0,22,115,0,0,0,0,0,0,9,111,0,0,65,177,215,162,171,25,0,0,181,169,133,108,162,0,0,0,18,0,0,0,42,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,16,156,202,117,0,0,0,0,17,82,41,223,11,0,0,0,29,102,180,112,0,0,0,0,29,107,189,51,0,0,0,35,131,39,166,97,0,0,0,31,178,183,99,5,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,71,184,13,0,0,0,0,51,214,175,199,20,0,0,0,146,33,5,94,131,0,0,0,172,0,0,115,94,0,0,0,212,28,92,157,6,0,0,0,147,209,123,7,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,32,7,55,18,0,0,0,0,139,10,91,29,0,0,0,14,138,0,100,109,2,0,0,70,177,151,197,222,144,1,0,4,30,17,101,72,0,0,0,0,0,0,94,82,0,0,0,0,0,0,8,11,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,68,189,219,80,0,0,0,0,161,65,96,81,0,0,0,0,0,0,152,31,0,0,0,0,0,30,158,1,0,0,0,0,0,153,59,0,0,0,0,0,3,115,3,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,47,10,0,0,0,0,28,153,125,84,9,0,0,0,113,22,19,143,3,0,0,0,124,165,208,61,0,0,0,0,1,11,122,2,0,0,0,0,0,111,47,0,0,0,0,0,0,49,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,88,137,100,5,0,0,0,88,100,8,92,94,0,0,0,0,0,0,73,85,0,0,0,0,0,48,198,120,100,9,0,0,0,8,8,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,1,56,131,125,1,0,0,0,115,131,69,202,2,0,0,0,21,127,183,190,40,0,0,0,40,56,3,167,33,0,0,2,0,1,97,128,0,0,0,163,150,165,105,2,0,0,0,9,32,15,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,3,77,124,129,10,0,0,0,59,122,80,187,11,0,0,0,0,1,146,72,0,0,0,0,0,11,165,153,53,0,0,0,0,0,1,43,182,0,0,0,0,47,121,166,105,0,0,0,0,19,26,7,0,0,0
.byte 0,0,1,21,16,0,0,0,0,0,115,159,179,25,0,0,0,0,92,2,73,104,0,0,0,0,0,0,55,133,0,0,0,0,71,175,192,136,4,0,0,0,173,98,174,117,143,1,0,0,47,126,20,0,1,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,44,61,3,0,0,0,0,89,95,86,97,0,0,0,0,116,66,59,123,0,0,0,0,9,107,120,118,0,0,0,0,0,0,47,81,0,0,0,0,0,17,134,18,0,0,0,0,0,72,41,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,12,87,107,95,14,0,0,0,51,124,119,239,115,0,0,0,54,190,237,150,3,0,0,2,0,0,22,208,9,0,25,146,0,0,58,221,14,0,5,129,183,183,178,63,0,0,0,0,4,6,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,5,20,5,62,73,0,0,0,5,146,100,34,0,0,0,0,48,172,39,0,0,0,0,0,11,15,124,3,0,0,0,7,0,0,125,11,0,0,0,12,110,125,57,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,81,152,32,0,0,0,0,67,144,139,22,0,0,0,0,160,122,79,0,0,0,0,9,194,96,0,0,0,0,4,152,173,55,0,0,0,0,23,178,137,3,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,40,182,144,36,0,0,0,15,202,27,1,34,0,0,0,88,217,10,0,0,0,0,0,137,163,130,120,2,0,0,0,63,100,0,94,61,0,0,0,0,70,117,159,40,0,0,0,0,0,0,0,0,0
.byte 0,0,0,22,41,0,0,0,0,0,1,149,49,0,0,0,0,0,50,139,0,0,0,0,0,0,129,49,10,100,50,0,0,0,137,37,129,54,151,0,0,0,101,121,51,141,97,0,0,0,3,61,72,64,1,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,4,3,84,0,0,0,0,0,0,49,120,0,0,0,0,0,2,175,26,0,0,0,0,0,75,120,0,0,0,0,0,8,151,10,0,0,0,0,0,52,69,0,0,0,0,0,0,8,6,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,20,22,0,0,95,211,176,191,190,34,0,0,158,132,84,44,5,0,0,0,104,206,143,8,0,0,0,0,38,18,180,60,0,0,0,0,35,155,204,39,0,0,0,0,0,48,67,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,31,10,37,57,16,0,0,0,182,219,172,125,21,0,0,0,109,63,0,0,0,0,36,66,38,128,0,0,0,0,5,160,116,169,0,0,0,0,0,3,128,182,5,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,104,144,104,0,0,0,0,13,171,68,9,0,0,0,0,38,200,176,73,0,0,0,0,17,107,6,159,8,0,0,0,0,0,2,164,24,0,0,33,144,103,157,107,0,0,0,0,11,33,12,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,80,48,0,0,0,0,0,0,76,89,0,0,0,0,0,0,66,99,0,0,0,0,0,0,86,99,0,0,0,0,0,0,99,76,0,0,0,0,0,0,59,69,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,9,116,37,16,0,0,0,0,116,151,124,238,61,0,0,0,212,29,53,139,90,0,0,0,195,9,0,130,76,0,0,0,199,12,15,178,30,0,0,0,137,212,195,67,0,0,0,0,0,24,10,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,1,56,4,20,12,0,0,0,92,244,193,218,222,19,0,14,223,210,135,16,204,36,0,90,200,65,1,69,196,2,0,128,199,109,152,208,47,0,0,15,138,169,92,11,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,26,60,92,107,108,84,0,0,85,75,55,30,114,162,0,0,0,0,2,114,141,7,0,0,0,2,134,98,3,0,0,0,5,144,81,0,0,0,0,0,41,72,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,185,117,109,174,185,9,0,79,228,148,78,158,105,1,0,42,26,0,104,144,2,0,0,0,0,55,188,13,0,0,0,0,4,184,36,0,0,0,0,0,31,125,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,2,57,133,110,7,0,0,2,135,141,143,158,6,0,0,13,186,143,130,5,0,0,0,30,237,85,1,0,0,0,0,155,197,55,0,0,0,0,0,171,193,41,0,0,0,0,0,12,28,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,6,68,9,0,0,0,0,4,169,239,144,3,0,0,0,43,248,161,250,34,0,0,0,0,119,165,212,100,0,0,0,0,0,0,115,192,0,0,0,0,0,0,68,238,17,0,0,0,0,0,0,79,6,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,41,81,0,0,0,101,26,0,149,42,0,0,10,181,14,39,176,10,0,0,74,166,141,220,148,48,0,0,0,0,37,153,1,0,0,0,0,0,115,48,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,42,44,0,0,0,1,78,6,147,5,0,0,0,65,205,104,60,0,0,0,0,93,98,194,35,0,0,0,0,4,139,23,0,0,0,0,0,78,84,0,0,0,0,0,0,18,10,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,95,60,0,0,0,2,8,51,135,70,0,0,0,83,79,141,20,2,0,0,0,162,79,151,0,0,0,0,0,59,200,35,0,0,0,0,0,35,129,0,0,0,0,0,0,10,13,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,11,99,0,0,0,0,0,0,13,157,0,0,0,0,0,0,13,157,0,0,0,0,0,0,13,157,0,0,0,0,0,0,20,150,0,0,0,0,0,0,7,109,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,1,30,19,0,0,0,0,0,110,228,77,0,0,0,0,81,222,46,0,0,0,0,3,209,91,27,27,7,0,0,43,233,166,252,252,134,0,0,11,228,252,252,218,48,0,0,0,35,126,96,21,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,56,6,0,0,0,0,0,0,143,2,0,0,0,0,0,9,130,0,0,0,0,0,0,52,85,0,0,0,0,0,0,81,62,0,0,0,0,0,0,107,9,0,0,0,0,0,0,15,3,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,52,76,3,0,0,34,60,8,70,138,29,0,26,182,26,0,0,161,21,0,115,52,0,1,105,94,0,0,104,91,29,124,92,0,0,0,5,89,109,31,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,15,32,3,0,0,0,0,21,202,253,225,74,0,0,0,167,182,67,71,209,0,0,96,134,9,0,33,169,0,0,202,25,16,84,142,19,0,0,100,193,155,45,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,92,161,92,0,0,0,0,0,112,24,19,0,0,0,0,0,66,219,29,0,0,0,0,0,71,82,0,0,0,0,0,0,98,0,0,0,0,0,0,0,20,0,0,0,0
.byte 0,0,0,0,50,6,0,0,0,0,0,31,155,5,0,0,0,0,3,159,18,0,0,0,0,0,71,111,97,99,0,0,0,0,109,114,129,152,13,0,0,0,74,226,147,114,1,0,0,0,0,50,16,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,25,26,0,0,0,0,0,8,108,7,0,0,0,0,0,93,17,0,0,0,0,0,0,115,0,0,0,0,0,0,16,134,112,80,0,0,0,0,10,215,126,54,0,0,0,0,0,28,18,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,22,8,0,0,0,0,0,62,125,142,4,0,0,0,0,8,0,132,26,0,0,0,0,0,0,132,12,0,0,0,0,2,72,122,0,0,0,0,0,104,187,145,38,12,0,0,0,107,46,40,85,18,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,3,182,203,72,0,0,0,0,0,16,131,147,0,0,0,0,24,129,209,41,0,0,0,0,63,208,188,61,0,0,0,0,64,28,181,186,0,0,0,0,105,215,164,31,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,18,76,6,19,0,0,0,0,56,152,46,147,0,0,0,0,129,126,145,122,0,0,0,0,131,190,210,59,0,0,0,0,1,1,211,28,0,0,0,0,0,5,209,10,0,0,0,0,0,0,22,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,131,212,191,163,120,4,0,66,166,13,6,108,216,13,0,44,13,4,129,203,25,0,0,0,12,151,191,23,0,0,0,38,193,127,3,0,0,0,0,36,83,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,60,44,0,0,0,0,0,0,182,86,0,0,0,0,0,31,216,16,0,0,0,0,0,115,127,0,0,0,0,0,10,208,23,0,0,0,0,0,77,157,0,0,0,0,0,0,4,12,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,35,22,0,0,0,0,4,113,138,146,31,0,0,0,108,86,1,151,94,0,0,0,160,115,167,138,0,0,0,0,17,123,159,5,0,0,0,0,45,188,8,0,0,0,0,0,48,23,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,25,174,154,159,59,3,0,0,56,135,2,18,182,21,0,0,0,88,133,133,188,0,0,0,0,0,0,77,118,0,0,0,0,0,0,114,82,0,0,0,0,0,0,57,94,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,13,34,30,50,94,79,0,0,8,62,75,34,39,65,0,0,0,0,0,0,79,42,0,0,0,0,0,0,82,22,0,0,0,0,0,0,106,7,0,0,0,0,0,0,98,0,0,0
.byte 0,0,0,8,32,2,0,0,0,0,2,174,195,97,0,0,0,0,0,25,67,118,0,0,0,0,0,2,172,33,0,0,0,3,29,111,125,0,0,0,0,62,245,244,178,138,14,0,0,21,86,11,32,89,32,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,3,139,200,37,0,0,0,0,98,251,189,185,0,0,0,0,192,165,43,247,25,0,0,49,241,38,15,232,60,0,0,101,212,8,26,234,35,0,0,23,156,198,205,111,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,3,116,76,0,0,0,0,0,124,213,173,8,0,0,0,28,189,169,102,16,0,0,0,83,61,0,121,4,0,0,0,124,28,30,111,0,0,0,0,66,163,155,14,0,0,0,0,1,32,11,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7,126,0,0,117,56,0,0,128,83,0,102,87,0,0,45,132,120,166,192,9,0,0,20,128,62,120,28,0,0,0,0,0,0,95,0,0,0,0,0,0,0,6,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,2,90,0,0,0,0,0,0,72,82,0,0,0,0,0,0,142,9,0,0,0,0,0,50,110,0,0,0,0,0,1,164,71,0,0,0,0,0,23,120,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,23,79,0,7,0,0,0,19,188,115,6,143,3,0,23,213,214,85,174,145,0,0,26,136,175,237,206,34,0,0,0,0,16,214,31,0,0,0,0,3,157,67,0,0,0,0,0,1,24,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,13,92,0,0,0,0,0,0,48,143,0,0,0,0,0,0,79,90,0,0,0,0,0,0,77,92,0,0,0,0,0,0,32,148,0,0,0,0,0,0,2,131,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,8,124,164,0,0,0,0,1,146,206,230,19,0,0,0,68,206,10,166,47,0,0,8,206,70,30,194,17,0,0,68,194,110,209,77,0,0,0,40,200,148,24,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,50,79,93,114,30,0,0,23,246,175,97,47,3,0,0,11,235,31,16,16,0,0,0,0,183,181,165,182,74,0,0,0,3,2,3,120,129,0,0,0,43,160,187,186,27,0,0,0,0,11,23,5,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,45,25,0,0,0,0,0,0,169,41,0,0,0,0,0,4,149,4,0,0,0,0,0,53,119,0,0,0,0,0,0,167,36,0,0,0,0,0,0,148,0,0,0,0,0,0,0,11,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,18,18,0,2,0,0,0,10,139,18,12,138,0,0,3,129,63,5,108,67,0,0,22,194,154,151,182,3,0,0,0,0,0,144,60,0,0,0,0,0,41,124,0,0,0,0,0,0,45,4,0,0,0
.byte 0,0,0,0,20,0,0,0,0,0,0,0,135,0,0,0,0,0,0,4,182,0,0,0,0,0,0,36,175,0,0,0,0,0,0,92,116,0,0,0,0,0,0,130,145,4,0,0,0,0,0,77,82,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,5,111,104,37,0,0,0,0,0,24,45,107,0,0,0,0,0,48,141,12,0,0,0,0,0,5,121,26,0,0,0,0,7,0,62,52,0,0,0,11,81,75,114,5,0,0,0,0,22,28,1,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,8,5,5,86,0,0,0,0,90,101,61,149,0,0,0,0,90,98,167,85,0,0,0,0,20,166,236,25,0,0,0,0,0,128,136,0,0,0,0,0,23,204,16,0,0,0,0,0,5,19,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,45,121,136,44,0,0,0,95,181,106,138,170,43,0,0,140,15,0,0,17,168,4,0,135,0,0,0,0,160,8,0,135,54,0,0,6,157,1,0,24,171,119,69,149,38,0,0,0,10,36,36,20,0,0
.byte 0,0,0,0,0,0,0,0,0,0,2,13,0,31,55,0,0,0,104,65,1,161,14,0,0,0,163,8,39,156,0,0,0,0,128,110,184,92,0,0,0,0,7,82,167,46,0,0,0,0,0,0,135,21,0,0,0,0,0,0,12,1,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,68,177,182,31,0,0,0,68,216,198,143,140,0,0,16,219,60,3,83,109,0,0,109,154,0,4,183,31,0,0,135,117,47,139,173,0,0,0,21,187,203,141,16,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,78,156,129,0,0,0,17,167,196,125,79,0,0,3,186,160,19,152,90,0,0,123,177,7,0,190,74,0,0,199,96,30,100,217,21,0,0,94,214,204,133,39,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,171,184,161,156,5,0,0,6,149,47,20,200,8,0,0,0,0,0,128,117,0,0,0,0,0,25,197,19,0,0,0,0,4,172,53,0,0,0,0,0,35,98,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,23,38,3,75,71,0,0,3,176,200,199,152,37,0,0,32,191,60,97,47,0,0,0,92,224,113,55,114,141,0,0,18,90,2,0,34,188,0,0,0,131,139,158,198,47,0,0,0,5,34,20,8,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,185,165,134,63,0,0,0,3,160,33,55,123,0,0,0,0,7,1,58,78,0,0,0,0,0,0,136,19,0,0,0,0,0,0,145,0,0,0,0,0,0,0,100,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,49,19,0,0,0,0,9,134,158,96,0,0,0,0,87,188,211,106,0,0,0,0,5,32,141,41,0,0,0,0,0,28,173,2,0,0,0,0,0,155,59,0,0,0,0,0,0,70,1,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,26,90,0,0,0,0,0,0,32,118,0,0,0,0,0,0,36,106,0,0,0,0,0,0,57,69,0,0,0,0,0,0,108,59,0,0,0,0,0,0,88,31,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,46,189,97,0,0,0,0,18,222,149,226,10,0,0,0,64,181,5,218,15,0,0,0,154,113,2,204,13,0,0,0,155,122,89,167,0,0,0,0,34,181,171,23,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,100,128,123,128,114,0,0,0,0,0,1,105,78,0,0,0,0,5,120,76,0,0,0,0,4,120,56,0,0,0,0,10,120,45,0,0,0,0,0,100,46,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,65,181,60,0,0,0,0,40,124,61,88,0,0,0,0,0,0,122,36,0,0,0,0,1,35,186,28,0,0,0,0,70,186,117,131,65,0,0,0,61,145,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,27,73,25,0,0,0,0,0,86,23,137,17,0,0,0,0,0,0,102,35,0,0,0,0,38,126,139,21,0,0,0,0,0,0,56,63,0,0,0,0,0,7,120,10,0,0,0,0,0,51,27,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,2,44,49,1,0,0,0,0,152,200,192,132,0,0,0,0,185,7,94,218,0,0,0,0,134,131,207,201,0,0,0,0,22,132,51,169,0,0,0,0,0,0,26,167,0,0,0,0,0,0,13,43,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,58,165,172,118,0,0,0,0,129,66,42,138,0,0,0,0,45,4,146,52,0,0,0,0,0,27,167,1,0,0,0,0,0,116,74,0,0,0,0,0,0,116,9,0,0,0
.byte 0,0,0,0,0,0,0,0,0,13,51,102,98,82,7,0,0,90,77,45,39,118,30,0,0,0,52,171,150,155,16,0,0,0,26,50,0,2,103,0,0,58,131,27,0,0,59,0,0,2,61,122,131,125,84,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,29,163,174,169,4,0,0,0,130,66,6,0,0,0,0,15,229,179,162,151,27,0,0,0,15,0,0,31,144,2,0,38,64,1,0,35,146,1,0,22,143,183,160,169,20,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,56,167,81,0,0,0,0,0,0,64,171,0,0,0,0,0,1,181,99,0,0,0,0,0,0,18,148,103,0,0,0,0,33,19,11,208,8,0,0,0,88,162,162,84,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,12,137,155,167,37,0,0,0,1,3,22,156,33,0,0,0,0,6,173,40,0,0,0,0,0,0,40,142,141,29,0,0,0,0,0,13,135,86,0,0,52,134,137,125,47,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,1,29,5,0,0,0,0,0,9,183,188,28,0,0,0,0,0,0,93,144,0,0,17,113,163,108,149,123,0,20,219,111,58,196,233,15,0,30,207,67,159,209,193,20,0,0,70,134,93,12,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,36,118,19,0,0,0,0,40,141,49,175,0,0,0,0,127,31,58,133,0,0,0,0,132,116,219,49,0,0,0,5,14,65,171,5,0,0,0,8,0,25,153,0,0,0,0,0,0,7,19,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,45,149,168,16,0,0,0,34,213,69,180,25,0,0,0,196,84,0,53,128,0,0,41,182,2,0,32,184,0,0,40,197,43,68,176,66,0,0,0,119,194,156,37,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,32,36,8,0,0,0,0,0,9,50,94,114,5,0,0,0,0,0,0,114,1,0,0,0,0,34,61,158,75,21,0,0,0,19,36,129,2,0,0,0,0,0,0,126,0,0,0,0,0,0,0,50,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,5,29,0,0,0,0,2,70,211,218,0,0,0,0,88,211,204,216,0,0,0,0,203,198,226,105,0,0,0,0,16,49,212,14,0,0,0,0,0,148,79,0,0,0,0,0,0,71,3,0,0,0
.byte 0,0,0,43,7,0,0,0,0,0,43,158,3,0,0,0,0,0,146,54,0,0,0,0,0,0,175,4,8,58,10,0,0,0,169,184,124,92,173,3,0,0,58,222,104,72,144,4,0,0,0,8,63,32,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,1,24,3,0,0,0,0,6,132,233,91,0,0,0,0,56,142,100,136,0,0,0,0,2,1,115,74,0,0,0,0,14,49,213,15,0,0,0,109,229,238,202,109,0,0,0,47,52,11,10,119,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,7,53,35,0,0,0,0,0,179,159,187,74,0,0,0,0,185,58,46,135,0,0,0,0,44,174,241,208,0,0,0,0,0,0,158,112,0,0,0,0,0,21,197,4,0,0,0,0,0,8,54,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,15,68,0,0,0,0,0,0,18,130,0,0,0,0,0,0,18,130,0,0,0,0,0,0,15,130,0,0,0,0,0,0,11,127,0,0,0,0,0,0,3,137,0,0,0,0,0,0,0,16,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,9,11,16,22,0,0,0,0,75,16,44,16,0,0,0,0,81,6,66,7,0,0,0,0,51,101,143,27,0,0,0,0,0,3,109,0,0,0,0,0,0,0,111,0,0,0,0,0,0,0,12,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,113,167,30,0,0,0,0,50,66,175,20,0,0,0,0,38,161,122,0,0,0,0,0,3,180,160,14,0,0,0,0,25,149,132,57,0,0,0,0,3,148,157,10,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,2,18,0,0,0,0,0,3,153,99,0,0,0,0,0,105,90,13,19,0,0,0,0,169,33,173,178,2,0,0,0,143,169,23,92,66,0,0,0,67,198,99,175,19,0,0,0,3,113,105,25,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,52,182,191,25,0,0,0,129,229,54,191,37,0,0,0,66,244,198,115,0,0,0,0,4,194,197,5,0,0,0,0,105,159,199,55,0,0,0,0,117,213,188,58,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,5,58,4,0,0,0,0,44,185,172,159,21,0,0,18,190,32,124,239,12,0,0,42,197,169,200,192,0,0,0,1,23,11,111,140,0,0,0,0,0,0,181,82,0,0,0,0,0,0,52,21,0,0
.byte 0,0,0,0,0,0,0,0,0,0,89,120,86,75,0,0,0,0,207,235,173,110,0,0,0,0,18,149,157,21,0,0,0,0,0,0,84,172,6,0,0,15,61,18,2,191,73,0,0,12,91,165,209,216,41,0,0,0,0,0,24,24,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,96,194,63,0,0,0,0,36,236,127,158,57,0,0,0,155,151,1,102,133,0,0,0,208,71,10,179,112,0,0,0,208,111,181,184,8,0,0,0,88,212,147,12,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,76,140,201,211,44,0,0,134,231,103,16,174,60,0,0,100,27,0,50,205,0,0,0,0,0,0,150,110,0,0,0,0,0,47,168,5,0,0,0,0,0,52,53,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,23,134,189,72,0,0,0,0,15,29,36,152,0,0,0,0,45,137,200,67,0,0,0,0,50,72,64,129,0,0,0,0,0,0,77,138,0,0,0,141,161,165,129,11,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,21,190,159,5,0,0,0,23,198,148,146,88,0,0,0,174,89,3,89,146,0,0,16,216,3,3,133,62,0,0,31,195,60,164,91,0,0,0,0,198,198,47,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,31,61,8,132,0,0,0,0,94,117,35,143,0,0,0,0,111,81,103,91,7,5,0,0,162,138,205,152,100,8,0,0,208,67,207,16,0,0,0,0,6,6,177,8,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,94,61,0,0,0,0,0,77,165,0,0,0,0,0,11,195,32,0,0,0,0,0,126,118,0,0,0,0,0,60,188,10,0,0,0,0,0,149,18,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,24,72,72,25,1,0,0,0,91,192,194,248,72,0,0,0,0,37,146,251,190,86,1,0,0,172,249,251,250,169,2,0,0,8,196,244,95,3,0,0,0,12,216,228,23,0,0,0,0,3,71,61,1,0,0
.byte 0,0,0,25,21,0,0,0,0,0,88,190,199,59,0,0,0,0,81,17,74,131,0,0,0,0,0,0,81,125,0,0,0,0,107,177,223,87,19,2,0,0,189,137,224,175,95,3,0,0,81,116,22,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,1,87,178,18,0,0,0,0,66,175,166,5,0,0,0,0,28,91,142,0,0,0,0,0,0,4,173,60,0,0,0,0,50,93,37,182,0,0,0,0,8,127,185,164,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,20,94,93,114,0,0,0,45,195,96,113,236,6,0,0,57,184,42,42,170,0,0,0,0,56,216,229,118,0,0,0,0,133,98,14,155,61,0,0,0,105,167,119,185,63,0,0,0,1,27,36,32,1,0
.byte 0,0,0,0,0,0,0,0,0,0,0,36,73,48,0,0,0,0,0,133,132,211,0,0,0,0,0,113,137,43,0,0,0,0,0,124,111,0,0,0,0,0,21,132,119,0,0,0,0,0,79,51,122,0,0,0,0,0,20,92,21,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,9,29,36,0,0,0,0,0,72,83,169,12,0,0,0,0,0,2,151,0,0,0,0,0,0,61,107,0,0,0,0,0,0,104,60,0,0,0,0,0,0,102,75,0,0,0,0,0,0,31,24,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,60,174,3,0,0,0,0,23,202,249,175,10,0,0,0,168,125,118,224,75,0,0,38,186,3,0,126,81,0,0,121,92,0,47,211,41,0,0,108,122,101,209,121,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,75,9,0,0,0,0,4,30,178,2,0,0,0,0,16,170,48,0,0,0,0,1,145,90,0,0,0,0,0,77,138,0,0,0,0,0,12,162,6,0,0,0,0,0,1,18,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,34,155,208,115,0,0,0,0,134,123,170,87,0,0,0,0,22,101,193,18,0,0,0,0,0,11,162,1,0,0,0,0,0,74,101,0,0,0,0,0,0,66,58,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,16,125,7,0,0,0,0,0,67,124,100,0,0,0,0,0,35,140,144,0,0,0,0,0,0,0,107,23,0,0,0,0,0,0,75,61,0,0,0,0,10,128,157,52,0,0,0,0,0,0,27,2,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,45,14,0,0,0,0,0,47,137,134,133,1,0,0,0,87,26,16,129,1,0,0,0,0,42,175,63,0,0,0,0,0,32,128,1,0,0,0,0,1,161,23,0,0,0,0,0,2,69,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,138,184,185,53,0,0,0,0,14,2,163,54,0,0,0,0,34,172,200,8,0,0,0,0,32,49,127,131,10,0,0,0,180,49,17,188,24,0,0,0,52,161,179,91,35,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,60,81,11,0,0,0,0,0,58,155,149,0,0,0,0,0,0,122,108,0,0,0,0,7,118,241,186,151,111,28,0,53,168,47,43,67,95,59,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,12,115,70,8,0,0,0,28,152,74,51,2,0,0,52,165,27,17,111,0,0,4,164,21,1,123,51,0,0,41,136,13,105,78,1,0,0,2,105,139,72,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,32,14,0,12,1,0,0,0,211,97,11,186,3,0,0,45,246,125,65,239,30,0,0,148,219,174,225,252,104,0,0,18,14,0,122,218,24,0,0,0,0,0,169,119,0,0,0,0,0,0,65,24,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,3,64,10,0,0,0,0,18,174,192,68,0,0,0,0,103,231,201,104,0,0,0,0,4,49,198,27,0,0,0,0,0,90,140,0,0,0,0,0,19,190,19,0,0,0,0,0,23,56,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,112,43,0,0,0,0,0,1,172,7,0,0,0,0,0,25,161,0,0,0,0,0,0,79,109,0,0,0,0,0,0,148,56,0,0,0,0,0,0,149,14,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,28,30,5,4,0,0,0,0,35,132,162,187,18,0,0,0,0,0,0,109,41,0,0,0,0,0,0,143,57,0,0,0,0,0,0,158,45,0,0,0,0,0,0,173,21,0,0,0,0,0,0,67,2,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,82,160,159,148,154,0,0,0,0,1,18,57,182,0,0,0,0,0,0,136,57,0,0,0,0,0,49,116,0,0,0,0,0,2,162,70,0,0,0,0,0,8,120,1,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,20,45,2,7,0,0,0,10,188,56,57,161,0,0,0,68,145,0,88,171,0,0,0,37,208,138,216,89,0,0,0,0,21,36,175,61,0,0,0,0,0,0,65,165,3,0,0,0,0,0,0,63,6,0
.byte 0,0,0,0,0,0,0,0,0,0,45,178,179,46,0,0,0,89,238,131,86,130,0,0,0,78,46,65,201,210,21,0,0,0,0,98,99,117,114,0,0,5,148,76,78,184,61,0,0,2,134,210,194,70,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,40,190,128,0,0,0,0,19,218,83,170,0,0,0,0,14,52,41,169,0,0,0,0,17,119,204,44,0,0,0,0,170,164,51,61,0,0,0,0,107,210,216,103,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,70,202,164,34,0,0,0,0,60,87,122,144,0,0,0,0,0,6,192,117,0,0,0,0,2,122,186,24,0,0,0,0,67,248,169,98,66,0,0,0,127,147,115,55,8,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,129,7,0,0,0,0,0,0,149,44,0,0,0,0,0,0,89,100,0,0,0,0,0,0,40,160,0,0,0,0,0,0,1,188,13,0,0,0,0,0,0,116,27,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,51,14,0,0,0,0,0,49,152,6,0,0,0,0,8,178,20,0,0,0,0,0,98,123,14,103,97,0,0,0,193,35,181,139,148,0,0,0,124,174,236,137,10,0,0,0,4,63,29,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,10,52,0,0,0,0,0,0,116,78,0,0,0,0,0,27,170,2,0,0,0,0,0,129,67,8,0,0,0,0,11,203,247,81,0,0,0,0,28,246,190,13,0,0,0,0,0,55,4,0,0,0,0,0,0,0,0,0,0,0

train_labels: 
.byte 1,6,2,3,0,4,7,9,2,3,3,2,9,3,5,8,6,6,1,5,5,5,1,0,0,7,7,8,9,4,4,4,1,6,1,0,0,9,6,6,2,3,4,7,1,9,9,7,2,0,0,4,1,4,1,0,5,1,4,1,3,4,0,4,0,0,7,5,7,9,1,0,7,2,3,9,7,3,5,3,3,2,9,0,7,9,6,2,9,1,4,8,6,8,9,5,0,7,3,0,4,1,7,2,3,8,8,7,0,1,9,9,7,3,2,0,4,9,1,7,7,9,3,2,2,1,6,6

test_images: 
.byte 0,0,0,0,0,0,0,0,0,0,69,163,153,46,0,0,0,0,94,81,124,47,0,0,0,0,3,123,179,28,0,0,0,0,12,139,13,133,3,0,0,0,77,60,0,114,30,0,0,0,40,153,158,154,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,62,51,0,0,0,0,1,126,157,100,0,0,0,0,55,110,22,122,0,0,0,0,134,31,9,131,0,0,0,0,131,6,71,88,0,0,0,0,57,144,101,2,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,6,81,108,0,0,0,0,84,193,93,5,0,0,0,0,107,133,114,132,0,0,0,0,159,41,0,140,34,0,0,0,88,22,0,109,75,0,0,0,33,105,138,157,14,0,0,0,1,12,19,2,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,32,0,30,0,0,0,0,59,124,81,139,0,0,0,13,162,31,163,6,0,0,0,140,156,180,119,0,0,0,0,13,144,90,1,0,0,0,0,65,121,0,0,0,0,0,0,42,11,0,0,0,0
.byte 0,0,0,0,3,25,8,0,0,0,0,8,145,134,46,0,0,0,6,145,42,0,0,0,0,0,111,92,24,28,0,0,0,7,217,209,160,150,161,0,0,21,130,50,56,149,92,0,0,1,107,124,57,8,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,17,49,3,0,0,0,14,157,182,189,79,0,0,0,14,53,2,127,124,0,0,0,0,0,6,201,57,0,0,0,0,0,101,183,3,0,0,0,0,10,222,58,0,0,0,0,0,4,79,1,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,58,141,111,0,0,0,0,2,53,47,176,0,0,0,0,10,167,207,80,0,0,0,14,0,0,40,131,0,0,0,92,65,0,120,98,0,0,0,3,142,174,130,3,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,38,99,137,145,20,0,0,0,41,114,221,152,5,0,0,0,0,152,227,31,0,0,0,0,0,0,96,97,0,0,5,110,4,0,101,63,0,0,3,118,166,167,180,15,0,0,0,0,10,34,9,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,68,188,194,44,0,0,0,0,104,45,88,146,0,0,0,0,0,15,184,89,0,0,0,0,127,193,89,0,0,0,0,0,206,138,199,162,16,0,0,0,171,100,22,112,62,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,2,42,106,142,109,4,0,0,166,179,113,105,219,11,0,0,20,3,72,202,58,0,0,0,10,121,159,28,0,0,0,16,186,137,64,115,0,0,0,131,246,208,146,29,0,0,0,13,34,7,0,0,0,0 

test_labels:  
.byte 8,0,5,4,6,7,3,3,2,2

squared_distances: .zero 512  # 128 * 4 bytes
neighbors: .zero 40           # 5 * 8 bytes
vote_counts: .zero 40         # 10 * 4 bytes
predicted_labels: .zero 10  # 10 bytes, one per test sample


.text
.globl _start

_start:
    # Initialize data
    jal x1, init_sample_data

    # Main classification routine
    li x5, 0                   # correct_count = 0
    li x6, 0                   # test_index = 0

test_loop:
    li x7, NUM_TEST
    bge x6, x7, end_test_loop
    
    # Initialize distance calculation
    li x8, 0                   # train_idx = 0

dist_loop:
    li x7, TRAIN_SIZE
    bge x8, x7, end_dist_loop
    
    li x9, 0                   # pixel_offset = 0
    li x10, 0                  # sq_dist = 0

pixel_loop:
    li x7, IMAGE_PIXELS
    bge x9, x7, end_pixel_loop
    
    # Calculate addresses
    slli x11, x8, 6            # train_offset = train_idx * 64
    add x11, x11, x9           # + pixel_offset
    la x12, train_images
    add x12, x12, x11
    lbu x12, 0(x12)            # train_byte (unsigned)
    
    slli x13, x6, 6            # test_offset = test_index * 64
    add x13, x13, x9           # + pixel_offset
    la x14, test_images
    add x14, x14, x13
    lbu x14, 0(x14)            # test_byte (unsigned)
    
    sub x15, x12, x14          # diff = train_byte - test_byte
    mul x15, x15, x15          # diff_sq = diff * diff
    add x10, x10, x15          # sq_dist += diff_sq
    
    addi x9, x9, 1             # pixel_offset++
    j pixel_loop

end_pixel_loop:
    # Clamp distance
    li x7, DIST_CLAMP
    blt x10, x7, no_clamp
    mv x10, x7                 # sq_dist = DIST_CLAMP
    
no_clamp:
    # Store squared distance
    slli x11, x8, 2            # index*4
    la x12, squared_distances
    add x12, x12, x11
    sw x10, 0(x12)
    
    addi x8, x8, 1             # train_idx++
    j dist_loop

end_dist_loop:
    # Initialize neighbor list
    li x8, 0                   # i = 0
    li x9, DIST_CLAMP          # max distance
    
init_neighbors:
    li x7, K_NEIGHBORS
    bge x8, x7, end_init_neighbors
    slli x10, x8, 3            # index*8
    la x11, neighbors
    add x11, x11, x10
    sw x9, 0(x11)              # distance = DIST_CLAMP
    sw x0, 4(x11)              # label = 0
    addi x8, x8, 1
    j init_neighbors

end_init_neighbors:
    # Find nearest neighbors
    li x8, 0                   # train_idx = 0
    
scan_loop:
    li x7, TRAIN_SIZE
    bge x8, x7, end_scan_loop
    
    # Load current squared distance
    slli x9, x8, 2
    la x10, squared_distances
    add x10, x10, x9
    lw x10, 0(x10)             # current distance
    
    # Find position to insert
    li x11, 0                  # insert_pos = 0
    li x12, DIST_CLAMP         # max distance
    li x13, 0                  # found = 0
    
find_insert_pos:
    li x7, K_NEIGHBORS
    bge x11, x7, end_find_pos
    slli x14, x11, 3
    la x15, neighbors
    add x15, x15, x14
    lw x16, 0(x15)             # neighbor distance
    
    beq x16, x12, found_empty  # Found empty slot
    blt x10, x16, found_insert # Found better distance
    addi x11, x11, 1
    j find_insert_pos

found_empty:
    li x13, 1                  # found empty = true
    j end_find_pos

found_insert:
    li x13, 1                  # found insert position
    
end_find_pos:
    # Insert or skip
    beqz x13, skip_insert      # No empty slot and not better
    
    # Shift neighbors down
    li x14, K_NEIGHBORS
    addi x14, x14, -1          # last index
    
shift_loop:
    ble x14, x11, end_shift    # if index <= insert_pos, done
    slli x15, x14, 3           # current offset
    addi x16, x14, -1          # previous index
    slli x16, x16, 3           # previous offset
    
    la x17, neighbors
    add x18, x17, x16          # previous element
    add x19, x17, x15          # current element
    
    lw x20, 0(x18)             # load previous distance
    sw x20, 0(x19)             # store to current
    lw x20, 4(x18)             # load previous label
    sw x20, 4(x19)             # store to current
    
    addi x14, x14, -1          # move to previous
    j shift_loop

end_shift:
    # Insert new neighbor
    slli x14, x11, 3
    la x15, neighbors
    add x15, x15, x14
    sw x10, 0(x15)             # store distance
    
    la x16, train_labels
    add x16, x16, x8
    lbu x17, 0(x16)            # get label
    sw x17, 4(x15)             # store label

skip_insert:
    addi x8, x8, 1
    j scan_loop

end_scan_loop:
    # Zero vote counts
    li x8, 0
    
zero_votes:
    li x7, NUM_CLASSES
    bge x8, x7, end_zero_votes
    slli x9, x8, 2
    la x10, vote_counts
    add x10, x10, x9
    sw x0, 0(x10)
    addi x8, x8, 1
    j zero_votes

end_zero_votes:
    # Weighted voting
    li x8, 0                   # i = 0
    
vote_loop:
    li x7, K_NEIGHBORS
    bge x8, x7, end_vote_loop
    slli x9, x8, 3
    la x10, neighbors
    add x10, x10, x9
    lw x11, 0(x10)             # distance
    beqz x11, skip_vote        # skip if distance=0
    
    lw x12, 4(x10)             # label
    # Compute weight = INV_SCALE / distance
    li x13, INV_SCALE
    div x14, x13, x11          # weight
    
    # Add to vote count
    slli x15, x12, 2           # label*4
    la x16, vote_counts
    add x16, x16, x15
    lw x17, 0(x16)
    add x17, x17, x14
    sw x17, 0(x16)

skip_vote:
    addi x8, x8, 1
    j vote_loop

end_vote_loop:
    # Find max vote
    li x8, 0                   # max_index = 0
    la x9, vote_counts
    lw x10, 0(x9)              # max_vote = vote_counts[0]
    li x11, 1                  # i = 1
    
find_max_vote:
    li x7, NUM_CLASSES
    bge x11, x7, end_find_max
    slli x12, x11, 2
    la x13, vote_counts
    add x13, x13, x12
    lw x14, 0(x13)             # vote_counts[i]
    ble x14, x10, next_class
    mv x8, x11                 # max_index = i
    mv x10, x14                # max_vote = vote_counts[i]
    
next_class:
    addi x11, x11, 1
    j find_max_vote

end_find_max:
    # Check if correct
    la x12, test_labels
    add x12, x12, x6
    lbu x13, 0(x12)            # true label
    la x14, predicted_labels   # load predicted_labels address
    add x14, x14, x6           # offset by test index
    sb x8, 0(x14)              # store predicted label

    bne x8, x13, not_correct
    addi x5, x5, 1             # correct_count++

not_correct:
    addi x6, x6, 1             # test_index++
    j test_loop

end_test_loop:
    # Exit with correct count in x5
    li x17, 93                 # exit system call
    mv x10, x5                 # return correct_count
    ecall

# Data initialization function
init_sample_data:
    # Initialize training images with simple patterns
    la x20, train_images
    li x21, 0                  # counter
    li x22, TRAIN_SIZE         # total samples
    
init_train_loop:
    bge x21, x22, init_train_labels
    
    # Create simple pattern based on class
    li x23, 10
    rem x24, x21, x23          # class = sample_idx % 10
    slli x25, x21, 6           # offset = sample_idx * 64
    add x26, x20, x25          # address
    
    li x27, 0                  # pixel counter
    
init_pixel_loop:
    li x28, IMAGE_PIXELS
    bge x27, x28, next_train_sample
    
    # Simple pattern: class value + some variation
    add x29, x24, x27
    li x30, 256
    rem x29, x29, x30          # keep in byte range
    add x31, x26, x27
    sb x29, 0(x31)
    
    addi x27, x27, 1
    j init_pixel_loop
    
next_train_sample:
    addi x21, x21, 1
    j init_train_loop

init_train_labels:
    # Initialize training labels
    la x20, train_labels
    li x21, 0
    li x22, TRAIN_SIZE
    
init_label_loop:
    bge x21, x22, init_test_images
    li x23, 10
    rem x24, x21, x23          # label = sample_idx % 10
    add x25, x20, x21
    sb x24, 0(x25)
    addi x21, x21, 1
    j init_label_loop

init_test_images:
    # Initialize test images
    la x20, test_images
    li x21, 0
    li x22, NUM_TEST
    
init_test_loop:
    bge x21, x22, init_test_labels
    
    li x23, 10
    rem x24, x21, x23          # class
    slli x25, x21, 6           # offset
    add x26, x20, x25          # address
    
    li x27, 0                  # pixel counter
    
init_test_pixel_loop:
    li x28, IMAGE_PIXELS
    bge x27, x28, next_test_sample
    
    # Similar pattern to training but with small difference
    add x29, x24, x27
    addi x29, x29, 1           # small variation
    li x30, 256
    rem x29, x29, x30
    add x31, x26, x27
    sb x29, 0(x31)
    
    addi x27, x27, 1
    j init_test_pixel_loop
    
next_test_sample:
    addi x21, x21, 1
    j init_test_loop

init_test_labels:
    # Initialize test labels
    la x20, test_labels
    li x21, 0
    li x22, NUM_TEST
    
init_test_label_loop:
    bge x21, x22, init_done
    li x23, 10
    rem x24, x21, x23
    add x25, x20, x21
    sb x24, 0(x25)
    addi x21, x21, 1
    j init_test_label_loop

init_done:
    ret
