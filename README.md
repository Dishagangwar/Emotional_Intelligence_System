# 🌿Emotional Intelligence System

> From Understanding Humans → To Guiding Them



## 🚀 Overview

This system goes beyond traditional ML classification.

It:
- Understands user emotional state
- Predicts emotional intensity
- Suggests meaningful actions
- Decides when the user should act
- Handles uncertainty

---

## 🧠 Problem Statement

Given noisy user reflections and contextual signals (sleep, stress, energy), build a system that:

1. Predicts emotional state  
2. Predicts intensity (1–5)  
3. Suggests what to do  
4. Suggests when to do it  
5. Handles uncertainty  

---

## 🏗️ Approach

### 1. Hybrid Modeling
- Text features → TF-IDF (n-grams)
- Metadata → sleep, stress, energy, time

### 2. Model
- XGBoost Classifier for:
  - Emotional State
  - Intensity Prediction

### 3. Feature Engineering
- Text length
- Word count

### 4. Decision Layer (Core Innovation)
A rule-based system converts predictions into actions:
- stressed → breathing
- focused → deep work
- restless → grounding

### 5. Uncertainty Handling
- Confidence from prediction probabilities
- Uncertain flag for low confidence cases

### 6. Human-like Response
- Dynamic supportive messages
- Non-repetitive suggestions

---

## 📊 Results

- Accuracy: ~65–70%
- Robust to noisy and short inputs
- Handles real-world ambiguity

---

## ⚠️ Limitations

- Ambiguous text ("I'm fine")
- Short inputs ("ok", "hmm")
- Label noise
- Overlapping emotional classes

---

## 🔍 Error Analysis

Key failure cases:
- Conflicting signals (text vs stress)
- Short/unclear text
- Rare classes
- High intensity confusion

---

## 📦 Output Format

| id | predicted_state | predicted_intensity | confidence | uncertain_flag | what_to_do | when_to_do | support_message |

---

## 🧠 Key Insight

> Emotion is not just text — it is contextual and multi-dimensional.

---

## ⚙️ How to Run

```bash
pip install -r requirements.txt
python main.py
