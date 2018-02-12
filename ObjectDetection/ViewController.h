#import <UIKit/UIKit.h>
#import "GPUImage.h"
#import "RenderRectangleFilter.h"


@interface ViewController : UIViewController
{
    GPUImagePicture *backgroundImage;
    GPUImageView *cameraView;
    GPUImageVideoCamera *videoCamera;
    GPUImageMedianFilter *blurFilter;
    GPUImageGrayscaleFilter *grayScaleFilter;
    GPUImageTwoInputFilter *twoInputFilter;
    BOOL isStartToDetect;
}

@property (weak, nonatomic) IBOutlet UIImageView *image_view;
@property (weak, nonatomic) IBOutlet UIButton *btn_record;

@end

