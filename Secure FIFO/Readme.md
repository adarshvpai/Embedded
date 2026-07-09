# Secure Asynchronous FIFO with Hardware Trojan Detection

A secure **Asynchronous First-In-First-Out (FIFO)** design implemented in **Verilog HDL** using **Xilinx Vivado 2025.2**. The project enables reliable clock domain crossing (CDC) while incorporating a lightweight runtime hardware Trojan detection framework based on feature extraction, rule-based analysis, and decision-tree classification.

---

## Overview

Asynchronous FIFOs are widely used to transfer data safely between modules operating under different clock domains. While conventional FIFO designs address synchronization and metastability issues, they remain vulnerable to malicious hardware modifications (Hardware Trojans).

This project extends a standard asynchronous FIFO by integrating a runtime monitoring framework capable of detecting abnormal behavior caused by hardware Trojans without affecting normal FIFO operation.

---

## Features

- Asynchronous FIFO implementation using dual-port memory
- Independent read and write clock domains
- Gray code pointer synchronization
- Two Flip-Flop synchronizers for CDC
- Full and Empty flag generation
- Runtime Hardware Trojan detection
- Feature extraction module
- Rule-based anomaly detection
- Decision Tree-based classification
- Security monitor with `trojan_alert` generation
- Behavioral simulation using Vivado XSIM

---

## Project Architecture

```
                  +-------------------------+
                  |    Write Controller     |
                  +-----------+-------------+
                              |
                         Binary Pointer
                              |
                      Gray Code Encoder
                              |
                     2-FF Synchronizer
                              |
+------------------------------------------------------------+
|                    Dual-Port FIFO Memory                   |
+------------------------------------------------------------+
                              |
                     2-FF Synchronizer
                              |
                      Gray Code Decoder
                              |
                  +-----------+-------------+
                  |     Read Controller     |
                  +-------------------------+

                         Runtime Monitoring
                 +------------------------------+
                 |      Feature Extractor        |
                 +--------------+---------------+
                                |
               +----------------+----------------+
               |                                 |
        Rule Checker                  Decision Tree
               |                                 |
               +----------------+----------------+
                                |
                        Security Monitor
                                |
                         trojan_alert
```

---

## Hardware Trojan Scenarios

The detection framework was validated against four hardware Trojan implementations.

### Trojan I – Write Pointer Reset

- Trigger: Write pointer reaches predefined value
- Effect: Pointer resets unexpectedly
- Detection: Pointer jump detected

---

### Trojan II – Read Pointer Reset

- Trigger: Valid read operation
- Effect: Read pointer reset causing repeated data
- Detection: Abnormal pointer transition

---

### Trojan III – Wrap-around MSB Manipulation

- Trigger: FIFO wrap-around
- Effect: Incorrect Full flag generation
- Detection: Illegal pointer behavior

---

### Trojan IV – Hybrid Attack

- Trigger: Pointer manipulation with data corruption
- Effect: Data integrity violation
- Detection: Feature extraction + Decision Tree

---

## Project Structure

```
secure_async_fifo/
│
├── async_fifo_top.v
├── write_controller.v
├── read_controller.v
├── gray_encoder.v
├── sync_2ff.v
├── fifo_memory.v
│
├── feature_extractor.v
├── rule_checker.v
├── decision_tree.v
├── security_monitor.v
│
├── tb_async_fifo.v
│
├── simulation/
│   ├── normal_operation.png
│   ├── trojan1.png
│   ├── trojan2.png
│   ├── trojan3.png
│   └── trojan4.png
│
├── paper/
│   └── Secure_Asynchronous_FIFO.pdf
│
└── README.md
```

---

## Simulation Environment

| Parameter | Value |
|-----------|-------|
| Language | Verilog HDL |
| Tool | Xilinx Vivado Design Suite 2025.2 |
| Simulator | Vivado XSIM |
| Target FPGA | Artix-7 (xc7a35tcsg324-1L) |

---

## Verification

The design was verified under:

- Normal FIFO operation
- Write Pointer Reset Trojan
- Read Pointer Reset Trojan
- Wrap-around MSB Manipulation Trojan
- Hybrid Pointer/Data Corruption Trojan

The `trojan_alert` signal was successfully asserted for all malicious scenarios while remaining low during normal FIFO operation.

---

## Detection Flow

```
FIFO Signals
      │
      ▼
Feature Extraction
      │
      ▼
Rule Checker ───────┐
                    │
Decision Tree ──────┤
                    ▼
           Security Monitor
                    │
                    ▼
             trojan_alert
```

---

## Results

- Reliable asynchronous data transfer
- Correct Full/Empty flag generation
- Successful detection of all implemented Trojan scenarios
- No false alarms during normal FIFO operation
- Lightweight runtime monitoring with minimal impact on FIFO functionality

---

## Applications

- FPGA-based Systems
- Network-on-Chip (NoC)
- Secure Embedded Systems
- Clock Domain Crossing Designs
- Safety-Critical Digital Systems
- Hardware Security Research

---

## Future Improvements

- FPGA hardware validation
- Advanced machine learning-based detection
- Power and area optimization
- Support for additional Hardware Trojan classes
- Integration with NoC architectures
- Automatic recovery and mitigation mechanisms

---

## Author

**Adarsh V Pai**

Department of Electronics and Communication Engineering  
Amrita Vishwa Vidyapeetham

---

## License

This project is intended for academic and research purposes.
