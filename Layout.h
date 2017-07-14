//
//  Layout.h
//  waterFlowLayout
//
//  Created by 雅风 on 2017/7/14.
//  Copyright © 2017年 yafeng. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Layout;
@protocol LayoutDelegate <NSObject>

//@required
////决定cell的高度，必须实现的方法
//-(CGFloat)waterFlowLayout:(Layout *)layout heightForRowAtIndex:(NSInteger)index itemWidth:(CGFloat)width;

@optional
//决定cell的列数
-(NSInteger)columnCountInLayout:(Layout *)layout;

//决定cell的列的距离
-(CGFloat)columnMarginLayout:(Layout *)layout;

//决定cell的行的距离
-(CGFloat)rowMarginInLayout:(Layout *)layout;

//决定cell的边缘距离
-(UIEdgeInsets)edgeInsetInLayout:(Layout *)layout;



@end

@interface Layout : UICollectionViewLayout

@property(nonatomic,assign) id <LayoutDelegate>delegate;
-(NSInteger)columnCount;
-(CGFloat)columnMargin;
-(CGFloat)rowMargin;
-(UIEdgeInsets)defaultEdgeInsets;
@end
