@import XCTest;

#import "NYPLCatalogFacet.h"
#import "NYPLOPDSLink.h"
#import "NYPLXML.h"

@interface NYPLCatalogFacetTests : XCTestCase

@end

static NYPLOPDSLink *biographyXML = nil;
static NYPLOPDSLink *scienceFictionXML = nil;

@implementation NYPLCatalogFacetTests

+ (void)setUp
{
  {
    NSString *const XMLString = (@"<link rel=\"http://opds-spec.org/facet\""
                                 @" href=\"http://example.com/biography\""
                                 @" title=\"Biography\""
                                 @" opds:facetGroup=\"Categories\"/>");
    
    NYPLXML *const XML = [NYPLXML XMLWithData:[XMLString dataUsingEncoding:NSUTF8StringEncoding]];
    
    biographyXML = [[NYPLOPDSLink alloc] initWithXML:XML];
    
    assert(biographyXML);
  }
  
  {
    NSString *const XMLString = (@"<link rel=\"http://opds-spec.org/facet\""
                                 @" href=\"http://example.com/sci-fi\""
                                 @" title=\"Science-Fiction\""
                                 @" opds:activeFacet=\"true\"/>");
    
    NYPLXML *const XML = [NYPLXML XMLWithData:[XMLString dataUsingEncoding:NSUTF8StringEncoding]];
    
    scienceFictionXML = [[NYPLOPDSLink alloc] initWithXML:XML];
    
    assert(scienceFictionXML);
  }
}

- (void)testBiography
{
  NYPLCatalogFacet *const facet = [NYPLCatalogFacet catalogFacetWithLink:biographyXML];
  
  XCTAssert(facet);
  
  XCTAssert(!facet.active);
  
  XCTAssertEqualObjects(facet.href, [[NSURL alloc] initWithScheme:@"http"
                                                             host:@"example.com"
                                                             path:@"/biography"]);
  
  XCTAssertEqualObjects(facet.title, @"Biography");
}

- (void)testScienceFiction
{
  NYPLCatalogFacet *const facet = [NYPLCatalogFacet catalogFacetWithLink:scienceFictionXML];
  
  XCTAssert(facet);
  
  XCTAssert(facet.active);
  
  XCTAssertEqualObjects(facet.href, [[NSURL alloc] initWithScheme:@"http"
                                                             host:@"example.com"
                                                             path:@"/sci-fi"]);
  
  XCTAssertEqualObjects(facet.title, @"Science-Fiction");
}

@end
