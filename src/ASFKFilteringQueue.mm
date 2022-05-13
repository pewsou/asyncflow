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
//
//  Copyright © 2019-2022 Boris Vigman. All rights reserved.
//
#import "ASFKBase.h"
#import "ASFKFilteringQueue.h"

@implementation ASFKFilteringQueue{
    std::atomic<eASFKQDroppingPolicy> dpolicy;
    std::atomic<NSUInteger> maxQSize;
    std::atomic<NSUInteger> minQSize;
    ASFKFilter* itsFilter;

}
-(id)init{
    self=[super init];
    if(self){
        [self _initFQ];
    }
    return self;
}

-(id)initWithName:(NSString*)name{
    self=[super initWithName:name];
    if(self){
        [self _initFQ];
    }
    return self;
}
-(void) _initFQ{
    dpolicy=E_ASFK_Q_DP_HEAD;
    itsFilter=nil;
    minQSize=0;
    maxQSize=ULONG_MAX;
}
-(void) setMaxQSize:(NSUInteger)size{
    maxQSize=size;
}
-(void) setMinQSize:(NSUInteger)size{
    minQSize=size;
}
-(void) setDroppingPolicy:(eASFKQDroppingPolicy)policy{
    dpolicy=policy;
}
-(void) setDroppingAlgorithmL1:(ASFKFilter*)dropAlg{
    [lkNonLocal lock];
    itsFilter = dropAlg;
    [lkNonLocal unlock];
}
-(BOOL) removeObjWithId:(id)obj andBlock:(BOOL (^)(id item,id sample, BOOL* stop)) blk{
    BOOL r=NO;
    NSMutableIndexSet* mis=[NSMutableIndexSet new];
    if(obj){
        NSUInteger c=0;
        [lkNonLocal lock];
        BOOL stop = NO;
        for (id o in q) {
            if(blk(o,obj,&stop)){
                [mis addIndex:c];
            }
            ++c;
            
            if( stop ){
                break;
            }
        }
        [q removeObjectsAtIndexes:mis];
        [lkNonLocal unlock];
        
        [mis removeAllIndexes];
        

    }
    return r;
}
-(BOOL)push:(id)item{
    BOOL res=NO;
    if(item){
        [lock lock];
        NSUInteger qc = [q count];
        if(qc+1 <= maxQSize)
        {
            [q addObject:item];
            res=YES;
        }
        else
        {
            NSRange r;
            if(dpolicy == E_ASFK_Q_DP_HEAD && qc > 0){
                r.location=0;
                r.length=qc-maxQSize+1;
                [q removeObjectsInRange:r];
                [q addObject:item];
                res = YES;
            }
            else if(dpolicy == E_ASFK_Q_DP_TAIL){
                r.location=maxQSize-1;
                r.length=qc-maxQSize+1;
                [q removeObjectsInRange:r];
                [q addObject:item];
                res = YES;
            }
            else if(dpolicy == E_ASFK_Q_DP_REJECT){
                res=NO;
            }
            else if(dpolicy == E_ASFK_Q_DP_ALGO){
                NSMutableIndexSet* iset=[NSMutableIndexSet new];
                res=[itsFilter filterCandidatesInArray:q saveToIndexSet:iset];
                if(res){
                    [q removeObjectsAtIndexes:iset];
                    [q addObject:item];
                    res=YES;
                }
                else{
                    res=NO;
                }
            }
        }
        [lock unlock];
    }
    return res;
}
-(id)pull{
    [lock lock];
    NSUInteger qc = [q count];
    id item=[q firstObject];
    if (item && qc >= minQSize) {
        [q removeObjectAtIndex:0];
    }
    else{
        item=nil;
    }
    [lock unlock];;

    return item;
}
-(void) filterWith:(ASFKFilter*)filter{
    ASFKFilter* ft=filter;
    if(!ft)
    {
        ft=itsFilter;
    }
    if(ft){
        NSMutableIndexSet* iset=[NSMutableIndexSet new];
        BOOL res=[itsFilter filterCandidatesInArray:q saveToIndexSet:iset];
        if(res){
            [lock lock];
            [q removeObjectsAtIndexes:iset];
            [lock unlock];
        }
    }
}

@end
