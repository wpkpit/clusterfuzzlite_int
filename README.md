# clusterfuzzlite_int
Try out clusterfuzzlite

## A minimal fuzz test
This minimal example is from the libfuzzer documentation
Bazel build uses [bazel fuzzing rules](https://github.com/bazelbuild/rules_fuzzing)

## Running the fuzz test
```sh
$ bazel run --config=asan-libfuzzer //:fuzz_test_run
```

