#include <iostream>
#include <fstream>
#include <cstring>
#include <cstdio>
#include <bitset>
using namespace std;

struct wav_struct
{
    unsigned long file_size;        //文件大小
    unsigned short channel;            //通道数
    unsigned long frequency;        //采样频率
    unsigned long Bps;                //Byte率
    unsigned short sample_num_bit;    //一个样本的位数
    unsigned long data_size;        //数据大小
    unsigned char *data;            //音频数据 ,这里要定义什么就看样本位数了，我这里只是单纯的复制数据

};

int main(int argc,char **argv)
{
    fstream fs;
    wav_struct WAV;
    fs.open("a.wav",ios::binary|ios::in);

    //    fs.seekg(0x04);                //从文件数据中获取文件大小
    //    fs.read((char*)&WAV.file_size,sizeof(WAV.file_size));
    //    WAV.file_size+=8;

    fs.seekg(0,ios::end);        //用c++常用方法获得文件大小
    WAV.file_size=fs.tellg();

    fs.seekg(0x14);
    fs.read((char*)&WAV.channel,sizeof(WAV.channel));

    fs.seekg(0x18);
    fs.read((char*)&WAV.frequency,sizeof(WAV.frequency));

    fs.seekg(0x1c);
    fs.read((char*)&WAV.Bps,sizeof(WAV.Bps));

    fs.seekg(0x22);
    fs.read((char*)&WAV.sample_num_bit,sizeof(WAV.sample_num_bit));

    fs.seekg(0x2a);
    fs.read((char*)&WAV.data_size,sizeof(WAV.data_size));



    cout<<"file size : "<<WAV.file_size<<endl;
    cout<<"channel : "<<WAV.channel<<endl;
    cout<<"frequency : "<<WAV.frequency<<endl;
    cout<<"Byte per second : "<<WAV.Bps<<endl;
    cout<<"sample num bit : "<<WAV.sample_num_bit<<endl;
    cout<<"data size : "<<WAV.data_size<<endl;

    cout << "all size : " <<  WAV.data_size / 3 << endl;

    WAV.data=new unsigned char[WAV.data_size];

    fs.seekg(0x2e);
    fs.read((char *)WAV.data,sizeof(char)*WAV.data_size);
    fs.close();

    FILE *fpw = fopen( "a.out" , "wb" );



    char a = 0;
    for (unsigned long i = 0 ;i < WAV.data_size; i++)
    {
        fwrite(&WAV.data[i], 1 , sizeof( unsigned char ) , fpw );
        if (i % 3 == 2){
            fwrite(&a, 1, sizeof(unsigned char), fpw);
        }
    }

    fclose( fpw );

    //===========================================================

    freopen("a.txt", "w", stdout);
    printf("WIDTH=24;\n");
    printf("DEPTH=%d;\n", WAV.data_size / 3);
    printf("\n");
    printf("ADDRESS_RADIX=UNS;\n");
    printf("DATA_RADIX=BIN;\n");
    printf("\n");
    printf("CONTENT BEGIN\n");

    int cnt = 0;
    int v;
    int wv;
    int cc;
    string buf = "";
    for (unsigned long i = 0 ;i < WAV.data_size; i++)
    {
        if (i % 3 == 0){
            printf("%d : ", cnt);
            cnt++;
            v = 0;
            wv = 1;
        }


        bitset<8> bb = bitset<sizeof(char)*8>(WAV.data[i]);
        for (int j = 0; j < 8; j++){
            if (bb.test(j)) {
                v += wv;
                buf = "1" + buf;
            }else buf = "0" + buf;
            wv = wv * 2;
            if (wv == (1 << 23)) wv = -wv;
            cc++;
        }
        if (i % 3 == 2){
            printf("%s;  --  ", buf.c_str());
            printf("%d\n", v);
            cc = 0;
            buf = "";
        }
    }

    printf("END;\n");


    fclose( fpw );


    delete[] WAV.data;

}
