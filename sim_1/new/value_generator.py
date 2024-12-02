import os
import numpy as np
import pandas as pd

os.chdir(os.path.dirname(__file__))

SAMPLES = 1
ADC_SAMPLES = 256 * SAMPLES
ADC_TEST_BITS = 8 * ADC_SAMPLES

SAMPLE = np.array([np.random.randint(0, 2) for _ in range(8)]).astype('int32')

VALUES_PATH = '/'.join("C:\\Users\\diogo\\OneDrive\\UofC\\ENEL453\\Lab_7\\Lab_7.srcs\\sim_1\\new\\value.txt".split("\\"))

values = np.zeros(ADC_TEST_BITS).astype('int32')
for i in range(ADC_SAMPLES):
    line = SAMPLE
    index = np.random.randint(6, 8)
    line[index] = not SAMPLE[index]
    print(line)
    for j,k  in enumerate(line):
        values[i * 8 + j] = k
print()
print(SAMPLE)

df = pd.DataFrame(values)
print(VALUES_PATH)

with open('values.txt', 'w') as f:
    for i in values:
        f.write(f"\t\t#INDEX_DELAY; comp_r2r = {i};\n")
