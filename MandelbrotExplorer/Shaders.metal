//
//  Shaders.metal
//  MandelbrotExplorer
//
//  Created by Jae Seung Lee on 6/2/20.
//  Copyright © 2020 Jae Seung Lee. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#define MIN(X, Y) (((X) < (Y)) ? (X) : (Y))

struct MandelBrot
{
    float zoom;
    float deltax;
    float deltay;
    float originx;
    float originy;
};

struct VertexIn {
    float4 position [[attribute(0)]];
    float2 texture [[attribute(1)]];
};

struct VertexOut {
    float4 position [[position]];
    float2 texture;
};

struct MandelbrotIn
{
    float real [[attribute(0)]];
    float imag [[attribute(0)]];
};

float4 HeatMapColor(float value, float minValue, float maxValue)
{
#define HEATMAP_COLORS_COUNT 6
    float4 colors[HEATMAP_COLORS_COUNT] =
    {
        float4(0.32, 0.00, 0.32, 1.00),
        float4(0.00, 0.00, 1.00, 1.00),
        float4(0.00, 1.00, 0.00, 1.00),
        float4(1.00, 1.00, 0.00, 1.00),
        float4(1.00, 0.60, 0.00, 1.00),
        float4(1.00, 0.00, 0.00, 1.00),
    };
    float ratio=(HEATMAP_COLORS_COUNT-1.0)*saturate((value-minValue)/(maxValue-minValue));
    int indexMin = floor(ratio);
    
    int indexMax = MIN(indexMin+1, HEATMAP_COLORS_COUNT-1);
    
    return colors[indexMin] + (colors[indexMax] - colors[indexMin]) * ratio-indexMin;
}

vertex VertexOut vertex_main(VertexIn vertexBuffer [[stage_in]]) {
    VertexOut out {
        .position = vertexBuffer.position,
        .texture = vertexBuffer.texture
        
    };
    return out;
}

fragment float4 fragment_main(VertexOut in [[stage_in]], constant MandelBrot &mandel [[buffer(0)]]) {
    float4 color = float4(0,0,0,1);
    
    float x = (mandel.originx + in.texture.x * (mandel.deltax) );
    float y = (mandel.originy + in.texture.y * (mandel.deltay) );
    
    /* initial value of orbit = critical point Z = 0 */
    float Zx=0.0;
    float Zy=0.0;
    float Zx2=Zx*Zx;
    float Zy2=Zy*Zy;
    /* */
    int iter = 0;
    for (iter=0;iter<200 && ((Zx2+Zy2)<4);iter++)
    {
        Zy=2*Zx*Zy + y;
        Zx=Zx2-Zy2 + x;
        Zx2=Zx*Zx;
        Zy2=Zy*Zy;
    }
    
    if (iter < 200)
    { /* exterior of Mandelbrot set = white or gradient of colors */
        
        float zn = sqrt( Zx2 + Zy2 );
        float nu = metal::log( log(zn) / log(2.0) ) / log(2.0);
        
        // Rearranging the potential function.
        // Could remove the sqrt and multiply log(zn) by 1/2, but less clear.
        // Dividing log(zn) by log(2) instead of log(N = 1<<8)
        // because we want the entire palette to range from the
        // center to radius 2, NOT our bailout radius.
        iter = iter + 1 - nu;
    }
    
    color = HeatMapColor(iter, 0.0, 60.0);
    
    return color;
    
}

kernel void sigmoid(const device float *inVector [[ buffer(0) ]],
                    device float *outVector [[ buffer(1) ]],
                    uint id [[ thread_position_in_grid ]]) {
    // This calculates sigmoid for _one_ position (=id) in a vector per call on the GPU
    outVector[id] = 1.0 / (1.0 + exp(-inVector[id]));
}

kernel void mandelbrot(texture2d<float, access::read> inTexture [[ texture(0) ]],
                       texture2d<float, access::write> outTexture [[ texture(1) ]],
                       uint2 id [[ thread_position_in_grid ]]) {
    // Check if the pixel is within the bounds of the output texture
    if((id.x >= outTexture.get_width()) || (id.y >= outTexture.get_height()))
    {
        // Return early if the pixel is out of bounds
        return;
    }
    
    float z_real = 0.0;
    float z_imag = 0.0;
    
    float4 z0 = inTexture.read(id);
    
    int iter = 0;
    for (iter = 0; iter<200 && ((z_real * z_real + z_imag * z_imag) < 4); iter++)
    {
        float new_real = z_real * z_real - z_imag * z_imag + z0.x;
        float new_imag = 2 * z_real * z_imag + z0.y;
        
        z_real = new_real;
        z_imag = new_imag;
    }
   
    float value = (iter == 200) ? 0 : (float(iter) / 200.0 * 255.0);
    outTexture.write(float4(value, 0, 0, 0), id);
}
