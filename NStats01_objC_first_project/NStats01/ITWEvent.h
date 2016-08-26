//
//  ITWEvent.h
//  Stats
//
//  Created by Majkl on 10/06/14.
//  Copyright (c) 2014 Majkl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ITWEvent : NSObject

@property (nonatomic, strong) NSString *eventKey;
@property (nonatomic, strong) NSString *eventName;
@property (nonatomic, strong) NSString *eventLocation;
@property (nonatomic, strong) NSString *subjectName;
@property (nonatomic) int eventDate;
@property (nonatomic) int subjectDate;
@property (nonatomic) int dateCreated;
@property (nonatomic) int dateModified;
@property (nonatomic) double orderingValue;
@property (nonatomic, strong) NSString *customStat;


@end
