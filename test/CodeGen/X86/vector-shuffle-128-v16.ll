; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mcpu=x86-64 -x86-experimental-vector-shuffle-lowering | FileCheck %s --check-prefix=ALL --check-prefix=SSE --check-prefix=SSE2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mcpu=x86-64 -mattr=+ssse3 -x86-experimental-vector-shuffle-lowering | FileCheck %s --check-prefix=ALL --check-prefix=SSE --check-prefix=SSSE3
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mcpu=x86-64 -mattr=+sse4.1 -x86-experimental-vector-shuffle-lowering | FileCheck %s --check-prefix=ALL --check-prefix=SSE --check-prefix=SSE41
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mcpu=x86-64 -mattr=+avx -x86-experimental-vector-shuffle-lowering | FileCheck %s --check-prefix=ALL --check-prefix=AVX --check-prefix=AVX1
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mcpu=x86-64 -mattr=+avx2 -x86-experimental-vector-shuffle-lowering | FileCheck %s --check-prefix=ALL --check-prefix=AVX --check-prefix=AVX2

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-unknown"

define <16 x i8> @shuffle_v16i8_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00(<16 x i8> %a, <16 x i8> %b) {
; FIXME: SSE2 should look like the following:
; FIXME-LABEL: @shuffle_v16i8_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00
; FIXME:       # BB#0:
; FIXME-NEXT:    punpcklbw %xmm0, %xmm0
; FIXME-NEXT:    pshuflw {{.*}} # xmm0 = xmm0[0,0,0,0,4,5,6,7]
; FIXME-NEXT:    pshufd {{.*}} # xmm0 = xmm0[0,1,0,1]
; FIXME-NEXT:    retq
;
; SSE2-LABEL: shuffle_v16i8_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00:
; SSE2:       # BB#0:
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,1,0,3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[0,0,0,0,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm0 = xmm0[0,1,2,3,4,4,4,4]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuffle_v16i8_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    pxor %xmm1, %xmm1
; SSSE3-NEXT:    pshufb %xmm1, %xmm0
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuffle_v16i8_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00:
; SSE41:       # BB#0:
; SSE41-NEXT:    pxor %xmm1, %xmm1
; SSE41-NEXT:    pshufb %xmm1, %xmm0
; SSE41-NEXT:    retq
;
; AVX1-LABEL: shuffle_v16i8_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00:
; AVX1:       # BB#0:
; AVX1-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX1-NEXT:    vpshufb %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: shuffle_v16i8_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpbroadcastb %xmm0, %xmm0
; AVX2-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_00_00_00_00_00_00_00_00_01_01_01_01_01_01_01_01(<16 x i8> %a, <16 x i8> %b) {
; SSE2-LABEL: shuffle_v16i8_00_00_00_00_00_00_00_00_01_01_01_01_01_01_01_01:
; SSE2:       # BB#0:
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,1,0,3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[0,0,0,0,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm0 = xmm0[0,1,2,3,5,5,5,5]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuffle_v16i8_00_00_00_00_00_00_00_00_01_01_01_01_01_01_01_01:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuffle_v16i8_00_00_00_00_00_00_00_00_01_01_01_01_01_01_01_01:
; SSE41:       # BB#0:
; SSE41-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1]
; SSE41-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_00_00_00_00_00_00_00_00_01_01_01_01_01_01_01_01:
; AVX:       # BB#0:
; AVX-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1]
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_00_00_00_00_00_00_00_00_08_08_08_08_08_08_08_08(<16 x i8> %a, <16 x i8> %b) {
; SSE2-LABEL: shuffle_v16i8_00_00_00_00_00_00_00_00_08_08_08_08_08_08_08_08:
; SSE2:       # BB#0:
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,2,2,3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[0,2,2,2,4,5,6,7]
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[0,0,0,0,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm0 = xmm0[0,1,2,3,6,6,6,6]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuffle_v16i8_00_00_00_00_00_00_00_00_08_08_08_08_08_08_08_08:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0,0,0,0,0,0,0,0,8,8,8,8,8,8,8,8]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuffle_v16i8_00_00_00_00_00_00_00_00_08_08_08_08_08_08_08_08:
; SSE41:       # BB#0:
; SSE41-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0,0,0,0,0,0,0,0,8,8,8,8,8,8,8,8]
; SSE41-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_00_00_00_00_00_00_00_00_08_08_08_08_08_08_08_08:
; AVX:       # BB#0:
; AVX-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0,0,0,0,0,0,0,0,8,8,8,8,8,8,8,8]
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 8, i32 8, i32 8, i32 8, i32 8, i32 8, i32 8, i32 8>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_00_00_00_00_01_01_01_01_02_02_02_02_03_03_03_03(<16 x i8> %a, <16 x i8> %b) {
; SSE-LABEL: shuffle_v16i8_00_00_00_00_01_01_01_01_02_02_02_02_03_03_03_03:
; SSE:       # BB#0:
; SSE-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; SSE-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3]
; SSE-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_00_00_00_00_01_01_01_01_02_02_02_02_03_03_03_03:
; AVX:       # BB#0:
; AVX-NEXT:    vpunpcklbw {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; AVX-NEXT:    vpunpcklwd {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3]
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 0, i32 0, i32 0, i32 0, i32 1, i32 1, i32 1, i32 1, i32 2, i32 2, i32 2, i32 2, i32 3, i32 3, i32 3, i32 3>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_04_04_04_04_05_05_05_05_06_06_06_06_07_07_07_07(<16 x i8> %a, <16 x i8> %b) {
; SSE-LABEL: shuffle_v16i8_04_04_04_04_05_05_05_05_06_06_06_06_07_07_07_07:
; SSE:       # BB#0:
; SSE-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; SSE-NEXT:    punpckhwd {{.*#+}} xmm0 = xmm0[4,4,5,5,6,6,7,7]
; SSE-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_04_04_04_04_05_05_05_05_06_06_06_06_07_07_07_07:
; AVX:       # BB#0:
; AVX-NEXT:    vpunpcklbw {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; AVX-NEXT:    vpunpckhwd {{.*#+}} xmm0 = xmm0[4,4,5,5,6,6,7,7]
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 4, i32 4, i32 4, i32 4, i32 5, i32 5, i32 5, i32 5, i32 6, i32 6, i32 6, i32 6, i32 7, i32 7, i32 7, i32 7>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_00_00_00_00_04_04_04_04_08_08_08_08_12_12_12_12(<16 x i8> %a, <16 x i8> %b) {
; SSE2-LABEL: shuffle_v16i8_00_00_00_00_04_04_04_04_08_08_08_08_12_12_12_12:
; SSE2:       # BB#0:
; SSE2-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[0,2,2,3,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm0 = xmm0[0,1,2,3,4,6,6,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,2,2,3]
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[0,0,2,2,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm0 = xmm0[0,1,2,3,4,4,6,6]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuffle_v16i8_00_00_00_00_04_04_04_04_08_08_08_08_12_12_12_12:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0,0,0,0,4,4,4,4,8,8,8,8,12,12,12,12]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuffle_v16i8_00_00_00_00_04_04_04_04_08_08_08_08_12_12_12_12:
; SSE41:       # BB#0:
; SSE41-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0,0,0,0,4,4,4,4,8,8,8,8,12,12,12,12]
; SSE41-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_00_00_00_00_04_04_04_04_08_08_08_08_12_12_12_12:
; AVX:       # BB#0:
; AVX-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0,0,0,0,4,4,4,4,8,8,8,8,12,12,12,12]
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 0, i32 0, i32 0, i32 0, i32 4, i32 4, i32 4, i32 4, i32 8, i32 8, i32 8, i32 8, i32 12, i32 12, i32 12, i32 12>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_00_00_01_01_02_02_03_03_04_04_05_05_06_06_07_07(<16 x i8> %a, <16 x i8> %b) {
; SSE-LABEL: shuffle_v16i8_00_00_01_01_02_02_03_03_04_04_05_05_06_06_07_07:
; SSE:       # BB#0:
; SSE-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; SSE-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_00_00_01_01_02_02_03_03_04_04_05_05_06_06_07_07:
; AVX:       # BB#0:
; AVX-NEXT:    vpunpcklbw {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 0, i32 0, i32 1, i32 1, i32 2, i32 2, i32 3, i32 3, i32 4, i32 4, i32 5, i32 5, i32 6, i32 6, i32 7, i32 7>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_0101010101010101(<16 x i8> %a, <16 x i8> %b) {
; FIXME: SSE2 should be the following:
; FIXME-LABEL: @shuffle_v16i8_0101010101010101
; FIXME:       # BB#0:
; FIXME-NEXT:    pshuflw {{.*}} # xmm0 = xmm0[0,0,0,0,4,5,6,7]
; FIXME-NEXT:    pshufd {{.*}} # xmm0 = xmm0[0,1,0,1]
; FIXME-NEXT:    retq
;
; SSE2-LABEL: shuffle_v16i8_0101010101010101:
; SSE2:       # BB#0:
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,1,0,3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[0,0,0,0,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm0 = xmm0[0,1,2,3,4,4,4,4]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuffle_v16i8_0101010101010101:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuffle_v16i8_0101010101010101:
; SSE41:       # BB#0:
; SSE41-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1]
; SSE41-NEXT:    retq
;
; AVX1-LABEL: shuffle_v16i8_0101010101010101:
; AVX1:       # BB#0:
; AVX1-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1]
; AVX1-NEXT:    retq
;
; AVX2-LABEL: shuffle_v16i8_0101010101010101:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpbroadcastw %xmm0, %xmm0
; AVX2-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 0, i32 1, i32 0, i32 1, i32 0, i32 1, i32 0, i32 1, i32 0, i32 1, i32 0, i32 1, i32 0, i32 1, i32 0, i32 1>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_00_16_01_17_02_18_03_19_04_20_05_21_06_22_07_23(<16 x i8> %a, <16 x i8> %b) {
; SSE-LABEL: shuffle_v16i8_00_16_01_17_02_18_03_19_04_20_05_21_06_22_07_23:
; SSE:       # BB#0:
; SSE-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3],xmm0[4],xmm1[4],xmm0[5],xmm1[5],xmm0[6],xmm1[6],xmm0[7],xmm1[7]
; SSE-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_00_16_01_17_02_18_03_19_04_20_05_21_06_22_07_23:
; AVX:       # BB#0:
; AVX-NEXT:    vpunpcklbw {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3],xmm0[4],xmm1[4],xmm0[5],xmm1[5],xmm0[6],xmm1[6],xmm0[7],xmm1[7]
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 0, i32 16, i32 1, i32 17, i32 2, i32 18, i32 3, i32 19, i32 4, i32 20, i32 5, i32 21, i32 6, i32 22, i32 7, i32 23>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_08_24_09_25_10_26_11_27_12_28_13_29_14_30_15_31(<16 x i8> %a, <16 x i8> %b) {
; SSE-LABEL: shuffle_v16i8_08_24_09_25_10_26_11_27_12_28_13_29_14_30_15_31:
; SSE:       # BB#0:
; SSE-NEXT:    punpckhbw {{.*#+}} xmm0 = xmm0[8],xmm1[8],xmm0[9],xmm1[9],xmm0[10],xmm1[10],xmm0[11],xmm1[11],xmm0[12],xmm1[12],xmm0[13],xmm1[13],xmm0[14],xmm1[14],xmm0[15],xmm1[15]
; SSE-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_08_24_09_25_10_26_11_27_12_28_13_29_14_30_15_31:
; AVX:       # BB#0:
; AVX-NEXT:    vpunpckhbw {{.*#+}} xmm0 = xmm0[8],xmm1[8],xmm0[9],xmm1[9],xmm0[10],xmm1[10],xmm0[11],xmm1[11],xmm0[12],xmm1[12],xmm0[13],xmm1[13],xmm0[14],xmm1[14],xmm0[15],xmm1[15]
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 8, i32 24, i32 9, i32 25, i32 10, i32 26, i32 11, i32 27, i32 12, i32 28, i32 13, i32 29, i32 14, i32 30, i32 15, i32 31>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_16_00_16_01_16_02_16_03_16_04_16_05_16_06_16_07(<16 x i8> %a, <16 x i8> %b) {
; SSE-LABEL: shuffle_v16i8_16_00_16_01_16_02_16_03_16_04_16_05_16_06_16_07:
; SSE:       # BB#0:
; SSE-NEXT:    punpcklbw {{.*#+}} xmm1 = xmm1[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; SSE-NEXT:    pshuflw {{.*#+}} xmm1 = xmm1[0,0,0,0,4,5,6,7]
; SSE-NEXT:    punpcklbw {{.*#+}} xmm1 = xmm1[0],xmm0[0],xmm1[1],xmm0[1],xmm1[2],xmm0[2],xmm1[3],xmm0[3],xmm1[4],xmm0[4],xmm1[5],xmm0[5],xmm1[6],xmm0[6],xmm1[7],xmm0[7]
; SSE-NEXT:    movdqa %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX1-LABEL: shuffle_v16i8_16_00_16_01_16_02_16_03_16_04_16_05_16_06_16_07:
; AVX1:       # BB#0:
; AVX1-NEXT:    vpunpcklbw {{.*#+}} xmm1 = xmm1[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; AVX1-NEXT:    vpshuflw {{.*#+}} xmm1 = xmm1[0,0,0,0,4,5,6,7]
; AVX1-NEXT:    vpunpcklbw {{.*#+}} xmm0 = xmm1[0],xmm0[0],xmm1[1],xmm0[1],xmm1[2],xmm0[2],xmm1[3],xmm0[3],xmm1[4],xmm0[4],xmm1[5],xmm0[5],xmm1[6],xmm0[6],xmm1[7],xmm0[7]
; AVX1-NEXT:    retq
;
; AVX2-LABEL: shuffle_v16i8_16_00_16_01_16_02_16_03_16_04_16_05_16_06_16_07:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpbroadcastb %xmm1, %xmm1
; AVX2-NEXT:    vpunpcklbw {{.*#+}} xmm0 = xmm1[0],xmm0[0],xmm1[1],xmm0[1],xmm1[2],xmm0[2],xmm1[3],xmm0[3],xmm1[4],xmm0[4],xmm1[5],xmm0[5],xmm1[6],xmm0[6],xmm1[7],xmm0[7]
; AVX2-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 16, i32 0, i32 16, i32 1, i32 16, i32 2, i32 16, i32 3, i32 16, i32 4, i32 16, i32 5, i32 16, i32 6, i32 16, i32 7>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_03_02_01_00_07_06_05_04_11_10_09_08_15_14_13_12(<16 x i8> %a, <16 x i8> %b) {
; SSE2-LABEL: shuffle_v16i8_03_02_01_00_07_06_05_04_11_10_09_08_15_14_13_12:
; SSE2:       # BB#0:
; SSE2-NEXT:    pxor %xmm1, %xmm1
; SSE2-NEXT:    movdqa %xmm0, %xmm2
; SSE2-NEXT:    punpckhbw {{.*#+}} xmm2 = xmm2[8],xmm1[8],xmm2[9],xmm1[9],xmm2[10],xmm1[10],xmm2[11],xmm1[11],xmm2[12],xmm1[12],xmm2[13],xmm1[13],xmm2[14],xmm1[14],xmm2[15],xmm1[15]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm2 = xmm2[3,2,1,0,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm2 = xmm2[0,1,2,3,7,6,5,4]
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3],xmm0[4],xmm1[4],xmm0[5],xmm1[5],xmm0[6],xmm1[6],xmm0[7],xmm1[7]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[3,2,1,0,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm0 = xmm0[0,1,2,3,7,6,5,4]
; SSE2-NEXT:    packuswb %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuffle_v16i8_03_02_01_00_07_06_05_04_11_10_09_08_15_14_13_12:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[3,2,1,0,7,6,5,4,11,10,9,8,15,14,13,12]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuffle_v16i8_03_02_01_00_07_06_05_04_11_10_09_08_15_14_13_12:
; SSE41:       # BB#0:
; SSE41-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[3,2,1,0,7,6,5,4,11,10,9,8,15,14,13,12]
; SSE41-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_03_02_01_00_07_06_05_04_11_10_09_08_15_14_13_12:
; AVX:       # BB#0:
; AVX-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[3,2,1,0,7,6,5,4,11,10,9,8,15,14,13,12]
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 3, i32 2, i32 1, i32 0, i32 7, i32 6, i32 5, i32 4, i32 11, i32 10, i32 9, i32 8, i32 15, i32 14, i32 13, i32 12>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_03_02_01_00_07_06_05_04_19_18_17_16_23_22_21_20(<16 x i8> %a, <16 x i8> %b) {
; SSE2-LABEL: shuffle_v16i8_03_02_01_00_07_06_05_04_19_18_17_16_23_22_21_20:
; SSE2:       # BB#0:
; SSE2-NEXT:    pxor %xmm2, %xmm2
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1],xmm1[2],xmm2[2],xmm1[3],xmm2[3],xmm1[4],xmm2[4],xmm1[5],xmm2[5],xmm1[6],xmm2[6],xmm1[7],xmm2[7]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm1 = xmm1[3,2,1,0,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm1 = xmm1[0,1,2,3,7,6,5,4]
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1],xmm0[2],xmm2[2],xmm0[3],xmm2[3],xmm0[4],xmm2[4],xmm0[5],xmm2[5],xmm0[6],xmm2[6],xmm0[7],xmm2[7]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[3,2,1,0,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm0 = xmm0[0,1,2,3,7,6,5,4]
; SSE2-NEXT:    packuswb %xmm1, %xmm0
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuffle_v16i8_03_02_01_00_07_06_05_04_19_18_17_16_23_22_21_20:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    pshufb {{.*#+}} xmm1 = zero,zero,zero,zero,zero,zero,zero,zero,xmm1[3,2,1,0,7,6,5,4]
; SSSE3-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[3,2,1,0,7,6,5,4],zero,zero,zero,zero,zero,zero,zero,zero
; SSSE3-NEXT:    por %xmm1, %xmm0
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuffle_v16i8_03_02_01_00_07_06_05_04_19_18_17_16_23_22_21_20:
; SSE41:       # BB#0:
; SSE41-NEXT:    pshufb {{.*#+}} xmm1 = zero,zero,zero,zero,zero,zero,zero,zero,xmm1[3,2,1,0,7,6,5,4]
; SSE41-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[3,2,1,0,7,6,5,4],zero,zero,zero,zero,zero,zero,zero,zero
; SSE41-NEXT:    por %xmm1, %xmm0
; SSE41-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_03_02_01_00_07_06_05_04_19_18_17_16_23_22_21_20:
; AVX:       # BB#0:
; AVX-NEXT:    vpshufb {{.*#+}} xmm1 = zero,zero,zero,zero,zero,zero,zero,zero,xmm1[3,2,1,0,7,6,5,4]
; AVX-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[3,2,1,0,7,6,5,4],zero,zero,zero,zero,zero,zero,zero,zero
; AVX-NEXT:    vpor %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 3, i32 2, i32 1, i32 0, i32 7, i32 6, i32 5, i32 4, i32 19, i32 18, i32 17, i32 16, i32 23, i32 22, i32 21, i32 20>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_03_02_01_00_31_30_29_28_11_10_09_08_23_22_21_20(<16 x i8> %a, <16 x i8> %b) {
; SSE2-LABEL: shuffle_v16i8_03_02_01_00_31_30_29_28_11_10_09_08_23_22_21_20:
; SSE2:       # BB#0:
; SSE2-NEXT:    pxor %xmm2, %xmm2
; SSE2-NEXT:    movdqa %xmm1, %xmm3
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm3 = xmm3[0],xmm2[0],xmm3[1],xmm2[1],xmm3[2],xmm2[2],xmm3[3],xmm2[3],xmm3[4],xmm2[4],xmm3[5],xmm2[5],xmm3[6],xmm2[6],xmm3[7],xmm2[7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm3 = xmm3[0,1,2,3,7,6,5,4]
; SSE2-NEXT:    movdqa %xmm0, %xmm4
; SSE2-NEXT:    punpckhbw {{.*#+}} xmm4 = xmm4[8],xmm2[8],xmm4[9],xmm2[9],xmm4[10],xmm2[10],xmm4[11],xmm2[11],xmm4[12],xmm2[12],xmm4[13],xmm2[13],xmm4[14],xmm2[14],xmm4[15],xmm2[15]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm4 = xmm4[3,2,1,0,4,5,6,7]
; SSE2-NEXT:    movsd %xmm4, %xmm3
; SSE2-NEXT:    punpckhbw {{.*#+}} xmm1 = xmm1[8],xmm2[8],xmm1[9],xmm2[9],xmm1[10],xmm2[10],xmm1[11],xmm2[11],xmm1[12],xmm2[12],xmm1[13],xmm2[13],xmm1[14],xmm2[14],xmm1[15],xmm2[15]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm1 = xmm1[0,1,2,3,7,6,5,4]
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1],xmm0[2],xmm2[2],xmm0[3],xmm2[3],xmm0[4],xmm2[4],xmm0[5],xmm2[5],xmm0[6],xmm2[6],xmm0[7],xmm2[7]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[3,2,1,0,4,5,6,7]
; SSE2-NEXT:    movsd %xmm0, %xmm1
; SSE2-NEXT:    packuswb %xmm3, %xmm1
; SSE2-NEXT:    movdqa %xmm1, %xmm0
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuffle_v16i8_03_02_01_00_31_30_29_28_11_10_09_08_23_22_21_20:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    pshufb {{.*#+}} xmm1 = zero,zero,zero,zero,xmm1[15,14,13,12],zero,zero,zero,zero,xmm1[7,6,5,4]
; SSSE3-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[3,2,1,0],zero,zero,zero,zero,xmm0[11,10,9,8],zero,zero,zero,zero
; SSSE3-NEXT:    por %xmm1, %xmm0
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuffle_v16i8_03_02_01_00_31_30_29_28_11_10_09_08_23_22_21_20:
; SSE41:       # BB#0:
; SSE41-NEXT:    pshufb {{.*#+}} xmm1 = zero,zero,zero,zero,xmm1[15,14,13,12],zero,zero,zero,zero,xmm1[7,6,5,4]
; SSE41-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[3,2,1,0],zero,zero,zero,zero,xmm0[11,10,9,8],zero,zero,zero,zero
; SSE41-NEXT:    por %xmm1, %xmm0
; SSE41-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_03_02_01_00_31_30_29_28_11_10_09_08_23_22_21_20:
; AVX:       # BB#0:
; AVX-NEXT:    vpshufb {{.*#+}} xmm1 = zero,zero,zero,zero,xmm1[15,14,13,12],zero,zero,zero,zero,xmm1[7,6,5,4]
; AVX-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[3,2,1,0],zero,zero,zero,zero,xmm0[11,10,9,8],zero,zero,zero,zero
; AVX-NEXT:    vpor %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 3, i32 2, i32 1, i32 0, i32 31, i32 30, i32 29, i32 28, i32 11, i32 10, i32 9, i32 8, i32 23, i32 22, i32 21, i32 20>
  ret <16 x i8> %shuffle
}

define <16 x i8> @trunc_v4i32_shuffle(<16 x i8> %a) {
; SSE2-LABEL: trunc_v4i32_shuffle:
; SSE2:       # BB#0:
; SSE2-NEXT:    pand {{.*}}(%rip), %xmm0
; SSE2-NEXT:    packuswb %xmm0, %xmm0
; SSE2-NEXT:    packuswb %xmm0, %xmm0
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: trunc_v4i32_shuffle:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0,4,8,12,u,u,u,u,u,u,u,u,u,u,u,u]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: trunc_v4i32_shuffle:
; SSE41:       # BB#0:
; SSE41-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0,4,8,12,u,u,u,u,u,u,u,u,u,u,u,u]
; SSE41-NEXT:    retq
;
; AVX-LABEL: trunc_v4i32_shuffle:
; AVX:       # BB#0:
; AVX-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0,4,8,12,u,u,u,u,u,u,u,u,u,u,u,u]
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> undef, <16 x i32> <i32 0, i32 4, i32 8, i32 12, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  ret <16 x i8> %shuffle
}

define <16 x i8> @stress_test0(<16 x i8> %s.0.1, <16 x i8> %s.0.2, <16 x i8> %s.0.3, <16 x i8> %s.0.4, <16 x i8> %s.0.5, <16 x i8> %s.0.6, <16 x i8> %s.0.7, <16 x i8> %s.0.8, <16 x i8> %s.0.9) {
; We don't have anything useful to check here. This generates 100s of
; instructions. Instead, just make sure we survived codegen.
; ALL-LABEL: stress_test0:
; ALL:         retq
entry:
  %s.1.4 = shufflevector <16 x i8> %s.0.4, <16 x i8> %s.0.5, <16 x i32> <i32 1, i32 22, i32 21, i32 28, i32 3, i32 16, i32 6, i32 1, i32 19, i32 29, i32 12, i32 31, i32 2, i32 3, i32 3, i32 6>
  %s.1.5 = shufflevector <16 x i8> %s.0.5, <16 x i8> %s.0.6, <16 x i32> <i32 31, i32 20, i32 12, i32 19, i32 2, i32 15, i32 12, i32 31, i32 2, i32 28, i32 2, i32 30, i32 7, i32 8, i32 17, i32 28>
  %s.1.8 = shufflevector <16 x i8> %s.0.8, <16 x i8> %s.0.9, <16 x i32> <i32 14, i32 10, i32 17, i32 5, i32 17, i32 9, i32 17, i32 21, i32 31, i32 24, i32 16, i32 6, i32 20, i32 28, i32 23, i32 8>
  %s.2.2 = shufflevector <16 x i8> %s.0.3, <16 x i8> %s.0.4, <16 x i32> <i32 20, i32 9, i32 21, i32 11, i32 11, i32 4, i32 3, i32 18, i32 3, i32 30, i32 4, i32 31, i32 11, i32 24, i32 13, i32 29>
  %s.3.2 = shufflevector <16 x i8> %s.2.2, <16 x i8> %s.1.4, <16 x i32> <i32 15, i32 13, i32 5, i32 11, i32 7, i32 17, i32 14, i32 22, i32 22, i32 16, i32 7, i32 24, i32 16, i32 22, i32 7, i32 29>
  %s.5.4 = shufflevector <16 x i8> %s.1.5, <16 x i8> %s.1.8, <16 x i32> <i32 3, i32 13, i32 19, i32 7, i32 23, i32 11, i32 1, i32 9, i32 16, i32 25, i32 2, i32 7, i32 0, i32 21, i32 23, i32 17>
  %s.6.1 = shufflevector <16 x i8> %s.3.2, <16 x i8> %s.3.2, <16 x i32> <i32 11, i32 2, i32 28, i32 31, i32 27, i32 3, i32 9, i32 27, i32 25, i32 25, i32 14, i32 7, i32 12, i32 28, i32 12, i32 23>
  %s.7.1 = shufflevector <16 x i8> %s.6.1, <16 x i8> %s.3.2, <16 x i32> <i32 15, i32 29, i32 14, i32 0, i32 29, i32 15, i32 26, i32 30, i32 6, i32 7, i32 2, i32 8, i32 12, i32 10, i32 29, i32 17>
  %s.7.2 = shufflevector <16 x i8> %s.3.2, <16 x i8> %s.5.4, <16 x i32> <i32 3, i32 29, i32 3, i32 19, i32 undef, i32 20, i32 undef, i32 3, i32 27, i32 undef, i32 undef, i32 11, i32 undef, i32 undef, i32 undef, i32 undef>
  %s.16.0 = shufflevector <16 x i8> %s.7.1, <16 x i8> %s.7.2, <16 x i32> <i32 13, i32 1, i32 16, i32 16, i32 6, i32 7, i32 29, i32 18, i32 19, i32 28, i32 undef, i32 undef, i32 31, i32 1, i32 undef, i32 10>
  ret <16 x i8> %s.16.0
}

define <16 x i8> @stress_test1(<16 x i8> %s.0.5, <16 x i8> %s.0.8, <16 x i8> %s.0.9) noinline nounwind {
; There is nothing interesting to check about these instructions other than
; that they survive codegen. However, we actually do better and delete all of
; them because the result is 'undef'.
;
; ALL-LABEL: stress_test1:
; ALL:       # BB#0: # %entry
; ALL-NEXT:    retq
entry:
  %s.1.8 = shufflevector <16 x i8> %s.0.8, <16 x i8> undef, <16 x i32> <i32 9, i32 9, i32 undef, i32 undef, i32 undef, i32 2, i32 undef, i32 6, i32 undef, i32 6, i32 undef, i32 14, i32 14, i32 undef, i32 undef, i32 0>
  %s.2.4 = shufflevector <16 x i8> undef, <16 x i8> %s.0.5, <16 x i32> <i32 21, i32 undef, i32 undef, i32 19, i32 undef, i32 undef, i32 29, i32 24, i32 21, i32 23, i32 21, i32 17, i32 19, i32 undef, i32 20, i32 22>
  %s.2.5 = shufflevector <16 x i8> %s.0.5, <16 x i8> undef, <16 x i32> <i32 3, i32 8, i32 undef, i32 7, i32 undef, i32 10, i32 8, i32 0, i32 15, i32 undef, i32 1, i32 undef, i32 undef, i32 undef, i32 undef, i32 9>
  %s.2.9 = shufflevector <16 x i8> %s.0.9, <16 x i8> undef, <16 x i32> <i32 7, i32 undef, i32 14, i32 7, i32 8, i32 undef, i32 7, i32 8, i32 5, i32 15, i32 undef, i32 1, i32 11, i32 undef, i32 undef, i32 11>
  %s.3.4 = shufflevector <16 x i8> %s.2.4, <16 x i8> %s.0.5, <16 x i32> <i32 5, i32 0, i32 21, i32 6, i32 15, i32 27, i32 22, i32 21, i32 4, i32 22, i32 19, i32 26, i32 9, i32 26, i32 8, i32 29>
  %s.3.9 = shufflevector <16 x i8> %s.2.9, <16 x i8> undef, <16 x i32> <i32 8, i32 6, i32 8, i32 1, i32 undef, i32 4, i32 undef, i32 2, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 6, i32 undef>
  %s.4.7 = shufflevector <16 x i8> %s.1.8, <16 x i8> %s.2.9, <16 x i32> <i32 9, i32 0, i32 22, i32 20, i32 24, i32 7, i32 21, i32 17, i32 20, i32 12, i32 19, i32 23, i32 2, i32 9, i32 17, i32 10>
  %s.4.8 = shufflevector <16 x i8> %s.2.9, <16 x i8> %s.3.9, <16 x i32> <i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 6, i32 10, i32 undef, i32 0, i32 5, i32 undef, i32 9, i32 undef>
  %s.5.7 = shufflevector <16 x i8> %s.4.7, <16 x i8> %s.4.8, <16 x i32> <i32 16, i32 0, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %s.8.4 = shufflevector <16 x i8> %s.3.4, <16 x i8> %s.5.7, <16 x i32> <i32 undef, i32 undef, i32 undef, i32 28, i32 undef, i32 0, i32 undef, i32 undef, i32 undef, i32 undef, i32 1, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %s.9.4 = shufflevector <16 x i8> %s.8.4, <16 x i8> undef, <16 x i32> <i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 10, i32 5>
  %s.10.4 = shufflevector <16 x i8> %s.9.4, <16 x i8> undef, <16 x i32> <i32 undef, i32 7, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %s.12.4 = shufflevector <16 x i8> %s.10.4, <16 x i8> undef, <16 x i32> <i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 13, i32 undef, i32 undef, i32 undef>

  ret <16 x i8> %s.12.4
}

define <16 x i8> @PR20540(<8 x i8> %a) {
; SSE2-LABEL: PR20540:
; SSE2:       # BB#0:
; SSE2-NEXT:    pand {{.*}}(%rip), %xmm0
; SSE2-NEXT:    packuswb %xmm0, %xmm0
; SSE2-NEXT:    pxor %xmm1, %xmm1
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3],xmm0[4],xmm1[4],xmm0[5],xmm1[5],xmm0[6],xmm1[6],xmm0[7],xmm1[7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[0,1,0,3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm1 = xmm1[0,0,0,0,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm1 = xmm1[0,1,2,3,4,4,4,4]
; SSE2-NEXT:    packuswb %xmm1, %xmm0
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: PR20540:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    pxor %xmm1, %xmm1
; SSSE3-NEXT:    pshufb {{.*#+}} xmm1 = zero,zero,zero,zero,zero,zero,zero,zero,xmm1[0,0,0,0,0,0,0,0]
; SSSE3-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0,2,4,6,8,10,12,14],zero,zero,zero,zero,zero,zero,zero,zero
; SSSE3-NEXT:    por %xmm1, %xmm0
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: PR20540:
; SSE41:       # BB#0:
; SSE41-NEXT:    pxor %xmm1, %xmm1
; SSE41-NEXT:    pshufb {{.*#+}} xmm1 = zero,zero,zero,zero,zero,zero,zero,zero,xmm1[0,0,0,0,0,0,0,0]
; SSE41-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0,2,4,6,8,10,12,14],zero,zero,zero,zero,zero,zero,zero,zero
; SSE41-NEXT:    por %xmm1, %xmm0
; SSE41-NEXT:    retq
;
; AVX-LABEL: PR20540:
; AVX:       # BB#0:
; AVX-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX-NEXT:    vpshufb {{.*#+}} xmm1 = zero,zero,zero,zero,zero,zero,zero,zero,xmm1[0,0,0,0,0,0,0,0]
; AVX-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0,2,4,6,8,10,12,14],zero,zero,zero,zero,zero,zero,zero,zero
; AVX-NEXT:    vpor %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
  %shuffle = shufflevector <8 x i8> %a, <8 x i8> zeroinitializer, <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 8, i32 8, i32 8, i32 8, i32 8, i32 8, i32 8>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_16_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz(i8 %i) {
; SSE2-LABEL: shuffle_v16i8_16_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz:
; SSE2:       # BB#0:
; SSE2-NEXT:    movzbl %dil, %eax
; SSE2-NEXT:    movd %eax, %xmm0
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuffle_v16i8_16_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    movd %edi, %xmm0
; SSSE3-NEXT:    pxor %xmm1, %xmm1
; SSSE3-NEXT:    pshufb {{.*#+}} xmm1 = zero,xmm1[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
; SSSE3-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0],zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero
; SSSE3-NEXT:    por %xmm1, %xmm0
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuffle_v16i8_16_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz:
; SSE41:       # BB#0:
; SSE41-NEXT:    movd %edi, %xmm0
; SSE41-NEXT:    pxor %xmm1, %xmm1
; SSE41-NEXT:    pshufb {{.*#+}} xmm1 = zero,xmm1[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
; SSE41-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0],zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero
; SSE41-NEXT:    por %xmm1, %xmm0
; SSE41-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_16_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz:
; AVX:       # BB#0:
; AVX-NEXT:    vmovd %edi, %xmm0
; AVX-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX-NEXT:    vpshufb {{.*#+}} xmm1 = zero,xmm1[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
; AVX-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0],zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero
; AVX-NEXT:    vpor %xmm0, %xmm1, %xmm0
; AVX-NEXT:    retq
  %a = insertelement <16 x i8> undef, i8 %i, i32 0
  %shuffle = shufflevector <16 x i8> zeroinitializer, <16 x i8> %a, <16 x i32> <i32 16, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_zz_zz_zz_zz_zz_16_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz(i8 %i) {
; SSE2-LABEL: shuffle_v16i8_zz_zz_zz_zz_zz_16_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz:
; SSE2:       # BB#0:
; SSE2-NEXT:    movzbl %dil, %eax
; SSE2-NEXT:    movd %eax, %xmm0
; SSE2-NEXT:    pslldq {{.*#+}} xmm0 = zero,zero,zero,zero,zero,xmm0[0,1,2,3,4,5,6,7,8,9,10]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuffle_v16i8_zz_zz_zz_zz_zz_16_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    movd %edi, %xmm0
; SSSE3-NEXT:    pxor %xmm1, %xmm1
; SSSE3-NEXT:    pshufb {{.*#+}} xmm1 = xmm1[0,0,0,0,0],zero,xmm1[0,0,0,0,0,0,0,0,0,0]
; SSSE3-NEXT:    pshufb {{.*#+}} xmm0 = zero,zero,zero,zero,zero,xmm0[0],zero,zero,zero,zero,zero,zero,zero,zero,zero,zero
; SSSE3-NEXT:    por %xmm1, %xmm0
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuffle_v16i8_zz_zz_zz_zz_zz_16_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz:
; SSE41:       # BB#0:
; SSE41-NEXT:    movd %edi, %xmm0
; SSE41-NEXT:    pxor %xmm1, %xmm1
; SSE41-NEXT:    pshufb {{.*#+}} xmm1 = xmm1[0,0,0,0,0],zero,xmm1[0,0,0,0,0,0,0,0,0,0]
; SSE41-NEXT:    pshufb {{.*#+}} xmm0 = zero,zero,zero,zero,zero,xmm0[0],zero,zero,zero,zero,zero,zero,zero,zero,zero,zero
; SSE41-NEXT:    por %xmm1, %xmm0
; SSE41-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_zz_zz_zz_zz_zz_16_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz:
; AVX:       # BB#0:
; AVX-NEXT:    vmovd %edi, %xmm0
; AVX-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX-NEXT:    vpshufb {{.*#+}} xmm1 = xmm1[0,0,0,0,0],zero,xmm1[0,0,0,0,0,0,0,0,0,0]
; AVX-NEXT:    vpshufb {{.*#+}} xmm0 = zero,zero,zero,zero,zero,xmm0[0],zero,zero,zero,zero,zero,zero,zero,zero,zero,zero
; AVX-NEXT:    vpor %xmm0, %xmm1, %xmm0
; AVX-NEXT:    retq
  %a = insertelement <16 x i8> undef, i8 %i, i32 0
  %shuffle = shufflevector <16 x i8> zeroinitializer, <16 x i8> %a, <16 x i32> <i32 0, i32 0, i32 0, i32 0, i32 0, i32 16, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_zz_uu_uu_zz_uu_uu_zz_zz_zz_zz_zz_zz_zz_zz_zz_16(i8 %i) {
; SSE2-LABEL: shuffle_v16i8_zz_uu_uu_zz_uu_uu_zz_zz_zz_zz_zz_zz_zz_zz_zz_16:
; SSE2:       # BB#0:
; SSE2-NEXT:    movzbl %dil, %eax
; SSE2-NEXT:    movd %eax, %xmm0
; SSE2-NEXT:    pslldq {{.*#+}} xmm0 = zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,xmm0[0]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuffle_v16i8_zz_uu_uu_zz_uu_uu_zz_zz_zz_zz_zz_zz_zz_zz_zz_16:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    movd %edi, %xmm0
; SSSE3-NEXT:    pxor %xmm1, %xmm1
; SSSE3-NEXT:    pshufb {{.*#+}} xmm1 = xmm1[0,u,u,3,u,u,6,7,8,9,10,11,12,13,14],zero
; SSSE3-NEXT:    pshufb {{.*#+}} xmm0 = zero,xmm0[u,u],zero,xmm0[u,u],zero,zero,zero,zero,zero,zero,zero,zero,zero,xmm0[0]
; SSSE3-NEXT:    por %xmm1, %xmm0
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuffle_v16i8_zz_uu_uu_zz_uu_uu_zz_zz_zz_zz_zz_zz_zz_zz_zz_16:
; SSE41:       # BB#0:
; SSE41-NEXT:    movd %edi, %xmm0
; SSE41-NEXT:    pxor %xmm1, %xmm1
; SSE41-NEXT:    pshufb {{.*#+}} xmm1 = xmm1[0,u,u,3,u,u,6,7,8,9,10,11,12,13,14],zero
; SSE41-NEXT:    pshufb {{.*#+}} xmm0 = zero,xmm0[u,u],zero,xmm0[u,u],zero,zero,zero,zero,zero,zero,zero,zero,zero,xmm0[0]
; SSE41-NEXT:    por %xmm1, %xmm0
; SSE41-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_zz_uu_uu_zz_uu_uu_zz_zz_zz_zz_zz_zz_zz_zz_zz_16:
; AVX:       # BB#0:
; AVX-NEXT:    vmovd %edi, %xmm0
; AVX-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX-NEXT:    vpshufb {{.*#+}} xmm1 = xmm1[0,u,u,3,u,u,6,7,8,9,10,11,12,13,14],zero
; AVX-NEXT:    vpshufb {{.*#+}} xmm0 = zero,xmm0[u,u],zero,xmm0[u,u],zero,zero,zero,zero,zero,zero,zero,zero,zero,xmm0[0]
; AVX-NEXT:    vpor %xmm0, %xmm1, %xmm0
; AVX-NEXT:    retq
  %a = insertelement <16 x i8> undef, i8 %i, i32 0
  %shuffle = shufflevector <16 x i8> zeroinitializer, <16 x i8> %a, <16 x i32> <i32 0, i32 undef, i32 undef, i32 3, i32 undef, i32 undef, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 16>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_zz_zz_19_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz(i8 %i) {
; SSE2-LABEL: shuffle_v16i8_zz_zz_19_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz:
; SSE2:       # BB#0:
; SSE2-NEXT:    movzbl %dil, %eax
; SSE2-NEXT:    movd %eax, %xmm0
; SSE2-NEXT:    pslldq {{.*#+}} xmm0 = zero,zero,xmm0[0,1,2,3,4,5,6,7,8,9,10,11,12,13]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuffle_v16i8_zz_zz_19_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    movd %edi, %xmm0
; SSSE3-NEXT:    palignr {{.*#+}} xmm0 = xmm0[13,14,15,0,1,2,3,4,5,6,7,8,9,10,11,12]
; SSSE3-NEXT:    pxor %xmm1, %xmm1
; SSSE3-NEXT:    pshufb {{.*#+}} xmm1 = xmm1[0,1],zero,xmm1[3,4,5,6,7,8,9,10,11,12,13,14,15]
; SSSE3-NEXT:    pshufb {{.*#+}} xmm0 = zero,zero,xmm0[3],zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero
; SSSE3-NEXT:    por %xmm1, %xmm0
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuffle_v16i8_zz_zz_19_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz:
; SSE41:       # BB#0:
; SSE41-NEXT:    movd %edi, %xmm0
; SSE41-NEXT:    palignr {{.*#+}} xmm0 = xmm0[13,14,15,0,1,2,3,4,5,6,7,8,9,10,11,12]
; SSE41-NEXT:    pxor %xmm1, %xmm1
; SSE41-NEXT:    pshufb {{.*#+}} xmm1 = xmm1[0,1],zero,xmm1[3,4,5,6,7,8,9,10,11,12,13,14,15]
; SSE41-NEXT:    pshufb {{.*#+}} xmm0 = zero,zero,xmm0[3],zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero
; SSE41-NEXT:    por %xmm1, %xmm0
; SSE41-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_zz_zz_19_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz:
; AVX:       # BB#0:
; AVX-NEXT:    vmovd %edi, %xmm0
; AVX-NEXT:    vpalignr {{.*#+}} xmm0 = xmm0[13,14,15,0,1,2,3,4,5,6,7,8,9,10,11,12]
; AVX-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX-NEXT:    vpshufb {{.*#+}} xmm1 = xmm1[0,1],zero,xmm1[3,4,5,6,7,8,9,10,11,12,13,14,15]
; AVX-NEXT:    vpshufb {{.*#+}} xmm0 = zero,zero,xmm0[3],zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero
; AVX-NEXT:    vpor %xmm0, %xmm1, %xmm0
; AVX-NEXT:    retq
  %a = insertelement <16 x i8> undef, i8 %i, i32 3
  %shuffle = shufflevector <16 x i8> zeroinitializer, <16 x i8> %a, <16 x i32> <i32 0, i32 1, i32 19, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_31_00_01_02_03_04_05_06_07_08_09_10_11_12_13_14(<16 x i8> %a, <16 x i8> %b) {
; SSE2-LABEL: shuffle_v16i8_31_00_01_02_03_04_05_06_07_08_09_10_11_12_13_14:
; SSE2:       # BB#0:
; SSE2-NEXT:    pxor %xmm2, %xmm2
; SSE2-NEXT:    movdqa %xmm0, %xmm3
; SSE2-NEXT:    punpckhbw {{.*#+}} xmm3 = xmm3[8],xmm2[8],xmm3[9],xmm2[9],xmm3[10],xmm2[10],xmm3[11],xmm2[11],xmm3[12],xmm2[12],xmm3[13],xmm2[13],xmm3[14],xmm2[14],xmm3[15],xmm2[15]
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1],xmm0[2],xmm2[2],xmm0[3],xmm2[3],xmm0[4],xmm2[4],xmm0[5],xmm2[5],xmm0[6],xmm2[6],xmm0[7],xmm2[7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm4 = xmm0[2,3,0,1]
; SSE2-NEXT:    pshufd {{.*#+}} xmm5 = xmm3[3,1,2,0]
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm3 = xmm3[0],xmm4[0],xmm3[1],xmm4[1],xmm3[2],xmm4[2],xmm3[3],xmm4[3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm3 = xmm3[0,2,2,3,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm3 = xmm3[0,1,2,3,4,7,6,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm3 = xmm3[0,2,2,3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm3 = xmm3[3,0,1,2,4,5,6,7]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm4 = xmm5[0,3,2,3,4,5,6,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm4 = xmm4[0,2,2,3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm4 = xmm4[1,2,3,0,4,5,6,7]
; SSE2-NEXT:    punpcklqdq {{.*#+}} xmm3 = xmm3[0],xmm4[0]
; SSE2-NEXT:    punpckhbw {{.*#+}} xmm1 = xmm1[8],xmm2[8],xmm1[9],xmm2[9],xmm1[10],xmm2[10],xmm1[11],xmm2[11],xmm1[12],xmm2[12],xmm1[13],xmm2[13],xmm1[14],xmm2[14],xmm1[15],xmm2[15]
; SSE2-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[0,3,2,3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm1 = xmm1[3,1,2,3,4,5,6,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[3,1,2,0]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[0,3,2,3,4,5,6,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[3,1,2,0]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[0,0,1,2,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm0 = xmm0[0,1,2,3,7,4,5,6]
; SSE2-NEXT:    pshufd {{.*#+}} xmm2 = xmm0[2,3,0,1]
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[2,1,2,3,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm0 = xmm0[0,1,2,3,4,6,6,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,2,2,3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[1,0,2,3,4,5,6,7]
; SSE2-NEXT:    punpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm2[0]
; SSE2-NEXT:    packuswb %xmm3, %xmm0
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuffle_v16i8_31_00_01_02_03_04_05_06_07_08_09_10_11_12_13_14:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    palignr {{.*#+}} xmm0 = xmm1[15],xmm0[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuffle_v16i8_31_00_01_02_03_04_05_06_07_08_09_10_11_12_13_14:
; SSE41:       # BB#0:
; SSE41-NEXT:    palignr {{.*#+}} xmm0 = xmm1[15],xmm0[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14]
; SSE41-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_31_00_01_02_03_04_05_06_07_08_09_10_11_12_13_14:
; AVX:       # BB#0:
; AVX-NEXT:    vpalignr {{.*#+}} xmm0 = xmm1[15],xmm0[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14]
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 31, i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_15_00_01_02_03_04_05_06_07_08_09_10_11_12_13_14(<16 x i8> %a, <16 x i8> %b) {
; SSE2-LABEL: shuffle_v16i8_15_00_01_02_03_04_05_06_07_08_09_10_11_12_13_14:
; SSE2:       # BB#0:
; SSE2-NEXT:    pxor %xmm1, %xmm1
; SSE2-NEXT:    movdqa %xmm0, %xmm2
; SSE2-NEXT:    punpckhbw {{.*#+}} xmm2 = xmm2[8],xmm1[8],xmm2[9],xmm1[9],xmm2[10],xmm1[10],xmm2[11],xmm1[11],xmm2[12],xmm1[12],xmm2[13],xmm1[13],xmm2[14],xmm1[14],xmm2[15],xmm1[15]
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3],xmm0[4],xmm1[4],xmm0[5],xmm1[5],xmm0[6],xmm1[6],xmm0[7],xmm1[7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm1 = xmm0[2,3,0,1]
; SSE2-NEXT:    movdqa %xmm2, %xmm3
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm3 = xmm3[0],xmm1[0],xmm3[1],xmm1[1],xmm3[2],xmm1[2],xmm3[3],xmm1[3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm1 = xmm3[0,2,2,3,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm1 = xmm1[0,1,2,3,4,7,6,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[0,2,2,3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm1 = xmm1[3,0,1,2,4,5,6,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm3 = xmm2[3,1,2,0]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm3 = xmm3[0,3,2,3,4,5,6,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm3 = xmm3[0,2,2,3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm3 = xmm3[1,2,3,0,4,5,6,7]
; SSE2-NEXT:    punpcklqdq {{.*#+}} xmm1 = xmm1[0],xmm3[0]
; SSE2-NEXT:    pshufd {{.*#+}} xmm2 = xmm2[2,3,0,1]
; SSE2-NEXT:    pshufd {{.*#+}} xmm3 = xmm0[3,1,2,0]
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1],xmm0[2],xmm2[2],xmm0[3],xmm2[3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[0,2,2,3,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm0 = xmm0[0,1,2,3,4,7,6,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,2,2,3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[3,0,1,2,4,5,6,7]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm2 = xmm3[0,3,2,3,4,5,6,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm2 = xmm2[0,2,2,3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm2 = xmm2[1,2,3,0,4,5,6,7]
; SSE2-NEXT:    punpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm2[0]
; SSE2-NEXT:    packuswb %xmm1, %xmm0
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuffle_v16i8_15_00_01_02_03_04_05_06_07_08_09_10_11_12_13_14:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    palignr {{.*#+}} xmm0 = xmm0[15,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuffle_v16i8_15_00_01_02_03_04_05_06_07_08_09_10_11_12_13_14:
; SSE41:       # BB#0:
; SSE41-NEXT:    palignr {{.*#+}} xmm0 = xmm0[15,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14]
; SSE41-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_15_00_01_02_03_04_05_06_07_08_09_10_11_12_13_14:
; AVX:       # BB#0:
; AVX-NEXT:    vpalignr {{.*#+}} xmm0 = xmm0[15,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14]
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 15, i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_17_18_19_20_21_22_23_24_25_26_27_28_29_30_31_00(<16 x i8> %a, <16 x i8> %b) {
; SSE2-LABEL: shuffle_v16i8_17_18_19_20_21_22_23_24_25_26_27_28_29_30_31_00:
; SSE2:       # BB#0:
; SSE2-NEXT:    pxor %xmm2, %xmm2
; SSE2-NEXT:    movdqa %xmm1, %xmm3
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm3 = xmm3[0],xmm2[0],xmm3[1],xmm2[1],xmm3[2],xmm2[2],xmm3[3],xmm2[3],xmm3[4],xmm2[4],xmm3[5],xmm2[5],xmm3[6],xmm2[6],xmm3[7],xmm2[7]
; SSE2-NEXT:    punpckhbw {{.*#+}} xmm1 = xmm1[8],xmm2[8],xmm1[9],xmm2[9],xmm1[10],xmm2[10],xmm1[11],xmm2[11],xmm1[12],xmm2[12],xmm1[13],xmm2[13],xmm1[14],xmm2[14],xmm1[15],xmm2[15]
; SSE2-NEXT:    pshufd {{.*#+}} xmm2 = xmm1[0,1,0,1]
; SSE2-NEXT:    pshufd {{.*#+}} xmm4 = xmm3[3,1,2,0]
; SSE2-NEXT:    punpckhwd {{.*#+}} xmm3 = xmm3[4],xmm2[4],xmm3[5],xmm2[5],xmm3[6],xmm2[6],xmm3[7],xmm2[7]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm2 = xmm3[2,1,2,3,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm2 = xmm2[0,1,2,3,4,6,6,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm2 = xmm2[0,2,2,3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm3 = xmm2[0,2,3,1,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm2 = xmm4[0,1,2,3,4,7,6,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm2 = xmm2[2,1,2,3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm2 = xmm2[1,2,3,0,4,5,6,7]
; SSE2-NEXT:    punpcklqdq {{.*#+}} xmm2 = xmm2[0],xmm3[0]
; SSE2-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[3,1,2,0]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm1 = xmm1[0,1,2,3,4,5,4,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[3,1,2,0]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm1 = xmm1[1,2,3,0,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm1 = xmm1[0,1,2,3,5,6,7,7]
; SSE2-NEXT:    pand {{.*}}(%rip), %xmm0
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,1,0,3]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm0 = xmm0[0,1,2,3,4,5,6,4]
; SSE2-NEXT:    movdqa %xmm1, %xmm3
; SSE2-NEXT:    punpckhwd {{.*#+}} xmm3 = xmm3[4],xmm0[4],xmm3[5],xmm0[5],xmm3[6],xmm0[6],xmm3[7],xmm0[7]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm0 = xmm3[0,2,2,3,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm0 = xmm0[0,1,2,3,4,7,6,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,2,2,3]
; SSE2-NEXT:    punpcklqdq {{.*#+}} xmm1 = xmm1[0],xmm0[0]
; SSE2-NEXT:    packuswb %xmm1, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuffle_v16i8_17_18_19_20_21_22_23_24_25_26_27_28_29_30_31_00:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    palignr {{.*#+}} xmm0 = xmm1[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15],xmm0[0]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuffle_v16i8_17_18_19_20_21_22_23_24_25_26_27_28_29_30_31_00:
; SSE41:       # BB#0:
; SSE41-NEXT:    palignr {{.*#+}} xmm0 = xmm1[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15],xmm0[0]
; SSE41-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_17_18_19_20_21_22_23_24_25_26_27_28_29_30_31_00:
; AVX:       # BB#0:
; AVX-NEXT:    vpalignr {{.*#+}} xmm0 = xmm1[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15],xmm0[0]
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30, i32 31, i32 0>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_01_02_03_04_05_06_07_08_09_10_11_12_13_14_15_16(<16 x i8> %a, <16 x i8> %b) {
; SSE2-LABEL: shuffle_v16i8_01_02_03_04_05_06_07_08_09_10_11_12_13_14_15_16:
; SSE2:       # BB#0:
; SSE2-NEXT:    pxor %xmm2, %xmm2
; SSE2-NEXT:    movdqa %xmm0, %xmm3
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm3 = xmm3[0],xmm2[0],xmm3[1],xmm2[1],xmm3[2],xmm2[2],xmm3[3],xmm2[3],xmm3[4],xmm2[4],xmm3[5],xmm2[5],xmm3[6],xmm2[6],xmm3[7],xmm2[7]
; SSE2-NEXT:    punpckhbw {{.*#+}} xmm0 = xmm0[8],xmm2[8],xmm0[9],xmm2[9],xmm0[10],xmm2[10],xmm0[11],xmm2[11],xmm0[12],xmm2[12],xmm0[13],xmm2[13],xmm0[14],xmm2[14],xmm0[15],xmm2[15]
; SSE2-NEXT:    pshufd {{.*#+}} xmm2 = xmm0[0,1,0,1]
; SSE2-NEXT:    pshufd {{.*#+}} xmm4 = xmm3[3,1,2,0]
; SSE2-NEXT:    punpckhwd {{.*#+}} xmm3 = xmm3[4],xmm2[4],xmm3[5],xmm2[5],xmm3[6],xmm2[6],xmm3[7],xmm2[7]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm2 = xmm3[2,1,2,3,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm2 = xmm2[0,1,2,3,4,6,6,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm2 = xmm2[0,2,2,3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm3 = xmm2[0,2,3,1,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm2 = xmm4[0,1,2,3,4,7,6,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm2 = xmm2[2,1,2,3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm2 = xmm2[1,2,3,0,4,5,6,7]
; SSE2-NEXT:    punpcklqdq {{.*#+}} xmm2 = xmm2[0],xmm3[0]
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[3,1,2,0]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm0 = xmm0[0,1,2,3,4,5,4,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[3,1,2,0]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[1,2,3,0,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm0 = xmm0[0,1,2,3,5,6,7,7]
; SSE2-NEXT:    pand {{.*}}(%rip), %xmm1
; SSE2-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[0,1,0,3]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm1 = xmm1[0,1,2,3,4,5,6,4]
; SSE2-NEXT:    movdqa %xmm0, %xmm3
; SSE2-NEXT:    punpckhwd {{.*#+}} xmm3 = xmm3[4],xmm1[4],xmm3[5],xmm1[5],xmm3[6],xmm1[6],xmm3[7],xmm1[7]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm1 = xmm3[0,2,2,3,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm1 = xmm1[0,1,2,3,4,7,6,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[0,2,2,3]
; SSE2-NEXT:    punpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; SSE2-NEXT:    packuswb %xmm0, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuffle_v16i8_01_02_03_04_05_06_07_08_09_10_11_12_13_14_15_16:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    palignr {{.*#+}} xmm1 = xmm0[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15],xmm1[0]
; SSSE3-NEXT:    movdqa %xmm1, %xmm0
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuffle_v16i8_01_02_03_04_05_06_07_08_09_10_11_12_13_14_15_16:
; SSE41:       # BB#0:
; SSE41-NEXT:    palignr {{.*#+}} xmm1 = xmm0[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15],xmm1[0]
; SSE41-NEXT:    movdqa %xmm1, %xmm0
; SSE41-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_01_02_03_04_05_06_07_08_09_10_11_12_13_14_15_16:
; AVX:       # BB#0:
; AVX-NEXT:    vpalignr {{.*#+}} xmm0 = xmm0[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15],xmm1[0]
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 16>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_01_02_03_04_05_06_07_08_09_10_11_12_13_14_15_00(<16 x i8> %a, <16 x i8> %b) {
; SSE2-LABEL: shuffle_v16i8_01_02_03_04_05_06_07_08_09_10_11_12_13_14_15_00:
; SSE2:       # BB#0:
; SSE2-NEXT:    pxor %xmm1, %xmm1
; SSE2-NEXT:    movdqa %xmm0, %xmm2
; SSE2-NEXT:    punpckhbw {{.*#+}} xmm2 = xmm2[8],xmm1[8],xmm2[9],xmm1[9],xmm2[10],xmm1[10],xmm2[11],xmm1[11],xmm2[12],xmm1[12],xmm2[13],xmm1[13],xmm2[14],xmm1[14],xmm2[15],xmm1[15]
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3],xmm0[4],xmm1[4],xmm0[5],xmm1[5],xmm0[6],xmm1[6],xmm0[7],xmm1[7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm1 = xmm0[0,1,0,1]
; SSE2-NEXT:    movdqa %xmm2, %xmm3
; SSE2-NEXT:    punpckhwd {{.*#+}} xmm3 = xmm3[4],xmm1[4],xmm3[5],xmm1[5],xmm3[6],xmm1[6],xmm3[7],xmm1[7]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm1 = xmm3[2,1,2,3,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm1 = xmm1[0,1,2,3,4,6,6,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[0,2,2,3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm1 = xmm1[0,2,3,1,4,5,6,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm3 = xmm2[3,1,2,0]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm3 = xmm3[0,1,2,3,4,7,6,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm3 = xmm3[2,1,2,3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm3 = xmm3[1,2,3,0,4,5,6,7]
; SSE2-NEXT:    punpcklqdq {{.*#+}} xmm3 = xmm3[0],xmm1[0]
; SSE2-NEXT:    pshufd {{.*#+}} xmm1 = xmm2[0,1,0,1]
; SSE2-NEXT:    pshufd {{.*#+}} xmm2 = xmm0[3,1,2,0]
; SSE2-NEXT:    punpckhwd {{.*#+}} xmm0 = xmm0[4],xmm1[4],xmm0[5],xmm1[5],xmm0[6],xmm1[6],xmm0[7],xmm1[7]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[2,1,2,3,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm0 = xmm0[0,1,2,3,4,6,6,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,2,2,3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm1 = xmm0[0,2,3,1,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm0 = xmm2[0,1,2,3,4,7,6,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[2,1,2,3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[1,2,3,0,4,5,6,7]
; SSE2-NEXT:    punpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; SSE2-NEXT:    packuswb %xmm3, %xmm0
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuffle_v16i8_01_02_03_04_05_06_07_08_09_10_11_12_13_14_15_00:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    palignr {{.*#+}} xmm0 = xmm0[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuffle_v16i8_01_02_03_04_05_06_07_08_09_10_11_12_13_14_15_00:
; SSE41:       # BB#0:
; SSE41-NEXT:    palignr {{.*#+}} xmm0 = xmm0[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0]
; SSE41-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_01_02_03_04_05_06_07_08_09_10_11_12_13_14_15_00:
; AVX:       # BB#0:
; AVX-NEXT:    vpalignr {{.*#+}} xmm0 = xmm0[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0]
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 0>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_15_16_17_18_19_20_21_22_23_24_25_26_27_28_29_30(<16 x i8> %a, <16 x i8> %b) {
; SSE2-LABEL: shuffle_v16i8_15_16_17_18_19_20_21_22_23_24_25_26_27_28_29_30:
; SSE2:       # BB#0:
; SSE2-NEXT:    pxor %xmm2, %xmm2
; SSE2-NEXT:    movdqa %xmm1, %xmm3
; SSE2-NEXT:    punpckhbw {{.*#+}} xmm3 = xmm3[8],xmm2[8],xmm3[9],xmm2[9],xmm3[10],xmm2[10],xmm3[11],xmm2[11],xmm3[12],xmm2[12],xmm3[13],xmm2[13],xmm3[14],xmm2[14],xmm3[15],xmm2[15]
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1],xmm1[2],xmm2[2],xmm1[3],xmm2[3],xmm1[4],xmm2[4],xmm1[5],xmm2[5],xmm1[6],xmm2[6],xmm1[7],xmm2[7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm4 = xmm1[2,3,0,1]
; SSE2-NEXT:    pshufd {{.*#+}} xmm5 = xmm3[3,1,2,0]
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm3 = xmm3[0],xmm4[0],xmm3[1],xmm4[1],xmm3[2],xmm4[2],xmm3[3],xmm4[3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm3 = xmm3[0,2,2,3,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm3 = xmm3[0,1,2,3,4,7,6,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm3 = xmm3[0,2,2,3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm3 = xmm3[3,0,1,2,4,5,6,7]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm4 = xmm5[0,3,2,3,4,5,6,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm4 = xmm4[0,2,2,3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm4 = xmm4[1,2,3,0,4,5,6,7]
; SSE2-NEXT:    punpcklqdq {{.*#+}} xmm3 = xmm3[0],xmm4[0]
; SSE2-NEXT:    punpckhbw {{.*#+}} xmm0 = xmm0[8],xmm2[8],xmm0[9],xmm2[9],xmm0[10],xmm2[10],xmm0[11],xmm2[11],xmm0[12],xmm2[12],xmm0[13],xmm2[13],xmm0[14],xmm2[14],xmm0[15],xmm2[15]
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,3,2,3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[3,1,2,3,4,5,6,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[3,1,2,0]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm1 = xmm1[0,3,2,3,4,5,6,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[3,1,2,0]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm1 = xmm1[0,0,1,2,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm1 = xmm1[0,1,2,3,7,4,5,6]
; SSE2-NEXT:    pshufd {{.*#+}} xmm2 = xmm1[2,3,0,1]
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm1 = xmm1[0],xmm0[0],xmm1[1],xmm0[1],xmm1[2],xmm0[2],xmm1[3],xmm0[3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm0 = xmm1[2,1,2,3,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm0 = xmm0[0,1,2,3,4,6,6,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,2,2,3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[1,0,2,3,4,5,6,7]
; SSE2-NEXT:    punpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm2[0]
; SSE2-NEXT:    packuswb %xmm3, %xmm0
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuffle_v16i8_15_16_17_18_19_20_21_22_23_24_25_26_27_28_29_30:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    palignr {{.*#+}} xmm1 = xmm0[15],xmm1[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14]
; SSSE3-NEXT:    movdqa %xmm1, %xmm0
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuffle_v16i8_15_16_17_18_19_20_21_22_23_24_25_26_27_28_29_30:
; SSE41:       # BB#0:
; SSE41-NEXT:    palignr {{.*#+}} xmm1 = xmm0[15],xmm1[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14]
; SSE41-NEXT:    movdqa %xmm1, %xmm0
; SSE41-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_15_16_17_18_19_20_21_22_23_24_25_26_27_28_29_30:
; AVX:       # BB#0:
; AVX-NEXT:    vpalignr {{.*#+}} xmm0 = xmm0[15],xmm1[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14]
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 15, i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_00_uu_uu_uu_uu_uu_uu_uu_01_uu_uu_uu_uu_uu_uu_uu(<16 x i8> %a) {
; SSE2-LABEL: shuffle_v16i8_00_uu_uu_uu_uu_uu_uu_uu_01_uu_uu_uu_uu_uu_uu_uu:
; SSE2:       # BB#0:
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3]
; SSE2-NEXT:    punpckldq {{.*#+}} xmm0 = xmm0[0,0,1,1]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuffle_v16i8_00_uu_uu_uu_uu_uu_uu_uu_01_uu_uu_uu_uu_uu_uu_uu:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0],zero,zero,zero,zero,zero,zero,zero,xmm0[1],zero,zero,zero,zero,zero,zero,zero
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuffle_v16i8_00_uu_uu_uu_uu_uu_uu_uu_01_uu_uu_uu_uu_uu_uu_uu:
; SSE41:       # BB#0:
; SSE41-NEXT:    pmovzxbq %xmm0, %xmm0
; SSE41-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_00_uu_uu_uu_uu_uu_uu_uu_01_uu_uu_uu_uu_uu_uu_uu:
; AVX:       # BB#0:
; AVX-NEXT:    vpmovzxbq %xmm0, %xmm0
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> zeroinitializer, <16 x i32> <i32 0, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 1, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_00_zz_zz_zz_zz_zz_zz_zz_01_zz_zz_zz_zz_zz_zz_zz(<16 x i8> %a) {
; SSE2-LABEL: shuffle_v16i8_00_zz_zz_zz_zz_zz_zz_zz_01_zz_zz_zz_zz_zz_zz_zz:
; SSE2:       # BB#0:
; SSE2-NEXT:    pxor %xmm1, %xmm1
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3],xmm0[4],xmm1[4],xmm0[5],xmm1[5],xmm0[6],xmm1[6],xmm0[7],xmm1[7]
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3]
; SSE2-NEXT:    punpckldq {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuffle_v16i8_00_zz_zz_zz_zz_zz_zz_zz_01_zz_zz_zz_zz_zz_zz_zz:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0],zero,zero,zero,zero,zero,zero,zero,xmm0[1],zero,zero,zero,zero,zero,zero,zero
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuffle_v16i8_00_zz_zz_zz_zz_zz_zz_zz_01_zz_zz_zz_zz_zz_zz_zz:
; SSE41:       # BB#0:
; SSE41-NEXT:    pmovzxbq %xmm0, %xmm0
; SSE41-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_00_zz_zz_zz_zz_zz_zz_zz_01_zz_zz_zz_zz_zz_zz_zz:
; AVX:       # BB#0:
; AVX-NEXT:    vpmovzxbq %xmm0, %xmm0
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> zeroinitializer, <16 x i32> <i32 0, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 1, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30, i32 31>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_00_uu_uu_uu_01_uu_uu_uu_02_uu_uu_uu_03_uu_uu_uu(<16 x i8> %a) {
; SSE2-LABEL: shuffle_v16i8_00_uu_uu_uu_01_uu_uu_uu_02_uu_uu_uu_03_uu_uu_uu:
; SSE2:       # BB#0:
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuffle_v16i8_00_uu_uu_uu_01_uu_uu_uu_02_uu_uu_uu_03_uu_uu_uu:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; SSSE3-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuffle_v16i8_00_uu_uu_uu_01_uu_uu_uu_02_uu_uu_uu_03_uu_uu_uu:
; SSE41:       # BB#0:
; SSE41-NEXT:    pmovzxbd %xmm0, %xmm0
; SSE41-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_00_uu_uu_uu_01_uu_uu_uu_02_uu_uu_uu_03_uu_uu_uu:
; AVX:       # BB#0:
; AVX-NEXT:    vpmovzxbd %xmm0, %xmm0
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> zeroinitializer, <16 x i32> <i32 0, i32 undef, i32 undef, i32 undef, i32 1, i32 undef, i32 undef, i32 undef, i32 2, i32 undef, i32 undef, i32 undef, i32 3, i32 undef, i32 undef, i32 undef>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_00_zz_zz_zz_01_zz_zz_zz_02_zz_zz_zz_03_zz_zz_zz(<16 x i8> %a) {
; SSE2-LABEL: shuffle_v16i8_00_zz_zz_zz_01_zz_zz_zz_02_zz_zz_zz_03_zz_zz_zz:
; SSE2:       # BB#0:
; SSE2-NEXT:    pxor %xmm1, %xmm1
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3],xmm0[4],xmm1[4],xmm0[5],xmm1[5],xmm0[6],xmm1[6],xmm0[7],xmm1[7]
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuffle_v16i8_00_zz_zz_zz_01_zz_zz_zz_02_zz_zz_zz_03_zz_zz_zz:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    pxor %xmm1, %xmm1
; SSSE3-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3],xmm0[4],xmm1[4],xmm0[5],xmm1[5],xmm0[6],xmm1[6],xmm0[7],xmm1[7]
; SSSE3-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuffle_v16i8_00_zz_zz_zz_01_zz_zz_zz_02_zz_zz_zz_03_zz_zz_zz:
; SSE41:       # BB#0:
; SSE41-NEXT:    pmovzxbd %xmm0, %xmm0
; SSE41-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_00_zz_zz_zz_01_zz_zz_zz_02_zz_zz_zz_03_zz_zz_zz:
; AVX:       # BB#0:
; AVX-NEXT:    vpmovzxbd %xmm0, %xmm0
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> zeroinitializer, <16 x i32> <i32 0, i32 17, i32 18, i32 19, i32 1, i32 21, i32 22, i32 23, i32 2, i32 25, i32 26, i32 27, i32 3, i32 29, i32 30, i32 31>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_00_uu_01_uu_02_uu_03_uu_04_uu_05_uu_06_uu_07_uu(<16 x i8> %a) {
; SSE2-LABEL: shuffle_v16i8_00_uu_01_uu_02_uu_03_uu_04_uu_05_uu_06_uu_07_uu:
; SSE2:       # BB#0:
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuffle_v16i8_00_uu_01_uu_02_uu_03_uu_04_uu_05_uu_06_uu_07_uu:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuffle_v16i8_00_uu_01_uu_02_uu_03_uu_04_uu_05_uu_06_uu_07_uu:
; SSE41:       # BB#0:
; SSE41-NEXT:    pmovzxbw %xmm0, %xmm0
; SSE41-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_00_uu_01_uu_02_uu_03_uu_04_uu_05_uu_06_uu_07_uu:
; AVX:       # BB#0:
; AVX-NEXT:    vpmovzxbw %xmm0, %xmm0
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> zeroinitializer, <16 x i32> <i32 0, i32 undef, i32 1, i32 undef, i32 2, i32 undef, i32 3, i32 undef, i32 4, i32 undef, i32 5, i32 undef, i32 6, i32 undef, i32 7, i32 undef>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_00_zz_01_zz_02_zz_03_zz_04_zz_05_zz_06_zz_07_zz(<16 x i8> %a) {
; SSE2-LABEL: shuffle_v16i8_00_zz_01_zz_02_zz_03_zz_04_zz_05_zz_06_zz_07_zz:
; SSE2:       # BB#0:
; SSE2-NEXT:    pxor %xmm1, %xmm1
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3],xmm0[4],xmm1[4],xmm0[5],xmm1[5],xmm0[6],xmm1[6],xmm0[7],xmm1[7]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuffle_v16i8_00_zz_01_zz_02_zz_03_zz_04_zz_05_zz_06_zz_07_zz:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    pxor %xmm1, %xmm1
; SSSE3-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3],xmm0[4],xmm1[4],xmm0[5],xmm1[5],xmm0[6],xmm1[6],xmm0[7],xmm1[7]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuffle_v16i8_00_zz_01_zz_02_zz_03_zz_04_zz_05_zz_06_zz_07_zz:
; SSE41:       # BB#0:
; SSE41-NEXT:    pmovzxbw %xmm0, %xmm0
; SSE41-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_00_zz_01_zz_02_zz_03_zz_04_zz_05_zz_06_zz_07_zz:
; AVX:       # BB#0:
; AVX-NEXT:    vpmovzxbw %xmm0, %xmm0
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> zeroinitializer, <16 x i32> <i32 0, i32 17, i32 1, i32 19, i32 2, i32 21, i32 3, i32 23, i32 4, i32 25, i32 5, i32 27, i32 6, i32 29, i32 7, i32 31>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_uu_10_02_07_22_14_07_02_18_03_01_14_18_09_11_00(<16 x i8> %a, <16 x i8> %b) {
; SSE2-LABEL: shuffle_v16i8_uu_10_02_07_22_14_07_02_18_03_01_14_18_09_11_00:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    pxor %xmm2, %xmm2
; SSE2-NEXT:    movdqa %xmm0, %xmm3
; SSE2-NEXT:    punpckhbw {{.*#+}} xmm3 = xmm3[8],xmm2[8],xmm3[9],xmm2[9],xmm3[10],xmm2[10],xmm3[11],xmm2[11],xmm3[12],xmm2[12],xmm3[13],xmm2[13],xmm3[14],xmm2[14],xmm3[15],xmm2[15]
; SSE2-NEXT:    pshufd {{.*#+}} xmm4 = xmm3[2,3,0,1]
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1],xmm0[2],xmm2[2],xmm0[3],xmm2[3],xmm0[4],xmm2[4],xmm0[5],xmm2[5],xmm0[6],xmm2[6],xmm0[7],xmm2[7]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm2 = xmm0[0,2,2,3,4,5,6,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm2 = xmm2[0,3,2,3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm2 = xmm2[1,0,3,3,4,5,6,7]
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm2 = xmm2[0],xmm4[0],xmm2[1],xmm4[1],xmm2[2],xmm4[2],xmm2[3],xmm4[3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm2 = xmm2[0,2,2,3,4,5,6,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm2 = xmm2[0,2,2,3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm2 = xmm2[2,0,3,1,4,5,6,7]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm4 = xmm3[2,1,2,3,4,5,6,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm4 = xmm4[0,3,2,3]
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm4 = xmm4[0],xmm0[0],xmm4[1],xmm0[1],xmm4[2],xmm0[2],xmm4[3],xmm0[3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm4 = xmm4[0,2,2,3,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm4 = xmm4[0,1,2,3,4,7,6,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm4 = xmm4[0,2,2,3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm4 = xmm4[0,2,3,1,4,5,6,7]
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm4 = xmm4[0],xmm2[0],xmm4[1],xmm2[1],xmm4[2],xmm2[2],xmm4[3],xmm2[3]
; SSE2-NEXT:    packuswb %xmm0, %xmm4
; SSE2-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[2,1,2,3,4,5,6,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,3,2,3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[0,1,3,3,4,5,6,7]
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm3[0],xmm0[1],xmm3[1],xmm0[2],xmm3[2],xmm0[3],xmm3[3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[0,2,2,3,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm0 = xmm0[0,1,2,3,4,7,6,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,2,2,3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm2 = xmm0[0,2,1,3,4,5,6,7]
; SSE2-NEXT:    packuswb %xmm0, %xmm2
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm1 = xmm1[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm1[3,1,2,3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[0,2,2,3,4,5,6,7]
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1],xmm0[2],xmm2[2],xmm0[3],xmm2[3],xmm0[4],xmm2[4],xmm0[5],xmm2[5],xmm0[6],xmm2[6],xmm0[7],xmm2[7]
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0],xmm4[0],xmm0[1],xmm4[1],xmm0[2],xmm4[2],xmm0[3],xmm4[3],xmm0[4],xmm4[4],xmm0[5],xmm4[5],xmm0[6],xmm4[6],xmm0[7],xmm4[7]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuffle_v16i8_uu_10_02_07_22_14_07_02_18_03_01_14_18_09_11_00:
; SSSE3:       # BB#0: # %entry
; SSSE3-NEXT:    movdqa %xmm0, %xmm2
; SSSE3-NEXT:    pshufb {{.*#+}} xmm2 = xmm2[2,7,1,11,u,u,u,u,u,u,u,u,u,u,u,u]
; SSSE3-NEXT:    pshufb {{.*#+}} xmm1 = xmm1[6,6,2,2,2,2,3,3,4,4,5,5,6,6,7,7]
; SSSE3-NEXT:    punpcklbw {{.*#+}} xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1],xmm1[2],xmm2[2],xmm1[3],xmm2[3],xmm1[4],xmm2[4],xmm1[5],xmm2[5],xmm1[6],xmm2[6],xmm1[7],xmm2[7]
; SSSE3-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[10,7,14,2,3,14,9,0,u,u,u,u,u,u,u,u]
; SSSE3-NEXT:    punpcklbw {{.*#+}} xmm1 = xmm1[0],xmm0[0],xmm1[1],xmm0[1],xmm1[2],xmm0[2],xmm1[3],xmm0[3],xmm1[4],xmm0[4],xmm1[5],xmm0[5],xmm1[6],xmm0[6],xmm1[7],xmm0[7]
; SSSE3-NEXT:    movdqa %xmm1, %xmm0
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuffle_v16i8_uu_10_02_07_22_14_07_02_18_03_01_14_18_09_11_00:
; SSE41:       # BB#0: # %entry
; SSE41-NEXT:    movdqa %xmm0, %xmm2
; SSE41-NEXT:    pshufb {{.*#+}} xmm2 = xmm2[2,7,1,11,u,u,u,u,u,u,u,u,u,u,u,u]
; SSE41-NEXT:    pshufb {{.*#+}} xmm1 = xmm1[6,6,2,2,2,2,3,3,4,4,5,5,6,6,7,7]
; SSE41-NEXT:    punpcklbw {{.*#+}} xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1],xmm1[2],xmm2[2],xmm1[3],xmm2[3],xmm1[4],xmm2[4],xmm1[5],xmm2[5],xmm1[6],xmm2[6],xmm1[7],xmm2[7]
; SSE41-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[10,7,14,2,3,14,9,0,u,u,u,u,u,u,u,u]
; SSE41-NEXT:    punpcklbw {{.*#+}} xmm1 = xmm1[0],xmm0[0],xmm1[1],xmm0[1],xmm1[2],xmm0[2],xmm1[3],xmm0[3],xmm1[4],xmm0[4],xmm1[5],xmm0[5],xmm1[6],xmm0[6],xmm1[7],xmm0[7]
; SSE41-NEXT:    movdqa %xmm1, %xmm0
; SSE41-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_uu_10_02_07_22_14_07_02_18_03_01_14_18_09_11_00:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpshufb {{.*#+}} xmm2 = xmm0[2,7,1,11,u,u,u,u,u,u,u,u,u,u,u,u]
; AVX-NEXT:    vpshufb {{.*#+}} xmm1 = xmm1[6,6,2,2,2,2,3,3,4,4,5,5,6,6,7,7]
; AVX-NEXT:    vpunpcklbw {{.*#+}} xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1],xmm1[2],xmm2[2],xmm1[3],xmm2[3],xmm1[4],xmm2[4],xmm1[5],xmm2[5],xmm1[6],xmm2[6],xmm1[7],xmm2[7]
; AVX-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[10,7,14,2,3,14,9,0,u,u,u,u,u,u,u,u]
; AVX-NEXT:    vpunpcklbw {{.*#+}} xmm0 = xmm1[0],xmm0[0],xmm1[1],xmm0[1],xmm1[2],xmm0[2],xmm1[3],xmm0[3],xmm1[4],xmm0[4],xmm1[5],xmm0[5],xmm1[6],xmm0[6],xmm1[7],xmm0[7]
; AVX-NEXT:    retq
entry:
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 undef, i32 10, i32 2, i32 7, i32 22, i32 14, i32 7, i32 2, i32 18, i32 3, i32 1, i32 14, i32 18, i32 9, i32 11, i32 0>

  ret <16 x i8> %shuffle
}

define <16 x i8> @stress_test2(<16 x i8> %s.0.0, <16 x i8> %s.0.1, <16 x i8> %s.0.2) {
; Nothing interesting to test here. Just make sure we didn't crashe.
; ALL-LABEL: stress_test2:
; ALL:         retq
entry:
  %s.1.0 = shufflevector <16 x i8> %s.0.0, <16 x i8> %s.0.1, <16 x i32> <i32 29, i32 30, i32 2, i32 16, i32 26, i32 21, i32 11, i32 26, i32 26, i32 3, i32 4, i32 5, i32 30, i32 28, i32 15, i32 5>
  %s.1.1 = shufflevector <16 x i8> %s.0.1, <16 x i8> %s.0.2, <16 x i32> <i32 31, i32 1, i32 24, i32 12, i32 28, i32 5, i32 2, i32 9, i32 29, i32 1, i32 31, i32 5, i32 6, i32 17, i32 15, i32 22>
  %s.2.0 = shufflevector <16 x i8> %s.1.0, <16 x i8> %s.1.1, <16 x i32> <i32 22, i32 1, i32 12, i32 3, i32 30, i32 4, i32 30, i32 undef, i32 1, i32 10, i32 14, i32 18, i32 27, i32 13, i32 16, i32 19>

  ret <16 x i8> %s.2.0
}
