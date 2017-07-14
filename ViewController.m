//
//  ViewController.m
//  waterFlowLayout
//
//  Created by 雅风 on 2017/7/14.
//  Copyright © 2017年 yafeng. All rights reserved.
//

#import "ViewController.h"
#import "Layout.h"
#import "Shop.h"
#import "ShopCellCollectionViewCell.h"
#import <MJExtension.h>
#import <MJRefresh.h>


@interface ViewController ()<UICollectionViewDataSource,LayoutDelegate>

@property (nonatomic,weak) UICollectionView *collectionView;

@property (nonatomic,strong) NSMutableArray *shops;
@end

@implementation ViewController
static NSString *const ID = @"shop";


- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"start");
    [self setUpCollectionView];
    [self setupRefresh];
}
-(void)setUpCollectionView{
    Layout *layout = [[Layout alloc]init];
    layout.delegate = self;
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:layout];
    [self.view addSubview:collectionView];
    _collectionView = collectionView;
    collectionView.dataSource = self;
    NSLog(@"ID1 = %@",ID);
    [collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([ShopCellCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:ID];
    NSLog(@"ID2 = %@",ID);
}
//创建上下刷新
-(void)setupRefresh{
    self.collectionView.mj_header = [MJRefreshNormalHeader
                                     headerWithRefreshingTarget:self refreshingAction:@selector(loadNewShops)];
    self.collectionView.mj_footer = [MJRefreshAutoNormalFooter
                                     footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreShops)];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView.mj_header beginRefreshing];
}
//加载下拉数据
-(void)loadNewShops{
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *shops = [Shop mj_objectArrayWithFilename:@"1.plist"];
        NSLog(@"%@",shops);
        [weakSelf.shops removeAllObjects];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.collectionView reloadData];
            [weakSelf.shops addObjectsFromArray:shops];
            [weakSelf.collectionView.mj_header endRefreshing];
            [weakSelf.collectionView reloadData];
        });
    });
    
}
//加载上拉数据
-(void)loadMoreShops{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *shops = [Shop mj_objectArrayWithFilename:@"1.plist"];
        [weakSelf.shops addObjectsFromArray:shops];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.collectionView.mj_footer endRefreshing];
            [weakSelf.collectionView reloadData];
        });
    });

}

-(NSUInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    self.collectionView.mj_footer.hidden = self.shops.count == 0;
    return self.shops.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ShopCellCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
    if (self.shops && self.shops.count >= indexPath.item + 1)  {
        cell.shop = self.shops[indexPath.item];
        
    }
    return cell;
}
-(NSInteger)columnCountInLayout:(Layout *)layout{
    return 3;
}
-(CGFloat)columnMarginLayout:(Layout *)layout{
    return 10;
}
-(CGFloat)rowMarginInLayout:(Layout *)layout{
    return 10;
}
-(UIEdgeInsets)edgeInsetInLayout:(Layout *)layout{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}
//- (CGFloat)waterFlowLayout:(Layout *)waterFlowLayout heightForRowAtIndex:(NSInteger)index itemWidth:(CGFloat)width{
//    return arc4random() % 100;
//}
- (NSMutableArray *)shops
{
    if (!_shops) {
        _shops = [NSMutableArray array];
    }
    return _shops;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
