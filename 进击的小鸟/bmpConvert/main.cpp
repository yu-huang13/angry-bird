#include "bmp.h"
#include "color.h"

using namespace std;

int main()
{
    Bmp *bmp = new Bmp(10, 10);
    bmp->Input("a.bmp");
    bmp->OutputPixelBmp("b.bmp",3);
    //bmp->OutputMif("a.mif");
    bmp->OutputData("a.out");
}

