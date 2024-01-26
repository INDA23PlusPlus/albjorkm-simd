# Findings

The following command was used to compile with SIMD support:
```
zig test -Dcpu=x86_64+avx+sse+sse2 -O ReleaseFast ./src/main.zig
```

The following command was used to comile without SIMD support:
```
zig test -Dcpu=x86_64-avx-sse-sse2 -O ReleaseFast ./src/main.zig
```

The intial results were, for compiling with SIMD:
```
Benchmark      Iterations    Min(ns)    Max(ns)   Variance   Mean(ns)
---------------------------------------------------------------------
small_gauss(0)   10000000          0     154400      20328         55
Test [2/4] test.benchmark big gauss...
Benchmark    Iterations    Min(ns)    Max(ns)   Variance   Mean(ns)
-------------------------------------------------------------------
big_gauss(0)   10000000        100      32200       5370        186
```

And for without:
```
Benchmark      Iterations    Min(ns)    Max(ns)   Variance   Mean(ns)
---------------------------------------------------------------------
small_gauss(0)   10000000          0      26700       3565         55
Test [2/4] test.benchmark big gauss...
Benchmark    Iterations    Min(ns)    Max(ns)   Variance   Mean(ns)
-------------------------------------------------------------------
big_gauss(0)   10000000        100      26000       4273        184
```

There doesn't seem to be that much difference between running the program with or without
SIMD support. What is more concerning is that when one analysis the compiled output using
a decompiler; it appears that the compiler is able to place simd instructions in every
appropriate place.

In order to ensure that the it wasn't the row length that was too short, a compilation of 16 column wide reduced-row-echelon-solver
was compiled. But this did not affect the result as the version using SIMD and the version not using it had the same performance.
These results are surprising.
