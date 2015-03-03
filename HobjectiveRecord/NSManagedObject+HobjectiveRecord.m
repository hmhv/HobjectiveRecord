//
//  NSManagedObject+HobjectiveRecord.m
//
// Copyright (c) 2015 hmhv <http://hmhv.info/>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "NSManagedObject+HobjectiveRecord.h"
#import "NSManagedObjectContext+HobjectiveRecord.h"

@interface NSString (HobjectiveRecord)

- (instancetype)toCamelCase;

@end

@implementation NSString (HobjectiveRecord)

- (instancetype)toCamelCase
{
    static NSRegularExpression *s_regex = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_regex = [NSRegularExpression regularExpressionWithPattern:@"(_)([a-z])" options:0 error:nil];
    });
    NSArray *results = [s_regex matchesInString:self options:kNilOptions range:NSMakeRange(0, self.length)];
    if ([results count] > 0) {
        NSMutableString *buffer = [self mutableCopy];
        for(NSTextCheckingResult *result in [results reverseObjectEnumerator]) {
            [buffer replaceCharactersInRange:[result rangeAtIndex:2] withString:[buffer substringWithRange:[result rangeAtIndex:2]].uppercaseString];
            [buffer deleteCharactersInRange:[result rangeAtIndex:1]];
        }
        return buffer;
    }
    return self;
}

@end

@implementation NSManagedObject (HobjectiveRecord)

#pragma mark - Instance Method

- (void)save
{
    [self.managedObjectContext save];
}

- (void)saveToStore
{
    [self.managedObjectContext saveToStore];
}

- (void)delete
{
    [self.managedObjectContext deleteObject:self];
}

- (void)performBlock:(void (^)())block
{
    if (block) {
        [self.managedObjectContext performBlock:^{
            block();
        }];
    }
}

- (void)performBlockSynchronously:(void (^)())block
{
    if (block) {
        [self.managedObjectContext performBlockSynchronously:block];
    }
}

#pragma mark - Creation / Deletion

+ (instancetype)create
{
    return [self create:nil inContext:[NSManagedObjectContext defaultContext]];
}

+ (instancetype)createInContext:(NSManagedObjectContext *)context
{
    return [self create:nil inContext:context];
}

+ (instancetype)create:(NSDictionary *)attributes
{
    return [self create:attributes inContext:[NSManagedObjectContext defaultContext]];
}

+ (instancetype)create:(NSDictionary *)attributes inContext:(NSManagedObjectContext *)context
{
    NSManagedObject *newEntity = [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:context];
    return [newEntity update:attributes];
}

+ (void)deleteAll
{
    [self deleteAllInContext:[NSManagedObjectContext defaultContext]];
}

+ (void)deleteAllInContext:(NSManagedObjectContext *)context
{
    NSArray *objects = [self allInContext:context];
    
    [objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [context deleteObject:obj];
    }];
}

#pragma mark - Finders

+ (NSArray *)all
{
    return [self allWithOrder:nil inContext:[NSManagedObjectContext defaultContext]];
}

+ (NSArray *)allInContext:(NSManagedObjectContext *)context
{
    return [self allWithOrder:nil inContext:[NSManagedObjectContext defaultContext]];
}

+ (NSArray *)allWithOrder:(NSString *)order
{
    return [self allWithOrder:order inContext:[NSManagedObjectContext defaultContext]];
}

+ (NSArray *)allWithOrder:(NSString *)order inContext:(NSManagedObjectContext *)context
{
    return [self fetchWithCondition:nil withOrder:order fetchLimit:nil inContext:context];
}

+ (NSArray *)where:(id)condition
{
    return [self where:condition order:nil limit:nil inContext:[NSManagedObjectContext defaultContext]];
}

+ (NSArray *)where:(id)condition inContext:(NSManagedObjectContext *)context
{
    return [self where:condition order:nil limit:nil inContext:context];
}

+ (NSArray *)where:(id)condition order:(NSString *)order
{
    return [self where:condition order:order limit:nil inContext:[NSManagedObjectContext defaultContext]];
}

+ (NSArray *)where:(id)condition order:(NSString *)order inContext:(NSManagedObjectContext *)context
{
    return [self where:condition order:order limit:nil inContext:context];
}

