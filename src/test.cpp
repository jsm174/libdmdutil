#include "DMDUtil/DMDUtil.h"

#include <chrono>
#include <thread>

void DMDUTILCALLBACK LogCallback(const char* format, va_list args)
{
   char buffer[1024];
   vsnprintf(buffer, sizeof(buffer), format, args);
   printf("%s\n", buffer);
}

uint8_t* CreateImage(int depth)
{
   uint8_t* pImage = (uint8_t*)malloc(128 * 32);
   int pos = 0;
   for (int y = 0; y < 32; ++y) {
     for (int x = 0; x < 128; ++x)
       pImage[pos++] = x % ((depth == 2) ? 4 : 16);
   }

   return pImage;
}

uint8_t* CreateImageRGB24()
{
   uint8_t* pImage = (uint8_t*)malloc(128 * 32 * 3);
   for (int y = 0; y < 32; ++y) {
     for (int x = 0; x < 128; ++x) {
       int index = (y * 128 + x) * 3;
       pImage[index++] = (uint8_t)(255 * x / 128);
       pImage[index++] = (uint8_t)(255 * y / 32);
       pImage[index] = (uint8_t)(128);
     }
   }

   return pImage;
}

int main(int argc, const char* argv[]) {
   DMDUtil::Config* pConfig = DMDUtil::Config::GetInstance();
   pConfig->SetLogCallback(LogCallback);

   DMDUtil::DMD* pDmd = new DMDUtil::DMD(128, 32);

   printf("Finding displays...\n");

   while (pDmd->IsFinding())
      std::this_thread::sleep_for(std::chrono::milliseconds(100));

   if (!pDmd->HasDisplay()) {
      printf("No displays to render.\n");
      delete pDmd;
      return 1;
   }

   printf("Rendering...\n");

   uint8_t* pImage2 = CreateImage(2);
   uint8_t* pImage4 = CreateImage(4);
   uint8_t* pImage24 = CreateImageRGB24();

   for (int i = 0; i < 4; i++) {
      pDmd->UpdateData(pImage2, 2, 255, 0, 0);
      std::this_thread::sleep_for(std::chrono::milliseconds(200));

      pDmd->UpdateData(pImage2, 2, 0, 255, 0);
      std::this_thread::sleep_for(std::chrono::milliseconds(200));

      pDmd->UpdateData(pImage2, 2, 0, 0, 255);
      std::this_thread::sleep_for(std::chrono::milliseconds(200));

      pDmd->UpdateData(pImage2, 2, 255, 255, 255);
      std::this_thread::sleep_for(std::chrono::milliseconds(200));

      pDmd->UpdateData(pImage4, 4, 255, 0, 0);
      std::this_thread::sleep_for(std::chrono::milliseconds(200));

      pDmd->UpdateData(pImage4, 4, 0, 255, 0);
      std::this_thread::sleep_for(std::chrono::milliseconds(200));

      pDmd->UpdateData(pImage4, 4, 0, 0, 255);
      std::this_thread::sleep_for(std::chrono::milliseconds(200));

      pDmd->UpdateData(pImage4, 4, 255, 255, 255);
      std::this_thread::sleep_for(std::chrono::milliseconds(200));

      pDmd->UpdateRGB24Data(pImage24, 24, 0, 0, 0);
      std::this_thread::sleep_for(std::chrono::milliseconds(200));
   }

   printf("Finished rendering\n");

   free(pImage2);
   free(pImage4);
   free(pImage24);

   delete pDmd;

   return 0;
}