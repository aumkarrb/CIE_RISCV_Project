#include <stdint.h>

#define K 3
#define TRAIN_SAMPLES 50
#define TEST_SAMPLES 10
#define FEATURES 4
#define NUM_CLASSES 3
#define FIXED_POINT_SHIFT 16
#define INT32_MAX 0x7FFFFFFF

typedef int32_t fixed16_16_t;
#define F_LIT(f) ((fixed16_16_t)((f) * (1 << FIXED_POINT_SHIFT)))

// ---------- Console Output ----------
void putchar(char c) {
    asm volatile (
        "mv a0, %0\n"
        "li a7, 11\n"
        "ecall"
        : : "r"(c) : "a0", "a7"
    );
}

void print_str(const char* s) {
    while (*s) putchar(*s++);
}

void print_nl() {
    putchar('\n');
}

void print_int(int val) {
    char buf[12];
    int i = 10;
    buf[11] = '\0';

    if (val == 0) {
        putchar('0');
        return;
    }

    int neg = 0;
    if (val < 0) {
        neg = 1;
        val = -val;
    }

    while (val && i) {
        buf[i--] = '0' + (val % 10);
        val /= 10;
    }

    if (neg) buf[i--] = '-';
    print_str(&buf[i + 1]);
}

// ---------- Fixed-Point Math ----------
static inline fixed16_16_t fixed_add(fixed16_16_t a, fixed16_16_t b) { return a + b; }
static inline fixed16_16_t fixed_sub(fixed16_16_t a, fixed16_16_t b) { return a - b; }
static inline fixed16_16_t fixed_mul(fixed16_16_t a, fixed16_16_t b) {
    return (fixed16_16_t)(((int64_t)a * b) >> FIXED_POINT_SHIFT);
}

// ---------- Training & Test Data ----------
static const fixed16_16_t training_data[TRAIN_SAMPLES][FEATURES] = {
    {F_LIT(5.1), F_LIT(3.5), F_LIT(1.4), F_LIT(0.2)},
    {F_LIT(4.9), F_LIT(3.0), F_LIT(1.4), F_LIT(0.2)},
    {F_LIT(4.7), F_LIT(3.2), F_LIT(1.3), F_LIT(0.2)},
    {F_LIT(4.6), F_LIT(3.1), F_LIT(1.5), F_LIT(0.2)},
    {F_LIT(5.0), F_LIT(3.6), F_LIT(1.4), F_LIT(0.2)},
    {F_LIT(5.4), F_LIT(3.9), F_LIT(1.7), F_LIT(0.4)},
    {F_LIT(4.6), F_LIT(3.4), F_LIT(1.4), F_LIT(0.3)},
    {F_LIT(5.0), F_LIT(3.4), F_LIT(1.5), F_LIT(0.2)},
    {F_LIT(4.4), F_LIT(2.9), F_LIT(1.4), F_LIT(0.2)},
    {F_LIT(4.9), F_LIT(3.1), F_LIT(1.5), F_LIT(0.1)},
    {F_LIT(5.4), F_LIT(3.7), F_LIT(1.5), F_LIT(0.2)},
    {F_LIT(4.8), F_LIT(3.4), F_LIT(1.6), F_LIT(0.2)},
    {F_LIT(4.8), F_LIT(3.0), F_LIT(1.4), F_LIT(0.1)},
    {F_LIT(4.3), F_LIT(3.0), F_LIT(1.1), F_LIT(0.1)},
    {F_LIT(5.8), F_LIT(4.0), F_LIT(1.2), F_LIT(0.2)},
    {F_LIT(5.7), F_LIT(4.4), F_LIT(1.5), F_LIT(0.4)},
    {F_LIT(7.0), F_LIT(3.2), F_LIT(4.7), F_LIT(1.4)},
    {F_LIT(6.4), F_LIT(3.2), F_LIT(4.5), F_LIT(1.5)},
    {F_LIT(6.9), F_LIT(3.1), F_LIT(4.9), F_LIT(1.5)},
    {F_LIT(5.5), F_LIT(2.3), F_LIT(4.0), F_LIT(1.3)},
    {F_LIT(6.5), F_LIT(2.8), F_LIT(4.6), F_LIT(1.5)},
    {F_LIT(5.7), F_LIT(2.8), F_LIT(4.5), F_LIT(1.3)},
    {F_LIT(6.3), F_LIT(3.3), F_LIT(4.7), F_LIT(1.6)},
    {F_LIT(4.9), F_LIT(2.4), F_LIT(3.3), F_LIT(1.0)},
    {F_LIT(6.6), F_LIT(2.9), F_LIT(4.6), F_LIT(1.3)},
    {F_LIT(5.2), F_LIT(2.7), F_LIT(3.9), F_LIT(1.4)},
    {F_LIT(5.0), F_LIT(2.0), F_LIT(3.5), F_LIT(1.0)},
    {F_LIT(5.9), F_LIT(3.0), F_LIT(4.2), F_LIT(1.5)},
    {F_LIT(6.0), F_LIT(2.2), F_LIT(4.0), F_LIT(1.0)},
    {F_LIT(6.1), F_LIT(2.9), F_LIT(4.7), F_LIT(1.4)},
    {F_LIT(6.3), F_LIT(3.3), F_LIT(6.0), F_LIT(2.5)},
    {F_LIT(5.8), F_LIT(2.7), F_LIT(5.1), F_LIT(1.9)},
    {F_LIT(7.1), F_LIT(3.0), F_LIT(5.9), F_LIT(2.1)},
    {F_LIT(6.3), F_LIT(2.9), F_LIT(5.6), F_LIT(1.8)},
    {F_LIT(6.5), F_LIT(3.0), F_LIT(5.8), F_LIT(2.2)},
    {F_LIT(7.6), F_LIT(3.0), F_LIT(6.6), F_LIT(2.1)},
    {F_LIT(4.9), F_LIT(2.5), F_LIT(4.5), F_LIT(1.7)},
    {F_LIT(7.3), F_LIT(2.9), F_LIT(6.3), F_LIT(1.8)},
    {F_LIT(6.7), F_LIT(2.5), F_LIT(5.8), F_LIT(1.8)},
    {F_LIT(7.2), F_LIT(3.6), F_LIT(6.1), F_LIT(2.5)},
    {F_LIT(6.2), F_LIT(2.8), F_LIT(4.8), F_LIT(1.8)},
    {F_LIT(6.1), F_LIT(3.0), F_LIT(4.9), F_LIT(1.8)},
    {F_LIT(6.4), F_LIT(2.8), F_LIT(5.6), F_LIT(2.1)},
    {F_LIT(7.2), F_LIT(3.0), F_LIT(5.8), F_LIT(1.6)},
    {F_LIT(7.4), F_LIT(2.8), F_LIT(6.1), F_LIT(1.9)},
    {F_LIT(7.9), F_LIT(3.8), F_LIT(6.4), F_LIT(2.0)},
    {F_LIT(6.4), F_LIT(2.8), F_LIT(5.6), F_LIT(2.2)},
};