+ (NSArray *)where:(id)condition limit:(NSNumber *)limit
{
    return [self where:condition order:nil limit:limit inContext:[NSManagedObjectContext defaultContext]];
}

+ (NSArray *)where:(id)condition limit:(NSNumber *)limit inContext:(NSManagedObjectContext *)context
{
    return [self where:condition order:nil limit:limit inContext:context];
}

+ (NSArray *)where:(id)condition order:(NSString *)order limit:(NSNumber *)limit
{
    return [self where:condition order:order limit:limit inContext:[NSManagedObjectContext defaultContext]];
}

+ (NSArray *)where:(id)condition order:(NSString *)order limit:(NSNumber *)limit inContext:(NSManagedObjectContext *)context
{
    return [self fetchWithCondition:condition withOrder:order fetchLimit:limit inContext:context];
}

+ (instancetype)find:(id)condition
{
    return [self find:condition inContext:[NSManagedObjectContext defaultContext]];
}

+ (instancetype)find:(id)condition inContext:(NSManagedObjectContext *)context
{
    return [self where:condition limit:@1 inContext:context].firstObject;
}

+ (instancetype)findOrCreate:(NSDictionary *)attributes
{
    return [self findOrCreate:attributes inContext:[NSManagedObjectContext defaultContext]];
}

+ (instancetype)findOrCreate:(NSDictionary *)properties inContext:(NSManagedObjectContext *)context
{
    NSManagedObject *existing = [self find:properties inContext:context];
    return existing ?: [self create:properties inContext:context];
}

#pragma mark - Aggregation

+ (NSUInteger)count
{
    return [self countWhere:nil inContext:[NSManagedObjectContext defaultContext]];
}

+ (NSUInteger)countInContext:(NSManagedObjectContext *)context
{
    return [self countWhere:nil inContext:context];
}

+ (NSUInteger)countWhere:(id)condition
{
    return [self countWhere:condition inContext:[NSManagedObjectContext defaultContext]];
}

+ (NSUInteger)countWhere:(id)condition inContext:(NSManagedObjectContext *)context
{
    return [self countForFetchWithPredicate:condition inContext:context];
}

#pragma mark - FetchedResultsController

+ (NSFetchedResultsController *)createFetchedResultsControllerWithCondition:(id)condition order:(NSString *)order sectionNameKeyPath:(NSString *)sectionNameKeyPath
{
    return [self createFetchedResultsControllerWithCondition:condition
                                                       order:order
                                          sectionNameKeyPath:sectionNameKeyPath
                                                   inContext:[NSManagedObjectContext defaultContext]];
}

+ (NSFetchedResultsController *)createFetchedResultsControllerWithCondition:(id)condition order:(NSString *)order sectionNameKeyPath:(NSString *)sectionNameKeyPath inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self createFetchRequestWithCondition:condition
                                                          withOrder:order
                                                         fetchLimit:nil
                                                          inContext:context];
    
    return [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                               managedObjectContext:context
                                                 sectionNameKeyPath:sectionNameKeyPath cacheName:nil];
}

#pragma mark - Naming

+ (NSString *)entityName
{
    return NSStringFromClass(self);
}

#pragma mark - Fetching

+ (BOOL)returnsObjectsAsFaults
{
    return NO;
}

+ (NSArray *)relationshipKeyPathsForPrefetching
{
    return nil;
}

#pragma mark - Mappings

+ (NSDictionary *)mappings
{
    return nil;
}

+ (BOOL)useFindOrCreate
{
    return YES;
}

#pragma mark - Private

+ (NSPredicate *)predicateFromDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context
{
    NSMutableArray *subPredicates = [NSMutableArray array];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:context];
    
    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        NSString *localKey = [self keyForRemoteKey:key inContext:context];
        
        if ([entity attributesByName][localKey]) {
            id object = [NSPredicate predicateWithFormat:@"%K = %@", localKey, obj];
            
            if (object) {
                [subPredicates addObject:object];
            }
        }
    }];
    
    return [NSCompoundPredicate andPredicateWithSubpredicates:subPredicates];
}

