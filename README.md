# clusterfuzzlite_int
Try out clusterfuzzlite - here are the steps that were followed

## A minimal fuzz test
This minimal example is from the libfuzzer documentation

Bazel build uses [bazel fuzzing rules](https://github.com/bazelbuild/rules_fuzzing)

## Running the fuzz test
```sh
$ bazel run --config=asan-libfuzzer //:fuzz_test_run
```

## Adding clusterfuzzlite support
Follow the documentation at https://google.github.io/clusterfuzzlite/build-integration/
And make sure to do the local tests as per documentation

Adopt build.sh based on grpc project's build.sh to get to a working set of compiler options. Was a quick hack to make things work.

In this particular setup the following tests were done
```sh
python infra/helper.py build_image --external $PATH_TO_PROJECT
python infra/helper.py build_fuzzers --external $PATH_TO_PROJECT --sanitizer address
python infra/helper.py check_build --external $PATH_TO_PROJECT --sanitizer address
python infra/helper.py run_fuzzer --external $PATH_TO_PROJECT fuzz_test_bin
python infra/helper.py build_fuzzers --external --sanitizer coverage $PATH_TO_PROJECT
python infra/helper.py check_build --external --sanitizer coverage $PATH_TO_PROJECT
python infra/helper.py run_fuzzer --external --sanitizer coverage $PATH_TO_PROJECT fuzz_test_bin
```
## Add github workflow
I am interested in setting up a batch run, so enable batch mode by adding .github/workflows/cflite_batch.yml