//
//  NSDate+Lunar.m
//  Lunar
//
//  Created by Apple on 2019/12/4.
//  Copyright © 2019 Geniune. All rights reserved.
//

#import "NSDate+Lunar.h"
#import <objc/runtime.h>

#define baseYear  1901

static NSCalendar *calendar;//公历 NSCalendar类对象
static NSCalendar *chinaCalendar;//农历 NSCalendar类对象

//static NSArray *weekArray;//星期

static NSArray *chineseMonths;//农历月
static NSArray *chineseDays;//农历天
static NSArray *arrSterns;//天干
static NSArray *arrBranches;//地支
static NSArray *arrZodiacs;//属相

static NSDictionary *StemsElementDic;//天干 对应五行
static NSDictionary *BranchesDic;//地支 对应五行

static NSArray *monthStreamTable;
static NSArray *dailyTable;

static NSArray *sectionalTermNames;
static NSArray *principleTermNames;
static NSArray *sectionalTermMap;
static NSArray *sectionalTermYear;
static NSArray *principleTermMap;
static NSArray *principleTermYear;

static NSArray *year_sterns; //用于计算年干
static NSArray *year_branches;//用于计算年支

//Heavenly Sterns //天干
//Earthly Branches //地支

@implementation SectionalModel

@end

@implementation NSDate (Lunar)

+ (void)load{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
        chinaCalendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierChinese];
        [self setupData];
    });
}

