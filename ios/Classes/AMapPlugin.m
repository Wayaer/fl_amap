#import "AMapPlugin.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapLocationKit/AMapLocationKit.h>


@interface AMapPlugin()<AMapLocationManagerDelegate,AMapGeoFenceManagerDelegate>

@end

@implementation AMapPlugin{
    AMapLocationManager *locationManager;
    AMapGeoFenceManager *geoFenceManager;
    AMapLocatingCompletionBlock completionBlock;
    FlutterMethodChannel *channel;
    FlutterResult result;
};

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"fl_amap"
                                     binaryMessenger:[registrar messenger]];
    AMapPlugin* amap = [[AMapPlugin alloc] initWithAMapPlugin:channel];
    [registrar addMethodCallDelegate:amap channel:channel];
    
}
- (instancetype)initWithAMapPlugin:(FlutterMethodChannel*)_channel{
    self = [super init];
    channel= _channel;
    return self;
}
- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)_result {
    result = _result;
    NSString* method = call.method;
    if([@"setApiKey" isEqualToString:method]){
        [AMapServices sharedServices].apiKey = call.arguments;
        result(@YES);
    } else if ([@"initLocation" isEqualToString:method]) {
        // 初始化定位系统
        result(@([self initLocation:call.arguments]));
    } else if([@"disposeLocation" isEqualToString:method]){
        // 关闭定位系统
        result(@([self disposeLocation]));
    } else if([@"getLocation" isEqualToString:method]){
        // 单次定位
        [self getLocation: [call.arguments boolValue] result:result];
    } else if([@"startLocation" isEqualToString:method]){
        // 开始监听位置
        if(locationManager){
            [locationManager startUpdatingLocation];
            result(@YES);
            return;
        }
        result(@NO);
    } else if([@"stopLocation" isEqualToString:method]){
        // 停止监听位置
        if(locationManager){
            [locationManager stopUpdatingLocation];
            result(@YES);
            return;
        }
        result(@NO);
    } else if([@"initGeoFence" isEqualToString:method]){
        geoFenceManager = [[AMapGeoFenceManager alloc] init];
        [geoFenceManager setDelegate:self];
        NSInteger type = [call.arguments[@"action"] intValue];
        if(type==0)geoFenceManager.activeAction = AMapGeoFenceActiveActionInside;
        if(type==1)geoFenceManager.activeAction = AMapGeoFenceActiveActionOutside;
        if(type==2)geoFenceManager.activeAction = AMapGeoFenceActiveActionInside|AMapGeoFenceActiveActionOutside;
        if(type==3)geoFenceManager.activeAction = AMapGeoFenceActiveActionInside|AMapGeoFenceActiveActionOutside|AMapGeoFenceActiveActionStayed;
        geoFenceManager.allowsBackgroundLocationUpdates = call.arguments[@"allowsBackgroundLocationUpdates"] ;
        result(@YES);
    } else if([@"disposeGeoFence" isEqualToString:method]){
        result(@([self disposeGeoFence]));
    } else if([@"pauseGeoFence" isEqualToString:method]){
        NSString *customID =call.arguments;
        NSArray *fences = [geoFenceManager pauseGeoFenceRegionsWithCustomID:customID];
        
        result(@YES);
        
    } else if([@"resumeGeoFence" isEqualToString:method]){
        NSString *customID =call.arguments;
        NSArray *fences = [geoFenceManager startGeoFenceRegionsWithCustomID:customID];
        
        result(@YES);
    } else if([@"getAllGeoFence" isEqualToString:method]){
        NSString * customID = call.arguments;
        
        NSArray *fences = [geoFenceManager geoFenceRegionsWithCustomID:customID==nil?nil:customID];
        result(@YES);
    } else if([@"addGeoFenceWithPOI" isEqualToString:method]){
        [geoFenceManager addKeywordPOIRegionForMonitoringWithKeyword:call.arguments[@"keyword"] POIType:call.arguments[@"type"] city:call.arguments[@"city"] size:[call.arguments[@"size"] intValue] customID:call.arguments[@"customID"]];
    } else if([@"addAMapGeoFenceWithLatLong" isEqualToString:method]){
        NSInteger latitude = [call.arguments[@"latitude"] doubleValue];
        NSInteger longitude = [call.arguments[@"longitude"] doubleValue];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        [geoFenceManager addAroundPOIRegionForMonitoringWithLocationPoint:coordinate aroundRadius:[call.arguments[@"aroundRadius"] doubleValue] keyword:call.arguments[@"keyword"] POIType:call.arguments[@"type"] size:[call.arguments[@"size"] intValue] customID:call.arguments[@"customID"]];
    } else if([@"addGeoFenceWithDistrict" isEqualToString:method]){
        [geoFenceManager addDistrictRegionForMonitoringWithDistrictName:call.arguments[@"keyword"] customID:call.arguments[@"customID"]];
    } else if([@"addCircleGeoFence" isEqualToString:method]){
        NSInteger latitude = [call.arguments[@"latitude"] doubleValue];
        NSInteger longitude = [call.arguments[@"longitude"] doubleValue];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        [geoFenceManager addCircleRegionForMonitoringWithCenter:coordinate radius:[call.arguments[@"size"] doubleValue] customID:call.arguments[@"customID"]];
    } else if([@"addCustomGeoFence" isEqualToString:method]){
        NSArray *latLongs = call.arguments[@"latLong"];
        NSInteger count= latLongs.count;
        CLLocationCoordinate2D *coorArr = malloc(sizeof(CLLocationCoordinate2D) * count);
        for(int i=0; i<count; i++){
            NSDictionary *latLong =  latLongs[i];
            NSInteger latitude = [latLong[@"latitude"] doubleValue];
            NSInteger longitude = [latLong[@"longitude"] doubleValue];
            coorArr[i] = CLLocationCoordinate2DMake(latitude, longitude);
        }
        free(coorArr);
        coorArr = NULL;
    } else if([@"removeTheGeoFence" isEqualToString:method]){
        //        [geoFenceManager removeTheGeoFenceRegion:];
    } else if([@"removeGeoFence" isEqualToString:method]){
        NSString *customID =call.arguments;
        if(customID){
            [geoFenceManager removeGeoFenceRegionsWithCustomID:customID];
        }else{
            [geoFenceManager removeAllGeoFenceRegions];
        }
        result(@YES);
    } else {
        result(FlutterMethodNotImplemented);
    }
}
////*****地理围栏******/

