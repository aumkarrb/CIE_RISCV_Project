#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <float.h>
#include <errno.h>
#include <time.h> // Include time.h for time measurement

#define MAX_LINE_LENGTH 2048
#define MAX_FEATURES 1000
#define MAX_FILENAME 256

// Data structures
typedef struct {
    double *features;
    double label; // Changed from int to double
    int num_features;
} DataPoint;

typedef struct {
    DataPoint *points;
    int num_points;
    int num_features;
} Dataset;

typedef struct {
    double distance;
    double label; // Changed from int to double
    int index;
} Neighbor;

// Function prototypes
int parse_arguments(int argc, char *argv[], char *train_file, char *test_file, 
                   char *output_file, int *k_value, double *threshold);
Dataset* load_csv_dataset(const char *filename);
Dataset* load_binary_dataset(const char *filename);
int save_binary_dataset(const Dataset *dataset, const char *filename);
void free_dataset(Dataset *dataset);
double euclidean_distance(const DataPoint *p1, const DataPoint *p2);
int compare_neighbors(const void *a, const void *b);
double knn_predict(const Dataset *train_data, const DataPoint *test_point, int k);
void run_classification(const Dataset *train_data, const Dataset *test_data, 
                       int k, double threshold, const char *output_file);
void print_usage(const char *program_name);
int count_csv_columns(const char *line);
char* trim_whitespace(char *str);

// Main function
int main(int argc, char *argv[]) {
    char train_file[MAX_FILENAME] = {0};
    char test_file[MAX_FILENAME] = {0};
    char output_file[MAX_FILENAME] = "results.txt";
    int k_value = 3;
    double threshold = 0.0; // Default threshold

    // Start time measurement
    clock_t start_time, end_time;
    double cpu_time_used;

    start_time = clock();

    // Parse command line arguments
    if (parse_arguments(argc, argv, train_file, test_file, output_file, &k_value, &threshold) != 0) {
        print_usage(argv[0]);
        return EXIT_FAILURE;
    }
    
    printf("Loading training dataset...\n");
    Dataset *train_data = NULL;
    
    // Determine file format and load training data
    char *ext = strrchr(train_file, '.');
    if (ext && strcmp(ext, ".csv") == 0) {
        train_data = load_csv_dataset(train_file);
    } else if (ext && strcmp(ext, ".bin") == 0) {
        train_data = load_binary_dataset(train_file);
    } else {
        fprintf(stderr, "Error: Unsupported file format for training file. Use .csv or .bin\n");
        return EXIT_FAILURE;
    }
    
    if (!train_data) {
        fprintf(stderr, "Error: Failed to load training dataset\n");
        return EXIT_FAILURE;
    }
    
    printf("Training dataset loaded: %d points, %d features\n", 
           train_data->num_points, train_data->num_features);
    
    printf("Loading test dataset...\n");
    Dataset *test_data = NULL;
    
    // Load test data
    ext = strrchr(test_file, '.');
    if (ext && strcmp(ext, ".csv") == 0) {
        test_data = load_csv_dataset(test_file);
    } else if (ext && strcmp(ext, ".bin") == 0) {
        test_data = load_binary_dataset(test_file);
    } else {
        fprintf(stderr, "Error: Unsupported file format for test file. Use .csv or .bin\n");
        free_dataset(train_data);
        return EXIT_FAILURE;
    }
    
    if (!test_data) {
        fprintf(stderr, "Error: Failed to load test dataset\n");
        free_dataset(train_data);
        return EXIT_FAILURE;
    }
    
    printf("Test dataset loaded: %d points, %d features\n", 
           test_data->num_points, test_data->num_features);
    
    // Validate feature compatibility
    if (train_data->num_features != test_data->num_features) {
        fprintf(stderr, "Error: Feature count mismatch between training (%d) and test (%d) datasets\n",
                train_data->num_features, test_data->num_features);
        free_dataset(train_data);
        free_dataset(test_data);
        return EXIT_FAILURE;
    }
    
    // Validate K value
    if (k_value <= 0 || k_value > train_data->num_points) {
        fprintf(stderr, "Error: K value (%d) must be between 1 and %d\n", 
                k_value, train_data->num_points);
        free_dataset(train_data);
        free_dataset(test_data);
        return EXIT_FAILURE;
    }
    
    // Validate threshold
    if (threshold < 0.0 || threshold > 1.0) {
        fprintf(stderr, "Error: Threshold value (%f) must be between 0.0 and 1.0\n", threshold);
        free_dataset(train_data);
        free_dataset(test_data);
        return EXIT_FAILURE;
    }
    
    // End time measurement for loading data
    end_time = clock();
    cpu_time_used = ((double) (end_time - start_time)) / CLOCKS_PER_SEC;
    printf("Time taken to load datasets: %.4f seconds\n", cpu_time_used);
    
    // Reset start time for classification
    start_time = clock();
    
    printf("Running K-NN classification with K=%d and threshold=%f...\n", k_value, threshold);
    run_classification(train_data, test_data, k_value, threshold, output_file);
    
    // End time measurement for classification
    end_time = clock();
    cpu_time_used = ((double) (end_time - start_time)) / CLOCKS_PER_SEC;
    printf("Time taken to run classification: %.4f seconds\n", cpu_time_used);
    
    // Cleanup
    free_dataset(train_data);
    free_dataset(test_data);
    
    printf("Classification complete. Results saved to %s\n", output_file);
    return EXIT_SUCCESS;
}

