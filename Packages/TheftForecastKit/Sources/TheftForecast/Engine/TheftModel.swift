//  TheftModel.swift
//
//  Wraps the bundled Core ML model `AutoTheftRegressor.mlmodel`.
//
//  Xcode compiles the model into `AutoTheftRegressor.mlmodelc` when building the app,
//  while `swift build`/`swift test` copy the raw `.mlmodel`; the loader accepts either and
//  compiles the raw file at runtime (milliseconds for a linear model). The generic
//  `MLModel` API is used instead of Xcode's generated class so both builds share one path.
//  Predictions run as one batch per month for all 158 neighbourhoods.

import CoreML
import Foundation
import TheftForecastInterface

/// The Core ML auto-theft regression: 20 inputs in, predicted thefts out.
struct TheftModel {
    private let model: MLModel
    private let inputCount: Int

    /// Compiles and loads the bundled model.
    ///
    /// - Parameter expectedInputCount: Number of variables the app will send; checked against the model.
    /// - Throws: `TheftForecastError.resourcesUnavailable` if the model is missing, fails to compile,
    ///   or expects a different number of inputs.
    init(expectedInputCount: Int) async throws {
        do {
            if let compiledURL = Bundle.module.url(forResource: "AutoTheftRegressor", withExtension: "mlmodelc") {
                model = try MLModel(contentsOf: compiledURL)
            } else if let rawURL = Bundle.module.url(forResource: "AutoTheftRegressor", withExtension: "mlmodel") {
                model = try MLModel(contentsOf: try await MLModel.compileModel(at: rawURL))
            } else {
                throw TheftForecastError.resourcesUnavailable("AutoTheftRegressor.mlmodel is missing from the bundle")
            }
        } catch let error as TheftForecastError {
            throw error
        } catch {
            throw TheftForecastError.resourcesUnavailable("Core ML: \(error.localizedDescription)")
        }
        let shape: [NSNumber]? = model.modelDescription.inputDescriptionsByName["features"]?
            .multiArrayConstraint?.shape
        guard shape?.first?.intValue == expectedInputCount else {
            throw TheftForecastError.resourcesUnavailable("model expects \(shape ?? []) inputs, app sends \(expectedInputCount)")
        }
        inputCount = expectedInputCount
    }

    /// Predicts thefts for many rows at once.
    ///
    /// - Parameter rows: Feature rows, each with `expectedInputCount` values in model order.
    /// - Returns: Predicted thefts per row, clipped at 0 like the notebook.
    /// - Throws: `TheftForecastError.resourcesUnavailable` if Core ML rejects the batch.
    func predict(_ rows: [[Double]]) throws -> [Double] {
        do {
            let inputs: [MLFeatureProvider] = try rows.map(makeInput)
            let outputs: MLBatchProvider = try model.predictions(
                from: MLArrayBatchProvider(array: inputs), options: MLPredictionOptions()
            )
            return (0..<outputs.count).map { index -> Double in
                max(0, outputs.features(at: index).featureValue(for: "thefts")?.doubleValue ?? 0)
            }
        } catch {
            throw TheftForecastError.resourcesUnavailable("Core ML prediction: \(error.localizedDescription)")
        }
    }

    private func makeInput(_ row: [Double]) throws -> MLFeatureProvider {
        precondition(row.count == inputCount, "feature row has \(row.count) values, model needs \(inputCount)")
        let array: MLMultiArray = try MLMultiArray(shape: [NSNumber(value: inputCount)], dataType: .double)
        for (index, value) in row.enumerated() {
            array[index] = NSNumber(value: value)
        }
        return try MLDictionaryFeatureProvider(dictionary: ["features": MLFeatureValue(multiArray: array)])
    }
}
