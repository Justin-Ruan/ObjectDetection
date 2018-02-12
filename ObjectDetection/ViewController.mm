#import "ViewController.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1920x1080 cameraPosition:AVCaptureDevicePositionBack];
    videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    
    if([videoCamera.inputCamera lockForConfiguration:nil]){
        [videoCamera.inputCamera setExposureMode:AVCaptureExposureModeLocked];
        [videoCamera.inputCamera setWhiteBalanceMode:AVCaptureWhiteBalanceModeLocked];
        [videoCamera.inputCamera setFocusMode:AVCaptureFocusModeLocked];
        [videoCamera.inputCamera unlockForConfiguration];
    }
    cameraView = [[GPUImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height)];
    [self.view addSubview:cameraView];
    [self.view sendSubviewToBack:cameraView];
    
    blurFilter = [[GPUImageMedianFilter alloc] init];
    [blurFilter forceProcessingAtSize:cameraView.sizeInPixels];
    
    grayScaleFilter = [[GPUImageGrayscaleFilter alloc] init];
    [grayScaleFilter forceProcessingAtSize:cameraView.sizeInPixels];
    
    [grayScaleFilter addTarget:blurFilter];
    
    twoInputFilter = [[GPUImageTwoInputFilter alloc] initWithFragmentShaderFromFile:@"Shader1"];

    [videoCamera addTarget:grayScaleFilter];
    [videoCamera addTarget:cameraView];
    
    [videoCamera startCameraCapture];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)takePhoto:(id)sender {
    
    [blurFilter useNextFrameForImageCapture];
    UIImage *image = [blurFilter imageFromCurrentFramebuffer];
    backgroundImage = [[GPUImagePicture alloc] initWithImage:image];
    [videoCamera removeAllTargets];
    
    RenderRectangleFilter *renderRectangleFilter = [[RenderRectangleFilter alloc] init];
    [renderRectangleFilter setAttribure:cameraView.frame.size.height width:cameraView.frame.size.width margin:2];
    
    GPUImageRawDataOutput *rawDataOutput = [[GPUImageRawDataOutput alloc] initWithImageSize:backgroundImage.outputImageSize resultsInBGRAFormat:YES];
    
    [backgroundImage addTarget:twoInputFilter];
    [blurFilter addTarget:twoInputFilter];
    [videoCamera addTarget:grayScaleFilter];
    [twoInputFilter addTarget:rawDataOutput];
    
    [videoCamera addTarget:renderRectangleFilter];
    [renderRectangleFilter addTarget:cameraView];
    
    //[twoInputFilter addTarget:cameraView];
    [backgroundImage processImage];
    
    CGSize _size = [rawDataOutput maximumOutputSize];
    
    int col = _size.height;
    int row = _size.width;
    
    
    __unsafe_unretained GPUImageRawDataOutput * weakOutput = rawDataOutput;
    [rawDataOutput setNewFrameAvailableBlock:^{
        [weakOutput lockFramebufferForReading];
        GLubyte *outputBytes = [weakOutput rawBytesForImage];
        NSInteger bytesPerRow = [weakOutput bytesPerRowInOutput];
        int min_x = 10000;
        int min_y = 10000;
        int max_x = -1;
        int max_y = -1;
        for(int yIndex = 0; yIndex < col; yIndex++){
            for (int xIndex = 0; xIndex < row; xIndex++)
            {
                if(outputBytes[yIndex * bytesPerRow + xIndex * 4]==255 &&
                   outputBytes[yIndex * bytesPerRow + xIndex * 4+1]==255 &&
                   outputBytes[yIndex * bytesPerRow + xIndex * 4+2]==255 &&
                   outputBytes[yIndex * bytesPerRow + xIndex * 4+3]==255){
                    if(yIndex >= max_y){
                        max_y = yIndex;
                    }
                    if(xIndex >= max_x ){
                        max_x = xIndex;
                    }
                    if(yIndex <= min_y){
                        min_y = yIndex;
                    }
                    if(xIndex <= min_x ){
                        min_x = xIndex;
                    }
                }
            }
        }
        
       if(min_x != 10000 && min_y != 10000 && max_x != -1 && max_y != -1 ){
            GPUVector3 p1;
            p1.one = (float)min_x/(float)row;
            p1.two = (float)min_y/(float)col;
            p1.three = 0.0;
            GPUVector3 p2;
            p2.one = (float)max_x/(float)row;
            p2.two = (float)max_y/(float)col;
            p2.three = 0.0;
            
            [renderRectangleFilter setPoint:p1 p2:p2];
       }else if(min_x == 10000 && min_y == 10000 && max_x == -1 && max_y == -1){
           GPUVector3 p1;
           p1.one = 0.0;;
           p1.two = 0.0;;
           p1.three = 0.0;
           GPUVector3 p2;
           p2.one =  0.0;
           p2.two =  0.0;
           p2.three = 0.0;
           
           [renderRectangleFilter setPoint:p1 p2:p2];
       }
        
        [weakOutput unlockFramebufferAfterReading];
    }];
}



@end
