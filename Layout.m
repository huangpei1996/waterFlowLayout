//
//  Layout.m
//  waterFlowLayout
//
//  Created by 雅风 on 2017/7/14.
//  Copyright © 2017年 yafeng. All rights reserved.
//

#import "Layout.h"

@interface Layout()

@property (nonatomic,strong)NSMutableArray *attrsArray;

@property (nonatomic,strong)NSMutableArray *columnHeight;

@property (nonatomic, assign) NSInteger noneDoubleTime;                                       ///< 没有生成大尺寸次数
@property (nonatomic, assign) NSInteger lastDoubleIndex;                                      ///< 最后一次大尺寸的列数
@property (nonatomic, assign) NSInteger lastFixIndex;                                         ///< 最后一次对齐矫正列数
@end

@implementation Layout
//列数
static const CGFloat columnCount = 3;
//每一列间距
static const CGFloat columnMargin = 10;
//每一行间距
static const CGFloat rowMargin = 10;
//边缘间距
static const UIEdgeInsets defaultEdgeInsets = {10,10,10,10};


//重写prepareLayout方法
-(void)prepareLayout{
    [super prepareLayout];
    // 判断如果有50个cell（首次刷新），就重新计算
    if ([self.collectionView numberOfItemsInSection:0] == 50) {
        [self.attrsArray removeAllObjects];
        [self.columnHeight removeAllObjects];
    }
    // 当列高度数组为空时，即为第一行计算，每一列的基础高度加上collection的边框的top值
    if (!self.columnHeight.count) {
        for (NSInteger i = 0; i < self.columnCount; i++) {
            [self.columnHeight addObject:@(self.defaultEdgeInsets.top)];
        }
    }
    // 遍历所有的cell，计算所有cell的布局
    for (NSInteger i = self.attrsArray.count; i < [self.collectionView numberOfItemsInSection:0]; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        // 计算布局属性并将结果添加到布局属性数组中
        [self.attrsArray addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
    }
    
}
//返回indexPath 位置cell对应的布局属性
-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
//    UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
//    //使用for循环，找出高度最短的那一列
//    //最短高度的列
//    NSInteger destColumn = 0;
//    CGFloat minColumnHeight = [self.columnHeight[0] doubleValue];
//    
//    for (NSInteger i = 1; i < self.columnCount; i++) {
//        CGFloat columnHeight = [self.columnHeight[i] doubleValue];
//        if (minColumnHeight > columnHeight) {
//            minColumnHeight = columnHeight;
//            destColumn = i;
//        }
//    }
//    CGFloat w = (self.collectionView.frame.size.width - self.defaultEdgeInsets.left - self.defaultEdgeInsets.right -(self.columnCount - 1) * self.columnMargin)/self.columnCount;
//    
//    CGFloat h = [self.delegate waterFlowLayout:self heightForRowAtIndex:indexPath.item itemWidth:w];
//    NSLog(@"w = %f",w);
//    
//    CGFloat x = self.defaultEdgeInsets.left + destColumn*(w + self.columnMargin);
//    
//    CGFloat y =minColumnHeight;
//    if (y != self.defaultEdgeInsets.top) {
//        y += self.rowMargin;
//    }
//    attr.frame = CGRectMake(x, y, w, h);
//    self.columnHeight[destColumn] = @(y + h);
//    return attr;
    UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    // collectionView的宽度
    CGFloat collectionViewW = self.collectionView.frame.size.width;
    // cell的宽度
    CGFloat w = (collectionViewW - self.defaultEdgeInsets.left - self.defaultEdgeInsets.right -
                 self.columnMargin * (self.columnCount - 1)) / self.columnCount;
    // cell的高度
    NSUInteger randomOfHeight = arc4random() % 100;
    CGFloat h = w * (randomOfHeight >= 50 ? 250 : 320) / 200;
    
    // cell应该拼接的列数
    NSInteger destColumn = 0;
    
    // 高度最小的列数高度
    CGFloat minColumnHeight = [self.columnHeight[0] doubleValue];
    // 获取高度最小的列数
    for (NSInteger i = 1; i < self.columnCount; i++) {
        CGFloat columnHeight = [self.columnHeight[i] doubleValue];
        if (minColumnHeight > columnHeight) {
            minColumnHeight = columnHeight;
            destColumn = i;
        }
    }
    
    // 计算cell的x
    CGFloat x = self.defaultEdgeInsets.left + destColumn * (w + self.columnMargin);
    // 计算cell的y
    CGFloat y = minColumnHeight;
    if (y != self.defaultEdgeInsets.top) {
        y += self.rowMargin;
    }
    
    // 随机数，用来随机生成大尺寸cell
    NSUInteger randomOfWhetherDouble = arc4random() % 100;
    
    // 判断是否放大
    if (destColumn < self.columnCount - 1                               // 放大的列数不能是最后一列（最后一列方法超出屏幕）
        && _noneDoubleTime >= 1                                         // 如果前个cell有放大就不放大，防止连续出现两个放大
        && (randomOfWhetherDouble >= 45 || _noneDoubleTime >= 8)        // 45%几率可能放大，如果累计8次没有放大，那么满足放大条件就放大
        && [self.columnHeight[destColumn] doubleValue] == [self.columnHeight[destColumn + 1] doubleValue] // 当前列的顶部和下一列的顶部要对齐
        && _lastDoubleIndex != destColumn) {             // 最后一次放大的列不等当前列，防止出现连续两列出现放大不美观
        _noneDoubleTime = 0;
        _lastDoubleIndex = destColumn;
        // 重定义当前cell的布局:宽度*2,高度*2
        attrs.frame = CGRectMake(x, y, w * 2 + self.columnMargin, h * 2 + self.rowMargin);
        // 当前cell列的高度就是当前cell的最大Y值
        self.columnHeight[destColumn] = @(CGRectGetMaxY(attrs.frame));
        // 当前cell列下一列的高度也是当前cell的最大Y值，因为cell宽度*2,占两列
        self.columnHeight[destColumn + 1] = @(CGRectGetMaxY(attrs.frame));
    } else {
        // 正常cell的布局
        if (_noneDoubleTime <= 3 || _lastFixIndex == destColumn) {                     // 如果没有放大次数小于3且当前列等于上次矫正的列，就不矫正
            attrs.frame = CGRectMake(x, y, w, h);
        } else if (self.columnHeight.count > destColumn + 1                         // 越界判断
                   && y + h - [self.columnHeight[destColumn + 1] doubleValue] < w * 0.1) { // 当前cell填充后和上一列的高度偏差不超过cell最大高度的10%，就和下一列对齐
            attrs.frame = CGRectMake(x, y, w, [self.columnHeight[destColumn + 1] doubleValue] - y);
            _lastFixIndex = destColumn;
        } else if (destColumn >= 1                                                   // 越界判断
                   && y + h - [self.columnHeight[destColumn - 1] doubleValue] < w * 0.1) { // 当前cell填充后和上上列的高度偏差不超过cell最大高度的10%，就和下一列对齐
            attrs.frame = CGRectMake(x, y, w, [self.columnHeight[destColumn - 1] doubleValue] - y);
            _lastFixIndex = destColumn;
        } else {
            attrs.frame = CGRectMake(x, y, w, h);
        }
        // 当前cell列的高度就是当前cell的最大Y值
        self.columnHeight[destColumn] = @(CGRectGetMaxY(attrs.frame));
        _noneDoubleTime += 1;
    }
    // 返回计算获取的布局
    return attrs;

}
//决定cell的排布

