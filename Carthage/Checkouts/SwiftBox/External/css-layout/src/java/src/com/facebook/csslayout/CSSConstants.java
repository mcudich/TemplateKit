/**
 * Copyright (c) 2014, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */
package com.facebook.csslayout;

public class CSSConstants {

  public static final float UNDEFINED = Float.NaN;

  public static boolean isUndefined(float value) {
    return Float.compare(value, UNDEFINED) == 0;
  }
}
