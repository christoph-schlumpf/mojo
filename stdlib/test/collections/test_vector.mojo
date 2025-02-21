# ===----------------------------------------------------------------------=== #
# Copyright (c) 2025, Modular Inc. All rights reserved.
#
# Licensed under the Apache License v2.0 with LLVM Exceptions:
# https://llvm.org/LICENSE.txt
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ===----------------------------------------------------------------------=== #
# RUN: %mojo %s

from collections.vector import InlinedFixedVector

from test_utils import MoveCounter
from testing import assert_equal


def test_inlined_fixed_vector_moves():
    var v1 = InlinedFixedVector[Int, 5](10)
    var v2 = InlinedFixedVector[Int, 5](10)

    # do one within the smallvec
    v2[3] = 99
    v1[3] = 42

    # plus one within the dynarray
    v2[7] = 9999
    v1[7] = 4242
    v2 = v1^  # moves

    assert_equal(v2[3], 42)
    assert_equal(v2[7], 4242)


def test_inlined_fixed_vector():
    var vector = InlinedFixedVector[Int, 5](10)

    for i in range(5):
        vector.append(i)

    # Verify it's iterable
    var index = 0
    for element in vector:
        assert_equal(vector[index], element)
        index += 1

    assert_equal(5, len(vector))

    # Can assign a specified index in static data range via `setitem`
    vector[2] = -2
    assert_equal(0, vector[0])
    assert_equal(1, vector[1])
    assert_equal(-2, vector[2])
    assert_equal(3, vector[3])
    assert_equal(4, vector[4])

    assert_equal(0, vector[-5])
    assert_equal(3, vector[-2])
    assert_equal(4, vector[-1])

    vector[-5] = 5
    assert_equal(5, vector[-5])
    vector[-2] = 3
    assert_equal(3, vector[-2])
    vector[-1] = 7
    assert_equal(7, vector[-1])

    # Can assign past the static size into the regrowable dynamic data portion
    for j in range(5, 10):
        vector.append(j)

    assert_equal(10, len(vector))

    # Verify the dynamic data got properly assigned to from above
    assert_equal(5, vector[5])
    assert_equal(6, vector[6])
    assert_equal(7, vector[7])
    assert_equal(8, vector[8])
    assert_equal(9, vector[9])

    assert_equal(9, vector[-1])

    # Assign a specified index in the dynamic_data portion
    vector[5] = -2
    assert_equal(-2, vector[5])

    vector.clear()
    assert_equal(0, len(vector))


def test_inlined_fixed_vector_with_default():
    var vector = InlinedFixedVector[Int](10)

    for i in range(5):
        vector.append(i)

    assert_equal(5, len(vector))

    vector[2] = -2

    assert_equal(0, vector[0])
    assert_equal(1, vector[1])
    assert_equal(-2, vector[2])
    assert_equal(3, vector[3])
    assert_equal(4, vector[4])

    for j in range(5, 10):
        vector.append(j)

    assert_equal(10, len(vector))

    assert_equal(5, vector[5])

    vector[5] = -2
    assert_equal(-2, vector[5])

    vector.clear()
    assert_equal(0, len(vector))


def test_indexing():
    var vector = InlinedFixedVector[Int](10)
    for i in range(5):
        vector.append(i)
    assert_equal(0, vector[Int(0)])
    assert_equal(1, vector[True])
    assert_equal(2, vector[2])


def main():
    test_inlined_fixed_vector()
    test_inlined_fixed_vector_with_default()
    test_indexing()
