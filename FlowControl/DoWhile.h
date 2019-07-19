//
//  DoWhile.h
//
//  Created by Boris Vigman on 03/04/2019.
//  Copyright © 2019 Boris Vigman. All rights reserved.
//
#import "ASFKLoopSeq.h"
@interface ASFKDoWhileSeq : ASFKLoopSeq
-(void) runWithExitCondition:(ASFKExecutableProcedureConditional)condBlock andBody:(ASFKExecutableProcedure)body andSummary:(ASFKExecutableProcedureSummary)summary;
@end
