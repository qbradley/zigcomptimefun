### metaprogramming experiments from portland zig day

we tried two different approaches for teaching the zig compiler new languages.
source text is parsed and turned into static evaluation machinery,
all at compile time.


## interp

forth inspired stack language.
vm style codegen with inline looping.


## zim

employing [mecha](https://github.com/Hejsil/mecha) parser.
operation graph is built while parsing and used for codegen.

it works! example output for computation
`x + x * y * (y + x * 42) + x * (y + y) + 99`:
```
0000000000000000 <codegen_test>:
   0:   55                      push   %rbp
   1:   48 89 e5                mov    %rsp,%rbp
   4:   48 6b c7 2a             imul   $0x2a,%rdi,%rax
   8:   48 01 f0                add    %rsi,%rax
   b:   48 83 c0 02             add    $0x2,%rax
   f:   48 0f af f7             imul   %rdi,%rsi
  13:   48 0f af f0             imul   %rax,%rsi
  17:   48 8d 04 37             lea    (%rdi,%rsi,1),%rax
  1b:   48 83 c0 63             add    $0x63,%rax
  1f:   5d                      pop    %rbp
  20:   c3                      ret
```
