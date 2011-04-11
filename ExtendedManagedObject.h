@interface ExtendedManagedObject : NSManagedObject {
    BOOL traversed;
}

@property (nonatomic, assign) BOOL traversed;

- (NSDictionary*) toDictionary;
- (void) populateFromDictionary:(NSDictionary*)dict;
+ (ExtendedManagedObject*) createManagedObjectFromDictionary:(NSDictionary*)dict
                                                   inContext:(NSManagedObjectContext*)context;

@end