// 关闭围栏系统
-(BOOL)disposeGeoFence{
    if(geoFenceManager){
        [geoFenceManager removeAllGeoFenceRegions];
        [geoFenceManager setDelegate:nil];
        geoFenceManager = nil;
        return YES;
    }
    return NO;
}

// 获取围栏创建后的回调
// 在如下回调中知道创建的围栏是否成功，以及查看所创建围栏的具体内容
- (void)amapGeoFenceManager:(AMapGeoFenceManager *)manager didAddRegionForMonitoringFinished:(NSArray<AMapGeoFenceRegion *> *)regions customID:(NSString *)customID error:(NSError *)error {
    result(error ? @NO : @YES);
}
// 围栏状态改变时的回调
- (void)amapGeoFenceManager:(AMapGeoFenceManager *)manager didGeoFencesStatusChangedForRegion:(AMapGeoFenceRegion *)region customID:(NSString *)customID error:(NSError *)error {
    if (error) {
        AMapGeoFenceRegionStatus status = region.fenceStatus;
        NSInteger state=0;
        if(status == AMapGeoFenceRegionStatusInside)state=1;
        if(status == AMapGeoFenceRegionStatusOutside)state=2;
        if(status == AMapGeoFenceRegionStatusStayed)state=3;
        
        AMapGeoFenceRegionType regionType = region.regionType;
        NSInteger type = -1;
        if(regionType){
            if(regionType == AMapGeoFenceRegionTypeCircle)type=0;
            if(regionType == AMapGeoFenceRegionTypePolygon)type=1;
            if(regionType == AMapGeoFenceRegionTypePOI)type=2;
            if(regionType == AMapGeoFenceRegionTypeDistrict)type=3;
        }
        
        [channel invokeMethod:@"updateGeoFence" arguments:@{
            @"customID": customID,
            @"status": @(status),
            @"type": @(type),
            @"fenceId": region.identifier,
        }];
    }
}
// 地理围栏定位回调
- (void)amapLocationManager:(AMapGeoFenceManager *)manager doRequireTemporaryFullAccuracyAuth:(CLLocationManager *)locationManager completion:(void (^)(NSError *))completion {
    
}
////*****地理围栏******/



// 初始化定位参数
-(BOOL)initLocation:(NSDictionary*)args{
    if(!locationManager){
        locationManager = [[AMapLocationManager alloc] init];
        [locationManager setDelegate:self];
    }
    return [self initOption:args];
}

//关闭定位系统
-(BOOL)disposeLocation{
    if(locationManager){
        [locationManager stopUpdatingLocation];
        [locationManager setDelegate:nil];
        locationManager = nil;
        return YES;
    }
    return NO;
}
// 初始化定位参数
-(BOOL)initOption:(NSDictionary*)args{
    if(locationManager){
        //设置期望定位精度
        [locationManager setDesiredAccuracy:[ self getDesiredAccuracy: args[@"desiredAccuracy"]]];
        [locationManager setPausesLocationUpdatesAutomatically:[args[@"pausesLocationUpdatesAutomatically"] boolValue]];
        [locationManager setDistanceFilter: [args[@"distanceFilter"] doubleValue]];
        //设置在能不能再后台定位
        [locationManager setAllowsBackgroundLocationUpdates:[args[@"allowsBackgroundLocationUpdates"] boolValue]];
        //设置定位超时时间
        [locationManager setLocationTimeout:[args[@"locationTimeout"] integerValue]];
        //设置逆地理超时时间
        [locationManager setReGeocodeTimeout:[args[@"reGeocodeTimeout"] integerValue]];
        //定位是否需要逆地理信息
        [locationManager setLocatingWithReGeocode:[args[@"locatingWithReGeocode"] boolValue]];
        ///检测是否存在虚拟定位风险，默认为NO，不检测。 \n注意:设置为YES时，单次定位通过 AMapLocatingCompletionBlock 的error给出虚拟定位风险提示；连续定位通过 amapLocationManager:didFailWithError: 方法的error给出虚拟定位风险提示。error格式为error.domain==AMapLocationErrorDomain; error.code==AMapLocationErrorRiskOfFakeLocation;
        [locationManager setDetectRiskOfFakeLocation: [args[@"detectRiskOfFakeLocation"] boolValue ]];
        return YES;
    }
    return NO;
}

