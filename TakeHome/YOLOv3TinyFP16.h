//
// YOLOv3TinyFP16.h
//
// This file was automatically generated and should not be edited.
//

#import <Foundation/Foundation.h>
#import <CoreML/CoreML.h>
#include <stdint.h>
#include <os/log.h>

NS_ASSUME_NONNULL_BEGIN


/// Model Prediction Input Type
API_AVAILABLE(macos(10.14), ios(12.0), watchos(5.0), tvos(12.0)) __attribute__((visibility("hidden")))
@interface YOLOv3TinyFP16Input : NSObject<MLFeatureProvider>

/// 416x416 RGB image as color (kCVPixelFormatType_32BGRA) image buffer, 416 pixels wide by 416 pixels high
@property (readwrite, nonatomic) CVPixelBufferRef image;

/// This defines the radius of suppression. as optional double value
@property (readwrite, nonatomic, strong, nullable) NSNumber * iouThreshold;

/// Remove bounding boxes below this threshold (confidences should be nonnegative). as optional double value
@property (readwrite, nonatomic, strong, nullable) NSNumber * confidenceThreshold;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithImage:(CVPixelBufferRef)image;
- (instancetype)initWithImage:(CVPixelBufferRef)image iouThreshold:(nullable NSNumber *)iouThreshold confidenceThreshold:(nullable NSNumber *)confidenceThreshold NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)initWithImageFromCGImage:(CGImageRef)image error:(NSError * _Nullable __autoreleasing * _Nullable)error API_AVAILABLE(macos(10.15), ios(13.0), watchos(6.0), tvos(13.0)) __attribute__((visibility("hidden")));
- (nullable instancetype)initWithImageFromCGImage:(CGImageRef)image iouThreshold:(nullable NSNumber *)iouThreshold confidenceThreshold:(nullable NSNumber *)confidenceThreshold error:(NSError * _Nullable __autoreleasing * _Nullable)error API_AVAILABLE(macos(10.15), ios(13.0), watchos(6.0), tvos(13.0)) __attribute__((visibility("hidden")));

- (nullable instancetype)initWithImageAtURL:(NSURL *)imageURL error:(NSError * _Nullable __autoreleasing * _Nullable)error API_AVAILABLE(macos(10.15), ios(13.0), watchos(6.0), tvos(13.0)) __attribute__((visibility("hidden")));
- (nullable instancetype)initWithImageAtURL:(NSURL *)imageURL iouThreshold:(nullable NSNumber *)iouThreshold confidenceThreshold:(nullable NSNumber *)confidenceThreshold error:(NSError * _Nullable __autoreleasing * _Nullable)error API_AVAILABLE(macos(10.15), ios(13.0), watchos(6.0), tvos(13.0)) __attribute__((visibility("hidden")));

-(BOOL)setImageWithCGImage:(CGImageRef)image error:(NSError * _Nullable __autoreleasing * _Nullable)error  API_AVAILABLE(macos(10.15), ios(13.0), watchos(6.0), tvos(13.0)) __attribute__((visibility("hidden")));
-(BOOL)setImageWithURL:(NSURL *)imageURL error:(NSError * _Nullable __autoreleasing * _Nullable)error  API_AVAILABLE(macos(10.15), ios(13.0), watchos(6.0), tvos(13.0)) __attribute__((visibility("hidden")));
@end


/// Model Prediction Output Type
API_AVAILABLE(macos(10.14), ios(12.0), watchos(5.0), tvos(12.0)) __attribute__((visibility("hidden")))
@interface YOLOv3TinyFP16Output : NSObject<MLFeatureProvider>

/// Confidence derived for each of the bounding boxes.  as multidimensional array of doubles
@property (readwrite, nonatomic, strong) MLMultiArray * confidence;

/// Normalised coordiantes (relative to the image size) for each of the bounding boxes (x,y,w,h).  as multidimensional array of doubles
@property (readwrite, nonatomic, strong) MLMultiArray * coordinates;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithConfidence:(MLMultiArray *)confidence coordinates:(MLMultiArray *)coordinates NS_DESIGNATED_INITIALIZER;

@end


/// Class for model loading and prediction
API_AVAILABLE(macos(10.14), ios(12.0), watchos(5.0), tvos(12.0)) __attribute__((visibility("hidden")))
@interface YOLOv3TinyFP16 : NSObject
@property (readonly, nonatomic, nullable) MLModel * model;

/**
    URL of the underlying .mlmodelc directory.
*/
+ (nullable NSURL *)URLOfModelInThisBundle;