+ (void)setupData{

    dailyTable = @[@"癸未",
                            @"甲子",@"乙丑",@"丙寅",@"丁卯",@"戊辰",@"己巳",@"庚午",@"辛未",@"壬申",@"癸酉",
                            @"甲戌",@"乙亥",@"丙子",@"丁丑",@"戊寅",@"己卯",@"庚辰",@"辛巳",@"壬午",@"癸未",
                            @"甲申",@"乙酉",@"丙戌",@"丁亥",@"戊子",@"己丑",@"庚寅",@"辛卯",@"壬辰",@"癸巳",
                            @"甲午",@"乙未",@"丙申",@"丁酉",@"戊戌",@"己亥",@"庚子",@"辛丑",@"壬寅",@"癸卯",
                            @"甲辰",@"乙巳",@"丙午",@"丁未",@"戊申",@"己酉",@"庚戌",@"辛亥",@"壬子",@"癸丑",
                            @"甲寅",@"乙卯",@"丙辰",@"丁巳",@"戊午",@"己未",@"庚申",@"辛酉",@"壬戌",@"癸亥"
    ];
        
    chineseMonths = [NSArray arrayWithObjects:@"正", @"二", @"三", @"四", @"五", @"六", @"七", @"八",@"九", @"十", @"十一", @"腊", nil];
    chineseDays = [NSArray arrayWithObjects:@"初一",@"初二",@"初三",@"初四",@"初五",@"初六",@"初七",@"初八",@"初九",@"初十",@"十一",@"十二",@"十三",@"十四",@"十五", @"十六",@"十七",@"十八",@"十九",@"二十",@"廿一",@"廿二",@"廿三",@"廿四",@"廿五",@"廿六",@"廿七",@"廿八",@"廿九",@"三十",nil];
    
    arrSterns = @[@"甲",@"乙",@"丙",@"丁",@"戊",@"己",@"庚",@"辛",@"壬",@"癸"];
    arrBranches = @[@"子", @"丑",@"寅",@"卯",@"辰",@"巳",@"午",@"未",@"申",@"酉",@"戌",@"亥"];
    
    year_sterns = @[@"庚", @"辛", @"壬", @"癸", @"甲",@"乙",@"丙",@"丁",@"戊",@"己"];
    year_branches = @[ @"申", @"酉", @"戌", @"亥", @"子", @"丑", @"寅", @"卯", @"辰", @"巳", @"午", @"未"];
        
    arrZodiacs = @[@"鼠",@"牛",@"虎",@"兔",@"龙",@"蛇",@"马",@"羊",@"猴",@"鸡",@"狗",@"猪"];
        
    NSArray <NSArray *>*arr =
     @[
         @[@"丙寅",@"丁卯",@"戊辰",@"己巳",@"庚午",@"辛未",@"壬申",@"癸酉",@"甲戌",@"乙亥",@"丙子",@"丁丑"],//甲、己
         @[@"戊寅",@"己卯",@"庚辰",@"辛巳",@"壬午",@"癸未",@"甲申",@"乙酉",@"丙戌",@"丁亥",@"戊子",@"己丑"],//乙、庚
         @[@"庚寅",@"辛卯",@"壬辰",@"癸巳",@"甲午",@"乙未",@"丙申",@"丁酉",@"戊戌",@"己亥",@"庚子",@"辛丑"],//丙、辛
         @[@"壬寅",@"癸卯",@"甲辰",@"乙巳",@"丙午",@"丁未",@"戊申",@"己酉",@"庚戌",@"辛亥",@"壬子",@"癸丑"],//丁、壬
         @[@"甲寅",@"乙卯",@"丙辰",@"丁巳",@"戊午",@"己未",@"庚申",@"辛酉",@"壬戌",@"癸亥",@"甲子",@"乙丑"]//戊、癸
       ];
//        NSArray <NSArray *>*arr = @[
//        @[@"丙寅", @"戊寅", @"庚寅", @"壬寅", @"甲寅"], //寅月
//        @[@"丁卯", @"己卯", @"辛卯", @"癸卯", @"乙卯"], //卯月
//        @[@"戊辰", @"庚辰", @"壬辰", @"甲辰", @"丙辰"], //辰月
//        @[@"己巳", @"辛巳", @"癸巳", @"乙巳", @"丁巳"], //巳月
//        @[@"庚午", @"壬午", @"甲午", @"丙午", @"戊午"], //午月
//        @[@"辛未", @"癸未", @"乙未", @"丁未", @"己未"], //未月
//        @[@"壬申", @"甲申", @"丙申", @"戊申", @"庚申"], //申月
//        @[@"癸酉", @"乙酉", @"丁酉", @"己酉", @"辛酉"], //酉月
//        @[@"甲戌", @"丙戌", @"戊戌", @"庚戌", @"壬戌"], //戌月
//        @[@"乙亥", @"丁亥", @"己亥", @"辛亥", @"癸亥"], //子月
//        @[@"丙子", @"戊子", @"庚子", @"壬子", @"甲子"], //子月
//        @[@"丁丑", @"己丑", @"辛丑", @"癸丑", @"乙丑"]  //丑月
//        ];
        monthStreamTable = arr;
        
        StemsElementDic = @{
                                      @"甲":@"木",
                                      @"乙":@"木",
                                      @"丙":@"火",
                                      @"丁":@"火",
                                      @"戊":@"土",
                                      @"己":@"土",
                                      @"庚":@"金",
                                      @"辛":@"金",
                                      @"壬":@"水",
                                      @"癸":@"水",
                                      };
        
        BranchesDic = @{
                                 @"子":@"水",
                                 @"丑":@"土",
                                 @"寅":@"木",
                                 @"卯":@"木",
                                 @"辰":@"土",
                                 @"巳":@"火",
                                 @"午":@"火",
                                 @"未":@"土",
                                 @"申":@"金",
                                 @"酉":@"金",
                                 @"戌":@"土",
                                 @"亥":@"水",
                                 };
    
    //12节
    sectionalTermNames = @[@"小寒", @"立春", @"惊蛰", @"清明", @"立夏", @"芒种", @"小暑", @"立秋", @"白露", @"寒露", @"立冬", @"大雪"];
    //12气
    principleTermNames = @[@"大寒", @"雨水", @"春分", @"谷雨", @"小满", @"夏至", @"大暑", @"处暑", @"秋分", @"霜降", @"小雪", @"冬至"];
    
    sectionalTermMap = @[
    @[@(7), @(6), @(6), @(6), @(6), @(6), @(6), @(6), @(6), @(5), @(6), @(6), @(6), @(5), @(5), @(6), @(6), @(5), @(5), @(5), @(5), @(5), @(5), @(5), @(5), @(4), @(5), @(5)],
    @[@(5), @(4), @(5), @(5), @(5), @(4), @(4), @(5), @(5), @(4), @(4), @(4), @(4), @(4), @(4), @(4), @(4), @(3), @(4), @(4), @(4), @(3), @(3), @(4), @(4), @(3), @(3), @(3)],
    @[@(6), @(6), @(6), @(7), @(6), @(6), @(6), @(6), @(5), @(6), @(6), @(6), @(5), @(5), @(6), @(6), @(5), @(5), @(5), @(6), @(5), @(5), @(5), @(5), @(4), @(5), @(5), @(5), @(5)],
    @[@(5), @(5), @(6), @(6), @(5), @(5), @(5), @(6), @(5), @(5), @(5), @(5), @(4), @(5), @(5), @(5), @(4), @(4), @(5), @(5), @(4), @(4), @(4), @(5), @(4), @(4), @(4), @(4), @(5)],
    @[@(6), @(6), @(6), @(7), @(6), @(6), @(6), @(6), @(5), @(6), @(6), @(6), @(5), @(5), @(6), @(6), @(5), @(5), @(5), @(6), @(5), @(5), @(5), @(5), @(4), @(5), @(5), @(5), @(5)],
    @[@(6), @(6), @(7), @(7), @(6), @(6), @(6), @(7), @(6), @(6), @(6), @(6), @(5), @(6), @(6), @(6), @(5), @(5), @(6), @(6), @(5), @(5), @(5), @(6), @(5), @(5), @(5), @(5), @(4), @(5), @(5), @(5), @(5)],
    @[@(7), @(8), @(8), @(8), @(7), @(7), @(8), @(8), @(7), @(7), @(7), @(8), @(7), @(7), @(7), @(7), @(6), @(7), @(7), @(7), @(6), @(6), @(7), @(7), @(6), @(6), @(6), @(7), @(7)],
    @[@(8), @(8), @(8), @(9), @(8), @(8), @(8), @(8), @(7), @(8), @(8), @(8), @(7), @(7), @(8), @(8), @(7), @(7), @(7), @(8), @(7), @(7), @(7), @(7), @(6), @(7), @(7), @(7), @(6), @(6), @(7), @(7), @(7)],
    @[@(8), @(8), @(8), @(9), @(8), @(8), @(8), @(8), @(7), @(8), @(8), @(8), @(7), @(7), @(8), @(8), @(7), @(7), @(7), @(8), @(7), @(7), @(7), @(7), @(6), @(7), @(7), @(7), @(7)],
    @[@(9), @(9), @(9), @(9), @(8), @(9), @(9), @(9), @(8), @(8), @(9), @(9), @(8), @(8), @(8), @(9), @(8), @(8), @(8), @(8), @(7), @(8), @(8), @(8), @(7), @(7), @(8), @(8), @(8)],
    @[@(8), @(8), @(8), @(8), @(7), @(8), @(8), @(8), @(7), @(7), @(8), @(8), @(7), @(7), @(7), @(8), @(7), @(7), @(7), @(7), @(6), @(7), @(7), @(7), @(6), @(6), @(7), @(7), @(7)],
    @[@(7), @(8), @(8), @(8), @(7), @(7), @(8), @(8), @(7), @(7), @(7), @(8), @(7), @(7), @(7), @(7), @(6), @(7), @(7), @(7), @(6), @(6), @(7), @(7), @(6), @(6), @(6), @(7), @(7)]
    ];
    
    sectionalTermYear = @[
    @[@13, @49, @85, @117, @149, @185, @201, @250, @250],
    @[@13, @45, @81, @117, @149, @185, @201, @250, @250],
    @[@13, @48, @84, @112, @148, @184, @200, @201, @250],
    @[@13, @45, @76, @108, @140, @172, @200, @201, @250],
    @[@13, @44, @72, @104, @132, @168, @200, @201, @250],
    @[@5, @33, @68, @96, @124, @152, @188, @200, @201],
    @[@29, @57, @85, @120, @148, @176, @200, @201, @250],
    @[@13, @48, @76, @104, @132, @168, @196, @200, @201],
    @[@25, @60, @88, @120, @148, @184, @200, @201, @250],
    @[@16, @44, @76, @108, @144, @172, @200, @201, @250],
    @[@28, @60, @92, @124, @160, @192, @200, @201, @250],
    @[@17, @53, @85, @124, @156, @188, @200, @201, @250]
    ];
    
    principleTermMap = @[
    @[@21, @21, @21, @21, @21, @20, @21, @21, @21, @20, @20, @21, @21, @20, @20, @20, @20, @20, @20, @20, @20, @19, @20, @20, @20, @19, @19, @20],
    @[@20, @19, @19, @20, @20, @19, @19, @19, @19, @19, @19, @19, @19, @18, @19, @19, @19, @18, @18, @19, @19, @18, @18, @18, @18, @18, @18, @18],
    @[@21, @21, @21, @22, @21, @21, @21, @21, @20, @21, @21, @21, @20, @20, @21, @21, @20, @20, @20, @21, @20, @20, @20, @20, @19, @20, @20, @20, @20],
    @[@20, @21, @21, @21, @20, @20, @21, @21, @20, @20, @20, @21, @20, @20, @20, @20, @19, @20, @20, @20, @19, @19, @20, @20, @19, @19, @19, @20, @20],
    @[@21, @22, @22, @22, @21, @21, @22, @22, @21, @21, @21, @22, @21, @21, @21, @21, @20, @21, @21, @21, @20, @20, @21, @21, @20, @20, @20, @21, @21],
    @[@22, @22, @22, @22, @21, @22, @22, @22, @21, @21, @22, @22, @21, @21, @21, @22, @21, @21, @21, @21, @20, @21, @21, @21, @20, @20, @21, @21, @21],
    @[@23, @23, @24, @24, @23, @23, @23, @24, @23, @23, @23, @23, @22, @23, @23, @23, @22, @22, @23, @23, @22, @22, @22, @23, @22, @22, @22, @22, @23],
    @[@23, @24, @24, @24, @23, @23, @24, @24, @23, @23, @23, @24, @23, @23, @23, @23, @22, @23, @23, @23, @22, @22, @23, @23, @22, @22, @22, @23, @23],
    @[@23, @24, @24, @24, @23, @23, @24, @24, @23, @23, @23, @24, @23, @23, @23, @23, @22, @23, @23, @23, @22, @22, @23, @23, @22, @22, @22, @23, @23],
    @[@24, @24, @24, @24, @23, @24, @24, @24, @23, @23, @24, @24, @23, @23, @23, @24, @23, @23, @23, @23, @22, @23, @23, @23, @22, @22, @23, @23, @23],
    @[@23, @23, @23, @23, @22, @23, @23, @23, @22, @22, @23, @23, @22, @22, @22, @23, @22, @22, @22, @22, @21, @22, @22, @22, @21, @21, @22, @22, @22],
    @[@22, @22, @23, @23, @22, @22, @22, @23, @22, @22, @22, @22, @21, @22, @22, @22, @21, @21, @22, @22, @21, @21, @21, @22, @21, @21, @21, @21, @22]];
    
    principleTermYear = @[
    @[@13, @45, @81, @113, @149, @185, @201],
    @[@21, @57, @93, @125, @161, @193, @201],
    @[@21, @56, @88, @120, @152, @188, @200, @201],
    @[@21, @49, @81, @116, @144, @176, @200, @201],
    @[@17, @49, @77, @112, @140, @168, @200, @201],
    @[@28, @60, @88, @116, @148, @180, @200, @201],
    @[@25, @53, @84, @112, @144, @172, @200, @201],
    @[@29, @57, @89, @120, @148, @180, @200, @201],
    @[@17, @45, @73, @108, @140, @168, @200, @201],
    @[@28, @60, @92, @124, @160, @192, @200, @201],
    @[@16, @44, @80, @112, @148, @180, @200, @201],
    @[@17, @53, @88, @120, @156, @188, @200, @201]
    ];
}

