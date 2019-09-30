//
//  WaterHoverLayout.m
//  jadeite
//
//  Created by mac on 2019/9/27.
//  Copyright © 2019 com.kuruo.ivan. All rights reserved.
//

#import "WaterHoverLayout.h"

@interface WaterHoverLayout ()

///保存item的布局
@property (nonatomic, strong) NSMutableArray<NSMutableArray<UICollectionViewLayoutAttributes *> *> *itemLayoutAttributes;
///保存头视图的布局
@property (nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes *> *headerLayoutAttributes;
///保存尾视图的布局
@property (nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes *> *footerLayoutAttributes;

@property (nonatomic, strong) NSMutableArray<NSNumber *> *heightOfSections;
@property (nonatomic, assign) CGFloat contentHeight;

@end

/// 默认行数
NSInteger const defaultColumn = 2;

@implementation WaterHoverLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        _sectionInset = UIEdgeInsetsZero;
    }
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];
    
    NSAssert(self.dataSource != nil, @"WaterHoverLayout.dataSource cann't be nil.");
    if (self.collectionView.isDecelerating || self.collectionView.isDragging) {
        return;
    }
    
    _contentHeight = 0.0;
    _itemLayoutAttributes = [NSMutableArray array];
    _headerLayoutAttributes = [NSMutableArray array];
    _footerLayoutAttributes = [NSMutableArray array];
    _heightOfSections = [NSMutableArray array];
    
    [self prepareLayoutCalculate];
}

- (void)prepareLayoutCalculate {
    
    UICollectionView *collectionView = self.collectionView;
    NSInteger const numberOfSections = collectionView.numberOfSections;
    UIEdgeInsets const contentInset = collectionView.contentInset;
    CGFloat const contentWidth = collectionView.bounds.size.width - contentInset.left - contentInset.right;
    
///-------------------------------------------------------------------------------------------------------------
    
    for (NSInteger section=0; section < numberOfSections; section++) {
        NSInteger columnOfSection = defaultColumn;
        if ([self.dataSource respondsToSelector:@selector(collectionView:layout:numberOfColumnInSection:)]) {
            columnOfSection = [self.dataSource collectionView:collectionView layout:self numberOfColumnInSection:section];
        }
        UIEdgeInsets const contentInsetOfSection = [self contentInsetForSection:section];
        CGFloat const minimumLineSpacing = [self minimumLineSpacingForSection:section];
        CGFloat const minimumInteritemSpacing = [self minimumInteritemSpacingForSection:section];
        CGFloat const contentWidthOfSection = contentWidth - contentInsetOfSection.left - contentInsetOfSection.right;
        CGFloat const itemWidth = (contentWidthOfSection-(columnOfSection-1)*minimumInteritemSpacing) / columnOfSection;
        NSInteger const numberOfItems = [collectionView numberOfItemsInSection:section];
        
///-------------------------------------------------------------------------------------------------------------
        CGFloat headerHeight = 0.0;
        if ([self.dataSource respondsToSelector:@selector(collectionView:layout:referenceHeightForHeaderInSection:)]) {
            headerHeight = [self.dataSource collectionView:collectionView layout:self referenceHeightForHeaderInSection:section];
            UICollectionViewLayoutAttributes *headerLayoutAttribute = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
            headerLayoutAttribute.frame = CGRectMake(0.0, _contentHeight, contentWidth, headerHeight);
            [_headerLayoutAttributes addObject:headerLayoutAttribute];
        }
///-------------------------------------------------------------------------------------------------------------
        
        CGFloat offsetOfColumns[columnOfSection];
        for (NSInteger i=0; i<columnOfSection; i++) {
            offsetOfColumns[i] = headerHeight + contentInsetOfSection.top;
        }
        
        NSMutableArray *layoutAttributeOfSection = [NSMutableArray arrayWithCapacity:numberOfItems];
        for (NSInteger item=0; item<numberOfItems; item++) {
            NSInteger currentColumn = 0;
            for (NSInteger i=1; i<columnOfSection; i++) {
                if (offsetOfColumns[currentColumn] > offsetOfColumns[i]) {
                    currentColumn = i;
                }
            }
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            CGFloat itemHeight = [self.dataSource collectionView:collectionView layout:self itemWidth:itemWidth heightForItemAtIndexPath:indexPath];
            CGFloat x = contentInsetOfSection.left + itemWidth*currentColumn + minimumInteritemSpacing*currentColumn;
            CGFloat y = offsetOfColumns[currentColumn] + (item>=columnOfSection ? minimumLineSpacing : 0.0);
            
            UICollectionViewLayoutAttributes *layoutAttbiture = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            layoutAttbiture.frame = CGRectMake(x, y+_contentHeight, itemWidth, itemHeight);
            [layoutAttributeOfSection addObject:layoutAttbiture];
            
            offsetOfColumns[currentColumn] = (y + itemHeight);
        }
        [_itemLayoutAttributes addObject:layoutAttributeOfSection];
        
///-------------------------------------------------------------------------------------------------------------
        
        /// 当前块高度
        CGFloat maxOffsetValue = offsetOfColumns[0];
        for (int i=1; i<columnOfSection; i++) {
            if (offsetOfColumns[i] > maxOffsetValue) {
                maxOffsetValue = offsetOfColumns[i];
            }
        }
        maxOffsetValue += contentInsetOfSection.bottom;
        
///-------------------------------------------------------------------------------------------------------------
        CGFloat footerHeader = 0.0;
        if ([self.dataSource respondsToSelector:@selector(collectionView:layout:referenceHeightForFooterInSection:)]) {
            footerHeader = [self.dataSource collectionView:collectionView layout:self referenceHeightForFooterInSection:section];
            UICollectionViewLayoutAttributes *footerLayoutAttribute = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
            footerLayoutAttribute.frame = CGRectMake(0.0, _contentHeight+maxOffsetValue, contentWidth, headerHeight);
            [_footerLayoutAttributes addObject:footerLayoutAttribute];
        }
///-------------------------------------------------------------------------------------------------------------
        
        /// 保存每块的高度（包含头尾）
        CGFloat currentSectionHeight = maxOffsetValue + footerHeader;
        [_heightOfSections addObject:@(currentSectionHeight)];
        
        /// 更新高度
        _contentHeight += currentSectionHeight;
    }
    
}

