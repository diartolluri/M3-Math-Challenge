%% Simple MNIST MLP in MATLAB

clear; clc;

%% 1. Load Dataset
digitDatasetPath = fullfile(matlabroot, ...
    "toolbox","nnet","nndemos","nndatasets","DigitDataset");

imds = imageDatastore(digitDatasetPath, ...
    IncludeSubfolders=true, ...
    LabelSource="foldernames");

[imdsTrain, imdsTest] = splitEachLabel(imds, 0.8, "randomized");

%% 2. Define MLP Architecture

layers = [
    imageInputLayer([28 28 1], Normalization="rescale-zero-one")

    fullyConnectedLayer(128)
    reluLayer

    fullyConnectedLayer(64)
    reluLayer

    fullyConnectedLayer(10)
    softmaxLayer
    classificationLayer
];

%% 3. Training Options

options = trainingOptions("adam", ...
    MaxEpochs=5, ...
    MiniBatchSize=128, ...
    Shuffle="every-epoch", ...
    Plots="training-progress", ...
    Verbose=false);

%% 4. Train Network

net = trainNetwork(imdsTrain, layers, options);

%% 5. Evaluate

YPred = classify(net, imdsTest);
YTest = imdsTest.Labels;

accuracy = mean(YPred == YTest);

fprintf("Test Accuracy: %.2f%%\n", accuracy*100)