#import <Foundation/Foundation.h>
#import "RenderRectangleFilter.h"
NSString *const kGPUImageRenderRectangleFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform lowp vec3 point1;
 uniform lowp vec3 point2;
 uniform lowp float ratiox;
 uniform lowp float ratioy;
 
 void main()
 {
     lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     
     
     if(textureCoordinate.x >= point1.x && textureCoordinate.x <= point2.x && textureCoordinate.y >= point1.y && textureCoordinate.y <= (point1.y+ratioy)){
         gl_FragColor = vec4(0.0,1.0,0.0,textureColor.w);
     }else if(textureCoordinate.x >= point1.x && textureCoordinate.x <= point2.x && textureCoordinate.y <= point2.y && textureCoordinate.y >= (point2.y-ratioy)){
         gl_FragColor = vec4(0.0,1.0,0.0,textureColor.w);
     }else if(textureCoordinate.x >= point1.x && textureCoordinate.x <= (point1.x+ratiox) && textureCoordinate.y >= point1.y && textureCoordinate.y <= point2.y){
         gl_FragColor = vec4(0.0,1.0,0.0,textureColor.w);
     }else if(textureCoordinate.x <= point2.x && textureCoordinate.x >= (point2.x-ratiox) && textureCoordinate.y >= point1.y && textureCoordinate.y <= point2.y){
         gl_FragColor = vec4(0.0,1.0,0.0,textureColor.w);
     }else{
     
         gl_FragColor = textureColor;
     }
 }
 );

@interface RenderRectangleFilter ()

@end

@implementation RenderRectangleFilter


- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageRenderRectangleFragmentShaderString]))
    {
        return nil;
    }
    
    rectangleUniform1 = [filterProgram uniformIndex:@"point1"];
    rectangleUniform2 = [filterProgram uniformIndex:@"point2"];
    ratioxUniform = [filterProgram uniformIndex:@"ratiox"];
    ratioyUniform = [filterProgram uniformIndex:@"ratioy"];
    
    height = 1920;
    width = 1080;
    margin = 2;
    
    return self;
}

- (void)setPoint:(GPUVector3)point1 p2:(GPUVector3)point2;
{
    p1 = point1;
    p2 = point2;
    [self setVec3:p1 forUniform:rectangleUniform1 program:filterProgram];
    [self setVec3:p2 forUniform:rectangleUniform2 program:filterProgram];
}
- (void)setAttribure:(int)_height width:(int)_width margin:(int)_margin;
{
    height = _height;
    width = _width;
    margin = _margin;
    
    float ratiox = (float)margin/(float)width;
    float ratioy = (float)margin/(float)height;
    
    [self setFloat:ratiox forUniform:ratioxUniform program:filterProgram];
    [self setFloat:ratioy forUniform:ratioyUniform program:filterProgram];
    
}

@end