+ (NSPredicate *)predicateFromObject:(id)condition inContext:(NSManagedObjectContext *)context
{
    if ([condition isKindOfClass:[NSPredicate class]]) {
        return condition;
    }
    
    if ([condition isKindOfClass:[NSString class]]) {
        return [NSPredicate predicateWithFormat:condition];
    }
    
    if ([condition isKindOfClass:[NSDictionary class]]) {
        return [self predicateFromDictionary:condition inContext:context];
    }
    
    return nil;
}

+ (NSSortDescriptor *)sortDescriptor:(NSString *)sortKeyAndValue
{
    NSArray *keyAndValue = [sortKeyAndValue componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    NSString *key = nil;

    BOOL isAscending = YES;

    for (NSString *keyOrValue in keyAndValue) {
        if ([keyOrValue length] == 0) continue;
        
        if (key == nil) {
            key = keyOrValue;
            continue;
        }
        else if ([[keyOrValue uppercaseString] hasPrefix:@"D"]) {
            isAscending = NO;
            break;
        }
    }
    
    return key ? [NSSortDescriptor sortDescriptorWithKey:key ascending:isAscending] : nil;
}

+ (NSArray *)sortDescriptors:(NSString *)order
{
    NSArray *orders = [order componentsSeparatedByString:@","];
    NSMutableArray *sortDescriptors = [NSMutableArray arrayWithCapacity:orders.count];
    
    for (NSString *sortKeyAndValue in orders) {
        id newObject = [self sortDescriptor:sortKeyAndValue];
        
        if (newObject) {
            [sortDescriptors addObject:newObject];
        }
    }
    
    return sortDescriptors;
}

+ (NSFetchRequest *)createFetchRequestWithCondition:(id)condition
                                          withOrder:(NSString *)order
                                         fetchLimit:(NSNumber *)fetchLimit
                                          inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest new];
    NSEntityDescription *entity = [NSEntityDescription entityForName:[self entityName]
                                              inManagedObjectContext:context];
    [request setEntity:entity];
    
    if (condition) {
        [request setPredicate:[self predicateFromObject:condition inContext:context]];
    }
    
    if (order) {
        [request setSortDescriptors:[self sortDescriptors:order]];
    }
    
    if (fetchLimit) {
        [request setFetchLimit:[fetchLimit integerValue]];
    }
    
    request.returnsObjectsAsFaults = [self returnsObjectsAsFaults];
    
    request.relationshipKeyPathsForPrefetching = [self relationshipKeyPathsForPrefetching];
    
    return request;
}

+ (NSArray *)fetchWithCondition:(id)condition
                      withOrder:(NSString *)order
                     fetchLimit:(NSNumber *)fetchLimit
                      inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self createFetchRequestWithCondition:condition
                                                          withOrder:order
                                                         fetchLimit:fetchLimit
                                                          inContext:context];
    
    NSError *error = nil;
    NSArray *result = [context executeFetchRequest:request error:&error];
    
    if (result == nil) {
        NSLog(@"ERROR WHILE EXECUTE FETCH REEQUEST %@", error);
    }
    return result;
}

+ (NSUInteger)countForFetchWithPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self createFetchRequestWithCondition:predicate
                                                          withOrder:nil
                                                         fetchLimit:nil
                                                          inContext:context];
    
    NSError *error = nil;
    NSUInteger count = [context countForFetchRequest:request error:&error];
    
    if (count == NSNotFound) {
        NSLog(@"ERROR WHILE EXECUTE COUNT FETCH REEQUEST %@", error);
    }
    return count;
}

- (instancetype)update:(NSDictionary *)propertis
{
    if (propertis && [propertis isKindOfClass:[NSDictionary class]]) {
        NSDictionary *attributes = [[self entity] attributesByName];
        NSDictionary *relationships = [[self entity] relationshipsByName];
        
        [propertis enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            
            NSString *localKey = [[self class] keyForRemoteKey:key inContext:self.managedObjectContext];
            
            if (attributes[localKey]) {
                [self setAttributeValue:obj forKey:localKey withAttribute:attributes[localKey]];
            }
            else if (relationships[localKey]) {
                [self setRelationshipValue:obj forKey:localKey withRelationship:relationships[localKey]];
            }
        }];
    }
    
    return self;
}

+ (NSCache *)keyMappingCache
{
    static NSCache *s_keyMappingCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_keyMappingCache = [NSCache new];
    });
    return s_keyMappingCache;
}

