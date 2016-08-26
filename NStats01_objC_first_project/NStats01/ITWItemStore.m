//
//  ITWItemStore.m
//  Stats
//
//  Created by Majkl on 29/05/14.
//  Copyright (c) 2014 Majkl. All rights reserved.
//

#import "ITWItemStore.h"
#import "ITWEvent.h"
#import "ITWAppDelegate.h"

@interface ITWItemStore ()

@property (nonatomic) NSMutableArray *privateEvents;

@end

@implementation ITWItemStore

+ (instancetype)sharedStore
{
    static ITWItemStore *sharedStore = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStore = [[self alloc] initPrivate];
    });
    
    return sharedStore;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Singleton" reason:@"Use +[ITWItemStore sharedStore]" userInfo:nil];
}

- (instancetype)initPrivate
{
    self = [super init];
    if (self) {
 
        [self copyDatabaseToDocDirectory];
    }
    return self;
}

- (void)copyDatabaseToDocDirectory
{
    NSFileManager *fileMan = [NSFileManager defaultManager];
    NSError *error;
    // Get the path to the database in the documents directory
    NSArray *allPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [allPaths objectAtIndex:0];
    NSString *dbPath = [docPath stringByAppendingPathComponent:@"stats.sql"];
    // Does the database exist in the documents directory?
    if (![fileMan fileExistsAtPath:dbPath]) {
        // If not, copy the file:
        NSString *bundlePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"stats.sql"];
        if (![fileMan copyItemAtPath:bundlePath toPath:dbPath error:&error]) {
            //NSLog(@"Database file could not be copied to documents path: %@", error.localizedDescription);
        } else {
            //NSLog(@"DB copied...");
        }
    } else {
        //NSLog(@"File exists at path %@", dbPath);
    }
}

- (void)test
{
    NSLog(@"This is the ITWItemStore");
}

- (void)openDatabase
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"stats.sql"];
    
    sqlite3 *connection;
    if (sqlite3_open([path UTF8String], &connection) != SQLITE_OK) {
        NSLog(@"Cannot open database!");
    }
    self.eventDatabase = connection;
}

- (void)closeDatabase
{
    sqlite3_close(self.eventDatabase);
    self.eventDatabase = nil;
}

- (void)addToEvent:(NSString *)eventKey eventName:(NSString *)eventName eventLocation:(NSString *)eventLocation eventDate:(NSUInteger)eventDate dateCreated:(NSUInteger)dateCreated dateModified:(NSUInteger)dateModified
{
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO Event (eventKey, eventName, eventLocation, eventDate, dateCreated, dateModified) VALUES (\"%@\", \"%@\", \"%@\", %lu, %lu, %lu)", eventKey, eventName, eventLocation, (unsigned long)eventDate, (unsigned long)dateCreated, (unsigned long)dateModified];
    
    sqlite3_stmt *insert;
    int result = sqlite3_prepare_v2(self.eventDatabase, [sql UTF8String], -1, &insert, NULL);
    if (result == SQLITE_OK) {
        sqlite3_step(insert);
    } else {
        NSLog(@"Error: insert prepare statement failed: %s", sqlite3_errmsg(self.eventDatabase));
    }
    sqlite3_finalize(insert);
}

- (NSArray *)loadEvents
{
    NSMutableArray *eventArray = [[NSMutableArray alloc] init];
    NSString *sql = @"SELECT eventKey, eventName, eventLocation, eventDate, dateCreated FROM Event ORDER BY dateCreated DESC;";

    sqlite3_stmt *select;
    int result = sqlite3_prepare_v2(self.eventDatabase, [sql UTF8String], -1, &select, NULL);

    if (result == SQLITE_OK) {

        while (sqlite3_step(select) == SQLITE_ROW) {
            
            ITWEvent *event = [[ITWEvent alloc] init];
            
            char *data1 = (char *) sqlite3_column_text(select, 0);
            event.eventKey = [NSString stringWithUTF8String:data1];
            
            char *data2 = (char *) sqlite3_column_text(select, 1);
            event.eventName = [NSString stringWithUTF8String:data2];
            
            char *data3 = (char *) sqlite3_column_text(select, 2);
            event.eventLocation = [NSString stringWithUTF8String:data3];
            
            event.eventDate = sqlite3_column_int(select, 3);            
            event.dateCreated = sqlite3_column_int(select, 4);

            // Add the Event
            [eventArray addObject:event];
        }
        sqlite3_finalize(select);
    }
    self.privateEvents = eventArray;
    return eventArray;
}

