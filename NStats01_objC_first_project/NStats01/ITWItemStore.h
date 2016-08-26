//
//  ITWItemStore.h
//  Stats
//
//  Created by Majkl on 29/05/14.
//  Copyright (c) 2014 Majkl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@class ITWEvent;

@interface ITWItemStore : NSObject

@property (nonatomic, readonly) NSArray *allEvents;
@property (nonatomic, assign) sqlite3 *eventDatabase;

+ (instancetype)sharedStore;
- (void)removeEvent:(ITWEvent *)event;
- (void)moveItemAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;

- (void)openDatabase;
- (void)closeDatabase;

- (void)addToEvent:(NSString *)eventKey eventName:(NSString *)eventName eventLocation:(NSString *)eventLocation eventDate:(NSUInteger)eventDate dateCreated:(NSUInteger)dateCreated dateModified:(NSUInteger)dateModified;

- (void)addToSubject:(NSString *)eventKey subjectName:(NSString *)subjectName dateCreated:(NSUInteger)dateCreated dateModified:(NSUInteger)dateModified;

- (void)addToStats:(NSString *)eventKey subjectName:(NSString *)subjectName statName:(NSString *)statName statValue:(NSUInteger)statValue dateCreated:(NSUInteger)dateCreated dateModified:(NSUInteger)dateModified;

- (void)updateStats:(NSString *)eventKey subjectName:(NSString *)subjectName statName:(NSString *)statName statValue:(NSUInteger)statValue dateModified:(NSUInteger)dateModified;

- (void)getStats:(NSString *)eventKey;

- (NSMutableDictionary *)statsAndValues;
- (NSArray *)loadEvents;
- (NSMutableDictionary *)loadStatsAndValues:(NSString *)eventKey;
- (void)deleteEvent:(NSString *)eventKey;
- (void)deleteStat:(NSString *)eventKey subjectName:(NSString *)subjectName statName:(NSString *)statName;
- (void)deleteStats:(NSString *)eventKey subjectName:(NSString *)subjectName;
- (void)deleteSubject:(NSString *)eventKey subjectName:(NSString *)subjectName;
- (NSString *)getStatValue:(NSString *)eventKey subjectName:(NSString *)subjectName statName:(NSString *)statName;
- (NSMutableArray *)loadStatsForSubject:(NSString *)eventKey subjectName:(NSString *)subjectName;
- (BOOL)getStat:(NSString *)eventKey subjectName:(NSString *)subjectName statName:(NSString *)statName;
- (NSMutableArray *)loadSubjects:(NSString *)eventKey;
- (void)updateEvent:(NSString *)eventKey eventName:(NSString *)eventName eventLocation:(NSString *)eventLocation eventDate:(NSUInteger)eventDate dateModified:(NSUInteger)dateModified;
- (void)updateSubject:(NSString *)eventKey subjectName:(NSString *)subjectName newSubjectName:(NSString *)newSubjectName dateModified:(NSUInteger)dateModified;
- (void)updateSubjectInStats:(NSString *)eventKey subjectName:(NSString *)subjectName newSubjectName:(NSString *)newSubjectName dateModified:(NSUInteger)dateModified;
- (BOOL)getEvent:(NSString *)eventName eventLocation:(NSString *)eventLocation eventDate:(NSUInteger)eventDate;
- (NSString *)getEventKey:(NSString *)eventName eventLocation:(NSString *)eventLocation eventDate:(NSUInteger)eventDate;
- (void)updateStatName:(NSString *)eventKey subjectName:(NSString *)subjectName newStatName:(NSString *)newStatName statName:(NSString *)statName dateModified:(NSUInteger)dateModified;

- (void)deleteAllEvents;

- (void)deleteAllSubjects;
- (void)deleteAllStats;

@end
