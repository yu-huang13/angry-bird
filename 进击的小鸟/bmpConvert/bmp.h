#ifndef BMP_H
#define BMP_H

#include"color.h"
#include<string>
#include <bitset>

using std::bitset;
extern const double EPS;

typedef unsigned char byte;
typedef unsigned short word;
typedef unsigned int dword;

struct BITMAPFILEHEADER {
	dword bfSize;
	word bfReserved1;
	word bfReserved2;
	dword bfOffBits;
};

struct BITMAPINFOHEADER {
	dword biSize;
	long biWidth;
	long biHeight;
	word biPlanes;
	word biBitCount;
	dword biCompression;
	dword biSizeImage;
	long biXPelsPerMeter;
	long biYPelsPerMeter;
	dword biClrUsed;
	dword biClrImportant;
};

struct RGBQUAD {
	byte rgbBlue;
	byte rgbGreen;
	byte rgbRed;
	byte rgbReserved;
};

struct IMAGEDATA {
	byte red;
	byte green;
	byte blue;
	Color GetColor() {
		return Color( red , green , blue ) / 256;
	}
};

class Bmp {
	BITMAPFILEHEADER strHead;
	BITMAPINFOHEADER strInfo;
	bool ima_created;
	IMAGEDATA** ima;

	void Release();
	
public:
	Bmp( int H = 0 , int W = 0 );
	~Bmp();

	int GetH() { return strInfo.biHeight; }
	int GetW() { return strInfo.biWidth; }
	Color GetColor( int i , int j ) { return Color( ima[i][j].red , ima[i][j].green , ima[i][j].blue ) / 256; }
	void SetColor( int i , int j , Color );

	void Initialize( int H , int W );
	void Input( std::string file );
	void Output( std::string file );
    void OutputPixelBmp(std::string file, int rate);
    Color GetSmoothColor( double u , double v );
    void trans(FILE *fw, byte color);
    void change(byte color, int& num, std::bitset<32> &bb);
    void OutputMif(std::string file);
    void OutputData(std::string file);
};

#endif