- (NSMutableArray *)loadSubjects:(NSString *)eventKey
{
    NSMutableArray *subjectArray = [[NSMutableArray alloc] init];
    NSString *sql = [NSString stringWithFormat:@"SELECT subjectName FROM Subject WHERE eventKey = \"%@\" ORDER BY dateCreated ASC;", eventKey];
    
    sqlite3_stmt *select;
    int result = sqlite3_prepare_v2(self.eventDatabase, [sql UTF8String], -1, &select, NULL);
    
    if (result == SQLITE_OK) {
        
        while (sqlite3_step(select) == SQLITE_ROW) {
            
            // Get subjectName
            char *data1 = (char *) sqlite3_column_text(select, 0);
            [subjectArray addObject:[NSString stringWithUTF8String:data1]];

        }
        sqlite3_finalize(select);
    }
    return subjectArray;
}

- (void)updateEvent:(NSString *)eventKey eventName:(NSString *)eventName eventLocation:(NSString *)eventLocation eventDate:(NSUInteger)eventDate dateModified:(NSUInteger)dateModified
{
    NSString *sql = [NSString stringWithFormat:@"UPDATE Event SET eventName = \"%@\", eventLocation = \"%@\", eventDate = %lu, dateModified = %lu WHERE eventKey = \"%@\";", eventName, eventLocation, (unsigned long)eventDate, (unsigned long)dateModified, eventKey];
    
    sqlite3_stmt *update;
    int result = sqlite3_prepare_v2(self.eventDatabase, [sql UTF8String], -1, &update, NULL);
    if (result == SQLITE_OK) {
        sqlite3_step(update);
    } else {
        NSLog(@"Error: update prepare statement failed: %s", sqlite3_errmsg(self.eventDatabase));
    }
    sqlite3_finalize(update);
}

- (void)updateSubject:(NSString *)eventKey subjectName:(NSString *)subjectName newSubjectName:(NSString *)newSubjectName dateModified:(NSUInteger)dateModified
{
    NSString *sql = [NSString stringWithFormat:@"UPDATE Subject SET subjectName = \"%@\", dateModified = %lu WHERE (eventKey = \"%@\" and subjectName = \"%@\");", newSubjectName, (unsigned long)dateModified, eventKey, subjectName];
    
    sqlite3_stmt *update;
    int result = sqlite3_prepare_v2(self.eventDatabase, [sql UTF8String], -1, &update, NULL);
    if (result == SQLITE_OK) {
        sqlite3_step(update);
    } else {
        NSLog(@"Error: update prepare statement failed: %s", sqlite3_errmsg(self.eventDatabase));
    }
    sqlite3_finalize(update);
}

- (void)updateSubjectInStats:(NSString *)eventKey subjectName:(NSString *)subjectName newSubjectName:(NSString *)newSubjectName dateModified:(NSUInteger)dateModified
{
    NSString *sql = [NSString stringWithFormat:@"UPDATE Stats SET subjectName = \"%@\", dateModified = %lu WHERE (eventKey = \"%@\" and subjectName = \"%@\");", newSubjectName, (unsigned long)dateModified, eventKey, subjectName];
    
    sqlite3_stmt *update;
    int result = sqlite3_prepare_v2(self.eventDatabase, [sql UTF8String], -1, &update, NULL);
    if (result == SQLITE_OK) {
        sqlite3_step(update);
    } else {
        NSLog(@"Error: update prepare statement failed: %s", sqlite3_errmsg(self.eventDatabase));
    }
    sqlite3_finalize(update);
}