- (CGSize)collectionViewContentSize {
    UIEdgeInsets contentInset = self.collectionView.contentInset;
    CGFloat width = CGRectGetWidth(self.collectionView.bounds) - contentInset.left - contentInset.right;
    CGFloat height = MAX(CGRectGetHeight(self.collectionView.bounds), _contentHeight);
    return CGSizeMake(width, height);
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray<UICollectionViewLayoutAttributes *> *result = [NSMutableArray array];
    [_itemLayoutAttributes enumerateObjectsUsingBlock:^(NSMutableArray<UICollectionViewLayoutAttributes *> *layoutAttributeOfSection, NSUInteger idx, BOOL *stop) {
        [layoutAttributeOfSection enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *attribute, NSUInteger idx, BOOL *stop) {
            if (CGRectIntersectsRect(rect, attribute.frame)) {
                [result addObject:attribute];
            }
        }];
    }];
    [_headerLayoutAttributes enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *attribute, NSUInteger idx, BOOL *stop) {
        if (attribute.frame.size.height && CGRectIntersectsRect(rect, attribute.frame)) {
            [result addObject:attribute];
        }
    }];
    [_footerLayoutAttributes enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *attribute, NSUInteger idx, BOOL *stop) {
        if (attribute.frame.size.height && CGRectIntersectsRect(rect, attribute.frame)) {
            [result addObject:attribute];
        }
    }];
    
    /// 头部悬停
    if (_sectionHeadersPinToVisibleBounds) {
        for (UICollectionViewLayoutAttributes *attriture in result) {
            if (![attriture.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) continue;
            NSInteger section = attriture.indexPath.section;
            UIEdgeInsets contentInsetOfSection = [self contentInsetForSection:section];
            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];
            UICollectionViewLayoutAttributes *itemAttribute = [self layoutAttributesForItemAtIndexPath:firstIndexPath];
            if (!itemAttribute) continue;
            CGFloat headerHeight = CGRectGetHeight(attriture.frame);
            CGRect frame = attriture.frame;
            frame.origin.y = MIN(
                                 MAX(self.collectionView.contentOffset.y, CGRectGetMinY(itemAttribute.frame)-headerHeight-contentInsetOfSection.top),
                                 CGRectGetMinY(itemAttribute.frame)+[_heightOfSections[section] floatValue]
                                 );
            attriture.frame = frame;
            attriture.zIndex = (NSIntegerMax/2)+section;
        }
    }
    
    return result;
}

/// 插入item时系统会调用
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_itemLayoutAttributes.count <= indexPath.section || _itemLayoutAttributes[indexPath.section].count <= indexPath.item) {
        return nil;
    }
    return _itemLayoutAttributes[indexPath.section][indexPath.item];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        for (UICollectionViewLayoutAttributes *attributes in _headerLayoutAttributes) {
            if (attributes.indexPath.section == indexPath.section) {
                return attributes;
            }
        }
    }
    if ([elementKind isEqualToString:UICollectionElementKindSectionFooter]) {
        for (UICollectionViewLayoutAttributes *attributes in _footerLayoutAttributes) {
            if (attributes.indexPath.section == indexPath.section) {
                return attributes;
            }
        }
    }
    return nil;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    if (_sectionHeadersPinToVisibleBounds) {
        return YES;
    }
    return [super shouldInvalidateLayoutForBoundsChange:newBounds];
}


#pragma mark Private

- (UIEdgeInsets)contentInsetForSection:(NSInteger)section {
    UIEdgeInsets edgeInsets = _sectionInset;
    if ([self.dataSource respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
        edgeInsets = [self.dataSource collectionView:self.collectionView layout:self insetForSectionAtIndex:section];
    }
    return edgeInsets;
}

- (CGFloat)minimumLineSpacingForSection:(NSInteger)section {
    CGFloat minimumLineSpacing = self.minimumLineSpacing;
    if ([self.dataSource respondsToSelector:@selector(collectionView:layout:minimumLineSpacingForSectionAtIndex:)]) {
        minimumLineSpacing = [self.dataSource collectionView:self.collectionView layout:self minimumLineSpacingForSectionAtIndex:section];
    }
    return minimumLineSpacing;
}

- (CGFloat)minimumInteritemSpacingForSection:(NSInteger)section {
    CGFloat minimumInteritemSpacing = self.minimumInteritemSpacing;
    if ([self.dataSource respondsToSelector:@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)]) {
        minimumInteritemSpacing = [self.dataSource collectionView:self.collectionView layout:self minimumInteritemSpacingForSectionAtIndex:section];
    }
    return minimumInteritemSpacing;
}

@end
