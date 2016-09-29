// Copyright (c) 2015 Uber Technologies, Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
#pragma glslify: sum_fp64 = require(./sum-fp64, ONE=ONE)
#pragma glslify: mul_fp64 = require(./mul-fp64, ONE=ONE)

const vec2 inv_fact0 = vec2(1.666666716337204e-01, -4.967053879312289e-09);
const vec2 inv_fact2 = vec2(8.333333767950535e-03, -4.34617203337595e-10);
const vec2 inv_fact4 = vec2(1.9841270113829523e-04,  -2.725596874933456e-12);
const vec2 inv_fact6 = vec2(2.75573188446287533e-06, 3.7935713937038186e-14);
const vec2 inv_fact8 = vec2(2.5052107943679403e-08, 4.4176231769972645e-16);

vec2 sin_taylor_fp64(vec2 a) {
  vec2 r, s, t, x;

  if (a.x == 0.0 && a.y == 0.0) {
    return vec2(0.0, 0.0);
  }

  x = -mul_fp64(a, a);
  s = a;
  r = a;

  r = mul_fp64(r, x);
  t = mul_fp64(r, inv_fact0);
  s = sum_fp64(s, t);

  r = mul_fp64(r, x);
  t = mul_fp64(r, inv_fact2);
  s = sum_fp64(s, t);

  r = mul_fp64(r, x);
  t = mul_fp64(r, inv_fact4);
  s = sum_fp64(s, t);

  r = mul_fp64(r, x);
  t = mul_fp64(r, inv_fact6);
  s = sum_fp64(s, t);

  return s;
}
#pragma glslify: export(sin_taylor_fp64)
