
/**
 
 This is code that I reversed from sharingd LaunchDaemon, the reason i included this code is
 becausae this process is one that we are intervening on to prevent the exception through at the
 if (!handler) { check
 }
 
 there is PROBABLY a more proper way to fix this, but I'm honestly not certain apple had any intention
 on making AirDrop ever work bidirectionally on tvOS.
 
 I realize some of the code isn't PERFECT replica, but its close enough to follow the flow.
 
 */

@implementation SDAirDropTransferManager

- (void)askEventForRecordID:(id)recordID withResults:(id)results {

	SFAirDropTransfer *transfer = [SFAirDropTransfer initWithIdentifier:recordID initialInformation:results]
	[transfer updateWithInformation: results]; 
	NSSet *itemTypes = [self itemTypesForTransfer:transfer];
	SFAirDropTransferMetaData *metadata = [transfer metaData];
	[metaData setItems:itemTypes];

	NSMutableDictionary *transferIdentifier = [self transferIdentifierToTransfer];
	[transferIdentifier setObject:transfer forKeyedSubscript:recordID]; 
	id handler = [self determineHandlerForTransfer:transfer]; 

        //if handler is null throw an exception
        if (!handler) {

          NSString *errorString = [NSString stringWithUTF8String:"/BuildRoot/Library/Caches/com.apple.xbs/Sources/Sharing_executables/Sharing-1288.62/Daemon/SDAirDropTransferManager.m"];
          if (!errorString) {
             errorString = CFSTR("<Unknown File>");
           }
            NSAssertionHandler *assertionHandler = [NSAssertionHandler currentHandler];
             [assertionHandler handleFailureInMethod:@"askEventForRecordID:withResults:" object:self file:errorString lineNumber:133 description:@"Failed to find valid handler for transfer"];           
        }      
          //never get this far

	id keys = [self kvoObservingKeys];
	[transfer addObserver:self forKeysPaths:keys: options:0LL context:SDAirDropTransferManagerObserverContext];
	
    /*
     
     theres more code after this that i didnt bother to reverse. just for posterity on what is happening that
     we intervere with to prevent sharingd from quitting.
     
     */
}


@end