-(double)getDesiredAccuracy:(NSString*)str{
    if([@"kCLLocationAccuracyBest" isEqualToString:str]){
        return kCLLocationAccuracyBest;
    }else if([@"kCLLocationAccuracyNearestTenMeters" isEqualToString:str]){
        return kCLLocationAccuracyNearestTenMeters;
    }else if([@"kCLLocationAccuracyHundredMeters" isEqualToString:str]){
        return kCLLocationAccuracyHundredMeters;
    }else if([@"kCLLocationAccuracyKilometer" isEqualToString:str]){
        return kCLLocationAccuracyKilometer;
    }else{
        return kCLLocationAccuracyThreeKilometers;
    }
}

-(void)getLocation:(BOOL)withReGeocode result:(FlutterResult)result{
    completionBlock = ^(CLLocation *location, AMapLocationReGeocode *reGeocode, NSError *error){
        if (error != nil) {
            //定位错误：此时location和reGeocode没有返回值，不进行annotation的添加
            result(@{ @"code":@(error.code),@"description":error.localizedDescription, @"success":@NO });
        } else {
            //没有错误：location有返回值，reGeocode是否有返回值取决于是否进行逆地理操作，进行annotation的添加
            NSMutableDictionary* md = [[NSMutableDictionary alloc]initWithDictionary: [self location2map:location]  ];
            if (reGeocode) {
                [md addEntriesFromDictionary:[self reGeocode2map:reGeocode]];
                md[@"code"] = @0;
                md[@"success"] = @YES;
            } else{
                md[@"code"]=@(error.code);
                md[@"description"]=error.localizedDescription;
                md[@"success"] = @YES;
            }
            result(md);
        }
    };
    [locationManager requestLocationWithReGeocode:withReGeocode completionBlock:completionBlock];
}


-(id)checkNull:(NSObject*)value{
    return value == nil ? [NSNull null] : value;
}

-(NSDictionary*)location2map:(CLLocation *)location{
    return @{@"latitude": @(location.coordinate.latitude),
             @"longitude": @(location.coordinate.longitude),
             @"accuracy": @((location.horizontalAccuracy + location.verticalAccuracy)/2),
             @"altitude": @(location.altitude),
             @"speed": @(location.speed),
             @"timestamp": @(location.timestamp.timeIntervalSince1970),};
    
}

-(NSDictionary*)reGeocode2map:(AMapLocationReGeocode *)reGeocode{
    return @{@"formattedAddress":reGeocode.formattedAddress,
             @"country":reGeocode.country,
             @"province":reGeocode.province,
             @"city":reGeocode.city,
             @"district":reGeocode.district,
             @"cityCode":reGeocode.citycode,
             @"adCode":reGeocode.adcode,
             @"street":reGeocode.street,
             @"number":reGeocode.number,
             @"poiName":[self checkNull : reGeocode.POIName],
             @"aoiName":[self checkNull :reGeocode.AOIName],
    };
}

/**
 *  @brief 连续定位回调函数.注意：如果实现了本方法，则定位信息不会通过amapLocationManager:didUpdateLocation:方法回调。
 *  @param manager 定位 AMapLocationManager 类。
 *  @param location 定位结果。
 *  @param reGeocode 逆地理信息。
 */
- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location reGeocode:(AMapLocationReGeocode *)reGeocode{
    NSMutableDictionary* md = [[NSMutableDictionary alloc]initWithDictionary: [self location2map:location]];
    if(reGeocode) [md addEntriesFromDictionary:[self reGeocode2map:reGeocode ]];
    
    md[@"success"]=@YES;
    [channel invokeMethod:@"updateLocation" arguments:md];
}

/**
 *  @brief 定位权限状态改变时回调函数
 *  @param manager 定位 AMapLocationManager 类。
 *  @param status 定位权限状态。
 */
- (void)amapLocationManager:(AMapLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
}

/**
 *  @brief 当定位发生错误时，会调用代理的此方法。
 *  @param manager 定位 AMapLocationManager 类。
 *  @param error 返回的错误，参考 CLError 。
 */
- (void)amapLocationManager:(AMapLocationManager *)manager didFailWithError:(NSError *)error{
    [channel invokeMethod:@"updateLocation" arguments:@{ @"code":@(error.code),@"description":error.localizedDescription,@"success":@NO }];
    
}
@end