- (void)updateStatName:(NSString *)eventKey subjectName:(NSString *)subjectName newStatName:(NSString *)newStatName statName:(NSString *)statName dateModified:(NSUInteger)dateModified
{
    NSString *sql = [NSString stringWithFormat:@"UPDATE Stats SET statName = \"%@\", dateModified = %lu WHERE (eventKey = \"%@\" and subjectName = \"%@\" AND statName = \"%@\");", newStatName, (unsigned long)dateModified, eventKey, subjectName, statName];
    
    sqlite3_stmt *update;
    int result = sqlite3_prepare_v2(self.eventDatabase, [sql UTF8String], -1, &update, NULL);
    if (result == SQLITE_OK) {
        sqlite3_step(update);
    } else {
        NSLog(@"Error: update prepare statement failed: %s", sqlite3_errmsg(self.eventDatabase));
    }
    sqlite3_finalize(update);
}

- (void)deleteAllEvents
{
    NSString *sql = @"DELETE FROM Event";
    sqlite3_stmt *delete;
    int result = sqlite3_prepare_v2(self.eventDatabase, [sql UTF8String], -1, &delete, NULL);
    if (result == SQLITE_OK) {
        sqlite3_step(delete);
    }
    sqlite3_finalize(delete);
}

- (void)deleteEvent:(NSString *)eventKey
{
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM Event WHERE eventKey = \"%@\"", eventKey];
    sqlite3_stmt *delete1;
    int result = sqlite3_prepare_v2(self.eventDatabase, [sql UTF8String], -1, &delete1, NULL);
    if (result == SQLITE_OK) {
        sqlite3_step(delete1);
    }
    sqlite3_finalize(delete1);
    
    NSString *sql2 = [NSString stringWithFormat:@"DELETE FROM Subject WHERE eventKey = \"%@\"", eventKey];
    sqlite3_stmt *delete2;
    int result2 = sqlite3_prepare_v2(self.eventDatabase, [sql2 UTF8String], -1, &delete2, NULL);
    if (result2 == SQLITE_OK) {
        sqlite3_step(delete2);
    }
    sqlite3_finalize(delete2);

    NSString *sql3 = [NSString stringWithFormat:@"DELETE FROM Stats WHERE eventKey = \"%@\"", eventKey];
    sqlite3_stmt *delete3;
    int result3 = sqlite3_prepare_v2(self.eventDatabase, [sql3 UTF8String], -1, &delete3, NULL);
    if (result3 == SQLITE_OK) {
        sqlite3_step(delete3);
    }
    sqlite3_finalize(delete3);
}

- (void)deleteStat:(NSString *)eventKey subjectName:(NSString *)subjectName statName:(NSString *)statName
{
    NSString *sql1 = [NSString stringWithFormat:@"DELETE FROM Stats WHERE eventKey = \"%@\" AND subjectName = \"%@\" AND statName =\"%@\"", eventKey, subjectName, statName];
    sqlite3_stmt *delete1;
    int result3 = sqlite3_prepare_v2(self.eventDatabase, [sql1 UTF8String], -1, &delete1, NULL);
    if (result3 == SQLITE_OK) {
        sqlite3_step(delete1);
    }
    sqlite3_finalize(delete1);
}

- (void)deleteStats:(NSString *)eventKey subjectName:(NSString *)subjectName
{
    NSString *sql1 = [NSString stringWithFormat:@"DELETE FROM Stats WHERE eventKey = \"%@\" AND subjectName = \"%@\"", eventKey, subjectName];
    sqlite3_stmt *delete1;
    int result3 = sqlite3_prepare_v2(self.eventDatabase, [sql1 UTF8String], -1, &delete1, NULL);
    if (result3 == SQLITE_OK) {
        sqlite3_step(delete1);
    }
    sqlite3_finalize(delete1);
}

- (void)deleteSubject:(NSString *)eventKey subjectName:(NSString *)subjectName
{
    NSString *sql1 = [NSString stringWithFormat:@"DELETE FROM Subject WHERE eventKey = \"%@\" AND subjectName = \"%@\"", eventKey, subjectName];
    sqlite3_stmt *delete1;
    int result3 = sqlite3_prepare_v2(self.eventDatabase, [sql1 UTF8String], -1, &delete1, NULL);
    if (result3 == SQLITE_OK) {
        sqlite3_step(delete1);
    }
    sqlite3_finalize(delete1);
}