#pragma mark - 公历
//public - 公历年
- (NSInteger)year{
    
    return [calendar component:NSCalendarUnitYear fromDate:self];
}

//public - 公历月
- (NSInteger)month{
    
    return [calendar component:NSCalendarUnitMonth fromDate:self];
}

//public - 公历日
- (NSInteger)day{
    
    return [calendar component:NSCalendarUnitDay fromDate:self];
}

//public - 公历时
- (NSInteger)hour{
    
    return [calendar component:NSCalendarUnitHour fromDate:self];
}

#pragma mark - 农历
//private - 农历年
- (NSInteger)chineseYear{
    
    return [chinaCalendar component:NSCalendarUnitYear fromDate:self];
}

//private - 农历月
- (NSInteger)chineseMonth{
    
    return [chinaCalendar component:NSCalendarUnitMonth fromDate:self];
}

//private - 农历日
- (NSInteger)chineseDay{
    
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
    NSDateComponents *localeComp = [chinaCalendar components:unitFlags fromDate:self];
    
    if(localeComp.hour >= 23){//特殊处理：如果已超过晚11点，农历日应按第二天计算
        return [chinaCalendar component:NSCalendarUnitDay fromDate:self] + 1;
    }else{
        return [chinaCalendar component:NSCalendarUnitDay fromDate:self];
    }
}

