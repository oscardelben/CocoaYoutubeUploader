
#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"


@interface YoutubeUploader : NSObject {
    
    id delegate;
    
    NSString *source;
    NSString *devKey;
    NSString *path;
    NSString *email;
    NSString *password;
    NSString *slug;
    NSString *title;
    NSString *description;
    NSString *keywords;
    NSString *category;
    
    NSString *requestToken;
}

@property (assign) id delegate;

@property (retain) NSString *source;
@property (retain) NSString *devKey;
@property (retain) NSString *path;
@property (retain) NSString *email;
@property (retain) NSString *password;
@property (retain) NSString *slug;
@property (retain) NSString *title;
@property (retain) NSString *description;
@property (retain) NSString *keywords;
@property (retain) NSString *category;

- (void)startUpload;

- (void)requestFinished:(ASIHTTPRequest *)request;
- (void)requestFailed:(ASIHTTPRequest *)request;

@end