- (void)addToSubject:(NSString *)eventKey subjectName:(NSString *)subjectName dateCreated:(NSUInteger)dateCreated dateModified:(NSUInteger)dateModified
{
    {
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO Subject (eventKey, subjectName, dateCreated, dateModified) VALUES (\"%@\", \"%@\", %lu, %lu)", eventKey, subjectName, (unsigned long)dateCreated, (unsigned long)dateModified];
        
        sqlite3_stmt *insert;
        int result = sqlite3_prepare_v2(self.eventDatabase, [sql UTF8String], -1, &insert, NULL);
        if (result == SQLITE_OK) {
            sqlite3_step(insert);
        } else {
            NSLog(@"Error: insert prepare statement failed: %s", sqlite3_errmsg(self.eventDatabase));
        }
        sqlite3_finalize(insert);
    }
}

- (NSDictionary *)allSubjects
{
    NSMutableDictionary *subjectDictionary = [[NSMutableDictionary alloc] initWithCapacity:6];
    NSString *sql = @"SELECT * FROM Subject;";
    
    sqlite3_stmt *select;
    int result = sqlite3_prepare_v2(self.eventDatabase, [sql UTF8String], -1, &select, NULL);
    
    if (result == SQLITE_OK) {
        NSString *primaryKey1;
        NSString *primaryKey2;

        NSString *primaryKey;
        while (sqlite3_step(select) == SQLITE_ROW) {
            
            NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:5];
            
            // Add the eventKey
            [values addObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(select, 0)]];
            // Add the subjectName
            [values addObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(select, 1)]];
            // Add the dateCreated
            [values addObject:[NSNumber numberWithInteger:sqlite3_column_int(select, 2)]];
            // Get the primaryKey1
            primaryKey1 = [NSString stringWithFormat:@"%s", sqlite3_column_text(select, 0)];
            // Get the primaryKey2
            primaryKey2 = [NSString stringWithFormat:@"%s", sqlite3_column_text(select, 1)];

            primaryKey = [NSString stringWithFormat:@"%@/%@", primaryKey1, primaryKey2];
            
            // Add all to the dictionary
            [subjectDictionary setObject:values forKey:primaryKey];
        }
        sqlite3_finalize(select);
    }
    return subjectDictionary;
}

- (NSDictionary *)justSubjects
{
    NSMutableDictionary *subjectDictionary = [[NSMutableDictionary alloc] initWithCapacity:6];
    NSString *sql = @"SELECT * FROM Subject;";
    
    sqlite3_stmt *select;
    int result = sqlite3_prepare_v2(self.eventDatabase, [sql UTF8String], -1, &select, NULL);
    
    if (result == SQLITE_OK) {
        NSString *primaryKey1;
        NSString *primaryKey2;
        NSString *primaryKey;
        
        while (sqlite3_step(select) == SQLITE_ROW) {
            
            NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:5];
            
            // Add the subjectName
            [values addObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(select, 1)]];
            
            // Get the primaryKey1
            primaryKey1 = [NSString stringWithFormat:@"%s", sqlite3_column_text(select, 0)];
            // Get the primaryKey2
            primaryKey2 = [NSString stringWithFormat:@"%s", sqlite3_column_text(select, 1)];
            
            primaryKey = [NSString stringWithFormat:@"%@/%@", primaryKey1, primaryKey2];
            
            // Add all to the dictionary
            [subjectDictionary setObject:values forKey:primaryKey];
        }
        sqlite3_finalize(select);
    }
    return subjectDictionary;
}

- (void)getStats:(NSString *)eventKey
{
    int check = 0;

    NSString *sql1 = [NSString stringWithFormat:@"SELECT COUNT(*) FROM Stats WHERE eventKey = \"%@\"", eventKey];
    sqlite3_stmt *statement;
    int result = sqlite3_prepare_v2(self.eventDatabase, [sql1 UTF8String], -1, &statement, NULL);
    if (result == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
        
            check = sqlite3_column_int(statement, 0);

            }
        
        sqlite3_finalize(statement);
    }
    
    //NSLog(@"check = %d", check);
    
    if (check > 0) {
        
        NSMutableDictionary *sDict1 = [[NSMutableDictionary alloc] init];
        
        NSString *sql2 = [NSString stringWithFormat:@"SELECT subjectName, statName FROM Stats WHERE eventKey = \"%@\"", eventKey];
        sqlite3_stmt *select;
        int result2 = sqlite3_prepare_v2(self.eventDatabase, [sql2 UTF8String], -1, &select, NULL);
        if (result2 == SQLITE_OK) {
            NSString *primaryKey;
        
            while (sqlite3_step(select) == SQLITE_ROW) {
            
                NSMutableArray *values = [[NSMutableArray alloc] init];
            
                // Get statName
                char *data1 = (char *) sqlite3_column_text(select, 1);
                [values addObject:[NSString stringWithUTF8String:data1]];
                
                // Get the primaryKey1
                char *data2 = (char *) sqlite3_column_text(select, 0);
                primaryKey = [NSString stringWithUTF8String:data2];
            
                // Add all to the dictionary
                [sDict1 setObject:values forKey:primaryKey];
            }
        sqlite3_finalize(select);
        }
    }
}