//private - 农历时
- (NSInteger)chineseHour{
    
    return [chinaCalendar component:NSCalendarUnitHour fromDate:self];
}

//public - 农历年
- (NSString *)chinaStream:(NSInteger)year{
    
    return [NSString stringWithFormat:@"%@%@", year_sterns[year % 10], year_branches[year % 12]];
}

//public - 农历月
- (NSString *)chinaMonth{
    
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
    NSDateComponents *localeComp = [chinaCalendar components:unitFlags fromDate:self];
    
    if(localeComp.isLeapMonth){
        return [NSString stringWithFormat:@"闰%@", [chineseMonths objectAtIndex:[self chineseMonth] - 1]];
    }else{
        return [chineseMonths objectAtIndex:[self chineseMonth] - 1];
    }
}

//public - 农历日
- (NSString *)chinaDay{
    return [chineseDays objectAtIndex:[self chineseDay] -1];
}

//public - 农历时
- (NSString *)chinaHour{
    
    //@"子", @"丑",@"寅",@"卯",@"辰",@"巳",@"午",@"未",@"申",@"酉",@"戌",@"亥"
    //农历时干支计算方法：
    //23~1  子时
    //1~3  丑时
    //3~5  寅时
    //5~7  卯时
    //7~9  辰时
    //9~11  巳时
    //11~13  午时
    //13~15  未时
    //15~17  申时
    //17~19  酉时
    //19~21  戌时
    //21~23  亥时
    switch ([self chineseHour]) {
        case 1:
        case 2:
            return [arrBranches objectAtIndex:1];
            break;
            
        case 3:
        case 4:
            return [arrBranches objectAtIndex:2];
            break;
            
        case 5:
        case 6:
            return [arrBranches objectAtIndex:3];
            break;
            
        case 7:
        case 8:
            return [arrBranches objectAtIndex:4];
            break;
            
        case 9:
        case 10:
            return [arrBranches objectAtIndex:5];
            break;
            
        case 11:
        case 12:
            return [arrBranches objectAtIndex:6];
            break;
            
        case 13:
        case 14:
            return [arrBranches objectAtIndex:7];
            break;
            
        case 15:
        case 16:
            return [arrBranches objectAtIndex:8];
            break;
            
        case 17:
        case 18:
            return [arrBranches objectAtIndex:9];
            break;
            
        case 19:
        case 20:
            return [arrBranches objectAtIndex:10];
            break;
            
        case 21:
        case 22:
            return [arrBranches objectAtIndex:11];
            break;
            
        case 23:
        case 0:
            return [arrBranches objectAtIndex:0];
            break;
            
        default:{
            
            return @"";
        }
            break;
    }
}

