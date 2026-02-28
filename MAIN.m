%% Simple MNIST CNN in MATLAB

clear; clc;

%% 1. Load Dataset
digitDatasetPath = fullfile(matlabroot, ...
    "toolbox","nnet","nndemos","nndatasets","DigitDataset");

imds = imageDatastore(digitDatasetPath, ...
    IncludeSubfolders=true, ...
    LabelSource="foldernames");

[imdsTrain, imdsTest] = splitEachLabel(imds, 0.8, "randomized");

%% 2. Define CNN Architecture

layers = [
    imageInputLayer([28 28 1], Normalization="rescale-zero-one")
    
    convolution2dLayer(3, 16, Padding="same")
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer(2, Stride=2)
    
    convolution2dLayer(3, 32, Padding="same")
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer(2, Stride=2)

    fullyConnectedLayer(10)
    softmaxLayer
    classificationLayer
];

%% 3. Training Options

options = trainingOptions("adam", ...
    MaxEpochs=10, ...
    MiniBatchSize=128, ...
    ValidationData=imdsTest, ...
    ValidationFrequency=30, ...
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

%% 6. Visualize Sample Predictions
idx = randperm(numel(imdsTest.Files), 9);
figure('Name', 'Sample Predictions', 'NumberTitle', 'off');
sgtitle('Random Test Samples with Predictions');

for i = 1:9
    subplot(3,3,i)
    I = readimage(imdsTest, idx(i));
    imshow(I)
    label = YPred(idx(i));
    actual = YTest(idx(i));
    
    if label == actual
        titleColor = 'g'; % Green for correct
    else
        titleColor = 'r'; % Red for incorrect
    end
    
    title(string(label), 'Color', titleColor);
end