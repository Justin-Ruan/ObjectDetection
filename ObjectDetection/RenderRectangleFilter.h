#import "GPUImage.h"

@interface RenderRectangleFilter:GPUImageFilter{
    GLuint rectangleUniform1;
    GLuint rectangleUniform2;
    GLuint ratioxUniform;
    GLuint ratioyUniform;
    
    GPUVector3 p1;
    GPUVector3 p2;
    int width;
    int height;
    int margin;
    float ratio;
}
- (void)setPoint:(GPUVector3)point1 p2:(GPUVector3)point2;
- (void)setAttribure:(int)height width:(int)width margin:(int)margin;
@end
