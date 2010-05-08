@interface ExtendedManagedObject : NSManagedObject {
    BOOL traversed;
}

@property (nonatomic, assign) BOOL traversed;

- (NSDictionary*) toDictionary;
+ (ExtendedManagedObject*) createManagedObjectFromDictionary:(NSDictionary*)dict
                                                   inContext:(NSManagedObjectContext*)context;

@end