
#import "YoutubeUploader.h"

@implementation YoutubeUploader

@synthesize delegate;
@synthesize source, devKey, path, email, password, slug, title, description, category, keywords;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [source release];
    [devKey release];
    [path release];
    [email release];
    [password release];
    [slug release];
    [title release];
    [description release];
    [category release];
    [keywords release];
    
    [requestToken release];
    [super dealloc];
}

#pragma mark -

- (void)fetchRequestToken
{
    NSURL *authTokenUrl = [NSURL URLWithString:@"https://www.google.com/accounts/ClientLogin"];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:authTokenUrl];
    request.delegate = self;
    
    [request setRequestMethod:@"POST"];
    
    [request setPostValue:email forKey:@"Email"];
    [request setPostValue:password forKey:@"Passwd"];
    [request setPostValue:kYoutubeService forKey:@"service"];
    [request setPostValue:source forKey:@"source"];
    
    [request startAsynchronous];
}

- (NSString *)xmlPayload {
    NSString *payLoad = [NSString stringWithFormat:@"<?xml version=\"1.0\"?>"
                         "<entry xmlns=\"http://www.w3.org/2005/Atom\" xmlns:media=\"http://search.yahoo.com/mrss/\" xmlns:yt=\"http://gdata.youtube.com/schemas/2007\">"
                         "<media:group><media:title type=\"plain\"><![CDATA[%@]]></media:title>"
                         "<media:description type=\"plain\"><![CDATA[%@]]></media:description>"
                         "<media:category scheme=\"http://gdata.youtube.com/schemas/2007/categories.cat\"><![CDATA[%@]]></media:category>"
                         "<media:keywords><![CDATA[%@]]></media:keywords>"
                         "</media:group></entry>", title, description, category, keywords];
    return payLoad;
}

- (void)performUpload
{
    NSURL *uploadUrl = [NSURL URLWithString:@"http://uploads.gdata.youtube.com/feeds/api/users/default/uploads"];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:uploadUrl];
    request.delegate = self;
    
    [request setRequestMethod:@"POST"];
    
    // Add headers
    [request addRequestHeader:@"Host" value:@"uploads.gdata.youtube.com"];
    
    NSString *authorization = [NSString stringWithFormat:@"GoogleLogin auth=%@", requestToken];
    [request addRequestHeader:@"Authorization" value:authorization];
    [request addRequestHeader:@"X-GData-Key" value:[NSString stringWithFormat:@"key=%@", devKey]];
    
    [request addRequestHeader:@"GData-Version" value:@"2"];
    [request addRequestHeader:@"Slug" value:slug];
    [request addRequestHeader:@"Connection" value:@"close"];
    
    NSString *xml = [self xmlPayload];
    
    [request setData:[xml dataUsingEncoding:NSUTF8StringEncoding] withFileName:@"xml" andContentType:@"application/atom+xml" forKey:@"xml"];
    
    [request setFile:path forKey:@"video"]; 
    
    [request buildPostBody]; //Force the request to build the post body first 
    
    [request addRequestHeader:@"Content-Type" value:[NSString stringWithFormat:@"multipart/related; boundary=%@", kYoutubeBoundary]]; 
    
    [request startAsynchronous];
}

- (void)extractRequestToken:(NSString *)response
{
    NSRange range = [response rangeOfString:@"Auth="];
    
    if (range.location != NSNotFound) 
    {
        NSString *auth = [response substringFromIndex:(range.location + range.length)];
        requestToken = [auth stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];

        [self performUpload];
    }
    else
    {
        if ([[self delegate] respondsToSelector:@selector(youtubeErrorReceived:)]) 
        {
            [[self delegate] performSelector:@selector(youtubeErrorReceived:) withObject:nil];
        }
    }
}

- (void)extractResponse:(NSString *)response
{
    // Check if we got a valid response
    NSRange range = [response rangeOfString:@"<?xml version"];
    
    if (range.location != NSNotFound)
    {
        if ([[self delegate] respondsToSelector:@selector(youtubeUploadSuccessful:)]) 
        {
            [[self delegate] performSelector:@selector(youtubeUploadSuccessful:) withObject:response];
        }
    }
    else
    {
        if ([[self delegate] respondsToSelector:@selector(youtubeErrorReceived:)]) 
        {
            [[self delegate] performSelector:@selector(youtubeErrorReceived:) withObject:nil];
        }
    }
}

#pragma mark -

- (void)startUpload
{
    [self fetchRequestToken];
}


#pragma mark -

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSString *response = [request responseString];
    
    if (requestToken) 
    {
        [self extractResponse:response];
    }
    else
    {
        [self extractRequestToken:response];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    
    if ([[self delegate] respondsToSelector:@selector(youtubeErrorReceived:)]) 
    {
        [[self delegate] performSelector:@selector(youtubeErrorReceived:) withObject:error];
    }
}



@end
