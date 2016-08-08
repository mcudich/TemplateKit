/**
 * Copyright (c) 2014, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */
package com.facebook.csslayout;

/**
 * The CSS style definition for a {@link CSSNode}.
 */
public class CSSStyle {

  public CSSFlexDirection flexDirection = CSSFlexDirection.COLUMN;
  public CSSJustify justifyContent = CSSJustify.FLEX_START;
  public CSSAlign alignItems = CSSAlign.STRETCH;
  public CSSAlign alignSelf = CSSAlign.AUTO;
  public CSSPositionType positionType = CSSPositionType.RELATIVE;
  public CSSWrap flexWrap = CSSWrap.NOWRAP;
  public float flex;

  public float[] margin = Spacing.newSpacingResultArray();
  public float[] padding = Spacing.newSpacingResultArray();
  public float[] border = Spacing.newSpacingResultArray();

  public float positionTop = CSSConstants.UNDEFINED;
  public float positionBottom = CSSConstants.UNDEFINED;
  public float positionLeft = CSSConstants.UNDEFINED;
  public float positionRight = CSSConstants.UNDEFINED;

  public float width = CSSConstants.UNDEFINED;
  public float height = CSSConstants.UNDEFINED;
}
