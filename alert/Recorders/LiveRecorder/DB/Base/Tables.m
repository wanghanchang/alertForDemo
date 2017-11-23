//
//  Tables.m
//  PersonalRecord
//
//  Created by 匹诺曹 on 16/6/27.
//  Copyright © 2016年 匹诺曹. All rights reserved.
//

#import "Tables.h"

@implementation Tables


+ (SqliteTable *)tableRecord {
    return [SqliteTable tableWithName:TableRecord
                          withColumns:@[[SqliteColumn columnWithName:kColID withType:@"integer" withConstraint:@"primary key autoincrement"],
                                        [SqliteColumn columnWithName:kFileLength withType:@"integer" withConstraint:@"not null"],
                                        [SqliteColumn columnWithName:kfileId withType:@"text" withConstraint:@"not null"],
                                        [SqliteColumn columnWithName:kresultTransStr withType:@"text" withConstraint:@"not null"],
                                        [SqliteColumn columnWithName:kExpandName withType:@"text" withConstraint:@"not null"],
                                        [SqliteColumn columnWithName:kTranslateState withType:@"integer" withConstraint:@"default 0"],
                                        [SqliteColumn columnWithName:kStartTime withType:@"integer" withConstraint:@"not null"],
                                        [SqliteColumn columnWithName:ktimeLong withType:@"integer" withConstraint:@"default 0"],
                                        [SqliteColumn columnWithName:kOrderId withType:@"text" withConstraint:@"not null"],
                                        [SqliteColumn columnWithName:kFileName withType:@"text" withConstraint:@"not null"],
                                        [SqliteColumn columnWithName:kRecordTagColor withType:@"text" withConstraint:@"not null"],
                                        [SqliteColumn columnWithName:kRecordTag withType:@"text" withConstraint:@"not null"],
                                        [SqliteColumn columnWithName:kisFinishUplaod withType:@"integer" withConstraint:@"default 0"],
                                        [SqliteColumn columnWithName:kisFinishBindOrder withType:@"integer" withConstraint:@"default 0"],
                                        [SqliteColumn columnWithName:kuserNamedFile withType:@"text" withConstraint:@"not null"]

                                                                ]
                 withPrimaryKeyColumn:kColID];

}

+ (SqliteTable*)callRecorder {
    return [SqliteTable tableWithName:kTableCallRecorder
                          withColumns:@[[SqliteColumn columnWithName:kColID withType:@"integer" withConstraint:@"primary key autoincrement"],
                                        [SqliteColumn columnWithName:kDirection withType:@"text" withConstraint:@"not null"],
                                        [SqliteColumn columnWithName:kDownload withType:@"text" withConstraint:@"not null"],
                                        [SqliteColumn columnWithName:kBegintime withType:@"text" withConstraint:@"not null"],
                                        [SqliteColumn columnWithName:kDuration withType:@"text" withConstraint:@"not null"],
                                        [SqliteColumn columnWithName:kExt withType:@"text" withConstraint:@"not null"],
                                        [SqliteColumn columnWithName:kContactNumber withType:@"text" withConstraint:@"not null"],
                                        [SqliteColumn columnWithName:kNote withType:@"text" withConstraint:@"not null"],
                                        [SqliteColumn columnWithName:kIsCollect withType:@"integer" withConstraint:@"not null"],
                                        [SqliteColumn columnWithName:kRecordid withType:@"text" withConstraint:@"not null"],
                                        [SqliteColumn columnWithName:KSize withType:@"text" withConstraint:@"not null"],
                                        [SqliteColumn columnWithName:kListen withType:@"text" withConstraint:@"not null"]
                                        ]
                 withPrimaryKeyColumn:kColID];
}

+ (SqliteTable *)message {
    return [SqliteTable tableWithName:kMessage
                          withColumns:@[[SqliteColumn columnWithName:kColID withType:@"integer" withConstraint:@"primary key autoincrement"],
                                        [SqliteColumn columnWithName:kMessageTime withType:@"text" withConstraint:@"not null"],
                                        [SqliteColumn columnWithName:kMessageIsNew withType:@"integer" withConstraint:@"default 0"],
                                        [SqliteColumn columnWithName:kMessageContent withType:@"text" withConstraint:@"not null"]]
                 withPrimaryKeyColumn:kColID];
}

@end
