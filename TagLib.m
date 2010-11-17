//
//  TagLib.m
//  TagLibBundle
//
//  A simple Obj-C wrapper around the C functions that TagLib exposes
//
//  Created by Nick Ludlam on 21/07/2010.
//

#import "TagLib.h"
#include "tag_c.h"

// Required in order to be able to use #require in Ruby to load this bundle
void Init_TagLibBundle(void) { }

@implementation TagLib

@synthesize validTags, validAudioProperties;

@synthesize path;

@synthesize title;
@synthesize artist;
@synthesize album;
@synthesize comment;
@synthesize genre;
@synthesize track;
@synthesize year;

@synthesize length, sampleRate, bitRate;


- (NSString*)stringValueFor:(const char*) value {
    NSString *result = nil;
    
    if (value != NULL && strlen(value) > 0)
        result = [NSString stringWithUTF8String:value];
    
    return result;
}

-(NSNumber*)intValueFor:(unsigned int) value {
    NSNumber *result = nil;
    
    if (value > 0)
        result = [NSNumber numberWithUnsignedInt:value];
    
    return result;
}

- (id)initWithFileAtPath:(NSString *)filePath {
    if (self = [super init]) {

        // Initialisation as per the TagLib example C code
        TagLib_File *file;
        TagLib_Tag *tag;
        
        // We want UTF8 strings out of TagLib
        taglib_set_strings_unicode(TRUE);

        file = taglib_file_new([filePath cStringUsingEncoding:NSUTF8StringEncoding]);

        self.path = filePath;

        if (file != NULL) {
            tag = taglib_file_tag(file);
            
            if (tag != NULL) {
                // Collect title, artist, album, comment, genre, track and year in turn.
                // Sanity check them for presence, and length
                
                self.validTags = YES;
                
                self.title = [self stringValueFor: taglib_tag_title(tag)];
                self.artist = [self stringValueFor: taglib_tag_artist(tag)];
                self.album = [self stringValueFor: taglib_tag_album(tag)];
                self.comment = [self stringValueFor: taglib_tag_comment(tag)];
                self.genre = [self stringValueFor: taglib_tag_genre(tag)];
                self.year = [self intValueFor: taglib_tag_year(tag)];
                self.track = [self intValueFor: taglib_tag_track(tag)];
            } else {
                self.validTags = NO;
            }
            
            const TagLib_AudioProperties *properties = taglib_file_audioproperties(file);

            if (properties != NULL) {
                
                self.validAudioProperties = YES;

                if (taglib_audioproperties_length(properties) > 0) {
                    self.length = [NSNumber numberWithInt:taglib_audioproperties_length(properties)];
                }
            } else {
                self.validAudioProperties = NO;
            }
            
            // Free up our used memory so far
            taglib_tag_free_strings();
            taglib_file_free(file);
            
        }
    }
    
    return self;
}

@end
