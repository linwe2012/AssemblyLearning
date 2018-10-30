# AssemblyLearning
ASM learning

# LASM
A small cross-platform library implementing assembly command.

It can be used in such ways:

- `_ABC(arg1, arg2)`  which will behave like a function, which returns result if possible.

  note that this is only available with GNUC cuz it use its xtension `({...})`, which is not allowed in MSC. And I can't find a substitue.

- `ABC(arg1, arg2)` will behave like a actual asm cmd, e.g. `RORB(a, 2)` will make last byte of `a` rotate 2 bits.

  It will be intel style cuz AT&T style is inhuman.






---F**K U, GITHUB. MY EDIT ONLINE ALL GOT DELETED-----