// Parse command line arguments
int parse_arguments(int argc, char *argv[], char *train_file, char *test_file, 
                   char *output_file, int *k_value, double *threshold) {
    if (argc < 5) {
        return -1;
    }
    
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-train") == 0 && i + 1 < argc) {
            strncpy(train_file, argv[++i], MAX_FILENAME - 1);
        } else if (strcmp(argv[i], "-test") == 0 && i + 1 < argc) {
            strncpy(test_file, argv[++i], MAX_FILENAME - 1);
        } else if (strcmp(argv[i], "-k") == 0 && i + 1 < argc) {
            *k_value = atoi(argv[++i]);
        } else if (strcmp(argv[i], "-threshold") == 0 && i + 1 < argc) {
            *threshold = atof(argv[++i]);
        } else if (strcmp(argv[i], "-output") == 0 && i + 1 < argc) {
            strncpy(output_file, argv[++i], MAX_FILENAME - 1);
        }
    }
    
    if (strlen(train_file) == 0 || strlen(test_file) == 0) {
        return -1;
    }
    
    return 0;
}

// Load dataset from CSV file
Dataset* load_csv_dataset(const char *filename) {
    FILE *file = fopen(filename, "r");
    if (!file) {
        fprintf(stderr, "Error: Cannot open file %s: %s\n", filename, strerror(errno));
        return NULL;
    }
    
    Dataset *dataset = malloc(sizeof(Dataset));
    if (!dataset) {
        fprintf(stderr, "Error: Memory allocation failed for dataset\n");
        fclose(file);
        return NULL;
    }
    
    char line[MAX_LINE_LENGTH];
    int capacity = 100;
    dataset->points = malloc(capacity * sizeof(DataPoint));
    dataset->num_points = 0;
    dataset->num_features = -1;
    
    if (!dataset->points) {
        fprintf(stderr, "Error: Memory allocation failed for data points\n");
        free(dataset);
        fclose(file);
        return NULL;
    }
    
    while (fgets(line, sizeof(line), file)) {
        // Skip empty lines
        char *trimmed = trim_whitespace(line);
        if (strlen(trimmed) == 0) continue;
        
        // Determine number of features from first valid line
        if (dataset->num_features == -1) {
            dataset->num_features = count_csv_columns(trimmed) - 1; // -1 for label
            if (dataset->num_features <= 0) {
                fprintf(stderr, "Error: Invalid CSV format - need at least 2 columns\n");
                free_dataset(dataset);
                fclose(file);
                return NULL;
            }
        }
        
        // Expand capacity if needed
        if (dataset->num_points >= capacity) {
            capacity *= 2;
            DataPoint *temp = realloc(dataset->points, capacity * sizeof(DataPoint));
            if (!temp) {
                fprintf(stderr, "Error: Memory reallocation failed\n");
                free_dataset(dataset);
                fclose(file);
                return NULL;
            }
            dataset->points = temp;
        }
        
        // Parse line
        DataPoint *point = &dataset->points[dataset->num_points];
        point->features = malloc(dataset->num_features * sizeof(double));
        point->num_features = dataset->num_features;
        
        if (!point->features) {
            fprintf(stderr, "Error: Memory allocation failed for features\n");
            free_dataset(dataset);
            fclose(file);
            return NULL;
        }
        
        char *token = strtok(trimmed, ",");
        int feature_idx = 0;
        int parse_error = 0;
        
        // Parse features
        while (token && feature_idx < dataset->num_features) {
            char *endptr;
            point->features[feature_idx] = strtod(token, &endptr);
            if (*endptr != '\0' && *endptr != '\n' && *endptr != '\r') {
                fprintf(stderr, "Error: Invalid numeric value '%s' at line %d\n", 
                        token, dataset->num_points + 1);
                parse_error = 1;
                break;
            }
            feature_idx++;
            token = strtok(NULL, ",");
        }
        
        // Parse label
        if (!parse_error && token) {
            char *endptr;
            point->label = strtod(token, &endptr);
            if (*endptr != '\0' && *endptr != '\n' && *endptr != '\r') {
                fprintf(stderr, "Error: Invalid label '%s' at line %d\n", 
                        token, dataset->num_points + 1);
                parse_error = 1;
            }
        } else if (!parse_error) {
            fprintf(stderr, "Error: Missing label at line %d\n", dataset->num_points + 1);
            parse_error = 1;
        }
        
        if (parse_error) {
            free(point->features);
            free_dataset(dataset);
            fclose(file);
            return NULL;
        }
        
        dataset->num_points++;
    }
    
    fclose(file);
    
    if (dataset->num_points == 0) {
        fprintf(stderr, "Error: No valid data points found in %s\n", filename);
        free_dataset(dataset);
        return NULL;
    }
    
    return dataset;
}