+ (NSString *)keyForRemoteKey:(NSString *)remoteKey inContext:(NSManagedObjectContext *)context
{
    NSString *localKey = [[self keyMappingCache] objectForKey:remoteKey];
    
    if (localKey == nil) {
        localKey = [self mappings][remoteKey];
        
        if (localKey == nil) {
            NSString *camelCasedProperty = [remoteKey toCamelCase];
            
            NSEntityDescription *entity = [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:context];
            
            if ([entity propertiesByName][camelCasedProperty]) {
                localKey = camelCasedProperty;
            }
        }
        
        if (localKey == nil) {
            localKey = remoteKey;
        }
        
        [[self keyMappingCache] setObject:localKey forKey:remoteKey];
    }
    
    return localKey;
}

- (void)setAttributeValue:(id)value forKey:(NSString *)key withAttribute:(NSAttributeDescription *)attribute
{
    if (value == [NSNull null]) {
        [self setNilValueForKey:key];
    }
    else {
        NSAttributeType attributeType = [attribute attributeType];
        
        if ((attributeType == NSStringAttributeType) && ([value isKindOfClass:[NSNumber class]])) {
            value = [value stringValue];
        }
        else if ([value isKindOfClass:[NSString class]]) {
            if ((attributeType == NSInteger16AttributeType) || (attributeType == NSInteger32AttributeType) || (attributeType == NSInteger64AttributeType)) {
                value = [NSNumber numberWithInteger:[value integerValue]];
            }
            else if (attributeType == NSFloatAttributeType || attributeType == NSDoubleAttributeType) {
                value = [NSNumber numberWithDouble:[value doubleValue]];
            }
            else if (attributeType == NSBooleanAttributeType) {
                value = [NSNumber numberWithBool:[value boolValue]];
            }
            else if (attributeType == NSDecimalAttributeType) {
                value = [NSDecimalNumber decimalNumberWithString:value];
            }
            else if (attributeType == NSDecimalAttributeType) {
                value = [NSDecimalNumber decimalNumberWithString:value];
            }
            else if (attributeType == NSBinaryDataAttributeType) {
                value = [value dataUsingEncoding:NSUTF8StringEncoding];
            }
        }
        
        [self setValue:value forKey:key];
    }
}

- (void)setRelationshipValue:(id)value forKey:(NSString *)key withRelationship:(NSRelationshipDescription *)relationship
{
    if (relationship.isToMany) {
        NSMutableArray *valueArray = [NSMutableArray array];
        
        if ([value isKindOfClass:[NSDictionary class]]) {
            Class class = NSClassFromString(relationship.destinationEntity.name);
            id object = nil;
            if ([class useFindOrCreate]) {
                [class findOrCreate:value inContext:self.managedObjectContext];
            }
            else {
                [class create:value inContext:self.managedObjectContext];
            }
            if (object) {
                [valueArray addObject:object];
            }
        }
        else if ([value isKindOfClass:[NSArray class]]) {
            NSArray *objects = (NSArray *)value;
            Class class = NSClassFromString(relationship.destinationEntity.name);
            
            [objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([obj isKindOfClass:[NSDictionary class]]) {
                    id object = nil;
                    if ([class useFindOrCreate]) {
                        [class findOrCreate:value inContext:self.managedObjectContext];
                    }
                    else {
                        [class create:value inContext:self.managedObjectContext];
                    }
                    if (object) {
                        [valueArray addObject:object];
                    }
                }
            }];
        }
        
        if (relationship.isOrdered) {
            NSMutableOrderedSet *set = [self mutableOrderedSetValueForKey:key];
            [set removeAllObjects];
            [set addObjectsFromArray:valueArray];
        }
        else {
            NSMutableSet *set = [self mutableSetValueForKey:key];
            [set removeAllObjects];
            [set addObjectsFromArray:valueArray];
        }
    }
    else {
        if ([value isKindOfClass:[NSDictionary class]]) {
            Class class = NSClassFromString(relationship.destinationEntity.name);
            id object = nil;
            if ([class useFindOrCreate]) {
                [class findOrCreate:value inContext:self.managedObjectContext];
            }
            else {
                [class create:value inContext:self.managedObjectContext];
            }
            if (object) {
                [self setValue:object forKey:key];
            }
        }
        else {
            [self setNilValueForKey:key];
        }
    }
}


@end
