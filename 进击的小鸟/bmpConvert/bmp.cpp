#include"bmp.h"
#include<cstdio>
#include<fstream>
#include<iostream>
#include<string>
#include<cmath>

using namespace std;

Bmp::Bmp( int H , int W ) {
    Initialize( H , W );
}

Bmp::~Bmp() {
    Release();
}

void Bmp::Initialize( int H , int W ) {
    strHead.bfReserved1 = 0;
    strHead.bfReserved2 = 0;
    strHead.bfOffBits = 54;

    strInfo.biSize = 40;
    strInfo.biPlanes = 1;
    strInfo.biHeight = H;
    strInfo.biWidth = W;
    strInfo.biBitCount = 24;
    strInfo.biCompression = 0;
    strInfo.biSizeImage = H * W * 3;
    strInfo.biXPelsPerMeter = 0;
    strInfo.biYPelsPerMeter = 0;
    strInfo.biClrUsed = 0;
    strInfo.biClrImportant = 0;

    strHead.bfSize = strInfo.biSizeImage + strInfo.biBitCount;

    ima = new IMAGEDATA*[H];
    for ( int i = 0 ; i < H ; i++ )
        ima[i] = new IMAGEDATA[W];
}

void Bmp::Release() {
    for ( int i = 0 ; i < strInfo.biHeight ; i++ )
        delete[] ima[i];

    delete[] ima;
}

void Bmp::Input( std::string file ) {
    Release();
    FILE *fpi = fopen( file.c_str() , "rb" );
    word bfType;
    fread( &bfType , 1 , sizeof( word ) , fpi );
    fread( &strHead , 1 , sizeof( BITMAPFILEHEADER ) , fpi );
    fread( &strInfo , 1 ,  sizeof( BITMAPINFOHEADER ), fpi );
    if (strInfo.biBitCount != 24){
        printf("error ,the bit count is not equal to 24!!\n");
    }
    RGBQUAD Pla;
    for ( int i = 0 ; i < ( int ) strInfo.biClrUsed ; i++ ) {
        fread( ( char * ) & ( Pla.rgbBlue ) , 1 , sizeof( byte ) , fpi );
        fread( ( char * ) & ( Pla.rgbGreen ) , 1 , sizeof( byte ) , fpi );
        fread( ( char * ) & ( Pla.rgbRed ) , 1 , sizeof( byte ) , fpi );
    }

    Initialize( strInfo.biHeight , strInfo.biWidth );
    int pitch = strInfo.biWidth % 4;
    for(int i = 0 ; i < strInfo.biHeight ; i++ ) {
        for(int j = 0 ; j < strInfo.biWidth ; j++ ) {
            fread( &ima[i][j].blue , 1 , sizeof( byte ) , fpi );
            fread( &ima[i][j].green , 1 , sizeof( byte ) , fpi );
            fread( &ima[i][j].red , 1 , sizeof( byte ) , fpi );
        }
        byte buffer = 0;
        for (int j = 0; j < pitch; j++)
            fread( &buffer , 1 , sizeof( byte ) , fpi );
    }
    fclose( fpi );
}

void Bmp::Output( std::string file ) {
    FILE *fpw = fopen( file.c_str() , "wb" );

    word bfType = 0x4d42;
    fwrite( &bfType , 1 , sizeof( word ) , fpw );
    fwrite( &strHead , 1 , sizeof( BITMAPFILEHEADER ) , fpw );
    fwrite( &strInfo , 1 , sizeof( BITMAPINFOHEADER ) , fpw );

    int pitch = strInfo.biWidth % 4;
    for ( int i = 0 ; i < strInfo.biHeight ; i++ ) {
        for ( int j = 0 ; j < strInfo.biWidth ; j++ ) {
            fwrite( &ima[i][j].blue , 1 , sizeof( byte ) , fpw );
            fwrite( &ima[i][j].green , 1 , sizeof( byte ) , fpw );
            fwrite( &ima[i][j].red , 1 , sizeof( byte ) , fpw );
        }
        byte buffer = 0;
        for (int j = 0; j < pitch; j++)
            fwrite( &buffer , 1 , sizeof( byte ) , fpw );
    }

    fclose( fpw );
}

