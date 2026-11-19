#!/usr/bin/env bash
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Print every test Surefire skipped, with its reason. For skips raised by a bare
# JUnit assumption (no message), also print the assumption's source line taken
# from the skip's stack trace, so the log names the cause of each skip.
echo "Skipped tests and reasons (from surefire reports):"
awk '
/<testcase / {
  tc = $0
  match($0, /name="[^"]*"/); nm = substr($0, RSTART + 6, RLENGTH - 7)
  match($0, /classname="[^"]*"/); cls = substr($0, RSTART + 11, RLENGTH - 12)
}
/<skipped/ { print "SKIPPED " FILENAME " -> " tc " " $0; insk = 1 }
insk && index($0, "at " cls "." nm "(") > 0 {
  match($0, /:[0-9]+\)/); ln = substr($0, RSTART + 1, RLENGTH - 2) + 0
  p = cls; gsub(/\./, "/", p); src = "src/test/java/" p ".java"
  i = 0
  while ((getline l < src) > 0) {
    i++
    if (i == ln) { sub(/^[ \t]+/, "", l); print "    skip cause (" src ":" ln "): " l; break }
  }
  close(src); insk = 0
}
/<\/testcase>/ { insk = 0 }
' target/surefire-reports/TEST-*.xml
