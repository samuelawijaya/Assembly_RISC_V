# Assembly_RISC_V
Projects and simulations I've done using RISC-V Assembly
## 🚦 Programs

### 1. Binary Clock
A digital clock that outputs a binary time representation on the LEDs.

**Features:**
- Uses a **clock divider** to slow down the 50 MHz FPGA clock to 1 Hz.
- Implements a **shift register counter** to increment seconds.
- Displays the binary count directly on the red LEDs (`LEDR`).
- Includes **reset** and **run/stop** control using push-buttons (`KEY`).

**Learning Highlights:**
- Clock division for human-readable timing.
- FSM-based control for reset and run states.
- Binary representation of time on physical hardware.

---

### 2. Variable Speed LED Counter
A programmable LED counter that cycles through LEDs at different speeds depending on switch input.

**Features:**
- Uses **switches (`SW`)** to set the counter speed (fast/medium/slow).
- Divides the 50 MHz FPGA clock into multiple selectable frequencies.
- Implements a **shift register** to cycle a single "on" LED across the outputs.
- Includes **pause/resume** control with push-buttons.

**Learning Highlights:**
- Parameterized **clock dividers** for variable speed.
- Practical use of **shift registers** to create moving LED effects.
- Simple FSM control for run/pause.

---
