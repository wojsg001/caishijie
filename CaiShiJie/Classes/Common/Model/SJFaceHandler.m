//
//  SJFaceHandler.m
//  CaiShiJie
//
//  Created by user on 16/10/21.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJFaceHandler.h"

#pragma mark - 正则列表

#define REGULAREXPRESSION_OPTION(regularExpression,regex,option) \
\
static inline NSRegularExpression * k##regularExpression() { \
static NSRegularExpression *_##regularExpression = nil; \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_##regularExpression = [[NSRegularExpression alloc] initWithPattern:(regex) options:(option) error:nil];\
});\
\
return _##regularExpression;\
}\

#define REGULAREXPRESSION(regularExpression,regex) REGULAREXPRESSION_OPTION(regularExpression,regex,NSRegularExpressionCaseInsensitive)

REGULAREXPRESSION(URLRegularExpression,@"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)")

REGULAREXPRESSION(PhoneNumerRegularExpression, @"\\d{3}-\\d{8}|\\d{3}-\\d{7}|\\d{4}-\\d{8}|\\d{4}-\\d{7}|1+[358]+\\d{9}|\\d{8}|\\d{7}")

REGULAREXPRESSION(EmailRegularExpression, @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}")

REGULAREXPRESSION(AtRegularExpression, @"@[\\u4e00-\\u9fa5\\w\\-]+")

//@"#([^\\#|.]+)#"
REGULAREXPRESSION_OPTION(PoundSignRegularExpression, @"#([\\u4e00-\\u9fa5\\w\\-]+)#", NSRegularExpressionCaseInsensitive)

//微信的表情符其实不是这种格式，这个格式的只是让人看起来更友好。。
REGULAREXPRESSION(EmojiRegularExpression, @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]")

//@"/:[\\w:~!@$&*()|+<>',?-]{1,8}" , // @"/:[\\x21-\\x2E\\x30-\\x7E]{1,8}" ，经过检测发现\w会匹配中文，好奇葩。
REGULAREXPRESSION(SlashEmojiRegularExpression, @"/:[\\x21-\\x2E\\x30-\\x7E]{1,8}")


static SJFaceHandler *instance = nil;

@implementation SJFaceHandler

