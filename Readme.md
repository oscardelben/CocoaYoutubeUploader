### Youtube Uploader

This sample code contains a reusable class for uploading videos to Youtube from your Cocoa apps.

You'll need to include ASIHTTPRequest to use this project.

Usage is very simple, simply create an instance of YoutubeUploader, fill in its properties and then call startUpload to upload your video to youtube.

Youtube Uploader will call the following delegate methods if they exist:

    - (void)youtubeErrorReceived:(NSError *)error;
    - (void)youtubeUploadSuccessful:(NSString *)response;

License: MIT