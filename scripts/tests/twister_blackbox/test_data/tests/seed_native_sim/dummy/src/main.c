/*
 * Copyright (c) 2024 Intel Corporation
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include <zephyr/ztest.h>

ZTEST_SUITE(a1_1_tests, NULL, NULL, NULL, NULL, NULL);

/**
 * @brief Test Asserts
 *
 * This test verifies various assert macros provided by ztest.
 *
 */
ZTEST(a1_1_tests, test_assert)
{
	zassert_true(0, "1 was false");
	zassert_false(1, "0 was true");
}