#pragma mark - 属相/生肖
- (NSString *)zodiac{

    NSString *branch = [[self yearStream] substringFromIndex:1];
    __block NSInteger zodiacIndex = 0;
    
    [arrBranches enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL * _Nonnull stop) {
        
        if([branch isEqualToString:obj]){
            zodiacIndex = index;
            *stop = YES;
        }
    }];
    
    return arrZodiacs[zodiacIndex];
}


#pragma mark - 干支
//public - 干支年
- (NSString *)yearStream{
    
    return [self calculatYearStem];
}

//public - 干支月
- (NSString *)monthStream{
    
    return [self calculatMonthStem];
}

//public - 干支日
- (NSString *)dayStream{
    
    return [self calculatDayStem];
}

//public - 干支时
- (NSString *)hourStream{
        
    return [self calculatHourStem];
}

- (NSString *)calculatYearStem{

    NSArray *sectionalArray = [self calutorSectionByYear:self.year];
    
    SectionalModel *firstSectionModel = sectionalArray[0];

//    typedef NS_CLOSED_ENUM(NSInteger, NSComparisonResult) {
//        NSOrderedAscending = -1L, //大于
//        NSOrderedSame, //相同
//        NSOrderedDescending //小于
//    };
    NSComparisonResult result = [self compare:firstSectionModel.presentDate];
    
    //判断列表第一个日期和当前日期，如果比他小，则需要计算前一年的节气
    if(result == NSOrderedAscending){
     
        NSMutableArray *frontSectionArray = [NSMutableArray array];
        [frontSectionArray addObjectsFromArray:[self calutorSectionByYear:self.year - 1]];
        [frontSectionArray addObjectsFromArray:sectionalArray];
        
        sectionalArray = frontSectionArray;
    }
    
    for(int i = 0;i < sectionalArray.count - 1;i ++){
        
        SectionalModel *present_model = sectionalArray[i];
        SectionalModel *next_model = sectionalArray[i + 1];
        
        NSComparisonResult result1 = [self compare:present_model.presentDate];
        NSComparisonResult result2 = [self compare:next_model.presentDate];

        if((result1 == NSOrderedSame || result1 == NSOrderedDescending) && result2 == NSOrderedAscending){//检查当前日期是否在两个节气之间
            
//            NSLog(@"节气：%@（%zd年%zd月%zd日）", present_model.sectional, present_model.presentDate.year, present_model.presentDate.month, present_model.presentDate.day);
//            NSLog(@"节气：%@（%zd年%zd月%zd日）", next_model.sectional, next_model.presentDate.year, next_model.presentDate.month, next_model.presentDate.day);

            if(sectionalArray.count == 24 && i < 12){//立春前，年干取上一年
                return [self chinaStream:self.year - 1];
            }else{
                return [self chinaStream:self.year];
            }
       }else{
           
           if([present_model.sectional isEqualToString:@"立春"] && sectionalArray.count == 12){
               
               //说明当前日期在立春之前，属于上个回归年
               NSMutableArray *frontSectionArray = [NSMutableArray array];
               [frontSectionArray addObjectsFromArray:[self calutorSectionByYear:self.year - 1]];
               [frontSectionArray addObjectsFromArray:sectionalArray];
               
               sectionalArray = frontSectionArray;
               i = 0;
               continue;
           }
        }
    }
    
    return @"";
}

