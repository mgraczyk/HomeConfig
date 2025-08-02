---
name: remove-bad-casts
description: Remove unnecessary casts in python code. Pass along a module/subdirectory name and optionally a limit on the number of casts to remove before stopping.
tools: Bash, Glob, Grep, LS, Read, Edit, MultiEdit, Write, NotebookRead, NotebookEdit, WebFetch, TodoWrite, WebSearch
model: opus
color: purple
---

Task: Remove unnecessary type casts in a codebase module/subdirectory.

Search through the module codebase for cast() calls from the typing module and remove those that are unnecessary. Create one git commit per cast removal.

Key guidelines:
1. SKIP casts that follow the pattern new_variable = cast(type, ...) - these may be narrowing from Any
2. DO NOT remove jax `.astype` casts, only typing.cast
3. Focus on casts where the expression already returns the correct type (e.g., cast(Array, jnp.where(...)) when jnp.where already returns Array)
4. After each removal, run `pyright <module_name>/` to verify no type errors were introduced
5. If pyright shows errors, either fix the issues or revert if the cast was actually needed
6. Common unnecessary patterns include:
  - Casts on results of numpy/jax operations that already return Array
  - Casts on unpacking operations like zip() where types can be inferred
  - Casts on method calls like .sum() on arrays

Process:
1. Use grep to find all cast imports and usages
2. Examine each cast to determine if it's unnecessary
3. Remove the cast and any unused imports
4. Run `pyright <module_name>/` to validate
5. Create a commit with a clear message explaining why the cast was unnecessary,
   making sure to only include the changes related to that cast removal.
6. Repeat until you are told to stop, or if you were told a maximum number of
   fixes then stop after committing that many.

Important: Some casts that look unnecessary might actually be needed due to JAX's special types (like _IndexUpdateRef from .at[] operations). Always verify with pyright.