static const int training_labels[TRAIN_SAMPLES] = {
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,
    2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
};

static const fixed16_16_t test_data[TEST_SAMPLES][FEATURES] = {
    {F_LIT(5.0), F_LIT(3.3), F_LIT(1.4), F_LIT(0.2)},
    {F_LIT(6.0), F_LIT(2.7), F_LIT(5.1), F_LIT(1.6)},
    {F_LIT(6.8), F_LIT(3.2), F_LIT(5.9), F_LIT(2.3)},
    {F_LIT(4.8), F_LIT(3.1), F_LIT(1.6), F_LIT(0.2)},
    {F_LIT(5.6), F_LIT(3.0), F_LIT(4.5), F_LIT(1.5)},
    {F_LIT(6.7), F_LIT(3.1), F_LIT(5.6), F_LIT(2.4)},
    {F_LIT(5.1), F_LIT(3.8), F_LIT(1.9), F_LIT(0.4)},
    {F_LIT(6.0), F_LIT(3.0), F_LIT(4.8), F_LIT(1.8)},
    {F_LIT(5.5), F_LIT(2.4), F_LIT(3.8), F_LIT(1.1)},
    {F_LIT(6.3), F_LIT(2.5), F_LIT(5.0), F_LIT(1.9)}
};

static const int expected_labels[TEST_SAMPLES] = {0,2,2,0,1,2,0,2,1,2};

int predicted_labels[TEST_SAMPLES] = {0};

// ---------- Core Algorithm ----------
static fixed16_16_t euclidean_distance_squared(const fixed16_16_t* a, const fixed16_16_t* b) {
    fixed16_16_t total = 0;
    for (int i = 0; i < FEATURES; ++i) {
        fixed16_16_t d = fixed_sub(a[i], b[i]);
        total = fixed_add(total, fixed_mul(d, d));
    }
    return total;
}

static int find_majority_class(const int* neighbor_labels) {
    int counts[NUM_CLASSES] = {0};
    for (int i = 0; i < K; ++i) counts[neighbor_labels[i]]++;
    int majority = 0, max = 0;
    for (int i = 0; i < NUM_CLASSES; ++i) {
        if (counts[i] > max) {
            max = counts[i];
            majority = i;
        }
    }
    return majority;
}

void k_nearest_neighbors() {
    for (int i = 0; i < TEST_SAMPLES; ++i) {
        fixed16_16_t neighbor_distances[K];
        int neighbor_indices[K], neighbor_labels[K];

        for (int k = 0; k < K; ++k) {
            neighbor_distances[k] = INT32_MAX;
            neighbor_indices[k] = -1;
        }

        for (int j = 0; j < TRAIN_SAMPLES; ++j) {
            fixed16_16_t dist = euclidean_distance_squared(test_data[i], training_data[j]);
            for (int k = 0; k < K; ++k) {
                if (dist < neighbor_distances[k]) {
                    for (int s = K - 1; s > k; --s) {
                        neighbor_distances[s] = neighbor_distances[s - 1];
                        neighbor_indices[s] = neighbor_indices[s - 1];
                    }
                    neighbor_distances[k] = dist;
                    neighbor_indices[k] = j;
                    break;
                }
            }
        }

        for (int k = 0; k < K; ++k)
            neighbor_labels[k] = training_labels[neighbor_indices[k]];

        predicted_labels[i] = find_majority_class(neighbor_labels);
    }
}

// ---------- Entry ----------
int main() {
    k_nearest_neighbors();

    print_str("\n--- Predictions ---\n");
    int correct = 0;
    for (int i = 0; i < TEST_SAMPLES; ++i) {
        print_str("Sample ");
        print_int(i);
        print_str(": Predicted ");
        print_int(predicted_labels[i]);
        print_str(", Expected ");
        print_int(expected_labels[i]);
        print_nl();
        if (predicted_labels[i] == expected_labels[i]) correct++;
    }

    int accuracy = (correct * 100) / TEST_SAMPLES;
    print_str("Accuracy: ");
    print_int(accuracy);
    print_str("%\n");

    while (1) {}
    return 0;
}
