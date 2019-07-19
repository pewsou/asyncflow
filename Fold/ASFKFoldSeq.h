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
//  Created by Boris Vigman on 23/02/2019.
//  Copyright © 2019 Boris Vigman. All rights reserved.
//

#import <ASFKBase.h>
@interface FoldSeq : ASFKCombination
#pragma mark - Immediate Execution
-(NSArray*) runLeft:(ASFKExecutableProcedure)proc withString:(NSString*)value onArray:(NSArray*)array withSummary:(ASFKExecutableProcedureSummary)summary;
-(NSDictionary*) runLeft:(ASFKExecutableProcedure)proc onDictionary:(NSDictionary*)dictionary withSummary:(ASFKExecutableProcedureSummary)summary;

-(NSArray*) runRight:(ASFKExecutableProcedure)proc withString:(NSString*)value onArray:(NSArray*)array withSummary:(ASFKExecutableProcedureSummary)summary;
-(NSDictionary*) runRight:(ASFKExecutableProcedure)proc onDictionary:(NSDictionary*)dictionary withSummary:(ASFKExecutableProcedureSummary)summary;
@end
