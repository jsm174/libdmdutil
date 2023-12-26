/*
 * Portions of this code was derived from DMDExt
 *
 * https://github.com/freezy/dmd-extensions/blob/master/LibDmd/Common/FrameUtil.cs
 */

#include "FrameUtil.h"

#include <iostream>
#include <sstream>
#include <iomanip>

namespace DMDUtil {

int FrameUtil::MapAdafruitIndex(int x, int y, int width, int height, int numLogicalRows)
{
   int logicalRowLengthPerMatrix = 32 * 32 / 2 / numLogicalRows;
   int logicalRow = y % numLogicalRows;
   int dotPairsPerLogicalRow = width * height / numLogicalRows / 2;
   int widthInMatrices = width / 32;
   int matrixX = x / 32;
   int matrixY = y / 32;
   int totalMatrices = width * height / 1024;
   int matrixNumber = totalMatrices - ((matrixY + 1) * widthInMatrices) + matrixX;
   int indexWithinMatrixRow = x % logicalRowLengthPerMatrix;
   int index = logicalRow * dotPairsPerLogicalRow
     + matrixNumber * logicalRowLengthPerMatrix + indexWithinMatrixRow;
   return index;
}

void FrameUtil::SplitIntoRgbPlanes(const uint16_t* rgb565, int rgb565Size, int width, int numLogicalRows, uint8_t* dest, ColorMatrix colorMatrix)
{
   int pairOffset = 16;
   int height = rgb565Size / width;
   int subframeSize = rgb565Size / 2;

   int r0 = 0, r1 = 0, g0 = 0, g1 = 0, b0 = 0, b1 = 0, inputIndex0, inputIndex1;
   uint16_t color0, color1;
   uint8_t dotPair;

   for (int x = 0; x < width; ++x) {
      for (int y = 0; y < height; ++y) {
         if (y % (pairOffset * 2) >= pairOffset)
            continue;
           
         inputIndex0 = y * width + x;
         inputIndex1 = (y + pairOffset) * width + x;

         color0 = rgb565[inputIndex0];
         color1 = rgb565[inputIndex1];

         switch (colorMatrix) {
            case ColorMatrix::Rgb:
               r0 = (color0 >> 13) & 0x7;
               g0 = (color0 >> 8) & 0x7;
               b0 = (color0 >> 2) & 0x7;
               r1 = (color1 >> 13) & 0x7;
               g1 = (color1 >> 8) & 0x7;
               b1 = (color1 >> 2) & 0x7;
               break;

            case ColorMatrix::Rbg:
               r0 = (color0 >> 13) & 0x7;
               b0 = (color0 >> 8) & 0x7;
               g0 = (color0 >> 2) & 0x7;
               r1 = (color1 >> 13) & 0x7;
               b1 = (color1 >> 8) & 0x7;
               g1 = (color1 >> 2) & 0x7;
               break;
         }

         for (int subframe = 0; subframe < 3; ++subframe) {
            dotPair =
               (r0 & 1) << 5 |
               (g0 & 1) << 4 |
               (b0 & 1) << 3 |
               (r1 & 1) << 2 |
               (g1 & 1) << 1 |
               (b1 & 1);
            int indexWithinSubframe = MapAdafruitIndex(x, y, width, height, numLogicalRows);
            int indexWithinOutput = subframe * subframeSize + indexWithinSubframe;
            dest[indexWithinOutput] = dotPair;
            r0 >>= 1;
            g0 >>= 1;
            b0 >>= 1;
            r1 >>= 1;
            g1 >>= 1;
            b1 >>= 1;
         }
      }
   }
}

float FrameUtil::CalcBrightness(float x)
{
   // function to improve the brightness with fx=ax²+bc+c, f(0)=0, f(1)=1, f'(1.1)=0
   return (-x * x + 2.1f * x) / 1.1f;
}

std::string FrameUtil::HexDump(const uint8_t* data, size_t size)
{
   const int bytesPerLine = 32;

   std::stringstream ss;

   for (size_t i = 0; i < size; i += bytesPerLine) {
      for (size_t j = i; j < i + bytesPerLine && j < size; ++j)
         ss << std::setw(2) << std::setfill('0') << std::hex << static_cast<int>(data[j]) << ' ';

      for (size_t j = i; j < i + bytesPerLine && j < size; ++j) {
         char ch = data[j];
         if (ch < 32 || ch > 126)
             ch = '.';
         ss << ch;
      }

      ss << std::endl;
   }

   return ss.str();
}

}