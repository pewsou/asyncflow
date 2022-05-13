/*
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU Affero General Public License as
 published by the Free Software Foundation, either version 3 of the
 License, or (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Affero General Public License for more details.
 
 You should have received a copy of the GNU Affero General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

//  Copyright © 2019-2022 Boris Vigman. All rights reserved.
//

#import "ASFKBase.h"
#import "ASFKBase+Internal.h"
#import <atomic>
@implementation ASFKControlBlock{
    std::atomic< BOOL> abortByCallback;
    std::atomic< BOOL> abortByCaller;
    std::atomic< BOOL> abortByInternal;

    std::vector<std::vector<long long>> indexes;
}
-(id)initWithParent:(ASFK_IDENTITY_TYPE)parentId sessionId:(ASFK_IDENTITY_TYPE) sessionId andSubId:(ASFK_IDENTITY_TYPE)subid{
    self=[super init];
    if(self){
        _parentId=[parentId copy];
        _sessionId=[ASFKBase concatIdentity:sessionId withIdentity:subid];

        itsLock=[[NSLock alloc]init];

        abortByCallback=NO;
        abortByCaller=NO;
        abortByInternal=NO;

        flushed=NO;
        paused=NO;

    }
    return self;
}

-(void)cancel{
    abortByCaller=YES;
}
-(void) flushRequested:(BOOL)flush{
    flushed=flush;
}
-(BOOL) flushRequested{
    return flushed;
}
-(BOOL) cancellationRequestedByStarter{
    BOOL cr=abortByCaller;
    return cr;
}
-(BOOL) cancellationRequestedByCallback{
    BOOL b=abortByCallback;
    return b;
}
-(void) reset{
    abortByCallback=NO;
    abortByCaller=NO;
    [itsLock lock];
    indexes.clear();
    [itsLock unlock];
}
-(void) stop{
    abortByCallback=YES;
}
-(BOOL) cancellationRequested{
    BOOL b=abortByCallback|abortByCaller;
    return b;
}
-(NSString*) getCurrentSessionId{
    return self.sessionId;
}
-(NSString*)getParentObjectId{
    return self.parentId;
}
-(ASFKProgressRoutine) getProgressRoutine{
    [itsLock lock];
    ASFKProgressRoutine p=itsProgressProc;
    [itsLock unlock];
    return p;
}
@end