- (NSString *)getStatValue:(NSString *)eventKey subjectName:(NSString *)subjectName statName:(NSString *)statName
{
    NSString *value;
    NSString *sql = [NSString stringWithFormat:@"SELECT statValue FROM Stats WHERE eventKey = \"%@\" AND subjectName = \"%@\" AND statName = \"%@\"", eventKey, subjectName, statName];
    
    sqlite3_stmt *select;
    int result = sqlite3_prepare_v2(self.eventDatabase, [sql UTF8String], -1, &select, NULL);
    
    if (result == SQLITE_OK) {

        while (sqlite3_step(select) == SQLITE_ROW) {
            
            char *data1 = (char *) sqlite3_column_text(select, 0);
            value = [NSString stringWithUTF8String:data1];
        }
        
        sqlite3_finalize(select);
    }
    return value;
}

- (NSMutableArray *)loadStatsForSubject:(NSString *)eventKey subjectName:(NSString *)subjectName
{
    NSMutableArray *aTemp1 = [[NSMutableArray alloc] init];
    
    NSString *sql1 = [NSString stringWithFormat:@"SELECT statName FROM Stats WHERE eventKey = \"%@\" AND subjectName = \"%@\"", eventKey, subjectName];
    sqlite3_stmt *select;
    int result1 = sqlite3_prepare_v2(self.eventDatabase, [sql1 UTF8String], -1, &select, NULL);
    if (result1 == SQLITE_OK) {
        
        while (sqlite3_step(select) == SQLITE_ROW) {
            
            // Get statName
            char *data1 = (char *) sqlite3_column_text(select, 0);
            
            // Add all to the array
            [aTemp1 addObject:[NSString stringWithUTF8String:data1]];
            
        }
        sqlite3_finalize(select);
    }
    return aTemp1;
}

- (void)deleteAllSubjects
{
    NSString *sql = @"DELETE FROM Subject";
    sqlite3_stmt *delete;
    int result = sqlite3_prepare_v2(self.eventDatabase, [sql UTF8String], -1, &delete, NULL);
    if (result == SQLITE_OK) {
        sqlite3_step(delete);
    }
    sqlite3_finalize(delete);
}

-(void)addToStats:(NSString *)eventKey subjectName:(NSString *)subjectName statName:(NSString *)statName statValue:(NSUInteger)statValue dateCreated:(NSUInteger)dateCreated dateModified:(NSUInteger)dateModified
{
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO Stats (eventKey, subjectName, statName, statValue, dateCreated, dateModified) VALUES (\"%@\", \"%@\", \"%@\", %lu, %lu, %lu)", eventKey, subjectName, statName, (unsigned long)statValue, (unsigned long)dateCreated, (unsigned long)dateModified];
        
    sqlite3_stmt *insert;
    int result = sqlite3_prepare_v2(self.eventDatabase, [sql UTF8String], -1, &insert, NULL);
    if (result == SQLITE_OK) {
        sqlite3_step(insert);
    } else {
        NSLog(@"Error: insert prepare statement failed: %s", sqlite3_errmsg(self.eventDatabase));
    }
    sqlite3_finalize(insert);
}

