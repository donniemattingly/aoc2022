# Advent of Code 2022

I'm trying to document the functions with doctests, so you should just be able
to run `mix test` to confirm it's all working.


## Installing

Just run

```bash
mix deps.get
```

Then this weird version of mix compile to solve an issue with the matrex library I'm using (assuming you're on macOS 10.15)

```bash
C_INCLUDE_PATH=/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Headers mix compile
```

