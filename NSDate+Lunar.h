//
//  NSDate+Lunar.h
//  Lunar
//
//  Created by Apple on 2019/12/4.
//  Copyright © 2019 Geniune. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SectionalModel : NSObject

@property (nonatomic, strong) NSDate *presentDate;
@property (nonatomic, strong) NSString *sectional;
@property (nonatomic, strong) NSString *stem;

@end

@interface NSDate (Lunar)

#pragma mark - 公历数据
- (NSInteger)year;
- (NSInteger)month;
- (NSInteger)day;
- (NSInteger)hour;

#pragma mark - 农历数据

- (BOOL)bissextile; //判断闰年

- (NSString *)chinaMonth;
- (NSString *)chinaDay;
- (NSString *)chinaHour;

#pragma mark - 干支
- (NSString *)yearStream;
- (NSString *)monthStream;
- (NSString *)dayStream;
- (NSString *)hourStream;

#pragma mark - 属相/生肖
- (NSString *)zodiac;

#pragma mark - 五行
- (NSString *)yearElement;
- (NSString *)monthElement;
- (NSString *)dayElement;
- (NSString *)hourElement;

@end