- (void)updateStats:(NSString *)eventKey subjectName:(NSString *)subjectName statName:(NSString *)statName statValue:(NSUInteger)statValue dateModified:(NSUInteger)dateModified
{
    NSString *sql = [NSString stringWithFormat:@"UPDATE Stats SET statValue = %lu, dateModified = %lu WHERE (eventKey = \"%@\" AND subjectName = \"%@\" AND statName = \"%@\");", (unsigned long)statValue, (unsigned long)dateModified, eventKey, subjectName, statName];
    
    sqlite3_stmt *update;
    int result = sqlite3_prepare_v2(self.eventDatabase, [sql UTF8String], -1, &update, NULL);
    if (result == SQLITE_OK) {
        sqlite3_step(update);
    } else {
        NSLog(@"Error: update prepare statement failed: %s", sqlite3_errmsg(self.eventDatabase));
    }
    sqlite3_finalize(update);
}

- (BOOL)getStat:(NSString *)eventKey subjectName:(NSString *)subjectName statName:(NSString *)statName
{
    int check = 0;
    
    NSString *sql1 = [NSString stringWithFormat:@"SELECT COUNT(*) FROM Stats WHERE eventKey = \"%@\" AND subjectName = \"%@\" AND statName = \"%@\"", eventKey, subjectName, statName];
    sqlite3_stmt *statement;
    int result = sqlite3_prepare_v2(self.eventDatabase, [sql1 UTF8String], -1, &statement, NULL);
    if (result == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            check = sqlite3_column_int(statement, 0);
            
        }
        
        sqlite3_finalize(statement);
    }
    
    if (check > 0) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)getEvent:(NSString *)eventName eventLocation:(NSString *)eventLocation eventDate:(NSUInteger)eventDate
{
    int check = 0;
    
    NSString *sql1 = [NSString stringWithFormat:@"SELECT COUNT(*) FROM Event WHERE eventName = \"%@\" AND eventLocation = \"%@\" AND eventDate = %lu", eventName, eventLocation, (unsigned long)eventDate];
    sqlite3_stmt *statement;
    int result = sqlite3_prepare_v2(self.eventDatabase, [sql1 UTF8String], -1, &statement, NULL);
    if (result == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            check = sqlite3_column_int(statement, 0);
            
        }
        
        sqlite3_finalize(statement);
    }
    
    if (check > 0) {
        return YES;
    } else {
        return NO;
    }
}

- (NSString *)getEventKey:(NSString *)eventName eventLocation:(NSString *)eventLocation eventDate:(NSUInteger)eventDate
{
    NSString *value;
    NSString *sql = [NSString stringWithFormat:@"SELECT eventKey FROM Event WHERE eventName = \"%@\" AND eventLocation = \"%@\" AND eventDate = %lu", eventName, eventLocation, (unsigned long)eventDate];
    
    sqlite3_stmt *select;
    int result = sqlite3_prepare_v2(self.eventDatabase, [sql UTF8String], -1, &select, NULL);
    
    if (result == SQLITE_OK) {
        
        while (sqlite3_step(select) == SQLITE_ROW) {
            
            char *data1 = (char *) sqlite3_column_text(select, 0);
            value = [NSString stringWithUTF8String:data1];
        }
        
        sqlite3_finalize(select);
    }
    return value;
}

- (NSDictionary *)allStats
{
    NSMutableDictionary *statsDictionary = [[NSMutableDictionary alloc] initWithCapacity:6];
    NSString *sql = @"SELECT * FROM Stats;";
    
    sqlite3_stmt *select;
    int result = sqlite3_prepare_v2(self.eventDatabase, [sql UTF8String], -1, &select, NULL);
    
    if (result == SQLITE_OK) {
        NSString *primaryKey1;
        NSString *primaryKey2;
        NSString *primaryKey3;
        
        NSString *primaryKey;
        while (sqlite3_step(select) == SQLITE_ROW) {
            
            NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:5];
            
            // Add the eventKey
            [values addObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(select, 0)]];
            // Add the subjectName
            [values addObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(select, 1)]];
            // Add the statName
            [values addObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(select, 2)]];
            // Add the statValue
            [values addObject:[NSNumber numberWithInteger:sqlite3_column_int(select, 3)]];
            // Add the dateCreated
            [values addObject:[NSNumber numberWithInteger:sqlite3_column_int(select, 4)]];
            // Get the primaryKey1
            primaryKey1 = [NSString stringWithFormat:@"%s", sqlite3_column_text(select, 0)];
            // Get the primaryKey2
            primaryKey2 = [NSString stringWithFormat:@"%s", sqlite3_column_text(select, 1)];
            // Get the primaryKey3
            primaryKey3 = [NSString stringWithFormat:@"%s", sqlite3_column_text(select, 2)];
            
            primaryKey = [NSString stringWithFormat:@"%@/%@/%@", primaryKey1, primaryKey2, primaryKey3];
            
            // Add all to the dictionary
            [statsDictionary setObject:values forKey:primaryKey];
        }
        sqlite3_finalize(select);
    }
    return statsDictionary;
}

