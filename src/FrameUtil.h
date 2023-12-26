/*
 * Portions of this code was derived from DMDExt
 *
 * https://github.com/freezy/dmd-extensions/blob/master/LibDmd/Common/FrameUtil.cs
 */

#pragma once

#include <cstdint>
#include <string>

namespace DMDUtil {

enum class ColorMatrix {
    Rgb,
    Rbg
};

class FrameUtil {
public:
   static int MapAdafruitIndex(int x, int y, int width, int height, int numLogicalRows);
   static void SplitIntoRgbPlanes(const uint16_t* rgb565, int rgb565Size, int width, int numLogicalRows, uint8_t* dest, ColorMatrix colorMatrix = ColorMatrix::Rgb);
   static float CalcBrightness(float x);
   static std::string HexDump(const uint8_t* data, size_t size);
};

}