/**
    Initialize YOLOv3TinyFP16 instance from an existing MLModel object.

    Usually the application does not use this initializer unless it makes a subclass of YOLOv3TinyFP16.
    Such application may want to use `-[MLModel initWithContentsOfURL:configuration:error:]` and `+URLOfModelInThisBundle` to create a MLModel object to pass-in.
*/
- (instancetype)initWithMLModel:(MLModel *)model NS_DESIGNATED_INITIALIZER;

/**
    Initialize YOLOv3TinyFP16 instance with the model in this bundle.
*/
- (nullable instancetype)init;

/**
    Initialize YOLOv3TinyFP16 instance with the model in this bundle.

    @param configuration The model configuration object
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
*/
- (nullable instancetype)initWithConfiguration:(MLModelConfiguration *)configuration error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/**
    Initialize YOLOv3TinyFP16 instance from the model URL.

    @param modelURL URL to the .mlmodelc directory for YOLOv3TinyFP16.
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
*/
- (nullable instancetype)initWithContentsOfURL:(NSURL *)modelURL error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/**
    Initialize YOLOv3TinyFP16 instance from the model URL.

    @param modelURL URL to the .mlmodelc directory for YOLOv3TinyFP16.
    @param configuration The model configuration object
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
*/
- (nullable instancetype)initWithContentsOfURL:(NSURL *)modelURL configuration:(MLModelConfiguration *)configuration error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/**
    Construct YOLOv3TinyFP16 instance asynchronously with configuration.
    Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

    @param configuration The model configuration
    @param handler When the model load completes successfully or unsuccessfully, the completion handler is invoked with a valid YOLOv3TinyFP16 instance or NSError object.
*/
+ (void)loadWithConfiguration:(MLModelConfiguration *)configuration completionHandler:(void (^)(YOLOv3TinyFP16 * _Nullable model, NSError * _Nullable error))handler API_AVAILABLE(macos(11.0), ios(14.0), watchos(7.0), tvos(14.0)) __attribute__((visibility("hidden")));

/**
    Construct YOLOv3TinyFP16 instance asynchronously with URL of .mlmodelc directory and optional configuration.

    Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

    @param modelURL The model URL.
    @param configuration The model configuration
    @param handler When the model load completes successfully or unsuccessfully, the completion handler is invoked with a valid YOLOv3TinyFP16 instance or NSError object.
*/
+ (void)loadContentsOfURL:(NSURL *)modelURL configuration:(MLModelConfiguration *)configuration completionHandler:(void (^)(YOLOv3TinyFP16 * _Nullable model, NSError * _Nullable error))handler API_AVAILABLE(macos(11.0), ios(14.0), watchos(7.0), tvos(14.0)) __attribute__((visibility("hidden")));

/**
    Make a prediction using the standard interface
    @param input an instance of YOLOv3TinyFP16Input to predict from
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
    @return the prediction as YOLOv3TinyFP16Output
*/
- (nullable YOLOv3TinyFP16Output *)predictionFromFeatures:(YOLOv3TinyFP16Input *)input error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/**
    Make a prediction using the standard interface
    @param input an instance of YOLOv3TinyFP16Input to predict from
    @param options prediction options
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
    @return the prediction as YOLOv3TinyFP16Output
*/
- (nullable YOLOv3TinyFP16Output *)predictionFromFeatures:(YOLOv3TinyFP16Input *)input options:(MLPredictionOptions *)options error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/**
    Make a prediction using the convenience interface
    @param image 416x416 RGB image as color (kCVPixelFormatType_32BGRA) image buffer, 416 pixels wide by 416 pixels high:
    @param iouThreshold This defines the radius of suppression. as optional double value:
    @param confidenceThreshold Remove bounding boxes below this threshold (confidences should be nonnegative). as optional double value:
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
    @return the prediction as YOLOv3TinyFP16Output
*/
- (nullable YOLOv3TinyFP16Output *)predictionFromImage:(CVPixelBufferRef)image iouThreshold:(nullable NSNumber *)iouThreshold confidenceThreshold:(nullable NSNumber *)confidenceThreshold error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/**
    Batch prediction
    @param inputArray array of YOLOv3TinyFP16Input instances to obtain predictions from
    @param options prediction options
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
    @return the predictions as NSArray<YOLOv3TinyFP16Output *>
*/
- (nullable NSArray<YOLOv3TinyFP16Output *> *)predictionsFromInputs:(NSArray<YOLOv3TinyFP16Input*> *)inputArray options:(MLPredictionOptions *)options error:(NSError * _Nullable __autoreleasing * _Nullable)error;
@end

NS_ASSUME_NONNULL_END