- (void)deleteAllStats
{
    NSString *sql = @"DELETE FROM Stats";
    sqlite3_stmt *delete;
    int result = sqlite3_prepare_v2(self.eventDatabase, [sql UTF8String], -1, &delete, NULL);
    if (result == SQLITE_OK) {
        sqlite3_step(delete);
    }
    sqlite3_finalize(delete);
}

- (NSMutableDictionary *)statsAndValues
{
    NSMutableDictionary *statsDictionary = [[NSMutableDictionary alloc] init];
    
    NSString *eventKey;
    
    NSString *sql1 = [NSString stringWithFormat:@"SELECT eventKey, dateCreated FROM Event E WHERE dateCreated = (SELECT MAX (dateCreated) FROM Event WHERE eventKey = E.eventKey) ORDER BY dateCreated DESC LIMIT 1;"];
    sqlite3_stmt *select1;
    int result1 = sqlite3_prepare_v2(self.eventDatabase, [sql1 UTF8String], -1, &select1, NULL);
    if (result1 == SQLITE_OK) {
        while (sqlite3_step(select1) == SQLITE_ROW) {
            
            char *data1 = (char *) sqlite3_column_text(select1, 0);
            eventKey = [NSString stringWithUTF8String:data1];
            
        }
        sqlite3_finalize(select1);
    }
    
    int check = 0;
    
    NSString *sql2 = [NSString stringWithFormat:@"SELECT COUNT(*) FROM Stats WHERE eventKey = \"%@\"", eventKey];
    sqlite3_stmt *select2;
    int result2 = sqlite3_prepare_v2(self.eventDatabase, [sql2 UTF8String], -1, &select2, NULL);
    if (result2 == SQLITE_OK) {
        while (sqlite3_step(select2) == SQLITE_ROW) {
            
            check = sqlite3_column_int(select2, 0);
            
        }
        sqlite3_finalize(select2);
    }

    if (check > 0) {
        
        NSMutableArray *keys = [[NSMutableArray alloc] init];
        
        NSString *sql3 = [NSString stringWithFormat:@"SELECT MIN(subjectName) FROM Stats WHERE eventKey = \"%@\" GROUP BY subjectName", eventKey];
        sqlite3_stmt *select3;
        int result3 = sqlite3_prepare_v2(self.eventDatabase, [sql3 UTF8String], -1, &select3, NULL);
        if (result3 == SQLITE_OK) {
            
            while (sqlite3_step(select3) == SQLITE_ROW) {
                
                // Get statName
                char *data1 = (char *) sqlite3_column_text(select3, 0);
                [keys addObject:[NSString stringWithUTF8String:data1]];
            }
            sqlite3_finalize(select3);
        }

        NSString *primaryKey1;
        
        for (int i = 0; i < [keys count]; i++) {
            
            NSMutableDictionary *keyvalues = [[NSMutableDictionary alloc] init];
            
            NSString *sql4 = [NSString stringWithFormat:@"SELECT statName, statValue FROM Stats WHERE eventKey = \"%@\" AND subjectName = \"%@\"", eventKey, [keys objectAtIndex:i]];
            
            sqlite3_stmt *select4;
            int result4 = sqlite3_prepare_v2(self.eventDatabase, [sql4 UTF8String], -1, &select4, NULL);
            if (result4 == SQLITE_OK) {
                
                while (sqlite3_step(select4) == SQLITE_ROW) {
                    
                    // Get statName and statValue and add them to Dictionary
                    char *data1 = (char *) sqlite3_column_text(select4, 1);
                    char *data2 = (char *) sqlite3_column_text(select4, 0);
                    [keyvalues setObject:[NSString stringWithUTF8String:data1] forKey:[NSString stringWithUTF8String:data2]];
                    
                    // Get the primaryKey1
                    primaryKey1 = [keys objectAtIndex:i];

                }
                
                sqlite3_finalize(select4);
                
                // Add all to the main dictionary
                [statsDictionary setObject:keyvalues forKey:primaryKey1];
            }
        }
    }
    return statsDictionary;
}