void Bmp::OutputPixelBmp(string file, int rate)
{
    FILE *fpw = fopen( file.c_str() , "wb" );

    word bfType = 0x4d42;
    fwrite( &bfType , 1 , sizeof( word ) , fpw );
    fwrite( &strHead , 1 , sizeof( BITMAPFILEHEADER ) , fpw );
    fwrite( &strInfo , 1 , sizeof( BITMAPINFOHEADER ) , fpw );

    int pitch = strInfo.biWidth % 4;
    for ( int i = 0 ; i < strInfo.biHeight ; i++ ) {
        for ( int j = 0 ; j < strInfo.biWidth ; j++ ) {
            int ii = i /rate * rate;
            int jj = j /rate * rate;
            Color pp = Color(0,0,0);
            for (int ti = 0; ti < rate; ti++){
                for (int tj = 0; tj < rate; tj++){
                    pp = pp + ima[ii + ti][jj + tj].GetColor();
                }
            }
            pp /= rate * rate;
            SetColor(i, j, pp);
            fwrite( &ima[i][j].blue , 1 , sizeof( byte ) , fpw );
            fwrite( &ima[i][j].green , 1 , sizeof( byte ) , fpw );
            fwrite( &ima[i][j].red , 1 , sizeof( byte ) , fpw );
        }
        byte buffer = 0;
        for (int j = 0; j < pitch; j++)
            fwrite( &buffer , 1 , sizeof( byte ) , fpw );
    }

    fclose( fpw );
}


void Bmp::trans(FILE* fw, byte color){
    color = 1.0 * color / 256 * 8;
    int a[3] = {0, 0, 0};
    for(int i = 2; color != 0;i--){
        a[i] = color % 2;
        color = color / 2;
    }
    for(int i = 0; i < 3; i++)
        fprintf(fw, "%d", a[i]);
}

void Bmp::change(byte color, int& num, std::bitset<32> &bb)
{
    color = 1.0 * color / 256 * 8;
    bool a[3] = {0, 0, 0};
    for(int i = 2; color != 0;i--){
        a[i] = color % 2;
        color = color / 2;
    }
    for(int i = 0; i < 3; i++){
        bb.set(num, a[i]);
        num--;
    }
}

void Bmp::OutputMif(std::string file)
{
    FILE *fw = fopen(file.c_str(), "w");
    fprintf(fw, "WIDTH=9;\n");
    fprintf(fw, "DEPTH=%d;\n", strInfo.biHeight * strInfo.biWidth);
    fprintf(fw, "\n");
    fprintf(fw, "ADDRESS_RADIX=UNS;\n");
    fprintf(fw, "DATA_RADIX=BIN;\n");
    fprintf(fw, "\n");
    fprintf(fw, "CONTENT BEGIN\n");
    int cnt = 0;
    cout << strInfo.biHeight << endl;
    cout << strInfo.biWidth << endl;
    for ( int i = strInfo.biHeight - 1 ; i >= 0 ; i-- )
        for ( int j = 0 ; j < strInfo.biWidth ; j++ ) {
            fprintf(fw, "%d : ", cnt);
            cnt++;
            //fprintf(fw, "%d %d %d\n", ima[i][j].red, ima[i][j].green ,ima[i][j].blue);
            trans(fw, ima[i][j].red);
            trans(fw, ima[i][j].green);
            trans(fw, ima[i][j].blue);
            fprintf(fw, ";\n");
        }
    fprintf(fw, "END;\n");
    fclose( fw );
}

void Bmp::OutputData(string file)
{
    FILE *fw = fopen(file.c_str(), "wb+");
    int cnt = 0;
    bitset<32> bb;
    int ccc;
    int a;
    for ( int i = strInfo.biHeight - 1 ; i >= 0 ; i-- ){
        for ( int j = 0 ; j < strInfo.biWidth ; j++ ) {
            int num = 8;
            change(ima[i][j].red, num, bb);
            change(ima[i][j].green, num, bb);
            change(ima[i][j].blue, num, bb);
            for (int k = 31; k > 8; k--){
                bb[k] = 0;
            }
            a = bb.to_ulong();
            fwrite(&a , 1 , sizeof(int) , fw );
        }
    }
    fclose( fw );
}

void Bmp::SetColor( int i , int j , Color col ) {
    ima[i][j].red = ( int ) ( col.r * 255 );
    ima[i][j].green = ( int ) ( col.g * 255 );
    ima[i][j].blue = ( int ) ( col.b * 255 );
}

Color Bmp::GetSmoothColor( double u , double v ) {
    double U = ( u - floor( u ) ) * strInfo.biHeight;
    double V = ( v - floor( v ) ) * strInfo.biWidth;
    int U1 = ( int ) floor( U + EPS ) , U2 = U1 + 1;
    int V1 = ( int ) floor( V + EPS ) , V2 = V1 + 1;
    double rat_U = U2 - U;
    double rat_V = V2 - V;
    if ( U1 < 0 ) U1 = strInfo.biHeight - 1; if ( U2 == strInfo.biHeight ) U2 = 0;
    if ( V1 < 0 ) V1 = strInfo.biWidth - 1; if ( V2 == strInfo.biWidth ) V2 = 0;
    Color ret;
    ret = ret + ima[U1][V1].GetColor() * rat_U * rat_V;
    ret = ret + ima[U1][V2].GetColor() * rat_U * ( 1 - rat_V );
    ret = ret + ima[U2][V1].GetColor() * ( 1 - rat_U ) * rat_V;
    ret = ret + ima[U2][V2].GetColor() * ( 1 - rat_U ) * ( 1 - rat_V );
    return ret;
}