- (NSString *)calculatMonthStem{
    
    NSString *streamStr;
    
    NSArray *sectionalArray = [self calutorSectionByYear:self.year];
    
    SectionalModel *firstSectionModel = sectionalArray[0];

    NSComparisonResult result = [self compare:firstSectionModel.presentDate];
    
    //判断列表第一个日期和当前日期，如果比他小，则需要计算前一年的节气
    if(result == NSOrderedAscending){
     
        NSMutableArray *frontSectionArray = [NSMutableArray array];
        [frontSectionArray addObjectsFromArray:[self calutorSectionByYear:self.year - 1]];
        [frontSectionArray addObjectsFromArray:sectionalArray];
        
        sectionalArray = frontSectionArray;
    }
    
    for(int i = 0;i < sectionalArray.count;i ++){
        
        SectionalModel *present_model = sectionalArray[i];
        SectionalModel *next_model = sectionalArray[i + 1];
        
        NSComparisonResult result1 = [self compare:present_model.presentDate]; //大于等于
        NSComparisonResult result2 = [self compare:next_model.presentDate]; //小于

        if((result1 == NSOrderedSame || result1 == NSOrderedDescending) && result2 == NSOrderedAscending){//检查当前日期是否在两个节气之间

            return present_model.stem;
        }else{
            
            if([present_model.sectional isEqualToString:@"立春"] && sectionalArray.count == 12){
                //说明当前日期在立春之前，属于上个回归年
                
                NSMutableArray *frontSectionArray = [NSMutableArray array];
                [frontSectionArray addObjectsFromArray:[self calutorSectionByYear:self.year - 1]];
                [frontSectionArray addObjectsFromArray:sectionalArray];
                
                sectionalArray = frontSectionArray;
                i = 0;
                continue;
            }
        }
    }
    
    return streamStr;
}

