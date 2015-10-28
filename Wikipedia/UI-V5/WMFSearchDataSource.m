//
//  WMFSearchDataSource.m
//  Wikipedia
//
//  Created by Corey Floyd on 10/27/15.
//  Copyright © 2015 Wikimedia Foundation. All rights reserved.
//

#import "WMFSearchDataSource.h"
#import "MWKTitle.h"
#import "MWKSavedPageList.h"
#import "WMFSearchResults.h"
#import "MWKSearchResult.h"
#import "WMFSearchResultCell.h"
#import "UIView+WMFDefaultNib.h"

@interface WMFSearchDataSource ()

@property (nonatomic, strong, readwrite) MWKSite* searchSite;
@property (nonatomic, strong, readwrite) WMFSearchResults* searchResults;
@property (nonatomic, strong, readwrite) MWKSavedPageList* savedPageList;

@end

@implementation WMFSearchDataSource

- (nonnull instancetype)initWithSearchSite:(MWKSite*)site searchResults:(WMFSearchResults*)searchResults savedPages:(MWKSavedPageList*)savedPages {
    NSParameterAssert(site);
    NSParameterAssert(searchResults);
    NSParameterAssert(savedPages);
    self = [super initWithItems:searchResults.results];
    if (self) {
        self.searchSite    = site;
        self.searchResults = searchResults;
        self.savedPageList = savedPages;

        self.cellClass = [WMFSearchResultCell class];

        @weakify(self);
        self.cellConfigureBlock = ^(WMFSearchResultCell* cell,
                                    MWKSearchResult* result,
                                    UICollectionView* collectionView,
                                    NSIndexPath* indexPath) {
            @strongify(self);
            MWKTitle* title = [self titleForIndexPath:indexPath];
            [cell setTitle:title highlightingSubstring:self.searchResults.searchTerm];
            [cell setSearchResultDescription:result.wikidataDescription];
            [cell setImageURL:result.thumbnailURL];
            [cell setSavedPageList:self.savedPageList];
        };
    }
    return self;
}

- (void)setCollectionView:(UICollectionView* __nullable)collectionView {
    [super setCollectionView:collectionView];
    [self.collectionView registerNib:[WMFSearchResultCell wmf_classNib] forCellWithReuseIdentifier:[WMFSearchResultCell identifier]];
}

- (nullable NSString*)displayTitle {
    return self.searchResults.searchTerm;
}

- (NSArray*)titles {
    return [[self.searchResults results] bk_map:^id (MWKSearchResult* obj) {
        return [self.searchSite titleWithString:obj.displayTitle];
    }];
}

- (NSUInteger)titleCount {
    return [self.searchResults.results count];
}

- (MWKSearchResult*)searchResultForIndexPath:(NSIndexPath*)indexPath {
    MWKSearchResult* result = self.searchResults.results[indexPath.row];
    return result;
}

- (MWKTitle*)titleForIndexPath:(NSIndexPath*)indexPath {
    MWKSearchResult* result = [self searchResultForIndexPath:indexPath];
    return [self.searchSite titleWithString:result.displayTitle];
}

- (NSIndexPath*)indexPathForTitle:(MWKTitle*)title {
    NSUInteger index = [self.titles indexOfObject:title];
    if (index == NSNotFound) {
        return nil;
    }
    return [NSIndexPath indexPathForItem:index inSection:0];
}

- (BOOL)canDeleteItemAtIndexpath:(NSIndexPath*)indexPath {
    return NO;
}

- (BOOL)noResults {
    return (self.searchResults && [self.searchResults.results count] == 0);
}

- (MWKHistoryDiscoveryMethod)discoveryMethod {
    return MWKHistoryDiscoveryMethodSearch;
}

- (CGFloat)estimatedItemHeight {
    return 60.f;
}

@end
