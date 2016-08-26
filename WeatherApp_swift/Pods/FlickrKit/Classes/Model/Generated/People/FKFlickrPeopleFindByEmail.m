//
//  FKFlickrPeopleFindByEmail.m
//  FlickrKit
//
//  Generated by FKAPIBuilder.
//  Copyright (c) 2013 DevedUp Ltd. All rights reserved. http://www.devedup.com
//
//  DO NOT MODIFY THIS FILE - IT IS MACHINE GENERATED


#import "FKFlickrPeopleFindByEmail.h" 

@implementation FKFlickrPeopleFindByEmail



- (BOOL) needsLogin {
    return NO;
}

- (BOOL) needsSigning {
    return NO;
}

- (FKPermission) requiredPerms {
    return -1;
}

- (NSString *) name {
    return @"flickr.people.findByEmail";
}

- (BOOL) isValid:(NSError **)error {
    BOOL valid = YES;
	NSMutableString *errorDescription = [[NSMutableString alloc] initWithString:@"You are missing required params: "];
	if(!self.find_email) {
		valid = NO;
		[errorDescription appendString:@"'find_email', "];
	}

	if(error != NULL) {
		if(!valid) {	
			NSDictionary *userInfo = @{NSLocalizedDescriptionKey: errorDescription};
			*error = [NSError errorWithDomain:FKFlickrKitErrorDomain code:FKErrorInvalidArgs userInfo:userInfo];
		}
	}
    return valid;
}

- (NSDictionary *) args {
    NSMutableDictionary *args = [NSMutableDictionary dictionary];
	if(self.find_email) {
		[args setValue:self.find_email forKey:@"find_email"];
	}

    return [args copy];
}

- (NSString *) descriptionForError:(NSInteger)error {
    switch(error) {
		case FKFlickrPeopleFindByEmailError_UserNotFound:
			return @"User not found";
		case FKFlickrPeopleFindByEmailError_InvalidAPIKey:
			return @"Invalid API Key";
		case FKFlickrPeopleFindByEmailError_ServiceCurrentlyUnavailable:
			return @"Service currently unavailable";
		case FKFlickrPeopleFindByEmailError_WriteOperationFailed:
			return @"Write operation failed";
		case FKFlickrPeopleFindByEmailError_FormatXXXNotFound:
			return @"Format \"xxx\" not found";
		case FKFlickrPeopleFindByEmailError_MethodXXXNotFound:
			return @"Method \"xxx\" not found";
		case FKFlickrPeopleFindByEmailError_InvalidSOAPEnvelope:
			return @"Invalid SOAP envelope";
		case FKFlickrPeopleFindByEmailError_InvalidXMLRPCMethodCall:
			return @"Invalid XML-RPC Method Call";
		case FKFlickrPeopleFindByEmailError_BadURLFound:
			return @"Bad URL found";
  
		default:
			return @"Unknown error code";
    }
}

@end