//计算对应年份的节气
- (NSMutableArray *)calutorSectionByYear:(NSInteger)c_year{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *c_date = [formatter dateFromString:[NSString stringWithFormat:@"%zd-7-6 8:00:00", c_year]];
    
    NSString *yearStream = [[self chinaStream:c_date.year] substringToIndex:1]; //先计算出年干支
    
    NSArray *tmp = @[@"甲己", @"乙庚", @"丙辛", @"丁壬", @"戊癸"];
    NSInteger indexOfMonth = 0;

    for(int i = 0;i < tmp.count;i ++){
       if([tmp[i] rangeOfString:yearStream].length > 0){
           indexOfMonth = i;
           break;
       }
    }

    NSArray *streamMonthArr = [monthStreamTable objectAtIndex:indexOfMonth];
    
    NSMutableArray *sectionalArray = [NSMutableArray array];
    
    int sectionIndex = 0;
    
    NSInteger sectionYear = c_year;
    NSInteger sectionMonth = 1;
    
    while (sectionalArray.count < 12) {
        
        int sectionDay = [self sectionalTerm:sectionYear month:sectionMonth];
        NSString *sectionalStr = sectionalTermNames[sectionMonth - 1];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        
        //这里需要注意，以当代计时标准，晚23:00过后就是子时了，干支就要按第二天的计算，所以这里的节气日要算作前一天晚上11点
        //例如：2020年2月4日 遇节：立春
        //则干支时间划分
        //2020年2月3日 23:00   之前前为：   己亥年丁丑月
        //2020年2月3日 23:00   之后则为：   庚子年戊寅月
        NSDate *date = [formatter dateFromString:[NSString stringWithFormat:@"%zd-%zd-%d 23:00:00", sectionYear, sectionMonth, sectionDay - 1]];
        
        if([sectionalStr isEqualToString:@"小寒"] && sectionalArray.count == 0){
            if(sectionMonth + 1 > 12){
                sectionYear += 1;
                sectionMonth = 1;
            }else{
                sectionMonth ++;
            }
            continue;
        }
        
        SectionalModel *model = [SectionalModel new];

        model.presentDate = date;
        model.sectional = sectionalStr;
        model.stem = streamMonthArr[sectionIndex];
        [sectionalArray addObject:model];
        
//        NSLog(@"Year:%zd  Month:%zd  Day:%zd  Hour:%zd", [date chineseYear], [date chineseMonth], [date chineseDay], [date chineseHour]);

        
        sectionIndex ++;
        
        if(sectionMonth + 1 > 12){
            sectionYear += 1;
            sectionMonth = 1;
        }else{
            sectionMonth ++;
        }
    }
    
    return sectionalArray;
}

- (NSString *)calculatDayStem{
    
     NSInteger year = [self year];
       NSInteger month = [self month];
       NSInteger day = [self day];
       NSInteger hour = [self hour];

       if(hour == 23){//注意，过了23点就是子时，要按第二天来计算
          return [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:([self timeIntervalSinceReferenceDate]+2*3600)].dayStream;
       }

       NSInteger center = year % 100 == 0? year/100 : year/100 + 1;
       //C = 世纪年数减去1
       NSInteger C = center -1;

       //1月和 2月按上一年的13月和14月来计算
       NSInteger M = month;
       if(month == 1 || month == 2){
          
          year -= 1;
          if(month == 1){
              M = 13;
          }else{
              M = 14;
          }
       }

       //y = 年份后两位
       NSInteger Y = year % 100;
       //d = 日期
       NSInteger D = day;

       NSInteger gz = 44*C + C/4 + 5*Y + Y/4 + 30 *(M + 1) + 3*(M+1)/5 + D + 7;
          
       return [dailyTable objectAtIndex:gz%60];
}

