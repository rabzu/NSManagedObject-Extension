@implementation ExtendedManagedObject

@synthesize traversed

#pragma mark -
#pragma mark Dictionary conversion methods

- (NSDictionary*) toDictionary
{
    self.traversed = YES;

    NSArray* attributes = [[[self entity] attributesByName] allKeys];
    NSArray* relationships = [[[self entity] relationshipsByName] allKeys];
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:
                                 [attributes count] + [relationships count] + 1];

    [dict setObject:[[self class] description] forKey:@"class"];

    for (NSString* attr in attributes) {
        NSObject* value = [self valueForKey:attr];

        if (value != nil) {
            [dict setObject:value forKey:attr];
        }
    }

    for (NSString* relationship in relationships) {
        NSObject* value = [self valueForKey:relationship];

        if ([value isKindOfClass:[NSSet class]]) {
            // To-many relationship

            // The core data set holds a collection of managed objects
            NSSet* relatedObjects = (NSSet*) value;

            // Our set holds a collection of dictionaries
            NSMutableSet* dictSet = [NSMutableSet setWithCapacity:[relatedObjects count]];

            for (ExtendedManagedObject* relatedObject in relatedObjects) {
                if (!relatedObject.traversed) {
                    [dictSet addObject:[relatedObject toDictionary]];
                }
            }

            [dict setObject:dictSet forKey:relationship];
        }
        else if ([value isKindOfClass:[ExtendedManagedObject class]]) {
            // To-one relationship

            ExtendedManagedObject* relatedObject = (ExtendedManagedObject*) value;

            if (!relatedObject.traversed) {
                // Call toDictionary on the referenced object and put the result back into our dictionary.
                [dict setObject:[relatedObject toDictionary] forKey:relationship];
            }
        }
    }

    return dict;
}


- (void) populateFromDictionary:(NSDictionary*)dict
{
    NSManagedObjectContext* context = [self managedObjectContext];

    for (NSString* key in dict) {
        if ([key isEqualToString:@"class"]) {
            continue;
        }

        NSObject* value = [dict objectForKey:key];

        if ([value isKindOfClass:[NSDictionary class]]) {
            // This is a to-one relationship
            ExtendedManagedObject* relatedObject =
                [ExtendedManagedObject createManagedObjectFromDictionary:(NSDictionary*)value
                                                               inContext:context];

            [newObject setValue:relatedObject forKey:key];
        }
        else if ([value isKindOfClass:[NSSet class]]) {
            // This is a to-many relationship
            NSSet* relatedObjectDictionaries = (NSSet*) value;

            // Get a proxy set that represents the relationship, and add related objects to it.
            // (Note: this is provided by Core Data)
            NSMutableSet* relatedObjects = [newObject mutableSetValueForKey:key];

            for (NSDictionary* relatedObjectDict in relatedObjectDictionaries) {
                ExtendedManagedObject* relatedObject =
                    [ExtendedManagedObject createManagedObjectFromDictionary:relatedObjectDict
                                                                   inContext:context];
                [relatedObjects addObject:relatedObject];
            }
        }
        else if (value != nil) {
            // This is an attribute
            [newObject setValue:value forKey:key];
        }
    }
}

+ (ExtendedManagedObject*) createManagedObjectFromDictionary:(NSDictionary*)dict
                                                   inContext:(NSManagedObjectContext*)context
{
    NSString* class = [dict objectForKey:@"class"];
    ExtendedManagedObject* newObject =
        (ExtendedManagedObject*)[NSEntityDescription insertNewObjectForEntityForName:class
                                                              inManagedObjectContext:context];

    [newObject populateFromDictionary:dict];

    return newObject;
}

@end