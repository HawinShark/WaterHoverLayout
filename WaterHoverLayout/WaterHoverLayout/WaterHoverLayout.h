//
//  WaterHoverLayout.h
//  jadeite
//
//  Created by mac on 2019/9/27.
//  Copyright © 2019 com.kuruo.ivan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class WaterHoverLayout;
@protocol WaterHoverLayoutDataSource;

@interface WaterHoverLayout : UICollectionViewLayout

@property (nonatomic, weak) IBOutlet id<WaterHoverLayoutDataSource> dataSource;

@property (nonatomic, assign) IBInspectable CGFloat minimumLineSpacing;
@property (nonatomic, assign) IBInspectable CGFloat minimumInteritemSpacing;
@property (nonatomic, assign) UIEdgeInsets sectionInset;

@property (nonatomic, assign) IBInspectable BOOL sectionHeadersPinToVisibleBounds;
//@property (nonatomic, assign) IBInspectable BOOL sectionFootersPinToVisibleBounds;

@end

@protocol WaterHoverLayoutDataSource <NSObject>

@required

/// 返回`计算后的高`
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(WaterHoverLayout *)layout
                itemWidth:(CGFloat)width
 heightForItemAtIndexPath:(NSIndexPath *)indexPath;

@optional

/// 动态切换`排数`(default = 2 if not return).
- (NSInteger)collectionView:(UICollectionView *)collectionView
                     layout:(WaterHoverLayout*)layout
    numberOfColumnInSection:(NSInteger)section;

/// 动态`行间距`
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(WaterHoverLayout*)layout minimumLineSpacingForSectionAtIndex:(NSInteger)section;
/// 动态`列间距`
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(WaterHoverLayout*)layout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section;
/// 动态`块偏移`
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(WaterHoverLayout*)layout
        insetForSectionAtIndex:(NSInteger)section;

/// 动态`块头部高度`
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(WaterHoverLayout*)layout referenceHeightForHeaderInSection:(NSInteger)section;
/// 动态`块尾部高度`
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(WaterHoverLayout*)layout referenceHeightForFooterInSection:(NSInteger)section;

@end



NS_ASSUME_NONNULL_END
