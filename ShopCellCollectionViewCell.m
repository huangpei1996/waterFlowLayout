//
//  ShopCellCollectionViewCell.m
//  waterFlowLayout
//
//  Created by 雅风 on 2017/7/14.
//  Copyright © 2017年 yafeng. All rights reserved.
//

#import "ShopCellCollectionViewCell.h"
#import "Shop.h"
#import <UIImageView+WebCache.h>

@interface ShopCellCollectionViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;


@end
@implementation ShopCellCollectionViewCell
-(void)setShop:(Shop *)shop{
    _shop = shop;
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:shop.img] placeholderImage:[UIImage imageNamed:@"loading"]];
    self.priceLabel.text = shop.price;
}

@end
