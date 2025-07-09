## knn_algo contains the basic implementation of the KNN algorithm on the assembly language. This is yet to be improvised for further indepth analysis.

## For the sake of the project goals and demonstration purposes, We will be using MNIST "Digits" Dataset for testing. However, the code is designed to perform on other existing datasets as well.


## The KNN_full_complete.s is the complete working code for 10 train and 1 test image. I have explored the possible inaccuracy factors, when it comes to voting stage, here not all K-NN will have majority/ multiple labels, thereby leading to no prediction methodology. This is covered by FALLBACK that ensures such a case is handled by default chosing the nearest neighbour's label as the predicted label.

## mnist_dataset.s contains the .byte initialised memory values.

## In the actual demo implementation
- Predicted Label-->  Computed in `x8` + stored in register `x14`
- Votes Array --> Likely at `0x100022e6` (10 × 4-byte entries).
- Actual Labels--> Stored at `0x10002090` (10 bytes, one per test case).


