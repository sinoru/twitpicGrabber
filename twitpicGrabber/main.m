//
//  main.m
//  twitpicGrabber
//
//  Created by 재홍 강 on 11. 12. 11..
//  Copyright (c) 2011년 __MyCompanyName__. All rights reserved.
//

#import <math.h>
#import <Foundation/Foundation.h>

int main (int argc, const char * argv[])
{
    
    @autoreleasepool {
        
        // insert code here...
        char username[20];
        int picsNumber;
        NSLog(@"This application is twitpic grabber");
        NSLog(@"Please enter twitter user name");
        printf("Username: ");
        scanf("%19s", &username);
        NSLog(@"Please enter how many pics do you need from this user?");
        scanf("%d", &picsNumber);
        
        NSMutableArray *longIDArray = [[NSMutableArray alloc] init];
        NSMutableArray *shortIDArray = [[NSMutableArray alloc] init];
        NSMutableArray *imageTypeArray = [[NSMutableArray alloc] init];
        
        int pageCount;
        
        if (picsNumber < 20) {
            pageCount = 1;
        }
        else {
            pageCount = ceil(picsNumber / 20);
        }
        
        for (int i = 1; i <= pageCount; i++) {
            NSLog(@"Get image list from page %d... (%d/%d)", i, i, pageCount);
            NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://api.twitpic.com/2/users/show.json?username=%s&page=%d", username, i]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
            urlRequest.HTTPMethod = @"GET";
            
            NSData *responseData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:nil];
            
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONWritingPrettyPrinted error:nil];
            
            int lastPicsCount = 20;
            
            if (i == pageCount) {
                lastPicsCount = picsNumber % 20;
            }
            
            int j = 1;
            
            for (NSDictionary *imageDict in [responseDictionary objectForKey:@"images"]) {
                NSString *longID = [imageDict objectForKey:@"id"];
                [longIDArray addObject:longID];
                
                NSString *shortID = [imageDict objectForKey:@"short_id"];
                [shortIDArray addObject:shortID];
                
                NSString *type = [imageDict objectForKey:@"type"];
                [imageTypeArray addObject:type];
                
                if (j == lastPicsCount) {
                    break;
                }
                
                j++;
            }
        }
        
        NSString *imageSaveDirectoryPath = [NSString stringWithFormat:@"%@/twitpic/%s", [NSSearchPathForDirectoriesInDomains(NSPicturesDirectory, NSUserDomainMask, YES) objectAtIndex:0], username];
        if (![[NSFileManager defaultManager] fileExistsAtPath:imageSaveDirectoryPath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:imageSaveDirectoryPath
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:nil];
        }
        
        for (NSString *shortID in shortIDArray) {
            /*
            NSLog(@"Get full image URL for %@...", shortID);
            NSString *html = [[NSString alloc] initWithData:[[NSData alloc] initWithContentsOfURL:[[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://twitpic.com/%@/full", shortID]]] encoding:NSUTF8StringEncoding];
            NSString *imageURLString = [[[[[[html componentsSeparatedByString:@"<div style=\"padding-bottom:10px;\"><img src=\"/images/logo-main.png\"></div>"] objectAtIndex:1] componentsSeparatedByString:@"<img src=\""] objectAtIndex:1] componentsSeparatedByString:@"\" alt="] objectAtIndex:0];
            
            
             NSLog(@"Download image data for %@...", shortID);
             NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:imageURLString]];
            */
            
            NSLog(@"Download image data for %@... (%lu/%lu)", shortID, [shortIDArray indexOfObject:shortID] + 1, [shortIDArray count]);
            NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://twitpic.com/show/full/%@", shortID]]];
            
            NSString *path = [NSString stringWithFormat:@"%@/%@ (%@).%@", imageSaveDirectoryPath, [longIDArray objectAtIndex:[shortIDArray indexOfObject:shortID]], shortID, [imageTypeArray objectAtIndex:[shortIDArray indexOfObject:shortID]]];
            
            [imageData writeToFile:path atomically:YES];
        }
    }
    
    NSLog(@"Finished.");
    
    return 0;
}