// Load dataset from binary file
Dataset* load_binary_dataset(const char *filename) {
    FILE *file = fopen(filename, "rb");
    if (!file) {
        fprintf(stderr, "Error: Cannot open binary file %s: %s\n", filename, strerror(errno));
        return NULL;
    }
    
    Dataset *dataset = malloc(sizeof(Dataset));
    if (!dataset) {
        fprintf(stderr, "Error: Memory allocation failed for dataset\n");
        fclose(file);
        return NULL;
    }
    
    // Read header
    if (fread(&dataset->num_points, sizeof(int), 1, file) != 1 || 
        fread(&dataset->num_features, sizeof(int), 1, file) != 1) {
        fprintf(stderr, "Error: Failed to read binary file header\n");
        free(dataset);
        fclose(file);
        return NULL;
    }
    
    // Validate header values
    if (dataset->num_points <= 0 || dataset->num_features <= 0 || 
        dataset->num_points > 1000000 || dataset->num_features > MAX_FEATURES) {
        fprintf(stderr, "Error: Invalid binary file format or corrupted data\n");
        free(dataset);
        fclose(file);
        return NULL;
    }
    
    // Allocate memory for data points
    dataset->points = malloc(dataset->num_points * sizeof(DataPoint));
    if (!dataset->points) {
        fprintf(stderr, "Error: Memory allocation failed for data points\n");
        free(dataset);
        fclose(file);
        return NULL;
    }
    
    // Read data points
    for (int i = 0; i < dataset->num_points; i++) {
        DataPoint *point = &dataset->points[i];
        point->num_features = dataset->num_features;
        point->features = malloc(dataset->num_features * sizeof(double));
        
        if (!point->features) {
            fprintf(stderr, "Error: Memory allocation failed for features\n");
            // Free previously allocated features
            for (int j = 0; j < i; j++) {
                free(dataset->points[j].features);
            }
            free(dataset->points);
            free(dataset);
            fclose(file);
            return NULL;
        }
        
        if (fread(point->features, sizeof(double), dataset->num_features, file) != dataset->num_features || 
            fread(&point->label, sizeof(double), 1, file) != 1) {
            fprintf(stderr, "Error: Failed to read data point %d from binary file\n", i);
            free_dataset(dataset);
            fclose(file);
            return NULL;
        }
    }
    
    fclose(file);
    return dataset;
}

