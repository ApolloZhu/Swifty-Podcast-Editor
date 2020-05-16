//
// punctuator.swift
//
// This file was automatically generated and should not be edited.
//

import CoreML


/// Model Prediction Input Type
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public class punctuatorInput : MLFeatureProvider {

    /// embedding_1_input as 1 by 30 matrix of floats
    var embedding_1_input: MLMultiArray

    public var featureNames: Set<String> {
        get {
            return ["embedding_1_input"]
        }
    }

    public func featureValue(for featureName: String) -> MLFeatureValue? {
        if (featureName == "embedding_1_input") {
            return MLFeatureValue(multiArray: embedding_1_input)
        }
        return nil
    }

    public init(embedding_1_input: MLMultiArray) {
        self.embedding_1_input = embedding_1_input
    }
}

/// Model Prediction Output Type
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public class punctuatorOutput : MLFeatureProvider {

    /// Source provided by CoreML
    private let provider : MLFeatureProvider


    /// dense_1/Softmax as multidimensional array of floats
    public lazy var dense_1_Softmax: MLMultiArray = {
        [unowned self] in return self.provider.featureValue(for: "dense_1/Softmax")!.multiArrayValue
    }()!

    public var featureNames: Set<String> {
        return self.provider.featureNames
    }

    public func featureValue(for featureName: String) -> MLFeatureValue? {
        return self.provider.featureValue(for: featureName)
    }

    init(dense_1_Softmax: MLMultiArray) {
        self.provider = try! MLDictionaryFeatureProvider(dictionary: ["dense_1/Softmax" : MLFeatureValue(multiArray: dense_1_Softmax)])
    }

    init(features: MLFeatureProvider) {
        self.provider = features
    }
}


/// Class for model loading and prediction
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public class punctuator {
    var model: MLModel

    /// URL of model assuming it was installed in the same bundle as this class
    class var urlOfModelInThisBundle : URL {
        let bundle = Bundle(for: punctuator.self)
        return bundle.url(forResource: "punctuator", withExtension:"mlmodelc")!
    }

    /**
        Construct a model with explicit path to mlmodelc file
        - parameters:
           - url: the file url of the model
           - throws: an NSError object that describes the problem
    */
    init(contentsOf url: URL) throws {
        self.model = try MLModel(contentsOf: url)
    }

    /// Construct a model that automatically loads the model from the app's bundle
    public convenience init() {
        try! self.init(contentsOf: type(of:self).urlOfModelInThisBundle)
    }

    /**
        Construct a model with configuration
        - parameters:
           - configuration: the desired model configuration
           - throws: an NSError object that describes the problem
    */
    convenience init(configuration: MLModelConfiguration) throws {
        try self.init(contentsOf: type(of:self).urlOfModelInThisBundle, configuration: configuration)
    }

    /**
        Construct a model with explicit path to mlmodelc file and configuration
        - parameters:
           - url: the file url of the model
           - configuration: the desired model configuration
           - throws: an NSError object that describes the problem
    */
    init(contentsOf url: URL, configuration: MLModelConfiguration) throws {
        self.model = try MLModel(contentsOf: url, configuration: configuration)
    }

    /**
        Make a prediction using the structured interface
        - parameters:
           - input: the input to the prediction as punctuatorInput
        - throws: an NSError object that describes the problem
        - returns: the result of the prediction as punctuatorOutput
    */
    public func prediction(input: punctuatorInput) throws -> punctuatorOutput {
        return try self.prediction(input: input, options: MLPredictionOptions())
    }

    /**
        Make a prediction using the structured interface
        - parameters:
           - input: the input to the prediction as punctuatorInput
           - options: prediction options
        - throws: an NSError object that describes the problem
        - returns: the result of the prediction as punctuatorOutput
    */
    public func prediction(input: punctuatorInput, options: MLPredictionOptions) throws -> punctuatorOutput {
        let outFeatures = try model.prediction(from: input, options:options)
        return punctuatorOutput(features: outFeatures)
    }

    /**
        Make a prediction using the convenience interface
        - parameters:
            - embedding_1_input as 1 by 30 matrix of floats
        - throws: an NSError object that describes the problem
        - returns: the result of the prediction as punctuatorOutput
    */
    public func prediction(embedding_1_input: MLMultiArray) throws -> punctuatorOutput {
        let input_ = punctuatorInput(embedding_1_input: embedding_1_input)
        return try self.prediction(input: input_)
    }

    /**
        Make a batch prediction using the structured interface
        - parameters:
           - inputs: the inputs to the prediction as [punctuatorInput]
           - options: prediction options
        - throws: an NSError object that describes the problem
        - returns: the result of the prediction as [punctuatorOutput]
    */
    public func predictions(inputs: [punctuatorInput], options: MLPredictionOptions = MLPredictionOptions()) throws -> [punctuatorOutput] {
        let batchIn = MLArrayBatchProvider(array: inputs)
        let batchOut = try model.predictions(from: batchIn, options: options)
        var results : [punctuatorOutput] = []
        results.reserveCapacity(inputs.count)
        for i in 0..<batchOut.count {
            let outProvider = batchOut.features(at: i)
            let result =  punctuatorOutput(features: outProvider)
            results.append(result)
        }
        return results
    }
}
