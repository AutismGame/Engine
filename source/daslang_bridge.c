#define _MMINTRIN_H_INCLUDED
#define _EMMINTRIN_H_INCLUDED
#define _XMMINTRIN_H_INCLUDED
#define _IMMINTRIN_H_INCLUDED
#define __MMINTRIN_H
#define __IMMINTRIN_H

typedef float __m128 __attribute__((__aligned__(16)));
typedef double __m128d __attribute__((__aligned__(16)));
typedef long long __m128i __attribute__((__aligned__(16)));

#include "daScript/daScriptC.h"