- (NSArray *)allEvents
{
    return self.privateEvents;
}

- (NSMutableDictionary *)loadStatsAndValues:(NSString *)eventKey
{
    NSMutableDictionary *statsDictionary = [[NSMutableDictionary alloc] init];
        
    NSMutableArray *keys = [[NSMutableArray alloc] init];
        
    NSString *sql3 = [NSString stringWithFormat:@"SELECT MIN(subjectName) FROM Stats WHERE eventKey = \"%@\" GROUP BY subjectName", eventKey];
    sqlite3_stmt *select3;
    int result3 = sqlite3_prepare_v2(self.eventDatabase, [sql3 UTF8String], -1, &select3, NULL);
    if (result3 == SQLITE_OK) {
            
        while (sqlite3_step(select3) == SQLITE_ROW) {
                
            // Get statName
            char *data1 = (char *) sqlite3_column_text(select3, 0);
            [keys addObject:[NSString stringWithUTF8String:data1]];
        }
        sqlite3_finalize(select3);
    }
        
    NSString *primaryKey1;
        
    for (int i = 0; i < [keys count]; i++) {
            
        NSMutableDictionary *keyvalues = [[NSMutableDictionary alloc] init];
            
        NSString *sql4 = [NSString stringWithFormat:@"SELECT statName, statValue FROM Stats WHERE eventKey = \"%@\" AND subjectName = \"%@\"", eventKey, [keys objectAtIndex:i]];
            
        sqlite3_stmt *select4;
        int result4 = sqlite3_prepare_v2(self.eventDatabase, [sql4 UTF8String], -1, &select4, NULL);
        if (result4 == SQLITE_OK) {
                
            while (sqlite3_step(select4) == SQLITE_ROW) {
                    
                // Get statName and statValue and add them to Dictionary
                char *data1 = (char *) sqlite3_column_text(select4, 1);
                char *data2 = (char *) sqlite3_column_text(select4, 0);
                [keyvalues setObject:[NSString stringWithUTF8String:data1] forKey:[NSString stringWithUTF8String:data2]];
                
                // Get the primaryKey1
                primaryKey1 = [keys objectAtIndex:i];
                    
            }
                
            sqlite3_finalize(select4);
                
            // Add all to the main dictionary
            [statsDictionary setObject:keyvalues forKey:primaryKey1];
            //NSLog(@"statsDictionary = %@", statsDictionary);
        }
    }
    return statsDictionary;
}

- (void)removeEvent:(ITWEvent *)event
{
    [self.privateEvents removeObjectIdenticalTo:event];
}

- (void)moveItemAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
    if (fromIndex == toIndex) {
        return;
    }
    
    // Get pointer to object being moved so you can re-insert it
    ITWEvent *event = self.privateEvents[fromIndex];
    
    // Remove item from array
    [self.privateEvents removeObjectAtIndex:fromIndex];
    
    // Insert item in array at new location
    [self.privateEvents insertObject:event atIndex:toIndex];
    
    // Computing a new orderValue for the object that was moved
    double lowerBound = 0.0;
    
    // Is there an object before it in the array?
    if (toIndex > 0) {
        lowerBound = [self.privateEvents[(toIndex - 1)] orderingValue];
    } else {
        lowerBound = [self.privateEvents[1] orderingValue] - 2.0;
    }
    
    double upperBound = 0.0;
    
    // Is there an object after it in the array?
    if (toIndex < [self.privateEvents count] - 1) {
        upperBound = [self.privateEvents[(toIndex + 1)] orderingValue];
    } else {
        upperBound = [self.privateEvents[(toIndex - 1)] orderingValue] + 2.0;
    }
    
    double newOrderValue = (lowerBound + upperBound) / 2.0;
    
    event.orderingValue = newOrderValue;
    
}

- (NSString *)itemArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    // Get the one document directory from that list
    NSString *documentDirectory = [documentDirectories firstObject];

    return [documentDirectory stringByAppendingPathComponent:@"store.data"];
}

@end
