varying highp vec2 textureCoordinate;
varying highp vec2 textureCoordinate2;

uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture2;

void main()
{
    lowp vec3 tc = vec3(0.0, 0.0, 0.0);

    lowp vec3 texture1 = texture2D(inputImageTexture, textureCoordinate).rgb;
    lowp vec3 texture2 = texture2D(inputImageTexture2, textureCoordinate2).rgb;
    
    tc = abs(texture1-texture2);
    
    if(tc.r > 0.1 && tc.r <= 1.0){
        gl_FragColor = vec4(1.0,1.0,1.0, 1.0);
    }else{
        gl_FragColor = vec4(0.0,0.0,0.0, 1.0);
    }
   
}
