import sys
import os

# Always find build/ relative to this file, regardless of where Python is run from
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "build"))

import ocular_cpp
import numpy as np

img = ocular_cpp.prepare_input_data('Images/2_left.jpg')

assert img.shape == (224, 224, 3), f'Bad shape: {img.shape}'
assert img.dtype == np.float32,    f'Bad dtype: {img.dtype}'
assert img.min() >= 0.0,           f'Min below 0: {img.min()}'
assert img.max() <= 1.0,           f'Max above 1: {img.max()}'

print(f'shape  : {img.shape}')
print(f'dtype  : {img.dtype}')
print(f'min    : {img.min():.4f}')
print(f'max    : {img.max():.4f}')
print('ALL CHECKS PASSED')