## 📂 Programs

### 1. Binary Clock (`BinaryClock.s`)
A simple binary clock that uses the timer peripheral to count in hundredths of a second and seconds, then displays the value on the LEDs.

**Key Features:**
- Uses **polling** of the edge-capture register for push-button input.
- Timer configured to tick every 0.01 seconds.
- Increments a hundredth-second counter (`s9`) and second counter (`s8`).
- Combines both counters into a binary representation displayed on the red LEDs (`LEDR`).
- Resets after 8 seconds for demonstration.

**Concepts Demonstrated:**
- Timer configuration and polling.
- Binary counting across multiple time bases.
- Memory-mapped I/O (LEDs, keys, timer).

---

### 2. Variable-Speed LED Counter (`VariableSpeedLEDCounter.s`)
An LED counter that supports **variable speed control and run/pause functionality** using interrupts.

**Key Features:**
- **Interrupt-driven** (uses `mcause` to distinguish between timer interrupts and key interrupts).
- Timer controls the LED update rate, adjustable with push-buttons:
  - **KEY0** → Toggle run/pause.
  - **KEY1** → Speed up (halve timer period).
  - **KEY2** → Slow down (double timer period).
- Counter value is written to LEDs (`LEDR`).
- Maintains a **RUN flag** in memory to track paused/active state.
- Stack and registers preserved inside the interrupt handler.

**Concepts Demonstrated:**
- Interrupt handling in RISC-V (`mtvec`, `mcause`, `mie`, `mstatus`).
- Timer configuration for continuous operation.
- Push-button edge-capture and event handling.
- Low-level control of speed and state with global variables.

---
