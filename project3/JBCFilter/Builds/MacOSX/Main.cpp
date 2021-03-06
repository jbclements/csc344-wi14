//
//  Main.cpp
//  JBCFilter
//
//  Created by John Clements on 2/10/14.
//
//

#include "Main.h"
#include "PluginProcessor.h"

#define BUFSIZE 1024
#define CHANNELS 2

int floatToS16Int(float f){
    return roundDoubleToInt(f*32767.0);
}

float floatToS16IntToFloat(float f){
    return (((double)floatToS16Int(f))/32767.0);
}

int main(int argc, const char * argv[])
{
    printf ("f2s(0.01) = %d\n",floatToS16Int(0.01));
    printf ("f2s2f(0.01) = %g\n",floatToS16IntToFloat(0.01));
    const double sampleRate = 44100.0;
    const double pitch = 800.0;
    JbcfilterAudioProcessor filter;
    AudioSampleBuffer buf(2,BUFSIZE);
    MidiBuffer midibuf;

    
    for (int i = 0; i < CHANNELS; i++) {
        float *lbuf = buf.getSampleData(i);
        for (int j = 0; j< BUFSIZE; j++) {
            lbuf[j] = floatToS16IntToFloat((double)(j%30) / 30.0); // 0.1 * sin((2*double_Pi/44100.0)*pitch*j);
        }
    }

    {
        std::cout << "pre-filter\n";
        float *resultBuf = buf.getSampleData(0);
        for (int i = 0; i < 20; i++) {
            std::cout << floatToS16Int(resultBuf[i]);
            std::cout << "\n";
        }
    }
    
    filter.setPlayConfigDetails(2, 2, sampleRate, BUFSIZE);
    filter.prepareToPlay(sampleRate,BUFSIZE);
    filter.processBlock(buf, midibuf);
    
    {
        std::cout << "post-filter\n";
        float *resultBuf = buf.getSampleData(0);
        for (int i = 0; i < 20; i++) {
            std::cout << floatToS16Int(resultBuf[i]);
            std::cout << "\n";
        }
    }
    
    // insert code here...
    std::cout << "Hello, World!\n";
    
    return 0;
}