// Save dataset to binary file
int save_binary_dataset(const Dataset *dataset, const char *filename) {
    FILE *file = fopen(filename, "wb");
    if (!file) {
        fprintf(stderr, "Error: Cannot create binary file %s: %s\n", filename, strerror(errno));
        return -1;
    }
    
    // Write header
    if (fwrite(&dataset->num_points, sizeof(int), 1, file) != 1 || 
        fwrite(&dataset->num_features, sizeof(int), 1, file) != 1) {
        fprintf(stderr, "Error: Failed to write binary file header\n");
        fclose(file);
        return -1;
    }
    
    // Write data points
    for (int i = 0; i < dataset->num_points; i++) {
        const DataPoint *point = &dataset->points[i];
        if (fwrite(point->features, sizeof(double), dataset->num_features, file) != dataset->num_features ||
            fwrite(&point->label, sizeof(double), 1, file) != 1) {
            fprintf(stderr, "Error: Failed to write data point %d to binary file\n", i);
            fclose(file);
            return -1;
        }
    }
    
    fclose(file);
    return 0;
}

// Free dataset memory
void free_dataset(Dataset *dataset) {
    if (!dataset) return;
    
    if (dataset->points) {
        for (int i = 0; i < dataset->num_points; i++) {
            if (dataset->points[i].features) {
                free(dataset->points[i].features);
            }
        }
        free(dataset->points);
    }
    
    free(dataset);
}

// Calculate Euclidean distance between two data points
double euclidean_distance(const DataPoint *p1, const DataPoint *p2) {
    double sum = 0.0;
    int min_features = p1->num_features < p2->num_features ? p1->num_features : p2->num_features;
    
    for (int i = 0; i < min_features; i++) {
        double diff = p1->features[i] - p2->features[i];
        sum += diff * diff;
    }
    
    return sqrt(sum);
}

// Compare function for sorting neighbors by distance
int compare_neighbors(const void *a, const void *b) {
    const Neighbor *na = (const Neighbor *)a;
    const Neighbor *nb = (const Neighbor *)b;
    
    if (na->distance < nb->distance) return -1;
    if (na->distance > nb->distance) return 1;
    return 0;
}

// Predict class label using K-NN algorithm with thresholding
double knn_predict(const Dataset *train_data, const DataPoint *test_point, int k) {
    // Allocate memory for all neighbors
    Neighbor *neighbors = malloc(train_data->num_points * sizeof(Neighbor));
    if (!neighbors) {
        fprintf(stderr, "Error: Memory allocation failed for neighbors\n");
        return -1;
    }
    
    // Calculate distances to all training points
    for (int i = 0; i < train_data->num_points; i++) {
        neighbors[i].distance = euclidean_distance(test_point, &train_data->points[i]);
        neighbors[i].label = train_data->points[i].label;
        neighbors[i].index = i;
    }
    
    // Sort neighbors by distance
    qsort(neighbors, train_data->num_points, sizeof(Neighbor), compare_neighbors);
    
    // Count votes from K nearest neighbors
    int max_label = 0;
    for (int i = 0; i < k; i++) {
        if (neighbors[i].label > max_label) {
            max_label = (int)neighbors[i].label;
        }
    }
    
    int *votes = calloc(max_label + 1, sizeof(int));
    if (!votes) {
        fprintf(stderr, "Error: Memory allocation failed for votes\n");
        free(neighbors);
        return -1;
    }
    
    for (int i = 0; i < k; i++) {
        votes[(int)neighbors[i].label]++;
    }
    
    // Find majority class
    int predicted_label = 0;
    int max_votes = 0;
    for (int i = 0; i <= max_label; i++) {
        if (votes[i] > max_votes) {
            max_votes = votes[i];
            predicted_label = i;
        }
    }
    
    free(neighbors);
    free(votes);
    return predicted_label;
}