-(NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGFloat)rect{
    return self.attrsArray;
}
//决定collectionView的可滚动范围

-(CGSize)collectionViewContentSize{
    CGFloat maxHeight = [self.columnHeight[0] doubleValue];
    for (int i = 1; i < self.columnCount; i++) {
        CGFloat value = [self.columnHeight[i] doubleValue];
        if (maxHeight < value) {
            maxHeight = value;
            
        }
    }
    return CGSizeMake(0, maxHeight + self.defaultEdgeInsets.bottom);
}

-(NSInteger)columnCount{
    if ([self.delegate respondsToSelector:@selector(columnCountInLayout:)]) {
        return [self.delegate columnCountInLayout:self];}
        else{
            return columnCount;
        }
}
-(CGFloat)columnMargin{
    if ([self.delegate respondsToSelector:@selector(columnMarginLayout:)]) {
        return [self.delegate columnMarginLayout:self];
    }
    else{
        return columnMargin;
    }
}

-(CGFloat)rowMargin{
    if ([self.delegate respondsToSelector:@selector(rowMarginInLayout:)]) {
        return [self.delegate rowMarginInLayout:self];
    }
    else{
        return rowMargin;
    }
}
-(UIEdgeInsets)defaultEdgeInsets{
    if ([self.delegate respondsToSelector:@selector(edgeInsetInLayout:)]) {
        return [self.delegate edgeInsetInLayout:self];
    }
    else{
        return defaultEdgeInsets;
    }
}


//懒加载
-(NSMutableArray *)attrsArray{
    if (!_attrsArray) {
        _attrsArray = [NSMutableArray array];
    }
    return _attrsArray;
}

-(NSMutableArray *)columnHeight{
    if (!_columnHeight) {
        _columnHeight = [NSMutableArray array];
    }
    return _columnHeight;
}
@end

