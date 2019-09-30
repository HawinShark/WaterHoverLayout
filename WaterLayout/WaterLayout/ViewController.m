//
//  ViewController.m
//  WaterLayout
//
//  Created by mac on 2019/9/30.
//  Copyright © 2019 com.ivan. All rights reserved.
//

#import "ViewController.h"
#import "WaterHoverLayout.h"
#import "WaterCollectionViewCell.h"

static NSString * const headerId = @"headerId";
static NSString * const cellId   = @"cellId";
static NSString * const footerId = @"footerId";

NSInteger const sections = 2;
NSInteger const numbers = 10;

@interface ViewController () <
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    WaterHoverLayoutDataSource
>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UICollectionView *c = _collectionView;
    
    [c registerNib:[UINib nibWithNibName:NSStringFromClass(WaterCollectionViewCell.class) bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:cellId];
    
    [c registerClass:UICollectionReusableView.class forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerId];
    [c registerClass:UICollectionReusableView.class forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:footerId];
}


#pragma mark - DataSource && Delegate

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    BOOL isHead = [kind isEqualToString:UICollectionElementKindSectionHeader];
    UICollectionReusableView *reusableView = [collectionView
                                              dequeueReusableSupplementaryViewOfKind:kind
                                              withReuseIdentifier:isHead ? headerId : footerId forIndexPath:indexPath];
    reusableView.backgroundColor = [UIColor whiteColor];
    {
        [reusableView removeAllSubViews];
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont fontWithName:@"PingFangSC-Medium" size:12];
        label.textColor = isHead ? [UIColor lightGrayColor] : [UIColor orangeColor];
        label.text = @"[哎呀呀..😢]";
        [label sizeToFit];
        [reusableView addSubview:label];
    }
    return reusableView;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return sections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return numbers;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WaterCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(WaterCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(8_0) {
    cell.textLabel.text = [NSString stringWithFormat:@"[%ld列%ld行]", indexPath.section, indexPath.row];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"[宝宝乖~😻]");
}

#pragma mark - WaterLayout

/// 返回`计算后的高`
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(WaterHoverLayout *)layout
                itemWidth:(CGFloat)width
 heightForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat rate = 1.f + (indexPath.row % 10) / 10.f;
    return width * rate;
}

/// 动态`块偏移`
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(WaterHoverLayout*)layout
        insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(numbers, numbers, numbers, numbers);
}

/// 动态`块头部高度`
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(WaterHoverLayout*)layout referenceHeightForHeaderInSection:(NSInteger)section {
    return 20;
}

/// 动态`块尾部高度`
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(WaterHoverLayout *)layout referenceHeightForFooterInSection:(NSInteger)section {
    return 20;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

@implementation UIView (Extra)
- (void)removeAllSubViews{
    for (UIView *subview in self.subviews){
        [subview removeFromSuperview];
    }
}

@end