- (NSString *)calculatHourStem{
    
    //每日十二时辰与十二地支相配固定不变
    NSArray *timeStreamArr;
    NSString *dayStream = [[self dayStream] substringToIndex:1];

    //十个天干排列如下
    if([dayStream isEqualToString:@"甲"] || [dayStream isEqualToString:@"己"]){
        timeStreamArr = @[@"甲",@"乙",@"丙",@"丁",@"戊",@"己",@"庚",@"辛",@"壬",@"癸",@"甲",@"乙"];
    }else if([dayStream isEqualToString:@"乙"] || [dayStream isEqualToString:@"庚"]){
        timeStreamArr = @[@"丙",@"丁",@"戊",@"己",@"庚",@"辛",@"壬",@"癸",@"甲",@"乙",@"丙",@"丁"];
    }else if([dayStream isEqualToString:@"丙"] || [dayStream isEqualToString:@"辛"]){
        timeStreamArr = @[@"戊",@"己",@"庚",@"辛",@"壬",@"癸",@"甲",@"乙",@"丙",@"丁",@"戊",@"己"];
    }else if([dayStream isEqualToString:@"丁"] || [dayStream isEqualToString:@"壬"]){
        timeStreamArr = @[@"庚",@"辛",@"壬",@"癸",@"甲",@"乙",@"丙",@"丁",@"戊",@"己",@"庚",@"辛"];
    }else if([dayStream isEqualToString:@"戊"] || [dayStream isEqualToString:@"癸"]){
        timeStreamArr = @[@"壬",@"癸",@"甲",@"乙",@"丙",@"丁",@"戊",@"己",@"庚",@"辛",@"壬",@"癸"];
    }
    
    float hourFloatValue = (float)[self chineseHour];
    NSInteger hourIndex = ceilf(hourFloatValue / 2);//时/2并向上取整
    hourIndex = hourIndex > 11? 0:hourIndex;
        
    return [NSString stringWithFormat:@"%@%@", timeStreamArr[hourIndex], arrBranches[hourIndex]];
}

#pragma mark - 五行
- (NSString *)yearElement{
    
    return [self elementFromStream:[self yearStream]];
}

- (NSString *)monthElement{
    
    return [self elementFromStream:[self monthStream]];
}

- (NSString *)dayElement{
    
    return [self elementFromStream:[self dayStream]];
}

- (NSString *)hourElement{
    
    return [self elementFromStream:[self hourStream]];
}

- (NSString *)elementFromStream:(NSString *)stems{

    return [NSString stringWithFormat:@"%@%@", [StemsElementDic objectForKey:[stems substringToIndex:1]], [BranchesDic objectForKey:[stems substringFromIndex:1]]];
}

- (BOOL)bissextile{
    
    //判断当前年份是否为闰年
    //计算闰年的规律：四年一闰，百年不闰，四百年再闰
    //换算为算法：公历年份可以被4整除但不能被100整除的为闰年、可以被400整除的为闰年
    NSInteger year = [self year];
    
    if ((year%4==0 && year %100 !=0) || year%400==0) {
        return YES;
    }else {
        return NO;
    }
    return NO;
}

- (int)sectionalTerm:(NSInteger)year month:(NSInteger)month{

    NSInteger index = 0;
    NSInteger ry = year - baseYear + 1;
    while (ry >= [sectionalTermYear[month - 1][index] intValue]) {
        index++;
    }
    int term = [sectionalTermMap[month - 1][4 * index + ry % 4] intValue];
    if ((ry == 121) && (month == 4)){
        term = 5;
    }
    if ((ry == 132) && (month == 4)){
        term = 5;
    }
    if ((ry == 194) && (month == 6)){
        term = 6;
    }
    return term;
}

- (int)principleTerm:(NSInteger)year month:(NSInteger)month{

    int index = 0;
    NSInteger ry = year - baseYear + 1;
    while (ry >= [principleTermYear[month - 1][index] intValue]) {
        index++;
    }
    int term = [principleTermMap[month - 1][4 * index + ry % 4] intValue];
    if ((ry == 171) && (month == 3)){
        term = 21;
    }
    if ((ry == 181) && (month == 5)){
        term = 21;
    }
    return term;
}

@end
