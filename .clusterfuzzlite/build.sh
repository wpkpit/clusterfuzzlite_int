#!/bin/bash -eu

# build project
# e.g.
# ./autogen.sh
# ./configure
# make -j$(nproc) all

# build fuzzers
# e.g.
# $CXX $CXXFLAGS -std=c++11 -Iinclude \
#     /path/to/name_of_fuzzer.cc -o $OUT/name_of_fuzzer \
#     $LIB_FUZZING_ENGINE /path/to/library.a

# build grpc
# Temporary hack, see https://github.com/google/oss-fuzz/issues/383
readonly NO_VPTR='--copt=-fno-sanitize=vptr --linkopt=-fno-sanitize=vptr'

# Copied from envoy's build.sh
# Copy $CFLAGS and $CXXFLAGS into Bazel command-line flags, for both
# compilation and linking.
#
# Some flags, such as `-stdlib=libc++`, generate warnings if used on a C source
# file. Since the build runs with `-Werror` this will cause it to break, so we
# use `--conlyopt` and `--cxxopt` instead of `--copt`.
#
readonly EXTRA_BAZEL_FLAGS="$(
for f in ${CFLAGS}; do
  echo "--conlyopt=${f}" "--linkopt=${f}"
done
for f in ${CXXFLAGS}; do
  echo "--cxxopt=${f}" "--linkopt=${f}"
done
if [ "$SANITIZER" = "undefined" ]
then
  # Bazel uses clang to link binary, which does not link clang_rt ubsan library for C++ automatically.
  # See issue: https://github.com/bazelbuild/bazel/issues/8777
  echo "--linkopt=$(find $(llvm-config --libdir) -name libclang_rt.ubsan_standalone_cxx-x86_64.a | head -1)"
fi
)"

bazel build --config=asan-libfuzzer --dynamic_mode=off \
  --spawn_strategy=standalone \
  --genrule_strategy=standalone \
  ${NO_VPTR} \
  --strip=never \
  --linkopt=-lc++ \
  --linkopt=-pthread \
  --copt=${LIB_FUZZING_ENGINE} \
  --linkopt=${LIB_FUZZING_ENGINE} \
  ${EXTRA_BAZEL_FLAGS} \
  //:fuzz_test_run

cp bazel-bin/fuzz_test_run.runfiles/__main__/fuzz_test_bin "$OUT/"
