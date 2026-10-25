#!/bin/bash
# Run a gtest binary the way ctest + gtest_discover_tests does in Gluten/Velox CI:
# each matching test case in its own process. Some suites (e.g. Gluten's
# MultiMemoryManagerTest) re-initialize process-global state such as glog and abort
# when every suite shares one process.
#
# Usage: run-gtests.sh <binary> <gtest_filter> <logfile>
# Exit: 0 if at least one test ran and all passed; 1 otherwise.
set -uo pipefail

bin="$1" filter="$2" log="$3"
name=$(basename "$bin")
: > "$log"

# --gtest_list_tests prints "Suite." lines followed by "  Case" lines; drop
# "# GetParam() = ..." comments by keeping only the first field.
tests=()
while IFS= read -r t; do
  [ -n "$t" ] && tests+=("$t")
done < <("$bin" --gtest_list_tests --gtest_filter="$filter" 2>>"$log" \
  | awk '/^[^ ]/ {suite=$1; next} /^  [^ ]/ {print suite $1}')

if [ "${#tests[@]}" -eq 0 ]; then
  echo "gtest-isolated: no tests matched filter '$filter' in $name" | tee -a "$log"
  exit 1
fi

passed=0 failed=()
for t in "${tests[@]}"; do
  echo "===== $t" >> "$log"
  if "$bin" --gtest_filter="$t" >> "$log" 2>&1; then
    passed=$((passed + 1))
  else
    failed+=("$t")
  fi
done

echo "gtest-isolated: $passed passed, ${#failed[@]} failed of ${#tests[@]} ($name, filter '$filter')" | tee -a "$log"
for t in ${failed[@]+"${failed[@]}"}; do echo "gtest-isolated: FAILED $t" | tee -a "$log"; done
[ "${#failed[@]}" -eq 0 ]