// Run classification on test dataset with thresholding
void run_classification(const Dataset *train_data, const Dataset *test_data, 
                       int k, double threshold, const char *output_file) {
    FILE *output = fopen(output_file, "w");
    if (!output) {
        fprintf(stderr, "Error: Cannot create output file %s: %s\n", output_file, strerror(errno));
        return;
    }
    
    int correct = 0;
    
    fprintf(output, "Test_Point,Actual_Label,Predicted_Label,Correct\n");
    
    for (int i = 0; i < test_data->num_points; i++) {
        double predicted = knn_predict(train_data, &test_data->points[i], k);
        double actual = test_data->points[i].label;
        int is_correct = 0;
        
        // Apply thresholding to convert floating-point labels to discrete classes
        int actual_class = (actual > threshold) ? 1 : 0;
        int predicted_class = (predicted > threshold) ? 1 : 0;
        
        if (predicted_class == actual_class) {
            correct++;
            is_correct = 1;
        }
        
        fprintf(output, "%d,%f,%d,%s\n", i + 1, actual, predicted_class, 
                is_correct ? "Yes" : "No");
        
        if ((i + 1) % 100 == 0) {
            printf("Processed %d/%d test points...\n", i + 1, test_data->num_points);
        }
    }
    
    double accuracy = (double)correct / test_data->num_points * 100.0;
    
    fprintf(output, "\nClassification Summary:\n");
    fprintf(output, "Total test points: %d\n", test_data->num_points);
    fprintf(output, "Correct predictions: %d\n", correct);
    fprintf(output, "Incorrect predictions: %d\n", test_data->num_points - correct);
    fprintf(output, "Accuracy: %.2f%%\n", accuracy);
    fprintf(output, "K value used: %d\n", k);
    fprintf(output, "Threshold value: %.2f\n", threshold);
    
    printf("Accuracy: %.2f%% (%d/%d correct)\n", accuracy, correct, test_data->num_points);
    
    fclose(output);
}

// Print usage information
void print_usage(const char *program_name) {
    printf("Usage: %s -train <train_file> -test <test_file> [-k <k_value>] [-threshold <threshold>] [-output <output_file>]\n\n", program_name);
    printf("Required arguments:\n");
    printf("  -train <file>    Training dataset file (.csv or .bin)\n");
    printf("  -test <file>     Test dataset file (.csv or .bin)\n\n");
    printf("Optional arguments:\n");
    printf("  -k <value>       K value for KNN (default: 3)\n");
    printf("  -threshold <value> Threshold value for classification (default: 0.0)\n");
    printf("  -output <file>   Output file for results (default: results.txt)\n\n");
    printf("File formats:\n");
    printf("  CSV: feature1,feature2,...,featureN,label\n");
    printf("  Binary: Custom binary format with header\n\n");
    printf("Examples:\n");
    printf("  %s -train data.csv -test test.csv -k 5 -threshold 0.5\n", program_name);
    printf("  %s -train train.bin -test test.bin -k 7 -threshold 0.3 -output my_results.txt\n", program_name);    
}

// Count number of columns in CSV line
int count_csv_columns(const char *line) {
    int count = 1;
    for (int i = 0; line[i]; i++) {
        if (line[i] == ',') count++;
    }
    return count;
}

// Trim whitespace from string
char* trim_whitespace(char *str) {
    char *end;
    
    // Trim leading space
    while (*str == ' ' || *str == '\t' || *str == '\n' || *str == '\r') str++;
    
    if (*str == 0) return str;
    
    // Trim trailing space
    end = str + strlen(str) - 1;
    while (end > str && (*end == ' ' || *end == '\t' || *end == '\n' || *str == '\r')) end--;
    
    end[1] = '\0';
    return str;
}
