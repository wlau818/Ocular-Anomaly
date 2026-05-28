# Ocular Anomaly Detection
*In short: Project on detecting anomalies in ocular images*

A deep learning pipeline for detecting glaucoma and other ocular diseases from retinal fundus images. The project combines a C++ image preprocessing backend (via pybind11 + OpenCV) with a PyTorch ResNet50 classifier trained on the ODIR-5K and EyePACS-AIROGS datasets.

---

## What it does

- Classifies retinal fundus images as **healthy or non-healthy**
- Identifies specific conditions including **glaucoma**, diabetic retinopathy, cataract, AMD, hypertension, and pathological myopia
- Uses a native C++ preprocessing engine to load, resize, and normalize images at high throughput
- Produces Grad-CAM heatmaps to highlight which regions of the image influenced the model's decision

---

## Project structure

```
Ocular-Anomaly/
├── src/
│   └── main.cpp                        # C++ image preprocessing (OpenCV + pybind11)
├── Images/                             # Retinal fundus images (not committed to git)
├── data/
│   ├── full_df.csv                     # ODIR-5K metadata
│   └── metadata.csv                    # EyePACS-AIROGS metadata
├── build/                              # C++ compiled output (not committed to git)
├── Ocular_Anomaly_Detection.ipynb      # Data preparation and model training notebook
├── test_cpp.py                         # C++ module verification script
├── CMakeLists.txt                      # C++ build configuration
├── pyproject.toml                      # Python package config (scikit-build-core)
└── requirements.txt                    # Python dependencies
```

---

## Setup

### Requirements

- Python 3.10+
- CMake >= 3.15
- OpenCV (via Homebrew on Mac: `brew install opencv`)
- A virtual environment

### Install

```bash
git clone https://github.com/wlau818/Ocular-Anomaly.git
cd Ocular-Anomaly

python -m venv .venv
source .venv/bin/activate       # Mac/Linux
# .venv\Scripts\activate        # Windows

pip install -r requirements.txt
```

### Build the C++ module

**Mac:**
```bash
mkdir -p build && cd build
cmake -DPYTHON_EXECUTABLE=$(which python) \
      -Dpybind11_DIR=$(python -m pybind11 --cmakedir) \
      ..
make -j$(sysctl -n hw.logicalcpu)
cd ..
```

**Linux:**
```bash
mkdir -p build && cd build
cmake -DPYTHON_EXECUTABLE=$(which python) \
      -Dpybind11_DIR=$(python -m pybind11 --cmakedir) \
      ..
make -j$(nproc)
cd ..
```

**Windows (PowerShell):**
```powershell
mkdir build; cd build
cmake -DPYTHON_EXECUTABLE=$(python -c "import sys; print(sys.executable)") `
      -Dpybind11_DIR=$(python -m pybind11 --cmakedir) `
      ..
cmake --build . --config Release
cd ..
```

### Verify the build

```bash
python test_cpp.py
# Expected output:
# shape  : (224, 224, 3)
# dtype  : float32
# min    : 0.0000
# max    : 1.0000
# ALL CHECKS PASSED
```

---

## Datasets

| Dataset | Size | Labels | Source |
|---|---|---|---|
| ODIR-5K | 8,000 images | Normal, Diabetes, Glaucoma, Cataract, AMD, Hypertension, Myopia, Other | [Kaggle](https://www.kaggle.com/datasets/andrewmvd/ocular-disease-recognition-odir5k) |
| EyePACS-AIROGS Light v2 | ~9,500 images | RG (glaucoma), NRG (no glaucoma) | [Kaggle](https://www.kaggle.com/datasets/deathtrooper/glaucoma-dataset-eyepacs-airogs-light-v2) |

Images are downloaded via `kagglehub` and stored locally in `Images/`. They are excluded from git via `.gitignore`.

---

## C++ preprocessing API

The `ocular_cpp` module is built from `src/main.cpp` and exposes one function:

**`ocular_cpp.prepare_input_data(path: str) -> numpy.ndarray`**

Loads a retinal image from disk, converts BGR → RGB, resizes to 224×224, normalizes pixel values to `[0, 1]`, and returns a `(224, 224, 3)` float32 NumPy array ready for model input.

```python
import sys
sys.path.insert(0, "build/")
import ocular_cpp

img = ocular_cpp.prepare_input_data("Images/0_left.jpg")
print(img.shape)   # (224, 224, 3)
print(img.dtype)   # float32
```

---

## Training

Model training is done in Google Colab using a GPU runtime. The notebook `Ocular_Anomaly_Detection.ipynb` handles:

- Data loading and train/val/test splitting (70/10/20)
- PyTorch Dataset and DataLoader setup
- ResNet50 fine-tuning (pretrained ImageNet weights, binary classification head)
- Training and validation loops with loss and accuracy tracking
- Model checkpointing — best weights saved to Google Drive during training

---

## Evaluation metrics

| Metric | Purpose |
|---|---|
| Accuracy | Overall classification correctness |
| AUC-ROC | Primary metric; robust to class imbalance |
| F1-Score | Balance of precision and recall |
| Sensitivity / Specificity | Clinical validation |
| Confusion Matrix | Per-class breakdown |
| Grad-CAM | Visual explanation of model predictions |

---

## CI

GitHub Actions runs on every push to `main`:

- Installs system dependencies (OpenCV, CMake)
- Builds the C++ module
- Executes the notebook end-to-end via `nbconvert`

See `.github/workflows/OcularCI.yml` for the full pipeline.

---

## Contributors

- Alexandria Lim
- Winnie Lau