+ (instancetype)sharedFaceHandler {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

- (NSArray *)getComputerFaceArray {
    NSArray *computerFaceArray = @[@"[惊讶]",@"[撇嘴]",@"[色]",@"[发呆]",@"[得意]",@"[害羞]",@"[闭嘴]",@"[睡]",@"[大哭]",@"[尴尬]",@"[发怒]",@"[调皮]",@"[呲牙]",@"[微笑]",@"[难过]",@"[酷]",@"[折磨]",@"[吐]",@"[偷笑]",@"[可爱]",@"[白眼]",@"[傲慢]",@"[饥饿]",@"[困]",@"[惊恐]",@"[流汗]",@"[憨笑]",@"[大兵]",@"[奋斗]",@"[疑问]",@"[嘘]",@"[晕]",@"[衰]",@"[骷髅]",@"[敲打]",@"[再见]",@"[发抖]",@"[爱情]",@"[跳跳]",@"[猪头]",@"[拥抱]",@"[蛋糕]",@"[闪电]",@"[炸弹]",@"[刀]",@"[足球]",@"[便便]",@"[咖啡]",@"[饭]",@"[玫瑰]",@"[凋谢]",@"[爱心]",@"[心碎]",@"[礼物]",@"[太阳]",@"[月亮]",@"[强]",@"[弱]",@"[握手]",@"[飞吻]",@"[怄火]",@"[西瓜]",@"[冷汗]",@"[抠鼻]",@"[鼓掌]",@"[溴大了]",@"[坏笑]",@"[左哼哼]",@"[右哼哼]",@"[哈欠]",@"[鄙视]",@"[委屈]",@"[快哭了]",@"[阴险]",@"[亲亲]",@"[吓]",@"[可怜]",@"[菜刀]",@"[啤酒]",@"[篮球]",@"[乒乓]",@"[示爱]",@"[瓢虫]",@"[抱拳]",@"[勾引]",@"[拳头]",@"[差劲]",@"[爱你]",@"[NO]",@"[OK]",@"[转圈]",@"[磕头]",@"[回头]",@"[跳绳]",@"[挥手]",@"[激动]",@"[街舞]",@"[献吻]",@"[左太极]",@"[右太极]",@"[领带]",@"[祈祷]",@"[金领]",@"[糖果]",@"[红包]",@"[切糕]",@"[十一]",@"[万圣节]",@"[给力]",@"[围巾]",@"[手套]",@"[圣诞袜]",@"[铃铛]",@"[圣诞帽]",@"[圣诞树]",@"[圣诞老人]",@"[巧克力]",@"[福到]",@"[礼炮]"];
    return computerFaceArray;
}

- (NSArray *)getPhoneFaceArray {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Expression" ofType:@"plist"];
    NSArray *phoneFaceArray = [NSArray arrayWithContentsOfFile:path];
    //SJLog(@"%@", phoneFaceArray);
    return phoneFaceArray;
}

- (NSDictionary *)getPhoneFaceDictionary {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ExpressionImage" ofType:@"plist"];
    NSDictionary *phoneFaceDictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    //SJLog(@"%@", phoneFaceDictionary);
    return phoneFaceDictionary;
}

/**
 *  归档为Plist
 */
- (void)initPlist
{
    //    NSString *testString = @"/::)/::~/::B/::|/:8-)/::</::$/::X/::Z/::'(/::-|/::@/::P/::D/::O/::(/::+/:--b/::Q/::T/:,@P/:,@-D/::d/:,@o/::g/:|-)/::!/::L/::>/::,@/:,@f/::-S/:?/:,@x/:,@@/::8/:,@!/:!!!/:xx/:bye/:wipe/:dig/:handclap/:&-(/:B-)/:<@/:@>/::-O/:>-|/:P-(/::'|/:X-)/::*/:@x/:8*/:pd/:<W>/:beer/:basketb/:oo/:coffee/:eat/:pig/:rose/:fade/:showlove/:heart/:break/:cake/:li/:bome/:kn/:footb/:ladybug/:shit/:moon/:sun/:gift/:hug/:strong/:weak/:share/:v/:@)/:jj/:@@/:bad/:lvu/:no/:ok/:love/:<L>/:jump/:shake/:<O>/:circle/:kotow/:turn/:skip/:oY";
    //    NSMutableArray *testArray = [NSMutableArray array];
    //    NSMutableDictionary *testDict = [NSMutableDictionary dictionary];
    //    [kSlashEmojiRegularExpression() enumerateMatchesInString:testString options:0 range:NSMakeRange(0, testString.length) usingBlock:^(NSTextCheckingResult *result, __unused NSMatchingFlags flags, __unused BOOL *stop) {
    //        [testArray addObject:[testString substringWithRange:result.range]];
    //        [testDict setObject:[NSString stringWithFormat:@"Expression_%u",testArray.count] forKey:[testString substringWithRange:result.range]];
    //    }];
    //
    //    NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    //    NSString *doc = [NSString stringWithFormat:@"%@/expression.plist",documentDir];
    //    NSLog(@"%@,length:%u",doc,testArray.count);
    //    if ([testArray writeToFile:doc atomically:YES]) {
    //        NSLog(@"归档expression.plist成功");
    //    }
    //    doc = [NSString stringWithFormat:@"%@/expressionImage.plist",documentDir];
    //    if ([testDict writeToFile:doc atomically:YES]) {
    //        NSLog(@"归档到expressionImage.plist成功");
    //    }
    
    NSString *testString = @"[微笑][撇嘴][色][发呆][得意][大哭][害羞][闭嘴][睡][大哭][尴尬][发怒][调皮][呲牙][惊讶][难过][酷][冷汗][折磨][吐][偷笑][可爱][白眼][傲慢][饥饿][困][惊恐][流汗][憨笑][大兵][奋斗][咒骂][疑问][嘘][晕][疯了][衰][骷髅][敲打][再见][擦汗][抠鼻][鼓掌][糗大了][坏笑][左哼哼][右哼哼][哈欠][鄙视][委屈][快哭了][阴险][亲亲][吓][可怜][菜刀][西瓜][啤酒][篮球][乒乓][咖啡][饭][猪头][玫瑰][凋谢][示爱][爱心][心碎][蛋糕][闪电][炸弹][刀][足球][瓢虫][便便][月亮][太阳][礼物][拥抱][强][弱][握手][胜利][抱拳][勾引][拳头][差劲][爱你][NO][OK][爱情][飞吻][跳跳][发抖][怄火][转圈][磕头][回头][跳绳][挥手][激动][街舞][献吻][左太极][右太极]";
    NSMutableArray *testArray = [NSMutableArray array];
    NSMutableDictionary *testDict = [NSMutableDictionary dictionary];
    [kEmojiRegularExpression() enumerateMatchesInString:testString options:0 range:NSMakeRange(0, testString.length) usingBlock:^(NSTextCheckingResult *result, __unused NSMatchingFlags flags, __unused BOOL *stop) {
        [testArray addObject:[testString substringWithRange:result.range]];
        [testDict setObject:[NSString stringWithFormat:@"Expression_%u",testArray.count] forKey:[testString substringWithRange:result.range]];
    }];
    NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *doc = [NSString stringWithFormat:@"%@/Expression.plist",documentDir];
    NSLog(@"%@,length:%u",doc,testArray.count);
    if ([testArray writeToFile:doc atomically:YES]) {
        NSLog(@"归档Expression.plist成功");
    }
    doc = [NSString stringWithFormat:@"%@/ExpressionImage.plist",documentDir];
    if ([testDict writeToFile:doc atomically:YES]) {
        NSLog(@"归档到ExpressionImage.plist成功");
    }
}

@end
